import SwiftUI

/// Yaklaşan (henüz başlamamış) randevuların listesi.
struct UpcomingView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        NavigationStack {
            Group {
                if session.upcoming.isEmpty {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        message: "Yaklaşan\nrandevu yok"
                    )
                } else {
                    List(session.upcoming) { appointment in
                        AppointmentRow(appointment: appointment)
                    }
                    .listStyle(.carousel)
                }
            }
            .navigationTitle("Yaklaşan")
        }
    }
}
