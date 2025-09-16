import SpriteKit

final class IceWallNode: SKShapeNode {
    private(set) var frozen: CGFloat = 1.0 // 1 = solid, 0 = gone
    private var meltRate: CGFloat = 0.4  // From Level01 tuning
    private var refreezeRate: CGFloat = 0.12  // From Level01 tuning
    private var targetFrozen: CGFloat = 1.0
    private let lerpSpeed: CGFloat = 0.15
    
    init(size: CGSize, meltRate: CGFloat = 0.4, refreezeRate: CGFloat = 0.12) {
        super.init()
        self.meltRate = meltRate
        self.refreezeRate = refreezeRate
        
        let rect = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)
        self.path = CGPath(rect: rect, transform: nil)
        self.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.9)
        self.strokeColor = .clear
        self.name = "ice"
        
        // Add subtle gradient effect
        self.glowWidth = 2.0
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func applyHeat(intensity: CGFloat, deltaTime: TimeInterval) {
        // Clamp intensity to valid range
        let clampedIntensity = clamp01(intensity)
        
        if clampedIntensity > 0 {
            // Melt when heat is applied
            targetFrozen = clamp01(targetFrozen - meltRate * clampedIntensity * CGFloat(deltaTime))
        } else {
            // Refreeze when no heat
            targetFrozen = clamp01(targetFrozen + refreezeRate * CGFloat(deltaTime))
        }
        
        // Smooth lerp to target
        frozen = lerp(frozen, targetFrozen, lerpSpeed)
        
        // Update visual state
        updateVisualState()
    }
    
    private func updateVisualState() {
        alpha = frozen
        isHidden = frozen <= 0.01
        
        // Add color shift as ice melts
        let r = 0.8 + (1.0 - frozen) * 0.1
        let g = 0.9 - (1.0 - frozen) * 0.1
        let b = 1.0
        fillColor = SKColor(red: r, green: g, blue: b, alpha: 0.9 * frozen)
    }
    
    private func clamp01(_ value: CGFloat) -> CGFloat {
        return max(0, min(1, value))
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
    
    // Reset for level restart
    func reset() {
        frozen = 1.0
        targetFrozen = 1.0
        updateVisualState()
    }
}