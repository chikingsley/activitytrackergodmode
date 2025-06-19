//
//  ActivitySummary+CoreDataProperties.swift
//  activitytrackergodmode
//
//  Created by Agent Smith on 2023-01-01.
//  Copyright © 2023 Google. All rights reserved.
//
//

import Foundation
import CoreData


extension ActivitySummary {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ActivitySummary> {
        return NSFetchRequest<ActivitySummary>(entityName: "ActivitySummary")
    }

    @NSManaged public var date: Date
    @NSManaged public var totalActiveTime: Double
    @NSManaged public var applicationStats: NSSet?

}

// MARK: Generated accessors for applicationStats
extension ActivitySummary {

    @objc(addApplicationStatsObject:)
    @NSManaged public func addToApplicationStats(_ value: AppStat)

    @objc(removeApplicationStatsObject:)
    @NSManaged public func removeFromApplicationStats(_ value: AppStat)

    @objc(addApplicationStats:)
    @NSManaged public func addToApplicationStats(_ values: NSSet)

    @objc(removeApplicationStats:)
    @NSManaged public func removeFromApplicationStats(_ values: NSSet)

}

extension ActivitySummary : Identifiable {

}
