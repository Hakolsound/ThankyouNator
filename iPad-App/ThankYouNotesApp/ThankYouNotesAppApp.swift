import SwiftUI
import Firebase

@main
struct ThankYouNotesAppApp: App {
    @StateObject private var sessionManager = SessionManager()

    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
                .statusBar(hidden: true)
                .preferredColorScheme(.light)
        }
    }
}
