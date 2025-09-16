import SpriteKit

final class SparkScene: BaseScene {
    private let spark = SparkNode()
    private var lastTime: TimeInterval = 0
    private var windPower: CGFloat = 0.0
    
    // Authored objects
    private var windmills: [WindmillNode] = []
    private var bridges: [BridgeNode] = []
    private var heatPlates: [HeatPlateNode] = []
    private var surgeBarriers: [SurgeBarrierNode] = []
    private var sparkPortal: ExitPortalNode?
    
    // Beauty enhancements
    private var sparkTrail: SKEmitterNode?
    private var parallax: [SKSpriteNode] = []
    private var microPanTarget = CGPoint.zero
    private var cameraNode: SKCameraNode?
    
    override func didMove(to view: SKView) {
        GameManager.shared.sparkScene = self
        backgroundColor = SKColor(red: 0.09, green: 0.07, blue: 0.12, alpha: 1)
        addChild(spark)
        isUserInteractionEnabled = true
        
        // Setup camera for micro-pan
        let cam = SKCameraNode()
        self.camera = cam
        addChild(cam)
        cameraNode = cam
        
        // Add trail to Spark
        sparkTrail = particlePool.makeTrailNode(baseColor: .systemYellow)
        spark.addChild(sparkTrail!)
        sparkTrail!.targetNode = self
    }
    
    func apply(level: LevelData) {
        removeAllChildren()
        addChild(spark)
        parallax.removeAll()
        
        // Re-add camera
        if let cam = cameraNode {
            addChild(cam)
        }
        
        // Parallax layers
        for i in 0..<2 {
            let layer = SKSpriteNode(color: SKColor(red: 0.12+CGFloat(i)*0.03, green: 0.08, blue: 0.16+CGFloat(i)*0.03, alpha: 1),
                                     size: CGSize(width: size.width * 1.2, height: size.height * 1.2))
            layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            layer.position = CGPoint(x: size.width/2, y: size.height/2)
            layer.zPosition = -10 - CGFloat(i)
            addChild(layer)
            parallax.append(layer)
        }
        
        // Reset containers
        windmills.removeAll(); bridges.removeAll(); heatPlates.removeAll(); surgeBarriers.removeAll(); sparkPortal = nil
        
        // Place Spark
        spark.position = level.sparkStart
        
        // Build authored nodes
        for w in level.windmills {
            let node = WindmillNode(position: w.position, linkIndex: w.linkIndex)
            addChild(node); windmills.append(node)
        }
        for b in level.bridges {
            let node = BridgeNode(origin: b.origin, maxWidth: b.maxWidth, linkIndex: b.linkIndex)
            addChild(node); bridges.append(node)
        }
        for h in level.heatPlates {
            let node = HeatPlateNode(position: h.position, radius: h.radius, linkIndex: h.linkIndex)
            addChild(node); heatPlates.append(node)
        }
        for s in level.surgeBarriers {
            let node = SurgeBarrierNode(position: s.position, size: s.size)
            addChild(node); surgeBarriers.append(node)
        }
        let portal = ExitPortalNode(position: level.sparkPortal.position, radius: level.sparkPortal.radius, color: .systemYellow)
        addChild(portal); sparkPortal = portal
        
        // Add visual hints for Level 0
        if level.index == 0 {
            // Arrow pointing to portal
            let arrow = SKLabelNode(text: "→")
            arrow.fontSize = 40
            arrow.fontName = "Arial-BoldMT"
            arrow.fontColor = .systemYellow
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
        
        // Re-add trail
        if sparkTrail == nil {
            sparkTrail = particlePool.makeTrailNode(baseColor: .systemYellow)
            spark.addChild(sparkTrail!)
            sparkTrail!.targetNode = self
        }
    }
    
    override func update(deltaTime: TimeInterval) {
        // Reset particle emissions counter each frame
        particlePool.resetFrameCounter()
        
        let dt = CGFloat(deltaTime)
        
        spark.tick(dt: dt)
        spark.render(in: self)
        updateParallax(dt: dt)
        updateMicroPan(dt: dt)
        
        // Windmills + bridges
        for wm in windmills {
            wm.setActive(windPower > 0.3)
            wm.tick(dt: dt)
        }
        for br in bridges {
            let pct = windPower // simple: one pool
            br.setTarget(percent: pct, dt: dt)
            
            // Micro-pan toward bridge when extending
            if windPower > 0.3 {
                microPanTarget = CGPoint(x: br.position.x, y: br.position.y)
            }
        }
        
        // Heat plates → send heat map to Vesper via linkIndex
        var heatDict: [Int: CGFloat] = [:]
        for hp in heatPlates {
            let active = hp.isActive(sparkPosition: spark.position)
            if active { heatDict[hp.linkIndex, default: 0] = 1.0 }
        }
        GameManager.shared.heatPlateIntensity(heatDict)
        
        // Surge barrier break
        for sb in surgeBarriers { sb.tryBreak(surge: GameManager.shared.surge) }
        
        // Portal occupancy
        sparkPortal?.updateOccupancy(entityPosition: spark.position)
        GameManager.shared.setSparkExit(sparkPortal?.occupied ?? false)
        
        // Proximity calc (share positions)
        if let vp = GameManager.shared.vesperScene?.vesperPosition {
            GameManager.shared.updateProximity(spark: spark.position, vesper: vp, maxRange: 150)
        }
        
        // Modulate trail by speed
        if let trail = sparkTrail {
            let speed = hypot(spark.physicsBody?.velocity.dx ?? 0, spark.physicsBody?.velocity.dy ?? 0)
            trail.particleBirthRate = min(150, 30 + speed * 2)
        }
    }
    
    private func updateParallax(dt: CGFloat) {
        // Parallax: subtle drift with Spark
        for (i, layer) in parallax.enumerated() {
            let f = CGFloat(0.02 + 0.02*CGFloat(i))
            layer.position = CGPoint(
                x: size.width/2 - spark.position.x * f,
                y: size.height/2 - spark.position.y * f
            )
        }
    }
    
    private func updateMicroPan(dt: CGFloat) {
        // Micro-pan toward cross-world changes
        let offset = CGPoint(
            x: (microPanTarget.x - size.width*0.5) * 0.02,
            y: (microPanTarget.y - size.height*0.5) * 0.02
        )
        
        // Smooth interpolation
        if let cam = cameraNode {
            let currentX = cam.position.x
            let currentY = cam.position.y
            cam.position.x = currentX + (offset.x - currentX) * min(1.0, dt * 3.0)
            cam.position.y = currentY + (offset.y - currentY) * min(1.0, dt * 3.0)
        }
    }
    
    // Cross-world input
    func receiveWindPower(_ pct: CGFloat) { windPower = max(0, min(1, pct)) }
    
    // Touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        spark.beginDrag(at: t.location(in: self))
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let t = touches.first else { return }
        spark.drag(to: t.location(in: self))
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) { spark.endDrag() }
    
    // FX
    func flashWin() {
        let flash = SKSpriteNode(color: .white, size: size)
        flash.alpha = 0; flash.zPosition = 1000; flash.anchorPoint = .zero; addChild(flash)
        flash.run(.sequence([.fadeAlpha(to: 0.5, duration: 0.12), .fadeOut(withDuration: 0.25), .removeFromParent()]))
    }
}