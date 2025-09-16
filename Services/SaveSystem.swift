import Foundation

struct SaveState: Codable {
    var currentLevel: Int
    var unlocked: [Int]
    var bestTimes: [Int: Int] // level : seconds
}

enum SaveSystem {
    private static let key = "sv.save"
    static func load() -> SaveState {
        guard let data = UserDefaults.standard.data(forKey: key),
              let s = try? JSONDecoder().decode(SaveState.self, from: data) else {
            return SaveState(currentLevel: 0, unlocked: [0], bestTimes: [:])
        }
        return s
    }
    static func save(_ state: SaveState) {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}