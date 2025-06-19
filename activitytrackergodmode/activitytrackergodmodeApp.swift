//
//  activitytrackergodmodeApp.swift
//  activitytrackergodmode
//
//  Created by Simon Jackson on 5/6/25.
//

import SwiftUI
import CoreData
import AppKit

@main
struct activitytrackergodmodeApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var appState = AppState()
    @State private var settingsWindow: NSWindow?

    init() {
        // Request accessibility permissions on app launch
        // This will prompt the user if permissions haven't been granted yet.
        AccessibilityService.shared.requestAccessibilityPermissions()

        // Initialize and start activity monitoring
        // The ActivityMonitorService constructor sets up the necessary observers.
        let _ = ActivityMonitorService.shared
        // If startMonitoring() was designed to be explicitly called and not just rely on init:
        // ActivityMonitorService.shared.startMonitoring()
    }

    var body: some Scene {
        MenuBarExtra("Activity Tracker", systemImage: "chart.bar") {
            VStack(spacing: 0) {
                // Header
                VStack {
                    Text("Activity Tracker")
                        .font(.headline)
                    Text("God Mode")
                        .font(.subheadline.bold())
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor))
                
                Divider()
                
                // Current activity section with app icon
                HStack(alignment: .top, spacing: 8) {
                    // Try to get app icon
                    Image(nsImage: NSWorkspace.shared.icon(forFile: "/Applications/\(appState.currentAppName).app"))
                        .resizable()
                        .frame(width: 36, height: 36)
                        .cornerRadius(6)
                        .padding(.vertical, 4)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Current Activity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(appState.currentAppName)
                            .font(.headline)
                            .lineLimit(1)
                        
                        if !appState.currentWindowTitle.isEmpty && appState.currentWindowTitle != "Unknown" {
                            Text(appState.currentWindowTitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(nsColor: .alternatingContentBackgroundColors[0]))
                
                Divider()
                
                // App usage statistics
                VStack(alignment: .leading, spacing: 8) {
                    Text("TODAY'S ACTIVITY")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    if appState.activeApps.isEmpty {
                        Text("No data collected yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    } else {
                        ForEach(appState.activeApps.prefix(3)) { appUsage in
                            HStack(spacing: 12) {
                                // App icon
                                Image(nsImage: NSWorkspace.shared.icon(forFile: "/Applications/\(appUsage.appName).app"))
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                                // App name and time
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appUsage.appName)
                                        .font(.subheadline)
                                        .lineLimit(1)
                                    
                                    // Progress bar
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: geometry.size.width, height: 4)
                                                .foregroundColor(Color(nsColor: .quaternaryLabelColor))
                                                .cornerRadius(2)
                                            
                                            Rectangle()
                                                .frame(width: geometry.size.width * min(CGFloat(appUsage.totalTimeSeconds) / 3600, 1.0), height: 4)
                                                .foregroundColor(Color.accentColor)
                                                .cornerRadius(2)
                                        }
                                    }
                                    .frame(height: 4)
                                }
                                
                                Spacer()
                                
                                Text(appUsage.formattedTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            
                            if appUsage.id != appState.activeApps.prefix(3).last?.id {
                                Divider()
                                    .padding(.leading, 46)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
                .background(Color(nsColor: .alternatingContentBackgroundColors[1]))
                
                Divider()
                
                // Status and controls
                VStack(spacing: 12) {
                    // Status indicator with colored dot
                    HStack {
                        Circle()
                            .fill(appState.isTracking ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(appState.statusMessage)
                            .font(.caption)
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.isTracking)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .onChange(of: appState.isTracking) { _, newValue in
                                appState.toggleTracking()
                            }
                    }
                    
                    // Control buttons
                    #if DEBUG
                    Divider()
                    Button("Generate Test Data") {
                        let dataManager = DataManager() // Assuming default PersistenceController.shared
                        let generator = TestDataGenerator(dataManager: dataManager)
                        generator.generateTestData()
                    }
                    .padding(.bottom, 5)

                    Divider() // Separator before ActiveSessionsView
                    ActiveSessionsView()
                    // No specific padding for ActiveSessionsView itself here, it has internal padding.
                    #endif

                    HStack(spacing: 8) {
                        Button(action: {
                            openSettings()
                        }) {
                            Label("Settings", systemImage: "gear")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        .controlSize(.small)
                        
                        Button(action: {
                            NSApplication.shared.terminate(nil)
                        }) {
                            Label("Quit", systemImage: "power")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .buttonBorderShape(.roundedRectangle(radius: 6))
                        .controlSize(.small)
                        .keyboardShortcut("q", modifiers: .command)
                    }
                    
                    #if DEBUG
                    Button("Simulate Activity") {
                        appState.simulateActivity()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption)
                    #endif
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
            }
            .frame(width: 300)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }
    
    func openSettings() {
        // If the window exists and is still valid, just bring it to front
        if let window = settingsWindow, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            return
        }
        
        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 450),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.center()
        
        // Create a hosting view with appropriate frame
        let hostingView = NSHostingView(rootView: SettingsView(appState: appState))
        hostingView.frame = window.contentView!.bounds
        hostingView.autoresizingMask = [NSView.AutoresizingMask.width, NSView.AutoresizingMask.height]
        
        // Set the hosting view as the content view
        window.contentView = hostingView
        
        // Set delegate to handle window closing
        window.delegate = SettingsWindowDelegate.shared
        
        // Store the window reference and show it
        settingsWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

// Window delegate to handle window closing properly
class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = SettingsWindowDelegate()
    
    func windowWillClose(_ notification: Notification) {
        // Clean up any resources if needed
    }
}
