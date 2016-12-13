//
//  MXManagedObject.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/8.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData

open class MXManagedObject: NSManagedObject {
    //如果存在有值需要转化,请重写此方法
    open class func registerValueTransformers(){
        
    }
    class func entityName()->String {
        let className = self;
        let classString = "\(className)";
        print(classString);
        let string = classString.deleteSpecialStr();
        return string ;
    }
    
    open class func sortedFetchRequest<A:MXManagedObject>() ->NSFetchRequest<A>{
        let request = NSFetchRequest<A>(entityName: self.entityName())
        request.sortDescriptors = defaultSortDescriptors();
        request.predicate = defaultPredicate();
        return request;
    }
    open class func defaultSortDescriptors()-> [NSSortDescriptor] {
        return []
    }
    open class func defaultPredicate ()-> NSPredicate {
        return NSPredicate(value: true)
    }
    
    public class func sortedFetchRequest<A:MXManagedObject>(with predicate:NSPredicate) ->NSFetchRequest<A>{
        let request:NSFetchRequest<A> = sortedFetchRequest();
        guard let existingPredicate = request.predicate else { fatalError("must have predicate") }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, predicate])
        return request;
    }
    
    public class func sortedFetchRequest<A:MXManagedObject>(with format:String, args:CVarArg...) ->NSFetchRequest<A>{
        let predicate = withVaList(args) { NSPredicate(format: format, arguments: $0) }
        return sortedFetchRequest(with: predicate);
    }
    
    public static func predicateWithPredicate(predicate: NSPredicate) -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [defaultPredicate(), predicate])
    }

    
    
}

