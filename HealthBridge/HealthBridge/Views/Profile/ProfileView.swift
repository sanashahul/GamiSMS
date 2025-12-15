import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userProfile: UserProfile
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showResetAlert = false

    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.blue, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 70, height: 70)

                            Text(userProfile.name.prefix(1).uppercased())
                                .font(.title.bold())
                                .foregroundColor(.white)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(userProfile.name.isEmpty ? "Welcome" : userProfile.name)
                                .font(.title2.bold())

                            if !userProfile.zipCode.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "location.fill")
                                        .font(.caption)
                                    Text("ZIP: \(userProfile.zipCode)")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Selected Services
                Section("My Services") {
                    if userProfile.selectedServiceAreas.isEmpty {
                        Text("No services selected")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(Array(userProfile.selectedServiceAreas).sorted { $0.rawValue < $1.rawValue }) { service in
                            HStack(spacing: 12) {
                                Image(systemName: service.icon)
                                    .foregroundColor(colorForService(service))
                                    .frame(width: 30)
                                Text(service.displayName)
                            }
                        }
                    }
                }

                // Healthcare Info (if selected)
                if userProfile.needsHealthcare {
                    Section("Healthcare") {
                        ProfileRow(icon: "creditcard", title: "Insurance", value: userProfile.insuranceStatus.displayName)

                        if userProfile.needsMentalHealthSupport {
                            ProfileRow(icon: "brain.head.profile", title: "Mental Health", value: "Support needed")
                        }

                        if userProfile.needsDentalCare {
                            ProfileRow(icon: "mouth", title: "Dental Care", value: "Needed")
                        }

                        if userProfile.needsMedications {
                            ProfileRow(icon: "pills", title: "Medications", value: "Assistance needed")
                        }
                    }
                }

                // Employment Info (if selected)
                if userProfile.needsEmployment {
                    Section("Employment") {
                        ProfileRow(icon: "briefcase", title: "Status", value: userProfile.employmentStatus.displayName)

                        if !userProfile.hasResume {
                            ProfileRow(icon: "doc.text", title: "Resume", value: "Need help creating")
                        }

                        if userProfile.needsJobTraining {
                            ProfileRow(icon: "graduationcap", title: "Training", value: "Interested")
                        }
                    }
                }

                // Housing Info (if selected)
                if userProfile.needsHousing {
                    Section("Housing") {
                        ProfileRow(icon: "house", title: "Current Situation", value: userProfile.currentHousingSituation.displayName)

                        ProfileRow(icon: "list.clipboard", title: "On Waitlist", value: userProfile.isOnHousingWaitlist ? "Yes" : "No")

                        ProfileRow(icon: "person.text.rectangle", title: "ID Documents", value: userProfile.idDocumentStatus.displayName)
                    }
                }

                // Preferences
                Section("Preferences") {
                    ProfileRow(icon: "globe", title: "Language", value: userProfile.preferredLanguage.displayName)

                    ProfileRow(icon: "bubble.left.and.bubble.right", title: "Interpreter", value: userProfile.needsInterpreter ? "Needed" : "Not needed")
                }

                // Actions
                Section {
                    Button(action: {
                        showResetAlert = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.orange)
                            Text("Restart Onboarding")
                                .foregroundColor(.primary)
                        }
                    }
                }

                // App Info
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("App")
                        Spacer()
                        Text("CareConnect")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .alert("Restart Onboarding?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Restart", role: .destructive) {
                    resetOnboarding()
                }
            } message: {
                Text("This will clear your current profile and start the setup process again.")
            }
        }
    }

    private func colorForService(_ service: ServiceArea) -> Color {
        switch service {
        case .healthcare: return .red
        case .employment: return .blue
        case .housing: return .green
        }
    }

    private func resetOnboarding() {
        // Clear profile
        userProfile.name = ""
        userProfile.selectedServiceAreas = []
        userProfile.zipCode = ""
        userProfile.save()

        // Reset onboarding flag
        hasCompletedOnboarding = false
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserProfile())
}
