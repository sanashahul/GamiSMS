import SwiftUI

struct InsuranceView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)

                Text("Do you have health insurance?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Don't worry if you don't - we'll help you find care regardless of insurance status.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            // Insurance options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(InsuranceStatus.allCases) { insurance in
                        InsuranceOptionButton(
                            insurance: insurance,
                            isSelected: userProfile.insuranceStatus == insurance,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    userProfile.insuranceStatus = insurance
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Info based on selection
            InsuranceInfoBox(status: userProfile.insuranceStatus, profile: userProfile)
                .padding(.horizontal)

            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
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
        .animation(.easeInOut, value: userProfile.insuranceStatus)
    }
}

struct InsuranceOptionButton: View {
    let insurance: InsuranceStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconFor(insurance))
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .green)
                    .frame(width: 40)

                Text(insurance.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green : Color(.systemGray6))
            )
        }
    }

    private func iconFor(_ insurance: InsuranceStatus) -> String {
        switch insurance {
        case .none: return "xmark.circle"
        case .medicaid: return "checkmark.seal"
        case .medicare: return "checkmark.seal"
        case .marketplace: return "cart"
        case .employer: return "building.2"
        case .emergencyMedicaid: return "staroflife"
        case .unsure: return "questionmark.circle"
        }
    }
}

struct InsuranceInfoBox: View {
    let status: InsuranceStatus
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("What this means for you")
                    .font(.headline)
            }

            Text(infoText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(12)
    }

    var infoText: String {
        switch status {
        case .none:
            if profile.mayQualifyForMedicaid {
                return "Based on your status, you may qualify for Medicaid! We'll help you find clinics that can help you apply. In the meantime, community health centers offer sliding-scale fees based on income."
            } else {
                return "No problem! Community health centers and free clinics provide care regardless of insurance. You may also qualify for Emergency Medicaid for urgent situations."
            }
        case .medicaid, .medicare:
            return "Great! Many clinics accept Medicaid/Medicare. We'll show you providers in your network."
        case .marketplace:
            return "We'll help you find in-network providers to get the most from your coverage."
        case .employer:
            return "We'll help you find providers that accept your insurance plan."
        case .emergencyMedicaid:
            return "Emergency Medicaid covers urgent care needs. We'll also show you clinics that offer ongoing care options."
        case .unsure:
            return "That's okay! We can help you figure out what coverage you might have or qualify for. Community health centers can also help you apply for programs."
        }
    }
}

#Preview {
    InsuranceView(onContinue: {})
        .environmentObject(UserProfile())
}
