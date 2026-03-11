import Foundation
import Combine
import WatchConnectivity

final class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {

    static let shared = WatchSessionManager()

    @Published var upcoming: [WatchAppointment] = []
    @Published var current: WatchAppointment?    = nil
    @Published var past:    [WatchAppointment]   = []
    @Published var statuses: [WatchStatus]       = []
    @Published var isRefreshing: Bool            = false

    private override init() {
        super.init()
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Durum Değiştirme

    /// iPhone'a durum değiştirme isteği gönderir.
    ///
    /// - Parameter appointmentId: Güncellenecek randevunun ID'si
    /// - Parameter statusId: Yeni statü ID'si
    /// - Parameter completion: Başarı durumunu iletir (main thread)
    func changeStatus(
        appointmentId: Int,
        statusId: Int,
        completion: @escaping (Bool) -> Void
    ) {
        guard WCSession.default.isReachable else {
            print("[Watch] Durum değiştirme: iPhone ulaşılamaz")
            completion(false)
            return
        }
        WCSession.default.sendMessage(
            ["action": "changeStatus",
             "appointment_id": appointmentId,
             "status_id": statusId],
            replyHandler: { reply in
                let success = reply["success"] as? Bool ?? false
                print("[Watch] Durum değiştirme yanıtı — başarılı: \(success)")
                DispatchQueue.main.async { completion(success) }
            },
            errorHandler: { error in
                print("[Watch] Durum değiştirme hatası: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        )
    }

    // MARK: - Refresh

    /// iPhone'a randevuları yeniden gönder diye istek atar.
    func requestRefresh() {
        guard WCSession.default.isReachable else {
            print("[Watch] Refresh: iPhone ulaşılamaz, context yeniden yükleniyor")
            let ctx = WCSession.default.receivedApplicationContext
            if let json = ctx["appointments_json"] as? String {
                parseAndUpdate(jsonString: json)
            }
            return
        }
        DispatchQueue.main.async { self.isRefreshing = true }
        WCSession.default.sendMessage(["action": "refresh"], replyHandler: { [weak self] reply in
            print("[Watch] Refresh yanıtı alındı")
            if let json = reply["appointments_json"] as? String {
                self?.parseAndUpdate(jsonString: json)
            } else {
                DispatchQueue.main.async { self?.isRefreshing = false }
            }
        }, errorHandler: { [weak self] error in
            print("[Watch] Refresh hatası: \(error)")
            DispatchQueue.main.async { self?.isRefreshing = false }
        })
    }

    // MARK: - WCSessionDelegate

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("[Watch] Aktivasyon: \(activationState.rawValue), hata: \(error?.localizedDescription ?? "yok")")
        if activationState == .activated {
            let context = session.receivedApplicationContext
            print("[Watch] Mevcut context anahtarları: \(context.keys.joined(separator: ", "))")
            if let json = context["appointments_json"] as? String {
                print("[Watch] Context'ten veri alındı, uzunluk: \(json.count)")
                parseAndUpdate(jsonString: json)
            } else {
                print("[Watch] Context boş — iPhone uygulamasını açıp randevuları yükle")
            }
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        print("[Watch] sendMessage alındı, anahtarlar: \(message.keys.joined(separator: ", "))")
        if let json = message["appointments_json"] as? String {
            parseAndUpdate(jsonString: json)
        }
    }

    nonisolated func session(
        _ session: WCSession,
        didReceiveApplicationContext applicationContext: [String: Any]
    ) {
        print("[Watch] applicationContext alındı, anahtarlar: \(applicationContext.keys.joined(separator: ", "))")
        if let json = applicationContext["appointments_json"] as? String {
            parseAndUpdate(jsonString: json)
        }
    }

    // MARK: - Parse

    nonisolated private func parseAndUpdate(jsonString: String) {
        guard
            let data = jsonString.data(using: .utf8),
            let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            print("[Watch] JSON parse hatası")
            return
        }

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

        let statusList = (root["statuses"] as? [[String: Any]] ?? [])
            .compactMap { WatchStatus(dict: $0) }

        print("[Watch] Parse tamamlandı — upcoming:\(upcomingList.count) current:\(currentAppt != nil) past:\(pastList.count) statuses:\(statusList.count)")

        DispatchQueue.main.async {
            self.upcoming  = upcomingList
            self.current   = currentAppt
            self.past      = pastList
            self.statuses  = statusList
            self.isRefreshing = false
        }
    }
}
