//
//  PostModel.swift
//  App_hse
//
//  Created by Vladislava on 09/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import Foundation

struct Response: Codable {
    let count: Int
    let items: [Item]
    let profiles: [Profile]
    let groups: [Group]
}

struct ProfileUser: Codable {
    let response: [ProfileUserResponse]
}

struct ProfileUserResponse: Codable {
    let id: Int
    let firstName, lastName: String
    let isClosed, canAccessClosed: Bool
    let photo100: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case isClosed = "is_closed"
        case canAccessClosed = "can_access_closed"
        case photo100 = "photo_200"
    }
}

struct Group: Codable {
    let id: Int
    let name, screenName: String
    let isClosed: Int
    let type: String
    let isAdmin, adminLevel, isMember, isAdvertiser: Int
    let photo50: String
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case screenName = "screen_name"
        case isClosed = "is_closed"
        case type
        case isAdmin = "is_admin"
        case adminLevel = "admin_level"
        case isMember = "is_member"
        case isAdvertiser = "is_advertiser"
        case photo50 = "photo_50"
    }
}

struct Item: Codable {
    let id, fromID, ownerID, date: Int
    let markedAsAds: Int
    let postType, text: String
    let signerID, canEdit, createdBy: Int?
    let canDelete, canPin: Int
    let postSource: PostSource
    let comments: Comments
    let likes: Likes
    let reposts: Reposts
    let isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromID = "from_id"
        case ownerID = "owner_id"
        case date
        case markedAsAds = "marked_as_ads"
        case postType = "post_type"
        case text
        case signerID = "signer_id"
        case canEdit = "can_edit"
        case createdBy = "created_by"
        case canDelete = "can_delete"
        case canPin = "can_pin"
        case postSource = "post_source"
        case comments, likes, reposts
        case isFavorite = "is_favorite"
    }
}

struct Comments: Codable {
    let count, canPost: Int
    let groupsCanPost: Bool
    let canClose: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case canPost = "can_post"
        case groupsCanPost = "groups_can_post"
        case canClose = "can_close"
    }
}

struct Likes: Codable {
    let count, userLikes, canLike, canPublish: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case userLikes = "user_likes"
        case canLike = "can_like"
        case canPublish = "can_publish"
    }
}

struct PostSource: Codable {
    let type: String
}

struct Reposts: Codable {
    let count, userReposted: Int
    
    enum CodingKeys: String, CodingKey {
        case count
        case userReposted = "user_reposted"
    }
}

struct Profile: Codable {
    let id: Int
    let firstName, lastName: String
    let isClosed, canAccessClosed: Bool
    let photo50: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case isClosed = "is_closed"
        case canAccessClosed = "can_access_closed"
        case photo50 = "photo_50"
    }
}

struct PostInfo {
    
    let id: Int
    let text: String
    let avatarURL: URL
    let name: String
    let surname: String?
}
