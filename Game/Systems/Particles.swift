import SpriteKit
import UIKit

final class Particles {
    // Prebuilt textures
    private let sparkTex: SKTexture
    private let vesperTex: SKTexture
    
    // Colors matching web demo
    private let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)      // #FFD700
    private let ember = UIColor(red: 1.0, green: 0.42, blue: 0.21, alpha: 1.0)    // #FF6B35
    private let lavender = UIColor(red: 0.90, green: 0.90, blue: 0.98, alpha: 1.0) // #E6E6FA
    private let windBlue = UIColor(red: 0.40, green: 0.80, blue: 1.0, alpha: 1.0)  // #66CCFF
    private let vesperPurple = UIColor(red: 0.42, green: 0.27, blue: 0.76, alpha: 1.0) // #6B46C1
    
    init() {
        sparkTex = ParticleTex.square(size: 6, color: .white)
        vesperTex = ParticleTex.softCircle(diameter: 40, color: vesperPurple)
    }
    
    // MARK: - Spark Particles
    
    func sparkMove() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = sparkTex
        e.particleBirthRate = 90
        e.particleLifetime = 0.4
        e.particleLifetimeRange = 0.2
        e.particleSize = CGSize(width: 6, height: 6)
        e.emissionAngleRange = .pi
        e.particleSpeed = 40
        e.particleSpeedRange = 30
        e.particleAlpha = 0.9
        e.particleAlphaRange = 0.1
        e.particleAlphaSpeed = -1.5
        e.particleColor = gold
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        e.particleRotationRange = .pi
        e.yAcceleration = 20  // Rise/flicker motion
        return e
    }
    
    func sparkSurgeBurst() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = sparkTex
        e.particleBirthRate = 0
        e.numParticlesToEmit = 80
        e.particleLifetime = 0.35
        e.particleLifetimeRange = 0.1
        e.particleSize = CGSize(width: 8, height: 8)
        e.emissionAngleRange = .pi * 2
        e.particleSpeed = 180
        e.particleSpeedRange = 60
        e.particleAlpha = 1.0
        e.particleAlphaSpeed = -2.8
        e.particleColor = gold
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        e.particleScale = 1.2
        e.particleScaleSpeed = -2.0
        return e
    }
    
    // MARK: - Vesper Particles
    
    func vesperFlow() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = vesperTex
        e.particleBirthRate = 50
        e.particleLifetime = 0.8
        e.particleLifetimeRange = 0.4
        e.particleSpeed = 12
        e.particleSpeedRange = 8
        e.emissionAngleRange = .pi * 2
        e.xAcceleration = 0
        e.yAcceleration = 0
        e.particleAlpha = 0.45
        e.particleAlphaRange = 0.15
        e.particleAlphaSpeed = -0.4
        e.particleScale = 0.6
        e.particleScaleRange = 0.3
        e.particleScaleSpeed = 0.3  // Expands over life (drift/expand)
        e.particleColor = vesperPurple
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
    
    func vesperFlowBurst() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = vesperTex
        e.particleBirthRate = 0
        e.numParticlesToEmit = 60
        e.particleLifetime = 0.6
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 80
        e.particleSpeedRange = 40
        e.emissionAngleRange = .pi * 2
        e.particleAlpha = 0.6
        e.particleAlphaSpeed = -1.0
        e.particleScale = 0.8
        e.particleScaleSpeed = 1.5
        e.particleColor = lavender
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
    
    // MARK: - Mechanic Particles
    
    func heatEmbers() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = vesperTex
        e.particleBirthRate = 70
        e.particleLifetime = 0.7
        e.particleLifetimeRange = 0.3
        e.particleSpeed = 25
        e.particleSpeedRange = 10
        e.yAcceleration = 40  // Rising heat
        e.emissionAngle = .pi / 2  // Upward
        e.emissionAngleRange = .pi / 4
        e.particleAlpha = 0.35
        e.particleAlphaSpeed = -0.5
        e.particleScale = 0.4
        e.particleScaleRange = 0.2
        e.particleColor = ember
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
    
    func windStream() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = sparkTex
        e.particleBirthRate = 120
        e.particleLifetime = 0.5
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 60
        e.particleSpeedRange = 20
        e.xAcceleration = 80  // Horizontal wind
        e.emissionAngle = 0  // Left to right
        e.emissionAngleRange = .pi / 6
        e.particleAlpha = 0.6
        e.particleAlphaSpeed = -1.2
        e.particleScale = 0.4
        e.particleScaleRange = 0.2
        e.particleColor = windBlue
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
    
    func iceShards() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = sparkTex
        e.particleBirthRate = 0
        e.numParticlesToEmit = 40
        e.particleLifetime = 0.6
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 90
        e.particleSpeedRange = 30
        e.yAcceleration = -40  // Falling shards
        e.emissionAngleRange = .pi
        e.particleAlpha = 0.8
        e.particleAlphaSpeed = -1.3
        e.particleScale = 0.6
        e.particleScaleRange = 0.3
        e.particleRotationRange = .pi
        e.particleRotationSpeed = 2.0
        e.particleColor = windBlue
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
    
    // MARK: - Proximity Effects
    
    func proximityGlow() -> SKEmitterNode {
        let e = SKEmitterNode()
        e.particleTexture = vesperTex
        e.particleBirthRate = 30
        e.particleLifetime = 0.4
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 5
        e.particleSpeedRange = 3
        e.emissionAngleRange = .pi * 2
        e.particleAlpha = 0.3
        e.particleAlphaSpeed = -0.75
        e.particleScale = 1.5
        e.particleScaleSpeed = 2.0
        e.particleColor = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        e.particleColorBlendFactor = 1.0
        e.particleBlendMode = .add
        return e
    }
}