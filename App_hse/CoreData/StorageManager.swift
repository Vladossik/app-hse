//
//  StorageManager.swift
//  TinkoffNews
//
//  Created by Vladislava on 27/06/2018.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import CoreData

class StorageManager {
    
    private let container: NSPersistentContainer
    
    // MARK: - Initializer
    
    init(coreDataStack: ICoreDataStack) {
        container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
    }

    func fetch(completion: @escaping (([PostInfo]) -> ())) {
        var items: [PostInfo] = []
        
        let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
        do {
            let posts = try self.container.viewContext.fetch(fetchRequest)
            items = posts.compactMap { post in
                guard
                    let text = post.text,
                    let avatarURL = post.user?.avatar ?? post.community?.avatar,
                    let name = post.user?.name ?? post.community?.name
                    else { return nil }
                
                let surname = post.user?.surname
                
                return PostInfo(id: Int(post.id),
                                text: text,
                                avatarURL: avatarURL,
                                name: name,
                                surname: surname)
            }
            
            completion(items)
        } catch {
            completion([])
        }
    }
    
    func delete(by id: Int) {
        let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as NSNumber)
        
        do {
            let posts = try self.container.viewContext.fetch(fetchRequest)
             print(posts)
            if !posts.isEmpty {
                self.container.viewContext.delete(posts[0])
                try self.container.viewContext.save()
            }
        } catch {
            print("Context delete error: \(error)")
        }
    }
    
    func saveFavoritePost(_ post: Item, profile: Profile, completion: @escaping (String?) -> ()) {
        Post.insert(post, profile: profile, in: self.container.viewContext)
        try? self.container.viewContext.save()
    }
    
    func saveFavoritePost(_ post: Item, group: Group, completion: @escaping (String?) -> ()) {
        Post.insert(post, group: group, in: self.container.viewContext)
        try? self.container.viewContext.save()
    }
}
