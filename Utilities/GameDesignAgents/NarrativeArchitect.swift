import Foundation

// MARK: - Narrative Architect Agent
// Analyzes story beats, emotional hooks, and wordless storytelling

class NarrativeArchitect {
    
    struct StoryBeats {
        var hook: Float = 0      // First 10 seconds
        var mystery: Float = 0   // What aren't you telling me?
        var payoff: Float = 0    // Was it worth my time?
    }
    
    struct NarrativeIssue {
        let fatal: Bool
        let location: String
        let fix: String
        let priority: Int
    }
    
    struct MicroNarrative {
        let environmental: String  // What the world tells
        let mechanical: String     // What the mechanics say
        let visual: String        // What the eyes see
        let emotional: String     // What the heart feels
        let wordCount: Int = 0   // ALWAYS zero
    }
    
    private var storyBeats = StoryBeats()
    
    // MARK: - Core Analysis
    
    func analyzeStoryBeat(levelIndex: Int, levelData: LevelData) -> [NarrativeIssue] {
        var issues: [NarrativeIssue] = []
        
        // The "Grandma Test" - can she explain it after playing?
        let conceptComplexity = calculateComplexity(levelData)
        if conceptComplexity > 3 {
            issues.append(NarrativeIssue(
                fatal: true,
                location: "Level \(levelIndex) concept",
                fix: "Spark/Vesper connection too abstract. Add ONE visual: when Spark touches heat, Vesper glows. Simple.",
                priority: 1
            ))
        }
        
        // The "Emotion-Per-Minute" metric
        if !hasEmotionalHooks(levelData) {
            issues.append(NarrativeIssue(
                fatal: true,
                location: "Level \(levelIndex) emotional arc",
                fix: "Level is just mechanics. Add: Spark's light flickers when Vesper struggles. Players FEEL the connection.",
                priority: 1
            ))
        }
        
        // The "30-Second Hook" rule
        if levelIndex == 0 && !hasImmediateHook(levelData) {
            issues.append(NarrativeIssue(
                fatal: true,
                location: "Level 0 opening",
                fix: "First 3 seconds must show consequence. Start with broken bridge, THEN show wind fixing it.",
                priority: 1
            ))
        }
        
        // The "Silent Tutorial" principle
        if levelIndex < 3 && requiresTextExplanation(levelData) {
            issues.append(NarrativeIssue(
                fatal: false,
                location: "Level \(levelIndex) teaching",
                fix: "Mechanic needs text to understand. Simplify: One cause → One visible effect.",
                priority: 2
            ))
        }
        
        return Array(issues.prefix(2)) // Max 2 issues per beat
    }
    
    // MARK: - Micro-Narrative Creation
    
    func createMicroNarrative(for levelIndex: Int) -> MicroNarrative {
        switch levelIndex {
        case 0:
            return MicroNarrative(
                environmental: "Broken bridge = they were separated here",
                mechanical: "Wind gets stronger = Vesper is excited to help",
                visual: "Exit portals brighten = they sense each other",
                emotional: "First success = relief, not triumph"
            )
        case 1:
            return MicroNarrative(
                environmental: "Ice wall has claw marks = Vesper tried to break through",
                mechanical: "Heat melts slowly = Spark is being careful",
                visual: "Steam rises = worlds are touching",
                emotional: "Melting ice = patience rewarded"
            )
        case 2:
            return MicroNarrative(
                environmental: "Two barriers = they each have fears",
                mechanical: "100% charge = giving everything",
                visual: "Barriers shatter together = synchronized breakthrough",
                emotional: "Dual success = we're stronger together"
            )
        default:
            return MicroNarrative(
                environmental: "World responds to presence",
                mechanical: "Actions have consequences",
                visual: "Beauty in cooperation",
                emotional: "Connection transcends space"
            )
        }
    }
    
    // MARK: - Environmental Storytelling
    
    func analyzeEnvironmentalNarrative(_ levelData: LevelData) -> [String] {
        var stories: [String] = []
        
        // Every object tells a story
        if !levelData.bridges.isEmpty {
            stories.append("Bridge: Something was connected before")
        }
        if !levelData.iceWalls.isEmpty {
            stories.append("Ice: Time has passed since warmth was here")
        }
        if !levelData.windmills.isEmpty {
            stories.append("Windmill: Someone built this expecting wind")
        }
        
        return stories
    }
    
    // MARK: - Emotional Pacing
    
    func calculateEmotionalArc(across levels: [LevelData]) -> [String: Float] {
        return [
            "curiosity": 1.0,    // Level 0-1: What is this?
            "discovery": 0.8,    // Level 2-3: I understand!
            "challenge": 0.6,    // Level 4-5: Can I do this?
            "mastery": 0.9,      // Level 6-7: I've got this!
            "connection": 1.0    // Level 8-9: We're one
        ]
    }
    
    // MARK: - Helper Methods
    
    private func calculateComplexity(_ level: LevelData) -> Int {
        var complexity = 0
        if !level.windmills.isEmpty { complexity += 1 }
        if !level.heatPlates.isEmpty { complexity += 1 }
        if !level.surgeBarriers.isEmpty { complexity += 2 }
        if !level.flowBarriers.isEmpty { complexity += 2 }
        return complexity
    }
    
    private func hasEmotionalHooks(_ level: LevelData) -> Bool {
        // Check for emotional mechanics
        let hasProximityMoment = abs(level.sparkStart.x - level.vesperStart.x) < 100
        let hasReunionPotential = level.sparkPortal.position == level.vesperPortal.position
        return hasProximityMoment || hasReunionPotential
    }
    
    private func hasImmediateHook(_ level: LevelData) -> Bool {
        // Something must be visibly broken/wrong in first 3 seconds
        return !level.bridges.isEmpty || !level.iceWalls.isEmpty
    }
    
    private func requiresTextExplanation(_ level: LevelData) -> Bool {
        let mechanicsCount = [
            level.windmills.count,
            level.heatPlates.count,
            level.surgeBarriers.count,
            level.flowBarriers.count
        ].reduce(0, +)
        return mechanicsCount > 2 // Too many new things at once
    }
    
    // MARK: - Recommendations
    
    func getTopRecommendation() -> String {
        """
        CRITICAL: Level 0 must establish emotional stakes in 3 seconds.
        Show Spark reaching for broken bridge, THEN Vesper fixes it.
        Player thinks: "Oh, they help each other!"
        Not: "What do I do?"
        """
    }
}