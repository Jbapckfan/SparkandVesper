import Foundation
import CoreGraphics
import QuartzCore

final class GameManager: ObservableObject {
    static let shared = GameManager()
    private init() {}
    
    // HUD state
    @Published var surge: CGFloat = 0.0
    @Published var flow: CGFloat = 0.0
    @Published var proximityStrength: CGFloat = 0.0
    @Published var levelTitle: String = "Level 1 – First Light"
    @Published var timerString: String = "00:00"
    
    // Smooth HUD values for lerping
    private var targetSurge: CGFloat = 0.0
    private var targetFlow: CGFloat = 0.0
    
    // Exit occupancy
    private var sparkAtExit = false
    private var vesperAtExit = false
    private var lastProximityTear = false
    
    // Scene hooks
    weak var sparkScene: SparkScene?
    weak var vesperScene: VesperScene?
    
    // Timer with proper timing
    private var startTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0
    private var gameTime: TimeInterval = 0
    private var timer: Timer?
    
    func startSession() {
        startTime = CACurrentMediaTime()
        lastUpdateTime = startTime
        gameTime = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            self?.updateTiming()
        }
        LevelManager.shared.loadCurrentLevel()
    }
    
    private func updateTiming() {
        let currentTime = CACurrentMediaTime()
        let dt = min(currentTime - lastUpdateTime, 0.05) // Cap at 50ms
        lastUpdateTime = currentTime
        gameTime += dt
        
        // Update timer display
        let t = Int(gameTime)
        timerString = String(format: "%02d:%02d", t/60, t%60)
        
        // Smooth lerp HUD values
        surge = lerp(surge, targetSurge, 0.12)
        flow = lerp(flow, targetFlow, 0.12)
    }
    
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
    func endSession() { timer?.invalidate() }
    
    func resetForNewLevel() {
        surge = 0; flow = 0; proximityStrength = 0
        sparkAtExit = false; vesperAtExit = false
    }
    
    // Mechanics bus with clamping
    func updateSurge(_ v: CGFloat)   { targetSurge = clamp01(v) }
    func updateFlow(_ v: CGFloat)    { targetFlow = clamp01(v) }
    
    private func clamp01(_ v: CGFloat) -> CGFloat {
        return max(0, min(1, v))
    }
    
    func updateProximity(spark: CGPoint, vesper: CGPoint, maxRange: CGFloat) {
        // Normalize positions to screen-independent coordinates
        let sparkNorm = normalizePosition(spark, in: sparkScene)
        let vesperNorm = normalizePosition(vesper, in: vesperScene)
        
        let dx = sparkNorm.x - vesperNorm.x
        let dy = sparkNorm.y - vesperNorm.y
        let dist = sqrt(dx*dx + dy*dy)
        let s = clamp01(1 - (dist / 0.25)) // 25% normalized threshold
        proximityStrength = CGFloat(s)
        let tear = s > 0.9
        sparkScene?.setTimeDilation(tear ? 0.5 : 1.0)
        vesperScene?.setTimeDilation(tear ? 0.5 : 1.0)
        
        // Haptic for proximity tear
        if tear && !lastProximityTear {
            Haptics.proximityTear()
        }
        lastProximityTear = tear
    }
    
    private func normalizePosition(_ point: CGPoint, in scene: BaseScene?) -> CGPoint {
        guard let scene = scene else { return point }
        let size = scene.size
        return CGPoint(x: point.x / size.width, y: point.y / size.height)
    }
    
    // Cross-world inputs
    func windPowerChanged(_ pct: CGFloat)    { sparkScene?.receiveWindPower(pct) }
    func heatPlateIntensity(_ dict: [Int: CGFloat]) { vesperScene?.receiveHeatMap(dict) }
    
    // Portals
    func setSparkExit(_ atExit: Bool)  { sparkAtExit = atExit; checkWin() }
    func setVesperExit(_ atExit: Bool) { vesperAtExit = atExit; checkWin() }
    
    private func checkWin() {
        if sparkAtExit && vesperAtExit {
            Haptics.win()
            sparkScene?.flashWin()
            vesperScene?.flashWin()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                LevelManager.shared.completeLevel()
            }
        }
    }
}