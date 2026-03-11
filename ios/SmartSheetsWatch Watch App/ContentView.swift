import SwiftUI

/// Apple Watch ana ekranı.
/// Üç sekme içerir: Yaklaşan / Şu An / Geçmiş
struct ContentView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        TabView {
            UpcomingView()
                .tabItem {
                    Label("Yaklaşan", systemImage: "calendar")
                }

            CurrentView()
                .tabItem {
                    Label("Şu An", systemImage: "clock.fill")
                }

            PastView()
                .tabItem {
                    Label("Geçmiş", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}
