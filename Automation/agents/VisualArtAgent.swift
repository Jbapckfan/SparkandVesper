import Foundation
import CoreImage
import Vision

// MARK: - Visual Art Agent
// Ensures consistency & detects rendering issues

class VisualArtAgent {
    
    struct VisualReport: Codable {
        let timestamp: Date
        let screenshots: [ScreenshotAnalysis]
        let summary: Summary
        let recommendations: [String]
        
        struct ScreenshotAnalysis: Codable {
            let levelId: String
            let device: String
            let ssimScore: Double
            let contrastRatio: Double
            let dominantColors: [ColorInfo]
            let emptyAreas: [Region]
            let issues: [Issue]
            
            struct ColorInfo: Codable {
                let hex: String
                let percentage: Double
                let name: String
            }
            
            struct Region: Codable {
                let x: Int
                let y: Int
                let width: Int
                let height: Int
                let severity: String // "low", "medium", "high"
            }
            
            struct Issue: Codable {
                let type: IssueType
                let description: String
                let location: Region?
                
                enum IssueType: String, Codable {
                    case lowContrast
                    case missingAsset
                    case zFighting
                    case emptySpace
                    case inconsistentPalette
                    case renderingArtifact
                }
            }
        }
        
        struct Summary: Codable {
            let avgSSIM: Double
            let minSSIM: Double
            let criticalIssues: Int
            let paletteConsistency: Double
            let accessibilityScore: Double
        }
    }
    
    struct ColorPalette: Codable {
        let primary: [String]    // Hex colors
        let secondary: [String]
        let accent: [String]
        let forbidden: [String]  // Colors to avoid
        let contrastMinimum: Double
    }
    
    struct GoldenScreenshots {
        let baseURL: URL
        let tolerance: Double // SSIM tolerance
        
        func path(for levelId: String, device: String) -> URL {
            return baseURL
                .appendingPathComponent(device)
                .appendingPathComponent("\(levelId).png")
        }
    }
    
    // MARK: - Core Analysis
    
    func analyzeScreenshots(_ screenshots: [URL], goldenPath: URL) -> VisualReport {
        let golden = GoldenScreenshots(baseURL: goldenPath, tolerance: 0.92)
        var analyses: [VisualReport.ScreenshotAnalysis] = []
        
        for screenshot in screenshots {
            // Extract metadata from filename
            let (levelId, device) = parseScreenshotMetadata(screenshot)
            
            // Load images
            guard let currentImage = CIImage(contentsOf: screenshot),
                  let goldenImage = CIImage(contentsOf: golden.path(for: levelId, device: device)) else {
                continue
            }
            
            // Calculate SSIM
            let ssim = calculateSSIM(currentImage, goldenImage)
            
            // Analyze contrast
            let contrast = analyzeContrast(currentImage)
            
            // Extract colors
            let colors = extractDominantColors(currentImage)
            
            // Find empty areas
            let emptyAreas = findEmptyAreas(currentImage)
            
            // Detect issues
            let issues = detectVisualIssues(
                current: currentImage,
                golden: goldenImage,
                ssim: ssim,
                contrast: contrast
            )
            
            analyses.append(VisualReport.ScreenshotAnalysis(
                levelId: levelId,
                device: device,
                ssimScore: ssim,
                contrastRatio: contrast,
                dominantColors: colors,
                emptyAreas: emptyAreas,
                issues: issues
            ))
        }
        
        // Generate summary
        let summary = generateSummary(analyses)
        
        // Generate recommendations
        let recommendations = generateRecommendations(analyses, summary: summary)
        
        return VisualReport(
            timestamp: Date(),
            screenshots: analyses,
            summary: summary,
            recommendations: recommendations
        )
    }
    
    // MARK: - SSIM Calculation
    
    private func calculateSSIM(_ image1: CIImage, _ image2: CIImage) -> Double {
        // Simplified SSIM calculation
        // In production, use proper SSIM algorithm
        
        // Ensure same size
        let size = image1.extent.size
        guard image2.extent.size == size else { return 0.0 }
        
        // Convert to grayscale for simplified comparison
        let gray1 = image1.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0])
        let gray2 = image2.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0])
        
        // Sample pixels and calculate similarity
        let samples = 100
        var totalDiff = 0.0
        
        for _ in 0..<samples {
            let x = CGFloat.random(in: 0..<size.width)
            let y = CGFloat.random(in: 0..<size.height)
            
            // Get pixel values (simplified)
            let pixel1 = samplePixel(gray1, at: CGPoint(x: x, y: y))
            let pixel2 = samplePixel(gray2, at: CGPoint(x: x, y: y))
            
            totalDiff += abs(pixel1 - pixel2)
        }
        
        // Convert to SSIM-like score
        let avgDiff = totalDiff / Double(samples)
        return max(0, 1.0 - avgDiff)
    }
    
    // MARK: - Contrast Analysis
    
    private func analyzeContrast(_ image: CIImage) -> Double {
        // Find Spark (bright) and background contrast
        let histogram = generateHistogram(image)
        
        // Calculate contrast ratio between peaks
        guard let darkPeak = histogram.first(where: { $0.value > 0.1 }),
              let brightPeak = histogram.last(where: { $0.value > 0.1 }) else {
            return 1.0
        }
        
        // Weber contrast formula
        let contrast = (brightPeak.key - darkPeak.key) / darkPeak.key
        return min(21.0, max(1.0, contrast)) // WCAG range
    }
    
    // MARK: - Color Extraction
    
    private func extractDominantColors(_ image: CIImage) -> [VisualReport.ScreenshotAnalysis.ColorInfo] {
        var colors: [VisualReport.ScreenshotAnalysis.ColorInfo] = []
        
        // Simplified k-means clustering
        let samples = sampleColors(image, count: 1000)
        let clusters = kMeansClustering(samples, k: 5)
        
        for (color, percentage) in clusters {
            colors.append(VisualReport.ScreenshotAnalysis.ColorInfo(
                hex: colorToHex(color),
                percentage: percentage,
                name: nameForColor(color)
            ))
        }
        
        return colors.sorted { $0.percentage > $1.percentage }
    }
    
    // MARK: - Empty Area Detection
    
    private func findEmptyAreas(_ image: CIImage) -> [VisualReport.ScreenshotAnalysis.Region] {
        var emptyAreas: [VisualReport.ScreenshotAnalysis.Region] = []
        
        // Divide image into grid
        let gridSize = 20
        let cellWidth = Int(image.extent.width) / gridSize
        let cellHeight = Int(image.extent.height) / gridSize
        
        for x in 0..<gridSize {
            for y in 0..<gridSize {
                let region = CGRect(
                    x: x * cellWidth,
                    y: y * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                if isRegionEmpty(image, region: region) {
                    emptyAreas.append(VisualReport.ScreenshotAnalysis.Region(
                        x: Int(region.origin.x),
                        y: Int(region.origin.y),
                        width: Int(region.width),
                        height: Int(region.height),
                        severity: severityForEmptyRegion(region, in: image.extent)
                    ))
                }
            }
        }
        
        // Merge adjacent empty areas
        return mergeAdjacentRegions(emptyAreas)
    }
    
    // MARK: - Issue Detection
    
    private func detectVisualIssues(
        current: CIImage,
        golden: CIImage,
        ssim: Double,
        contrast: Double
    ) -> [VisualReport.ScreenshotAnalysis.Issue] {
        var issues: [VisualReport.ScreenshotAnalysis.Issue] = []
        
        // Low contrast
        if contrast < 4.5 {
            issues.append(VisualReport.ScreenshotAnalysis.Issue(
                type: .lowContrast,
                description: "Contrast ratio \(String(format: "%.2f", contrast)) below WCAG AA minimum",
                location: nil
            ))
        }
        
        // Low SSIM indicates visual regression
        if ssim < 0.9 {
            issues.append(VisualReport.ScreenshotAnalysis.Issue(
                type: .renderingArtifact,
                description: "Visual regression detected (SSIM: \(String(format: "%.3f", ssim)))",
                location: nil
            ))
        }
        
        // Check for z-fighting patterns
        if hasZFightingPattern(current) {
            issues.append(VisualReport.ScreenshotAnalysis.Issue(
                type: .zFighting,
                description: "Z-fighting detected in overlapping sprites",
                location: nil
            ))
        }
        
        return issues
    }
    
    // MARK: - Summary Generation
    
    private func generateSummary(_ analyses: [VisualReport.ScreenshotAnalysis]) -> VisualReport.Summary {
        let ssimScores = analyses.map { $0.ssimScore }
        let avgSSIM = ssimScores.reduce(0, +) / Double(max(ssimScores.count, 1))
        let minSSIM = ssimScores.min() ?? 0
        
        let criticalIssues = analyses.flatMap { $0.issues }
            .filter { $0.type == .missingAsset || $0.type == .zFighting }
            .count
        
        // Calculate palette consistency
        let allColors = analyses.flatMap { $0.dominantColors.map { $0.hex } }
        let uniqueColors = Set(allColors)
        let paletteConsistency = 1.0 - (Double(uniqueColors.count) / Double(max(allColors.count, 1)))
        
        // Calculate accessibility score
        let contrastScores = analyses.map { $0.contrastRatio }
        let accessibilityScore = contrastScores.filter { $0 >= 4.5 }.count / max(contrastScores.count, 1)
        
        return VisualReport.Summary(
            avgSSIM: avgSSIM,
            minSSIM: minSSIM,
            criticalIssues: criticalIssues,
            paletteConsistency: paletteConsistency,
            accessibilityScore: Double(accessibilityScore)
        )
    }
    
    // MARK: - Recommendations
    
    private func generateRecommendations(
        _ analyses: [VisualReport.ScreenshotAnalysis],
        summary: VisualReport.Summary
    ) -> [String] {
        var recommendations: [String] = []
        
        if summary.minSSIM < 0.85 {
            recommendations.append("Critical: Visual regression on multiple levels. Review recent shader changes.")
        }
        
        if summary.accessibilityScore < 0.8 {
            recommendations.append("Increase contrast for Spark/Vesper against dark backgrounds")
        }
        
        if summary.paletteConsistency < 0.7 {
            recommendations.append("Consolidate color palette - too many unique colors detected")
        }
        
        // Check for specific patterns
        let emptyAreaCount = analyses.flatMap { $0.emptyAreas }.count
        if emptyAreaCount > 10 {
            recommendations.append("Consider adding visual interest to empty areas")
        }
        
        return recommendations
    }
    
    // MARK: - Helper Methods
    
    private func parseScreenshotMetadata(_ url: URL) -> (levelId: String, device: String) {
        let filename = url.deletingPathExtension().lastPathComponent
        let parts = filename.split(separator: "_")
        
        let levelId = parts.first.map(String.init) ?? "unknown"
        let device = parts.last.map(String.init) ?? "unknown"
        
        return (levelId, device)
    }
    
    private func samplePixel(_ image: CIImage, at point: CGPoint) -> Double {
        // Simplified pixel sampling
        return 0.5 // Placeholder
    }
    
    private func generateHistogram(_ image: CIImage) -> [Double: Double] {
        // Simplified histogram
        return [0.1: 0.3, 0.5: 0.2, 0.9: 0.5]
    }
    
    private func sampleColors(_ image: CIImage, count: Int) -> [CIColor] {
        // Sample random pixels
        return (0..<count).map { _ in
            CIColor(red: CGFloat.random(in: 0...1),
                   green: CGFloat.random(in: 0...1),
                   blue: CGFloat.random(in: 0...1))
        }
    }
    
    private func kMeansClustering(_ colors: [CIColor], k: Int) -> [(CIColor, Double)] {
        // Simplified k-means
        return [
            (CIColor.orange, 0.3),
            (CIColor.blue, 0.25),
            (CIColor.black, 0.45)
        ]
    }
    
    private func colorToHex(_ color: CIColor) -> String {
        return String(format: "#%02X%02X%02X",
                     Int(color.red * 255),
                     Int(color.green * 255),
                     Int(color.blue * 255))
    }
    
    private func nameForColor(_ color: CIColor) -> String {
        // Simple color naming
        if color.red > 0.8 && color.green > 0.4 {
            return "Orange"
        } else if color.blue > 0.7 {
            return "Blue"
        } else if color.red < 0.2 && color.green < 0.2 && color.blue < 0.2 {
            return "Black"
        }
        return "Mixed"
    }
    
    private func isRegionEmpty(_ image: CIImage, region: CGRect) -> Bool {
        // Check if region is mostly uniform
        return false // Simplified
    }
    
    private func severityForEmptyRegion(_ region: CGRect, in bounds: CGRect) -> String {
        let areaRatio = (region.width * region.height) / (bounds.width * bounds.height)
        if areaRatio > 0.1 { return "high" }
        if areaRatio > 0.05 { return "medium" }
        return "low"
    }
    
    private func mergeAdjacentRegions(_ regions: [VisualReport.ScreenshotAnalysis.Region]) -> [VisualReport.ScreenshotAnalysis.Region] {
        // Merge adjacent empty regions
        return regions // Simplified
    }
    
    private func hasZFightingPattern(_ image: CIImage) -> Bool {
        // Detect flickering/z-fighting patterns
        return false // Simplified
    }
    
    // MARK: - Export
    
    func exportHTMLReport(_ report: VisualReport, to url: URL) throws {
        let html = generateHTMLReport(report)
        try html.write(to: url, atomically: true, encoding: .utf8)
    }
    
    private func generateHTMLReport(_ report: VisualReport) -> String {
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Visual Analysis Report</title>
            <style>
                body { font-family: -apple-system, sans-serif; padding: 20px; }
                .summary { background: #f0f0f0; padding: 15px; border-radius: 8px; }
                .critical { color: #d32f2f; }
                .warning { color: #f57c00; }
                .good { color: #388e3c; }
                .screenshot { margin: 20px 0; border: 1px solid #ddd; padding: 10px; }
                .ssim-score { font-size: 24px; font-weight: bold; }
            </style>
        </head>
        <body>
            <h1>Visual Analysis Report</h1>
            <div class="summary">
                <h2>Summary</h2>
                <p>Average SSIM: <span class="ssim-score">\(String(format: "%.3f", report.summary.avgSSIM))</span></p>
                <p>Critical Issues: \(report.summary.criticalIssues)</p>
                <p>Accessibility Score: \(String(format: "%.0f%%", report.summary.accessibilityScore * 100))</p>
            </div>
            
            <h2>Recommendations</h2>
            <ul>
                \(report.recommendations.map { "<li>\($0)</li>" }.joined())
            </ul>
            
            <h2>Screenshots</h2>
            \(report.screenshots.map { screenshot in
                """
                <div class="screenshot">
                    <h3>\(screenshot.levelId) - \(screenshot.device)</h3>
                    <p>SSIM: \(String(format: "%.3f", screenshot.ssimScore))</p>
                    <p>Contrast: \(String(format: "%.2f", screenshot.contrastRatio))</p>
                    \(screenshot.issues.isEmpty ? "<p class='good'>✓ No issues</p>" : 
                        "<ul class='issues'>" + screenshot.issues.map { "<li class='warning'>\($0.description)</li>" }.joined() + "</ul>")
                </div>
                """
            }.joined())
        </body>
        </html>
        """
    }
}