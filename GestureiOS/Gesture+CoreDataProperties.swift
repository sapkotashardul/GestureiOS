//
//  Gesture+CoreDataProperties.swift
//  GestureiOS
//
//  Created by fluid on 11/18/18.
//  Copyright © 2018 fluid. All rights reserved.
//
//

import Foundation
import CoreData


extension Gesture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gesture> {
        return NSFetchRequest<Gesture>(entityName: "Gesture")
    }

    @NSManaged public var name: String?
    @NSManaged public var sensor: String?

}
