//
//  MXExtensions.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/9.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData
extension String{
    func contain(subStr: String) -> Bool {return (self as NSString).range(of: subStr).length > 0}
    func explode (_ separator: Character) -> [String] {
        return self.characters.split(whereSeparator: { (element: Character) -> Bool in
            return element == separator
        }).map { String($0) }
    }
    func repeatTimes(_ times: Int) -> String{
        
        var strM = ""
        
        for _ in 0..<times {
            strM += self
        }
        
        return strM
    }
    
    func deleteSpecialStr() -> String {
        return self.replacingOccurrencesOfString("Optional<", withString: "").replacingOccurrencesOfString(">", withString: "")
    }
    func replacingOccurrencesOfString(_ target: String, withString: String) -> String{
        return (self as NSString).replacingOccurrences(of: target, with: withString)
    }
    

}

extension Sequence{
    func findFirstOccurence(block: @escaping(Self.Iterator.Element) -> Bool) -> Self.Iterator.Element? {
        for x in self where block(x) {
            return x
        }
        return nil
    }
}

extension URL{
    static var documentsUrl:URL{
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true);
    }
    static func temporaryURL() -> URL {
        return try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(UUID().uuidString)
    }
    
}

extension NSPersistentStoreCoordinator {
    static func destroyStoreAtURL(url: URL) {
        do {
            let psc = self.init(managedObjectModel: NSManagedObjectModel())
            try psc.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
        } catch let e {
            print("failed to destroy persistent store at \(url)", e)
        }
    }
    
     static func replaceStoreAtURL(targetURL: URL, withStoreAtURL sourceURL: URL) throws {
        let psc = self.init(managedObjectModel: NSManagedObjectModel())
        try psc.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
    }
}

