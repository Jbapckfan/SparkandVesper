import SwiftUI
import WebKit
import GameKit

struct WebLevelView: UIViewRepresentable {
    let levelHTML: String
    @Binding var levelCompleted: Bool
    @Binding var score: Int
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        // Add message handlers for JavaScript communication
        let contentController = config.userContentController
        contentController.add(context.coordinator, name: "hapticController")
        contentController.add(context.coordinator, name: "gameCenterAuth")
        contentController.add(context.coordinator, name: "gameCenterSubmit")
        contentController.add(context.coordinator, name: "gameCenterAchievement")
        contentController.add(context.coordinator, name: "levelComplete")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if webView.url == nil {
            // Load HTML from project directory
            let fileManager = FileManager.default
            let projectPath = "/Users/jamesalford/Documents/Spark&Vesper/Content/Levels/\(levelHTML).html"
            
            if fileManager.fileExists(atPath: projectPath) {
                do {
                    let htmlContent = try String(contentsOfFile: projectPath, encoding: .utf8)
                    webView.loadHTMLString(htmlContent, baseURL: URL(fileURLWithPath: projectPath).deletingLastPathComponent())
                } catch {
                    print("Error loading HTML file: \(error)")
                }
            }
        }
    }
    
    class Coordinator: NSObject, WKScriptMessageHandler, GKGameCenterControllerDelegate {
        var parent: WebLevelView
        
        init(_ parent: WebLevelView) {
            self.parent = parent
            super.init()
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            switch message.name {
            case "hapticController":
                handleHaptic(message.body)
                
            case "gameCenterAuth":
                authenticateGameCenter()
                
            case "gameCenterSubmit":
                if let jsonString = message.body as? String,
                   let data = jsonString.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let level = json["level"] as? String,
                   let score = json["score"] as? Int {
                    submitScore(level: level, score: score)
                }
                
            case "gameCenterAchievement":
                if let achievementID = message.body as? String {
                    unlockAchievement(achievementID)
                }
                
            case "levelComplete":
                DispatchQueue.main.async {
                    self.parent.levelCompleted = true
                    if let score = message.body as? Int {
                        self.parent.score = score
                    }
                }
                
            default:
                break
            }
        }
        
        private func handleHaptic(_ type: Any?) {
            guard let hapticType = type as? String else { return }
            
            DispatchQueue.main.async {
                switch hapticType {
                case "tap":
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                case "impact":
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                case "success":
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                default:
                    let selection = UISelectionFeedbackGenerator()
                    selection.selectionChanged()
                }
            }
        }
        
        private func authenticateGameCenter() {
            let localPlayer = GKLocalPlayer.local
            localPlayer.authenticateHandler = { viewController, error in
                if let viewController = viewController {
                    // Present authentication view controller
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(viewController, animated: true)
                    }
                } else if localPlayer.isAuthenticated {
                    // Player authenticated successfully
                    self.notifyWebViewOfAuthentication(true)
                } else {
                    // Authentication failed
                    self.notifyWebViewOfAuthentication(false)
                }
            }
        }
        
        private func notifyWebViewOfAuthentication(_ authenticated: Bool) {
            // Execute JavaScript to notify the web view
            if let webView = findWebView() {
                let script = "window.gameCenterSetAuth(\(authenticated))"
                webView.evaluateJavaScript(script) { _, error in
                    if let error = error {
                        print("Error setting Game Center auth: \(error)")
                    }
                }
            }
        }
        
        private func submitScore(level: String, score: Int) {
            guard GKLocalPlayer.local.isAuthenticated else { return }
            
            GKLeaderboard.submitScore(
                score,
                context: 0,
                player: GKLocalPlayer.local,
                leaderboardIDs: [level]
            ) { error in
                if let error = error {
                    print("Error submitting score: \(error)")
                }
            }
        }
        
        private func unlockAchievement(_ identifier: String) {
            guard GKLocalPlayer.local.isAuthenticated else { return }
            
            let achievement = GKAchievement(identifier: identifier)
            achievement.percentComplete = 100
            achievement.showsCompletionBanner = true
            
            GKAchievement.report([achievement]) { error in
                if let error = error {
                    print("Error reporting achievement: \(error)")
                }
            }
        }
        
        private func findWebView() -> WKWebView? {
            // Helper to find the web view instance
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                return findWebViewInView(window)
            }
            return nil
        }
        
        private func findWebViewInView(_ view: UIView) -> WKWebView? {
            if let webView = view as? WKWebView {
                return webView
            }
            for subview in view.subviews {
                if let webView = findWebViewInView(subview) {
                    return webView
                }
            }
            return nil
        }
        
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true)
        }
    }
}