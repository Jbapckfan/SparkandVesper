import SpriteKit

final class VesperNode: SKShapeNode {
    private(set) var flow: CGFloat = 0.0
    private var flowTarget: CGPoint?
    private var vx: CGFloat = 0
    private var vy: CGFloat = 0
    private var trail: [CGPoint] = []
    
    // Level 3 style flow tuning
    private let flowSpeed: CGFloat = 100.0
    private let damping: CGFloat = 0.92
    private let flowChargeSmooth: CGFloat = 0.004
    
    override init() {
        super.init()
        let radius: CGFloat = 14
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius*2, height: radius*2), transform: nil)
        self.fillColor = .clear
        self.strokeColor = .clear
        self.name = "vesper"
        
        setupVisualEffects()
    }
    
    private func setupVisualEffects() {
        // Multiple glow layers (matching Level 3)
        for i in 1...3 {
            let glowRadius = 14.0 * (1 + CGFloat(i) * 0.4)
            let glow = SKShapeNode(circleOfRadius: glowRadius)
            glow.fillColor = UIColor(red: 0.58, green: 0.42, blue: 1.0, alpha: 0.15 / CGFloat(i))
            glow.strokeColor = .clear
            glow.blendMode = .add
            glow.zPosition = -CGFloat(i)
            addChild(glow)
        }
        
        // Core gradient (bright center)
        let core = SKShapeNode(circleOfRadius: 14)
        let coreGradient = [UIColor.white, UIColor(red: 0.89, green: 0.83, blue: 1.0, alpha: 1.0), 
                           UIColor(red: 0.78, green: 0.71, blue: 1.0, alpha: 1.0), UIColor(red: 0.58, green: 0.42, blue: 1.0, alpha: 1.0)]
        core.fillColor = coreGradient[1]
        core.strokeColor = .clear
        core.zPosition = 1
        addChild(core)
        
        // Inner highlight
        let highlight = SKShapeNode(circleOfRadius: 4.2)
        highlight.fillColor = UIColor(white: 1.0, alpha: 0.8)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: 2, y: -2)
        highlight.zPosition = 2
        addChild(highlight)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setFlowTarget(_ x: CGFloat, _ y: CGFloat) {
        flowTarget = CGPoint(x: x, y: y)
    }
    
    func tick(dt: CGFloat) {
        // Level 3 style automatic movement to target
        if let target = flowTarget {
            let dx = target.x - position.x
            let dy = target.y - position.y
            let dist = sqrt(dx*dx + dy*dy)
            
            if dist > 10 {
                vx += (dx / dist) * flowSpeed * dt
                vy += (dy / dist) * flowSpeed * dt
            } else {
                // Arrived at target, reduce flow target strength
                flowTarget = nil
            }
        }
        
        position.x += vx * dt
        position.y += vy * dt
        
        vx *= damping
        vy *= damping
        
        // Trail effect
        trail.append(position)
        if trail.count > 25 { trail.removeFirst() }
        
        // Flow charges from smooth motion (Level 3 style)
        let speed = sqrt(vx*vx + vy*vy)
        flow = max(0, min(1, flow + flowChargeSmooth))
        GameManager.shared.updateFlow(flow)
        
        // Flow ping at 100%
        if flow >= 1.0 && previousFlow < 1.0 {
            Haptics.barrierBreak()
        }
        previousFlow = flow
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
        trailNode.strokeColor = UIColor(red: 0.58, green: 0.42, blue: 1.0, alpha: 0.3)
        trailNode.lineWidth = 4
        trailNode.lineCap = .round
        trailNode.zPosition = -10
        scene.addChild(trailNode)
        
        trailNode.run(.sequence([
            .fadeAlpha(to: 0, duration: 0.5),
            .removeFromParent()
        ]))
    }
    private var previousFlow: CGFloat = 0
}