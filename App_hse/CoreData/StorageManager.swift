//
//  StorageManager.swift
//  TinkoffNews
//
//  Created by Oleg Samoylov on 27/06/2018.
//  Copyright © 2018 Oleg Samoylov. All rights reserved.
//

import CoreData

class StorageManager {
    
    // MARK: - Dependency
    
    private let coreDataStack: ICoreDataStack
    
    // MARK: - Initializer
    
    init(coreDataStack: ICoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - IStorageManager
    
    
    
//    func isEmpty(offset: Int) -> Bool {
//        var result = false
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(News.self)")
//        fetchRequest.fetchLimit = 20
//        fetchRequest.fetchOffset = offset
//        fetchRequest.resultType = .countResultType
//
//        do {
//            result = try coreDataStack.mainContext.count(for: fetchRequest) == 0
//        } catch {
//            result = true
//        }
//
//        return result
//    }
//
//    func fetchViewCounts(offset: Int, completion: @escaping ([String: Int]?, String?) -> ()) {
//        var newsFeed = [String: Int]()
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(News.self)")
//        fetchRequest.fetchLimit = 20
//        fetchRequest.fetchOffset = offset
//        fetchRequest.propertiesToFetch = ["id", "viewsCount"]
//        fetchRequest.resultType = .dictionaryResultType
//
//        coreDataStack.mainContext.perform {
//            do {
//                let result = try self.coreDataStack.mainContext.fetch(fetchRequest) as? [[String: Any]]
//                guard let dictionary = result else {
//                    completion(nil, "Cannot cast fetch request result to dictionaries.")
//                    return
//                }
//
//                for item in dictionary {
//                    let id = item["id"] as! String
//                    let viewsCount = item["viewsCount"] as! Int
//
//                    newsFeed[id] = viewsCount
//                }
//            } catch {
//                completion(nil, error.localizedDescription)
//                return
//            }
//
//            completion(newsFeed, nil)
//        }
//    }
//
//    func fetchNewsFeed(offset: Int, completion: @escaping ([FeedItem]?, String?) -> ()) {
//        var newsFeed = [FeedItem]()
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(News.self)")
//        fetchRequest.fetchLimit = 20
//        fetchRequest.fetchOffset = offset
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
//        fetchRequest.propertiesToFetch = ["id", "name", "date", "viewsCount"]
//        fetchRequest.resultType = .dictionaryResultType
//
//        coreDataStack.mainContext.perform {
//            do {
//                let result = try self.coreDataStack.mainContext.fetch(fetchRequest) as? [[String: Any]]
//                guard let dictionary = result else {
//                    completion(nil, "Cannot cast fetch request result to dictionaries.")
//                    return
//                }
//
//                for item in dictionary {
//                    let id = item["id"] as! String
//                    let name = item["name"] as! String
//                    let date = item["date"] as! Date
//                    let viewsCount = item["viewsCount"] as! Int
//
//                    newsFeed.append(FeedItem(id: id, text: name, publicationDate: PublicationDate(milliseconds: date.milliseconds()), viewsCount: viewsCount))
//                }
//            } catch {
//                completion(nil, error.localizedDescription)
//                return
//            }
//
//            completion(newsFeed, nil)
//        }
//    }
//
//    func fetchNewsPost(id: String, completion: @escaping (PostItem?, String?) -> ()) {
//        var post: PostItem?
//
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "\(News.self)")
//        fetchRequest.propertiesToFetch = ["id", "content"]
//        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
//        fetchRequest.resultType = .dictionaryResultType
//
//        coreDataStack.mainContext.perform {
//            do {
//                let result = try self.coreDataStack.mainContext.fetch(fetchRequest).first as? [String: Any]
//                guard let item = result else {
//                    completion(nil, "Cannot cast fetch request result to dictionary.")
//                    return
//                }
//
//                let title = Title(id: item["id"] as! String)
//
//                guard let content = item["content"] as? String else {
//                    completion(nil, "No cached content for this post.")
//                    return
//                }
//
//                post = PostItem(title: title, content: content)
//            } catch {
//                completion(nil, error.localizedDescription)
//                return
//            }
//
//            completion(post, nil)
//        }
//    }
//
//    func saveNewsFeed(_ newsFeed: [FeedItem], completion: @escaping (String?) -> ()) {
//        coreDataStack.saveContext.perform {
//            for model in newsFeed {
//                News.findOrInsert(model, in: self.coreDataStack.saveContext)
//            }
//
//            self.performSave(in: self.coreDataStack.saveContext, completion: completion)
//        }
//    }
//
//    func saveItem(_ model: Mappable, completion: @escaping (String?) -> ()) {
//        coreDataStack.saveContext.perform {
//            News.findOrInsert(model, in: self.coreDataStack.saveContext)
//            self.performSave(in: self.coreDataStack.saveContext, completion: completion)
//        }
//    }
    
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
            if !posts.isEmpty {
                coreDataStack.mainContext.delete(posts[0])
                try coreDataStack.mainContext.save()
            }
        } catch {
            print(error)
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

    // MARK: - Private methods
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
