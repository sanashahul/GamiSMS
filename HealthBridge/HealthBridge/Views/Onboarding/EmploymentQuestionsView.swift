import SwiftUI

// MARK: - Employment Questions Part 1 (Status, Work Type, Resume)
struct EmploymentQuestions1View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Employment Needs")
                        .font(.title.bold())
                    Text("Let's understand your job situation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q1: Employment Status
                VStack(alignment: .leading, spacing: 12) {
                    Label("What is your current employment status?", systemImage: "person.badge.clock")
                        .font(.headline)

                    ForEach(EmploymentStatus.allCases) { status in
                        SelectionButton(
                            title: status.displayName,
                            isSelected: userProfile.employmentStatus == status,
                            action: { userProfile.employmentStatus = status }
                        )
                    }
                }
                .padding(.horizontal)

                // Q2: Preferred Work Types
                VStack(alignment: .leading, spacing: 12) {
                    Label("What type of work are you interested in?", systemImage: "hammer")
                        .font(.headline)

                    Text("Select all that apply")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(WorkType.allCases) { workType in
                            MultiSelectButton(
                                title: workType.displayName,
                                isSelected: userProfile.preferredWorkTypes.contains(workType),
                                action: {
                                    if userProfile.preferredWorkTypes.contains(workType) {
                                        userProfile.preferredWorkTypes.removeAll { $0 == workType }
                                    } else {
                                        userProfile.preferredWorkTypes.append(workType)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)

                // Q3: Resume
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have a resume?", systemImage: "doc.text")
                        .font(.headline)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.hasResume,
                            action: { userProfile.hasResume = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.hasResume,
                            action: { userProfile.hasResume = false }
                        )
                    }

                    if !userProfile.hasResume {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("We can help you create one!")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Employment Questions Part 2 (Experience, Training, Barriers)
struct EmploymentQuestions2View: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    Text("Your Work Background")
                        .font(.title.bold())
                    Text("Help us find the right opportunities for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)

                // Q4: Work Experience
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you have work experience?", systemImage: "clock.badge.checkmark")
                        .font(.headline)

                    Text("Any previous jobs, even informal work")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.hasWorkExperience,
                            action: { userProfile.hasWorkExperience = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.hasWorkExperience,
                            action: { userProfile.hasWorkExperience = false }
                        )
                    }
                }
                .padding(.horizontal)

                // Q5: Job Training
                VStack(alignment: .leading, spacing: 12) {
                    Label("Do you need job training or skills development?", systemImage: "graduationcap")
                        .font(.headline)

                    Text("Computer skills, certifications, trade skills, etc.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 16) {
                        YesNoButton(
                            title: "Yes",
                            isSelected: userProfile.needsJobTraining,
                            action: { userProfile.needsJobTraining = true }
                        )
                        YesNoButton(
                            title: "No",
                            isSelected: !userProfile.needsJobTraining,
                            action: { userProfile.needsJobTraining = false }
                        )
                    }
                }
                .padding(.horizontal)

                // Q6: Barriers to Employment
                VStack(alignment: .leading, spacing: 12) {
                    Label("What barriers do you face in finding work?", systemImage: "exclamationmark.triangle")
                        .font(.headline)

                    Text("Select all that apply (it's okay to skip)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                        ForEach(JobBarrier.allCases) { barrier in
                            MultiSelectButton(
                                title: barrier.displayName,
                                isSelected: userProfile.jobBarriers.contains(barrier),
                                action: {
                                    if userProfile.jobBarriers.contains(barrier) {
                                        userProfile.jobBarriers.removeAll { $0 == barrier }
                                    } else {
                                        userProfile.jobBarriers.append(barrier)
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)

                // Encouraging message
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("Many programs exist to help overcome these barriers. We'll connect you with the right resources.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
}

#Preview {
    EmploymentQuestions1View(onContinue: {})
        .environmentObject(UserProfile())
}
