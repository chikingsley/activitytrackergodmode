//
//  activitytrackergodmodeTests.swift
//  activitytrackergodmodeTests
//
//  Created by Simon Jackson on 5/6/25.
//

import Testing
import CoreData
@testable import activitytrackergodmode

struct DataManagerTests {

    @Test func testCreateSession() throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)

        // Given
        let appName = "TestApp"
        let bundleID = "com.test.app"
        let windowTitle = "Test Window"

        // When
        let session = dataManager.createNewSession(
            applicationName: appName,
            applicationBundleID: bundleID,
            windowTitle: windowTitle
        )

        // Then
        #expect(session.applicationName == appName)
        #expect(session.applicationBundleID == bundleID)
        #expect(session.windowTitle == windowTitle)
        #expect(session.isActive == true)
        #expect(session.startTime != nil)
        #expect(session.endTime == nil)
        #expect(session.uuid != nil)
    }

    @Test func testEndSession() throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)

        // Given
        let session = dataManager.createNewSession(
            applicationName: "TestApp",
            applicationBundleID: "com.test.app"
        )
        let initialStartTime = session.startTime // Ensure startTime is set

        // When
        // Adding a small delay to ensure endTime is measurably different from startTime if system is too fast
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        dataManager.endSession(session)

        // Then
        #expect(session.isActive == false)
        #expect(session.endTime != nil)
        // Check if endTime is after startTime
        if let startTime = initialStartTime, let endTime = session.endTime {
            #expect(endTime > startTime)
        } else {
            Issue.record("Either startTime or endTime was nil when it shouldn't be.")
        }
    }

    @Test func testGetActiveSessions() throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)

        // Given
        _ = dataManager.createNewSession(
            applicationName: "ActiveApp1",
            applicationBundleID: "com.test.active1"
        )

        let inactiveSession = dataManager.createNewSession(
            applicationName: "InactiveApp",
            applicationBundleID: "com.test.inactive"
        )
        dataManager.endSession(inactiveSession)

        _ = dataManager.createNewSession(
            applicationName: "ActiveApp2",
            applicationBundleID: "com.test.active2"
        )

        // When
        let activeSessions = dataManager.getActiveSessions()

        // Then
        #expect(activeSessions.count == 2)
        for session in activeSessions {
            #expect(session.isActive == true)
        }
    }

    @Test func testGetSessionsByDay() throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        let context = persistenceController.container.viewContext

        // Given
        let today = Date()
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            Issue.record("Could not calculate yesterday's date.")
            return
        }
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) else {
            Issue.record("Could not calculate tomorrow's date.")
            return
        }

        // Session for yesterday
        let yesterdaySession = dataManager.createNewSession(
            applicationName: "YesterdayApp",
            applicationBundleID: "com.test.yesterday"
        )
        yesterdaySession.startTime = yesterday
        // Manually save context after direct modification if not done by create/end session
        try context.save()


        // Sessions for today
        _ = dataManager.createNewSession(
            applicationName: "TodayApp1",
            applicationBundleID: "com.test.today1"
        )
        _ = dataManager.createNewSession(
            applicationName: "TodayApp2",
            applicationBundleID: "com.test.today2"
        )

        // Session for tomorrow (should not be fetched by getSessionsByDay(date: today))
        let tomorrowSession = dataManager.createNewSession(
            applicationName: "TomorrowApp",
            applicationBundleID: "com.test.tomorrow"
        )
        tomorrowSession.startTime = tomorrow
        try context.save()


        // When
        let todaySessions = dataManager.getSessionsByDay(date: today)
        let yesterdaySessions = dataManager.getSessionsByDay(date: yesterday)
        let tomorrowSessions = dataManager.getSessionsByDay(date: tomorrow)

        // Then
        #expect(todaySessions.count == 2)
        #expect(yesterdaySessions.count == 1)
        #expect(yesterdaySessions.first?.applicationName == "YesterdayApp")
        #expect(tomorrowSessions.count == 1)
        #expect(tomorrowSessions.first?.applicationName == "TomorrowApp")

        // Also check that a date with no sessions returns empty
        if let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) {
            let twoDaysAgoSessions = dataManager.getSessionsByDay(date: twoDaysAgo)
            #expect(twoDaysAgoSessions.isEmpty == true)
        } else {
            Issue.record("Could not calculate two days ago.")
        }
    }
}
