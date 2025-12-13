import SwiftUI

struct LanguageSelectionView: View {
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
                Image(systemName: "globe")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("What language do you prefer?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("Select your preferred language. You can change this anytime.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            .padding(.horizontal)

            // Language grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(PreferredLanguage.allCases) { language in
                        LanguageButton(
                            language: language,
                            isSelected: userProfile.preferredLanguage == language,
                            action: {
                                withAnimation(.spring(response: 0.3)) {
                                    userProfile.preferredLanguage = language
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

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
}

struct LanguageButton: View {
    let language: PreferredLanguage
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(language.displayName)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    LanguageSelectionView(onContinue: {})
        .environmentObject(UserProfile())
}
