//
//  Student+CoreDataProperties.swift
//  Wong Park
//
//  Created by Daniel Prastiwa on 24/07/19.
//  Copyright © 2019 Kipacraft. All rights reserved.
//
//

import Foundation
import CoreData


extension Student {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Student> {
        return NSFetchRequest<Student>(entityName: "Student")
    }

    @NSManaged public var name: String?
    @NSManaged public var lesson: Lesson?

}
