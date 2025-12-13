import SwiftUI

struct HealthNeedsView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)

                Text("What healthcare do you need?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Select all that apply. This helps us show you the most relevant clinics and resources.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)

            // Health concerns grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(HealthConcern.allCases) { concern in
                        HealthConcernButton(
                            concern: concern,
                            isSelected: userProfile.healthConcerns.contains(concern),
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    toggleConcern(concern)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // Selected count
            if !userProfile.healthConcerns.isEmpty {
                Text("\(userProfile.healthConcerns.count) selected")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }

    private func toggleConcern(_ concern: HealthConcern) {
        if let index = userProfile.healthConcerns.firstIndex(of: concern) {
            userProfile.healthConcerns.remove(at: index)
        } else {
            userProfile.healthConcerns.append(concern)
        }
    }
}

struct HealthConcernButton: View {
    let concern: HealthConcern
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.red.opacity(0.2) : Color(.systemGray6))
                        .frame(width: 50, height: 50)

                    Image(systemName: concern.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? .red : .secondary)
                }

                Text(concern.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.red.opacity(0.1) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.red : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    HealthNeedsView(onContinue: {})
        .environmentObject(UserProfile())
}
