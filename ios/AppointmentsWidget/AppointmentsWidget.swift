import WidgetKit
import SwiftUI

struct WidgetAppointment: Codable, Identifiable {
    var id: Int
    var title: String
    var startsAt: String
    var statusName: String
    var statusColor: String
    enum CodingKeys: String, CodingKey {
        case id, title
        case startsAt    = "starts_at"
        case statusName  = "status_name"
        case statusColor = "status_color"
    }
}

struct AppointmentsEntry: TimelineEntry {
    let date: Date
    let appointments: [WidgetAppointment]
}

struct AppointmentsProvider: TimelineProvider {
    private let appGroupId = "group.com.smartmetrics.smartsheetsapp"
    private let dataKey    = "appointments_json"

    func placeholder(in context: Context) -> AppointmentsEntry {
        AppointmentsEntry(date: Date(), appointments: [])
    }
    func getSnapshot(in context: Context, completion: @escaping (AppointmentsEntry) -> Void) {
        completion(loadEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<AppointmentsEntry>) -> Void) {
        let entry = loadEntry()
        let next  = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
    private func loadEntry() -> AppointmentsEntry {
        let json  = UserDefaults(suiteName: appGroupId)?.string(forKey: dataKey) ?? "[]"
        let apts  = (try? JSONDecoder().decode([WidgetAppointment].self, from: Data(json.utf8))) ?? []
        return AppointmentsEntry(date: Date(), appointments: apts)
    }
}

extension Color {
    init?(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var n: UInt64 = 0
        guard Scanner(string: h).scanHexInt64(&n) else { return nil }
        let a, r, g, b: UInt64
        switch h.count {
        case 3: (a,r,g,b) = (255,(n>>8)*17,(n>>4 & 0xF)*17,(n & 0xF)*17)
        case 6: (a,r,g,b) = (255,n>>16,n>>8 & 0xFF,n & 0xFF)
        case 8: (a,r,g,b) = (n>>24,n>>16 & 0xFF,n>>8 & 0xFF,n & 0xFF)
        default: return nil
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

struct AppointmentRowView: View {
    let appointment: WidgetAppointment
    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(hex: appointment.statusColor) ?? Color.gray)
                .frame(width: 3, height: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(appointment.title)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "clock").font(.system(size: 9)).foregroundColor(.secondary)
                    Text(formatTime(appointment.startsAt)).font(.system(size: 10)).foregroundColor(.secondary)
                    if !appointment.statusName.isEmpty {
                        Text("·").font(.system(size: 10)).foregroundColor(.secondary)
                        Text(appointment.statusName)
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: appointment.statusColor) ?? .secondary)
                            .lineLimit(1)
                    }
                }
            }
            Spacer()
        }
    }
    private func formatTime(_ iso: String) -> String {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: iso) { return fmt(d) }
        f.formatOptions = [.withInternetDateTime]
        if let d = f.date(from: iso) { return fmt(d) }
        return iso
    }
    private func fmt(_ d: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; f.timeZone = .current; return f.string(from: d)
    }
}

struct AppointmentsWidgetEntryView: View {
    var entry: AppointmentsProvider.Entry
    @Environment(\.widgetFamily) var family
    private var maxRows: Int { family == .systemSmall ? 3 : 5 }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Image(systemName: "calendar").font(.system(size: 11, weight: .semibold)).foregroundColor(.accentColor)
                Text("Randevular").font(.system(size: 12, weight: .bold))
                Spacer()
                Text(todayStr()).font(.system(size: 10)).foregroundColor(.secondary)
            }
            .padding(.bottom, 6)
            Divider().padding(.bottom, 6)
            if entry.appointments.isEmpty {
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle").font(.system(size: 20)).foregroundColor(.secondary.opacity(0.5))
                    Text("Yaklaşan randevu yok").font(.system(size: 11)).foregroundColor(.secondary).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(entry.appointments.prefix(maxRows))) { AppointmentRowView(appointment: $0) }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(12)
    }
    private func todayStr() -> String {
        let f = DateFormatter(); f.dateFormat = "d MMM"; f.locale = Locale(identifier: "tr_TR"); return f.string(from: Date())
    }
}

struct AppointmentsWidget: Widget {
    let kind = "AppointmentsWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AppointmentsProvider()) { entry in
            AppointmentsWidgetEntryView(entry: entry)
                .containerBackground(.background, for: .widget)
        }
        .configurationDisplayName("Randevular")
        .description("Yaklaşan randevularını takip et.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
