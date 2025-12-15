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

                Text("Welcome, \(userProfile.name.isEmpty ? "friend" : userProfile.name)!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .opacity(showConfetti ? 1 : 0)
            .animation(.easeIn.delay(0.3), value: showConfetti)

            Spacer()

            // Summary based on selected services
            VStack(alignment: .leading, spacing: 16) {
                Text("We'll help you with:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 12) {
                    // Healthcare summary
                    if userProfile.needsHealthcare {
                        SummaryItem(
                            icon: "cross.case.fill",
                            color: .red,
                            text: healthcareSummary
                        )
                    }

                    // Employment summary
                    if userProfile.needsEmployment {
                        SummaryItem(
                            icon: "briefcase.fill",
                            color: .blue,
                            text: employmentSummary
                        )
                    }

                    // Housing summary
                    if userProfile.needsHousing {
                        SummaryItem(
                            icon: "house.fill",
                            color: .green,
                            text: housingSummary
                        )
                    }

                    // Additional services
                    if userProfile.needsIDHelp {
                        SummaryItem(
                            icon: "person.text.rectangle",
                            color: .orange,
                            text: "Help getting ID documents"
                        )
                    }

                    if userProfile.isVeteran {
                        SummaryItem(
                            icon: "star.fill",
                            color: .purple,
                            text: "Veteran-specific programs and services"
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
                    Text("Let's Go!")
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

    private var healthcareSummary: String {
        var parts: [String] = []
        if userProfile.insuranceStatus == .none || userProfile.insuranceStatus == .unsure {
            parts.append("free clinics")
        }
        if userProfile.needsMentalHealthSupport {
            parts.append("mental health support")
        }
        if userProfile.needsDentalCare {
            parts.append("dental care")
        }
        if parts.isEmpty {
            return "Healthcare clinics in your area"
        }
        return "Find " + parts.joined(separator: ", ")
    }

    private var employmentSummary: String {
        var parts: [String] = []
        if !userProfile.hasResume {
            parts.append("resume help")
        }
        if userProfile.needsJobTraining {
            parts.append("job training")
        }
        if userProfile.employmentStatus == .unemployedLooking {
            parts.append("job placement")
        }
        if parts.isEmpty {
            return "Employment resources and opportunities"
        }
        return "Connect you with " + parts.joined(separator: ", ")
    }

    private var housingSummary: String {
        switch userProfile.currentHousingSituation {
        case .street, .vehicle:
            return "Emergency shelter and housing programs"
        case .shelter:
            return "Transitional housing and permanent housing options"
        case .temporaryWithOthers:
            return "Housing assistance and waitlist signup"
        case .motel:
            return "Affordable housing and rental assistance"
        case .transitionHousing:
            return "Permanent housing options and support"
        }
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
