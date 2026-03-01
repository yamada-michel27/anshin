//
//  FriendManager.swift
//  anshin
//
//  友達データの管理を行うサービスクラス
//

import Foundation

class FriendManager {
    var friends: [Friend] = []
    private let userDefaults = UserDefaults.standard
    private var currentUserId: String?

    init() {
        loadFriendsForCurrentUser()
    }

    func setCurrentUser(_ userId: String) {
        currentUserId = userId
        loadFriendsForCurrentUser()
    }

    // MARK: - 友達の追加
    func addFriend(name: String, relationship: RelationshipType, details: String? = nil, gender: Gender = .unknown, age: Int? = nil) {
        let newFriend = Friend(name: name, relationship: relationship, relationshipDetails: details, gender: gender, age: age)
        friends.append(newFriend)
        saveFriends()
    }

    // MARK: - 友達の削除
    func removeFriend(at index: Int) {
        guard index < friends.count else { return }
        friends.remove(at: index)
        saveFriends()
    }

    func removeFriend(by id: UUID) {
        friends.removeAll { $0.id == id }
        saveFriends()
    }

    // MARK: - 友達情報の更新
    func updateFriend(at index: Int, name: String? = nil, relationship: RelationshipType? = nil, details: String? = nil, gender: Gender? = nil, age: Int? = nil) {
        guard index < friends.count else { return }

        if let name = name {
            friends[index].name = name
        }
        if let relationship = relationship {
            friends[index].updateRelationship(relationship, details: details)
        }
        if gender != nil || age != nil {
            friends[index].updatePersonalInfo(gender: gender, age: age)
        }
        friends[index].lastUpdated = Date()
        saveFriends()
    }

    func updateFriend(by id: UUID, name: String? = nil, relationship: RelationshipType? = nil, details: String? = nil, gender: Gender? = nil, age: Int? = nil) {
        guard let index = friends.firstIndex(where: { $0.id == id }) else { return }
        updateFriend(at: index, name: name, relationship: relationship, details: details, gender: gender, age: age)
    }

    // MARK: - 検索機能
    func searchFriends(by name: String) -> [Friend] {
        if name.isEmpty {
            return friends
        }
        return friends.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    func getFriends(by relationship: RelationshipType) -> [Friend] {
        return friends.filter { $0.relationship == relationship }
    }

    func getAllFriends() -> [Friend] {
        return friends
    }

    // MARK: - データの永続化
    private func saveFriends() {
        guard let userId = currentUserId else { return }
        let friendsKey = "SavedFriends_\(userId)"

        do {
            let encodedData = try JSONEncoder().encode(friends)
            userDefaults.set(encodedData, forKey: friendsKey)
        } catch {
            print("友達データの保存に失敗しました: \(error)")
        }
    }

    private func loadFriendsForCurrentUser() {
        guard let userId = currentUserId else {
            friends = []
            return
        }

        let friendsKey = "SavedFriends_\(userId)"
        guard let data = userDefaults.data(forKey: friendsKey) else {
            friends = []
            return
        }

        do {
            friends = try JSONDecoder().decode([Friend].self, from: data)
        } catch {
            print("友達データの読み込みに失敗しました: \(error)")
            friends = []
        }
    }

    // MARK: - 共有用のテキスト生成
    func generateShareText() -> String {
        let groupedFriends = Dictionary(grouping: friends) { $0.relationship }

        var shareText = "【友人関係一覧】\n\n"

        for relationshipType in RelationshipType.allCases {
            if let friendsInCategory = groupedFriends[relationshipType], !friendsInCategory.isEmpty {
                shareText += "■ \(relationshipType.displayName)\n"
                for friend in friendsInCategory {
                    shareText += "・\(friend.name)"

                    // 性別・年齢情報を追加
                    var personalInfo: [String] = []
                    if friend.gender != .unknown {
                        personalInfo.append(friend.gender.displayName)
                    }
                    if let age = friend.age {
                        personalInfo.append("\(age)歳")
                    }
                    if !personalInfo.isEmpty {
                        shareText += " (\(personalInfo.joined(separator: "・")))"
                    }

                    // 詳細情報を追加
                    if let details = friend.relationshipDetails, !details.isEmpty {
                        shareText += " - \(details)"
                    }
                    shareText += "\n"
                }
                shareText += "\n"
            }
        }

        shareText += "※ ANSHINアプリで管理中"
        return shareText
    }
}