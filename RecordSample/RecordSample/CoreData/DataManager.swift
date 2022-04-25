//
//  DataManager.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/29.
//

import Foundation
import CoreData

final class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    lazy var container: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "RecordModel")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return container
    }()
    
    func save(attributes: [String : Any], type name: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: name, in: container.viewContext) else {
            return
        }
        
        let backgroundContext = container.newBackgroundContext()
        
        backgroundContext.performAndWait {
            let entityObject = NSManagedObject(entity: entity, insertInto: container.viewContext)
            
            attributes.forEach {
                entityObject.setValue($0.value, forKey: $0.key)
            }
            
            do {
                try container.viewContext.save()
            } catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func remove(object: NSManagedObject, type name: String) {
        do {
            self.container.viewContext.delete(object)
            try self.container.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetch() -> [Record] {
        do {
            let context = try container.viewContext.fetch(Record.fetchRequest())
            return context
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
