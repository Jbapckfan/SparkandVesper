import SwiftUI

struct MeterView: View {
    var colorA: Color
    var colorB: Color
    @Binding var value: CGFloat  // 0...1
    @State private var smoothed: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.black.opacity(0.4))
                
                // Fill bar with gradient
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [colorA, colorB, Color.white.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * smoothed)
                    .shadow(color: colorB.opacity(0.8), radius: 8, x: 0, y: 0)
                    .animation(.easeOut(duration: 0.2), value: smoothed)
            }
            .onChange(of: value) { oldValue, newValue in
                withAnimation(.easeOut(duration: 0.2)) {
                    smoothed = newValue
                }
            }
            .onAppear {
                smoothed = value
            }
        }
        .frame(height: 10)
    }
}

struct PulseDivider: View {
    var proximity: CGFloat  // 0..1
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 1, green: 0.84, blue: 0).opacity(0.4 + 0.6 * proximity),
                        Color(red: 0.42, green: 0.27, blue: 0.76).opacity(0.4 + 0.6 * proximity)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 6)
            .shadow(color: .yellow.opacity(proximity), radius: 10 + 30 * proximity)
            .shadow(color: .purple.opacity(proximity), radius: 10 + 30 * proximity)
            .animation(.easeInOut(duration: 0.8), value: proximity)
    }
}

// MARK: - HUD Container

struct GameHUD: View {
    @ObservedObject var gameManager = GameManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // Top bar with level and timer
            HStack {
                Text(gameManager.levelTitle)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.9))
                
                Spacer()
                
                Text(gameManager.timerString)
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            
            // Meters
            VStack(spacing: 12) {
                // Surge meter (Spark)
                HStack(spacing: 8) {
                    Text("SURGE")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1, green: 0.84, blue: 0))
                        .frame(width: 50, alignment: .leading)
                    
                    MeterView(
                        colorA: Color(red: 1, green: 0.84, blue: 0),
                        colorB: Color(red: 1, green: 0.42, blue: 0.21),
                        value: $gameManager.surge
                    )
                }
                
                // Flow meter (Vesper)
                HStack(spacing: 8) {
                    Text("FLOW")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 0.42, green: 0.27, blue: 0.76))
                        .frame(width: 50, alignment: .leading)
                    
                    MeterView(
                        colorA: Color(red: 0.42, green: 0.27, blue: 0.76),
                        colorB: Color(red: 0.90, green: 0.90, blue: 0.98),
                        value: $gameManager.flow
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // Proximity divider
            PulseDivider(proximity: gameManager.proximityStrength)
                .padding(.horizontal, 0)
        }
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [
                    Color.black.opacity(0.8),
                    Color.black.opacity(0.4)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

// MARK: - Win Screen

struct WinScreen: View {
    let time: Int
    let levelIndex: Int
    let hasNextLevel: Bool
    let onRestart: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Title
                Text("HARMONIZED")
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 1, green: 0.84, blue: 0),
                                Color(red: 0.42, green: 0.27, blue: 0.76)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 20)
                    .shadow(color: .purple.opacity(0.5), radius: 20)
                
                // Time
                VStack(spacing: 8) {
                    Text("COMPLETED IN")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(String(format: "%02d:%02d", time / 60, time % 60))
                        .font(.system(size: 28, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Buttons
                HStack(spacing: 24) {
                    Button(action: onRestart) {
                        Text("RESTART")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                    }
                    
                    if hasNextLevel {
                        Button(action: onNext) {
                            Text("NEXT LEVEL")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(.black)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 1, green: 0.84, blue: 0),
                                            Color(red: 0.42, green: 0.27, blue: 0.76)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                                .shadow(color: .yellow.opacity(0.5), radius: 10)
                                .shadow(color: .purple.opacity(0.5), radius: 10)
                        }
                    }
                }
            }
            .padding(40)
        }
    }
}