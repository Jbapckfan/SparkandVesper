import SpriteKit

final class SparkNode: SKShapeNode {
    private(set) var surge: CGFloat = 0.0
    private var dragging = false
    private var targetX: CGFloat = 0
    private var targetY: CGFloat = 0
    private var vx: CGFloat = 0
    private var vy: CGFloat = 0
    private var trail: [CGPoint] = []
    var selected = false
    
    // Movement tuning (matching Level 3)
    private let acceleration: CGFloat = 8.0
    private let damping: CGFloat = 0.9
    private let chargeRate: CGFloat = 0.0035
    private let dischargeRate: CGFloat = 0.0012
    
    override init() {
        super.init()
        let radius: CGFloat = 15
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .clear
        self.strokeColor = .clear
        self.name = "spark"
        
        targetX = position.x
        targetY = position.y
        
        setupVisualEffects()
    }
    
    private func setupVisualEffects() {
        // Multiple glow layers (matching Level 3)
        for i in 1...3 {
            let glowRadius = 15.0 * (1 + CGFloat(i) * 0.4)
            let glow = SKShapeNode(circleOfRadius: glowRadius)
            glow.fillColor = UIColor(red: 1.0, green: 0.78, blue: 0.39, alpha: 0.2 / CGFloat(i))
            glow.strokeColor = .clear
            glow.blendMode = .add
            glow.zPosition = -CGFloat(i)
            addChild(glow)
        }
        
        // Core gradient (bright center)
        let core = SKShapeNode(circleOfRadius: 15)
        let colors = [UIColor.white, UIColor(red: 1.0, green: 0.89, blue: 0.67, alpha: 1.0), 
                     UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0), UIColor(red: 1.0, green: 0.58, blue: 0.26, alpha: 1.0)]
        core.fillColor = colors[1]
        core.strokeColor = .clear
        core.zPosition = 1
        addChild(core)
        
        // Inner highlight
        let highlight = SKShapeNode(circleOfRadius: 4.5)
        highlight.fillColor = UIColor(white: 1.0, alpha: 0.8)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -3, y: -3)
        highlight.zPosition = 2
        addChild(highlight)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Input (Level 3 style)
    func beginDrag(at point: CGPoint) {
        let distance = hypot(point.x - position.x, point.y - position.y)
        if distance < 50 {
            dragging = true
            selected = true
        }
    }
    
    func drag(to point: CGPoint) {
        guard dragging else { return }
        targetX = point.x
        targetY = point.y
        
        surge = min(1.0, surge + chargeRate)
        GameManager.shared.updateSurge(surge)
        
        // Surge threshold haptic
        if surge >= 1.0 && previousSurge < 1.0 {
            Haptics.barrierBreak()
        }
        previousSurge = surge
    }
    
    private var previousSurge: CGFloat = 0
    func endDrag() {
        dragging = false
        selected = false
        surge = max(0, surge - dischargeRate)
    }
    
    func tick(dt: CGFloat) {
        // Level 3 style smooth movement
        let dx = targetX - position.x
        let dy = targetY - position.y
        
        vx += dx * dt * acceleration
        vy += dy * dt * acceleration
        
        position.x += vx * dt * 60
        position.y += vy * dt * 60
        
        vx *= damping
        vy *= damping
        
        // Trail effect
        trail.append(position)
        if trail.count > 20 { trail.removeFirst() }
        
        // Passive discharge
        surge = max(0, surge - dischargeRate*dt*60)
        GameManager.shared.updateSurge(surge)
    }
    
    func render(in scene: SKScene) {
        // Render trail (Level 3 style)
        guard trail.count > 1 else { return }
        
        let trailPath = CGMutablePath()
        trailPath.move(to: trail[0])
        for i in 1..<trail.count {
            trailPath.addLine(to: trail[i])
        }
        
        let trailNode = SKShapeNode(path: trailPath)
        trailNode.strokeColor = UIColor(red: 1.0, green: 0.58, blue: 0.26, alpha: 0.3)
        trailNode.lineWidth = 4
        trailNode.lineCap = .round
        trailNode.zPosition = -10
        scene.addChild(trailNode)
        
        trailNode.run(.sequence([
            .fadeAlpha(to: 0, duration: 0.5),
            .removeFromParent()
        ]))
    }
}
