//
//  PrototypeModel.swift
//  DataNote
//
//  Created by Michael Swarm on 3/20/25.
//

/*
 Class IS NOT main actor.
 Update function IS main actor.
 Updated properties SHOULD BE main actor.
 
 DO receive context did save notifications, but write storage is TOO LATE to capture query change.
 DO receive object did change notification, with known and unknown keys.
 
 Seems easier to monitor query result for changes, and forward that event. 
 */

import Foundation
import SwiftData
import CoreData

@Observable
// @MainActor
class PrototypeModel {
    // MARK: Lazy Init Singleton
    static var shared: PrototypeModel = { return PrototypeModel() }()

    var x: NSObjectProtocol?
    var y: NSObjectProtocol?
    var z: NSObjectProtocol?
    
    func startReceiveNotifications() {
        // Closure reference should be [weak self] to avoid reference cycle. Requires unwrap self.
        x = NotificationCenter.default.addObserver(forName: ModelContext.didSave, object: nil, queue: nil) { [weak self] notification in
            print("Receive ModelContext.didSave notification...")
            /*Task {
                await self?.update() // Calls to instance method 'update()' from outside of its actor context are implicitly asynchronous
            }*/
        }
        // Closure reference should be [weak self] to avoid reference cycle. Requires unwrap self.
        y = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { [weak self] notification in
            print("Receive ManagedObjectContextDidSave notification...")
            /*Task {
                await self?.update() // Calls to instance method 'update()' from outside of its actor context are implicitly asynchronous
            }*/
        }
        // NSManagedObjectContextObjectsDidChangeNotification
        z = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: nil, queue: nil) { [weak self] notification in
            print("Receive ManagedObjectContextObjectsDidChange notification...")
            
            self?.handleCoreDataNotification(notification)
            
            Task {
                await self?.update() // Calls to instance method 'update()' from outside of its actor context are implicitly asynchronous
            }
        }
    }
    func stopReceiveNotifications() {
        if let x = x {
            NotificationCenter.default.removeObserver(x)
        }
        if let y = y {
            NotificationCenter.default.removeObserver(y)
        }
        if let z = z {
            NotificationCenter.default.removeObserver(z)
        }
    }
    
    init() {
        startReceiveNotifications()
    }
    deinit {
        stopReceiveNotifications()
    }
    
    @MainActor func update() {
        print("Update some isolated state...")
    }
    
    func handleCoreDataNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        for (key, value) in userInfo {
            if let stringKey = key as? String { // Cast to String
                switch stringKey {
                    
                case NSInsertedObjectsKey:
                    if let insertedObjects = value as? Set<NSManagedObject> {
                        print("Inserted objects:")
                        for object in insertedObjects {
                            print("- \(object.entity.name ?? "Unknown Entity")")
                            // Do something with inserted objects
                        }
                    }
                case NSUpdatedObjectsKey:
                    if let updatedObjects = value as? Set<NSManagedObject> {
                        print("Updated objects:") // Note property changes, such as content edit, or title rename.
                        for object in updatedObjects {
                            print("- \(object.entity.name ?? "Unknown Entity")")
                            // Do something with updated objects
                        }
                    }
                case NSDeletedObjectsKey:
                    if let deletedObjects = value as? Set<NSManagedObject> {
                        print("Deleted objects:")
                        for object in deletedObjects {
                            print("- \(object.entity.name ?? "Unknown Entity")")
                            // Do something with deleted objects
                        }
                    }
                case NSRefreshedObjectsKey:
                    if let refreshedObjects = value as? Set<NSManagedObject> {
                        print("Refreshed objects:")
                        for object in refreshedObjects {
                            print("- \(object.entity.name ?? "Unknown Entity")")
                            //Do something with refreshed objects
                        }
                    }
                case NSInvalidatedObjectsKey:
                    if let invalidatedObjects = value as? Set<NSManagedObject> {
                        print("Invalidated objects:")
                        for object in invalidatedObjects {
                            print("- \(object.entity.name ?? "Unknown Entity")")
                            //Do something with invalidated objects
                        }
                    }
                case NSInvalidatedAllObjectsKey:
                    if let invalidatedAllObjects = value as? NSNumber, invalidatedAllObjects.boolValue {
                        print("All objects invalidated")
                        // Do something when all objects are invalidated
                    }
                default:
                    print("Unknown key: \(key)") // Unknown key: managedObjectContext
                }
            } else{
                print("Key is not a string, and is \(key)")
            }
        }
    }
}
