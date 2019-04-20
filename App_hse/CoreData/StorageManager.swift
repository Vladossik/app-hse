//
//  StorageManager.swift
//  TinkoffNews
//
//  Created by Vladislava on 27/06/2018.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import CoreData

class StorageManager {
    
    private let coreDataStack: ICoreDataStack
    
    // MARK: - Initializer
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    func fetch(completion: @escaping (([PostInfo]) -> ())) {
        var items: [PostInfo] = []
        
        let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
        coreDataStack.mainContext.perform {
            do {
                let posts = try self.coreDataStack.mainContext.fetch(fetchRequest)
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
    }
    
    func delete(by id: Int) {
        let fetchRequest = NSFetchRequest<Post>(entityName: "Post")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as NSNumber)
        
        do {
            let posts = try coreDataStack.mainContext.fetch(fetchRequest)
             print(posts)
            if !posts.isEmpty {
                coreDataStack.mainContext.delete(posts[0])
                try coreDataStack.mainContext.save()
            }
        } catch {
            print("Context delete error: \(error)")
        }
    }
    
    func saveFavoritePost(_ post: Item, profile: Profile, completion: @escaping (String?) -> ()) {
        coreDataStack.saveContext.perform {
            Post.insert(post, profile: profile, in: self.coreDataStack.saveContext)
            self.performSave(in: self.coreDataStack.saveContext, completion: completion)
        }
    }
    
    func saveFavoritePost(_ post: Item, group: Group, completion: @escaping (String?) -> ()) {
        coreDataStack.saveContext.perform {
            Post.insert(post, group: group, in: self.coreDataStack.saveContext)
            self.performSave(in: self.coreDataStack.saveContext, completion: completion)
        }
    }

    private func performSave(in context: NSManagedObjectContext, completion: @escaping (String?) -> ()) {
        if context.hasChanges {
            context.perform { [weak self] in
                do {
                    try context.save()
                } catch {
                    print("Context save error: \(error)")
                    completion(error.localizedDescription)
                }

                if let parent = context.parent {
                    self?.performSave(in: parent, completion: completion)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
}
