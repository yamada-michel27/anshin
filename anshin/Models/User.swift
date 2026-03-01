//
//  User.swift
//  anshin
//
//  ユーザー情報とアプリ内共有のデータモデル
//

import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String // ユーザー固有のID
    var displayName: String
    var email: String // メールアドレス
    var createdAt: Date
    var lastLoginAt: Date

    init(displayName: String) {
        self.id = UUID().uuidString.prefix(8).uppercased() + String(Int.random(in: 1000...9999))
        self.displayName = displayName
        self.email = ""
        self.createdAt = Date()
        self.lastLoginAt = Date()
    }

    init(id: String, displayName: String, email: String, createdAt: Date, lastLoginAt: Date) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

struct ShareRequest: Codable, Identifiable, Hashable {
    let id: UUID
    let fromUserId: String
    let fromUserName: String
    let toUserId: String
    let friendIds: [UUID] // 共有する友達のID
    var status: ShareRequestStatus
    let createdAt: Date
    var respondedAt: Date?

    init(fromUserId: String, fromUserName: String, toUserId: String, friendIds: [UUID]) {
        self.id = UUID()
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.toUserId = toUserId
        self.friendIds = friendIds
        self.status = .pending
        self.createdAt = Date()
    }
}

enum ShareRequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending:
            return "承認待ち"
        case .approved:
            return "承認済み"
        case .rejected:
            return "拒否済み"
        }
    }

    var emoji: String {
        switch self {
        case .pending:
            return "⏳"
        case .approved:
            return "✅"
        case .rejected:
            return "❌"
        }
    }
}

struct SharedFriendList: Codable, Identifiable, Hashable {
    let id: UUID
    let shareRequestId: UUID
    let fromUserId: String
    let fromUserName: String
    let friends: [Friend]
    let sharedAt: Date
    let expiresAt: Date? // 共有期限（optional）

    init(shareRequest: ShareRequest, friends: [Friend], expiresAt: Date? = nil) {
        self.id = UUID()
        self.shareRequestId = shareRequest.id
        self.fromUserId = shareRequest.fromUserId
        self.fromUserName = shareRequest.fromUserName
        self.friends = friends
        self.sharedAt = Date()
        self.expiresAt = expiresAt
    }
}

// MARK: - Partner System

struct Partner: Codable, Identifiable, Hashable {
    let id: UUID
    let userId: String
    let userName: String
    let connectedAt: Date
    var status: PartnerStatus

    init(userId: String, userName: String) {
        self.id = UUID()
        self.userId = userId
        self.userName = userName
        self.connectedAt = Date()
        self.status = .connected
    }
}

enum PartnerStatus: String, Codable, CaseIterable {
    case connected = "connected"
    case disconnected = "disconnected"

    var displayName: String {
        switch self {
        case .connected:
            return "連携中"
        case .disconnected:
            return "切断"
        }
    }

    var emoji: String {
        switch self {
        case .connected:
            return "🔗"
        case .disconnected:
            return "🔌"
        }
    }
}

struct PartnerRequest: Codable, Identifiable, Hashable {
    let id: UUID
    let fromUserId: String
    let fromUserName: String
    let toUserId: String
    var status: PartnerRequestStatus
    let createdAt: Date
    var respondedAt: Date?

    init(fromUserId: String, fromUserName: String, toUserId: String) {
        self.id = UUID()
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.toUserId = toUserId
        self.status = .pending
        self.createdAt = Date()
    }
}

enum PartnerRequestStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"

    var displayName: String {
        switch self {
        case .pending:
            return "承認待ち"
        case .accepted:
            return "承認済み"
        case .rejected:
            return "拒否済み"
        }
    }

    var emoji: String {
        switch self {
        case .pending:
            return "⏳"
        case .accepted:
            return "✅"
        case .rejected:
            return "❌"
        }
    }
}

// MARK: - Friend Share System

struct FriendShare: Codable, Identifiable, Hashable {
    let id: UUID
    let fromUserId: String
    let fromUserName: String
    let toUserId: String
    let friends: [Friend]
    let purpose: String // 用途
    let location: String // 場所
    let dateTime: Date // 日時
    let createdAt: Date
    var isRead: Bool // 通知既読フラグ

    init(fromUserId: String, fromUserName: String, toUserId: String, friends: [Friend], purpose: String, location: String, dateTime: Date) {
        self.id = UUID()
        self.fromUserId = fromUserId
        self.fromUserName = fromUserName
        self.toUserId = toUserId
        self.friends = friends
        self.purpose = purpose
        self.location = location
        self.dateTime = dateTime
        self.createdAt = Date()
        self.isRead = false
    }
}

struct ShareNotification: Codable, Identifiable, Hashable {
    let id: UUID
    let shareId: UUID
    let toUserId: String
    let fromUserName: String
    let friendCount: Int
    let purpose: String
    let location: String
    let dateTime: Date
    let createdAt: Date
    var isRead: Bool

    init(share: FriendShare) {
        self.id = UUID()
        self.shareId = share.id
        self.toUserId = share.toUserId
        self.fromUserName = share.fromUserName
        self.friendCount = share.friends.count
        self.purpose = share.purpose
        self.location = share.location
        self.dateTime = share.dateTime
        self.createdAt = share.createdAt
        self.isRead = false
    }
}