import Foundation

// MARK: - Pacing Analyzer Agent
// Turns real player sessions into concrete tuning knobs

class PacingAnalyzer {
    
    struct TelemetryEvent: Codable {
        let timestamp: Date
        let levelId: String
        let event: EventType
        let payload: [String: Any]?
        
        enum EventType: String, Codable {
            case levelStart
            case levelComplete
            case death
            case checkpoint
            case stuck
            case quit
            case mechanicUsed
            case hintShown
        }
        
        enum CodingKeys: String, CodingKey {
            case timestamp, levelId, event, payload
        }
    }
    
    struct PacingReport: Codable {
        let levelId: String
        let sessionCount: Int
        let metrics: Metrics
        let knobs: [TuningKnob]
        let heatmapUrl: String?
        
        struct Metrics: Codable {
            let avgClearTime: Double
            let p50ClearTime: Double
            let failRate: Double
            let quitRate: Double
            let avgDeathsBeforeClear: Double
            let stuckPoints: [StuckPoint]
        }
        
        struct StuckPoint: Codable {
            let position: CGPoint
            let avgTimeStuck: Double
            let percentAffected: Double
        }
        
        struct TuningKnob: Codable {
            let path: String
            let currentValue: Double
            let suggestedValue: Double
            let impact: String
            let confidence: Double
        }
    }
    
    struct LevelPatch: Codable {
        let levelId: String
        let tuning: [String: Any]
        
        enum CodingKeys: String, CodingKey {
            case levelId, tuning
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(levelId, forKey: .levelId)
            // Simplified encoding for tuning dictionary
        }
    }
    
    // MARK: - Core Analysis
    
    func analyzeSessions(_ events: [TelemetryEvent]) -> PacingReport {
        let levelGroups = Dictionary(grouping: events) { $0.levelId }
        
        // Focus on most problematic level
        let worstLevel = findWorstLevel(levelGroups)
        let levelEvents = levelGroups[worstLevel] ?? []
        
        // Calculate metrics
        let metrics = calculateMetrics(levelEvents)
        
        // Generate tuning knobs
        let knobs = generateKnobs(metrics: metrics, events: levelEvents)
        
        // Generate heatmap (would create actual image in production)
        let heatmapUrl = generateHeatmap(events: levelEvents)
        
        return PacingReport(
            levelId: worstLevel,
            sessionCount: countUniqueSessions(levelEvents),
            metrics: metrics,
            knobs: Array(knobs.prefix(3)), // Max 3 knobs
            heatmapUrl: heatmapUrl
        )
    }
    
    // MARK: - Knob Generation
    
    private func generateKnobs(metrics: PacingReport.Metrics, events: [TelemetryEvent]) -> [PacingReport.TuningKnob] {
        var knobs: [PacingReport.TuningKnob] = []
        
        // Knob 1: Adjust timing windows
        if metrics.failRate > 0.3 {
            knobs.append(PacingReport.TuningKnob(
                path: "resonancePad.windowMs",
                currentValue: 300,
                suggestedValue: 360,
                impact: "Reduce fail rate by ~15%",
                confidence: 0.85
            ))
        }
        
        // Knob 2: Move checkpoint
        if let worstStuck = metrics.stuckPoints.first {
            knobs.append(PacingReport.TuningKnob(
                path: "checkpoint.x",
                currentValue: Double(worstStuck.position.x),
                suggestedValue: Double(worstStuck.position.x - 20),
                impact: "Reduce stuck time by ~20%",
                confidence: 0.75
            ))
        }
        
        // Knob 3: Adjust hint triggers
        if metrics.avgDeathsBeforeClear > 5 {
            knobs.append(PacingReport.TuningKnob(
                path: "hint.triggerFailures",
                currentValue: 5,
                suggestedValue: 3,
                impact: "Show hints earlier for struggling players",
                confidence: 0.90
            ))
        }
        
        return knobs
    }
    
    // MARK: - Metrics Calculation
    
    private func calculateMetrics(_ events: [TelemetryEvent]) -> PacingReport.Metrics {
        let sessions = groupBySessions(events)
        
        // Clear times
        let clearTimes = sessions.compactMap { session -> Double? in
            guard let start = session.first(where: { $0.event == .levelStart }),
                  let complete = session.first(where: { $0.event == .levelComplete }) else {
                return nil
            }
            return complete.timestamp.timeIntervalSince(start.timestamp)
        }
        
        let avgClearTime = clearTimes.reduce(0, +) / Double(max(clearTimes.count, 1))
        let p50ClearTime = clearTimes.sorted()[clearTimes.count / 2]
        
        // Fail and quit rates
        let failRate = Double(sessions.filter { hasEvent($0, .death) }.count) / Double(sessions.count)
        let quitRate = Double(sessions.filter { hasEvent($0, .quit) }.count) / Double(sessions.count)
        
        // Deaths before clear
        let deathCounts = sessions.map { session in
            session.filter { $0.event == .death }.count
        }
        let avgDeaths = Double(deathCounts.reduce(0, +)) / Double(max(deathCounts.count, 1))
        
        // Stuck points
        let stuckPoints = findStuckPoints(events)
        
        return PacingReport.Metrics(
            avgClearTime: avgClearTime,
            p50ClearTime: p50ClearTime,
            failRate: failRate,
            quitRate: quitRate,
            avgDeathsBeforeClear: avgDeaths,
            stuckPoints: stuckPoints
        )
    }
    
    // MARK: - Helper Methods
    
    private func findWorstLevel(_ groups: [String: [TelemetryEvent]]) -> String {
        // Find level with highest quit rate
        var worstLevel = "Level00"
        var worstQuitRate = 0.0
        
        for (levelId, events) in groups {
            let quitRate = Double(events.filter { $0.event == .quit }.count) / Double(events.count)
            if quitRate > worstQuitRate {
                worstQuitRate = quitRate
                worstLevel = levelId
            }
        }
        
        return worstLevel
    }
    
    private func groupBySessions(_ events: [TelemetryEvent]) -> [[TelemetryEvent]] {
        // Simplified: group by 5-minute windows
        var sessions: [[TelemetryEvent]] = []
        var currentSession: [TelemetryEvent] = []
        var lastTime: Date?
        
        for event in events.sorted(by: { $0.timestamp < $1.timestamp }) {
            if let last = lastTime, event.timestamp.timeIntervalSince(last) > 300 {
                if !currentSession.isEmpty {
                    sessions.append(currentSession)
                }
                currentSession = [event]
            } else {
                currentSession.append(event)
            }
            lastTime = event.timestamp
        }
        
        if !currentSession.isEmpty {
            sessions.append(currentSession)
        }
        
        return sessions
    }
    
    private func findStuckPoints(_ events: [TelemetryEvent]) -> [PacingReport.StuckPoint] {
        let stuckEvents = events.filter { $0.event == .stuck }
        
        // Group by position (simplified)
        var pointMap: [String: [TelemetryEvent]] = [:]
        for event in stuckEvents {
            if let x = event.payload?["x"] as? Double,
               let y = event.payload?["y"] as? Double {
                let key = "\(Int(x/20))-\(Int(y/20))" // Grid snap
                pointMap[key, default: []].append(event)
            }
        }
        
        return pointMap.compactMap { (key, events) -> PacingReport.StuckPoint? in
            guard let first = events.first,
                  let x = first.payload?["x"] as? Double,
                  let y = first.payload?["y"] as? Double,
                  let duration = first.payload?["duration"] as? Double else {
                return nil
            }
            
            return PacingReport.StuckPoint(
                position: CGPoint(x: x, y: y),
                avgTimeStuck: duration,
                percentAffected: Double(events.count) / Double(stuckEvents.count)
            )
        }.sorted { $0.percentAffected > $1.percentAffected }
    }
    
    private func countUniqueSessions(_ events: [TelemetryEvent]) -> Int {
        return groupBySessions(events).count
    }
    
    private func hasEvent(_ session: [TelemetryEvent], _ type: TelemetryEvent.EventType) -> Bool {
        return session.contains { $0.event == type }
    }
    
    private func generateHeatmap(events: [TelemetryEvent]) -> String {
        // In production, would generate actual heatmap image
        return "/Automation/reports/heatmap_\(Date().timeIntervalSince1970).png"
    }
    
    // MARK: - Patch Generation
    
    func generatePatch(from report: PacingReport) -> LevelPatch {
        var tuning: [String: Any] = [:]
        
        for knob in report.knobs {
            // Convert path to nested dictionary
            let components = knob.path.split(separator: ".")
            if components.count == 2 {
                tuning[String(components[0])] = [String(components[1]): knob.suggestedValue]
            } else {
                tuning[knob.path] = knob.suggestedValue
            }
        }
        
        return LevelPatch(
            levelId: report.levelId,
            tuning: tuning
        )
    }
}