//
//  MXCoreDataUtils.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/8.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData

public var MXDBPath = "db.sqlite"; //默认存放路径,在document下,如果需要自定义,请自己修改该变量的值

private let StoreURL = URL.documentsUrl.appendingPathComponent(MXDBPath);

public func createCoreDataMainContext<Version: MXModelVersionType>(curentVersion:Version,registerValueTransformerArr:[String]?, progress:Progress? = nil, migrationCompletion:@escaping (NSManagedObjectContext)->() = {_ in})->NSManagedObjectContext?{
    if  let registerValueTransformerArr = registerValueTransformerArr {
        for registerClass in registerValueTransformerArr {
            let className = ClassFromString(registerClass) as! MXManagedObject.Type;
            className.registerValueTransformers();
        }
    }
    let version = Version(storeURL: StoreURL)
    guard version == nil || version == curentVersion else {
        DispatchQueue.global(qos: .userInitiated).async {
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, modelVersion: curentVersion, storeURL: StoreURL, progress: progress)
            DispatchQueue.main.async {
                migrationCompletion(context)
            }
        }
        return nil
    }
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType, modelVersion: curentVersion, storeURL: StoreURL)
    return context;
}

func migrateStoreFromURL<Version: MXModelVersionType>(sourceURL: URL, toURL: URL, targetVersion: Version, deleteSource: Bool = false, progress: Progress? = nil) {
    guard let sourceVersion = Version(storeURL: sourceURL) else { fatalError("unknown store version at URL \(sourceURL)") }
    var currentURL = sourceURL
    let migrationSteps = sourceVersion.migrationStepsToVersion(targetVersion)
    var migrationProgress: Progress?
    if let p = progress {
        migrationProgress = Progress(totalUnitCount: Int64(migrationSteps.count), parent: p, pendingUnitCount: p.totalUnitCount)
    }
    for step in migrationSteps {
        migrationProgress?.becomeCurrent(withPendingUnitCount: 1)
        let manager = NSMigrationManager(sourceModel: step.sourceModel, destinationModel: step.destinationModel)
        migrationProgress?.resignCurrent()
        let destinationURL = URL.temporaryURL()
        for mapping in step.mappingModels {
            try! manager.migrateStore(from: currentURL, sourceType: NSSQLiteStoreType, options: nil, with: mapping, toDestinationURL: destinationURL, destinationType: NSSQLiteStoreType, destinationOptions: nil)
        }
        if currentURL != sourceURL {
            NSPersistentStoreCoordinator.destroyStoreAtURL(url: currentURL)
        }
        currentURL = destinationURL
    }
    try! NSPersistentStoreCoordinator.replaceStoreAtURL(targetURL: toURL, withStoreAtURL: currentURL)
    if (currentURL != sourceURL) {
        NSPersistentStoreCoordinator.destroyStoreAtURL(url: currentURL)
    }
    if (toURL != sourceURL && deleteSource) {
        NSPersistentStoreCoordinator.destroyStoreAtURL(url: sourceURL)
    }
}


func ClassFromString(_ str: String) -> AnyClass!{
    
    if  var appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String {
        
        if appName == "" {appName = ((Bundle.main.bundleIdentifier!).characters.split{$0 == "."}.map { String($0) }).last ?? ""}
        var clsStr = str
        if !str.contain(subStr: "\(appName)."){
            clsStr = appName + "." + str
        }
        let strArr = clsStr.explode(".")
        var className = ""
        
        let num = strArr.count
        
        if num > 2 || strArr.contains(appName) {
            
            var nameStringM = "_TtC" + "C".repeatTimes(num - 2)
            
            for (_, s): (Int, String) in strArr.enumerated(){
                
                nameStringM += "\(s.characters.count)\(s)"
            }
            
            className = nameStringM
            
        }else{
            
            className = clsStr
        }
        
        return NSClassFromString(className)
    }
    
    return nil;
}
