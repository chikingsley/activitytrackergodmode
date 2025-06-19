import Foundation

public class TestDataGenerator {
    private let dataManager: DataManager

    public init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    public func generateTestData() {
        // Create a few test sessions
        let xcodeSession = dataManager.createNewSession(
            applicationName: "Xcode",
            applicationBundleID: "com.apple.dt.Xcode",
            windowTitle: "ActivityTrackerGodMode - Running",
            projectName: "ActivityTrackerGodMode"
        )

        let safariSession = dataManager.createNewSession(
            applicationName: "Safari",
            applicationBundleID: "com.apple.Safari",
            windowTitle: "Apple Developer Documentation - Safari",
            tabTitle: "https://developer.apple.com"
        )

        // End the Safari session (user switched away)
        // Adding a slight delay to ensure endTime is after startTime
        Thread.sleep(forTimeInterval: 0.1)
        dataManager.endSession(safariSession)

        // Back to Xcode - still active, update its window title
        dataManager.updateSession(
            xcodeSession,
            windowTitle: "DataManager.swift - ActivityTrackerGodMode"
        )

        print("Test data generated successfully.")
    }
}
