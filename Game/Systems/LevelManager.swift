import Foundation
import CoreGraphics
import Combine

// MARK: - Specs
struct WindmillSpec: Codable { let position: CGPoint; let linkIndex: Int }
struct BridgeSpec: Codable { let origin: CGPoint; let maxWidth: CGFloat; let linkIndex: Int }
struct HeatPlateSpec: Codable { let position: CGPoint; let radius: CGFloat; let linkIndex: Int }
struct IceWallSpec: Codable { let position: CGPoint; let size: CGSize; let linkIndex: Int; let meltTime: CGFloat }
struct SurgeBarrierSpec: Codable { let position: CGPoint; let size: CGSize }   // Spark world
struct FlowBarrierSpec: Codable { let position: CGPoint; let size: CGSize }    // Vesper world
struct PortalSpec: Codable { let position: CGPoint; let radius: CGFloat }

struct LevelData: Codable {
    let index: Int
    let title: String
    let sparkStart: CGPoint
    let vesperStart: CGPoint
    let windmills: [WindmillSpec]
    let bridges: [BridgeSpec]
    let heatPlates: [HeatPlateSpec]
    let iceWalls: [IceWallSpec]
    let surgeBarriers: [SurgeBarrierSpec]
    let flowBarriers: [FlowBarrierSpec]
    let sparkPortal: PortalSpec
    let vesperPortal: PortalSpec
}

final class LevelManager: ObservableObject {
    static let shared = LevelManager()
    private init() {}
    
    @Published private(set) var currentLevelIndex: Int = SaveSystem.load().currentLevel
    @Published private(set) var levelData: LevelData = LevelManager.levels[0]
    
    private var startTime: Date?
    private var cancellables = Set<AnyCancellable>()
    
    func loadCurrentLevel() {
        let idx = max(0, min(Self.levels.count - 1, SaveSystem.load().currentLevel))
        loadLevel(at: idx)
    }
    
    func loadLevel(at index: Int) {
        let idx = max(0, min(Self.levels.count - 1, index))
        currentLevelIndex = idx
        levelData = Self.levels[idx]
        GameManager.shared.levelTitle = levelData.title
        startTime = Date()
        GameManager.shared.resetForNewLevel()
        GameManager.shared.sparkScene?.apply(level: levelData)
        GameManager.shared.vesperScene?.apply(level: levelData)
    }
    
    func completeLevel() {
        guard let start = startTime else { return }
        let seconds = Int(Date().timeIntervalSince(start))
        var state = SaveSystem.load()
        // best time
        if let best = state.bestTimes[levelData.index], best <= seconds {
            // keep
        } else {
            state.bestTimes[levelData.index] = seconds
        }
        // unlock next
        if levelData.index == state.currentLevel {
            state.currentLevel = min(Self.levels.count - 1, state.currentLevel + 1)
            if !state.unlocked.contains(state.currentLevel) {
                state.unlocked.append(state.currentLevel)
            }
        }
        SaveSystem.save(state)
        
        // Show win screen and wait for user action
        showWinScreen(seconds: seconds)
    }
    
    func restartCurrentLevel() {
        loadCurrentLevel()
    }
    
    func advanceToNextLevel() {
        let nextIdx = min(Self.levels.count-1, levelData.index + 1)
        currentLevelIndex = nextIdx
        levelData = Self.levels[nextIdx]
        loadCurrentLevel()
    }
    
    private func showWinScreen(seconds: Int) {
        // Notify UI to show win screen with options
        NotificationCenter.default.post(
            name: Notification.Name("ShowWinScreen"),
            object: nil,
            userInfo: [
                "time": seconds,
                "levelIndex": levelData.index,
                "hasNextLevel": levelData.index < Self.levels.count - 1
            ]
        )
    }
}

// MARK: - Authored Levels 0-3
extension LevelManager {
    static let levels: [LevelData] = [
        // Level 0 – Teaching level with clear visual objectives
        LevelData(
            index: 0,
            title: "Level 0 – First Sight",
            sparkStart: .init(x: 60, y: 200),
            vesperStart: .init(x: 60, y: 100),
            windmills: [ .init(position: .init(x: 150, y: 180), linkIndex: 0) ],
            bridges:   [ .init(origin:   .init(x: 120, y: 140), maxWidth: 100, linkIndex: 0) ],
            heatPlates:[ .init(position: .init(x: 200, y: 180), radius: 35, linkIndex: 0) ],
            iceWalls:  [ .init(position: .init(x: 220, y: 100), size: .init(width: 45, height: 70), linkIndex: 0, meltTime: 1.0) ],
            surgeBarriers: [],
            flowBarriers: [],
            sparkPortal:  .init(position: .init(x: 280, y: 180), radius: 30),
            vesperPortal: .init(position: .init(x: 280, y: 100), radius: 30)
        ),
        // Level 1 – First Contact (simple introduction level)
        LevelData(
            index: 1,
            title: "First Contact",
            sparkStart: .init(x: 80, y: 160),
            vesperStart: .init(x: 80, y: 120),
            windmills: [ .init(position: .init(x: 180, y: 140), linkIndex: 0) ],
            bridges:   [ .init(origin:   .init(x: 220, y: 120), maxWidth: 80, linkIndex: 0) ],
            heatPlates: [],
            iceWalls: [],
            surgeBarriers: [], flowBarriers: [],
            sparkPortal:  .init(position: .init(x: 350, y: 160), radius: 28),
            vesperPortal: .init(position: .init(x: 350, y: 120), radius: 28)
        ),
        // Level 2 – Warmth & Thaw
        LevelData(
            index: 2,
            title: "Level 2 – Warmth & Thaw",
            sparkStart: .init(x: 100, y: 260),
            vesperStart: .init(x: 80,  y: 150),
            windmills: [], bridges: [],
            heatPlates:[ .init(position: .init(x: 220, y: 200), radius: 28, linkIndex: 0) ],
            iceWalls:  [ .init(position: .init(x: 280, y: 140), size: .init(width: 60, height: 110), linkIndex: 0, meltTime: 3.0) ],
            surgeBarriers: [], flowBarriers: [],
            sparkPortal:  .init(position: .init(x: 360, y: 110), radius: 26),
            vesperPortal: .init(position: .init(x: 360, y: 120), radius: 26)
        ),
        // Level 3 – Shared Burden
        LevelData(
            index: 3,
            title: "Level 3 – Shared Burden",
            sparkStart: .init(x: 90,  y: 260),
            vesperStart: .init(x: 90,  y: 150),
            windmills: [ .init(position: .init(x: 220, y: 210), linkIndex: 0) ],
            bridges:   [ .init(origin:   .init(x: 190, y: 140), maxWidth: 120, linkIndex: 0) ],
            heatPlates:[ .init(position: .init(x: 300, y: 220), radius: 28, linkIndex: 0) ],
            iceWalls:  [ .init(position: .init(x: 300, y: 140), size: .init(width: 60, height: 110), linkIndex: 0, meltTime: 4.0) ],
            surgeBarriers: [ .init(position: .init(x: 250, y: 120), size: .init(width: 40, height: 28)) ],
            flowBarriers:  [ .init(position: .init(x: 250, y: 120), size: .init(width: 40, height: 28)) ],
            sparkPortal:  .init(position: .init(x: 380, y: 120), radius: 26),
            vesperPortal: .init(position: .init(x: 380, y: 120), radius: 26)
        )
    ]
}