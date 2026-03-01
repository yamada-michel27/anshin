//
//  Friend.swift
//  anshin
//
//  友達とその関係性を表現するデータモデル
//

import Foundation

struct Friend: Codable, Identifiable, Hashable {
    let id = UUID()
    var name: String
    var relationship: RelationshipType
    var relationshipDetails: String?
    var gender: Gender
    var age: Int?
    var createdAt: Date
    var lastUpdated: Date

    init(name: String, relationship: RelationshipType, relationshipDetails: String? = nil, gender: Gender = .unknown, age: Int? = nil) {
        self.name = name
        self.relationship = relationship
        self.relationshipDetails = relationshipDetails
        self.gender = gender
        self.age = age
        self.createdAt = Date()
        self.lastUpdated = Date()
    }

    mutating func updateRelationship(_ newRelationship: RelationshipType, details: String? = nil) {
        self.relationship = newRelationship
        self.relationshipDetails = details
        self.lastUpdated = Date()
    }

    mutating func updatePersonalInfo(gender: Gender? = nil, age: Int? = nil) {
        if let gender = gender {
            self.gender = gender
        }
        if let age = age {
            self.age = age
        }
        self.lastUpdated = Date()
    }

    var displayAge: String {
        if let age = age {
            return "\(age)歳"
        } else {
            return "年齢不明"
        }
    }
}

enum Gender: String, CaseIterable, Codable {
    case male = "男性"
    case female = "女性"
    case unknown = "不明"

    var displayName: String {
        return self.rawValue
    }

    var emoji: String {
        switch self {
        case .male:
            return "👨"
        case .female:
            return "👩"
        case .unknown:
            return "👤"
        }
    }
}

enum RelationshipType: String, CaseIterable, Codable {
    case friend = "友達"
    case family = "家族"
    case colleague = "同僚"
    case classmate = "同級生"
    case clubmate = "部活・サークル仲間"
    case partTimeJob = "バイト先"
    case neighbor = "近所の人"
    case familyFriend = "家族の友人"
    case exColleague = "元同僚"
    case hobbyFriend = "趣味友達"
    case onlineFriend = "ネット友達"
    case childhoodFriend = "幼馴染"
    case other = "その他"

    var displayName: String {
        return self.rawValue
    }

    var description: String {
        switch self {
        case .friend:
            return "プライベートでの友達です"
        case .family:
            return "家族・親戚です"
        case .colleague:
            return "一緒に働いている同僚です"
        case .classmate:
            return "学校時代の同級生です"
        case .clubmate:
            return "部活やサークルで一緒だった仲間です"
        case .partTimeJob:
            return "アルバイト先で知り合った人です"
        case .neighbor:
            return "近所に住んでいる人です"
        case .familyFriend:
            return "家族を通じて知り合った友人です"
        case .exColleague:
            return "以前一緒に働いていた元同僚です"
        case .hobbyFriend:
            return "共通の趣味を通じて知り合った友達です"
        case .onlineFriend:
            return "インターネット上で知り合った友達です"
        case .childhoodFriend:
            return "子供の頃からの幼馴染です"
        case .other:
            return "その他の関係性です"
        }
    }
}