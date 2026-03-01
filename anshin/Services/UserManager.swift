//
//  UserManager.swift
//  anshin
//
//  ユーザー管理とアプリ内共有機能を提供するサービス
//

import Foundation
import CryptoKit

class UserManager {
    static let shared = UserManager()

    private let userDefaultsKey = "anshin_current_user"
    private let allUsersKey = "anshin_all_users"
    private let passwordsKey = "anshin_user_passwords"
    private let shareRequestsKey = "anshin_share_requests"
    private let sharedFriendListsKey = "anshin_shared_friend_lists"
    private let partnerRequestsKey = "anshin_partner_requests"
    private let friendSharesKey = "anshin_friend_shares"
    private let shareNotificationsKey = "anshin_share_notifications"

    private init() {}

    // MARK: - Current User Management

    var currentUser: User? {
        get {
            guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        set {
            if let user = newValue {
                if let data = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(data, forKey: userDefaultsKey)
                }
                // 全ユーザーリストにも保存
                saveUserToAllUsers(user)
            } else {
                UserDefaults.standard.removeObject(forKey: userDefaultsKey)
            }
        }
    }

    func createUser(displayName: String) -> User {
        let user = User(displayName: displayName)
        currentUser = user
        return user
    }

    func createUserWithPassword(displayName: String, userId: String, email: String, password: String) -> Bool {
        // 既存のユーザーIDチェック
        if findUser(byId: userId) != nil {
            return false
        }

        // メールアドレスの重複チェック
        if !email.isEmpty && findUserByEmail(email: email) != nil {
            return false
        }

        // カスタムIDでユーザー作成
        let user = User(id: userId, displayName: displayName, email: email, createdAt: Date(), lastLoginAt: Date())

        // パスワードハッシュ化
        let hashedPassword = hashPassword(password)

        // ユーザー保存
        saveUserToAllUsers(user)

        // パスワード保存
        savePassword(for: userId, password: hashedPassword)

        return true
    }

    func loginUser(userId: String, password: String) -> Bool {
        guard let user = findUser(byId: userId),
              verifyPassword(password, for: userId) else {
            return false
        }

        // ログイン時間更新
        var updatedUser = user
        updatedUser.lastLoginAt = Date()
        currentUser = updatedUser
        saveUserToAllUsers(updatedUser)

        return true
    }

    func updateCurrentUser(displayName: String) -> Bool {
        guard var user = currentUser else { return false }
        user.displayName = displayName
        user.lastLoginAt = Date()
        currentUser = user
        return true
    }

    // MARK: - All Users Management

    private func saveUserToAllUsers(_ user: User) {
        var allUsers = getAllUsers()
        if let index = allUsers.firstIndex(where: { $0.id == user.id }) {
            allUsers[index] = user
        } else {
            allUsers.append(user)
        }

        if let data = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(data, forKey: allUsersKey)
        }
    }

    func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: allUsersKey) else { return [] }
        return (try? JSONDecoder().decode([User].self, from: data)) ?? []
    }

    func findUser(byId id: String) -> User? {
        return getAllUsers().first { $0.id == id }
    }

    func findUserByEmail(email: String) -> User? {
        return getAllUsers().first { $0.email.lowercased() == email.lowercased() }
    }

    func searchUsers(byId searchId: String) -> [User] {
        let allUsers = getAllUsers()
        return allUsers.filter { user in
            user.id.lowercased().contains(searchId.lowercased()) && user.id != currentUser?.id
        }
    }

    // MARK: - Share Request Management

    func sendShareRequest(toUserId: String, friendIds: [UUID]) -> Bool {
        guard let currentUser = currentUser else { return false }
        guard findUser(byId: toUserId) != nil else { return false }

        let request = ShareRequest(
            fromUserId: currentUser.id,
            fromUserName: currentUser.displayName,
            toUserId: toUserId,
            friendIds: friendIds
        )

        var requests = getShareRequests()
        requests.append(request)

        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: shareRequestsKey)
            return true
        }

        return false
    }

    func getShareRequests() -> [ShareRequest] {
        guard let data = UserDefaults.standard.data(forKey: shareRequestsKey) else { return [] }
        return (try? JSONDecoder().decode([ShareRequest].self, from: data)) ?? []
    }

    func getIncomingRequests() -> [ShareRequest] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getShareRequests().filter { $0.toUserId == currentUserId && $0.status == .pending }
    }

    func getOutgoingRequests() -> [ShareRequest] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getShareRequests().filter { $0.fromUserId == currentUserId }
    }

    func respondToShareRequest(requestId: UUID, approved: Bool, friendManager: FriendManager) -> Bool {
        var requests = getShareRequests()
        guard let index = requests.firstIndex(where: { $0.id == requestId }) else { return false }

        var request = requests[index]
        request.status = approved ? .approved : .rejected
        request.respondedAt = Date()
        requests[index] = request

        // 承認された場合は共有友達リストを作成
        if approved {
            let allFriends = friendManager.getAllFriends()
            let sharedFriends = allFriends.filter { friend in
                request.friendIds.contains(friend.id)
            }

            let sharedList = SharedFriendList(shareRequest: request, friends: sharedFriends)
            addSharedFriendList(sharedList)
        }

        // リクエストリストを更新
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: shareRequestsKey)
            return true
        }

        return false
    }

    // MARK: - Shared Friend Lists Management

    private func addSharedFriendList(_ sharedList: SharedFriendList) {
        var lists = getSharedFriendLists()
        lists.append(sharedList)

        if let data = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(data, forKey: sharedFriendListsKey)
        }
    }

    func getSharedFriendLists() -> [SharedFriendList] {
        guard let data = UserDefaults.standard.data(forKey: sharedFriendListsKey) else { return [] }
        return (try? JSONDecoder().decode([SharedFriendList].self, from: data)) ?? []
    }

    func getSharedListsForCurrentUser() -> [SharedFriendList] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getSharedFriendLists().filter { $0.fromUserId != currentUserId }
    }

    func getSharedListsByCurrentUser() -> [SharedFriendList] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getSharedFriendLists().filter { $0.fromUserId == currentUserId }
    }

    // MARK: - Helper Methods

    func hasCurrentUser() -> Bool {
        return currentUser != nil
    }

    func logout() {
        currentUser = nil
    }

    func deleteUser(userId: String) {
        // ユーザー削除
        var allUsers = getAllUsers()
        allUsers.removeAll { $0.id == userId }

        if let data = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(data, forKey: allUsersKey)
        }

        // パスワード削除
        removePassword(for: userId)

        // 現在のユーザーが削除対象の場合はログアウト
        if currentUser?.id == userId {
            currentUser = nil
        }
    }

    // MARK: - Password Management

    private func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func verifyPassword(_ password: String, for userId: String) -> Bool {
        guard let storedPassword = getPassword(for: userId) else { return false }
        let hashedInputPassword = hashPassword(password)
        return hashedInputPassword == storedPassword
    }

    private func savePassword(for userId: String, password: String) {
        var passwords = getPasswordDictionary()
        passwords[userId] = password

        if let data = try? JSONEncoder().encode(passwords) {
            UserDefaults.standard.set(data, forKey: passwordsKey)
        }
    }

    private func getPassword(for userId: String) -> String? {
        let passwords = getPasswordDictionary()
        return passwords[userId]
    }

    private func removePassword(for userId: String) {
        var passwords = getPasswordDictionary()
        passwords.removeValue(forKey: userId)

        if let data = try? JSONEncoder().encode(passwords) {
            UserDefaults.standard.set(data, forKey: passwordsKey)
        }
    }

    private func getPasswordDictionary() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: passwordsKey) else { return [:] }
        return (try? JSONDecoder().decode([String: String].self, from: data)) ?? [:]
    }

    // MARK: - Partner Management

    func sendPartnerRequest(toUserId: String) -> Bool {
        guard let currentUser = currentUser else { return false }
        guard currentUser.id != toUserId else { return false }
        guard findUser(byId: toUserId) != nil else { return false }

        // 既存のパートナー関係をチェック
        if isPartnerConnected(userId: toUserId) {
            return false
        }

        // 既存のpending状態のリクエストがある場合は削除（再送を可能にする）
        var existingRequests = getPartnerRequests()
        let existingPendingRequests = existingRequests.filter { request in
            request.status == .pending &&
            ((request.fromUserId == currentUser.id && request.toUserId == toUserId) ||
             (request.fromUserId == toUserId && request.toUserId == currentUser.id))
        }

        // 既存のpendingリクエストを削除
        if !existingPendingRequests.isEmpty {
            existingRequests.removeAll { request in
                existingPendingRequests.contains { $0.id == request.id }
            }

            // 更新されたリクエスト一覧を保存
            if let data = try? JSONEncoder().encode(existingRequests) {
                UserDefaults.standard.set(data, forKey: partnerRequestsKey)
            }
        }

        let request = PartnerRequest(
            fromUserId: currentUser.id,
            fromUserName: currentUser.displayName,
            toUserId: toUserId
        )

        var requests = getPartnerRequests()
        requests.append(request)

        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: partnerRequestsKey)
            return true
        }

        return false
    }

    func getPartnerRequests() -> [PartnerRequest] {
        guard let data = UserDefaults.standard.data(forKey: partnerRequestsKey) else { return [] }
        return (try? JSONDecoder().decode([PartnerRequest].self, from: data)) ?? []
    }

    func getIncomingPartnerRequests() -> [PartnerRequest] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getPartnerRequests().filter { $0.toUserId == currentUserId && $0.status == .pending }
    }

    func getOutgoingPartnerRequests() -> [PartnerRequest] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getPartnerRequests().filter { $0.fromUserId == currentUserId }
    }

    func respondToPartnerRequest(requestId: UUID, accepted: Bool) -> Bool {
        print("DEBUG: UserManager.respondToPartnerRequest開始")
        print("DEBUG: リクエストID: \(requestId)")
        print("DEBUG: 承認/拒否: \(accepted)")

        var requests = getPartnerRequests()
        print("DEBUG: 全リクエスト数: \(requests.count)")

        // デバッグ用：全リクエストのIDを出力
        for (idx, req) in requests.enumerated() {
            print("DEBUG: リクエスト[\(idx)] ID: \(req.id), ステータス: \(req.status)")
        }

        guard let index = requests.firstIndex(where: { $0.id == requestId }) else {
            print("DEBUG: リクエストが見つかりません")
            print("DEBUG: 検索対象ID: \(requestId)")
            return false
        }

        print("DEBUG: リクエストを発見 - インデックス: \(index)")

        var request = requests[index]
        print("DEBUG: 元のリクエスト状態: \(request.status)")
        request.status = accepted ? .accepted : .rejected
        request.respondedAt = Date()
        requests[index] = request
        print("DEBUG: 新しいリクエスト状態: \(request.status)")

        // 承認された場合はパートナー関係を作成
        if accepted {
            print("DEBUG: パートナー関係を作成中...")
            let partner = Partner(userId: request.fromUserId, userName: request.fromUserName)
            addPartner(partner)
            print("DEBUG: 自分のパートナーリストに追加完了")

            // 相手側にも自分をパートナーとして追加
            if let currentUser = currentUser {
                print("DEBUG: 相手側にパートナーとして追加中...")
                let reversePartner = Partner(userId: currentUser.id, userName: currentUser.displayName)
                addPartnerForUser(userId: request.fromUserId, partner: reversePartner)
                print("DEBUG: 相手側への追加完了")
            }
        }

        // リクエストリストを更新
        if let data = try? JSONEncoder().encode(requests) {
            UserDefaults.standard.set(data, forKey: partnerRequestsKey)
            print("DEBUG: リクエストリスト更新成功")
            return true
        }

        print("DEBUG: リクエストリスト更新失敗")
        return false
    }

    private func addPartner(_ partner: Partner) {
        guard let currentUserId = currentUser?.id else { return }

        var allPartnerships = getAllPartnerships()
        if allPartnerships[currentUserId] == nil {
            allPartnerships[currentUserId] = []
        }
        allPartnerships[currentUserId]?.append(partner)

        if let data = try? JSONEncoder().encode(allPartnerships) {
            UserDefaults.standard.set(data, forKey: "anshin_all_partnerships")
        }
    }

    private func addPartnerForUser(userId: String, partner: Partner) {
        // 他のユーザーのパートナーリストに追加する場合の処理
        // 現在の実装では同一デバイス内でのパートナー管理のため、グローバルなパートナー管理が必要
        var allPartnerships = getAllPartnerships()
        if allPartnerships[userId] == nil {
            allPartnerships[userId] = []
        }
        allPartnerships[userId]?.append(partner)

        if let data = try? JSONEncoder().encode(allPartnerships) {
            UserDefaults.standard.set(data, forKey: "anshin_all_partnerships")
        }
    }

    private func getAllPartnerships() -> [String: [Partner]] {
        guard let data = UserDefaults.standard.data(forKey: "anshin_all_partnerships") else { return [:] }
        return (try? JSONDecoder().decode([String: [Partner]].self, from: data)) ?? [:]
    }

    func getPartners() -> [Partner] {
        guard let currentUserId = currentUser?.id else { return [] }
        let allPartnerships = getAllPartnerships()
        return allPartnerships[currentUserId] ?? []
    }

    func getConnectedPartners() -> [Partner] {
        return getPartners().filter { $0.status == .connected }
    }

    func isPartnerConnected(userId: String) -> Bool {
        return getConnectedPartners().contains { $0.userId == userId }
    }

    func getPartnerStatus(userId: String) -> PartnerStatus? {
        let allPartners = getPartners()
        return allPartners.first { $0.userId == userId }?.status
    }

    func hasPendingPartnerRequest(userId: String) -> Bool {
        guard let currentUserId = currentUser?.id else { return false }
        let requests = getPartnerRequests()
        return requests.contains { request in
            request.status == .pending &&
            ((request.fromUserId == currentUserId && request.toUserId == userId) ||
             (request.fromUserId == userId && request.toUserId == currentUserId))
        }
    }

    func disconnectPartner(userId: String) -> Bool {
        guard let currentUserId = currentUser?.id else { return false }

        var allPartnerships = getAllPartnerships()
        if var partners = allPartnerships[currentUserId] {
            if let index = partners.firstIndex(where: { $0.userId == userId }) {
                partners[index].status = .disconnected
                allPartnerships[currentUserId] = partners

                if let data = try? JSONEncoder().encode(allPartnerships) {
                    UserDefaults.standard.set(data, forKey: "anshin_all_partnerships")
                    return true
                }
            }
        }
        return false
    }

    func getPartnerForSharing() -> Partner? {
        let connectedPartners = getConnectedPartners()
        return connectedPartners.first // 最初の連携パートナーを返す（複数パートナー対応は将来の拡張）
    }

    // MARK: - Friend Share Management

    func shareFriends(toUserId: String, friends: [Friend], purpose: String, location: String, dateTime: Date) -> Bool {
        guard let currentUser = currentUser else { return false }
        guard let toUser = findUser(byId: toUserId) else { return false }

        // パートナー関係をチェック
        if !isPartnerConnected(userId: toUserId) {
            return false
        }

        let friendShare = FriendShare(
            fromUserId: currentUser.id,
            fromUserName: currentUser.displayName,
            toUserId: toUserId,
            friends: friends,
            purpose: purpose,
            location: location,
            dateTime: dateTime
        )

        // 共有を保存
        var shares = getFriendShares()
        shares.append(friendShare)

        if let data = try? JSONEncoder().encode(shares) {
            UserDefaults.standard.set(data, forKey: friendSharesKey)

            // 通知を作成
            createShareNotification(for: friendShare)
            return true
        }

        return false
    }

    private func createShareNotification(for share: FriendShare) {
        let notification = ShareNotification(share: share)

        var notifications = getShareNotifications()
        notifications.append(notification)

        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: shareNotificationsKey)
        }
    }

    func getFriendShares() -> [FriendShare] {
        guard let data = UserDefaults.standard.data(forKey: friendSharesKey) else { return [] }
        return (try? JSONDecoder().decode([FriendShare].self, from: data)) ?? []
    }

    func getSharedFriendsForCurrentUser() -> [FriendShare] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getFriendShares().filter { $0.toUserId == currentUserId }
    }

    func getShareNotifications() -> [ShareNotification] {
        guard let data = UserDefaults.standard.data(forKey: shareNotificationsKey) else { return [] }
        return (try? JSONDecoder().decode([ShareNotification].self, from: data)) ?? []
    }

    func getUnreadNotificationsForCurrentUser() -> [ShareNotification] {
        guard let currentUserId = currentUser?.id else { return [] }
        return getShareNotifications().filter { $0.toUserId == currentUserId && !$0.isRead }
    }

    func markNotificationAsRead(notificationId: UUID) -> Bool {
        var notifications = getShareNotifications()
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true

            if let data = try? JSONEncoder().encode(notifications) {
                UserDefaults.standard.set(data, forKey: shareNotificationsKey)
                return true
            }
        }
        return false
    }

    func getSharedFriendsFromShare(shareId: UUID) -> [Friend] {
        return getFriendShares().first { $0.id == shareId }?.friends ?? []
    }

    // MARK: - Password Reset Management

    func resetPassword(email: String, newPassword: String) -> Bool {
        guard let user = findUserByEmail(email: email) else {
            return false // メールアドレスが見つからない
        }

        // 新しいパスワードをハッシュ化
        let hashedPassword = hashPassword(newPassword)

        // パスワード更新
        savePassword(for: user.id, password: hashedPassword)

        return true
    }

    func canResetPassword(email: String) -> Bool {
        return findUserByEmail(email: email) != nil
    }

    func getUserDisplayName(byEmail email: String) -> String? {
        return findUserByEmail(email: email)?.displayName
    }
}
