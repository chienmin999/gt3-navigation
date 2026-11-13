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
