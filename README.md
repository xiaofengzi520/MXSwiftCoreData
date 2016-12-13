# MXSwiftCoreData

帮助你快速在项目中集成使用coreData

**只适配于Xcode8 & Swift3.0**

#功能
1. 可以快速实现coredata的增删改查,你只需要关心模型的建立
2. 可以进行版本控制,自动进行版本升级
3. 可以与tableview进行融合,监听coredata中数据的增删改查,对应刷新列表

#使用:

1.所有的模型对象需继承MXManagedObject
2.对于需要自定义的如SortDescriptors,或者predicate,可以选择重写
3.如果有需要对值进行转化的需要重写registerValueTransformers方法,
4.如果要进行版本控制,请声明一个枚举,遵守MXModelVersionType协议,
5.当要对数据进行改变并持久化存储时,请调用context的performChanges,并在该方法的闭包中进行值改变操作
5.当要生成新的数据并插入时,可以调用context的insertObject方法,来快速得到模型对象


例子如下:

```
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
}  //管理数据库版本的枚举

context?.performChanges {
               _ = Photo.insert(into: context!, image: image as! UIImage);
 }  //插入对象

```

#注意

目前整个项目还不够完善,例如多个context的合并冲突的解决等等问题,请谨慎使用,详细使用请参考demo.
