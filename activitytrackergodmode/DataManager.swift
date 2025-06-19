import Foundation
import CoreData

public class DataManager {
    private let persistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        self.viewContext = persistenceController.container.viewContext
    }

    // MARK: - ActivitySession Operations

    public func createNewSession(
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

    public func endSession(_ session: ActivitySession) {
        session.endTime = Date()
        session.isActive = false
        saveContext()
    }

    public func updateSession(
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

    public func getActiveSessions() -> [ActivitySession] {
        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isActive == %@", NSNumber(value: true))

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching active sessions: \(error.localizedDescription)")
            return []
        }
    }

    public func getSessionsByDay(date: Date) -> [ActivitySession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            // This should ideally not happen if startOfDay is valid.
            // Consider if specific error handling or logging is needed here.
            print("Error calculating end of day for date: \(date)")
            return []
        }

        let fetchRequest: NSFetchRequest<ActivitySession> = ActivitySession.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "startTime >= %@ AND startTime < %@",
            startOfDay as NSDate,
            endOfDay as NSDate
        )

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("Error fetching sessions by day for date \(date): \(error.localizedDescription)")
            return []
        }
    }

    // MARK: - Helper Methods

    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                // It's generally better to handle errors more gracefully than just printing.
                // For example, logging to a file or analytics, or even informing the user in some cases.
                // However, for this phase, printing is acceptable as per the guide.
                let nserror = error as NSError
                print("Error saving context: \(nserror.localizedDescription), \(nserror.userInfo)")
            }
        }
    }
}
