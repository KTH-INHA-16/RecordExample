//
//  RecordEntity+CoreDataProperties.swift
//  RecordExample
//
//  Created by κΉνν on 2022/03/23.
//
//

import Foundation
import CoreData


extension RecordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecordEntity> {
        return NSFetchRequest<RecordEntity>(entityName: "RecordEntity")
    }

    @NSManaged public var title: String?

}

extension RecordEntity : Identifiable {

}
