import SpriteKit

final class FlowBarrierNode: SKShapeNode {
    private var open = false
    
    init(position: CGPoint, size: CGSize) {
        super.init()
        self.position = position
        self.path = CGPath(rect: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height), transform: nil)
        self.fillColor = .systemPurple.withAlphaComponent(0.9)
        self.strokeColor = .clear
        
        // Add flowing energy effect
        let flowField = SKShapeNode(rect: CGRect(x: -size.width/2 - 4, y: -size.height/2 - 4, width: size.width + 8, height: size.height + 8))
        flowField.fillColor = .clear
        flowField.strokeColor = .systemPurple
        flowField.lineWidth = 1
        flowField.alpha = 0.4
        flowField.zPosition = -1
        addChild(flowField)
        flowField.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.2, duration: 0.8),
            .fadeAlpha(to: 0.4, duration: 0.8)
        ])))
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func update(flow: CGFloat) {
        if flow >= 1.0 && !open {
            open = true
            Haptics.barrierBreak()
            run(.sequence([
                .fadeOut(withDuration: 0.12),
                .removeFromParent()
            ]))
        }
    }
}