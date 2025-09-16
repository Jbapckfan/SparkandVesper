import SpriteKit

final class ExitPortalNode: SKShapeNode {
    let radius: CGFloat
    private let pulse = SKShapeNode(circleOfRadius: 18)
    private let innerGlow = SKShapeNode(circleOfRadius: 10)
    private(set) var occupied = false
    
    init(position: CGPoint, radius: CGFloat, color: SKColor) {
        self.radius = radius
        super.init()
        self.position = position
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = color.withAlphaComponent(0.35)
        self.strokeColor = color
        self.lineWidth = 3
        self.glowWidth = 8
        
        // Inner glow
        innerGlow.fillColor = color.withAlphaComponent(0.3)
        innerGlow.strokeColor = .clear
        innerGlow.blendMode = .add
        addChild(innerGlow)
        
        // Outer pulse
        pulse.strokeColor = color
        pulse.lineWidth = 1
        pulse.alpha = 0.6
        addChild(pulse)
        pulse.run(.repeatForever(.sequence([
            .group([.scale(to: 1.15, duration: 0.9), .fadeAlpha(to: 0.2, duration: 0.9)]),
            .group([.scale(to: 1.0, duration: 0.9), .fadeAlpha(to: 0.6, duration: 0.9)])
        ])))
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func updateOccupancy(entityPosition: CGPoint) {
        let wasOccupied = occupied
        occupied = hypot(entityPosition.x - position.x, entityPosition.y - position.y) <= radius
        
        if occupied != wasOccupied {
            if occupied {
                run(.group([
                    .scale(to: 1.1, duration: 0.1),
                    .fadeAlpha(to: 1.0, duration: 0.1)
                ]))
                innerGlow.run(.fadeAlpha(to: 0.6, duration: 0.1))
            } else {
                run(.group([
                    .scale(to: 1.0, duration: 0.2),
                    .fadeAlpha(to: 0.6, duration: 0.2)
                ]))
                innerGlow.run(.fadeAlpha(to: 0.3, duration: 0.2))
            }
        }
    }
}