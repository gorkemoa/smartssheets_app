import Foundation
import WatchConnectivity

/// Apple Watch tarafında WatchConnectivity oturumunu yöneten ObservableObject.
///
/// iPhone'dan gelen randevu verilerini dinler ve SwiftUI view'larını günceller.
/// Arka planda (context) ve anlık (message) olmak üzere iki kanalı da destekler.
final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    @Published var upcoming: [WatchAppointment] = []
    @Published var current: WatchAppointment?    = nil
    @Published var past:    [WatchAppointment] = []

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        // Uygulama başladığında mevcut context'i yükle
        if activationState == .activated {
            let context = session.receivedApplicationContext
            if let json = context["appointments_json"] as? String {
                parseAndUpdate(jsonString: json)
            }
        }
    }

    /// iPhone uygulaması açıkken gerçek zamanlı mesaj alındığında çağrılır.
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        if let json = message["appointments_json"] as? String {
            parseAndUpdate(jsonString: json)
        }
    }

    /// iPhone uygulaması kapalıyken gönderilen context güncellemesi alındığında çağrılır.
    func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        if let json = applicationContext["appointments_json"] as? String {
            parseAndUpdate(jsonString: json)
        }
    }

    // MARK: - Yardımcı Metodlar

    /// Gelen JSON string'ini parse eder ve Published değişkenleri günceller.
    private func parseAndUpdate(jsonString: String) {
        guard
            let data = jsonString.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        let upcomingList = (root["upcoming"] as? [[String: Any]] ?? [])
            .compactMap { WatchAppointment(dict: $0) }

        let currentAppt: WatchAppointment?
        if let currentMap = root["current"] as? [String: Any], !currentMap.isEmpty {
            currentAppt = WatchAppointment(dict: currentMap)
        } else {
            currentAppt = nil
        }

        let pastList = (root["past"] as? [[String: Any]] ?? [])
            .compactMap { WatchAppointment(dict: $0) }

        DispatchQueue.main.async {
            self.upcoming = upcomingList
            self.current  = currentAppt
            self.past     = pastList
        }
    }
}
