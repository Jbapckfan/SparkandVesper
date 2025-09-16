import SwiftUI
import SpriteKit

struct Level: Identifiable {
    let id: Int
    let name: String
    let type: LevelType
    let description: String
    let htmlFile: String?
    
    enum LevelType {
        case spriteKit
        case webLevel
        case gameScreen
    }
}

struct SpriteKitView: UIViewRepresentable {
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        
        let scene = Level1Scene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {}
}

struct GameView: View {
    let level: Level
    @State private var levelCompleted = false
    @State private var score = 0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if level.type == .spriteKit {
                SpriteKitView()
                    .ignoresSafeArea()
            } else if level.type == .gameScreen {
                GameScreen(levelIndex: level.id - 1) // Convert to 0-based indexing
                    .ignoresSafeArea()
            } else if let htmlFile = level.htmlFile {
                WebLevelView(
                    levelHTML: htmlFile,
                    levelCompleted: $levelCompleted,
                    score: $score
                )
                .ignoresSafeArea()
            }
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.7))
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(level.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        if score > 0 {
                            Text("Score: \(score)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(Capsule().fill(.black.opacity(0.3)))
                    .padding()
                }
                
                Spacer()
            }
        }
        .statusBarHidden()
        .onChange(of: levelCompleted) { completed in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

struct LevelCard: View {
    let level: Level
    let isUnlocked: Bool
    let score: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isUnlocked ? 
                              LinearGradient(colors: [Color(hex: "#2A1F3E"), Color(hex: "#1A1528")],
                                           startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 140)
                    
                    if isUnlocked {
                        VStack(spacing: 4) {
                            Text("Level \(level.id)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                            
                            Text(level.name)
                                .font(.title3.bold())
                                .foregroundColor(.white)
                            
                            if score > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                    Text("\(score)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.top, 4)
                            }
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.3))
                    }
                }
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(isUnlocked ? 0.6 : 0.3))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
            }
        }
        .disabled(!isUnlocked)
    }
}

struct LevelSelectionView: View {
    let levels: [Level]
    let unlockedLevels: Set<Int>
    @Binding var selectedLevel: Level?
    @Environment(\.dismiss) var dismiss
    
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 20)]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#120E1A"), Color(hex: "#1B1230")],
                          startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("SELECT LEVEL")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [Color(hex:"#FFD700"), Color.white],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(.top, 40)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(levels, id: \.id) { level in
                            LevelCard(level: level, 
                                     isUnlocked: unlockedLevels.contains(level.id),
                                     score: 0) {
                                if unlockedLevels.contains(level.id) {
                                    selectedLevel = level
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button(action: { dismiss() }) {
                    Text("Back")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 12)
                        .background(.white.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.2)))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.bottom, 30)
            }
        }
    }
}

struct RootView: View {
    @State private var showLevelSelection = false
    @State private var selectedLevel: Level?
    @State private var currentLevel = 1
    @State private var unlockedLevels = Set<Int>([1, 2, 3])
    
    let levels = [
        Level(id: 1, name: "First Contact", type: .gameScreen, 
              description: "Spark and Vesper awaken in a fractured reality",
              htmlFile: nil),
        Level(id: 2, name: "Dual Paths", type: .webLevel,
              description: "Navigate parallel worlds with unique barriers", 
              htmlFile: "level1"),
        Level(id: 3, name: "Synaptic Echo", type: .webLevel,
              description: "Split dimensions require perfect synchronization",
              htmlFile: "level2")
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "#120E1A"), Color(hex: "#1B1230")],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("SPARK & VESPER")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(LinearGradient(colors: [Color(hex:"#FFD700"), Color.white],
                                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(radius: 8)
                
                Text("Two worlds. One soul.")
                    .foregroundStyle(.white.opacity(0.7))
                
                VStack(spacing: 16) {
                    Button(action: { showLevelSelection = true }) {
                        Text("Play")
                            .font(.title3.bold())
                            .padding(.horizontal, 32).padding(.vertical, 14)
                            .background(.white.opacity(0.15))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.3)))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button(action: { 
                        if let level = levels.first(where: { $0.id == currentLevel }) {
                            selectedLevel = level
                        }
                    }) {
                        Text("Continue")
                            .font(.body.bold())
                            .padding(.horizontal, 24).padding(.vertical, 10)
                            .background(.white.opacity(0.08))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.2)))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                
                Spacer().frame(height: 20)
            }
            .padding(.top, 120)
        }
        .fullScreenCover(isPresented: $showLevelSelection) {
            LevelSelectionView(levels: levels, unlockedLevels: unlockedLevels, selectedLevel: $selectedLevel)
        }
        .fullScreenCover(item: $selectedLevel) { level in
            GameView(level: level)
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17, (int>>4 & 0xF)*17, (int & 0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16, int>>8 & 0xFF, int & 0xFF)
        case 8: (a,r,g,b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}