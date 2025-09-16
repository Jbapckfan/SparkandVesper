import SpriteKit

final class SurgeBarrierNode: SKShapeNode {
    private var broken = false
    
    init(position: CGPoint, size: CGSize) {
        super.init()
        self.position = position
        self.path = CGPath(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), transform: nil)
        self.fillColor = .systemYellow.withAlphaComponent(0.9)
        self.strokeColor = .clear
        
        // Add energy pulse effect
        let energyField = SKShapeNode(rect: CGRect(x: -size.width/2 - 4, y: -size.height/2 - 4, width: size.width + 8, height: size.height + 8))
        energyField.fillColor = .clear
        energyField.strokeColor = .systemYellow
        energyField.lineWidth = 1
        energyField.alpha = 0.4
        energyField.zPosition = -1
        addChild(energyField)
        energyField.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.6),
            .fadeAlpha(to: 0.4, duration: 0.6)
        ])))
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func tryBreak(surge: CGFloat) {
        guard !broken, surge >= 1.0 else { return }
        broken = true
        Haptics.barrierBreak()
        run(.sequence([
            .scale(to: 1.2, duration: 0.06),
            .fadeOut(withDuration: 0.12),
            .removeFromParent()
        ]))
    }
}