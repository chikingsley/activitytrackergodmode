import Testing
import AppKit
import CoreData
@testable import activitytrackergodmode

// Helper struct to mock NSRunningApplication for testing
// NSRunningApplication is hard to instantiate directly in tests.
// We only need a few properties for these tests.
struct MockRunningApplication {
    var localizedName: String?
    var bundleIdentifier: String?

    // Add any other properties that NSRunningApplication has, if needed for tests.
    // For now, these two are sufficient for ActivityMonitorService.handleAppActivation
}


struct ActivityMonitorServiceTests {

    // Helper function to create a mock notification
    private func createMockActivationNotification(appName: String?, bundleId: String?) -> Notification {
        let mockApp = MockRunningApplication(localizedName: appName, bundleIdentifier: bundleId)
        let userInfo: [AnyHashable: Any] = [NSWorkspace.applicationUserInfoKey: mockApp]
        return Notification(name: NSWorkspace.didActivateApplicationNotification, object: nil, userInfo: userInfo)
    }

    // Test case: Initial app activation, no previous session
    @Test func testAppActivation_NoPreviousSession() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        // Initialize service without setting up real observers for this test
        let monitorService = ActivityMonitorService(dataManager: dataManager, setupObservers: false)

        // Given: No active session initially
        var activeSessions = dataManager.getActiveSessions()
        #expect(activeSessions.isEmpty, "Initially, there should be no active sessions.")

        // When: Simulate activation of "App1"
        let app1Notification = createMockActivationNotification(appName: "App1", bundleId: "com.example.app1")
        monitorService.handleAppActivation(app1Notification)

        // Then: One active session for "App1" should exist
        activeSessions = dataManager.getActiveSessions()
        #expect(activeSessions.count == 1, "Should be 1 active session after App1 activation.")

        let currentSession = activeSessions.first
        #expect(currentSession?.applicationName == "App1", "Active session should be for App1.")
        #expect(currentSession?.isActive == true, "App1 session should be active.")
        #expect(currentSession?.endTime == nil, "App1 session endTime should be nil.")

        // Also verify the internal state of monitorService if necessary and possible
        #expect(monitorService.activeSession?.applicationBundleID == "com.example.app1", "Monitor service's active session should be App1.")
    }

    // Test case: Switching from one app to another
    @Test func testAppActivation_SwitchToNewApp() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        let monitorService = ActivityMonitorService(dataManager: dataManager, setupObservers: false)

        // Given: "App1" is activated first
        let app1Notification = createMockActivationNotification(appName: "App1", bundleId: "com.example.app1")
        monitorService.handleAppActivation(app1Notification)
        let sessionApp1_ID = monitorService.activeSession?.uuid // Store App1's session UUID

        #expect(dataManager.getActiveSessions().count == 1, "After App1 activation, active sessions should be 1.")

        // When: Simulate activation of "App2"
        // Add a small delay to ensure time difference for session end times
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01 seconds
        let app2Notification = createMockActivationNotification(appName: "App2", bundleId: "com.example.app2")
        monitorService.handleAppActivation(app2Notification)

        // Then:
        // 1. Active session should now be "App2"
        let activeSessions = dataManager.getActiveSessions()
        #expect(activeSessions.count == 1, "Active sessions should be 1 after App2 activation.")
        let currentSession = activeSessions.first
        #expect(currentSession?.applicationName == "App2", "Active session should be for App2.")
        #expect(currentSession?.isActive == true, "App2 session should be active.")

        // 2. Total sessions in DB should be 2 (App1 ended, App2 active)
        // To get all sessions (including ended ones), we might need a new DataManager method
        // or fetch directly. For now, let's assume we can get them.
        // A simple way for test: get all ActivitySession entities
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        let allSessions = try persistenceController.container.viewContext.fetch(fetchRequest)
        #expect(allSessions.count == 2, "Total sessions in DB should be 2.")

        // 3. Session for "App1" should be inactive and have an end time
        let sessionApp1 = allSessions.first { $0.uuid == sessionApp1_ID }
        #expect(sessionApp1 != nil, "Session for App1 should exist.")
        #expect(sessionApp1?.isActive == false, "App1 session should be inactive.")
        #expect(sessionApp1?.endTime != nil, "App1 session should have an endTime.")

        #expect(monitorService.activeSession?.applicationBundleID == "com.example.app2", "Monitor service's active session should be App2.")
    }

    // Test case: Reactivating the same app
    @Test func testAppActivation_ReactivateSameApp() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        let monitorService = ActivityMonitorService(dataManager: dataManager, setupObservers: false)

        // Given: "App1" is activated
        let app1Notification = createMockActivationNotification(appName: "App1", bundleId: "com.example.app1")
        monitorService.handleAppActivation(app1Notification)
        let initialSessionID = monitorService.activeSession?.uuid
        let initialSessionStartTime = monitorService.activeSession?.startTime


        // When: Simulate reactivation of "App1"
        let app1ReactivationNotification = createMockActivationNotification(appName: "App1", bundleId: "com.example.app1")
        monitorService.handleAppActivation(app1ReactivationNotification)

        // Then:
        // 1. Still 1 active session, and it's for "App1"
        let activeSessions = dataManager.getActiveSessions()
        #expect(activeSessions.count == 1, "Active sessions should still be 1.")
        let currentSession = activeSessions.first
        #expect(currentSession?.applicationName == "App1", "Active session should still be for App1.")
        #expect(currentSession?.isActive == true, "App1 session should still be active.")

        // 2. The session ID and start time should be the same (no new session created)
        #expect(currentSession?.uuid == initialSessionID, "Session ID should be the same after reactivation.")
        #expect(currentSession?.startTime == initialSessionStartTime, "Session start time should be the same.")

        // 3. Total sessions in DB should be 1
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        let allSessions = try persistenceController.container.viewContext.fetch(fetchRequest)
        #expect(allSessions.count == 1, "Total sessions in DB should be 1.")

        #expect(monitorService.activeSession?.uuid == initialSessionID, "Monitor service's active session should be the same App1 session.")
    }

    // Test case: stopMonitoring ends an active session
    @Test func testStopMonitoring_EndsActiveSession() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        let monitorService = ActivityMonitorService(dataManager: dataManager, setupObservers: false)

        // Given: "App1" is activated
        let app1Notification = createMockActivationNotification(appName: "App1", bundleId: "com.example.app1")
        monitorService.handleAppActivation(app1Notification)
        let sessionApp1_ID = monitorService.activeSession?.uuid

        #expect(dataManager.getActiveSessions().count == 1, "Before stopMonitoring, active session count should be 1.")

        // When: stopMonitoring is called
        try await Task.sleep(nanoseconds: 10_000_000) // Ensure endTime is different
        monitorService.stopMonitoring()

        // Then:
        // 1. No active sessions
        let activeSessions = dataManager.getActiveSessions()
        #expect(activeSessions.isEmpty, "After stopMonitoring, there should be no active sessions.")

        // 2. The session for "App1" should be inactive and have an endTime
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        // To ensure we get the latest state, fetch from a fresh context or ensure current context is up-to-date
        let context = PersistenceController(inMemory: true).container.viewContext // Or use existing PC's context if sure it's fine
        // For this test, let's refetch using the same PC to see changes applied by DataManager
        let allSessions = try persistenceController.container.viewContext.fetch(fetchRequest)

        let sessionApp1 = allSessions.first { $0.uuid == sessionApp1_ID }
        #expect(sessionApp1 != nil, "Session for App1 should exist.")
        #expect(sessionApp1?.isActive == false, "App1 session should be inactive after stopMonitoring.")
        #expect(sessionApp1?.endTime != nil, "App1 session should have an endTime after stopMonitoring.")

        #expect(monitorService.activeSession == nil, "Monitor service's activeSession property should be nil after stopMonitoring.")
    }

    // Test case: Activation of the app itself is ignored
    @Test func testAppActivation_SelfActivationIgnored() async throws {
        let persistenceController = PersistenceController(inMemory: true)
        let dataManager = DataManager(persistenceController: persistenceController)
        let monitorService = ActivityMonitorService(dataManager: dataManager, setupObservers: false)

        // Given: Some other app ("OtherApp") is active
        let otherAppNotification = createMockActivationNotification(appName: "OtherApp", bundleId: "com.example.otherapp")
        monitorService.handleAppActivation(otherAppNotification)
        let otherAppSessionID = monitorService.activeSession?.uuid
        #expect(dataManager.getActiveSessions().count == 1, "OtherApp session should be active.")

        // When: Simulate activation of the current app (ActivityTrackerGodMode)
        let mainBundleID = Bundle.main.bundleIdentifier ?? "test.app.bundle.id.fallback"
        let selfAppNotification = createMockActivationNotification(appName: "ActivityTrackerGodMode", bundleId: mainBundleID)
        monitorService.handleAppActivation(selfAppNotification)

        // Then:
        // 1. The "OtherApp" session should still be the active one in monitorService.activeSession
        //    (because self-activation is ignored and doesn't change the tracked session)
        //    OR, if we decide self-activation *should* end the previous session, this test changes.
        //    Based on current ActivityMonitorService logic, it just prints and returns.
        //    The activeSession in monitorService will remain the "OtherApp".
        //    The active session in DataManager will also remain "OtherApp".
        #expect(monitorService.activeSession?.uuid == otherAppSessionID, "Monitor service's active session should still be OtherApp.")

        let activeDBSessions = dataManager.getActiveSessions()
        #expect(activeDBSessions.count == 1, "Active DB sessions should still be 1 (OtherApp).")
        #expect(activeDBSessions.first?.applicationBundleID == "com.example.otherapp", "The active session in DB should still be OtherApp.")

        // 2. No new session should be created for ActivityTrackerGodMode
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        let allSessions = try persistenceController.container.viewContext.fetch(fetchRequest)
        let selfAppSession = allSessions.first { $0.applicationBundleID == mainBundleID }
        #expect(selfAppSession == nil, "No session should have been created for ActivityTrackerGodMode itself.")
        #expect(allSessions.count == 1, "Total sessions in DB should still be 1 (OtherApp).")
    }
}
