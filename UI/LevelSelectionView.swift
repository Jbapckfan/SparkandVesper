import SwiftUI

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