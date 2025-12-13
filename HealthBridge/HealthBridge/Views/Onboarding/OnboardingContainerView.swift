import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var userProfile: UserProfile
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentStep = 0

    let totalSteps = 8

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.teal.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                if currentStep > 0 {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                        .padding(.top)
                }

                // Content
                TabView(selection: $currentStep) {
                    WelcomeView(onContinue: { currentStep = 1 })
                        .tag(0)

                    LanguageSelectionView(onContinue: { currentStep = 2 })
                        .tag(1)

                    StatusSelectionView(onContinue: { currentStep = 3 })
                        .tag(2)

                    HousingSelectionView(onContinue: { currentStep = 4 })
                        .tag(3)

                    PersonalInfoView(onContinue: { currentStep = 5 })
                        .tag(4)

                    HealthNeedsView(onContinue: { currentStep = 6 })
                        .tag(5)

                    InsuranceView(onContinue: { currentStep = 7 })
                        .tag(6)

                    LocationView(onContinue: { currentStep = 8 })
                        .tag(7)

                    OnboardingCompleteView(onComplete: {
                        userProfile.save()
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    })
                    .tag(8)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
            }
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
                        colors: [.blue, .teal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)

                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }

            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)

                Text("HealthBridge")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primary)

                Text("Your guide to healthcare in a new country")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            // Features list
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "mappin.circle.fill", color: .blue,
                          title: "Find Care Near You",
                          subtitle: "Locate clinics that welcome everyone")

                FeatureRow(icon: "calendar.badge.plus", color: .green,
                          title: "Easy Appointments",
                          subtitle: "Schedule visits with one tap")

                FeatureRow(icon: "book.fill", color: .purple,
                          title: "Learn the System",
                          subtitle: "Understand your healthcare rights")

                FeatureRow(icon: "globe", color: .orange,
                          title: "Your Language",
                          subtitle: "Available in multiple languages")
            }
            .padding(.horizontal, 30)

            Spacer()

            Button(action: onContinue) {
                HStack {
                    Text("Let's Get Started")
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
