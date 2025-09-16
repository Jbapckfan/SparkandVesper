import Foundation
import UIKit
// Uncomment after running `pod install`:
// import GoogleMobileAds

// MARK: - AdMob Configuration
struct AdMobConfig {
    // IMPORTANT: Replace with your actual AdMob IDs before release
    #if DEBUG
    // Test ad unit IDs (always show test ads in debug)
    static let appID = "ca-app-pub-3940256099942544~1458002511"  // Test App ID
    static let bannerID = "ca-app-pub-3940256099942544/2934735716"  // Test Banner
    static let interstitialID = "ca-app-pub-3940256099942544/4411468910"  // Test Interstitial
    static let rewardedID = "ca-app-pub-3940256099942544/1712485313"  // Test Rewarded
    static let rewardedInterstitialID = "ca-app-pub-3940256099942544/6978759866"  // Test Rewarded Interstitial
    #else
    // Production ad unit IDs - REPLACE THESE WITH YOUR ACTUAL IDS
    static let appID = "ca-app-pub-XXXXXXXXXXXXX~XXXXXXXXXX"  // Your App ID
    static let bannerID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"  // Your Banner ID
    static let interstitialID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"  // Your Interstitial ID
    static let rewardedID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"  // Your Rewarded ID
    static let rewardedInterstitialID = "ca-app-pub-XXXXXXXXXXXXX/XXXXXXXXXX"  // Your Rewarded Interstitial ID
    #endif
}

// MARK: - Real AdMob Manager
final class AdMobManager: NSObject, ObservableObject {
    static let shared = AdMobManager()

    @Published private(set) var isBannerReady = false
    @Published private(set) var isInterstitialReady = false
    @Published private(set) var isRewardedAdReady = false
    @Published private(set) var isShowingAd = false

    // Uncomment after pod install:
    /*
    private var bannerView: GADBannerView?
    private var interstitial: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    */

    // Ad frequency control
    private var lastInterstitialTime: Date?
    private let interstitialCooldown: TimeInterval = 180 // 3 minutes
    private var levelsCompletedSinceAd = 0
    private let levelsPerInterstitial = 3

    // Reward completion handlers
    private var rewardedAdCompletion: ((Bool) -> Void)?

    private override init() {
        super.init()
        initializeAdMob()
    }

    // MARK: - Initialization
    private func initializeAdMob() {
        // Uncomment after pod install:
        /*
        GADMobileAds.sharedInstance().start { [weak self] status in
            print("📱 AdMob SDK initialized")

            // Configure settings
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [
                GADSimulatorID // Always show test ads in simulator
                // Add your test device IDs here:
                // "YOUR_TEST_DEVICE_ID"
            ]

            // Start loading ads
            self?.loadBannerAd()
            self?.loadInterstitialAd()
            self?.loadRewardedAd()
        }
        */

        // For now, simulate initialization
        #if DEBUG
        print("📱 AdMob: Initialized (Simulation Mode)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isBannerReady = true
            self?.isInterstitialReady = true
            self?.isRewardedAdReady = true
        }
        #endif
    }

    // MARK: - Banner Ads
    func createBannerView(in viewController: UIViewController) -> UIView {
        // Uncomment after pod install:
        /*
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = AdMobConfig.bannerID
        bannerView.rootViewController = viewController
        bannerView.delegate = self

        self.bannerView = bannerView
        loadBannerAd()

        return bannerView
        */

        // Placeholder view for now
        let placeholderView = UIView()
        placeholderView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        placeholderView.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        return placeholderView
    }

    private func loadBannerAd() {
        // Uncomment after pod install:
        /*
        let request = GADRequest()
        bannerView?.load(request)
        */
    }

    // MARK: - Interstitial Ads
    private func loadInterstitialAd() {
        // Uncomment after pod install:
        /*
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdMobConfig.interstitialID,
                               request: request) { [weak self] ad, error in
            if let error = error {
                print("📱 AdMob: Failed to load interstitial: \(error.localizedDescription)")
                self?.isInterstitialReady = false
                // Retry after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self?.loadInterstitialAd()
                }
                return
            }

            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
            self?.isInterstitialReady = true
            print("📱 AdMob: Interstitial loaded")
        }
        */
    }

    func showInterstitial(from viewController: UIViewController, placement: AdPlacement, completion: (() -> Void)? = nil) {
        guard !StoreKitManager.shared.hasRemovedAds else {
            completion?()
            return
        }

        // Check frequency limits
        if let lastTime = lastInterstitialTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastTime)
            if timeSinceLastAd < interstitialCooldown {
                completion?()
                return
            }
        }

        if placement == .levelComplete {
            levelsCompletedSinceAd += 1
            if levelsCompletedSinceAd < levelsPerInterstitial {
                completion?()
                return
            }
            levelsCompletedSinceAd = 0
        }

        // Uncomment after pod install:
        /*
        guard let interstitial = interstitial else {
            completion?()
            loadInterstitialAd() // Reload for next time
            return
        }

        isShowingAd = true
        lastInterstitialTime = Date()

        interstitial.present(fromRootViewController: viewController)
        self.interstitialCompletion = completion
        */

        // Simulation for now
        #if DEBUG
        print("📱 AdMob: Showing interstitial for \(placement.rawValue)")
        isShowingAd = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isShowingAd = false
            self?.lastInterstitialTime = Date()
            completion?()
        }
        #endif

        AnalyticsManager.shared.trackAdImpression(adType: "interstitial", placement: placement.rawValue)
    }

    // MARK: - Rewarded Ads
    private func loadRewardedAd() {
        // Uncomment after pod install:
        /*
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: AdMobConfig.rewardedID,
                           request: request) { [weak self] ad, error in
            if let error = error {
                print("📱 AdMob: Failed to load rewarded ad: \(error.localizedDescription)")
                self?.isRewardedAdReady = false
                // Retry after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    self?.loadRewardedAd()
                }
                return
            }

            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenPresentingAd = self
            self?.isRewardedAdReady = true
            print("📱 AdMob: Rewarded ad loaded")
        }
        */
    }

    func showRewardedAd(from viewController: UIViewController, placement: AdPlacement, completion: @escaping (Bool) -> Void) {
        // Uncomment after pod install:
        /*
        guard let rewardedAd = rewardedAd else {
            completion(false)
            loadRewardedAd() // Reload for next time
            return
        }

        isShowingAd = true
        rewardedAdCompletion = completion

        rewardedAd.present(fromRootViewController: viewController) { [weak self] in
            // User earned reward
            let reward = rewardedAd.adReward
            print("📱 AdMob: User earned reward: \(reward.amount) \(reward.type)")

            AnalyticsManager.shared.trackRewardedAdComplete(
                reward: placement.rawValue,
                amount: Int(truncating: reward.amount)
            )

            self?.rewardedAdCompletion?(true)
            self?.loadRewardedAd() // Load next ad
        }
        */

        // Simulation for now
        #if DEBUG
        print("📱 AdMob: Showing rewarded ad for \(placement.rawValue)")
        isShowingAd = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowingAd = false
            let earnedReward = Bool.random() || true // Simulate 100% completion for testing
            if earnedReward {
                AnalyticsManager.shared.trackRewardedAdComplete(
                    reward: placement.rawValue,
                    amount: self?.getRewardAmount(for: placement) ?? 1
                )
            }
            completion(earnedReward)
        }
        #endif

        AnalyticsManager.shared.trackAdImpression(adType: "rewarded", placement: placement.rawValue)
    }

    // MARK: - Helper Methods
    private func getRewardAmount(for placement: AdPlacement) -> Int {
        switch placement {
        case .hintReward:
            return 3
        case .skipLevel:
            return 1
        case .extraLife:
            return 1
        default:
            return 10
        }
    }

    func preloadAds() {
        // Uncomment after pod install:
        /*
        if interstitial == nil {
            loadInterstitialAd()
        }
        if rewardedAd == nil {
            loadRewardedAd()
        }
        */
    }
}

// MARK: - AdMob Delegates
// Uncomment after pod install:
/*
extension AdMobManager: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("📱 AdMob: Banner loaded")
        isBannerReady = true
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("📱 AdMob: Banner failed to load: \(error.localizedDescription)")
        isBannerReady = false
        // Retry after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
            self?.loadBannerAd()
        }
    }

    func bannerViewDidRecordClick(_ bannerView: GADBannerView) {
        AnalyticsManager.shared.trackEvent(.adClicked, parameters: ["ad_type": "banner"])
    }
}

extension AdMobManager: GADFullScreenContentDelegate {
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📱 AdMob: Ad will present")
        isShowingAd = true
    }

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("📱 AdMob: Ad dismissed")
        isShowingAd = false

        // Handle completion
        if ad === interstitial {
            interstitialCompletion?()
            interstitialCompletion = nil
            interstitial = nil
            loadInterstitialAd() // Load next ad
        }
    }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("📱 AdMob: Failed to present ad: \(error.localizedDescription)")
        isShowingAd = false

        // Handle failure
        if ad === interstitial {
            interstitialCompletion?()
            interstitialCompletion = nil
            loadInterstitialAd()
        } else if ad === rewardedAd {
            rewardedAdCompletion?(false)
            rewardedAdCompletion = nil
            loadRewardedAd()
        }
    }

    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        let adType = (ad === interstitial) ? "interstitial" : "rewarded"
        AnalyticsManager.shared.trackEvent(.adClicked, parameters: ["ad_type": adType])
    }

    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        // Impression tracking is handled when showing the ad
    }
}
*/

// MARK: - SwiftUI Integration
import SwiftUI

struct BannerAdView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        // Add banner to view
        let bannerView = AdMobManager.shared.createBannerView(in: viewController)
        viewController.view.addSubview(bannerView)

        // Center banner at bottom
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bannerView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor),
            bannerView.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update if needed
    }
}

// MARK: - Setup Instructions
/*
 AdMob Integration Steps:

 1. Run `pod install` in terminal from project directory
 2. Open Spark&Vesper.xcworkspace (not .xcodeproj)
 3. Add to Info.plist:
    <key>GADApplicationIdentifier</key>
    <string>YOUR_ADMOB_APP_ID</string>

    <key>SKAdNetworkItems</key>
    <array>
        <dict>
            <key>SKAdNetworkIdentifier</key>
            <string>cstr6suwn9.skadnetwork</string>
        </dict>
        <!-- Add more SKAdNetwork identifiers as needed -->
    </array>

 4. Replace test ad unit IDs with production IDs in AdMobConfig
 5. Add test device IDs for development
 6. Uncomment the GoogleMobileAds import and implementation code

 Revenue Optimization Tips:
 - Show interstitials every 3-4 levels
 - Place banner ads in menus, not gameplay
 - Use rewarded ads for hints and skips
 - Implement mediation for higher fill rates
 - A/B test ad frequency for optimal revenue
 */