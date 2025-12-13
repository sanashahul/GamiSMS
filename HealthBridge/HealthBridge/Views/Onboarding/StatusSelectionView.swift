import SwiftUI

struct StatusSelectionView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)

                Text("Tell us about your situation")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("This helps us find the right resources for you. Your information is private and secure.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            // Privacy note
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.green)
                Text("Your information stays on your device only")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Status options
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(ImmigrationStatus.allCases) { status in
                        StatusOptionButton(
                            status: status,
                            isSelected: userProfile.immigrationStatus == status,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    userProfile.immigrationStatus = status
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Info box
            if let status = userProfile.immigrationStatus {
                InfoBox(status: status)
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
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
                .background(userProfile.immigrationStatus != nil ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(userProfile.immigrationStatus == nil)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut, value: userProfile.immigrationStatus)
    }
}

struct StatusOptionButton: View {
    let status: ImmigrationStatus
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: status.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .purple)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.displayName)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(status.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.purple : Color(.systemGray6))
            )
        }
    }
}

struct InfoBox: View {
    let status: ImmigrationStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Good to know")
                    .font(.headline)
            }

            Text(infoText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }

    var infoText: String {
        switch status {
        case .refugee:
            return "As a refugee, you may qualify for Medicaid and special refugee health programs. We'll help you find refugee health clinics near you."
        case .asylumSeeker:
            return "Asylum seekers can access emergency medical care and may qualify for certain health programs. Many community health centers serve everyone."
        case .undocumented:
            return "You have the right to emergency care regardless of status. Community health centers and free clinics serve everyone. We'll help you find them."
        case .visa:
            return "Depending on your visa type, you may have different healthcare options. Community health centers offer affordable care for everyone."
        case .greenCard:
            return "Green card holders can qualify for Medicaid and other programs. We'll help you understand your options."
        case .citizen:
            return "You have access to all healthcare programs. We'll help you find the best options based on your needs."
        case .other:
            return "No matter your situation, there are healthcare options available. Community health centers serve everyone regardless of status."
        }
    }
}

#Preview {
    StatusSelectionView(onContinue: {})
        .environmentObject(UserProfile())
}
