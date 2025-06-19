//
//  AppStat+CoreDataProperties.swift
//  activitytrackergodmode
//
//  Created by Agent Smith on 2023-01-01.
//  Copyright © 2023 Google. All rights reserved.
//
//

import Foundation
import CoreData


extension AppStat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AppStat> {
        return NSFetchRequest<AppStat>(entityName: "AppStat")
    }

    @NSManaged public var applicationName: String
    @NSManaged public var applicationBundleID: String
    @NSManaged public var totalTimeSpent: Double
    @NSManaged public var activityPercentage: Double
    @NSManaged public var activitySummary: ActivitySummary?

}

extension AppStat : Identifiable {

}
