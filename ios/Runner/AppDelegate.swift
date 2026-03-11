import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // 1. WatchConnectivity oturumunu başlat
    WatchConnectivityManager.shared.setup()

    // 2. Flutter ↔ iOS Platform Channel'ını kaydet
    if let controller = window?.rootViewController as? FlutterViewController {
      let watchChannel = FlutterMethodChannel(
        name: "com.smartmetrics.smartsheetsapp/watch",
        binaryMessenger: controller.binaryMessenger
      )

      // Watch → iPhone → Flutter köprüsü için channel ref'ini paylaş
      WatchConnectivityManager.shared.setFlutterChannel(watchChannel)

      watchChannel.setMethodCallHandler { call, result in
        switch call.method {
        case "sendAppointments":
          guard
            let args = call.arguments as? [String: Any],
            let jsonString = args["data"] as? String
          else {
            result(FlutterError(
              code: "INVALID_ARGS",
              message: "Randevu verisi eksik veya hatalı format",
              details: nil
            ))
            return
          }
          WatchConnectivityManager.shared.sendAppointments(jsonString: jsonString)
          result(nil)

        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
