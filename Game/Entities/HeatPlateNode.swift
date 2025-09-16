import SpriteKit

final class HeatPlateNode: SKShapeNode {
    let linkIndex: Int
    private let radius: CGFloat
    private let pulseGlow = SKShapeNode()
    
    init(position: CGPoint, radius: CGFloat, linkIndex: Int) {
        self.radius = radius
        self.linkIndex = linkIndex
        super.init()
        self.position = position
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .orange
        self.strokeColor = .clear
        self.alpha = 0.8
        
        // Add pulsing glow effect
        pulseGlow.path = CGPath(ellipseIn: CGRect(x: -radius*1.2, y: -radius*1.2, width: radius*2.4, height: radius*2.4), transform: nil)
        pulseGlow.fillColor = .clear
        pulseGlow.strokeColor = .orange
        pulseGlow.lineWidth = 2
        pulseGlow.alpha = 0.3
        pulseGlow.zPosition = -1
        addChild(pulseGlow)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func isActive(sparkPosition: CGPoint) -> Bool {
        let d = hypot(sparkPosition.x - position.x, sparkPosition.y - position.y)
        let on = d < radius + 7
        alpha = on ? 1.0 : 0.65
        
        if on {
            pulseGlow.removeAllActions()
            pulseGlow.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.6, duration: 0.3),
                .fadeAlpha(to: 0.3, duration: 0.3)
            ])))
        } else {
            pulseGlow.removeAllActions()
            pulseGlow.alpha = 0.3
        }
        
        return on
    }
}