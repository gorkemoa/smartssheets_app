import SwiftUI

/// Listedeki her randevuyu küçük ekrana uygun göster.
struct AppointmentRow: View {
    let appointment: WatchAppointment

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(appointment.title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)

            HStack(spacing: 4) {
                if !appointment.date.isEmpty {
                    Text(appointment.date)
                }
                if !appointment.date.isEmpty && !appointment.time.isEmpty {
                    Text("·")
                        .foregroundColor(.secondary)
                }
                if !appointment.time.isEmpty {
                    Text(appointment.time)
                }
            }
            .font(.system(size: 11))
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
