import SwiftUI
import Combine

// MARK: - App State
@MainActor
final class AppState: ObservableObject {
    // Navigation
    @Published var currentScreen: AppScreen = .mainMenu
    @Published var selectedLevel: Int = 0
    @Published var isShowingSettings = false
    @Published var isShowingShop = false

    // Game State
    @Published var isPlaying = false
    @Published var isPaused = false
    @Published var currentLevelData: LevelData?

    // Player Data
    @Published var playerProfile: PlayerProfile

    // Managers (Dependency Injection)
    let gameManager: GameManager
    let storeKit: StoreKitManager
    let analytics: AnalyticsManager
    let ads: AdManager
    let achievements: AchievementManager
    let audio: AudioManager
    let haptics: HapticsManager

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Initialize player profile
        self.playerProfile = PlayerProfile.load()

        // Initialize managers
        self.gameManager = GameManager.shared
        self.storeKit = StoreKitManager.shared
        self.analytics = AnalyticsManager.shared
        self.ads = AdManager.shared
        self.achievements = AchievementManager.shared
        self.audio = AudioManager()
        self.haptics = HapticsManager()

        setupBindings()
        setupNotifications()
    }

    private func setupBindings() {
        // Observe game manager state changes
        gameManager.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Observe store kit changes
        storeKit.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBecameActive()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &cancellables)
    }

    // MARK: - Navigation
    func navigateTo(_ screen: AppScreen) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentScreen = screen
        }

        // Track navigation
        analytics.trackEvent(.gameStart, parameters: ["screen": screen.rawValue])
    }

    func startLevel(_ level: Int) {
        selectedLevel = level
        currentLevelData = LevelLoader.loadLevel(level)
        isPlaying = true
        isPaused = false
        currentScreen = .gameplay

        gameManager.startSession()
        analytics.trackLevelStart(level: level)
    }

    func pauseGame() {
        isPaused = true
        audio.pauseBackgroundMusic()
    }

    func resumeGame() {
        isPaused = false
        audio.resumeBackgroundMusic()
    }

    func endLevel(completed: Bool) {
        isPlaying = false

        if completed {
            playerProfile.completeLevel(selectedLevel)
            playerProfile.save()

            // Check for achievements
            checkAchievements()

            // Show interstitial ad if appropriate
            if ads.shouldShowInterstitialAfterLevel(selectedLevel) {
                ads.showInterstitial(placement: .levelComplete) { [weak self] in
                    self?.navigateTo(.levelSelect)
                }
            } else {
                navigateTo(.levelSelect)
            }
        } else {
            analytics.trackLevelFail(level: selectedLevel, reason: "player_quit")
            navigateTo(.levelSelect)
        }

        gameManager.endSession()
    }

    // MARK: - Player Actions
    func useHint() {
        guard playerProfile.hints > 0 || storeKit.hasHintPack else {
            // Offer to watch ad for hints
            ads.showRewardedAd(placement: .hintReward) { [weak self] earned in
                if earned {
                    self?.playerProfile.hints += 3
                    self?.playerProfile.save()
                    self?.provideHint()
                }
            }
            return
        }

        if !storeKit.hasHintPack {
            playerProfile.hints -= 1
            playerProfile.save()
        }

        provideHint()
        analytics.trackHintUsed(level: selectedLevel)
    }

    private func provideHint() {
        // Provide contextual hint based on current level state
        // This would be implemented based on actual game logic
        haptics.hint()
    }

    func skipLevel() {
        ads.showRewardedAd(placement: .skipLevel) { [weak self] earned in
            guard let self = self, earned else { return }

            self.playerProfile.completeLevel(self.selectedLevel, skipped: true)
            self.playerProfile.save()
            self.endLevel(completed: true)
        }
    }

    // MARK: - Achievements
    private func checkAchievements() {
        // Check various achievement conditions
        if playerProfile.levelsCompleted.count == 1 {
            achievements.unlock(.firstWin)
        }

        if playerProfile.currentStreak >= 10 {
            achievements.unlock(.perfectRun)
        }

        // Add more achievement checks
    }

    // MARK: - App Lifecycle
    private func handleAppBecameActive() {
        analytics.startSession()
        ads.checkAdAvailability()

        // Check for daily rewards
        if playerProfile.canClaimDailyReward() {
            playerProfile.claimDailyReward()
            // Show daily reward UI
        }
    }

    private func handleAppWillResignActive() {
        if isPlaying {
            pauseGame()
        }
        analytics.endSession()
        playerProfile.save()
    }
}

// MARK: - App Screens
enum AppScreen: String {
    case mainMenu = "main_menu"
    case levelSelect = "level_select"
    case gameplay = "gameplay"
    case settings = "settings"
    case shop = "shop"
    case achievements = "achievements"
}

// MARK: - Player Profile
struct PlayerProfile: Codable {
    var levelsCompleted: Set<Int> = []
    var levelStars: [Int: Int] = [:] // level: stars (1-3)
    var bestTimes: [Int: TimeInterval] = [:]
    var totalSparks: Int = 50
    var hints: Int = 5
    var currentStreak: Int = 0
    var lastPlayDate: Date?
    var totalPlayTime: TimeInterval = 0

    // Daily rewards
    var lastDailyRewardDate: Date?
    var consecutiveDays: Int = 0

    static func load() -> PlayerProfile {
        guard let data = UserDefaults.standard.data(forKey: "playerProfile"),
              let profile = try? JSONDecoder().decode(PlayerProfile.self, from: data) else {
            return PlayerProfile()
        }
        return profile
    }

    mutating func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "playerProfile")
        }
    }

    mutating func completeLevel(_ level: Int, skipped: Bool = false) {
        levelsCompleted.insert(level)
        if !skipped {
            currentStreak += 1
        } else {
            currentStreak = 0
        }
        lastPlayDate = Date()
    }

    func canClaimDailyReward() -> Bool {
        guard let lastClaim = lastDailyRewardDate else { return true }
        return !Calendar.current.isDateInToday(lastClaim)
    }

    mutating func claimDailyReward() {
        lastDailyRewardDate = Date()
        consecutiveDays += 1

        // Award sparks based on consecutive days
        let reward = min(consecutiveDays * 10, 100)
        totalSparks += reward
    }
}

// MARK: - Audio Manager
class AudioManager: ObservableObject {
    @Published var isMusicEnabled = true
    @Published var isSoundEnabled = true

    func playBackgroundMusic() {
        guard isMusicEnabled else { return }
        // Implement background music
    }

    func pauseBackgroundMusic() {
        // Pause implementation
    }

    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        // Resume implementation
    }

    func playSound(_ sound: GameSound) {
        guard isSoundEnabled else { return }
        // Play sound effect
    }
}

enum GameSound {
    case tap, swipe, levelComplete, powerUp, fail
}

// MARK: - Haptics Manager
class HapticsManager {
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    func hint() {
        selection()
    }
}

// MARK: - Level Data
struct LevelData: Codable {
    let id: Int
    let name: String
    let difficulty: Difficulty
    let targetTime: TimeInterval
    let objectives: [String]
    // Add more level configuration

    enum Difficulty: String, Codable {
        case easy, medium, hard, expert
    }
}

// MARK: - Level Loader
enum LevelLoader {
    static func loadLevel(_ id: Int) -> LevelData? {
        // Load level data from JSON
        guard let url = Bundle.main.url(forResource: "Level\(String(format: "%02d", id))", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let level = try? JSONDecoder().decode(LevelData.self, from: data) else {
            return nil
        }
        return level
    }
}