import Foundation
import SwiftUI

// MARK: - Renk Yardımcısı

/// "#RRGGBB" hex string'ini SwiftUI Color'a çevirir.
func parseWatchColor(_ hex: String?) -> Color {
    guard
        let hex = hex?.trimmingCharacters(in: .init(charactersIn: "#")),
        hex.count == 6,
        let rgb = UInt64(hex, radix: 16)
    else { return .gray }
    let r = Double((rgb >> 16) & 0xFF) / 255
    let g = Double((rgb >> 8)  & 0xFF) / 255
    let b = Double( rgb        & 0xFF) / 255
    return Color(red: r, green: g, blue: b)
}

// MARK: - WatchStatus

/// Markaya ait bir randevu durumu.
struct WatchStatus: Identifiable {
    let id: Int
    let name: String
    let color: Color

    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? Int, id > 0 else { return nil }
        self.id    = id
        self.name  = dict["name"] as? String ?? ""
        self.color = parseWatchColor(dict["color"] as? String)
    }
}

// MARK: - WatchAppointment

/// Apple Watch tarafında kullanılan randevu veri modeli.
struct WatchAppointment: Identifiable {
    let id: UUID
    let appointmentId: Int
    let statusId: Int
    let title: String
    let date: String
    let time: String
    let endTime: String
    let statusName: String
    let statusColor: Color
    let notes: String

    init?(dict: [String: Any]) {
        guard let title = dict["title"] as? String, !title.isEmpty else {
            return nil
        }
        self.id            = UUID()
        self.appointmentId = dict["appointment_id"] as? Int ?? 0
        self.statusId      = dict["status_id"] as? Int ?? 0
        self.title         = title
        self.date          = dict["date"] as? String ?? ""
        self.time          = dict["time"] as? String ?? ""
        self.endTime       = dict["end_time"] as? String ?? ""
        self.statusName    = dict["status_name"] as? String ?? ""
        self.statusColor   = parseWatchColor(dict["status_color"] as? String)
        self.notes         = dict["notes"] as? String ?? ""
    }
}
