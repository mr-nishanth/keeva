import Flutter
import LocalAuthentication
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var biometricGuardChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let channel = FlutterMethodChannel(
      name: "io.nishvanta.keeva/biometric_guard",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "bind":
        result(Self.currentEnrollmentState())
      case "check":
        let arguments = call.arguments as? [String: Any]
        let stored = arguments?["token"] as? String
        result(Self.enrollmentStatus(storedToken: stored))
      case "clear":
        // The enrollment token lives in the Flutter secure store, which Dart deletes.
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    biometricGuardChannel = channel
  }

  /// Base64 `evaluatedPolicyDomainState`. Nil when biometrics are unavailable
  /// or the platform does not expose a domain state. This is not a biometric sample.
  private static func currentEnrollmentState() -> String? {
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
      return nil
    }
    return context.evaluatedPolicyDomainState?.base64EncodedString()
  }

  private static func enrollmentStatus(storedToken: String?) -> String {
    guard let current = currentEnrollmentState() else {
      return "unavailable"
    }
    guard let storedToken, !storedToken.isEmpty else {
      return "unsupported"
    }
    return storedToken == current ? "unchanged" : "changed"
  }
}
