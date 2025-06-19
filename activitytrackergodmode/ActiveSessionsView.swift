import SwiftUI
import CoreData // Though not directly used, good for context or future direct CoreData interaction

struct ActiveSessionsView: View {
    @State private var activeSessions: [ActivitySession] = []
    private let dataManager = DataManager() // Using default PersistenceController.shared

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Sessions")
                .font(.headline)
                .padding(.bottom, 5)

            if activeSessions.isEmpty {
                Text("No active sessions currently.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(activeSessions, id: \.uuid) { session in
                    VStack(alignment: .leading) {
                        Text(session.applicationName ?? "Unknown App")
                            .font(.subheadline)
                        if let windowTitle = session.windowTitle, !windowTitle.isEmpty {
                            Text(windowTitle)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .padding(.bottom, 2)
                    if session.uuid != activeSessions.last?.uuid {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .onAppear(perform: refreshSessions)
    }

    private func refreshSessions() {
        activeSessions = dataManager.getActiveSessions()
        print("ActiveSessionsView: Refreshed, found \(activeSessions.count) active sessions.")
    }
}

struct ActiveSessionsView_Previews: PreviewProvider {
    static var previews: some View {
        // Note: This preview will not work correctly without a functioning
        // DataManager and potentially some sample data in the preview context.
        // For now, it just renders the static view structure.
        ActiveSessionsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
