# Activity Tracker - Project Kickoff Guide

## Getting Started with Phase 1

This document provides a step-by-step guide to implementing Phase 1 of the Activity Tracker app. Each phase builds upon the previous one, allowing you to test and validate functionality before moving forward.

### Prerequisites

- macOS 13.0+ for development
- Xcode 14.0+ (latest version recommended)
- Apple Developer account (for testing on physical devices and eventual distribution)
- Basic knowledge of Swift and SwiftUI
- Understanding of macOS app development concepts

### Phase 1: Project Setup & Basic Menu Bar App (1-2 days)

#### Step 1: Create the Xcode Project

1. Open Xcode and create a new project
2. Select "macOS" → "App"
3. Configure the project with:
   - Product Name: "Activity Tracker God Mode"
   - Team: Select your personal team
   - Organization Identifier: com.yourcompany
   - Bundle Identifier: com.yourcompany.activitytrackergodmode
   - Interface: SwiftUI
   - Language: Swift
   - ✓ Include Core Data
   - ✓ Include Tests

4. Choose a location to save your project and initialize git repository if desired

#### Step 2: Configure as a Menu Bar App

1. Open Info.plist (or navigate to the Info tab in your project settings)
2. Add a new key: `LSUIElement` (Application is agent/background only)
3. Set its value to `YES`
4. This will make your app run as a menu bar app without appearing in the Dock

#### Step 3: Create the Basic Menu Bar Implementation

1. Open `App` file (usually `ActivityTrackerGodModeApp.swift`)
2. Replace the existing WindowGroup with a basic MenuBarExtra implementation:

```swift
@main
struct ActivityTrackerGodModeApp: App {
    var body: some Scene {
        MenuBarExtra("Activity Tracker", systemImage: "chart.bar") {
            VStack {
                Text("Activity Tracker")
                    .font(.headline)
                    .padding(.top)
                
                Divider()
                
                Text("Status: Running")
                    .font(.caption)
                    .padding(.bottom, 5)
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
                .padding(.bottom)
            }
            .frame(width: 200)
            .padding(.horizontal)
        }
    }
}
```

#### Step 4: Test the Basic App

1. Build and run the app (⌘R)
2. Verify that:
   - The app appears in the menu bar with the chart.bar icon
   - Clicking the icon shows the dropdown menu
   - The "Quit" button properly closes the app

#### Step 5: Add a Basic Settings View

1. Create a new SwiftUI View file named `SettingsView.swift`
2. Implement a minimal settings view:

```swift
import SwiftUI

struct SettingsView: View {
    @State private var isEnabled = true
    
    var body: some View {
        Form {
            Toggle("Enable tracking", isOn: $isEnabled)
            
            HStack {
                Spacer()
                Button("Close") {
                    NSApplication.shared.keyWindow?.close()
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
```

3. Add a "Settings" button to the MenuBarExtra:

```swift
Button("Settings") {
    openSettings()
}
.padding(.bottom, 5)

Divider()
```

4. Add the following helper method to your App struct to open the settings window:

```swift
func openSettings() {
    if let settingsWindow = NSApplication.shared.windows.first(where: { $0.title == "Settings" }) {
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    } else {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 150),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = "Settings"
        settingsWindow.center()
        settingsWindow.contentView = NSHostingView(rootView: SettingsView())
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
```

#### Success Criteria for Phase 1

- [ ] App appears as a menu bar app (no Dock icon)
- [ ] Menu drops down when clicking the icon
- [ ] Settings window can be opened from the menu
- [ ] App can be quit via the menu option
- [ ] All UI elements appear correctly styled

### Next Steps

After completing Phase 1, you'll have a basic menu bar app infrastructure in place. You can then proceed to Phase 2, which focuses on implementing the Core Data model and basic data management functionality.

## Testing Checklist for Phase 1

- [ ] App builds without errors or warnings
- [ ] Menu bar icon appears correctly
- [ ] Menu displays when clicked
- [ ] Settings window opens and closes properly
- [ ] App quits cleanly when using the Quit button
- [ ] App launches on system startup if set to do so
- [ ] UI is properly styled and matches macOS standards
- [ ] No console errors or warnings during operation

## Troubleshooting Common Issues

### Menu bar icon not appearing

- Check that LSUIElement is set correctly in Info.plist
- Verify that the app is actually running (check Activity Monitor)

### Settings window not opening

- Check for errors in the console related to window creation
- Verify SettingsView implementation has no errors

### Menu not styled correctly

- Ensure you're using appropriate macOS styling for menu items
- Check padding and sizing for proper appearance

## Documentation

Keep detailed notes as you implement each feature. These notes will be valuable for:

1. Understanding your implementation choices
2. Troubleshooting issues
3. Preparing for the next phases of development

Good luck with Phase 1! Once complete, we'll move on to implementing Core Data models and basic data management in Phase 2.
