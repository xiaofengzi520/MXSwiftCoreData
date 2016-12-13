//
//  PhotoVersion.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/9.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import MXSwiftCoreData
enum PhotoVersion: String {
    case Version1 = "Photo"
}


extension PhotoVersion: MXModelVersionType {
    static var AllVersions: [PhotoVersion] { return [.Version1] }
    static var CurrentVersion: PhotoVersion { return .Version1 }
    
    var name: String { return rawValue }
    var modelBundle: Bundle { return Bundle(for: Photo.self) }
    var modelDirectoryName: String { return "Photo.momd" }
}
