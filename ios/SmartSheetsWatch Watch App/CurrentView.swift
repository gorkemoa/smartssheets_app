import SwiftUI

/// Şu anda devam eden aktif randevuyu gösterir.
struct CurrentView: View {
    @EnvironmentObject var session: WatchSessionManager

    var body: some View {
        NavigationStack {
            Group {
                if let appointment = session.current {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            // Aktif göstergesi
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Devam ediyor")
                                    .font(.system(size: 11))
                                    .foregroundColor(.green)
                            }

                            Text(appointment.title)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.primary)

                            if !appointment.date.isEmpty {
                                Label(appointment.date, systemImage: "calendar")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }

                            if !appointment.time.isEmpty {
                                Label(appointment.time, systemImage: "clock")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                } else {
                    EmptyStateView(
                        icon: "clock",
                        message: "Şu an aktif\nrandevu yok"
                    )
                }
            }
            .navigationTitle("Şu An")
        }
    }
}
