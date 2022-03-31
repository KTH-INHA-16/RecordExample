//
//  DataManager.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/29.
//

import Foundation
import CoreData
import Combine

final class DataManager: ObservableObject {
    private lazy var container: NSPersistentContainer = {
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
    
    func fetch() -> [Record] {
        do {
            let context = try container.viewContext.fetch(Record.fetchRequest())
            return context
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
