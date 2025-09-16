import Foundation
import SwiftUI

// MARK: - Daily Rewards Manager
final class DailyRewardsManager: ObservableObject {
    static let shared = DailyRewardsManager()

    @Published var canClaimReward = false
    @Published var currentStreak = 0
    @Published var nextRewardTime: Date?
    @Published var todaysReward: DailyReward?

    private let userDefaults = UserDefaults.standard
    private var timer: Timer?

    // Reward configuration
    private let rewards: [DailyReward] = [
        DailyReward(day: 1, sparks: 10, hints: 1, description: "Welcome Back!"),
        DailyReward(day: 2, sparks: 15, hints: 1, description: "2 Day Streak!"),
        DailyReward(day: 3, sparks: 20, hints: 2, description: "3 Days Strong!"),
        DailyReward(day: 4, sparks: 25, hints: 2, description: "Dedicated Player!"),
        DailyReward(day: 5, sparks: 30, hints: 3, description: "5 Day Milestone!"),
        DailyReward(day: 6, sparks: 40, hints: 3, description: "Almost a Week!"),
        DailyReward(day: 7, sparks: 50, hints: 5, description: "Week Champion!", special: .removeAdsDay),
        DailyReward(day: 8, sparks: 20, hints: 2, description: "New Week!"),
        DailyReward(day: 9, sparks: 25, hints: 2, description: "Keep Going!"),
        DailyReward(day: 10, sparks: 30, hints: 3, description: "Double Digits!"),
        DailyReward(day: 11, sparks: 35, hints: 3, description: "11 Days!"),
        DailyReward(day: 12, sparks: 40, hints: 4, description: "Persistent!"),
        DailyReward(day: 13, sparks: 45, hints: 4, description: "Lucky 13!"),
        DailyReward(day: 14, sparks: 75, hints: 7, description: "Two Weeks!", special: .premiumLevelUnlock),
        DailyReward(day: 15, sparks: 35, hints: 3, description: "Half Month!"),
        DailyReward(day: 20, sparks: 50, hints: 5, description: "20 Days!"),
        DailyReward(day: 25, sparks: 60, hints: 6, description: "Almost a Month!"),
        DailyReward(day: 30, sparks: 100, hints: 10, description: "Monthly Master!", special: .exclusiveSkin),
    ]

    private init() {
        loadState()
        startTimer()
    }

    // MARK: - State Management
    private func loadState() {
        currentStreak = userDefaults.integer(forKey: "dailyRewardStreak")
        if let lastClaim = userDefaults.object(forKey: "lastDailyRewardClaim") as? Date {
            updateCanClaim(from: lastClaim)
        } else {
            canClaimReward = true
        }
        updateTodaysReward()
    }

    private func updateCanClaim(from lastClaim: Date) {
        let calendar = Calendar.current
        let now = Date()

        // Check if it's a new day
        if !calendar.isDate(lastClaim, inSameDayAs: now) {
            // Check if streak is broken (more than 1 day gap)
            let daysSince = calendar.dateComponents([.day], from: lastClaim, to: now).day ?? 0

            if daysSince > 1 {
                // Streak broken
                currentStreak = 0
                userDefaults.set(0, forKey: "dailyRewardStreak")
            }

            canClaimReward = true
            nextRewardTime = nil
        } else {
            // Already claimed today
            canClaimReward = false

            // Calculate next reward time (midnight)
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
               let midnight = calendar.dateComponents([.year, .month, .day], from: tomorrow).date {
                nextRewardTime = midnight
            }
        }
    }

    private func updateTodaysReward() {
        let rewardDay = min(currentStreak + 1, 30)
        todaysReward = rewards.first { $0.day == rewardDay } ?? rewards[0]
    }

    // MARK: - Claim Reward
    func claimDailyReward(completion: @escaping (DailyReward) -> Void) {
        guard canClaimReward, let reward = todaysReward else { return }

        // Update streak
        currentStreak += 1
        userDefaults.set(currentStreak, forKey: "dailyRewardStreak")

        // Save claim time
        let now = Date()
        userDefaults.set(now, forKey: "lastDailyRewardClaim")

        // Award rewards
        StoreKitManager.shared.addSparks(reward.sparks)

        var profile = PlayerProfile.load()
        profile.hints += reward.hints
        profile.save()

        // Handle special rewards
        if let special = reward.special {
            handleSpecialReward(special)
        }

        // Update state
        canClaimReward = false
        updateCanClaim(from: now)
        updateTodaysReward()

        // Track event
        AnalyticsManager.shared.trackEvent(.dailyRewardClaimed, parameters: [
            "day": reward.day,
            "streak": currentStreak,
            "sparks": reward.sparks,
            "hints": reward.hints
        ])

        completion(reward)
    }

    private func handleSpecialReward(_ special: SpecialReward) {
        switch special {
        case .removeAdsDay:
            // Grant temporary ad removal
            userDefaults.set(Date().addingTimeInterval(86400), forKey: "tempAdRemoval")

        case .premiumLevelUnlock:
            // Unlock a premium level
            var profile = PlayerProfile.load()
            profile.levelsCompleted.insert(100) // Premium level ID
            profile.save()

        case .exclusiveSkin:
            // Unlock exclusive character skin
            userDefaults.set(true, forKey: "skin_golden")
        }
    }

    // MARK: - Timer
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkForNewDay()
        }
    }

    private func checkForNewDay() {
        if let lastClaim = userDefaults.object(forKey: "lastDailyRewardClaim") as? Date {
            updateCanClaim(from: lastClaim)
        }
    }

    // MARK: - Helpers
    func getStreakBonus() -> Int {
        // Bonus sparks for maintaining streak
        switch currentStreak {
        case 3...6: return 5
        case 7...13: return 10
        case 14...29: return 20
        case 30...: return 50
        default: return 0
        }
    }

    func getMissedDayMessage() -> String? {
        guard currentStreak == 0,
              let lastClaim = userDefaults.object(forKey: "lastDailyRewardClaim") as? Date else {
            return nil
        }

        let daysSince = Calendar.current.dateComponents([.day], from: lastClaim, to: Date()).day ?? 0
        if daysSince > 1 {
            return "You missed \(daysSince - 1) day(s). Your streak has been reset."
        }
        return nil
    }
}

// MARK: - Daily Reward Model
struct DailyReward {
    let day: Int
    let sparks: Int
    let hints: Int
    let description: String
    var special: SpecialReward?
}

enum SpecialReward {
    case removeAdsDay
    case premiumLevelUnlock
    case exclusiveSkin
}

// MARK: - Daily Rewards View
struct DailyRewardsView: View {
    @StateObject private var manager = DailyRewardsManager.shared
    @State private var showingClaim = false
    @State private var claimedReward: DailyReward?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                }
                .padding()

                // Title
                VStack(spacing: 8) {
                    Text("Daily Rewards")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    if manager.currentStreak > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(manager.currentStreak) Day Streak")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.orange)
                        }
                    }
                }

                // Calendar Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 15) {
                        ForEach(1...30, id: \.self) { day in
                            DayRewardCell(
                                day: day,
                                isCompleted: day <= manager.currentStreak,
                                isToday: day == manager.currentStreak + 1,
                                reward: DailyRewardsManager.shared.rewards.first { $0.day == day }
                            )
                        }
                    }
                    .padding()
                }

                // Claim Button
                if manager.canClaimReward {
                    Button(action: claimReward) {
                        HStack(spacing: 12) {
                            Image(systemName: "gift.fill")
                            Text("Claim Today's Reward")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 1.0, green: 0.8, blue: 0.4),
                                    Color(red: 1.0, green: 0.6, blue: 0.2)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.3), radius: 10)
                    }
                    .padding(.horizontal)
                } else if let nextTime = manager.nextRewardTime {
                    NextRewardTimer(nextRewardTime: nextTime)
                        .padding(.horizontal)
                }

                Spacer()
            }

            // Claim Animation Overlay
            if showingClaim, let reward = claimedReward {
                ClaimAnimationView(reward: reward) {
                    showingClaim = false
                }
            }
        }
    }

    private func claimReward() {
        manager.claimDailyReward { reward in
            claimedReward = reward
            showingClaim = true
            Haptics.win()
        }
    }
}

// MARK: - Day Reward Cell
struct DayRewardCell: View {
    let day: Int
    let isCompleted: Bool
    let isToday: Bool
    let reward: DailyReward?

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: isToday ? 2 : 1)
                    )

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                } else if isToday {
                    VStack(spacing: 2) {
                        Image(systemName: "gift")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))

                        if let reward = reward {
                            Text("\(reward.sparks)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("\(day)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))

                        if let reward = reward {
                            Text("\(reward.sparks)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }
                }

                // Special indicator
                if reward?.special != nil {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                        .position(x: 8, y: 8)
                }
            }
            .frame(height: 60)
        }
    }

    private var backgroundColor: Color {
        if isCompleted {
            return Color.green.opacity(0.2)
        } else if isToday {
            return Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.2)
        } else {
            return Color.white.opacity(0.05)
        }
    }

    private var borderColor: Color {
        if isToday {
            return Color(red: 1.0, green: 0.8, blue: 0.4)
        } else if isCompleted {
            return Color.green.opacity(0.5)
        } else {
            return Color.white.opacity(0.1)
        }
    }
}

// MARK: - Next Reward Timer
struct NextRewardTimer: View {
    let nextRewardTime: Date
    @State private var timeRemaining = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("Next Reward In")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))

            Text(timeRemaining)
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.white.opacity(0.1))
        .cornerRadius(28)
        .onAppear { startTimer() }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateTimeRemaining()
        }
        updateTimeRemaining()
    }

    private func updateTimeRemaining() {
        let remaining = nextRewardTime.timeIntervalSinceNow
        if remaining > 0 {
            let hours = Int(remaining) / 3600
            let minutes = Int(remaining) % 3600 / 60
            let seconds = Int(remaining) % 60
            timeRemaining = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            timeRemaining = "Ready!"
        }
    }
}

// MARK: - Claim Animation View
struct ClaimAnimationView: View {
    let reward: DailyReward
    let onComplete: () -> Void

    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))

                Text(reward.description)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 30) {
                    VStack {
                        Text("\(reward.sparks)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                        Text("Sparks")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    VStack {
                        Text("\(reward.hints)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))
                        Text("Hints")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onComplete()
                }
            }
        }
    }
}