import Foundation
import AppKit // For AXIsProcessTrustedWithOptions, NSWorkspace, etc.

public class AccessibilityService {

    public static let shared = AccessibilityService()

    private init() {} // Private initializer for singleton

    /// Checks the current accessibility permission status.
    ///
    /// - Parameter promptIfNeeded: If true and permissions are not granted,
    ///   this will trigger the system prompt to the user.
    /// - Returns: True if permissions are granted, false otherwise.
    public func checkAccessibilityPermissions(promptIfNeeded: Bool = false) -> Bool {
        if promptIfNeeded {
            // When prompting, pass true for kAXTrustedCheckOptionPrompt
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
            return AXIsProcessTrustedWithOptions(options as CFDictionary)
        } else {
            // When just checking, pass false or an empty dictionary
            // AXIsProcessTrusted() is simpler if not prompting but deprecated.
            // Using AXIsProcessTrustedWithOptions with no prompt option is the modern way.
            let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
            return AXIsProcessTrustedWithOptions(options as CFDictionary)
        }
    }

    /// Convenience method to request accessibility permissions by triggering the system prompt if needed.
    ///
    /// This can also be a place to initiate custom UI guidance in the future
    /// if the user has previously denied permissions.
    @discardableResult // To allow calling without needing to use the Bool result
    public func requestAccessibilityPermissions() -> Bool {
        print("AccessibilityService: Requesting accessibility permissions (will prompt if needed).")
        let granted = checkAccessibilityPermissions(promptIfNeeded: true)
        if !granted {
            print("AccessibilityService: Permissions were not granted after prompt (or already denied).")
            // Consider calling showPermissionsGuidance() here or based on further logic
        } else {
            print("AccessibilityService: Permissions are granted.")
        }
        return granted
    }

    /// Placeholder for showing custom UI guidance on how to grant permissions
    /// in System Settings.
    public func showPermissionsGuidance() {
        // This would typically open a new window or guide the user to
        // System Settings > Privacy & Security > Accessibility.
        print("AccessibilityService: Showing permissions guidance (UI not yet implemented). For now, please go to System Settings > Privacy & Security > Accessibility and enable for this app.")
        // Example: NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
    }
}
