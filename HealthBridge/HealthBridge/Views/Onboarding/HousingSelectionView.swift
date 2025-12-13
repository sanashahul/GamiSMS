import SwiftUI

struct HousingSelectionView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)

                Text("What is your housing situation?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("This helps us connect you with the right services and support.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            // Housing options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(HousingStatus.allCases) { housing in
                        HousingOptionButton(
                            housing: housing,
                            isSelected: userProfile.housingStatus == housing,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    userProfile.housingStatus = housing
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Support message for homeless
            if userProfile.housingStatus == .homeless || userProfile.housingStatus == .shelter {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.orange)
                        Text("We're here to help")
                            .font(.headline)
                    }
                    Text("Many clinics specialize in serving people experiencing housing instability. We'll help you find Healthcare for the Homeless programs and other supportive services.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(userProfile.housingStatus != nil ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(userProfile.housingStatus == nil)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut, value: userProfile.housingStatus)
    }
}

struct HousingOptionButton: View {
    let housing: HousingStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: housing.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .orange)
                    .frame(width: 40)

                Text(housing.displayName)
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
                    .fill(isSelected ? Color.orange : Color(.systemGray6))
            )
        }
    }
}

#Preview {
    HousingSelectionView(onContinue: {})
        .environmentObject(UserProfile())
}
