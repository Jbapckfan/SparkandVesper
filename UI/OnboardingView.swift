import SwiftUI
import SpriteKit

// MARK: - Onboarding View
struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                // Progress indicator
                ProgressBar(progress: viewModel.progress)
                    .frame(height: 4)
                    .padding(.top, 50)

                // Tutorial content
                TabView(selection: $viewModel.currentStep) {
                    ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                        TutorialStepView(step: step, viewModel: viewModel)
                            .tag(step)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)

                // Navigation buttons
                HStack(spacing: 20) {
                    if viewModel.currentStep > 0 {
                        Button(action: viewModel.previousStep) {
                            Text("Back")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 100, height: 44)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(22)
                        }
                    }

                    Spacer()

                    if viewModel.canSkip {
                        Button(action: skipTutorial) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }

                    Button(action: handleNextAction) {
                        Text(viewModel.nextButtonTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 120, height: 44)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.8, blue: 0.4),
                                        Color(red: 1.0, green: 0.6, blue: 0.2)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(22)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            appState.analytics.trackEvent(.tutorialStart)
        }
    }

    private func handleNextAction() {
        if viewModel.isLastStep {
            completeTutorial()
        } else {
            viewModel.nextStep()
        }
    }

    private func skipTutorial() {
        appState.analytics.trackEvent(.tutorialSkipped)
        dismiss()
    }

    private func completeTutorial() {
        appState.analytics.trackTutorialComplete(duration: viewModel.elapsedTime)
        appState.playerProfile.levelsCompleted.insert(0) // Mark tutorial as complete
        appState.playerProfile.save()
        dismiss()
    }
}

// MARK: - Tutorial Step View
struct TutorialStepView: View {
    let step: Int
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 30) {
            switch step {
            case 0:
                WelcomeStep()
            case 1:
                CharacterIntroStep()
            case 2:
                ControlsStep()
            case 3:
                MechanicsStep()
            case 4:
                ObjectivesStep()
            case 5:
                InteractiveStep(viewModel: viewModel)
            default:
                EmptyView()
            }
        }
        .padding(.horizontal, 30)
    }
}

// MARK: - Tutorial Steps

struct WelcomeStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                .shadow(color: Color(red: 1.0, green: 0.8, blue: 0.4), radius: 20)

            Text("Welcome to\nSpark & Vesper")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("A journey of light and flow\nacross parallel worlds")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 10)

            Spacer()
        }
    }
}

struct CharacterIntroStep: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            HStack(spacing: 50) {
                // Spark character
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.9, blue: 0.6),
                                        Color(red: 1.0, green: 0.7, blue: 0.3),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)

                        Circle()
                            .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                            .frame(width: 50, height: 50)
                    }

                    Text("SPARK")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))

                    Text("Electric energy\nDrag to move")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Vesper character
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.4, green: 0.6, blue: 1.0),
                                        Color(red: 0.2, green: 0.4, blue: 0.9),
                                        Color.clear
                                    ]),
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)

                        Circle()
                            .fill(Color(red: 0.4, green: 0.6, blue: 1.0))
                            .frame(width: 50, height: 50)
                    }

                    Text("VESPER")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(red: 0.4, green: 0.6, blue: 1.0))

                    Text("Fluid flow\nTap to guide")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
            }

            Text("Two souls, one destiny")
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white)
                .padding(.top, 20)

            Spacer()
        }
    }
}

struct ControlsStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("How to Play")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)

            VStack(alignment: .leading, spacing: 25) {
                ControlRow(
                    icon: "hand.draw",
                    color: Color(red: 1.0, green: 0.8, blue: 0.4),
                    title: "Drag Spark",
                    description: "Hold and drag to move Spark through the upper world"
                )

                ControlRow(
                    icon: "hand.tap",
                    color: Color(red: 0.4, green: 0.6, blue: 1.0),
                    title: "Tap for Vesper",
                    description: "Tap anywhere to guide Vesper's flow in the lower world"
                )

                ControlRow(
                    icon: "circle.hexagongrid.circle",
                    color: Color.purple,
                    title: "Proximity Power",
                    description: "Keep them close to slow time and boost abilities"
                )

                ControlRow(
                    icon: "flag.checkered",
                    color: Color.green,
                    title: "Reach Portals",
                    description: "Guide both characters to their matching portals"
                )
            }

            Spacer()
        }
    }
}

struct MechanicsStep: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("World Mechanics")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 40)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                MechanicCard(
                    icon: "wind",
                    title: "Windmills",
                    description: "Circle to generate power",
                    color: .cyan
                )

                MechanicCard(
                    icon: "flame",
                    title: "Heat Plates",
                    description: "Stand to melt ice",
                    color: .orange
                )

                MechanicCard(
                    icon: "snowflake",
                    title: "Ice Walls",
                    description: "Block paths until melted",
                    color: Color(red: 0.7, green: 0.9, blue: 1.0)
                )

                MechanicCard(
                    icon: "bolt.shield",
                    title: "Barriers",
                    description: "Need energy to pass",
                    color: .purple
                )

                MechanicCard(
                    icon: "bridge",
                    title: "Bridges",
                    description: "Extend with wind power",
                    color: .brown
                )

                MechanicCard(
                    icon: "sparkles",
                    title: "Resonance",
                    description: "Proximity boosts power",
                    color: .pink
                )
            }

            Spacer()
        }
    }
}

struct ObjectivesStep: View {
    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("Your Mission")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 20) {
                ObjectiveRow(number: "1", text: "Master dual-world controls")
                ObjectiveRow(number: "2", text: "Solve environmental puzzles")
                ObjectiveRow(number: "3", text: "Synchronize movements")
                ObjectiveRow(number: "4", text: "Reach both portals together")
            }
            .padding(.horizontal, 20)

            Text("Ready to begin?")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .padding(.top, 30)

            Spacer()
        }
    }
}

struct InteractiveStep: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var sparkPosition = CGPoint(x: 100, y: 150)
    @State private var vesperPosition = CGPoint(x: 100, y: 150)
    @State private var completed = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Try it out!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)

            // Mini game area
            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    // Portals
                    Group {
                        // Spark portal
                        Circle()
                            .fill(Color(red: 1.0, green: 0.8, blue: 0.4).opacity(0.3))
                            .frame(width: 60, height: 60)
                            .position(x: geometry.size.width - 50, y: geometry.size.height * 0.3)

                        // Vesper portal
                        Circle()
                            .fill(Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3))
                            .frame(width: 60, height: 60)
                            .position(x: geometry.size.width - 50, y: geometry.size.height * 0.7)
                    }

                    // Characters
                    Circle()
                        .fill(Color(red: 1.0, green: 0.8, blue: 0.4))
                        .frame(width: 30, height: 30)
                        .position(sparkPosition)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    sparkPosition = value.location
                                    checkCompletion(in: geometry.size)
                                }
                        )

                    Circle()
                        .fill(Color(red: 0.4, green: 0.6, blue: 1.0))
                        .frame(width: 30, height: 30)
                        .position(vesperPosition)
                        .onTapGesture { location in
                            withAnimation(.easeOut(duration: 0.3)) {
                                vesperPosition = location
                            }
                            checkCompletion(in: geometry.size)
                        }
                }
            }
            .frame(height: 300)
            .padding(.horizontal)

            if completed {
                Text("Perfect! You're ready!")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.green)
                    .transition(.scale)
            } else {
                Text("Drag Spark and tap to move Vesper\nto their matching portals")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func checkCompletion(in size: CGSize) {
        let sparkAtPortal = distance(
            from: sparkPosition,
            to: CGPoint(x: size.width - 50, y: size.height * 0.3)
        ) < 40

        let vesperAtPortal = distance(
            from: vesperPosition,
            to: CGPoint(x: size.width - 50, y: size.height * 0.7)
        ) < 40

        if sparkAtPortal && vesperAtPortal && !completed {
            completed = true
            viewModel.completeInteractiveTutorial()
        }
    }

    private func distance(from: CGPoint, to: CGPoint) -> CGFloat {
        let dx = from.x - to.x
        let dy = from.y - to.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - Supporting Views

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.1))

                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 1.0, green: 0.8, blue: 0.4),
                                Color(red: 1.0, green: 0.6, blue: 0.2)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
    }
}

struct ControlRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()
        }
    }
}

struct MechanicCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text(description)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ObjectiveRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 20) {
            Text(number)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.4))
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.1))
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.9))

            Spacer()
        }
    }
}

// MARK: - View Model
class OnboardingViewModel: ObservableObject {
    @Published var currentStep = 0
    @Published var interactiveCompleted = false

    let totalSteps = 6
    let startTime = Date()

    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startTime)
    }

    var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }

    var isLastStep: Bool {
        currentStep == totalSteps - 1
    }

    var canSkip: Bool {
        currentStep < totalSteps - 1
    }

    var nextButtonTitle: String {
        if isLastStep {
            return interactiveCompleted ? "Start Playing" : "Complete"
        }
        return "Next"
    }

    func nextStep() {
        guard currentStep < totalSteps - 1 else { return }
        withAnimation {
            currentStep += 1
        }
        AnalyticsManager.shared.trackTutorialProgress(step: currentStep, action: "next")
    }

    func previousStep() {
        guard currentStep > 0 else { return }
        withAnimation {
            currentStep -= 1
        }
        AnalyticsManager.shared.trackTutorialProgress(step: currentStep, action: "back")
    }

    func completeInteractiveTutorial() {
        interactiveCompleted = true
        AnalyticsManager.shared.trackTutorialProgress(step: currentStep, action: "interactive_complete")
    }
}