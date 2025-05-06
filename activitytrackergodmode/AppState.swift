import SwiftUI
import AppKit

// A model to represent app usage
struct AppUsage: Identifiable {
    let id = UUID()
    let appName: String
    let bundleID: String 
    let totalTimeSeconds: Int
    
    var formattedTime: String {
        let hours = totalTimeSeconds / 3600
        let minutes = (totalTimeSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// A class to manage the app state and serve as a central place for shared data
class AppState: ObservableObject {
    @Published var isTracking: Bool = true
    
    // Current activity tracking properties
    @Published var statusMessage: String = "Running"
    @Published var currentAppName: String = "Unknown"
    @Published var currentWindowTitle: String = "Unknown"
    @Published var activeApps: [AppUsage] = []
    
    private var timer: Timer?
    private var appUsageDict: [String: Int] = [:]
    private var lastActiveTime: Date = Date()
    
    init() {
        startTracking()
        
        // Add some sample data for UI testing
        #if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activeApps = [
                AppUsage(appName: "Xcode", bundleID: "com.apple.dt.Xcode", totalTimeSeconds: 3600),
                AppUsage(appName: "Safari", bundleID: "com.apple.Safari", totalTimeSeconds: 1800),
                AppUsage(appName: "Messages", bundleID: "com.apple.Messages", totalTimeSeconds: 900)
            ]
        }
        #endif
    }
    
    deinit {
        stopTracking()
    }
    
    // This will be used in later phases for actual tracking
    func toggleTracking() {
        isTracking.toggle()
        statusMessage = isTracking ? "Running" : "Paused"
        
        if isTracking {
            startTracking()
        } else {
            stopTracking()
        }
    }
    
    private func startTracking() {
        stopTracking() // Ensure any existing timer is invalidated
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkCurrentApplication()
        }
        RunLoop.main.add(timer!, forMode: .common)
        
        // Initial check
        checkCurrentApplication()
    }
    
    private func stopTracking() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkCurrentApplication() {
        guard isTracking else { return }
        
        if let frontmostApp = NSWorkspace.shared.frontmostApplication {
            let appName = frontmostApp.localizedName ?? "Unknown"
            let bundleID = frontmostApp.bundleIdentifier ?? "unknown.bundleID"
            
            // Update app usage time
            let now = Date()
            let timeSpent = Int(now.timeIntervalSince(lastActiveTime))
            lastActiveTime = now
            
            if timeSpent > 0 && currentAppName != "Unknown" {
                appUsageDict[currentAppName, default: 0] += timeSpent
                updateActiveAppsList()
            }
            
            // Only update UI if something changed
            if currentAppName != appName {
                self.currentAppName = appName
                statusMessage = "Tracking: \(appName)"
            }
            
            // Try to get active window title
            if let window = getActiveWindow(for: frontmostApp) {
                self.currentWindowTitle = window
            } else {
                self.currentWindowTitle = ""
            }
        }
    }
    
    private func updateActiveAppsList() {
        // Convert dictionary to array and sort by time
        activeApps = appUsageDict.map { (appName, time) in
            AppUsage(
                appName: appName,
                bundleID: NSWorkspace.shared.urlForApplication(withBundleIdentifier: appName)?.absoluteString ?? "",
                totalTimeSeconds: time
            )
        }
        .sorted { $0.totalTimeSeconds > $1.totalTimeSeconds }
    }
    
    private func getActiveWindow(for app: NSRunningApplication) -> String? {
        let appPID = app.processIdentifier
        
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        
        for window in windowList {
            guard let windowOwnerPID = window[kCGWindowOwnerPID as String] as? Int,
                  windowOwnerPID == appPID,
                  let windowName = window[kCGWindowName as String] as? String,
                  !windowName.isEmpty else {
                continue
            }
            
            return windowName
        }
        
        return nil
    }
    
    // Sample functionality for development and testing
    #if DEBUG
    func simulateActivity() {
        // Create simulated app usage data
        var simulatedApps = [
            AppUsage(appName: "Xcode", bundleID: "com.apple.dt.Xcode", totalTimeSeconds: Int.random(in: 3600...7200)),
            AppUsage(appName: "Safari", bundleID: "com.apple.Safari", totalTimeSeconds: Int.random(in: 1800...3600)),
            AppUsage(appName: "Messages", bundleID: "com.apple.Messages", totalTimeSeconds: Int.random(in: 900...1800)),
            AppUsage(appName: "Mail", bundleID: "com.apple.Mail", totalTimeSeconds: Int.random(in: 600...1200)),
            AppUsage(appName: "Notes", bundleID: "com.apple.Notes", totalTimeSeconds: Int.random(in: 300...600))
        ]
        
        // Randomly choose top 3
        simulatedApps.shuffle()
        self.activeApps = Array(simulatedApps.prefix(3))
        
        // Simulate an active app change
        let apps = ["Xcode", "Safari", "Notes", "Mail", "Messages", "System Settings", "Terminal", "Finder"]
        self.currentAppName = apps.randomElement() ?? "Xcode"
        self.currentWindowTitle = "Working on something important"
        
        statusMessage = "Actively tracking..."
        
        // Simulate changing back to normal status after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.statusMessage = "Running"
        }
    }
    #endif
} 