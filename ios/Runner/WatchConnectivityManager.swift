import Foundation
import Flutter
import WatchConnectivity

/// iPhone tarafında WatchConnectivity oturumunu yöneten singleton sınıf.
final class WatchConnectivityManager: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivityManager()

    /// WCSession aktifleşmeden önce gelen veri burada bekler.
    private var pendingJSON: String?

    /// Flutter MethodChannel referansı — Watch'tan gelen istekleri Flutter'a iletmek için.
    private var flutterChannel: FlutterMethodChannel?

    private override init() {
        super.init()
    }

    // MARK: - Kurulum

    func setup() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func setFlutterChannel(_ channel: FlutterMethodChannel) {
        flutterChannel = channel
    }

    // MARK: - Veri Gönderimi

    func sendAppointments(jsonString: String) {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default

        // Session henüz aktif değilse veriyi sakla, aktivasyon bitince gönder
        guard session.activationState == .activated else {
            print("[Watch] Session aktif değil, veri beklemeye alındı")
            pendingJSON = jsonString
            return
        }

        _send(jsonString: jsonString, session: session)
    }

    private func _send(jsonString: String, session: WCSession) {
        let payload: [String: Any] = ["appointments_json": jsonString]
        print("[Watch] Gönderiliyor — paired:\(session.isPaired) installed:\(session.isWatchAppInstalled) reachable:\(session.isReachable)")

        // Her zaman context'i güncelle (Watch kapalıyken de çalışır)
        do {
            try session.updateApplicationContext(payload)
            print("[Watch] updateApplicationContext başarılı")
        } catch {
            print("[Watch] updateApplicationContext hatası: \(error)")
        }

        // Watch açıksa anlık mesaj da gönder
        if session.isReachable {
            session.sendMessage(payload, replyHandler: nil) { error in
                print("[Watch] sendMessage hatası: \(error)")
            }
            print("[Watch] sendMessage gönderildi")
        }
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("[Watch] iPhone aktivasyon: \(activationState.rawValue), hata: \(error?.localizedDescription ?? "yok")")
        // Aktivasyon tamamlandı — bekleyen veriyi şimdi gönder
        if activationState == .activated, let pending = pendingJSON {
            print("[Watch] Bekleyen veri gönderiliyor...")
            _send(jsonString: pending, session: session)
            pendingJSON = nil
        }
    }

    /// Watch'tan gelen mesajları işle (refresh / changeStatus)
    func session(_ session: WCSession, didReceiveMessage message: [String: Any],
                 replyHandler: @escaping ([String: Any]) -> Void) {
        let action = message["action"] as? String

        if action == "refresh" {
            print("[Watch] Watch'tan refresh isteği geldi")
            if let json = pendingJSON ?? session.applicationContext["appointments_json"] as? String {
                replyHandler(["appointments_json": json])
            } else {
                replyHandler([:])
            }

        } else if action == "changeStatus" {
            guard
                let appointmentId = message["appointment_id"] as? Int,
                let statusId      = message["status_id"] as? Int
            else {
                replyHandler(["success": false])
                return
            }
            print("[Watch] Durum değiştirme isteği — appointment:\(appointmentId) status:\(statusId)")

            DispatchQueue.main.async {
                self.flutterChannel?.invokeMethod(
                    "changeAppointmentStatus",
                    arguments: ["appointment_id": appointmentId, "status_id": statusId]
                ) { flutterResult in
                    let success = (flutterResult as? Bool) ?? false
                    print("[Watch] Flutter yanıtı — başarılı: \(success)")
                    replyHandler(["success": success])
                }
            }

        } else {
            replyHandler([:])
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
