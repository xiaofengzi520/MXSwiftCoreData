//
//  MXValueTransformer.swift
//  MXSwiftCoreDataSimple
//
//  Created by muxiao on 2016/12/8.
//  Copyright © 2016年 muxiao. All rights reserved.
//

import Foundation

public class MXValueTransformer<A:AnyObject, B:AnyObject>: ValueTransformer {
    public  typealias Transform = (A?) -> B?
    public  typealias ReverseTransform = (B?) -> A?
    private let transform:Transform
    private let reverseTransform:ReverseTransform
    init(_ transform:@escaping Transform, reverseTransform:@escaping ReverseTransform) {
        self.transform = transform;
        self.reverseTransform = reverseTransform;
        super.init()
    }
    
    public static func registerTransformerWithName(_ name:String, transform: @escaping Transform, reverseTransform: @escaping ReverseTransform){
        let vt = MXValueTransformer(transform, reverseTransform: reverseTransform)
        ValueTransformer.setValueTransformer(vt, forName: NSValueTransformerName(rawValue: name));
    }
    
    override  public class func transformedValueClass() ->AnyClass{
        return B.self;
    }
    
    override  public class func allowsReverseTransformation() -> Bool{
        return true;
    }
    
    override public func transformedValue(_ value: Any?) -> Any? {
        return transform(value as? A);
    }
    
    override public func reverseTransformedValue(_ value: Any?) -> Any?{
        return reverseTransform(value as? B);
    }
}
