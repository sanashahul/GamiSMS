import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var appointmentsManager: AppointmentsManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Header
                    WelcomeHeader(name: userProfile.name)

                    // Emergency Card (always visible)
                    EmergencyCard()

                    // Upcoming Appointments
                    if !appointmentsManager.upcomingAppointments.isEmpty {
                        UpcomingAppointmentsCard(appointments: appointmentsManager.upcomingAppointments)
                    }

                    // Quick Actions
                    QuickActionsGrid(profile: userProfile)

                    // Personalized Recommendations
                    RecommendationsSection(profile: userProfile)

                    // Health Tips
                    HealthTipsCard()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Welcome Header
struct WelcomeHeader: View {
    let name: String

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning" }
        if hour < 17 { return "Good afternoon" }
        return "Good evening"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(name.isEmpty ? "Welcome!" : name)
                    .font(.title.bold())
            }
            Spacer()

            // Profile picture placeholder
            Circle()
                .fill(LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(name.prefix(1).uppercased()))
                        .font(.title2.bold())
                        .foregroundColor(.white)
                )
        }
    }
}

// MARK: - Emergency Card
struct EmergencyCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cross.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                Text("Emergency")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 16) {
                EmergencyButton(
                    title: "Call 911",
                    subtitle: "Life-threatening",
                    icon: "phone.fill",
                    color: .red,
                    action: { callNumber("911") }
                )

                EmergencyButton(
                    title: "988",
                    subtitle: "Mental health crisis",
                    icon: "heart.fill",
                    color: .purple,
                    action: { callNumber("988") }
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private func callNumber(_ number: String) {
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

struct EmergencyButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Upcoming Appointments Card
struct UpcomingAppointmentsCard: View {
    let appointments: [Appointment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Upcoming Appointments")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") {
                    AppointmentsView()
                }
                .font(.subheadline)
            }

            ForEach(appointments.prefix(2)) { appointment in
                AppointmentRow(appointment: appointment)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }
}

struct AppointmentRow: View {
    let appointment: Appointment

    var body: some View {
        HStack(spacing: 12) {
            // Date box
            VStack {
                Text(appointment.date.formatted(.dateTime.month(.abbreviated)))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(appointment.date.formatted(.dateTime.day()))
                    .font(.title2.bold())
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.clinicName)
                    .font(.subheadline.weight(.medium))
                Text(appointment.appointmentType.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(appointment.time)
                    .font(.caption)
                    .foregroundColor(.blue)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Quick Actions Grid
struct QuickActionsGrid: View {
    let profile: UserProfile

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                QuickActionCard(
                    title: "Find a Clinic",
                    icon: "mappin.circle.fill",
                    color: .blue,
                    destination: AnyView(ClinicFinderView())
                )

                QuickActionCard(
                    title: "Book Appointment",
                    icon: "calendar.badge.plus",
                    color: .green,
                    destination: AnyView(AppointmentsView())
                )

                QuickActionCard(
                    title: "Learn Healthcare",
                    icon: "book.fill",
                    color: .purple,
                    destination: AnyView(LearnView())
                )

                QuickActionCard(
                    title: "My Rights",
                    icon: "shield.fill",
                    color: .orange,
                    destination: AnyView(RightsView())
                )
            }
        }
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
}

// MARK: - Recommendations Section
struct RecommendationsSection: View {
    let profile: UserProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended for You")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(recommendations, id: \.title) { rec in
                    RecommendationCard(recommendation: rec)
                }
            }
        }
    }

    var recommendations: [Recommendation] {
        var recs: [Recommendation] = []

        // Based on insurance status
        if profile.insuranceStatus == .none || profile.insuranceStatus == .unsure {
            recs.append(Recommendation(
                title: "Free & Low-Cost Care",
                description: "Find clinics that offer care regardless of ability to pay",
                icon: "dollarsign.circle.fill",
                color: .green
            ))
        }

        // Based on immigration status
        if profile.immigrationStatus == .refugee || profile.immigrationStatus == .asylumSeeker {
            recs.append(Recommendation(
                title: "Refugee Health Services",
                description: "Specialized clinics for refugees and asylum seekers",
                icon: "figure.walk.arrival",
                color: .purple
            ))
        }

        // Based on housing status
        if profile.housingStatus == .homeless || profile.housingStatus == .shelter {
            recs.append(Recommendation(
                title: "Healthcare for the Homeless",
                description: "Programs designed for people experiencing homelessness",
                icon: "hand.raised.fill",
                color: .orange
            ))
        }

        // Based on health concerns
        if profile.healthConcerns.contains(.mentalHealth) {
            recs.append(Recommendation(
                title: "Mental Health Support",
                description: "Counseling and mental health services",
                icon: "brain.head.profile",
                color: .teal
            ))
        }

        if profile.healthConcerns.contains(.pregnancy) {
            recs.append(Recommendation(
                title: "Prenatal Care",
                description: "Care for expecting mothers - often free regardless of status",
                icon: "figure.and.child.holdinghands",
                color: .pink
            ))
        }

        // Default recommendation
        if recs.isEmpty {
            recs.append(Recommendation(
                title: "Find Your Primary Care Doctor",
                description: "Having a regular doctor helps you stay healthy",
                icon: "stethoscope",
                color: .blue
            ))
        }

        return Array(recs.prefix(3))
    }
}

struct Recommendation {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: recommendation.icon)
                .font(.title2)
                .foregroundColor(recommendation.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.title)
                    .font(.subheadline.weight(.medium))
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Health Tips Card
struct HealthTipsCard: View {
    let tips = [
        ("You have the right to a free interpreter at any healthcare facility", "bubble.left.and.bubble.right"),
        ("Emergency rooms must treat you regardless of ability to pay", "cross.case"),
        ("Community health centers offer care on a sliding fee scale", "building.2"),
        ("You can get free vaccines through the VFC program", "syringe")
    ]

    @State private var currentTip = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Did You Know?")
                    .font(.headline)
            }

            HStack(spacing: 12) {
                Image(systemName: tips[currentTip].1)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)

                Text(tips[currentTip].0)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)

            // Dots
            HStack {
                Spacer()
                ForEach(0..<tips.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentTip ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
        .onAppear {
            startTimer()
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation {
                currentTip = (currentTip + 1) % tips.count
            }
        }
    }
}

// MARK: - Placeholder Views
struct RightsView: View {
    var body: some View {
        Text("Your Healthcare Rights")
            .navigationTitle("My Rights")
    }
}

struct ProfileView: View {
    @EnvironmentObject var userProfile: UserProfile

    var body: some View {
        NavigationView {
            List {
                Section("Personal Information") {
                    LabeledContent("Name", value: userProfile.name)
                    LabeledContent("Country", value: userProfile.countryOfOrigin)
                    LabeledContent("Status", value: userProfile.immigrationStatus?.displayName ?? "Not set")
                }

                Section("Preferences") {
                    LabeledContent("Language", value: userProfile.preferredLanguage.displayName)
                    LabeledContent("Needs Interpreter", value: userProfile.needsInterpreter ? "Yes" : "No")
                }

                Section {
                    Button("Reset Onboarding", role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
