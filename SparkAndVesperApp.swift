import SwiftUI
import Foundation
// Uncomment when GoogleService-Info.plist is added:
// import Firebase

@main
struct SparkAndVesperApp: App {
    // Firebase initialization
    init() {
        // Uncomment when GoogleService-Info.plist is added:
        // FirebaseApp.configure()

        // Initialize AdMob when Services folder is added to Xcode project:
        // setupAdMob()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
    }

    // Uncomment when Services folder is added to Xcode project:
    /*
    private func setupAdMob() {
        // Initialize AdMob (works even without Firebase)
        DispatchQueue.main.async {
            _ = AdMobManager.shared
        }
    }
    */
}