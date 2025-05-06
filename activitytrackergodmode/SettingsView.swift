import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState
    @State private var selectedTab = 0
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Tabs
            HStack {
                Picker("", selection: $selectedTab) {
                    Text("General").tag(0)
                    Text("Advanced").tag(1)
                    Text("About").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
            }
            .padding(.top, 16)
            
            TabView(selection: $selectedTab) {
                // GENERAL TAB
                VStack(spacing: 16) {
                    // Tracking settings
                    GroupBox(label: 
                        Text("Tracking Settings")
                            .font(.headline)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Enable activity tracking", isOn: $appState.isTracking)
                                .onChange(of: appState.isTracking) { _, newValue in
                                    appState.toggleTracking()
                                }
                            
                            Toggle("Start at login", isOn: .constant(false))
                                .disabled(true) // Implement in Phase 2
                            
                            Toggle("Show in menu bar", isOn: .constant(true))
                                .disabled(true) // Always true in Phase 1
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    // Display settings
                    GroupBox(label:
                        Text("Display Settings")
                            .font(.headline)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Menu bar icon:")
                                Spacer()
                                Picker("", selection: .constant("chart.bar")) {
                                    Label("Chart", systemImage: "chart.bar")
                                        .tag("chart.bar")
                                    
                                    Label("Clock", systemImage: "clock")
                                        .tag("clock")
                                    
                                    Label("Stopwatch", systemImage: "stopwatch")
                                        .tag("stopwatch")
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 120)
                            }
                            
                            HStack {
                                Text("Inactive timeout:")
                                Spacer()
                                Picker("", selection: .constant(5)) {
                                    Text("5 minutes").tag(5)
                                    Text("10 minutes").tag(10)
                                    Text("15 minutes").tag(15)
                                    Text("30 minutes").tag(30)
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                                .frame(width: 120)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    #if DEBUG
                    // Debug options
                    GroupBox(label:
                        Text("Debug Options")
                            .font(.headline)
                    ) {
                        Button("Simulate Activity") {
                            appState.simulateActivity()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    #endif
                    
                    Spacer()
                    
                    HStack {
                        Button("Reset Data") {
                            showResetConfirmation = true
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Button("Close") {
                            NSApplication.shared.keyWindow?.close()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .tag(0)
                
                // ADVANCED TAB
                VStack(spacing: 16) {
                    GroupBox(label:
                        Text("Privacy Settings")
                            .font(.headline)
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Track private browsing", isOn: .constant(false))
                            Toggle("Track sensitive apps", isOn: .constant(false))
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    GroupBox(label:
                        Text("Data Export")
                            .font(.headline)
                    ) {
                        VStack(spacing: 12) {
                            HStack {
                                Button("Export Data as CSV") {
                                    // To be implemented in Phase 2
                                }
                                .buttonStyle(.bordered)
                                .disabled(true) // Phase 2
                                
                                Spacer()
                                
                                Button("Export as JSON") {
                                    // To be implemented in Phase 2 
                                }
                                .buttonStyle(.bordered)
                                .disabled(true) // Phase 2
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
                .tag(1)
                
                // ABOUT TAB
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 48))
                        .foregroundColor(.accentColor)
                        .padding(.top, 20)
                    
                    Text("Activity Tracker God Mode")
                        .font(.title2.bold())
                    
                    Text("Version 0.1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer().frame(height: 20)
                    
                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity Tracker is a lightweight menu bar app for macOS that helps you track and analyze your app usage.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                            
                            Divider()
                                .padding(.vertical, 4)
                            
                            Text("Phase 1: Basic Menu Bar App")
                                .font(.headline)
                            
                            Text("✅ Menu bar functionality")
                            Text("✅ Basic app tracking")
                            Text("✅ Display current activity")
                            Text("☑️ Will be expanded in Phase 2")
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Text("© 2023 Your Company")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical)
                .tag(2)
            }
            .tabViewStyle(.automatic)
            .frame(height: 380)
        }
        .frame(width: 400, height: 450)
        .alert("Reset Activity Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                // Reset data (to be implemented)
            }
        } message: {
            Text("Are you sure you want to reset all activity data? This cannot be undone.")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(appState: AppState())
    }
} 