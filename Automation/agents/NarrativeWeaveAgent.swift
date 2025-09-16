import Foundation
import NaturalLanguage

// MARK: - Narrative Weave Agent
// Ensures mechanics and story form a coherent whole

class NarrativeWeaveAgent {
    
    struct NarrativeReport: Codable {
        let timestamp: Date
        let levels: [LevelNarrative]
        let arc: StoryArc
        let coherence: CoherenceAnalysis
        let suggestions: [NarrativeSuggestion]
        
        struct LevelNarrative: Codable {
            let levelId: String
            let title: String
            let mechanicsIntroduced: [String]
            let narrativeBeats: [String]
            let emotionalTone: EmotionalTone
            let coherenceScore: Double
            
            enum EmotionalTone: String, Codable {
                case discovery = "Discovery"
                case tension = "Building Tension"
                case revelation = "Revelation"
                case triumph = "Triumph"
                case reflection = "Reflection"
            }
        }
        
        struct StoryArc: Codable {
            let acts: [Act]
            let pacing: PacingAnalysis
            let themeDevelopment: [Theme]
            
            struct Act: Codable {
                let number: Int
                let name: String
                let levels: [String]
                let purpose: String
                let mechanicalFocus: String
                let emotionalArc: String
            }
            
            struct PacingAnalysis: Codable {
                let intensityCurve: [Double] // 0-1 for each level
                let restPoints: [Int]        // Level indices
                let climaxLevel: Int
                let denouementStart: Int
            }
            
            struct Theme: Codable {
                let name: String
                let introduction: Int  // Level index
                let development: [Int] // Level indices
                let resolution: Int?   // Level index
            }
        }
        
        struct CoherenceAnalysis: Codable {
            let mechanicsToStory: Double      // 0-1
            let difficultyToEmotion: Double   // 0-1
            let teachingClarity: Double       // 0-1
            let thematicConsistency: Double   // 0-1
            let overall: Double                // 0-1
        }
        
        struct NarrativeSuggestion: Codable {
            let levelId: String
            let type: SuggestionType
            let description: String
            let implementation: String
            let priority: Priority
            
            enum SuggestionType: String, Codable {
                case mechanicsAlignment = "Align mechanics with story"
                case emotionalPacing = "Adjust emotional pacing"
                case thematicReinforcement = "Reinforce theme"
                case teachingMoment = "Clarify teaching"
                case narrativeBeat = "Add narrative beat"
            }
            
            enum Priority: String, Codable {
                case critical = "Critical"
                case high = "High"
                case medium = "Medium"
                case low = "Low"
            }
        }
    }
    
    struct LevelDialogue: Codable {
        let levelId: String
        let preLevel: [String]?
        let midLevel: [String]?
        let postLevel: [String]?
        let hints: [String: String] // hint_id: text
    }
    
    // MARK: - Core Analysis
    
    func analyzeNarrative(levels: [LevelData], dialogue: [LevelDialogue]) -> NarrativeReport {
        // Analyze individual levels
        let levelNarratives = levels.map { level in
            analyzeLevelNarrative(level, dialogue: findDialogue(level.id, in: dialogue))
        }
        
        // Analyze overall arc
        let arc = analyzeStoryArc(levels, narratives: levelNarratives)
        
        // Analyze coherence
        let coherence = analyzeCoherence(levels, narratives: levelNarratives, arc: arc)
        
        // Generate suggestions
        let suggestions = generateSuggestions(
            levels: levels,
            narratives: levelNarratives,
            arc: arc,
            coherence: coherence
        )
        
        return NarrativeReport(
            timestamp: Date(),
            levels: levelNarratives,
            arc: arc,
            coherence: coherence,
            suggestions: suggestions
        )
    }
    
    // MARK: - Level Analysis
    
    private func analyzeLevelNarrative(_ level: LevelData, dialogue: LevelDialogue?) -> NarrativeReport.LevelNarrative {
        // Identify mechanics
        let mechanics = identifyMechanics(level)
        
        // Extract narrative beats
        let beats = extractNarrativeBeats(level, dialogue: dialogue)
        
        // Determine emotional tone
        let tone = determineEmotionalTone(level)
        
        // Calculate coherence
        let coherence = calculateLevelCoherence(
            mechanics: mechanics,
            beats: beats,
            tone: tone,
            levelIndex: level.index
        )
        
        return NarrativeReport.LevelNarrative(
            levelId: level.id,
            title: level.title,
            mechanicsIntroduced: mechanics,
            narrativeBeats: beats,
            emotionalTone: tone,
            coherenceScore: coherence
        )
    }
    
    private func identifyMechanics(_ level: LevelData) -> [String] {
        var mechanics: [String] = []
        
        if !level.windmills.isEmpty { mechanics.append("Wind Generation") }
        if !level.heatPlates.isEmpty { mechanics.append("Heat Transfer") }
        if !level.iceWalls.isEmpty { mechanics.append("Ice Melting") }
        if !level.bridges.isEmpty { mechanics.append("Bridge Extension") }
        if !level.surgeBarriers.isEmpty { mechanics.append("Surge Power") }
        if !level.flowBarriers.isEmpty { mechanics.append("Flow Control") }
        if !level.resonancePads.isEmpty { mechanics.append("Proximity Resonance") }
        
        return mechanics
    }
    
    private func extractNarrativeBeats(_ level: LevelData, dialogue: LevelDialogue?) -> [String] {
        var beats: [String] = []
        
        // Title implies narrative
        if level.title.contains("First") {
            beats.append("Introduction to parallel worlds")
        }
        if level.title.contains("Together") || level.title.contains("Apart") {
            beats.append("Exploration of connection/separation")
        }
        if level.title.contains("Resonance") {
            beats.append("Discovery of proximity power")
        }
        
        // Dialogue beats
        if let dialogue = dialogue {
            if dialogue.preLevel != nil {
                beats.append("Story setup through dialogue")
            }
            if dialogue.postLevel != nil {
                beats.append("Reflection on progress")
            }
        }
        
        return beats
    }
    
    private func determineEmotionalTone(_ level: LevelData) -> NarrativeReport.LevelNarrative.EmotionalTone {
        // Based on level progression and mechanics
        if level.index == 0 {
            return .discovery
        } else if level.index < 3 {
            return .discovery
        } else if level.index < 7 {
            return .tension
        } else if level.index == 7 || level.index == 8 {
            return .revelation
        } else if level.index == 9 {
            return .triumph
        } else {
            return .reflection
        }
    }
    
    private func calculateLevelCoherence(
        mechanics: [String],
        beats: [String],
        tone: NarrativeReport.LevelNarrative.EmotionalTone,
        levelIndex: Int
    ) -> Double {
        var score = 0.7 // Base score
        
        // Mechanics should match narrative
        if mechanics.contains("Proximity Resonance") && !beats.contains { $0.contains("connection") } {
            score -= 0.1
        }
        
        // Early levels should be simpler
        if levelIndex < 3 && mechanics.count > 2 {
            score -= 0.15
        }
        
        // Emotional tone should match difficulty
        if tone == .triumph && mechanics.count < 3 {
            score -= 0.1
        }
        
        return max(0, min(1, score))
    }
    
    // MARK: - Story Arc Analysis
    
    private func analyzeStoryArc(
        _ levels: [LevelData],
        narratives: [NarrativeReport.LevelNarrative]
    ) -> NarrativeReport.StoryArc {
        // Define acts
        let acts = [
            NarrativeReport.StoryArc.Act(
                number: 1,
                name: "Discovery",
                levels: ["Level00", "Level01", "Level02"],
                purpose: "Introduce parallel worlds and basic mechanics",
                mechanicalFocus: "Wind and Heat",
                emotionalArc: "Wonder and curiosity"
            ),
            NarrativeReport.StoryArc.Act(
                number: 2,
                name: "Separation",
                levels: ["Level03", "Level04", "Level05"],
                purpose: "Explore challenges of being apart",
                mechanicalFocus: "Barriers and obstacles",
                emotionalArc: "Tension and frustration"
            ),
            NarrativeReport.StoryArc.Act(
                number: 3,
                name: "Resonance",
                levels: ["Level06", "Level07", "Level08"],
                purpose: "Discover proximity power",
                mechanicalFocus: "Proximity mechanics",
                emotionalArc: "Revelation and hope"
            ),
            NarrativeReport.StoryArc.Act(
                number: 4,
                name: "Unity",
                levels: ["Level09"],
                purpose: "Master all mechanics in harmony",
                mechanicalFocus: "Combined mechanics",
                emotionalArc: "Triumph and resolution"
            )
        ]
        
        // Analyze pacing
        let pacing = analyzePacing(levels, narratives: narratives)
        
        // Track theme development
        let themes = [
            NarrativeReport.StoryArc.Theme(
                name: "Connection Across Dimensions",
                introduction: 0,
                development: [2, 4, 6],
                resolution: 9
            ),
            NarrativeReport.StoryArc.Theme(
                name: "Cooperation Despite Separation",
                introduction: 1,
                development: [3, 5, 7],
                resolution: 9
            ),
            NarrativeReport.StoryArc.Theme(
                name: "Power of Proximity",
                introduction: 6,
                development: [7, 8],
                resolution: 9
            )
        ]
        
        return NarrativeReport.StoryArc(
            acts: acts,
            pacing: pacing,
            themeDevelopment: themes
        )
    }
    
    private func analyzePacing(
        _ levels: [LevelData],
        narratives: [NarrativeReport.LevelNarrative]
    ) -> NarrativeReport.StoryArc.PacingAnalysis {
        // Calculate intensity for each level
        let intensityCurve = levels.map { level in
            calculateIntensity(level)
        }
        
        // Find rest points (levels with lower intensity after high)
        var restPoints: [Int] = []
        for i in 1..<intensityCurve.count {
            if intensityCurve[i] < intensityCurve[i-1] - 0.2 {
                restPoints.append(i)
            }
        }
        
        // Identify climax (highest intensity)
        let climaxLevel = intensityCurve.enumerated().max { $0.element < $1.element }?.offset ?? 8
        
        // Denouement starts after climax
        let denouementStart = climaxLevel + 1
        
        return NarrativeReport.StoryArc.PacingAnalysis(
            intensityCurve: intensityCurve,
            restPoints: restPoints,
            climaxLevel: climaxLevel,
            denouementStart: denouementStart
        )
    }
    
    private func calculateIntensity(_ level: LevelData) -> Double {
        var intensity = 0.2 // Base
        
        // Add for mechanics complexity
        intensity += Double(level.windmills.count) * 0.05
        intensity += Double(level.heatPlates.count) * 0.05
        intensity += Double(level.surgeBarriers.count) * 0.15
        intensity += Double(level.flowBarriers.count) * 0.15
        intensity += Double(level.resonancePads.count) * 0.2
        
        // Add for hazards
        intensity += Double(level.hazards.count) * 0.1
        
        return min(1.0, intensity)
    }
    
    // MARK: - Coherence Analysis
    
    private func analyzeCoherence(
        _ levels: [LevelData],
        narratives: [NarrativeReport.LevelNarrative],
        arc: NarrativeReport.StoryArc
    ) -> NarrativeReport.CoherenceAnalysis {
        // Mechanics to story alignment
        let mechanicsToStory = calculateMechanicsToStory(levels, narratives: narratives)
        
        // Difficulty matches emotional arc
        let difficultyToEmotion = calculateDifficultyToEmotion(arc, narratives: narratives)
        
        // Teaching clarity
        let teachingClarity = calculateTeachingClarity(levels)
        
        // Thematic consistency
        let thematicConsistency = calculateThematicConsistency(arc, narratives: narratives)
        
        // Overall score
        let overall = (mechanicsToStory + difficultyToEmotion + teachingClarity + thematicConsistency) / 4
        
        return NarrativeReport.CoherenceAnalysis(
            mechanicsToStory: mechanicsToStory,
            difficultyToEmotion: difficultyToEmotion,
            teachingClarity: teachingClarity,
            thematicConsistency: thematicConsistency,
            overall: overall
        )
    }
    
    private func calculateMechanicsToStory(_ levels: [LevelData], narratives: [NarrativeReport.LevelNarrative]) -> Double {
        var score = 1.0
        
        // Check if wind/heat mechanics align with elemental themes
        for (level, narrative) in zip(levels, narratives) {
            if narrative.mechanicsIntroduced.contains("Wind Generation") && 
               !narrative.narrativeBeats.contains { $0.contains("wind") || $0.contains("air") } {
                score -= 0.05
            }
        }
        
        return max(0, score)
    }
    
    private func calculateDifficultyToEmotion(_ arc: NarrativeReport.StoryArc, narratives: [NarrativeReport.LevelNarrative]) -> Double {
        var score = 1.0
        
        // Triumph levels should be challenging
        let triumphLevels = narratives.filter { $0.emotionalTone == .triumph }
        if triumphLevels.first?.mechanicsIntroduced.count ?? 0 < 3 {
            score -= 0.2
        }
        
        // Discovery levels should be simpler
        let discoveryLevels = narratives.filter { $0.emotionalTone == .discovery }
        if discoveryLevels.first?.mechanicsIntroduced.count ?? 0 > 2 {
            score -= 0.15
        }
        
        return max(0, score)
    }
    
    private func calculateTeachingClarity(_ levels: [LevelData]) -> Double {
        var score = 1.0
        
        // Check for gradual introduction
        var previousMechanics = Set<String>()
        for level in levels {
            let currentMechanics = Set(identifyMechanics(level))
            let newMechanics = currentMechanics.subtracting(previousMechanics)
            
            // Penalize introducing too many new mechanics
            if newMechanics.count > 1 {
                score -= 0.1
            }
            
            previousMechanics = currentMechanics
        }
        
        return max(0, score)
    }
    
    private func calculateThematicConsistency(_ arc: NarrativeReport.StoryArc, narratives: [NarrativeReport.LevelNarrative]) -> Double {
        var score = 1.0
        
        // Check if themes are properly developed
        for theme in arc.themeDevelopment {
            if theme.resolution == nil {
                score -= 0.1 // Unresolved theme
            }
        }
        
        return max(0, score)
    }
    
    // MARK: - Suggestions
    
    private func generateSuggestions(
        levels: [LevelData],
        narratives: [NarrativeReport.LevelNarrative],
        arc: NarrativeReport.StoryArc,
        coherence: NarrativeReport.CoherenceAnalysis
    ) -> [NarrativeReport.NarrativeSuggestion] {
        var suggestions: [NarrativeReport.NarrativeSuggestion] = []
        
        // Check mechanics alignment
        if coherence.mechanicsToStory < 0.8 {
            suggestions.append(NarrativeReport.NarrativeSuggestion(
                levelId: "Level03",
                type: .mechanicsAlignment,
                description: "Wind mechanics don't align with narrative of separation",
                implementation: "Add dialogue about 'winds of change' or 'air between worlds'",
                priority: .high
            ))
        }
        
        // Check emotional pacing
        if arc.pacing.restPoints.isEmpty {
            suggestions.append(NarrativeReport.NarrativeSuggestion(
                levelId: "Level04",
                type: .emotionalPacing,
                description: "No rest points in difficulty curve",
                implementation: "Add a breather level with reflection dialogue",
                priority: .medium
            ))
        }
        
        // Check teaching clarity
        if coherence.teachingClarity < 0.7 {
            suggestions.append(NarrativeReport.NarrativeSuggestion(
                levelId: "Level01",
                type: .teachingMoment,
                description: "Too many mechanics introduced at once",
                implementation: "Split into two levels or add tutorial hints",
                priority: .critical
            ))
        }
        
        // Check thematic development
        for theme in arc.themeDevelopment {
            if theme.development.count < 2 {
                suggestions.append(NarrativeReport.NarrativeSuggestion(
                    levelId: "Level05",
                    type: .thematicReinforcement,
                    description: "Theme '\(theme.name)' needs more development",
                    implementation: "Add visual or dialogue reference to theme",
                    priority: .low
                ))
            }
        }
        
        return suggestions
    }
    
    // MARK: - Helper Methods
    
    private func findDialogue(_ levelId: String, in dialogues: [LevelDialogue]) -> LevelDialogue? {
        return dialogues.first { $0.levelId == levelId }
    }
    
    // MARK: - Dialogue Generation
    
    func generateDialoguePatch(for suggestion: NarrativeReport.NarrativeSuggestion) -> LevelDialogue {
        var dialogue = LevelDialogue(
            levelId: suggestion.levelId,
            preLevel: nil,
            midLevel: nil,
            postLevel: nil,
            hints: [:]
        )
        
        switch suggestion.type {
        case .mechanicsAlignment:
            dialogue.preLevel = [
                "Vesper, can you feel it? The wind carries whispers between our worlds.",
                "Use my breath to power your mechanisms, Spark."
            ]
            
        case .emotionalPacing:
            dialogue.postLevel = [
                "We're getting better at this, aren't we?",
                "Every puzzle brings us closer, even when we're apart."
            ]
            
        case .thematicReinforcement:
            dialogue.midLevel = [
                "The distance doesn't weaken our bond.",
                "Together, always, no matter the dimension."
            ]
            
        case .teachingMoment:
            dialogue.hints = [
                "wind_hint": "Vesper's movement creates wind in Spark's world",
                "heat_hint": "Spark's warmth can melt ice in Vesper's realm"
            ]
            
        case .narrativeBeat:
            dialogue.preLevel = [
                "This feeling... we're stronger when we're close.",
                "The proximity awakens something new."
            ]
        }
        
        return dialogue
    }
    
    // MARK: - Export
    
    func exportReport(_ report: NarrativeReport, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(report)
        try data.write(to: url)
    }
}