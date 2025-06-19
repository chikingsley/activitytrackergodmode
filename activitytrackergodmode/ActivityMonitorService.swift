import AppKit
import Foundation

public class ActivityMonitorService {

    public static let shared = ActivityMonitorService(dataManager: DataManager())

    internal let dataManager: DataManager // Allow access for tests if absolutely needed, though prefer testing via public interface
    internal var activeSession: ActivitySession? // Allow inspection for tests
    private var appActivationObserver: Any?

    // Internal initializer for testing and for shared instance
    internal init(dataManager: DataManager, setupObservers: Bool = true) {
        self.dataManager = dataManager
        print("ActivityMonitorService: Initializing.")
        if setupObservers {
            print("ActivityMonitorService: Setting up notification observers.")
            setupNotificationObservers()
        }
    }

    // Convenience private init for the old shared instance, now unused.
    // private init() {
    //     dataManager = DataManager() // Uses PersistenceController.shared by default
    //     print("ActivityMonitorService: Initializing and setting up notification observers.")
    //     setupNotificationObservers()
    // }

    private func setupNotificationObservers() {
        // Ensure observers are not added multiple times
        if appActivationObserver != nil {
            NSWorkspace.shared.notificationCenter.removeObserver(appActivationObserver!)
            appActivationObserver = nil
        }

        appActivationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil, // Observe all applications
            queue: .main // Process on the main queue
        ) { [weak self] notification in
            self?.handleAppActivation(notification)
        }
        print("ActivityMonitorService: Did activate application notification observer set up.")
    }

    // Make internal for testing purposes
    @objc internal func handleAppActivation(_ notification: Notification) {
        guard let newApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else {
            print("ActivityMonitorService: Could not get NSRunningApplication from notification.")
            return
        }

        let applicationName = newApp.localizedName ?? "Unknown App"
        let applicationBundleID = newApp.bundleIdentifier ?? "unknown.bundle.id"

        // Ignore if it's our own app to prevent session issues on focus.
        // This might need adjustment if we want to track time spent *in* this app too.
        // For now, assuming we only track other apps.
        if applicationBundleID == Bundle.main.bundleIdentifier {
            print("ActivityMonitorService: Ignoring activation of self (\(applicationName)).")
            // Optionally, if there was an active session for another app, end it.
            // if let currentSession = activeSession, currentSession.applicationBundleID != applicationBundleID {
            //     print("ActivityMonitorService: Ending session for \(currentSession.applicationName ?? "previous app") due to self-activation.")
            //     dataManager.endSession(currentSession)
            //     activeSession = nil
            // }
            return
        }

        print("ActivityMonitorService: App activated: \(applicationName) (\(applicationBundleID))")

        // If there's an active session and it's for a different app, end it.
        if let currentSession = activeSession {
            if currentSession.applicationBundleID != applicationBundleID {
                print("ActivityMonitorService: Ending session for \(currentSession.applicationName ?? "previous app").")
                dataManager.endSession(currentSession)
                activeSession = nil // Clear before starting a new one
            } else {
                // It's the same app, no need to start a new session.
                // We might update window title or other details here in the future.
                print("ActivityMonitorService: Re-activation of the same app: \(applicationName). No new session created.")
                return
            }
        }

        // If no active session or it was just ended for a different app, start a new one.
        if activeSession == nil {
            print("ActivityMonitorService: Starting new session for \(applicationName).")
            // For now, windowTitle and other details are not captured here as per Phase 3 focus.
            // These will be added in Phase 4.
            activeSession = dataManager.createNewSession(
                applicationName: applicationName,
                applicationBundleID: applicationBundleID
                // windowTitle: nil, // Will be handled in Phase 4
                // tabTitle: nil, // Will be handled in Phase 4
                // projectName: nil, // Will be handled in Phase 4
                // filePath: nil // Will be handled in Phase 4
            )
            if activeSession != nil {
                print("ActivityMonitorService: New session created for \(applicationName) with ID \(activeSession!.uuid.uuidString)")
            } else {
                print("ActivityMonitorService: Failed to create new session for \(applicationName).")
            }
        }
    }

    public func startMonitoring() {
        // Primarily ensures observers are set up.
        // If observers could have been removed by stopMonitoring(), this ensures they are re-added.
        print("ActivityMonitorService: startMonitoring called.")
        setupNotificationObservers()
    }

    public func stopMonitoring() {
        print("ActivityMonitorService: stopMonitoring called.")
        if let observer = appActivationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            appActivationObserver = nil
            print("ActivityMonitorService: Removed didActivateApplicationNotification observer.")
        }

        if let currentSession = activeSession {
            print("ActivityMonitorService: Ending active session for \(currentSession.applicationName ?? "current app") due to monitoring stop.")
            dataManager.endSession(currentSession)
            activeSession = nil
        }
    }

    deinit {
        print("ActivityMonitorService: Deinitializing.")
        stopMonitoring()
    }
}
