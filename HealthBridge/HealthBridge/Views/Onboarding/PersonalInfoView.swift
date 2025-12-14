import SwiftUI

struct PersonalInfoView: View {
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var localization = LocalizationManager.shared
    let onContinue: () -> Void

    @State private var showDatePicker = false
    @FocusState private var focusedField: Field?

    enum Field {
        case name, country
    }

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.teal)

                Text(localization.localized("tell_us_about_yourself"))
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text(localization.localized("personal_info_desc"))
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
                        title: localization.localized("whats_your_name"),
                        placeholder: localization.localized("enter_your_name")
                    ) {
                        TextField(localization.localized("enter_your_name"), text: $userProfile.name)
                            .textContentType(.name)
                            .focused($focusedField, equals: .name)
                            .submitLabel(.next)
                            .onSubmit {
                                focusedField = .country
                            }
                    }

                    // Country of origin
                    FormField(
                        icon: "globe.americas",
                        title: localization.localized("where_are_you_from"),
                        placeholder: localization.localized("country_of_origin")
                    ) {
                        TextField(localization.localized("country_of_origin"), text: $userProfile.countryOfOrigin)
                            .focused($focusedField, equals: .country)
                            .submitLabel(.done)
                            .onSubmit {
                                focusedField = nil
                            }
                    }

                    // Arrival date
                    FormField(
                        icon: "calendar",
                        title: localization.localized("when_did_you_arrive"),
                        placeholder: ""
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
                        title: localization.localized("do_you_have_children"),
                        placeholder: ""
                    ) {
                        Toggle(localization.localized("i_have_children"), isOn: $userProfile.hasChildren)
                            .tint(.teal)
                    }

                    if userProfile.hasChildren {
                        FormField(
                            icon: "number",
                            title: localization.localized("how_many_children"),
                            placeholder: ""
                        ) {
                            Stepper("\(userProfile.numberOfChildren) child(ren)", value: $userProfile.numberOfChildren, in: 1...10)
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Transportation
                    FormField(
                        icon: "car",
                        title: localization.localized("do_you_have_transportation"),
                        placeholder: ""
                    ) {
                        Toggle(localization.localized("i_have_transportation"), isOn: $userProfile.hasTransportation)
                            .tint(.teal)
                    }
                }
                .padding(.horizontal)
            }
            .scrollDismissesKeyboard(.interactively)

            Spacer()

            // Continue button
            Button(action: {
                focusedField = nil
                onContinue()
            }) {
                HStack {
                    Text(localization.localized("continue"))
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
        .contentShape(Rectangle())
        .onTapGesture {
            focusedField = nil
        }
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
