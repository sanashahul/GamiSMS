import SwiftUI

struct OnboardingCompleteView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onComplete: () -> Void

    @State private var showConfetti = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 150, height: 150)

                Circle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }
            .scaleEffect(showConfetti ? 1 : 0.5)
            .opacity(showConfetti ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showConfetti)

            VStack(spacing: 12) {
                Text("You're All Set!")
                    .font(.largeTitle.bold())

                Text("Welcome to HealthBridge, \(userProfile.name.isEmpty ? "friend" : userProfile.name)!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .opacity(showConfetti ? 1 : 0)
            .animation(.easeIn.delay(0.3), value: showConfetti)

            Spacer()

            // Summary
            VStack(alignment: .leading, spacing: 16) {
                Text("What we'll help you with:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 12) {
                    SummaryItem(
                        icon: "mappin.circle.fill",
                        color: .blue,
                        text: "Find clinics that welcome \(statusText)"
                    )

                    if userProfile.insuranceStatus == .none {
                        SummaryItem(
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            text: "Free and sliding-scale clinics"
                        )
                    }

                    if userProfile.needsInterpreter {
                        SummaryItem(
                            icon: "bubble.left.and.bubble.right.fill",
                            color: .purple,
                            text: "Clinics with \(userProfile.preferredLanguage.displayName) interpreters"
                        )
                    }

                    if !userProfile.healthConcerns.isEmpty {
                        SummaryItem(
                            icon: "heart.fill",
                            color: .red,
                            text: "Care for: \(concernsText)"
                        )
                    }

                    if userProfile.needsHomelessServices {
                        SummaryItem(
                            icon: "hand.raised.fill",
                            color: .orange,
                            text: "Healthcare for the Homeless programs"
                        )
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
            .opacity(showConfetti ? 1 : 0)
            .animation(.easeIn.delay(0.5), value: showConfetti)

            Spacer()

            // Get Started button
            Button(action: onComplete) {
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
            .opacity(showConfetti ? 1 : 0)
            .animation(.easeIn.delay(0.7), value: showConfetti)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showConfetti = true
            }
        }
    }

    private var statusText: String {
        switch userProfile.immigrationStatus {
        case .refugee: return "refugees"
        case .asylumSeeker: return "asylum seekers"
        case .undocumented: return "everyone regardless of status"
        case .visa: return "visa holders"
        case .greenCard: return "green card holders"
        case .citizen: return "all patients"
        case .other, .none: return "everyone"
        }
    }

    private var concernsText: String {
        let concerns = userProfile.healthConcerns.prefix(2).map { $0.displayName }
        if userProfile.healthConcerns.count > 2 {
            return concerns.joined(separator: ", ") + ", and more"
        }
        return concerns.joined(separator: " and ")
    }
}

struct SummaryItem: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    OnboardingCompleteView(onComplete: {})
        .environmentObject(UserProfile())
}
