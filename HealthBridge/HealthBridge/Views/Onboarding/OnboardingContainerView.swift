import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var userProfile: UserProfile
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0

    // Calculate total steps dynamically based on service selections
    var totalSteps: Int {
        var steps = 4 // Welcome, Name, Service Selection, Location, Complete
        if userProfile.selectedServiceAreas.contains(.healthcare) { steps += 2 }
        if userProfile.selectedServiceAreas.contains(.employment) { steps += 2 }
        if userProfile.selectedServiceAreas.contains(.housing) { steps += 2 }
        return steps
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.green.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (hide on welcome)
                if currentStep > 0 {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                        .padding(.top)
                }

                // Content
                Group {
                    switch currentStep {
                    case 0:
                        WelcomeView(onContinue: { withAnimation { currentStep = 1 } })
                    case 1:
                        NameInputView(onContinue: { withAnimation { currentStep = 2 } })
                    case 2:
                        ServiceSelectionView(onContinue: { withAnimation { currentStep = 3 } })
                    default:
                        dynamicStepView
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
    }

    // Helper enum to determine which view to show
    enum DynamicStepType {
        case locationInput
        case onboardingComplete
        case healthcareQuestions1
        case healthcareQuestions2
        case employmentQuestions1
        case employmentQuestions2
        case housingQuestions1
        case housingQuestions2
    }

    // Compute which step type to show (non-ViewBuilder logic)
    func computeStepType() -> DynamicStepType {
        let stepAfterServiceSelection = currentStep - 3
        let services = Array(userProfile.selectedServiceAreas).sorted { $0.rawValue < $1.rawValue }

        // Handle empty services case
        if services.isEmpty {
            if stepAfterServiceSelection == 0 {
                return .locationInput
            } else {
                return .onboardingComplete
            }
        }

        // Calculate total service steps
        let totalServiceSteps = services.count * 2

        // Check if we're past all service questions
        if stepAfterServiceSelection >= totalServiceSteps {
            if stepAfterServiceSelection == totalServiceSteps {
                return .locationInput
            } else {
                return .onboardingComplete
            }
        }

        // Figure out where we are in the flow
        var stepsConsumed = 0
        var currentServiceIndex = 0
        var questionSetIndex = 0

        for (index, _) in services.enumerated() {
            if stepAfterServiceSelection < stepsConsumed + 2 {
                currentServiceIndex = index
                questionSetIndex = stepAfterServiceSelection - stepsConsumed
                break
            }
            stepsConsumed += 2
        }

        // Return the appropriate step type
        let service = services[currentServiceIndex]
        switch service {
        case .healthcare:
            return questionSetIndex == 0 ? .healthcareQuestions1 : .healthcareQuestions2
        case .employment:
            return questionSetIndex == 0 ? .employmentQuestions1 : .employmentQuestions2
        case .housing:
            return questionSetIndex == 0 ? .housingQuestions1 : .housingQuestions2
        }
    }

    // Dynamic step views based on service selections
    @ViewBuilder
    var dynamicStepView: some View {
        switch computeStepType() {
        case .locationInput:
            LocationView(onContinue: { withAnimation { currentStep += 1 } })
        case .onboardingComplete:
            OnboardingCompleteView(onComplete: {
                userProfile.save()
                withAnimation {
                    hasCompletedOnboarding = true
                }
            })
        case .healthcareQuestions1:
            HealthcareQuestions1View(onContinue: { withAnimation { currentStep += 1 } })
        case .healthcareQuestions2:
            HealthcareQuestions2View(onContinue: { withAnimation { currentStep += 1 } })
        case .employmentQuestions1:
            EmploymentQuestions1View(onContinue: { withAnimation { currentStep += 1 } })
        case .employmentQuestions2:
            EmploymentQuestions2View(onContinue: { withAnimation { currentStep += 1 } })
        case .housingQuestions1:
            HousingQuestions1View(onContinue: { withAnimation { currentStep += 1 } })
        case .housingQuestions2:
            HousingQuestions2View(onContinue: { withAnimation { currentStep += 1 } })
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            // App icon/logo
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .green],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)

                Image(systemName: "hands.sparkles.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("CareConnect")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)

                Text("Your path to healthcare, jobs, and housing")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "cross.case.fill", color: .red,
                          title: "Healthcare",
                          subtitle: "Find clinics and get the care you need")

                FeatureRow(icon: "briefcase.fill", color: .blue,
                          title: "Employment",
                          subtitle: "Job search, training, and career help")

                FeatureRow(icon: "house.fill", color: .green,
                          title: "Housing",
                          subtitle: "Shelters, programs, and stable housing")
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: onContinue) {
                HStack {
                    Text("Get Started")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Name Input View
struct NameInputView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)

                Text("What's your name?")
                    .font(.title.bold())

                Text("We'll use this to personalize your experience")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            TextField("Enter your name", text: $userProfile.name)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .focused($isFocused)

            Spacer()

            Button(action: {
                isFocused = false
                onContinue()
            }) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(userProfile.name.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(userProfile.name.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .onTapGesture { isFocused = false }
    }
}

// MARK: - Service Selection View
struct ServiceSelectionView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("Hi, \(userProfile.name)!")
                    .font(.title.bold())

                Text("What do you need help with?")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                ForEach(ServiceArea.allCases) { service in
                    ServiceAreaCard(
                        service: service,
                        isSelected: userProfile.selectedServiceAreas.contains(service),
                        onToggle: {
                            if userProfile.selectedServiceAreas.contains(service) {
                                userProfile.selectedServiceAreas.remove(service)
                            } else {
                                userProfile.selectedServiceAreas.insert(service)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(userProfile.selectedServiceAreas.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(userProfile.selectedServiceAreas.isEmpty)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
}

struct ServiceAreaCard: View {
    let service: ServiceArea
    let isSelected: Bool
    let onToggle: () -> Void

    var serviceColor: Color {
        switch service {
        case .healthcare: return .red
        case .employment: return .blue
        case .housing: return .green
        }
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                Image(systemName: service.icon)
                    .font(.title)
                    .foregroundColor(serviceColor)
                    .frame(width: 50)

                VStack(alignment: .leading, spacing: 4) {
                    Text(service.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(service.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? serviceColor : .gray)
            }
            .padding()
            .background(isSelected ? serviceColor.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? serviceColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    OnboardingContainerView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
