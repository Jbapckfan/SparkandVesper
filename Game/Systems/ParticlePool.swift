import SpriteKit

final class ParticlePool {
    private var pool: [SKEmitterNode] = []
    private var activeEmitters: Set<SKEmitterNode> = []
    private let maxPoolSize = 100
    private let maxActiveEmitters = 30
    private var emissionsThisFrame = 0
    private let maxEmissionsPerFrame = 5
    
    func getEmitter(named: String) -> SKEmitterNode? {
        // Cap per-frame emissions
        guard emissionsThisFrame < maxEmissionsPerFrame else { return nil }
        guard activeEmitters.count < maxActiveEmitters else { return nil }
        
        emissionsThisFrame += 1
        
        // Try to reuse from pool
        if let idx = pool.firstIndex(where: { $0.name == named }) {
            let emitter = pool.remove(at: idx)
            activeEmitters.insert(emitter)
            return emitter
        }
        
        // Create new if pool is empty
        let e = SKEmitterNode()
        e.name = named
        e.particleBirthRate = 0
        e.particleLifetime = 0.6
        e.particleLifetimeRange = 0.2
        e.particleSpeed = 60
        e.particleSpeedRange = 20
        e.particleAlpha = 0.9
        e.particleScale = 0.12
        e.particleScaleRange = 0.04
        e.particleColorBlendFactor = 1.0
        e.particleTexture = SKTexture(image: makeDot())
        e.targetNode = nil // Important for performance
        activeEmitters.insert(e)
        return e
    }
    func recycle(_ emitter: SKEmitterNode) {
        activeEmitters.remove(emitter)
        
        guard pool.count < maxPoolSize else {
            // If pool is full, just remove the emitter
            emitter.removeFromParent()
            return
        }
        
        // Reset emitter state
        emitter.removeAllActions()
        emitter.particleBirthRate = 0
        emitter.resetSimulation()
        emitter.removeFromParent()
        pool.append(emitter)
    }
    
    func resetFrameCounter() {
        emissionsThisFrame = 0
    }
    
    func recycleInactive() {
        // Clean up finished emitters
        let toRecycle = activeEmitters.filter { 
            $0.particleBirthRate == 0 && $0.numParticlesToEmit == 0 
        }
        toRecycle.forEach { recycle($0) }
    }
    
    private func makeDot() -> UIImage {
        let size = CGSize(width: 8, height: 8)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.fillEllipse(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

// Beauty enhancement - trail system
extension ParticlePool {
    func makeTrailNode(baseColor: SKColor) -> SKEmitterNode? {
        // Use pool for trails too
        guard let e = getEmitter(named: "trail") else { return nil }
        
        e.particleTexture = SKTexture(image: makeDot())
        e.particleBirthRate = 60  // Reduced from 90 for performance
        e.particleLifetime = 0.25
        e.particleAlpha = 0.5
        e.particleAlphaSpeed = -2.2
        e.particleScale = 0.12
        e.particleScaleSpeed = -0.3
        e.particleColor = baseColor
        e.particleBlendMode = .add
        e.particleSpeed = 0
        e.particlePositionRange = CGVector(dx: 2, dy: 2)
        e.numParticlesToEmit = 0  // Continuous emission
        e.targetNode = nil  // Better performance
        return e
    }
}