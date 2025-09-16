import Foundation

struct Level: Identifiable {
    let id: Int
    let name: String
    let type: LevelType
    let description: String
    let htmlFile: String?
    
    enum LevelType {
        case spriteKit
        case webLevel
    }
}