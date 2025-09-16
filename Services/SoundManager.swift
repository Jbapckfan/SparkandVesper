import AVFoundation
import UIKit

// MARK: - Sound Types
enum SoundEffect: String, CaseIterable {
    // UI Sounds
    case buttonTap = "button_tap"
    case menuOpen = "menu_open"
    case menuClose = "menu_close"

    // Gameplay - Spark
    case sparkMove = "spark_move"
    case sparkCharge = "spark_charge"
    case sparkDischarge = "spark_discharge"
    case windmillActivate = "windmill_activate"
    case surgeBarrierOpen = "surge_barrier_open"
    case surgeBarrierDenied = "surge_barrier_denied"

    // Gameplay - Vesper
    case vesperMove = "vesper_move"
    case vesperFlow = "vesper_flow"
    case iceWallMelt = "ice_wall_melt"
    case iceWallRefreeze = "ice_wall_refreeze"
    case flowBarrierOpen = "flow_barrier_open"
    case flowBarrierDenied = "flow_barrier_denied"

    // Shared Mechanics
    case bridgeExtend = "bridge_extend"
    case bridgeRetract = "bridge_retract"
    case heatPlateActivate = "heat_plate_activate"
    case resonancePulse = "resonance_pulse"
    case proximityGlow = "proximity_glow"

    // Success/Failure
    case portalReached = "portal_reached"
    case levelComplete = "level_complete"
    case levelFailed = "level_failed"
    case achievementUnlocked = "achievement_unlocked"

    // Hazards
    case electricShock = "electric_shock"
    case voidPull = "void_pull"
    case hazardWarning = "hazard_warning"

    // Rewards
    case coinCollect = "coin_collect"
    case rewardClaimed = "reward_claimed"
    case powerUpActivate = "powerup_activate"
}

enum BackgroundMusic: String {
    case mainMenu = "music_menu"
    case gameplay = "music_gameplay"
    case tutorial = "music_tutorial"
    case boss = "music_boss"
    case victory = "music_victory"
}

// MARK: - Sound Manager
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: "musicEnabled")
            if isMusicEnabled {
                resumeBackgroundMusic()
            } else {
                pauseBackgroundMusic()
            }
        }
    }

    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "soundEnabled")
        }
    }

    @Published var musicVolume: Float = 0.5 {
        didSet {
            UserDefaults.standard.set(musicVolume, forKey: "musicVolume")
            backgroundMusicPlayer?.volume = musicVolume
        }
    }

    @Published var soundVolume: Float = 0.7 {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        }
    }

    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [AVAudioPlayer] = []
    private let maxConcurrentSounds = 10

    // Sound effect cache
    private var soundCache: [SoundEffect: Data] = [:]
    private var musicCache: [BackgroundMusic: Data] = [:]

    // Haptic feedback support
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        // Load saved preferences
        isMusicEnabled = UserDefaults.standard.bool(forKey: "musicEnabled") != false
        isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled") != false
        musicVolume = UserDefaults.standard.float(forKey: "musicVolume") != 0 ? UserDefaults.standard.float(forKey: "musicVolume") : 0.5
        soundVolume = UserDefaults.standard.float(forKey: "soundVolume") != 0 ? UserDefaults.standard.float(forKey: "soundVolume") : 0.7

        setupAudioSession()
        preloadSounds()
    }

    // MARK: - Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("🔊 Failed to setup audio session: \(error)")
        }
    }

    private func preloadSounds() {
        // Preload frequently used sound effects
        let criticalSounds: [SoundEffect] = [
            .buttonTap, .sparkMove, .vesperMove,
            .levelComplete, .coinCollect
        ]

        for sound in criticalSounds {
            _ = loadSound(sound)
        }
    }

    // MARK: - Background Music
    func playBackgroundMusic(_ music: BackgroundMusic, fadeIn: Bool = true) {
        guard isMusicEnabled else { return }

        // Stop current music
        if fadeIn && backgroundMusicPlayer?.isPlaying == true {
            fadeOutAndStop { [weak self] in
                self?.startBackgroundMusic(music)
            }
        } else {
            startBackgroundMusic(music)
        }
    }

    private func startBackgroundMusic(_ music: BackgroundMusic) {
        // For now, use placeholder names. In production, add actual audio files
        let fileName = music.rawValue

        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("🔊 Music file not found: \(fileName)")
            createPlaceholderMusic(music)
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()

            // Fade in
            if backgroundMusicPlayer?.volume == 0 {
                fadeIn()
            }
        } catch {
            print("🔊 Failed to play background music: \(error)")
        }
    }

    func pauseBackgroundMusic() {
        backgroundMusicPlayer?.pause()
    }

    func resumeBackgroundMusic() {
        guard isMusicEnabled else { return }
        backgroundMusicPlayer?.play()
    }

    func stopBackgroundMusic(fadeOut: Bool = true) {
        if fadeOut {
            fadeOutAndStop()
        } else {
            backgroundMusicPlayer?.stop()
        }
    }

    // MARK: - Sound Effects
    func playSound(_ sound: SoundEffect, volume: Float? = nil) {
        guard isSoundEnabled else { return }

        // Add haptic feedback for certain sounds
        provideHapticFeedback(for: sound)

        // For now, generate procedural sounds
        generateProceduralSound(sound, volume: volume ?? soundVolume)
    }

    private func loadSound(_ sound: SoundEffect) -> Data? {
        // Check cache
        if let cachedData = soundCache[sound] {
            return cachedData
        }

        // Try to load from bundle
        let fileName = sound.rawValue
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else {
            // Generate placeholder sound
            return generatePlaceholderSound(sound)
        }

        do {
            let data = try Data(contentsOf: url)
            soundCache[sound] = data
            return data
        } catch {
            print("🔊 Failed to load sound: \(fileName)")
            return nil
        }
    }

    private func playSoundFromData(_ data: Data, volume: Float) {
        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = volume
            player.prepareToPlay()
            player.play()

            // Keep reference to prevent deallocation
            soundEffectPlayers.append(player)

            // Clean up finished players
            if soundEffectPlayers.count > maxConcurrentSounds {
                soundEffectPlayers.removeAll { !$0.isPlaying }
            }
        } catch {
            print("🔊 Failed to play sound: \(error)")
        }
    }

    // MARK: - Procedural Sound Generation
    private func generateProceduralSound(_ sound: SoundEffect, volume: Float) {
        // Use system sounds as placeholders
        let soundID: SystemSoundID

        switch sound {
        case .buttonTap, .menuOpen, .menuClose:
            soundID = 1104 // Tock sound

        case .sparkMove, .sparkCharge:
            soundID = 1057 // Tink sound

        case .vesperMove, .vesperFlow:
            soundID = 1103 // Bell sound

        case .levelComplete, .achievementUnlocked:
            soundID = 1025 // Positive sound

        case .levelFailed:
            soundID = 1073 // Negative sound

        case .coinCollect, .rewardClaimed:
            soundID = 1105 // Pop sound

        case .windmillActivate, .bridgeExtend:
            soundID = 1106 // Whoosh

        case .electricShock, .hazardWarning:
            soundID = 1052 // Warning sound

        default:
            soundID = 1104 // Default
        }

        // Play system sound
        if volume > 0.5 {
            AudioServicesPlaySystemSound(soundID)
        } else {
            AudioServicesPlaySystemSoundWithCompletion(soundID, nil)
        }
    }

    private func generatePlaceholderSound(_ sound: SoundEffect) -> Data? {
        // In production, this would generate or load actual sound data
        // For now, return nil to use system sounds
        return nil
    }

    private func createPlaceholderMusic(_ music: BackgroundMusic) {
        // In production, this would load actual music files
        // For now, we'll use silence
        print("🔊 Using placeholder for \(music.rawValue)")
    }

    // MARK: - Haptic Feedback
    private func provideHapticFeedback(for sound: SoundEffect) {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return }

        switch sound {
        case .buttonTap, .menuOpen, .menuClose:
            selectionGenerator.selectionChanged()

        case .levelComplete, .achievementUnlocked:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

        case .levelFailed:
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)

        case .sparkCharge, .vesperFlow, .resonancePulse:
            impactGenerator.impactOccurred()

        case .electricShock, .hazardWarning:
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()

        default:
            break
        }
    }

    // MARK: - Fade Effects
    private func fadeIn(duration: TimeInterval = 0.5) {
        guard let player = backgroundMusicPlayer else { return }

        player.volume = 0
        let targetVolume = musicVolume

        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = targetVolume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak player] in
                player?.volume = volumeStep * Float(i + 1)
            }
        }
    }

    private func fadeOutAndStop(duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        guard let player = backgroundMusicPlayer else {
            completion?()
            return
        }

        let startVolume = player.volume
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeStep = startVolume / Float(steps)

        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(i)) { [weak player] in
                player?.volume = startVolume - (volumeStep * Float(i + 1))
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.backgroundMusicPlayer?.stop()
            self?.backgroundMusicPlayer = nil
            completion?()
        }
    }

    // MARK: - Dynamic Audio
    func adjustMusicForGameState(surge: CGFloat, flow: CGFloat, proximity: CGFloat) {
        // Dynamic music adjustment based on game state
        guard let player = backgroundMusicPlayer else { return }

        // Increase tempo/intensity based on energy levels
        let intensity = (surge + flow + proximity) / 3.0
        let adjustedVolume = musicVolume * (0.7 + Float(intensity) * 0.3)
        player.volume = adjustedVolume
    }

    // MARK: - 3D Positional Audio
    func playPositionalSound(_ sound: SoundEffect, at position: CGPoint, listenerPosition: CGPoint) {
        guard isSoundEnabled else { return }

        // Calculate distance and pan
        let dx = position.x - listenerPosition.x
        let dy = position.y - listenerPosition.y
        let distance = sqrt(dx * dx + dy * dy)

        // Volume falloff based on distance
        let maxDistance: CGFloat = 500
        let volumeMultiplier = max(0, 1 - (distance / maxDistance))

        // Stereo panning (-1 to 1)
        let pan = max(-1, min(1, dx / 200))

        // Play with adjusted parameters
        playSound(sound, volume: soundVolume * Float(volumeMultiplier))

        // Note: Actual panning would require using AVAudioPlayer's pan property
        // or AVAudioEngine for more advanced 3D audio
    }
}

// MARK: - Sound Profiles
extension SoundManager {
    struct SoundProfile {
        let music: BackgroundMusic
        let ambientSounds: [SoundEffect]
        let musicVolume: Float
        let effectVolume: Float
    }

    static let menuProfile = SoundProfile(
        music: .mainMenu,
        ambientSounds: [],
        musicVolume: 0.5,
        effectVolume: 0.7
    )

    static let gameplayProfile = SoundProfile(
        music: .gameplay,
        ambientSounds: [.proximityGlow],
        musicVolume: 0.3,
        effectVolume: 0.8
    )

    static let bossProfile = SoundProfile(
        music: .boss,
        ambientSounds: [.hazardWarning],
        musicVolume: 0.6,
        effectVolume: 0.9
    )

    func applySoundProfile(_ profile: SoundProfile) {
        musicVolume = profile.musicVolume
        soundVolume = profile.effectVolume
        playBackgroundMusic(profile.music)
    }
}

// MARK: - SwiftUI Integration
import SwiftUI

struct SoundSettingsView: View {
    @StateObject private var soundManager = SoundManager.shared

    var body: some View {
        VStack(spacing: 20) {
            // Music Toggle
            Toggle("Music", isOn: $soundManager.isMusicEnabled)
                .onChange(of: soundManager.isMusicEnabled) { _ in
                    SoundManager.shared.playSound(.buttonTap)
                }

            // Music Volume
            if soundManager.isMusicEnabled {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $soundManager.musicVolume, in: 0...1)
                    Image(systemName: "speaker.wave.3.fill")
                }
            }

            // Sound Effects Toggle
            Toggle("Sound Effects", isOn: $soundManager.isSoundEnabled)
                .onChange(of: soundManager.isSoundEnabled) { newValue in
                    if newValue {
                        SoundManager.shared.playSound(.buttonTap)
                    }
                }

            // Sound Volume
            if soundManager.isSoundEnabled {
                HStack {
                    Image(systemName: "speaker.fill")
                    Slider(value: $soundManager.soundVolume, in: 0...1)
                        .onChange(of: soundManager.soundVolume) { _ in
                            SoundManager.shared.playSound(.buttonTap)
                        }
                    Image(systemName: "speaker.wave.3.fill")
                }
            }
        }
        .padding()
    }
}

// MARK: - Audio File Requirements
/*
 Required Audio Files:

 Background Music (looping MP3s):
 - music_menu.mp3 (calm, ambient)
 - music_gameplay.mp3 (energetic, rhythmic)
 - music_tutorial.mp3 (gentle, guiding)
 - music_boss.mp3 (intense, dramatic)
 - music_victory.mp3 (triumphant, celebratory)

 Sound Effects (WAV files):
 - UI: button_tap, menu_open, menu_close
 - Spark: spark_move, spark_charge, windmill_activate
 - Vesper: vesper_move, vesper_flow, ice_wall_melt
 - Shared: bridge_extend, resonance_pulse, proximity_glow
 - Success: level_complete, achievement_unlocked, coin_collect
 - Hazards: electric_shock, void_pull, hazard_warning

 Audio Guidelines:
 - Keep sound effects under 1 second
 - Use 44.1kHz sample rate
 - Compress music files to ~128kbps MP3
 - Total audio budget: ~10MB
 */