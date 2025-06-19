//
//  ActivitySession+CoreDataProperties.swift
//  activitytrackergodmode
//
//  Created by Agent Smith on 2023-01-01.
//  Copyright © 2023 Google. All rights reserved.
//
//

import Foundation
import CoreData


extension ActivitySession {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivitySession> {
        return NSFetchRequest<ActivitySession>(entityName: "ActivitySession")
    }

    @NSManaged public var uuid: UUID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var applicationName: String
    @NSManaged public var applicationBundleID: String
    @NSManaged public var windowTitle: String?
    @NSManaged public var tabTitle: String?
    @NSManaged public var projectName: String?
    @NSManaged public var filePath: String?
    @NSManaged public var isActive: Bool

}

extension ActivitySession : Identifiable {

}
