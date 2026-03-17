import Flutter
import UIKit
import StoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Use FlutterPluginRegistry API to avoid deprecation warning
    // This is the recommended way to register method channels
    let registrar = self.registrar(forPlugin: "TestFlightDetector")
    let testFlightChannel = FlutterMethodChannel(
      name: "com.ios.devalay/testflight",
      binaryMessenger: registrar!.messenger()
    )
    
    testFlightChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "isTestFlight" {
        // Check if app is running in TestFlight
        // TestFlight apps have a sandbox receipt
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
          let isTestFlight = appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
          result(isTestFlight)
        } else {
          // If no receipt URL, it's likely a development build
          result(false)
        }
      } else if call.method == "isInReviewEnvironment" {
        // Enhanced method that checks for review environments
        // This includes both TestFlight and potential App Store review scenarios
        var isReviewEnvironment = false
        
        // Check for TestFlight (sandbox receipt)
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
          isReviewEnvironment = appStoreReceiptURL.lastPathComponent == "sandboxReceipt"
        }
        
        // Note: App Store review builds are harder to detect reliably
        // They typically have production receipts, but we can't distinguish
        // between a review build and a regular production build
        // The Flutter side will handle this by making dialogs dismissible
        
        result(isReviewEnvironment)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
