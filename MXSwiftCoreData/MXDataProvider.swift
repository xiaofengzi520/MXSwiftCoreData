//
//  MXDataProvider.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/13.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation

public protocol MXDataProvider:class{
    associatedtype Object
    func objectAtIndexPath(_ indexPath:IndexPath) -> Object
    func numberOfItemsInSection(_ section:Int) -> Int
}

public protocol MXDataProviderDelegate:class {
    associatedtype Object
    func dataProviderDidUpdate(_ updates: [MXDataProviderUpdate<Object>]?)
}

public enum MXDataProviderUpdate<Object> {
    case insert(IndexPath)
    case update(IndexPath, Object)
    case move(IndexPath, IndexPath)
    case delete(IndexPath)
}
