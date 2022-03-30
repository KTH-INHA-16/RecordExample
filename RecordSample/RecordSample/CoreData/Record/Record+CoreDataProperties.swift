//
//  Record+CoreDataProperties.swift
//  RecordSample
//
//  Created by 김태훈 on 2022/03/29.
//
//

import Foundation
import CoreData


extension Record {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged public var file: String?

}

extension Record : Identifiable {

}
