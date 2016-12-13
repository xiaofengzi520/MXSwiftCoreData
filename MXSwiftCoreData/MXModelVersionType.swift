
import CoreData


public protocol MXModelVersionType: Equatable {
    static var AllVersions: [Self] { get }
    static var CurrentVersion: Self { get }
    var name: String { get }
    var successor: Self? { get }
    var modelBundle: Bundle { get }
    var modelDirectoryName: String { get }
    func mappingModelsToSuccessor() -> [NSMappingModel]?
}


extension MXModelVersionType {
    
    public var successor: Self? { return nil }
    
    public init?(storeURL: URL) {
        guard let metadata = try? NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil) else { return nil }
        let version = Self.AllVersions.findFirstOccurence {
            $0.managedObjectModel().isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        }
        guard let result = version else { return nil }
        self = result
    }
    
    public func managedObjectModel() -> NSManagedObjectModel {
        let omoURL = modelBundle.url(forResource: name, withExtension: "omo", subdirectory: modelDirectoryName)
        let momURL = modelBundle.url(forResource: name, withExtension: "mom", subdirectory: modelDirectoryName)
        guard let url = omoURL ?? momURL else { fatalError("model version \(self) not found") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("cannot open model at \(url)") }
        return model
    }
    
    public func mappingModelsToSuccessor() -> [NSMappingModel]? {
        guard let mapping = mappingModelToSuccessor() else { return nil }
        return [mapping]
    }
    
    func mappingModelToSuccessor() -> NSMappingModel? {
        guard let nextVersion = successor else { return nil }
        guard let mapping = NSMappingModel(from: [modelBundle], forSourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel()) else {
            fatalError("no mapping model found for \(self) to \(nextVersion)")
        }
        return mapping
    }
    
    func mappingModelsToSuccessor___() -> [NSMappingModel]? {
        guard let nextVersion = successor else { return nil }
        guard let mapping = NSMappingModel(from: [modelBundle], forSourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel())
            else { fatalError("no mapping from \(self) to \(nextVersion)") }
        return [mapping]
    }
    
    func migrationStepsToVersion(_ version: Self) -> [MXMigrationStep] {
        guard self != version else { return [] }
        guard let mappings = mappingModelsToSuccessor(), let nextVersion = successor else { fatalError("couldn't find mapping models") }
        let step = MXMigrationStep(sourceModel: managedObjectModel(), destinationModel: nextVersion.managedObjectModel(), mappingModels: mappings)
        return [step] + nextVersion.migrationStepsToVersion(version)
    }
    
}


struct MXMigrationStep {
    var sourceModel: NSManagedObjectModel
    var destinationModel: NSManagedObjectModel
    var mappingModels: [NSMappingModel]
}


