import SwiftUI

@main
struct SmartSheetsWatchApp: App {
    /// Watch oturum yöneticisini uygulama genelinde paylaşıyoruz.
    @StateObject private var sessionManager = WatchSessionManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionManager)
        }
    }
}
