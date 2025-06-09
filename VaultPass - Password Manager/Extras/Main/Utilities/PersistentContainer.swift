//
//  PersistentContainer.swift
//  VaultPass - Password Manager
//
//  Created by Andrew Masters on 8/5/23.
//

import CoreData

class PersistentContainer: NSPersistentCloudKitContainer {
    private let modelName: String = "Model"
    private let appGroupIdentifier = "group.vaultpass.masters"
    private let cloudContainer = "iCloud.VaultPassStorage"
    
    private var observer: NSObjectProtocol?
    
    init(iCloud enableiCloud: Bool) {
        var model: NSManagedObjectModel = NSManagedObjectModel()
        if let url = Bundle.main.url(forResource: self.modelName, withExtension: "momd"), let setModel = NSManagedObjectModel(contentsOf: url) {
            model = setModel
        }
        super.init(name: self.modelName, managedObjectModel: model)
        let url = URL.storeURL(for: self.appGroupIdentifier, databaseName: self.modelName)
        let persistentStoreDescription = NSPersistentStoreDescription(url: url)
        if enableiCloud {
            setupiCloudContainer(self, persistentStoreDescription)
        } else {
            persistentStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        }


        self.persistentStoreDescriptions = [persistentStoreDescription]
        self.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupiCloudContainer(_ container: NSPersistentCloudKitContainer, _ persistentStoreDescription: NSPersistentStoreDescription) {
        persistentStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: self.cloudContainer)
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.observer = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: .main) { [weak container] notification in
            guard let container else { return }
            self.mergeRemoteChanges(container)
        }
    }
    
    private func mergeRemoteChanges(_ persistentContainer: NSPersistentCloudKitContainer) {
        let backgroundContext = persistentContainer.newBackgroundContext()
        let viewContext = persistentContainer.viewContext
        
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "EncryptedCredentials")
            do {
                let remoteObjects = try backgroundContext.fetch(fetchRequest)

                for remoteObject in remoteObjects {
                    let objectID = remoteObject.objectID
                    let remoteTimestamp = remoteObject.value(forKey: "lastUpdated") as? Date

                    // Skip if no timestamp
                    guard let remoteTimestamp else { continue }

                    let localObject = try? viewContext.existingObject(with: objectID)
                    let localTimestamp = localObject?.value(forKey: "lastUpdated") as? Date

                    if localObject == nil || (localTimestamp != nil && remoteTimestamp > localTimestamp!) {
                        // Create or update the local object
                        let targetObject: NSManagedObject

                        if let localObject {
                            targetObject = localObject
                        } else {
                            targetObject = viewContext.object(with: objectID)
                        }

                        for key in remoteObject.entity.attributesByName.keys where key != "lastUpdated" {
                            targetObject.setValue(remoteObject.value(forKey: key), forKey: key)
                        }
                        targetObject.setValue(remoteTimestamp, forKey: "lastUpdated")
                    }
                }

                try self.viewContext.save()
            } catch {
                print("Error merging remote changes: \(error)")
            }
        }
    }
}
