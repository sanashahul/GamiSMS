import SwiftUI

// MARK: - Housing Questions Part 1 (Current Situation, Waitlist, Income)
struct HousingQuestions1View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("Housing Situation")
                        .font(.title.bold())
                    Text("Let's understand your housing needs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q1: Current Housing Situation
                VStack(alignment: .leading, spacing: 12) {
                    Label("Where are you currently staying?", systemImage: "location")
                        .font(.headline)

                    ForEach(CurrentHousingSituation.allCases) { situation in
                        HousingSituationButton(
                            situation: situation,
                            isSelected: userProfile.currentHousingSituation == situation,
                            action: { userProfile.currentHousingSituation = situation }
                        )
                    }
                }
                .padding(.horizontal)

                // Q2: Housing Waitlist
                VStack(alignment: .leading, spacing: 12) {
                    Label("Are you on any housing waitlists?", systemImage: "list.clipboard")
                        .font(.headline)

                    Text("Section 8, public housing, etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.isOnHousingWaitlist,
                            action: { userProfile.isOnHousingWaitlist = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.isOnHousingWaitlist,
                            action: { userProfile.isOnHousingWaitlist = false }
                        )
                    }

                    if !userProfile.isOnHousingWaitlist {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("We can help you get on waitlists")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)

                // Q3: Income for Rent
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have income to pay rent?", systemImage: "dollarsign.circle")
                        .font(.headline)

                    Text("Even partial income counts")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.hasIncomeForRent,
                            action: { userProfile.hasIncomeForRent = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.hasIncomeForRent,
                            action: { userProfile.hasIncomeForRent = false }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct HousingSituationButton: View {
    let situation: CurrentHousingSituation
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: situation.icon)
                    .font(.title3)
                    .frame(width: 30)
                    .foregroundColor(isSelected ? .white : .green)

                Text(situation.displayName)
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.green : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Housing Questions Part 2 (Barriers, ID, Family)
struct HousingQuestions2View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                    Text("More About Your Situation")
                        .font(.title.bold())
                    Text("This helps us find the right programs for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q4: Housing Barriers
                VStack(alignment: .leading, spacing: 12) {
                    Label("What barriers do you face in getting housing?", systemImage: "exclamationmark.triangle")
                        .font(.headline)

                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(HousingBarrier.allCases) { barrier in
                            MultiSelectButton(
                                title: barrier.displayName,
                                isSelected: userProfile.housingBarriers.contains(barrier),
                                action: {
                                    if userProfile.housingBarriers.contains(barrier) {
                                        userProfile.housingBarriers.removeAll { $0 == barrier }
                                    } else {
                                        userProfile.housingBarriers.append(barrier)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)

                // Q5: ID Documents
                VStack(alignment: .leading, spacing: 12) {
                    Label("What ID documents do you have?", systemImage: "person.text.rectangle")
                        .font(.headline)

                    ForEach(IDDocumentStatus.allCases) { status in
                        SelectionButton(
                            title: status.displayName,
                            isSelected: userProfile.idDocumentStatus == status,
                            action: { userProfile.idDocumentStatus = status }
                        )
                    }
                }
                .padding(.horizontal)

                // Q6: Family Status
                VStack(alignment: .leading, spacing: 12) {
                    Label("What best describes your situation?", systemImage: "person.2")
                        .font(.headline)

                    ForEach(FamilyStatus.allCases) { status in
                        SelectionButton(
                            title: status.displayName,
                            isSelected: userProfile.familyStatus == status,
                            action: { userProfile.familyStatus = status }
                        )
                    }
                }
                .padding(.horizontal)

                // Special programs info
                if userProfile.familyStatus == .veteran {
                    InfoBanner(
                        icon: "star.fill",
                        text: "As a veteran, you may qualify for special VA housing programs.",
                        color: .purple
                    )
                    .padding(.horizontal)
                }

                if userProfile.hasChildren {
                    InfoBanner(
                        icon: "figure.2.and.child.holdinghands",
                        text: "Families with children often get priority for certain housing programs.",
                        color: .orange
                    )
                    .padding(.horizontal)
                }

                Spacer(minLength: 100)
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

struct InfoBanner: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    HousingQuestions1View(onContinue: {})
        .environmentObject(UserProfile())
}
