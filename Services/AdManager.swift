import Foundation
import UIKit

// MARK: - Ad Types
enum AdType {
    case banner
    case interstitial
    case rewarded
    case rewardedInterstitial
}

// MARK: - Ad Placement
enum AdPlacement: String {
    case mainMenu = "main_menu"
    case levelComplete = "level_complete"
    case levelFailed = "level_failed"
    case pauseMenu = "pause_menu"
    case shopScreen = "shop_screen"
    case hintReward = "hint_reward"
    case skipLevel = "skip_level"
    case extraLife = "extra_life"
}

// MARK: - Ad Manager
final class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    @Published private(set) var isBannerReady = false
    @Published private(set) var isInterstitialReady = false
    @Published private(set) var isRewardedAdReady = false
    @Published private(set) var isShowingAd = false

    // Ad frequency control
    private var lastInterstitialTime: Date?
    private let interstitialCooldown: TimeInterval = 180 // 3 minutes between interstitials
    private var levelsCompletedSinceAd = 0
    private let levelsPerInterstitial = 3

    // Test mode flag
    private let isTestMode = true // Set to false for production

    private override init() {
        super.init()
        setupAds()
    }

    // MARK: - Setup
    private func setupAds() {
        // Initialize ad SDK here (AdMob, Unity Ads, etc.)
        // For now, we'll simulate ad availability

        #if DEBUG
        print("📱 AdManager: Initialized in test mode")
        #endif

        // Simulate ad loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isBannerReady = true
            self?.isInterstitialReady = true
            self?.isRewardedAdReady = true
        }
    }

    // MARK: - Banner Ads
    func showBanner(in viewController: UIViewController) {
        guard !StoreKitManager.shared.hasRemovedAds else { return }
        guard isBannerReady else { return }

        AnalyticsManager.shared.trackAdImpression(adType: "banner", placement: AdPlacement.mainMenu.rawValue)

        // Create and show banner view
        // In production, integrate with actual ad SDK
        #if DEBUG
        print("📱 AdManager: Showing banner ad")
        #endif
    }

    func hideBanner() {
        // Hide banner implementation
        #if DEBUG
        print("📱 AdManager: Hiding banner ad")
        #endif
    }

    // MARK: - Interstitial Ads
    func showInterstitial(placement: AdPlacement, completion: (() -> Void)? = nil) {
        guard !StoreKitManager.shared.hasRemovedAds else {
            completion?()
            return
        }

        // Check cooldown
        if let lastTime = lastInterstitialTime {
            let timeSinceLastAd = Date().timeIntervalSince(lastTime)
            if timeSinceLastAd < interstitialCooldown {
                completion?()
                return
            }
        }

        // Check level frequency
        if placement == .levelComplete {
            levelsCompletedSinceAd += 1
            if levelsCompletedSinceAd < levelsPerInterstitial {
                completion?()
                return
            }
            levelsCompletedSinceAd = 0
        }

        guard isInterstitialReady else {
            completion?()
            return
        }

        isShowingAd = true
        lastInterstitialTime = Date()

        AnalyticsManager.shared.trackAdImpression(adType: "interstitial", placement: placement.rawValue)

        // Simulate ad display
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isShowingAd = false
            self?.isInterstitialReady = false

            // Reload ad for next time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self?.isInterstitialReady = true
            }

            completion?()
        }

        #if DEBUG
        print("📱 AdManager: Showing interstitial ad for \(placement.rawValue)")
        #endif
    }

    // MARK: - Rewarded Ads
    func showRewardedAd(placement: AdPlacement, completion: @escaping (Bool) -> Void) {
        guard isRewardedAdReady else {
            completion(false)
            return
        }

        isShowingAd = true

        AnalyticsManager.shared.trackAdImpression(adType: "rewarded", placement: placement.rawValue)

        // Simulate ad display and reward
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.isShowingAd = false
            self?.isRewardedAdReady = false

            // User watched full ad, give reward
            let didEarnReward = true // In production, this comes from ad SDK callback

            if didEarnReward {
                AnalyticsManager.shared.trackRewardedAdComplete(
                    reward: placement.rawValue,
                    amount: self?.getRewardAmount(for: placement) ?? 1
                )
            }

            // Reload ad for next time
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self?.isRewardedAdReady = true
            }

            completion(didEarnReward)
        }

        #if DEBUG
        print("📱 AdManager: Showing rewarded ad for \(placement.rawValue)")
        #endif
    }

    // MARK: - Reward Configuration
    private func getRewardAmount(for placement: AdPlacement) -> Int {
        switch placement {
        case .hintReward:
            return 3 // 3 hints
        case .skipLevel:
            return 1 // Skip 1 level
        case .extraLife:
            return 1 // 1 extra life/continue
        default:
            return 10 // 10 sparks as default
        }
    }

    // MARK: - Ad Availability
    func checkAdAvailability() {
        // Check and update ad availability
        // In production, query ad SDK for actual availability

        if !isInterstitialReady {
            // Try to load interstitial
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.isInterstitialReady = true
            }
        }

        if !isRewardedAdReady {
            // Try to load rewarded ad
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.isRewardedAdReady = true
            }
        }
    }

    // MARK: - Smart Ad Display Logic
    func shouldShowInterstitialAfterLevel(_ level: Int) -> Bool {
        guard !StoreKitManager.shared.hasRemovedAds else { return false }

        // Don't show ads in early levels to avoid frustrating new players
        if level < 3 { return false }

        // Show ad every 3 levels after level 3
        if (level - 3) % levelsPerInterstitial == 0 {
            return isInterstitialReady
        }

        return false
    }

    // MARK: - Revenue Tracking
    func trackAdRevenue(value: Double, currency: String = "USD", adNetwork: String = "unknown") {
        // Track ad revenue for LTV calculations
        let currentRevenue = UserDefaults.standard.double(forKey: "ad_revenue_total")
        UserDefaults.standard.set(currentRevenue + value, forKey: "ad_revenue_total")

        #if DEBUG
        print("💰 Ad Revenue: \(value) \(currency) from \(adNetwork)")
        #endif
    }
}