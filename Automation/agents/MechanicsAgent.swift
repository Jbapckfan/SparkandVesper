import Foundation

// MARK: - Gameplay Mechanics & Level Design Agent
// Produces real level JSON patches that are winnable, readable, and fun

class MechanicsAgent {
    
    struct LevelPatch: Codable {
        let levelId: String
        let operations: [PatchOperation]
        let timestamp: Date
        let validator: ValidatorScript
        
        struct PatchOperation: Codable {
            enum OpType: String, Codable {
                case add, remove, replace, move
            }
            let op: OpType
            let path: String
            let value: Any?
            
            enum CodingKeys: String, CodingKey {
                case op, path, value
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(op, forKey: .op)
                try container.encode(path, forKey: .path)
                if let value = value as? Encodable {
                    try container.encode(value, forKey: .value)
                }
            }
        }
    }
    
    struct ValidatorScript: Codable {
        let inputs: [TimedInput]
        let expectedOutcome: Outcome
        let maxTime: Int // seconds
        
        struct TimedInput: Codable {
            let time: Double // seconds from start
            let action: String // "drag", "tap", "hold"
            let target: String // "spark", "vesper"
            let position: CGPoint?
        }
        
        struct Outcome: Codable {
            let sparkAtPortal: Bool
            let vesperAtPortal: Bool
            let time: Double
            let surgeUsed: Bool
            let flowUsed: Bool
        }
    }
    
    struct Routes: Codable {
        let intended: Route
        let mastery: Route
        let accessibility: Route?
        
        struct Route: Codable {
            let description: String
            let keyTimings: [String: Double]
            let difficulty: Int // 1-5
            let requiredMechanics: [String]
        }
    }
    
    // MARK: - Core Analysis
    
    func analyzeLevel(_ levelData: Data) -> (issues: [String], improvements: [String]) {
        var issues: [String] = []
        var improvements: [String] = []
        
        // Parse level (simplified for example)
        guard let level = try? JSONDecoder().decode(LevelData.self, from: levelData) else {
            return (["Failed to parse level"], [])
        }
        
        // Check teaching progression
        let mechanics = countMechanics(level)
        if mechanics.new > 1 {
            issues.append("Too many new mechanics introduced at once")
            improvements.append("Introduce one mechanic in first 20s, then combine")
        }
        
        // Check difficulty spike
        if level.surgeBarriers.count + level.flowBarriers.count > 2 && level.index < 5 {
            issues.append("Difficulty spike too early")
            improvements.append("Move barriers to later levels or reduce count")
        }
        
        // Check clear time
        let estimatedTime = estimateClearTime(level)
        if estimatedTime > 120 {
            issues.append("Level too long (\(estimatedTime)s estimated)")
            improvements.append("Split into two levels or add checkpoint")
        }
        
        // Check "aha" moments
        if !hasVisiblePayoff(level) {
            improvements.append("Add visible 'aha' payoff at 45-60s mark")
        }
        
        return (issues, improvements)
    }
    
    // MARK: - Patch Generation
    
    func generatePatch(for level: LevelData, issues: [String]) -> LevelPatch {
        var operations: [LevelPatch.PatchOperation] = []
        
        // Fix touch targets
        if level.heatPlates.first?.radius ?? 0 < 35 {
            operations.append(LevelPatch.PatchOperation(
                op: .replace,
                path: "/heatPlates/0/radius",
                value: 35
            ))
        }
        
        // Add checkpoint if too long
        if estimateClearTime(level) > 90 {
            operations.append(LevelPatch.PatchOperation(
                op: .add,
                path: "/tuning/checkpoints/0",
                value: ["x": 200, "y": 150]
            ))
        }
        
        // Generate validator script
        let validator = generateValidatorScript(for: level)
        
        return LevelPatch(
            levelId: "Level\(String(format: "%02d", level.index))",
            operations: operations,
            timestamp: Date(),
            validator: validator
        )
    }
    
    // MARK: - Validator Script Generation
    
    func generateValidatorScript(for level: LevelData) -> ValidatorScript {
        var inputs: [ValidatorScript.TimedInput] = []
        
        // Basic path for Level 0
        if level.index == 0 {
            // Move Vesper to generate wind
            inputs.append(ValidatorScript.TimedInput(
                time: 1.0,
                action: "tap",
                target: "vesper",
                position: CGPoint(x: 200, y: 100)
            ))
            
            // Drag Spark to heat plate
            inputs.append(ValidatorScript.TimedInput(
                time: 3.0,
                action: "drag",
                target: "spark",
                position: level.heatPlates.first?.position
            ))
            
            // Move both to portals
            inputs.append(ValidatorScript.TimedInput(
                time: 5.0,
                action: "tap",
                target: "vesper",
                position: level.vesperPortal.position
            ))
            
            inputs.append(ValidatorScript.TimedInput(
                time: 6.0,
                action: "drag",
                target: "spark",
                position: level.sparkPortal.position
            ))
        }
        
        return ValidatorScript(
            inputs: inputs,
            expectedOutcome: ValidatorScript.Outcome(
                sparkAtPortal: true,
                vesperAtPortal: true,
                time: 8.0,
                surgeUsed: false,
                flowUsed: false
            ),
            maxTime: 120
        )
    }
    
    // MARK: - Route Planning
    
    func generateRoutes(for level: LevelData) -> Routes {
        let intended = Routes.Route(
            description: "Standard path using all mechanics as taught",
            keyTimings: [
                "windmill_active": 2.0,
                "bridge_extended": 4.0,
                "ice_melted": 6.0,
                "portals_reached": 8.0
            ],
            difficulty: 2,
            requiredMechanics: ["wind", "heat"]
        )
        
        let mastery = Routes.Route(
            description: "Speed route using proximity boost",
            keyTimings: [
                "proximity_tear": 1.5,
                "simultaneous_solve": 3.0,
                "portals_reached": 4.5
            ],
            difficulty: 4,
            requiredMechanics: ["wind", "heat", "proximity"]
        )
        
        return Routes(
            intended: intended,
            mastery: mastery,
            accessibility: nil
        )
    }
    
    // MARK: - Helper Methods
    
    private func countMechanics(_ level: LevelData) -> (total: Int, new: Int) {
        let total = (level.windmills.isEmpty ? 0 : 1) +
                   (level.heatPlates.isEmpty ? 0 : 1) +
                   (level.surgeBarriers.isEmpty ? 0 : 1) +
                   (level.flowBarriers.isEmpty ? 0 : 1)
        
        // Simplified: assume new if it's the first appearance
        let new = level.index == 0 ? min(total, 1) : 0
        
        return (total, new)
    }
    
    private func estimateClearTime(_ level: LevelData) -> Int {
        var time = 10 // Base movement time
        
        // Add time for each mechanic
        time += level.windmills.count * 5
        time += level.heatPlates.count * 5
        time += level.iceWalls.count * 8
        time += level.surgeBarriers.count * 10
        time += level.flowBarriers.count * 10
        
        // Add distance factor
        let distance = abs(level.sparkPortal.position.x - level.sparkStart.x)
        time += Int(distance / 10)
        
        return time
    }
    
    private func hasVisiblePayoff(_ level: LevelData) -> Bool {
        // Check for dramatic moments
        return !level.iceWalls.isEmpty || // Ice melting is visible
               !level.bridges.isEmpty ||   // Bridge extending is visible
               !level.surgeBarriers.isEmpty // Barrier breaking is visible
    }
    
    // MARK: - Export
    
    func exportPatch(_ patch: LevelPatch, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(patch)
        try data.write(to: url)
    }
}