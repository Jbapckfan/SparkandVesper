import Foundation

// MARK: - Gaming Tycoon Agent
// Business reality check - what actually ships and sells

class GamingTycoon {
    
    struct SuccessMetrics {
        let d1Retention: Float = 0.40    // Industry: 0.25
        let d7Retention: Float = 0.20    // Industry: 0.12
        let d30Retention: Float = 0.08   // Industry: 0.05
        let organicShare: Float = 0.02   // Industry: 0.005
        let payingUsers: Float = 0.05    // Industry: 0.02
        let avgSessionLength: Int = 8    // Minutes (Industry: 5)
    }
    
    struct MarketAssessment {
        let verdict: String
        let criticalFixes: [String]
        let shipDate: String
        let confidence: Float
    }
    
    struct LaunchStrategy {
        let day: String
        let action: String
        let budget: String
        let metric: String
    }
    
    private let metrics = SuccessMetrics()
    
    // MARK: - Market Fit Analysis
    
    func assessMarketFit() -> MarketAssessment {
        return MarketAssessment(
            verdict: "Ship it, but...",
            criticalFixes: [
                "Levels 1-3 must be playable in 2 minutes total",
                "Add 'Continue' button that's 40% of screen",
                "Instagram story template after EVERY level complete",
                "Remove ALL text - icons only",
                "Add haptics on EVERY touch"
            ],
            shipDate: "Next Thursday (always Thursday)",
            confidence: 0.75
        )
    }
    
    // MARK: - Monetization Strategy
    
    func getPricingStrategy() -> [String: Any] {
        return [
            "model": "Free + Single Premium Unlock",
            "price": "$2.99", // Not $4.99. Volume > margin
            "freeContent": "Levels 0-8 (30 minutes)",
            "paidContent": "Levels 9-20 + Level Editor",
            "timing": "After level 8 cliffhanger",
            "conversionTrigger": "Show 'Vesper trapped' - pay to rescue",
            "whyItWorks": "Monument Valley model. Respect = revenue.",
            "projectedConversion": "3-5% at $2.99 vs 1% at $4.99"
        ]
    }
    
    // MARK: - Viral Mechanics
    
    func getViralMechanics() -> [[String: String]] {
        return [
            [
                "trigger": "Perfect sync moment (proximity > 90%)",
                "action": "Auto-record 3-second clip",
                "share": "One-tap to TikTok with #SparkAndVesper",
                "reward": "Unlock rainbow trail effect"
            ],
            [
                "trigger": "Speed run record",
                "action": "Generate shareable card with time",
                "share": "Instagram story template",
                "reward": "Name on global leaderboard"
            ],
            [
                "trigger": "Creative solution found",
                "action": "AI detects non-standard path",
                "share": "'I broke the puzzle' badge",
                "reward": "Secret character skin"
            ]
        ]
    }
    
    // MARK: - Launch Week Strategy
    
    func getWeekOneLaunch() -> [LaunchStrategy] {
        return [
            LaunchStrategy(
                day: "Monday",
                action: "Soft launch New Zealand + Canada",
                budget: "$0",
                metric: "Crash rate < 0.1%"
            ),
            LaunchStrategy(
                day: "Tuesday",
                action: "Fix top 3 crashes (there will be exactly 3)",
                budget: "$0",
                metric: "D1 retention > 35%"
            ),
            LaunchStrategy(
                day: "Wednesday",
                action: "Contact 5 puzzle streamers + send codes",
                budget: "$0",
                metric: "1 streamer commits"
            ),
            LaunchStrategy(
                day: "Thursday",
                action: "Global launch + ProductHunt + HackerNews",
                budget: "$500 Facebook",
                metric: "Top 10 ProductHunt"
            ),
            LaunchStrategy(
                day: "Friday",
                action: "Push 1.0.1 with Quick Restart button",
                budget: "$500 TikTok",
                metric: "10K downloads"
            ),
            LaunchStrategy(
                day: "Weekend",
                action: "Monitor + respond to every review",
                budget: "$0",
                metric: "4.5+ star average"
            )
        ]
    }
    
    // MARK: - Retention Killers
    
    func getRetentionKillers() -> [String: String] {
        return [
            "Level 0 > 45 seconds": "Lost 30% of players",
            "No continue button": "Lost 20% of returning players",
            "Unclear objective": "Lost 40% at Level 1",
            "Touch target too small": "Lost 15% to frustration",
            "No haptic feedback": "Feels cheap, lost 10%",
            "Loading > 3 seconds": "Lost 25% before playing"
        ]
    }
    
    // MARK: - ASO (App Store Optimization)
    
    func getASOStrategy() -> [String: Any] {
        return [
            "title": "Spark & Vesper: Parallel Souls",
            "subtitle": "Unite across dimensions",
            "keywords": "puzzle,monument,valley,two,dots,dual,split",
            "icon": "Both characters reaching toward each other",
            "screenshots": [
                "The separation (emotional hook)",
                "Wind bridge extending (mechanic)",
                "Ice melting (visual beauty)",
                "Perfect sync (achievement)",
                "Level editor (value)"
            ],
            "video": "15 seconds, no text, show connection moment"
        ]
    }
    
    // MARK: - Competition Analysis
    
    func analyzeCompetition() -> [String: String] {
        return [
            "Monument Valley": "We're faster, more replayable",
            "Two Dots": "We have narrative, not just mechanics",
            "Alto's Adventure": "We're puzzle, not endless",
            "Unique Angle": "Only game about connection, not collection"
        ]
    }
    
    // MARK: - Critical Success Factors
    
    func getCriticalSuccessFactors() -> String {
        """
        THREE THINGS THAT MATTER:
        
        1. First 30 seconds must be magic
           - No menus, straight to gameplay
           - One interaction, immediate result
           
        2. Shareability built-in
           - Every level ends with screenshot moment
           - Auto-generate, one-tap share
           
        3. Premium feel on free tier
           - Haptics everywhere
           - 60fps minimum
           - No ads, ever
           
        Miss any of these = dead game.
        """
    }
}