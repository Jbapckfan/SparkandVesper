import Foundation

class LevelManager: ObservableObject {
    static let shared = LevelManager()
    
    @Published var currentLevel = 1
    @Published var unlockedLevels = Set<Int>([1])
    @Published var levelScores: [Int: Int] = [:]
    
    let levels = [
        Level(id: 1, name: "Awakening", type: .spriteKit, 
              description: "Spark and Vesper awaken in a fractured reality",
              htmlFile: nil),
        Level(id: 2, name: "Dual Paths", type: .webLevel,
              description: "Navigate parallel worlds with unique barriers", 
              htmlFile: "level1"),
        Level(id: 3, name: "Synaptic Echo", type: .webLevel,
              description: "Split dimensions require perfect synchronization",
              htmlFile: "level2")
    ]
    
    private init() {
        loadProgress()
    }
    
    func completeLevel(_ levelId: Int, score: Int = 0) {
        levelScores[levelId] = max(levelScores[levelId] ?? 0, score)
        
        if levelId < levels.count {
            unlockedLevels.insert(levelId + 1)
        }
        
        saveProgress()
    }
    
    func resetProgress() {
        currentLevel = 1
        unlockedLevels = Set([1])
        levelScores = [:]
        saveProgress()
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "levelProgress"),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: data) {
            currentLevel = decoded.currentLevel
            unlockedLevels = Set(decoded.unlockedLevels)
            levelScores = decoded.levelScores
        }
    }
    
    private func saveProgress() {
        let saveData = SaveData(
            currentLevel: currentLevel,
            unlockedLevels: Array(unlockedLevels),
            levelScores: levelScores
        )
        if let encoded = try? JSONEncoder().encode(saveData) {
            UserDefaults.standard.set(encoded, forKey: "levelProgress")
        }
    }
    
    private struct SaveData: Codable {
        let currentLevel: Int
        let unlockedLevels: [Int]
        let levelScores: [Int: Int]
    }
}