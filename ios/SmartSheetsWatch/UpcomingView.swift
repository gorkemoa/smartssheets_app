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
                        NavigationLink(destination: AppointmentDetailView(appointment: appointment)) {
                            AppointmentRow(appointment: appointment)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Yaklaşan")
        }
    }
}
