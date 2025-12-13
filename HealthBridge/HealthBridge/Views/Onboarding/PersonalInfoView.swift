import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    @State private var showDatePicker = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.teal)

                Text("Tell us about yourself")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("This information helps us personalize your experience.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // Form
            ScrollView {
                VStack(spacing: 20) {
                    // Name
                    FormField(
                        icon: "person",
                        title: "What's your name?",
                        placeholder: "Enter your name"
                    ) {
                        TextField("Your name", text: $userProfile.name)
                            .textContentType(.name)
                    }

                    // Country of origin
                    FormField(
                        icon: "globe.americas",
                        title: "Where are you from?",
                        placeholder: "Country of origin"
                    ) {
                        TextField("Country", text: $userProfile.countryOfOrigin)
                    }

                    // Arrival date
                    FormField(
                        icon: "calendar",
                        title: "When did you arrive?",
                        placeholder: "Approximate date"
                    ) {
                        DatePicker(
                            "Arrival Date",
                            selection: Binding(
                                get: { userProfile.arrivalDate ?? Date() },
                                set: { userProfile.arrivalDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }

                    // Family
                    FormField(
                        icon: "figure.2.and.child.holdinghands",
                        title: "Do you have children?",
                        placeholder: ""
                    ) {
                        Toggle("I have children", isOn: $userProfile.hasChildren)
                            .tint(.teal)
                    }

                    if userProfile.hasChildren {
                        FormField(
                            icon: "number",
                            title: "How many children?",
                            placeholder: ""
                        ) {
                            Stepper("\(userProfile.numberOfChildren) child(ren)", value: $userProfile.numberOfChildren, in: 1...10)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Transportation
                    FormField(
                        icon: "car",
                        title: "Do you have transportation?",
                        placeholder: ""
                    ) {
                        Toggle("I have reliable transportation", isOn: $userProfile.hasTransportation)
                            .tint(.teal)
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
        .animation(.easeInOut, value: userProfile.hasChildren)
    }
}

struct FormField<Content: View>: View {
    let icon: String
    let title: String
    let placeholder: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.teal)
                    .frame(width: 24)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }

            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
}

#Preview {
    PersonalInfoView(onContinue: {})
        .environmentObject(UserProfile())
}
