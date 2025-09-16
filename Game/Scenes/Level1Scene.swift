import SpriteKit

final class Level1Scene: SKScene {
    
    private var bgNode: SKSpriteNode!
    private var platformNodes: [SKSpriteNode] = []
    private var orbNode: SKShapeNode!
    private var seamNode: SKSpriteNode!
    private var startTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.06, green: 0.07, blue: 0.1, alpha: 1.0)
        
        // Ensure we have a valid size
        let sceneSize = size.width > 0 && size.height > 0 ? size : view.bounds.size
        
        // Background gradient
        bgNode = SKSpriteNode(color: .clear, size: sceneSize)
        bgNode.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        
        // Create gradient programmatically using UIGraphicsImageRenderer
        if sceneSize.width > 0 && sceneSize.height > 0 {
            let renderer = UIGraphicsImageRenderer(size: sceneSize)
            let gradientImage = renderer.image { context in
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = CGRect(origin: .zero, size: sceneSize)
                gradientLayer.colors = [
                    UIColor(red: 0.22, green: 0.09, blue: 0.03, alpha: 1.0).cgColor,
                    UIColor(red: 0.08, green: 0.10, blue: 0.18, alpha: 1.0).cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
                gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
                gradientLayer.render(in: context.cgContext)
            }
            bgNode.texture = SKTexture(image: gradientImage)
        } else {
            // Fallback to solid color if size is invalid
            bgNode.color = SKColor(red: 0.15, green: 0.10, blue: 0.10, alpha: 1.0)
        }
        
        addChild(bgNode)
        
        // Platforms
        let platformColors = [
            UIColor(red: 0.16, green: 0.17, blue: 0.22, alpha: 1.0),
            UIColor(red: 0.19, green: 0.20, blue: 0.26, alpha: 1.0),
            UIColor(red: 0.22, green: 0.22, blue: 0.29, alpha: 1.0)
        ]
        
        let rects: [CGRect] = [
            CGRect(x: sceneSize.width*0.14, y: sceneSize.height*0.40, width: sceneSize.width*0.28, height: 18),
            CGRect(x: sceneSize.width*0.46, y: sceneSize.height*0.52, width: sceneSize.width*0.34, height: 20),
            CGRect(x: sceneSize.width*0.20, y: sceneSize.height*0.64, width: sceneSize.width*0.24, height: 16)
        ]
        
        for i in 0..<rects.count {
            let platform = SKSpriteNode(color: platformColors[i], size: CGSize(width: rects[i].width, height: rects[i].height))
            platform.position = CGPoint(x: rects[i].midX, y: rects[i].midY)
            platform.zPosition = 1
            platformNodes.append(platform)
            addChild(platform)
        }
        
        // Orb (using shape node for glow effect)
        orbNode = SKShapeNode(circleOfRadius: 30)
        orbNode.position = CGPoint(x: sceneSize.width*0.30, y: sceneSize.height*0.68)
        orbNode.fillColor = UIColor(red: 0.85, green: 0.62, blue: 0.25, alpha: 1.0)
        orbNode.strokeColor = UIColor(red: 0.85, green: 0.62, blue: 0.25, alpha: 0.5)
        orbNode.lineWidth = 8
        orbNode.glowWidth = 20
        orbNode.zPosition = 2
        addChild(orbNode)
        
        // Add pulse animation to orb
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 0.9, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        orbNode.run(SKAction.repeatForever(pulse))
        
        // Seam (dimensional veil)
        seamNode = SKSpriteNode(color: UIColor(red: 0.58, green: 0.42, blue: 1.0, alpha: 0.3), 
                                size: CGSize(width: 64, height: sceneSize.height*0.82))
        seamNode.position = CGPoint(x: sceneSize.width*0.66, y: sceneSize.height*0.54)
        seamNode.zPosition = 1.5
        addChild(seamNode)
        
        // Add shimmer effect
        let fadeIn = SKAction.fadeAlpha(to: 0.5, duration: 2.0)
        let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: 2.0)
        let shimmer = SKAction.sequence([fadeIn, fadeOut])
        seamNode.run(SKAction.repeatForever(shimmer))
        
        // Glyph clues
        addGlyph("why?", at: CGPoint(x: sceneSize.width*0.78, y: sceneSize.height*0.82), alpha: 0.14, size: 22)
        addGlyph("cold...", at: CGPoint(x: sceneSize.width*0.58, y: sceneSize.height*0.72), alpha: 0.12, size: 18)
        addGlyph("MISS", at: CGPoint(x: sceneSize.width*0.28, y: sceneSize.height*0.86), alpha: 0.10, size: 16)
        addGlyph("YOU", at: CGPoint(x: sceneSize.width*0.46, y: sceneSize.height*0.86), alpha: 0.10, size: 16)
        
        // Vignette overlay
        let vignette = SKSpriteNode(color: .clear, size: sceneSize)
        vignette.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        vignette.zPosition = 100
        
        // Create vignette texture using UIGraphicsImageRenderer
        if sceneSize.width > 0 && sceneSize.height > 0 {
            let renderer = UIGraphicsImageRenderer(size: sceneSize)
            let vignetteImage = renderer.image { context in
                let colors = [UIColor.clear.cgColor, UIColor(white: 0, alpha: 0.3).cgColor]
                let locations: [CGFloat] = [0.0, 1.0]
                if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), 
                                             colors: colors as CFArray, 
                                             locations: locations) {
                    let center = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
                    let radius = min(sceneSize.width, sceneSize.height) * 0.7
                    context.cgContext.drawRadialGradient(gradient, 
                                              startCenter: center, 
                                              startRadius: 0, 
                                              endCenter: center, 
                                              endRadius: radius, 
                                              options: .drawsAfterEndLocation)
                }
            }
            vignette.texture = SKTexture(image: vignetteImage)
        }
        
        addChild(vignette)
    }
    
    private func addGlyph(_ text: String, at pos: CGPoint, alpha: CGFloat, size: CGFloat) {
        let label = SKLabelNode(text: text)
        label.fontName = "Times"
        label.fontSize = size
        label.fontColor = UIColor(white: 1.0, alpha: alpha)
        label.position = pos
        label.zPosition = 0.8
        label.horizontalAlignmentMode = .center
        addChild(label)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if startTime == 0 { startTime = currentTime }
        let t = Float(currentTime - startTime)
        
        // Gentle sway for seam
        if let seamNode = seamNode {
            seamNode.position.x = size.width*0.66 + CGFloat(sin(t*0.27))*6
        }
    }
}