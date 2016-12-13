//
//  MXManagedObjectContextExtension.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/9.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
     convenience init<Version: MXModelVersionType>(concurrencyType: NSManagedObjectContextConcurrencyType, modelVersion: Version, storeURL: URL, progress: Progress? = nil) {
        if let storeVersion = Version(storeURL: storeURL), storeVersion != modelVersion {
            migrateStoreFromURL(sourceURL: storeURL, toURL: storeURL, targetVersion: modelVersion, deleteSource: true, progress: progress)
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: modelVersion.managedObjectModel())
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        self.init(concurrencyType: concurrencyType)
        persistentStoreCoordinator = psc
    }
    
    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
             _ = self.saveOrRollback()
        }
    }
    
    func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    public func insertObject<A: MXManagedObject>() -> A {
        print(A.entityName());
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName(), into: self) as? A else { fatalError("Wrong object type") }
        print(obj);
        return obj
    }

}
