import SwiftUI
import SpriteKit

struct GameScreen: View {
    let levelIndex: Int?
    @StateObject private var game = GameManager.shared
    @StateObject private var levels = LevelManager.shared
    
    init(levelIndex: Int? = nil) {
        self.levelIndex = levelIndex
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    // Top: Spark world
                    SpriteView(scene: {
                        let s = SparkScene(size: CGSize(width: geo.size.width * UIScreen.main.scale,
                                                        height: geo.size.height/2 * UIScreen.main.scale))
                        s.scaleMode = .resizeFill
                        return s
                    }(), preferredFramesPerSecond: 120)
                    .ignoresSafeArea()
                    
                    // Divider / proximity bar
                    ProximityBarView(value: game.proximityStrength)
                        .frame(height: 10)
                        .background(Color.white.opacity(0.06))
                    
                    // Bottom: Vesper world
                    SpriteView(scene: {
                        let s = VesperScene(size: CGSize(width: geo.size.width * UIScreen.main.scale,
                                                         height: geo.size.height/2 * UIScreen.main.scale))
                        s.scaleMode = .resizeFill
                        return s
                    }(), preferredFramesPerSecond: 120)
                    .ignoresSafeArea()
                }
                
                // Title overlay for Level 1
                if levelIndex == 0 || (levelIndex == nil && levels.currentLevelIndex == 0) {
                    LevelTitleOverlay()
                }
                
                // HUD overlays
                VStack {
                    HStack {
                        MeterView(title: "Surge", color: Color(hex:"#FFD700"), value: game.surge)
                        Spacer()
                        VStack(spacing: 4) {
                            Text(game.levelTitle).font(.caption).foregroundStyle(.white.opacity(0.8))
                            Text(game.timerString).font(.caption2.monospacedDigit()).foregroundStyle(.white.opacity(0.6))
                        }
                        Spacer()
                        MeterView(title: "Flow", color: Color(hex:"#6B46C1"), value: game.flow)
                    }
                    .padding(.horizontal, 16).padding(.top, 10)
                    Spacer()
                }
            }
            .onAppear { 
                if let levelIndex = levelIndex {
                    levels.loadLevel(at: levelIndex)
                } else {
                    levels.loadCurrentLevel()
                }
                game.startSession()
            }
            .onDisappear { game.endSession() }
        }
    }
}

struct LevelTitleOverlay: View {
    @State private var showTitle = false
    @State private var showSubtitle = false
    @State private var showHint = false
    
    var body: some View {
        ZStack {
            // Title
            VStack(spacing: 20) {
                Text("FIRST CONTACT")
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(colors: [
                            Color(hex: "#FFD700"),
                            Color.white,
                            Color(hex: "#6B46C1")
                        ], startPoint: .leading, endPoint: .trailing)
                    )
                    .opacity(showTitle ? 1 : 0)
                    .scaleEffect(showTitle ? 1 : 1.2)
                    .animation(.easeOut(duration: 1.5), value: showTitle)
                
                Text("Two souls, one destiny")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(showSubtitle ? 1 : 0)
                    .animation(.easeOut(duration: 1.5).delay(0.5), value: showSubtitle)
                
                Text("→ Reach the portals together →")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#00FF88").opacity(0.8))
                    .opacity(showHint ? 1 : 0)
                    .animation(.easeOut(duration: 1.5).delay(1.0), value: showHint)
            }
            .padding(.top, 60)
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showTitle = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showSubtitle = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                showHint = true
            }
            // Auto-hide after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    showTitle = false
                    showSubtitle = false
                    showHint = false
                }
            }
        }
    }
}

struct MeterView: View {
    let title: String
    let color: Color
    let value: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption.bold()).foregroundStyle(color)
            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.08)).frame(height: 8)
                Capsule().fill(color.opacity(0.9)).frame(width: max(0, value)*120, height: 8)
            }.frame(width: 120, alignment: .leading)
        }
    }
}

struct ProximityBarView: View {
    let value: CGFloat
    var body: some View {
        LinearGradient(colors: [
            Color(hex:"#FFD700").opacity(0.25),
            Color.white.opacity(0.4*value),
            Color(hex:"#6B46C1").opacity(0.25)
        ], startPoint: .leading, endPoint: .trailing)
        .overlay(Rectangle().fill(Color.white.opacity(0.15 * value)))
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.white.opacity(0.2 + 0.5*value), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: value)
    }
}