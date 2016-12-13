//
//  MXFetchedResultsDataProvider.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/13.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData

public class MXFetchedResultsDataProvider<ResultType : NSFetchRequestResult,Delegate:MXDataProviderDelegate>: NSObject, NSFetchedResultsControllerDelegate, MXDataProvider {
    public typealias Object = Delegate.Object
    public init(_ fetchedResultsController: NSFetchedResultsController<ResultType>, delegate: Delegate) {
        self.fetchedResultsController = fetchedResultsController
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    public init(_ fetchRequest:NSFetchRequest<ResultType>, managedObjectContext:NSManagedObjectContext, delegate:Delegate) {
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil);
        self.fetchedResultsController = frc
        self.delegate = delegate
        super.init()
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    // MARK: Private
    private let fetchedResultsController: NSFetchedResultsController<ResultType>
    private weak var delegate: Delegate!
    private var updates: [MXDataProviderUpdate<Object>] = []

    
    public func objectAtIndexPath(_ indexPath: IndexPath) -> Delegate.Object {
        guard let result = fetchedResultsController.object(at: indexPath) as? Object else { fatalError("Unexpected object at \(indexPath)") }
        return result
    }
    
    // MARK: NSFetchedResultsControllerDelegate

    public func numberOfItemsInSection(_ section: Int) -> Int {
        guard let sec = fetchedResultsController.sections?[section] else { return 0 }
        return sec.numberOfObjects
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updates = []
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updates.append(.insert(indexPath))
            delegate.dataProviderDidUpdate([.insert(indexPath)])
        case .update:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(indexPath)
            updates.append(.update(indexPath, object))
            delegate.dataProviderDidUpdate([.update(indexPath, object)])
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updates.append(.move(indexPath, newIndexPath))
            delegate.dataProviderDidUpdate([.move(indexPath, newIndexPath)])
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updates.append(.delete(indexPath))
            delegate.dataProviderDidUpdate([.delete(indexPath)])
        }
    }
    

}
