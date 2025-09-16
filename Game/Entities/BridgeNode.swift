import SpriteKit

final class BridgeNode: SKShapeNode {
    let linkIndex: Int
    private let origin: CGPoint
    private let maxWidth: CGFloat
    private var currentWidth: CGFloat = 0
    
    init(origin: CGPoint, maxWidth: CGFloat, linkIndex: Int) {
        self.origin = origin
        self.maxWidth = maxWidth
        self.linkIndex = linkIndex
        super.init()
        strokeColor = .clear
        fillColor = .brown
        alpha = 0.95
        zPosition = 1
        draw(width: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    
    func setTarget(percent: CGFloat, dt: CGFloat) {
        let target = (percent > 0.3) ? maxWidth : 0
        let prevWidth = currentWidth
        currentWidth += (target - currentWidth) * min(1.0, dt*6.0)
        
        // Haptic when crossing threshold
        if prevWidth < 10 && currentWidth >= 10 {
            Haptics.bridgeThreshold()
        }
        
        draw(width: currentWidth)
    }
    
    private func draw(width: CGFloat) {
        path = CGPath(rect: CGRect(x: origin.x, y: origin.y, width: width, height: 12), transform: nil)
    }
}