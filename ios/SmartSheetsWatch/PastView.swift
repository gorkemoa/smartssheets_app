import SwiftUI

/// Geçmiş (tamamlanmış) randevuların listesi.
struct PastView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        NavigationStack {
            Group {
                if session.past.isEmpty {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        message: "Geçmiş\nrandevu yok"
                    )
                } else {
                    List(session.past) { appointment in
                        NavigationLink(destination: AppointmentDetailView(appointment: appointment)) {
                            AppointmentRow(appointment: appointment)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Geçmiş")
        }
    }
}
