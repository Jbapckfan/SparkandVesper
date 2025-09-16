import Foundation
import UIKit

// MARK: - Analytics Events
enum AnalyticsEvent: String {
    // Core Game Events
    case gameStart = "game_start"
    case levelStart = "level_start"
    case levelComplete = "level_complete"
    case levelFail = "level_fail"
    case levelRestart = "level_restart"
    case gameEnd = "game_end"

    // Player Actions
    case hintUsed = "hint_used"
    case levelSkipped = "level_skipped"
    case achievementUnlocked = "achievement_unlocked"

    // Monetization
    case adShown = "ad_shown"
    case adClicked = "ad_clicked"
    case adRewarded = "ad_rewarded"
    case purchaseInitiated = "purchase_initiated"
    case purchaseCompleted = "purchase_completed"
    case purchaseFailed = "purchase_failed"

    // Retention
    case dailyRewardClaimed = "daily_reward_claimed"
    case sessionStart = "session_start"
    case sessionEnd = "session_end"

    // Tutorial
    case tutorialStart = "tutorial_start"
    case tutorialStep = "tutorial_step"
    case tutorialComplete = "tutorial_complete"
    case tutorialSkipped = "tutorial_skipped"
}

// MARK: - Analytics Manager
final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private var sessionStartTime: Date?
    private var currentLevel: Int = 0
    private var levelStartTime: Date?
    private let userDefaults = UserDefaults.standard

    // Player metrics
    private(set) var totalPlayTime: TimeInterval = 0
    private(set) var totalLevelsCompleted: Int = 0
    private(set) var totalHintsUsed: Int = 0
    private(set) var totalDeaths: Int = 0

    private init() {
        loadMetrics()
        startSession()
    }

    // MARK: - Session Management
    func startSession() {
        sessionStartTime = Date()
        trackEvent(.sessionStart)
        incrementRetentionDay()
    }

    func endSession() {
        guard let startTime = sessionStartTime else { return }
        let sessionDuration = Date().timeIntervalSince(startTime)
        totalPlayTime += sessionDuration

        trackEvent(.sessionEnd, parameters: [
            "duration": Int(sessionDuration),
            "levels_played": currentLevel
        ])

        saveMetrics()
        sessionStartTime = nil
    }

    // MARK: - Level Tracking
    func trackLevelStart(level: Int) {
        currentLevel = level
        levelStartTime = Date()

        trackEvent(.levelStart, parameters: [
            "level_id": level,
            "attempt_number": getLevelAttempts(level) + 1
        ])

        incrementLevelAttempts(level)
    }

    func trackLevelComplete(level: Int, time: TimeInterval, stars: Int = 0) {
        totalLevelsCompleted += 1

        trackEvent(.levelComplete, parameters: [
            "level_id": level,
            "completion_time": Int(time),
            "stars_earned": stars,
            "attempts": getLevelAttempts(level),
            "hints_used": getLevelHints(level)
        ])

        // Update best time
        updateBestTime(level: level, time: time)

        // Calculate and track progression metrics
        trackProgressionMetrics(level: level)
    }

    func trackLevelFail(level: Int, reason: String = "unknown") {
        totalDeaths += 1

        guard let startTime = levelStartTime else { return }
        let playTime = Date().timeIntervalSince(startTime)

        trackEvent(.levelFail, parameters: [
            "level_id": level,
            "fail_reason": reason,
            "play_time": Int(playTime),
            "attempt_number": getLevelAttempts(level)
        ])
    }

    // MARK: - Monetization Tracking
    func trackPurchase(productID: String, price: Double, currency: String = "USD") {
        trackEvent(.purchaseCompleted, parameters: [
            "product_id": productID,
            "price": price,
            "currency": currency,
            "lifetime_value": calculateLifetimeValue()
        ])

        incrementLifetimeValue(price)
    }

    func trackAdImpression(adType: String, placement: String) {
        trackEvent(.adShown, parameters: [
            "ad_type": adType,
            "placement": placement,
            "session_ads": getSessionAdCount() + 1
        ])

        incrementSessionAdCount()
    }

    func trackRewardedAdComplete(reward: String, amount: Int) {
        trackEvent(.adRewarded, parameters: [
            "reward_type": reward,
            "reward_amount": amount
        ])
    }

    // MARK: - Player Actions
    func trackHintUsed(level: Int, hintType: String = "generic") {
        totalHintsUsed += 1
        incrementLevelHints(level)

        trackEvent(.hintUsed, parameters: [
            "level_id": level,
            "hint_type": hintType,
            "total_hints": totalHintsUsed
        ])
    }

    func trackAchievementUnlocked(_ achievement: String) {
        trackEvent(.achievementUnlocked, parameters: [
            "achievement_id": achievement,
            "total_achievements": getTotalAchievements()
        ])
    }

    // MARK: - Tutorial Tracking
    func trackTutorialProgress(step: Int, action: String) {
        trackEvent(.tutorialStep, parameters: [
            "step_number": step,
            "action": action
        ])
    }

    func trackTutorialComplete(duration: TimeInterval) {
        trackEvent(.tutorialComplete, parameters: [
            "duration": Int(duration),
            "hints_used": totalHintsUsed
        ])
    }

    // MARK: - Retention Metrics
    private func incrementRetentionDay() {
        let lastPlayDate = userDefaults.object(forKey: "lastPlayDate") as? Date ?? Date()
        let daysSinceLastPlay = Calendar.current.dateComponents([.day], from: lastPlayDate, to: Date()).day ?? 0

        if daysSinceLastPlay >= 1 {
            let consecutiveDays = userDefaults.integer(forKey: "consecutiveDays")
            if daysSinceLastPlay == 1 {
                userDefaults.set(consecutiveDays + 1, forKey: "consecutiveDays")
            } else {
                userDefaults.set(1, forKey: "consecutiveDays")
            }
        }

        userDefaults.set(Date(), forKey: "lastPlayDate")

        // Track retention cohorts
        trackRetentionCohort()
    }

    private func trackRetentionCohort() {
        let installDate = userDefaults.object(forKey: "installDate") as? Date ?? Date()
        let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0

        // Track D1, D7, D30 retention
        if [1, 7, 30].contains(daysSinceInstall) {
            trackEvent(.sessionStart, parameters: [
                "retention_day": "D\(daysSinceInstall)",
                "cohort": dateFormatter.string(from: installDate)
            ])
        }
    }

    // MARK: - Core Tracking
    private func trackEvent(_ event: AnalyticsEvent, parameters: [String: Any]? = nil) {
        var params = parameters ?? [:]

        // Add common parameters
        params["platform"] = "iOS"
        params["os_version"] = UIDevice.current.systemVersion
        params["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        params["device_model"] = UIDevice.current.model
        params["timestamp"] = ISO8601DateFormatter().string(from: Date())

        // Log locally for debugging
        #if DEBUG
        print("📊 Analytics: \(event.rawValue)")
        if let parameters = parameters {
            print("   Parameters: \(parameters)")
        }
        #endif

        // TODO: Send to actual analytics service (Firebase, Amplitude, etc.)
        // For now, store locally for later batch upload
        storeEventLocally(event: event.rawValue, parameters: params)
    }

    private func storeEventLocally(event: String, parameters: [String: Any]) {
        var events = userDefaults.array(forKey: "pendingAnalyticsEvents") as? [[String: Any]] ?? []

        let eventData: [String: Any] = [
            "event": event,
            "parameters": parameters,
            "timestamp": Date().timeIntervalSince1970
        ]

        events.append(eventData)

        // Keep only last 1000 events to prevent storage bloat
        if events.count > 1000 {
            events = Array(events.suffix(1000))
        }

        userDefaults.set(events, forKey: "pendingAnalyticsEvents")
    }

    // MARK: - Helper Methods
    private func getLevelAttempts(_ level: Int) -> Int {
        userDefaults.integer(forKey: "level_\(level)_attempts")
    }

    private func incrementLevelAttempts(_ level: Int) {
        let current = getLevelAttempts(level)
        userDefaults.set(current + 1, forKey: "level_\(level)_attempts")
    }

    private func getLevelHints(_ level: Int) -> Int {
        userDefaults.integer(forKey: "level_\(level)_hints")
    }

    private func incrementLevelHints(_ level: Int) {
        let current = getLevelHints(level)
        userDefaults.set(current + 1, forKey: "level_\(level)_hints")
    }

    private func updateBestTime(level: Int, time: TimeInterval) {
        let key = "level_\(level)_best_time"
        let currentBest = userDefaults.double(forKey: key)
        if currentBest == 0 || time < currentBest {
            userDefaults.set(time, forKey: key)
        }
    }

    private func calculateLifetimeValue() -> Double {
        userDefaults.double(forKey: "lifetime_value")
    }

    private func incrementLifetimeValue(_ amount: Double) {
        let current = calculateLifetimeValue()
        userDefaults.set(current + amount, forKey: "lifetime_value")
    }

    private func getSessionAdCount() -> Int {
        userDefaults.integer(forKey: "session_ad_count")
    }

    private func incrementSessionAdCount() {
        let current = getSessionAdCount()
        userDefaults.set(current + 1, forKey: "session_ad_count")
    }

    private func getTotalAchievements() -> Int {
        userDefaults.integer(forKey: "total_achievements")
    }

    private func trackProgressionMetrics(level: Int) {
        // Calculate progression rate
        let totalLevels = 50 // Assuming 50 levels total
        let progressionRate = Double(level) / Double(totalLevels)

        // Track funnel metrics
        if [1, 5, 10, 20, 30, 40, 50].contains(level) {
            trackEvent(.levelComplete, parameters: [
                "milestone": "level_\(level)",
                "progression_rate": progressionRate,
                "total_play_time": Int(totalPlayTime)
            ])
        }
    }

    // MARK: - Persistence
    private func loadMetrics() {
        totalPlayTime = userDefaults.double(forKey: "total_play_time")
        totalLevelsCompleted = userDefaults.integer(forKey: "total_levels_completed")
        totalHintsUsed = userDefaults.integer(forKey: "total_hints_used")
        totalDeaths = userDefaults.integer(forKey: "total_deaths")

        // Set install date if first launch
        if userDefaults.object(forKey: "installDate") == nil {
            userDefaults.set(Date(), forKey: "installDate")
        }
    }

    private func saveMetrics() {
        userDefaults.set(totalPlayTime, forKey: "total_play_time")
        userDefaults.set(totalLevelsCompleted, forKey: "total_levels_completed")
        userDefaults.set(totalHintsUsed, forKey: "total_hints_used")
        userDefaults.set(totalDeaths, forKey: "total_deaths")
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}