import SpriteKit

final class WindmillNode: SKNode {
    let linkIndex: Int
    private let hub = SKShapeNode(circleOfRadius: 6)
    private var blades: [SKShapeNode] = []
    private var active = false
    
    init(position: CGPoint, linkIndex: Int) {
        self.linkIndex = linkIndex
        super.init()
        self.position = position
        
        hub.fillColor = .white
        hub.strokeColor = .clear
        addChild(hub)
        
        for i in 0..<4 {
            let blade = SKShapeNode(rectOf: CGSize(width: 28, height: 4), cornerRadius: 2)
            blade.fillColor = .white.withAlphaComponent(0.9)
            blade.strokeColor = .clear
            blade.zRotation = .pi/2 * CGFloat(i)
            blades.append(blade)
            addChild(blade)
        }
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func setActive(_ on: Bool) { active = on }
    
    func tick(dt: CGFloat) {
        guard active else { return }
        zRotation += 0.1 * dt * 60
    }
}