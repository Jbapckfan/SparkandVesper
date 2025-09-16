import SpriteKit

final class VesperScene: BaseScene {
    private let vesper = VesperNode()
    private var lastTime: TimeInterval = 0
    private var windAccumulator: CGFloat = 0
    private var currentDeltaTime: TimeInterval = 0
    
    // Authored objects
    private var iceWalls: [Int: IceWallNode] = [:]   // by linkIndex
    private var flowBarriers: [FlowBarrierNode] = []
    private var vesperPortal: ExitPortalNode?
    
    // Onboarding
    private var onboardingActive = false
    private var inactivityTimer: TimeInterval = 0
    private var ghostHint: SKShapeNode?
    
    var vesperPosition: CGPoint { vesper.position }
    
    override func didMove(to view: SKView) {
        GameManager.shared.vesperScene = self
        backgroundColor = SKColor(red: 0.06, green: 0.05, blue: 0.12, alpha: 1)
        addChild(vesper)
        isUserInteractionEnabled = true
    }
    
    func apply(level: LevelData) {
        removeAllChildren()
        addChild(vesper)
        
        let bg = SKSpriteNode(color: SKColor(red: 0.09, green: 0.07, blue: 0.16, alpha: 1), size: size)
        bg.anchorPoint = .zero; bg.position = .zero; bg.zPosition = -10
        addChild(bg)
        
        iceWalls.removeAll(); flowBarriers.removeAll(); vesperPortal = nil
        
        vesper.position = level.vesperStart
        
        // Setup onboarding for Level 0
        onboardingActive = (level.index == 0)
        inactivityTimer = 0
        setupGhostHint()
        if onboardingActive {
            isUserInteractionEnabled = false
            runOnboardingPath()
        } else {
            isUserInteractionEnabled = true
        }
        
        for w in level.iceWalls {
            let meltRate = 1.0 / w.meltTime  // Convert meltTime to meltRate
            let node = IceWallNode(size: w.size, meltRate: meltRate)
            node.position = w.position
            iceWalls[w.linkIndex] = node
            addChild(node)
        }
        for f in level.flowBarriers {
            let node = FlowBarrierNode(position: f.position, size: f.size)
            addChild(node); flowBarriers.append(node)
        }
        let portal = ExitPortalNode(position: level.vesperPortal.position, radius: level.vesperPortal.radius, color: .systemPurple)
        addChild(portal); vesperPortal = portal
        
        // Add visual hints for Level 0
        if level.index == 0 {
            // Arrow pointing to portal
            let arrow = SKLabelNode(text: "→")
            arrow.fontSize = 40
            arrow.fontName = "Arial-BoldMT"
            arrow.fontColor = .systemPurple
            arrow.position = CGPoint(x: portal.position.x - 60, y: portal.position.y)
            arrow.alpha = 0.6
            arrow.zPosition = 100
            addChild(arrow)
            arrow.run(.repeatForever(.sequence([
                .fadeAlpha(to: 0.3, duration: 0.8),
                .fadeAlpha(to: 0.8, duration: 0.8)
            ])))
            
            // "GOAL" text above portal
            let goalLabel = SKLabelNode(text: "GOAL")
            goalLabel.fontSize = 14
            goalLabel.fontName = "Arial-BoldMT"
            goalLabel.fontColor = .white
            goalLabel.position = CGPoint(x: portal.position.x, y: portal.position.y + 45)
            goalLabel.alpha = 0.7
            addChild(goalLabel)
        }
    }
    
    private func runOnboardingPath() {
        // glide along 3 points to immediately spin windmill & extend bridge
        let p1 = CGPoint(x: size.width*0.35, y: size.height*0.55)
        let p2 = CGPoint(x: size.width*0.55, y: size.height*0.50)
        let p3 = CGPoint(x: size.width*0.70, y: size.height*0.45)
        let seq = SKAction.sequence([
            SKAction.run { self.vesper.setFlowTarget(p1.x, p1.y) },
            SKAction.wait(forDuration: 0.7),
            SKAction.run { self.vesper.setFlowTarget(p2.x, p2.y) },
            SKAction.wait(forDuration: 0.7),
            SKAction.run { self.vesper.setFlowTarget(p3.x, p3.y) },
            SKAction.wait(forDuration: 0.6),
            SKAction.run {
                self.isUserInteractionEnabled = true
                self.onboardingActive = false
            }
        ])
        run(seq)
    }
    
    private func setupGhostHint() {
        ghostHint?.removeFromParent()
        let n = SKShapeNode(circleOfRadius: 16)
        n.strokeColor = .white
        n.lineWidth = 2
        n.alpha = 0.0
        n.zPosition = 50
        addChild(n)
        ghostHint = n
    }
    
    private func showGhostHint() {
        guard let ghost = ghostHint, ghost.hasActions() == false else { return }
        let pos = CGPoint(x: vesper.position.x + 80, y: vesper.position.y - 20)
        ghost.position = pos
        ghost.alpha = 0.0
        ghost.run(.repeatForever(.sequence([
            .group([.fadeAlpha(to: 0.6, duration: 0.4), .scale(to: 1.2, duration: 0.4)]),
            .group([.fadeAlpha(to: 0.0, duration: 0.4), .scale(to: 1.0, duration: 0.4)]),
            .wait(forDuration: 0.4)
        ])))
    }
    
    override func update(deltaTime: TimeInterval) {
        // Reset particle emissions counter each frame
        particlePool.resetFrameCounter()
        
        currentDeltaTime = deltaTime
        let dt = CGFloat(deltaTime)
        
        vesper.tick(dt: dt)
        vesper.render(in: self)
        generateWind(dt: dt)
        
        // inactivity → show ghost hint
        inactivityTimer += TimeInterval(dt)
        if inactivityTimer > 8.0 {
            showGhostHint()
        }
        
        // Flow barriers auto-open at 100% flow
        for fb in flowBarriers { fb.update(flow: GameManager.shared.flow) }
        
        // Portal occupancy
        vesperPortal?.updateOccupancy(entityPosition: vesper.position)
        GameManager.shared.setVesperExit(vesperPortal?.occupied ?? false)
    }
    
    private func generateWind(dt: CGFloat) {
        let v = vesper.speedEstimate
        let speedPct = min(1.0, v / 8.0)
        windAccumulator = max(0, min(1, windAccumulator + (speedPct - windAccumulator) * 0.08))
        GameManager.shared.windPowerChanged(windAccumulator)
    }
    
    // Heat from Spark: intensities per linkIndex
    func receiveHeatMap(_ intensities: [Int: CGFloat]) {
        for (idx, wall) in iceWalls {
            let intensity = intensities[idx] ?? 0
            wall.applyHeat(intensity: intensity, deltaTime: currentDeltaTime)
        }
    }
    func receiveHeat(intensity: CGFloat) {
        // Legacy single-wall support
        for (_, wall) in iceWalls {
            wall.applyHeat(intensity: intensity, deltaTime: currentDeltaTime)
        }
    }
    
    // Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        inactivityTimer = 0
        ghostHint?.removeAllActions()
        ghostHint?.alpha = 0
        guard let t = touches.first else { return }
        let location = t.location(in: self)
        vesper.setFlowTarget(location.x, location.y)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        inactivityTimer = 0
        guard let t = touches.first else { return }
        let location = t.location(in: self)
        vesper.setFlowTarget(location.x, location.y)
    }
    
    // FX
    func flashWin() {
        let flash = SKSpriteNode(color: .white, size: size)
        flash.alpha = 0; flash.zPosition = 1000; flash.anchorPoint = .zero; addChild(flash)
        flash.run(.sequence([.fadeAlpha(to: 0.5, duration: 0.12), .fadeOut(withDuration: 0.25), .removeFromParent()]))
    }
}

private extension VesperNode {
    var speedEstimate: CGFloat {
        let last = (userData?["lp"] as? NSValue)?.cgPointValue ?? position
        let dx = position.x - last.x, dy = position.y - last.y
        let s = sqrt(dx*dx + dy*dy)
        if userData == nil { userData = [:] }
        userData?["lp"] = NSValue(cgPoint: position)
        return s
    }
}