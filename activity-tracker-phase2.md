# Activity Tracker - Phase 2 Guide

## Core Data & Basic Structure (2-3 days)

After completing Phase 1, you now have a functioning menu bar app. Phase 2 focuses on setting up the Core Data model and implementing the basic data management functions that will power your activity tracking.

### Prerequisites

- Completed Phase 1 successfully
- Basic understanding of Core Data concepts
- Familiarity with CRUD operations

### Step 1: Design the Core Data Model

1. Open the `.xcdatamodeld` file in your project
2. Create the following entities:

#### Entity: ActivitySession
- **uuid**: UUID (required)
- **startTime**: Date (required)
- **endTime**: Date (optional)
- **applicationName**: String (required)
- **applicationBundleID**: String (required)
- **windowTitle**: String (optional)
- **tabTitle**: String (optional)
- **projectName**: String (optional)
- **filePath**: String (optional)
- **isActive**: Boolean (required)

#### Entity: ActivitySummary
- **date**: Date (required)
- **totalActiveTime**: Double (required)
- **relationships**: To-many relationship to AppStat called "applicationStats"

#### Entity: AppStat
- **applicationName**: String (required)
- **applicationBundleID**: String (required)
- **totalTimeSpent**: Double (required)
- **activityPercentage**: Double (required)
- **relationships**: To-one relationship to ActivitySummary

3. Generate NSManagedObject subclasses:
   - Select each entity
   - Editor → Create NSManagedObject Subclass...
   - Follow the wizard to create the classes

### Step 2: Set Up the Persistence Controller

1. Create a new Swift file named `PersistenceController.swift`
2. Implement a basic persistence controller:

```swift
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ActivityTrackerGodMode")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // For tests
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // Add sample data if needed
        return controller
    }()
}
```

3. Update your `App` file to use the PersistenceController:

```swift
@main
struct ActivityTrackerGodModeApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        // Existing code
    }
}
```

### Step 3: Create the DataManager

1. Create a new Swift file named `DataManager.swift`
2. Implement the basic CRUD operations:

```swift
import Foundation
import CoreData

class DataManager {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = persistenceController.container.viewContext
    }
    
    // MARK: - ActivitySession Operations
    
    func createNewSession(
        applicationName: String,
        applicationBundleID: String,
        windowTitle: String? = nil,
        tabTitle: String? = nil,
        projectName: String? = nil,
        filePath: String? = nil
    ) -> ActivitySession {
        let session = ActivitySession(context: viewContext)
        
        session.uuid = UUID()
        session.startTime = Date()
        session.isActive = true
        session.applicationName = applicationName
        session.applicationBundleID = applicationBundleID
        session.windowTitle = windowTitle
        session.tabTitle = tabTitle
        session.projectName = projectName
        session.filePath = filePath
        
        saveContext()
        return session
    }
    
    func endSession(_ session: ActivitySession) {
        session.endTime = Date()
        session.isActive = false
        saveContext()
    }
    
    func updateSession(
        _ session: ActivitySession,
        windowTitle: String? = nil,
        tabTitle: String? = nil,
        projectName: String? = nil,
        filePath: String? = nil
    ) {
        session.windowTitle = windowTitle ?? session.windowTitle
        session.tabTitle = tabTitle ?? session.tabTitle
        session.projectName = projectName ?? session.projectName
        session.filePath = filePath ?? session.filePath
        
        saveContext()
    }
    
    func getActiveSessions() -> [ActivitySession] {
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching active sessions: \(error)")
            return []
        }
    }
    
    func getSessionsByDay(date: Date) -> [ActivitySession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "startTime >= %@ AND startTime < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )
        
        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching sessions by day: \(error)")
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
}
```

### Step 4: Create a Test Harness

1. Create a new Swift file named `TestDataGenerator.swift`
2. Implement a simple function to create test data:

```swift
import Foundation

class TestDataGenerator {
    private let dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    func generateTestData() {
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
        dataManager.endSession(safariSession)
        
        // Back to Xcode - still active
        dataManager.updateSession(
            xcodeSession,
            windowTitle: "DataManager.swift - ActivityTrackerGodMode"
        )
        
        print("Test data generated successfully.")
    }
}
```

3. Add a button to your menu to generate test data:

```swift
#if DEBUG
Button("Generate Test Data") {
    let generator = TestDataGenerator(dataManager: DataManager())
    generator.generateTestData()
}
.padding(.bottom, 5)
#endif
```

### Step 5: Implement Basic Data Viewing

1. Create a simple view to display active sessions
2. Add it to the menu bar dropdown:

```swift
struct ActiveSessionsView: View {
    @State private var activeSessions: [ActivitySession] = []
    private let dataManager = DataManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Sessions")
                .font(.headline)
            
            if activeSessions.isEmpty {
                Text("No active sessions")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(activeSessions, id: \.uuid) { session in
                    VStack(alignment: .leading) {
                        Text(session.applicationName ?? "Unknown")
                            .font(.subheadline)
                        if let windowTitle = session.windowTitle {
                            Text(windowTitle)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                    .padding(.bottom, 2)
                }
            }
        }
        .padding()
        .onAppear {
            refreshSessions()
        }
    }
    
    private func refreshSessions() {
        activeSessions = dataManager.getActiveSessions()
    }
}
```

### Step 6: Write Unit Tests for the Data Layer

1. Create a test file for the DataManager
2. Implement basic unit tests:

```swift
import XCTest
@testable import ActivityTrackerGodMode

final class DataManagerTests: XCTestCase {
    var dataManager: DataManager!
    var testPersistenceController: PersistenceController!
    
    override func setUpWithError() throws {
        testPersistenceController = PersistenceController(inMemory: true)
        dataManager = DataManager(persistenceController: testPersistenceController)
    }
    
    override func tearDownWithError() throws {
        dataManager = nil
        testPersistenceController = nil
    }
    
    func testCreateSession() throws {
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
        XCTAssertEqual(session.applicationName, appName)
        XCTAssertEqual(session.applicationBundleID, bundleID)
        XCTAssertEqual(session.windowTitle, windowTitle)
        XCTAssertTrue(session.isActive)
        XCTAssertNotNil(session.startTime)
        XCTAssertNil(session.endTime)
    }
    
    func testEndSession() throws {
        // Given
        let session = dataManager.createNewSession(
            applicationName: "TestApp",
            applicationBundleID: "com.test.app"
        )
        
        // When
        dataManager.endSession(session)
        
        // Then
        XCTAssertFalse(session.isActive)
        XCTAssertNotNil(session.endTime)
    }
    
    func testGetActiveSessions() throws {
        // Given
        dataManager.createNewSession(
            applicationName: "ActiveApp1",
            applicationBundleID: "com.test.active1"
        )
        
        let inactiveSession = dataManager.createNewSession(
            applicationName: "InactiveApp",
            applicationBundleID: "com.test.inactive"
        )
        dataManager.endSession(inactiveSession)
        
        dataManager.createNewSession(
            applicationName: "ActiveApp2",
            applicationBundleID: "com.test.active2"
        )
        
        // When
        let activeSessions = dataManager.getActiveSessions()
        
        // Then
        XCTAssertEqual(activeSessions.count, 2)
        XCTAssertTrue(activeSessions.allSatisfy { $0.isActive })
    }
    
    func testGetSessionsByDay() throws {
        // Given
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        // Create sessions from yesterday
        let yesterdaySession = dataManager.createNewSession(
            applicationName: "YesterdayApp",
            applicationBundleID: "com.test.yesterday"
        )
        // Manually set the date to yesterday
        yesterdaySession.startTime = yesterday
        
        // Create sessions from today
        dataManager.createNewSession(
            applicationName: "TodayApp1",
            applicationBundleID: "com.test.today1"
        )
        
        dataManager.createNewSession(
            applicationName: "TodayApp2",
            applicationBundleID: "com.test.today2"
        )
        
        // When
        let todaySessions = dataManager.getSessionsByDay(date: today)
        let yesterdaySessions = dataManager.getSessionsByDay(date: yesterday)
        
        // Then
        XCTAssertEqual(todaySessions.count, 2)
        XCTAssertEqual(yesterdaySessions.count, 1)
    }
}
```

### Success Criteria for Phase 2

- [ ] Core Data model is properly defined and NSManagedObject subclasses generated
- [ ] Persistence Controller is implemented and working
- [ ] DataManager provides CRUD operations for activity sessions
- [ ] Test harness can generate sample data
- [ ] Active sessions can be displayed in the menu
- [ ] Unit tests pass for all data layer functionality

### Next Steps

After completing Phase 2, you'll have the data layer of your activity tracker in place. This provides the foundation for the actual activity monitoring, which will be implemented in Phase 3 using NSWorkspace notifications and Accessibility APIs.

## Testing Checklist for Phase 2

- [ ] Core Data model can be created and saved
- [ ] Active sessions can be queried
- [ ] Sessions can be filtered by date
- [ ] Test data generator creates valid data
- [ ] All unit tests pass
- [ ] Manual testing of the data layer works as expected
- [ ] Test for proper error handling in edge cases

## Troubleshooting Common Issues

### Core Data Entity Generation Issues
- Ensure your entity model has all required attributes
- Check for naming conflicts in your project
- Make sure the generated classes have the correct module

### Core Data Save Errors
- Look for constraint violations in your data model
- Check for threading issues (save on the same context)
- Verify relationships are properly configured

### Test Data Not Appearing
- Validate the in-memory flag for testing
- Check that save operations are being called
- Verify query predicates are formatted correctly

## Additional Resources

- [Apple's Core Data Documentation](https://developer.apple.com/documentation/coredata)
- [WWDC Videos on Core Data](https://developer.apple.com/videos/all-videos/?q=core%20data)
- [SwiftUI and Core Data Integration](https://developer.apple.com/documentation/swiftui/fetching_data_with_swiftui) 