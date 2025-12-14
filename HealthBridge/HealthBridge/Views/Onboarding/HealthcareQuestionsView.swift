import SwiftUI

// MARK: - Healthcare Questions Part 1 (Insurance, Urgent Needs, Chronic Conditions)
struct HealthcareQuestions1View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("Healthcare Needs")
                        .font(.title.bold())
                    Text("Let's understand your health situation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q1: Insurance Status
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have health insurance?", systemImage: "creditcard")
                        .font(.headline)

                    ForEach(InsuranceStatus.allCases) { status in
                        SelectionButton(
                            title: status.displayName,
                            isSelected: userProfile.insuranceStatus == status,
                            action: { userProfile.insuranceStatus = status }
                        )
                    }
                }
                .padding(.horizontal)

                // Q2: Urgent Health Needs
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have any urgent health needs?", systemImage: "exclamationmark.triangle")
                        .font(.headline)

                    ForEach(UrgentHealthNeed.allCases) { need in
                        SelectionButton(
                            title: need.displayName,
                            isSelected: userProfile.urgentHealthNeeds == need,
                            action: { userProfile.urgentHealthNeeds = need }
                        )
                    }
                }
                .padding(.horizontal)

                // Q3: Chronic Conditions
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have any chronic conditions?", systemImage: "heart.text.square")
                        .font(.headline)

                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(ChronicCondition.allCases) { condition in
                            MultiSelectButton(
                                title: condition.displayName,
                                isSelected: userProfile.chronicConditions.contains(condition),
                                action: {
                                    if userProfile.chronicConditions.contains(condition) {
                                        userProfile.chronicConditions.removeAll { $0 == condition }
                                    } else {
                                        if condition == .none {
                                            userProfile.chronicConditions = [.none]
                                        } else {
                                            userProfile.chronicConditions.removeAll { $0 == .none }
                                            userProfile.chronicConditions.append(condition)
                                        }
                                    }
                                }
                            )
                        }
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
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Healthcare Questions Part 2 (Mental Health, Dental, Medications)
struct HealthcareQuestions2View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "cross.case.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("More About Your Health")
                        .font(.title.bold())
                    Text("A few more questions to personalize your care")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q4: Mental Health Support
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you need mental health support?", systemImage: "brain.head.profile")
                        .font(.headline)

                    Text("Counseling, therapy, or emotional support")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.needsMentalHealthSupport,
                            action: { userProfile.needsMentalHealthSupport = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.needsMentalHealthSupport,
                            action: { userProfile.needsMentalHealthSupport = false }
                        )
                    }
                }
                .padding(.horizontal)

                // Q5: Dental Care
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you need dental care?", systemImage: "mouth")
                        .font(.headline)

                    Text("Teeth cleaning, fillings, extractions, etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.needsDentalCare,
                            action: { userProfile.needsDentalCare = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.needsDentalCare,
                            action: { userProfile.needsDentalCare = false }
                        )
                    }
                }
                .padding(.horizontal)

                // Q6: Medications
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you need help getting medications?", systemImage: "pills")
                        .font(.headline)

                    Text("Prescription assistance or refills")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.needsMedications,
                            action: { userProfile.needsMedications = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.needsMedications,
                            action: { userProfile.needsMedications = false }
                        )
                    }
                }
                .padding(.horizontal)

                // Summary of selections
                if userProfile.insuranceStatus == .none || userProfile.insuranceStatus == .unsure {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("Don't worry! We'll help you find free clinics and insurance options.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
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
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Reusable Selection Components
struct SelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

struct MultiSelectButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .cornerRadius(10)
        }
    }
}

struct YesNoButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(12)
        }
    }
}

#Preview {
    HealthcareQuestions1View(onContinue: {})
        .environmentObject(UserProfile())
}
