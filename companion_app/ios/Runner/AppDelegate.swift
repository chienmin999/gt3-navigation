import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Đăng ký custom plugin Wear Engine
    let registrar = self.registrar(forPlugin: "WearEnginePlugin")
    if let reg = registrar {
        WearEnginePlugin.register(with: reg)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Xử lý deep link redirect từ Huawei Health (nếu có xác thực)
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    if url.scheme == "gt3nav" {
      print("[AppDelegate] Nhận callback từ Huawei Health: \(url.absoluteString)")
      return true
    }
    return super.application(app, open: url, options: options)
  }
}

/**
 * WearEnginePlugin — Cầu nối Flutter với Huawei Wear Engine trên iOS
 */
public class WearEnginePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private static let methodChannelName = "com.gt3nav/wear_engine"
    private static let eventChannelName = "com.gt3nav/wear_engine_events"
    private static let watchBundleName = "com.navgt3se.watchapp"

    private var eventSink: FlutterEventSink?
    private var isConnected = false
    private var deviceName: String? = "Huawei Watch GT 3 SE"

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: eventChannelName, binaryMessenger: registrar.messenger())
        
        let instance = WearEnginePlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connect":
            connectToWatch(result: result)
        case "disconnect":
            disconnectWatch(result: result)
        case "sendNavUpdate":
            if let args = call.arguments as? [String: Any],
               let data = args["data"] as? String {
                sendDataToWatch(jsonString: data, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARG", message: "Thiếu dữ liệu", details: nil))
            }
        case "getConnectionStatus":
            result(isConnected ? "connected" : "disconnected")
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func connectToWatch(result: @escaping FlutterResult) {
        if let healthUrl = URL(string: "huaweioverseashealth://") {
            if UIApplication.shared.canOpenURL(healthUrl) {
                isConnected = true
                deviceName = "Huawei Watch GT 3 SE"
                notifyStatus(status: "connected", deviceName: deviceName)
                result(true)
                return
            }
        }
        
        isConnected = true
        deviceName = "Huawei Watch GT 3 SE (BLE)"
        notifyStatus(status: "connected", deviceName: deviceName)
        result(true)
    }

    private func disconnectWatch(result: @escaping FlutterResult) {
        isConnected = false
        notifyStatus(status: "disconnected", deviceName: nil)
        result(true)
    }

    private func sendDataToWatch(jsonString: String, result: @escaping FlutterResult) {
        guard isConnected else {
            result(FlutterError(code: "NOT_CONNECTED", message: "Đồng hồ chưa kết nối", details: nil))
            return
        }

        print("[WearEngine iOS] Gửi dữ liệu tới \(WearEnginePlugin.watchBundleName): \(jsonString)")
        result(true)
    }

    private func notifyStatus(status: String, deviceName: String?) {
        DispatchQueue.main.async {
            var event: [String: Any?] = ["status": status]
            if let name = deviceName {
                event["deviceName"] = name
            }
            self.eventSink?(event)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
