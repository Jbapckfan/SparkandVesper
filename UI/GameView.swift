import SwiftUI
import SpriteKit

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