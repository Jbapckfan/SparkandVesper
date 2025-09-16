import Foundation
import XCTest
import MetricKit

// MARK: - Performance Agent
// Catches frame drops before players do

class PerformanceAgent {
    
    struct PerformanceReport: Codable {
        let timestamp: Date
        let device: DeviceProfile
        let levels: [LevelMetrics]
        let summary: Summary
        let patches: [OptimizationPatch]
        
        struct DeviceProfile: Codable {
            let model: String
            let os: String
            let gpu: String
            let memory: Int // MB
            let tier: DeviceTier
            
            enum DeviceTier: String, Codable {
                case low    // iPhone 8, iPad 6th gen
                case medium // iPhone 11, iPad Air 3
                case high   // iPhone 13+, iPad Pro
            }
        }
        
        struct LevelMetrics: Codable {
            let levelId: String
            let fps: FPSMetrics
            let memory: MemoryMetrics
            let battery: BatteryMetrics
            let hotspots: [PerformanceHotspot]
            
            struct FPSMetrics: Codable {
                let p50: Double
                let p99: Double
                let p1: Double  // 1st percentile (worst)
                let drops: Int  // Count of frames < 30fps
                let hangs: Int  // Frames > 100ms
            }
            
            struct MemoryMetrics: Codable {
                let peak: Int     // MB
                let average: Int  // MB
                let leaks: Int    // Count
            }
            
            struct BatteryMetrics: Codable {
                let drainRate: Double // %/minute
                let cpuUsage: Double  // %
                let gpuUsage: Double  // %
            }
            
            struct PerformanceHotspot: Codable {
                let location: String  // "WindmillUpdate", "ParticleSystem", etc
                let timeMs: Double
                let frequency: Int   // Calls per frame
                let suggestion: String
            }
        }
        
        struct Summary: Codable {
            let passRate: Double      // % of levels meeting targets
            let criticalIssues: Int
            let deviceCoverage: Double // % of device tiers tested
            let recommendation: Recommendation
            
            enum Recommendation: String, Codable {
                case ship = "Ready to ship"
                case optimize = "Optimize before ship"
                case critical = "Critical issues - do not ship"
            }
        }
        
        struct OptimizationPatch: Codable {
            let target: String  // File or system to patch
            let change: String  // What to change
            let impact: String  // Expected improvement
            let risk: RiskLevel
            
            enum RiskLevel: String, Codable {
                case low    // Safe optimization
                case medium // May affect visuals
                case high   // Could break gameplay
            }
        }
    }
    
    struct FXBudget: Codable {
        let particlesPerFrame: Int
        let windEffectQuality: Quality
        let heatDistortionEnabled: Bool
        let proximityTearQuality: Quality
        let shadowResolution: Int
        let bloomEnabled: Bool
        
        enum Quality: String, Codable {
            case low, medium, high, ultra
        }
        
        static func for(tier: PerformanceReport.DeviceProfile.DeviceTier) -> FXBudget {
            switch tier {
            case .low:
                return FXBudget(
                    particlesPerFrame: 50,
                    windEffectQuality: .low,
                    heatDistortionEnabled: false,
                    proximityTearQuality: .low,
                    shadowResolution: 128,
                    bloomEnabled: false
                )
            case .medium:
                return FXBudget(
                    particlesPerFrame: 100,
                    windEffectQuality: .medium,
                    heatDistortionEnabled: true,
                    proximityTearQuality: .medium,
                    shadowResolution: 256,
                    bloomEnabled: true
                )
            case .high:
                return FXBudget(
                    particlesPerFrame: 200,
                    windEffectQuality: .high,
                    heatDistortionEnabled: true,
                    proximityTearQuality: .high,
                    shadowResolution: 512,
                    bloomEnabled: true
                )
            }
        }
    }
    
    // MARK: - Performance Testing
    
    func runPerformanceTest(device: String, levels: [String]) -> PerformanceReport {
        let deviceProfile = getDeviceProfile(device)
        var levelMetrics: [PerformanceReport.LevelMetrics] = []
        
        for levelId in levels {
            let metrics = measureLevel(levelId, on: deviceProfile)
            levelMetrics.append(metrics)
        }
        
        let summary = generateSummary(levelMetrics, device: deviceProfile)
        let patches = generateOptimizations(levelMetrics, device: deviceProfile)
        
        return PerformanceReport(
            timestamp: Date(),
            device: deviceProfile,
            levels: levelMetrics,
            summary: summary,
            patches: patches
        )
    }
    
    // MARK: - Level Measurement
    
    private func measureLevel(_ levelId: String, on device: PerformanceReport.DeviceProfile) -> PerformanceReport.LevelMetrics {
        // Simulate performance measurement
        let frameTimeMs = simulateFrameTimes(levelId, device: device)
        let fps = calculateFPSMetrics(frameTimeMs)
        let memory = measureMemory(levelId)
        let battery = measureBattery(levelId)
        let hotspots = findHotspots(levelId, frameTimes: frameTimeMs)
        
        return PerformanceReport.LevelMetrics(
            levelId: levelId,
            fps: fps,
            memory: memory,
            battery: battery,
            hotspots: hotspots
        )
    }
    
    private func simulateFrameTimes(_ levelId: String, device: PerformanceReport.DeviceProfile) -> [Double] {
        // Generate realistic frame times based on device tier
        var frameTimes: [Double] = []
        let baseTime: Double = device.tier == .low ? 18.0 : 16.0
        
        for _ in 0..<1800 { // 30 seconds at 60fps
            var time = baseTime
            
            // Add noise
            time += Double.random(in: -2...2)
            
            // Occasional spikes
            if Int.random(in: 0..<100) < 5 {
                time += Double.random(in: 10...50)
            }
            
            // Device-specific adjustments
            if device.tier == .low {
                time *= 1.2
            }
            
            frameTimes.append(time)
        }
        
        return frameTimes
    }
    
    private func calculateFPSMetrics(_ frameTimes: [Double]) -> PerformanceReport.LevelMetrics.FPSMetrics {
        let fps = frameTimes.map { 1000.0 / $0 }
        let sorted = fps.sorted()
        
        let p1Index = Int(Double(sorted.count) * 0.01)
        let p50Index = sorted.count / 2
        let p99Index = Int(Double(sorted.count) * 0.99)
        
        let drops = frameTimes.filter { $0 > 33.33 }.count // < 30fps
        let hangs = frameTimes.filter { $0 > 100 }.count
        
        return PerformanceReport.LevelMetrics.FPSMetrics(
            p50: sorted[p50Index],
            p99: sorted[p99Index],
            p1: sorted[p1Index],
            drops: drops,
            hangs: hangs
        )
    }
    
    private func measureMemory(_ levelId: String) -> PerformanceReport.LevelMetrics.MemoryMetrics {
        // Simulate memory measurement
        let baseMemory = 150 // MB
        let variance = Int.random(in: -20...50)
        
        return PerformanceReport.LevelMetrics.MemoryMetrics(
            peak: baseMemory + variance + 30,
            average: baseMemory + variance,
            leaks: Int.random(in: 0...2)
        )
    }
    
    private func measureBattery(_ levelId: String) -> PerformanceReport.LevelMetrics.BatteryMetrics {
        return PerformanceReport.LevelMetrics.BatteryMetrics(
            drainRate: Double.random(in: 0.3...0.8),
            cpuUsage: Double.random(in: 15...35),
            gpuUsage: Double.random(in: 40...70)
        )
    }
    
    private func findHotspots(_ levelId: String, frameTimes: [Double]) -> [PerformanceReport.LevelMetrics.PerformanceHotspot] {
        var hotspots: [PerformanceReport.LevelMetrics.PerformanceHotspot] = []
        
        // Analyze common performance bottlenecks
        if frameTimes.filter({ $0 > 20 }).count > 100 {
            hotspots.append(PerformanceReport.LevelMetrics.PerformanceHotspot(
                location: "WindmillNode.update()",
                timeMs: 8.5,
                frequency: 60,
                suggestion: "Cache wind velocity calculations"
            ))
        }
        
        if levelId.contains("3") || levelId.contains("4") {
            hotspots.append(PerformanceReport.LevelMetrics.PerformanceHotspot(
                location: "ProximityTear.render()",
                timeMs: 12.0,
                frequency: 60,
                suggestion: "Reduce tear particle count on low-end devices"
            ))
        }
        
        return hotspots
    }
    
    // MARK: - Device Profiles
    
    private func getDeviceProfile(_ device: String) -> PerformanceReport.DeviceProfile {
        let profiles: [String: PerformanceReport.DeviceProfile] = [
            "iPhone8": PerformanceReport.DeviceProfile(
                model: "iPhone 8",
                os: "iOS 16.0",
                gpu: "A11 Bionic",
                memory: 2048,
                tier: .low
            ),
            "iPhone12": PerformanceReport.DeviceProfile(
                model: "iPhone 12",
                os: "iOS 17.0",
                gpu: "A14 Bionic",
                memory: 4096,
                tier: .medium
            ),
            "iPhone14Pro": PerformanceReport.DeviceProfile(
                model: "iPhone 14 Pro",
                os: "iOS 17.0",
                gpu: "A16 Bionic",
                memory: 6144,
                tier: .high
            ),
            "iPadAir4": PerformanceReport.DeviceProfile(
                model: "iPad Air 4",
                os: "iPadOS 17.0",
                gpu: "A14 Bionic",
                memory: 4096,
                tier: .medium
            )
        ]
        
        return profiles[device] ?? profiles["iPhone12"]!
    }
    
    // MARK: - Summary Generation
    
    private func generateSummary(
        _ metrics: [PerformanceReport.LevelMetrics],
        device: PerformanceReport.DeviceProfile
    ) -> PerformanceReport.Summary {
        // Check if levels meet performance targets
        let targetFPS: Double = device.tier == .low ? 30 : 60
        let passingLevels = metrics.filter { $0.fps.p50 >= targetFPS - 2 }
        let passRate = Double(passingLevels.count) / Double(max(metrics.count, 1))
        
        // Count critical issues
        let criticalIssues = metrics.reduce(0) { count, level in
            count + (level.fps.hangs > 10 ? 1 : 0) + (level.memory.leaks > 0 ? 1 : 0)
        }
        
        // Determine recommendation
        let recommendation: PerformanceReport.Summary.Recommendation
        if criticalIssues > 0 {
            recommendation = .critical
        } else if passRate < 0.9 {
            recommendation = .optimize
        } else {
            recommendation = .ship
        }
        
        return PerformanceReport.Summary(
            passRate: passRate,
            criticalIssues: criticalIssues,
            deviceCoverage: 1.0, // Assuming single device for now
            recommendation: recommendation
        )
    }
    
    // MARK: - Optimization Generation
    
    private func generateOptimizations(
        _ metrics: [PerformanceReport.LevelMetrics],
        device: PerformanceReport.DeviceProfile
    ) -> [PerformanceReport.OptimizationPatch] {
        var patches: [PerformanceReport.OptimizationPatch] = []
        
        // Check for consistent hotspots
        let allHotspots = metrics.flatMap { $0.hotspots }
        let windmillIssues = allHotspots.filter { $0.location.contains("Windmill") }
        
        if windmillIssues.count > 2 {
            patches.append(PerformanceReport.OptimizationPatch(
                target: "Game/Entities/WindmillNode.swift",
                change: "Cache wind velocity calculations, update every 3 frames instead of every frame",
                impact: "~15% performance improvement on wind levels",
                risk: .low
            ))
        }
        
        // Check for memory issues
        let avgMemory = metrics.map { $0.memory.average }.reduce(0, +) / metrics.count
        if avgMemory > 200 {
            patches.append(PerformanceReport.OptimizationPatch(
                target: "Game/Systems/ParticleManager.swift",
                change: "Implement particle pooling to reduce allocations",
                impact: "Reduce memory by ~30MB",
                risk: .medium
            ))
        }
        
        // Device-specific optimizations
        if device.tier == .low {
            patches.append(PerformanceReport.OptimizationPatch(
                target: "Game/Systems/FXManager.swift",
                change: "Apply low-tier FX budget automatically",
                impact: "Maintain 30fps on older devices",
                risk: .low
            ))
        }
        
        return patches
    }
    
    // MARK: - CSV Export
    
    func exportCSV(_ report: PerformanceReport, to url: URL) throws {
        var csv = "Level,Device,FPS_P50,FPS_P1,Drops,Memory_Peak,Battery_Drain\n"
        
        for level in report.levels {
            csv += "\(level.levelId),"
            csv += "\(report.device.model),"
            csv += "\(String(format: "%.1f", level.fps.p50)),"
            csv += "\(String(format: "%.1f", level.fps.p1)),"
            csv += "\(level.fps.drops),"
            csv += "\(level.memory.peak),"
            csv += "\(String(format: "%.2f", level.battery.drainRate))\n"
        }
        
        try csv.write(to: url, atomically: true, encoding: .utf8)
    }
    
    // MARK: - FX Budget Export
    
    func exportFXBudget(_ budget: FXBudget, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(budget)
        try data.write(to: url)
    }
}