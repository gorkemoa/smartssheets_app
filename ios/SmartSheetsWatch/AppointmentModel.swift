import Foundation

/// Apple Watch tarafında kullanılan randevu veri modeli.
/// iPhone'dan WatchConnectivity ile gelen JSON verisi bu modele dönüştürülür.
struct WatchAppointment: Identifiable {
    let id: UUID
    let title: String
    let date: String   // Örnek: "15 Mart"
    let time: String   // Örnek: "14:30"

    init?(dict: [String: Any]) {
        guard let title = dict["title"] as? String, !title.isEmpty else {
            return nil
        }
        self.id    = UUID()
        self.title = title
        self.date  = dict["date"] as? String ?? ""
        self.time  = dict["time"] as? String ?? ""
    }
}
