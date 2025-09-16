import UIKit

enum Haptics {
    static let light = UIImpactFeedbackGenerator(style: .light)
    static let medium = UIImpactFeedbackGenerator(style: .medium)
    static let success = UINotificationFeedbackGenerator()

    static func prepare() {
        light.prepare()
        medium.prepare()
        success.prepare()
    }
    
    static func bridgeThreshold() { 
        light.impactOccurred(intensity: 0.7) 
    }
    
    static func barrierBreak() { 
        medium.impactOccurred(intensity: 0.9) 
    }
    
    static func win() { 
        success.notificationOccurred(.success) 
    }
    
    static func proximityTear() {
        light.impactOccurred(intensity: 0.4)
    }
}