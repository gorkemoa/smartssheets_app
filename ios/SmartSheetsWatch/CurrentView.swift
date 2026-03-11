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

                            // Statü badge
                            if !appointment.statusName.isEmpty {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(appointment.statusColor)
                                        .frame(width: 6, height: 6)
                                    Text(appointment.statusName)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(appointment.statusColor)
                                }
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(appointment.statusColor.opacity(0.15))
                                .clipShape(Capsule())
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
                                Label {
                                    Group {
                                        if appointment.endTime.isEmpty {
                                            Text(appointment.time)
                                        } else {
                                            Text("\(appointment.time) – \(appointment.endTime)")
                                        }
                                    }
                                    .font(.system(size: 12))
                                } icon: {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                }
                            }

                            if !appointment.notes.isEmpty {
                                Divider()
                                Label {
                                    Text(appointment.notes)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(4)
                                } icon: {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.secondary)
                                }
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
