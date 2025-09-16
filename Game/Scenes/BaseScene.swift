import SpriteKit

class BaseScene: SKScene {
    var timeDilation: CGFloat = 1.0
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0
    
    // Particle pool shared per scene
    let particlePool = ParticlePool()
    
    // High-DPI support
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configureScene()
    }
    
    private func configureScene() {
        // Set proper scaling mode for high-DPI displays
        scaleMode = .resizeFill
        
        // Enable antialiasing for smoother rendering
        if let view = self.view {
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            
            // Multi-sampling for better quality on retina displays
            view.preferredFramesPerSecond = 60
            view.shouldCullNonVisibleNodes = true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Calculate proper delta time with time dilation
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        
        deltaTime = min(currentTime - lastUpdateTime, 0.05) * timeDilation
        lastUpdateTime = currentTime
        
        // Call subclass update with delta
        update(deltaTime: deltaTime)
    }
    
    // Subclasses override this instead
    func update(deltaTime: TimeInterval) {
        // Override in subclasses
    }
    
    func setTimeDilation(_ v: CGFloat) { 
        timeDilation = max(0.1, min(2.0, v))
    }
    
    // Helper for RGBA colors
    func rgba(_ hex: String, _ alpha: CGFloat) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}