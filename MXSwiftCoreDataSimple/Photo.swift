//
//  Photo.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/9.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation
import CoreData
import MXSwiftCoreData
private var registrationToken: String = "MXManagedObject"
private let imageTransform = "imageTransform";

public class Photo: MXManagedObject {
    @NSManaged public private(set) var date:Date
    @NSManaged public private(set) var height:Int16
    @NSManaged public private(set) var width:Int16
    @NSManaged public private(set) var id:String
    @NSManaged public private(set) var image:UIImage
    
    override public class func registerValueTransformers(){
        DispatchQueue.once(token: registrationToken, block: {
            let reverseTransform:(NSData?)->UIImage? = {
                (data) in
                guard let dataS = data as? Data  else{return nil}
                return UIImage(data: dataS);
            }
            let tranform:(UIImage?)->NSData? = {
                (image) in
                guard let image = image else{return nil}
                guard let data = UIImagePNGRepresentation(image)else{return nil};
                return data as NSData;
            }
           MXValueTransformer<UIImage, NSData>.registerTransformerWithName(imageTransform, transform: tranform, reverseTransform: reverseTransform)
        });
    }
    
    static func insert(into context:NSManagedObjectContext, image:UIImage) ->Photo{
        let photo:Photo = context.insertObject();
        photo.date = Date();
        photo.height = Int16(image.size.height);
        photo.width = Int16(image.size.width);
        photo.id = "\(arc4random() % 1000000000)";
        photo.image = image;
        return photo;
    }
    
    
    
    override public class func defaultSortDescriptors() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "date", ascending: false)]
    }

    
}

extension DispatchQueue{
    private static var onceTracker = [String]()
    class func once(token:String, block:()->Void){
        objc_sync_enter(self);
        defer {
            objc_sync_exit(self)
        }
        if onceTracker.contains(token) {
            return;
        }
        onceTracker.append(token)
        block();
    }
}
