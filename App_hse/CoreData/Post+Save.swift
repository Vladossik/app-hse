//
//  Post+Save.swift
//  App_hse
//
//  Created by Vladislava on 16/03/2019.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import CoreData

extension Post {
    
    @nonobjc static func insert(_ item: Item, profile: Profile, in context: NSManagedObjectContext) {
        let post = Post(context: context)
        post.text = item.text
        post.id = Int64(item.id)
        
        let user = User(context: context)
        user.name = profile.firstName
        user.surname = profile.lastName
        user.avatar = URL(string: profile.photo50)
        
        post.user = user
    }
    
    @nonobjc static func insert(_ item: Item, group: Group, in context: NSManagedObjectContext) {
        let post = Post(context: context)
        post.text = item.text
        post.id = Int64(item.id)
        
        let community = Community(context: context)
        community.avatar = URL(string: group.photo50)
        community.name = group.name
        
        post.community = community
    }
}
