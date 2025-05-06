# Mac Activity Tracker - Incremental Development Plan

## Project Overview

**App Name:** Activity Tracker  
**Bundle Identifier:** com.yourcompany.activitytracker
**Platform:** macOS (13.0+)  
**Architecture:** Menu Bar App with expandable UI  
**Primary Goal:** Track active applications, windows, tabs, and projects with minimal resource usage

## Technology Stack

- **Language:** Swift (Latest stable version)
- **UI Framework:** SwiftUI for UI components
- **App Type:** Menu Bar Extra App with Window capabilities
- **Data Storage:** Core Data for activity tracking database
- **Background Processing:** AppKit's NSWorkspace and Accessibility APIs
- **Testing:** XCTest for unit/integration testing, XCUITest for UI testing
- **Permissions:** Accessibility, Screen Recording (optional)
- **Distribution:** Notarization for local use or Mac App Store submission

## Development Phases

### Phase 1: Project Setup & Basic Menu Bar App ✅

**Goals:**

- ✅ Create a basic menu bar app with SwiftUI
- ✅ Implement app icon and basic UI
- ✅ Create preferences window
- ✅ Set up navigation structure
- ✅ Handle menu bar interactions
- ✅ Implement basic activity tracking

**Details:**

- ✅ Create Xcode project with SwiftUI
- ✅ Set up Menu Bar Extra structure
- ✅ Design simple menu UI with expandable sections
- ✅ Create a preferences window for app settings
- ✅ Implement basic system to track current application
- ✅ Implement app visibility settings

**Success Criteria:**

- ✅ App appears as a menu bar icon
- ✅ Menu displays current activity
- ✅ Settings window loads and functions
- ✅ App collects basic usage statistics
- ✅ UI shows tracked apps and usage time

### Phase 2: Core Data & Basic Structure (2-3 days)

#### 2.1 Core Data Model

- Create Core Data model with initial entities:
  - ActivitySession
  - ActivitySummary
  - AppStat
- Generate NSManagedObject subclasses
- Create persistence controller

#### 2.2 Basic Data Manager

- Implement DataManager class
- Add CRUD operations for activity sessions
- Test Core Data stack is working properly

#### 2.3 Unit Tests for Data Layer

- Write tests for DataManager
- Create in-memory Core Data store for testing
- Test session creation, retrieval, and updates

#### Success Criteria

- Core Data model properly implemented
- Basic CRUD operations working correctly
- Data layer passes all unit tests

### Phase 3: Activity Monitoring Service (3-4 days)

#### 3.1 Accessibility Setup

- Add necessary Info.plist entries for accessibility
- Implement permission request handling
- Create user guidance for enabling permissions

#### 3.2 Basic Activity Monitoring

- Implement ActivityMonitorService
- Add NSWorkspace notification handling
- Implement timer-based updates
- Create test harness to verify monitoring

#### 3.3 App Switching Detection

- Detect application switching events
- Record app switching in Core Data
- Test proper recording of application usage

#### Success Criteria

- Accessibility permissions can be requested correctly
- Basic app switching detection works
- Activity data is properly recorded in database

### Phase 4: Window & Tab Detection (3-4 days)

#### 4.1 Window Title Detection

- Implement Accessibility API calls to get window title
- Add window information to activity sessions
- Test with various applications

#### 4.2 Browser Tab Detection

- Add browser-specific detection logic
- Implement tab title extraction for Safari, Chrome, Firefox
- Test with various websites

#### 4.3 Project/Document Detection

- Add IDE/document app specific detection
- Extract project names from coding environments
- Test with various document-based apps

#### Success Criteria

- Window titles correctly detected and recorded
- Browser tabs properly identified in supported browsers
- Project/document names detected where applicable

### Phase 5: Menu Bar UI (2-3 days)

#### 5.1 Current Activity Display

- Design and implement current activity view
- Show active application and window/tab
- Display duration of current activity

#### 5.2 Basic Statistics Display

- Add basic usage statistics to menu bar UI
- Create today's summary view
- Display top 3 applications used today

#### 5.3 Permission Request UI

- Create permissions request view
- Add direct links to system preferences
- Test UI flow for users without permissions

#### Success Criteria

- Menu bar UI displays current activity correctly
- Basic statistics are shown in the dropdown
- Permissions flow is clear and intuitive

### Phase 6: Basic Detail Window (2-3 days)

#### 6.1 Detail Window Setup

- Create basic window UI using WindowGroup
- Add navigation structure (sidebar or tabs)
- Implement window/menu bar connection

#### 6.2 Dashboard View

- Implement basic dashboard view
- Add timeframe selector (today, yesterday, etc.)
- Display summary statistics

#### 6.3 Settings View

- Create settings UI
- Implement user preference storage
- Add options for tracking behavior

#### Success Criteria

- Detail window can be opened from menu bar
- Basic dashboard shows activity data
- Settings can be changed and persisted

### Phase 7: Timeline & Charts (3-4 days)

#### 7.1 Timeline View

- Implement chronological activity timeline
- Show hourly breakdown of activities
- Add date selection for historical data

#### 7.2 Activity Charts

- Add app usage pie/bar charts
- Implement time distribution visualization
- Create trend analysis for multi-day views

#### 7.3 Data Loading Optimization
- Optimize data loading for large datasets
- Implement paging for timeline view
- Use background loading where appropriate

#### Success Criteria

- Timeline view shows activities chronologically
- Charts accurately reflect app usage
- UI remains responsive with large datasets

### Phase 8: Data Export & Management (2 days)

#### 8.1 Data Export

- Implement JSON/CSV export functionality
- Create export options UI
- Test exports with various data sizes

#### 8.2 Data Management

- Add data retention settings
- Implement automatic cleanup of old data
- Add manual data clearing options

#### 8.3 Data Import (Optional)

- Add import functionality for exported data
- Implement validation for imported data
- Test with various export formats

#### Success Criteria

- Data can be exported in usable formats
- Old data is properly managed per settings
- Data management UI is intuitive

### Phase 9: Advanced Features & Polish (3-4 days)

#### 9.1 Idle Detection

- Implement system idle detection
- Add settings for idle threshold
- Test idle handling in various scenarios

#### 9.2 Notifications & Alerts

- Add optional usage alerts/summaries
- Implement daily/weekly report notifications
- Create notification preferences

#### 9.3 UI Polish & Refinement

- Refine UI animations and transitions
- Add keyboard shortcuts where appropriate
- Ensure consistent visual design

#### Success Criteria

- Idle time properly detected and handled
- Notifications work as expected with user settings
- UI feels polished and professional

### Phase 10: Testing & Deployment (2-3 days)

#### 10.1 Comprehensive Testing

- Run full test suite (unit, integration, UI)
- Perform manual testing on various macOS versions
- Test with different permission scenarios

#### 10.2 Performance Optimization

- Profile app for CPU/memory usage
- Optimize database queries
- Reduce battery impact

#### 10.3 Deployment Preparation

- Configure code signing
- Prepare for notarization
- Create installation package

#### Success Criteria

- App passes all tests without issues
- Performance is optimized with minimal resource usage
- App is ready for distribution

## Testing Strategy

### Test-Driven Approach

1. Write tests before implementing features
2. Use XCTest framework for unit and integration tests
3. Create mock objects for external dependencies
4. Use in-memory Core Data store for data layer testing

### Component Testing

For each phase:

1. Test individual components in isolation
2. Verify integration between related components
3. Create test harnesses for components requiring user interaction

### Performance Testing

1. Test CPU usage during normal operation
2. Measure memory footprint over time
3. Check battery impact with extended usage
4. Verify responsiveness with large datasets

### User Testing

1. Have actual users test each major phase
2. Collect feedback on usability issues
3. Identify any confusion points in UI/flow
4. Test with permissions both granted and denied

## Technical Challenges & Mitigation

### Challenge: Accessibility Permissions

**Mitigation:**
- Clear explanations for why permissions are needed
- Step-by-step visual guidance for enabling permissions
- Graceful operation with limited functionality when permissions are denied

### Challenge: Browser Tab Detection

**Mitigation:**
- Browser-specific implementation for major browsers
- 
- Fallback to window title when tab detection isn't possible
- Regular updates to handle browser version changes

### Challenge: Battery Impact

**Mitigation:**

- Adjustable update frequency based on battery status
- Batch database operations to reduce disk I/O
- Optimize queries for data retrieval

### Challenge: Privacy Concerns

**Mitigation:**

- All data stored locally only
- Clear data retention policies
- Easy options to clear all stored data
- No external data transmission

## Phase Dependencies & Required Knowledge

### Dependencies Between Phases

- Phase 3 depends on Phase 2 for data storage
- Phase 5 depends on Phases 3-4 for activity data
- Phase 7 depends on sufficient data collected in earlier phases

### Required Knowledge

- Swift and SwiftUI fundamentals
- Core Data basics for data management
- AppKit APIs for system integration
- Accessibility API for window/app detection
- Basic chart generation with SwiftUI

## Resources & Tips

### Debugging Tips

- Use Accessibility Inspector to understand UI hierarchies
- Enable Core Data debug output for database issues
- Create debug settings for verbose logging

### Performance Tips

- Use Instruments to profile CPU/memory usage
- Test on older hardware to ensure performance
- Implement background processing for intensive operations

### Documentation

- Document permission requirements clearly
- Add inline comments for complex accessibility code
- Create a user guide explaining the app's capabilities

## Future Expansion Ideas

1. Sync across devices via iCloud
2. Automation via AppleScript/Shortcuts
3. Browser extensions for enhanced tracking
4. Productivity scoring and insights
5. Integration with task management systems
6. AI-powered work pattern analysis

## Release Plan

**MVP (v1.0):**

- Basic activity tracking
- Simple UI
- Core functionality
- Basic data visualization
- Local storage only

**Update (v1.x):**

- Enhanced tracking precision
- Improved UI and visualizations
- Basic productivity insights
- Export capabilities

**Full Release (v2.0):**

- Complete feature set
- Cross-device synchronization
- Advanced insights and reporting
- Integration capabilities
