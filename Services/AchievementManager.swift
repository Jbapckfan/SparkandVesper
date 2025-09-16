import Foundation

enum Achievement: String, CaseIterable, Codable {
    case firstWin, speedRunner, perfectRun, surgeMaster, flowMaster, particleMaster
}

final class AchievementManager {
    static let shared = AchievementManager()
    private init() {}
    
    private var unlocked = Set<Achievement>()
    
    func unlock(_ a: Achievement) {
        guard !unlocked.contains(a) else { return }
        unlocked.insert(a)
        // TODO: show popup UI via NotificationCenter / Combine to SwiftUI
        print("Achievement unlocked: \(a.rawValue)")
    }
}