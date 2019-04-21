//
//  CoreDataStack.swift
//  TinkoffChat
//
//  Created by Vladislava on 27/06/2018.
//  Copyright © 2019 VladislavaVakulenko. All rights reserved.
//

import CoreData

protocol ICoreDataStack {
    
    var managedObjectModel: NSManagedObjectModel { get }
    
    var mainContext: NSManagedObjectContext { get }
    var saveContext: NSManagedObjectContext { get }
}

final class CoreDataStack: ICoreDataStack {
    
    
    private let resourceName: String
    private let storeType: String
    
    // Lifecycle
    
    init(resourceName: String) {
        self.resourceName = resourceName
        self.storeType = NSSQLiteStoreType
    }
    
    // Model
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: resourceName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // Coordinator
    
    private var storeUrl: URL {
        let documentUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentUrl.appendingPathComponent("\(resourceName).sqlite")
    }
    
    lazy private var persistanceStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                           NSInferMappingModelAutomaticallyOption: true]
            try coordinator.addPersistentStore(ofType: storeType,
                                               configurationName: nil,
                                               at: storeUrl,
                                               options: options)
        }
        catch {
            assert(false, "Error adding persistent store to coordinator: \(error)")
        }
        
        return coordinator
    }()
    
    // Contexts
    
    lazy private var masterContext: NSManagedObjectContext = {
        var masterContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        masterContext.persistentStoreCoordinator = persistanceStoreCoordinator
        masterContext.mergePolicy = NSOverwriteMergePolicy
        
        return masterContext
    }()
    
    lazy var mainContext: NSManagedObjectContext = {
        var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        mainContext.parent = masterContext
        mainContext.mergePolicy = NSOverwriteMergePolicy
        
        return mainContext
    }()
    
    lazy var saveContext: NSManagedObjectContext = {
        var saveContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        saveContext.parent = mainContext
        saveContext.mergePolicy = NSOverwriteMergePolicy
        
        return saveContext
    }()
}
