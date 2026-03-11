import SwiftUI

/// Randevu detay ekranı — listedeki bir satıra tıklanınca açılır.
struct AppointmentDetailView: View {
    let appointment: WatchAppointment

    @EnvironmentObject var session: WatchSessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var showStatusPicker = false
    @State private var isChanging       = false
    @State private var changeError      = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {

                // Statü badge
                if !appointment.statusName.isEmpty {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(appointment.statusColor)
                            .frame(width: 8, height: 8)
                        Text(appointment.statusName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(appointment.statusColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(appointment.statusColor.opacity(0.15))
                    .clipShape(Capsule())
                }

                // Başlık
                Text(appointment.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)

                Divider()

                // Tarih & Saat
                if !appointment.date.isEmpty {
                    Label {
                        Text(appointment.date)
                            .font(.system(size: 12))
                    } icon: {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                    }
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

                // Notlar
                if !appointment.notes.isEmpty {
                    Divider()
                    Label {
                        Text(appointment.notes)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(5)
                    } icon: {
                        Image(systemName: "note.text")
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Durum Değiştir butonu
                Button {
                    showStatusPicker = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("Durumu Değiştir")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.blue)
                }
                .disabled(isChanging || session.statuses.isEmpty)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .navigationTitle("Detay")
        .sheet(isPresented: $showStatusPicker) {
            StatusPickerView(
                currentStatusId: appointment.statusId,
                statuses: session.statuses
            ) { selectedStatusId in
                isChanging = true
                session.changeStatus(
                    appointmentId: appointment.appointmentId,
                    statusId: selectedStatusId
                ) { success in
                    isChanging = false
                    if success {
                        dismiss()
                    } else {
                        changeError = true
                    }
                }
            }
        }
        .alert("Hata", isPresented: $changeError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Durum güncellenemedi.\nİnternet bağlantınızı kontrol edin.")
        }
    }
}

// MARK: - StatusPickerView

/// Durum seçim ekranı — sheet olarak açılır.
private struct StatusPickerView: View {
    let currentStatusId: Int
    let statuses: [WatchStatus]
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List(statuses) { status in
            Button {
                dismiss()
                onSelect(status.id)
            } label: {
                HStack(spacing: 8) {
                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                    Text(status.name)
                        .font(.system(size: 13))
                        .foregroundColor(.primary)
                    Spacer()
                    if status.id == currentStatusId {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Durum")
    }
}
