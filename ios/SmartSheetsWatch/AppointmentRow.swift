import SwiftUI

/// Listedeki her randevuyu küçük ekrana uygun göster.
struct AppointmentRow: View {
    let appointment: WatchAppointment

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Başlık
            Text(appointment.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack(spacing: 6) {
                // Statü renk badge'i
                if !appointment.statusName.isEmpty {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(appointment.statusColor)
                            .frame(width: 6, height: 6)
                        Text(appointment.statusName)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(appointment.statusColor)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Saat
                if !appointment.time.isEmpty {
                    Text(appointment.time)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }

            // Tarih
            if !appointment.date.isEmpty {
                Text(appointment.date)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 3)
    }
}
