import SpriteKit
import UIKit

enum ParticleTex {
    static func square(size: Int = 8, color: UIColor = .white) -> SKTexture {
        let imageSize = CGSize(width: size, height: size)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return SKTexture()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return SKTexture()
        }
        
        return SKTexture(image: image)
    }
    
    static func softCircle(diameter: Int = 32, color: UIColor = .white) -> SKTexture {
        let imageSize = CGSize(width: diameter, height: diameter)
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return SKTexture()
        }
        
        let center = CGPoint(x: CGFloat(diameter) / 2, y: CGFloat(diameter) / 2)
        let radius = CGFloat(diameter) / 2
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            color.withAlphaComponent(0.8).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ] as CFArray
        let locations: [CGFloat] = [0, 1]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) else {
            return SKTexture()
        }
        
        context.drawRadialGradient(
            gradient,
            startCenter: center,
            startRadius: 0,
            endCenter: center,
            endRadius: radius,
            options: .drawsAfterEndLocation
        )
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return SKTexture()
        }
        
        return SKTexture(image: image)
    }
}