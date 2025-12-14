import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @StateObject private var localization = LocalizationManager.shared

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
                    HealthTipsCard(profile: userProfile)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(localization.localized("home"))
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Welcome Header
struct WelcomeHeader: View {
    let name: String
    @StateObject private var localization = LocalizationManager.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return localization.localized("good_morning") }
        if hour < 17 { return localization.localized("good_afternoon") }
        return localization.localized("good_evening")
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(name.isEmpty ? localization.localized("welcome") : name)
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
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "cross.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                Text(localization.localized("emergency"))
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 16) {
                EmergencyButton(
                    title: localization.localized("call_911"),
                    subtitle: localization.localized("life_threatening"),
                    icon: "phone.fill",
                    color: .red,
                    action: { callNumber("911") }
                )

                EmergencyButton(
                    title: "988",
                    subtitle: localization.localized("mental_health_crisis"),
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
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text(localization.localized("upcoming_reminders"))
                    .font(.headline)
                Spacer()
                NavigationLink(localization.localized("see_all")) {
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
    @StateObject private var localization = LocalizationManager.shared

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localized("quick_actions"))
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                QuickActionCard(
                    title: localization.localized("find_clinic"),
                    icon: "mappin.circle.fill",
                    color: .blue,
                    destination: AnyView(ClinicFinderView())
                )

                QuickActionCard(
                    title: localization.localized("my_appointments"),
                    icon: "calendar.badge.clock",
                    color: .green,
                    destination: AnyView(AppointmentsView())
                )

                QuickActionCard(
                    title: localization.localized("learn_healthcare"),
                    icon: "book.fill",
                    color: .purple,
                    destination: AnyView(LearnView())
                )

                QuickActionCard(
                    title: localization.localized("my_rights"),
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
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localized("recommended_for_you"))
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

        // Based on insurance status - most important for accessing care
        if profile.insuranceStatus == .none || profile.insuranceStatus == .unsure {
            recs.append(Recommendation(
                title: localization.localized("rec_free_care_title"),
                description: localization.localized("rec_free_care_desc"),
                icon: "dollarsign.circle.fill",
                color: .green,
                filterType: .freeClinic
            ))
        }

        // Based on immigration status - specific programs available
        switch profile.immigrationStatus {
        case .refugee:
            recs.append(Recommendation(
                title: localization.localized("rec_refugee_title"),
                description: localization.localized("rec_refugee_desc"),
                icon: "figure.walk.arrival",
                color: .purple,
                filterType: .refugeeHealth
            ))
        case .asylumSeeker:
            recs.append(Recommendation(
                title: localization.localized("rec_asylum_title"),
                description: localization.localized("rec_asylum_desc"),
                icon: "hand.raised.fill",
                color: .purple,
                filterType: .refugeeHealth
            ))
        case .undocumented:
            recs.append(Recommendation(
                title: localization.localized("rec_fqhc_title"),
                description: localization.localized("rec_fqhc_desc"),
                icon: "building.2.fill",
                color: .blue,
                filterType: .communityHealth
            ))
        default:
            break
        }

        // Based on housing status
        if profile.housingStatus == .homeless || profile.housingStatus == .shelter {
            recs.append(Recommendation(
                title: localization.localized("rec_homeless_title"),
                description: localization.localized("rec_homeless_desc"),
                icon: "house.fill",
                color: .orange,
                filterType: .homelessHealth
            ))
        }

        // Based on specific health concerns
        if profile.healthConcerns.contains(.mentalHealth) {
            recs.append(Recommendation(
                title: localization.localized("rec_mental_health_title"),
                description: localization.localized("rec_mental_health_desc"),
                icon: "brain.head.profile",
                color: .teal,
                filterType: .mentalHealth
            ))
        }

        if profile.healthConcerns.contains(.pregnancy) {
            recs.append(Recommendation(
                title: localization.localized("rec_prenatal_title"),
                description: localization.localized("rec_prenatal_desc"),
                icon: "figure.and.child.holdinghands",
                color: .pink,
                filterType: nil
            ))
        }

        if profile.healthConcerns.contains(.dental) {
            recs.append(Recommendation(
                title: localization.localized("rec_dental_title"),
                description: localization.localized("rec_dental_desc"),
                icon: "mouth.fill",
                color: .cyan,
                filterType: .dental
            ))
        }

        if profile.healthConcerns.contains(.vision) {
            recs.append(Recommendation(
                title: localization.localized("rec_vision_title"),
                description: localization.localized("rec_vision_desc"),
                icon: "eye.fill",
                color: .indigo,
                filterType: nil
            ))
        }

        if profile.healthConcerns.contains(.childHealth) {
            recs.append(Recommendation(
                title: localization.localized("rec_pediatric_title"),
                description: localization.localized("rec_pediatric_desc"),
                icon: "figure.2.and.child.holdinghands",
                color: .mint,
                filterType: nil
            ))
        }

        if profile.healthConcerns.contains(.chronicCondition) {
            recs.append(Recommendation(
                title: localization.localized("rec_chronic_title"),
                description: localization.localized("rec_chronic_desc"),
                icon: "heart.text.square.fill",
                color: .red,
                filterType: .communityHealth
            ))
        }

        if profile.healthConcerns.contains(.medications) {
            recs.append(Recommendation(
                title: localization.localized("rec_medications_title"),
                description: localization.localized("rec_medications_desc"),
                icon: "pills.fill",
                color: .orange,
                filterType: nil
            ))
        }

        if profile.healthConcerns.contains(.vaccinations) {
            recs.append(Recommendation(
                title: localization.localized("rec_vaccines_title"),
                description: localization.localized("rec_vaccines_desc"),
                icon: "syringe.fill",
                color: .blue,
                filterType: nil
            ))
        }

        // If user has children
        if profile.hasChildren {
            if !recs.contains(where: { $0.icon == "figure.2.and.child.holdinghands" }) {
                recs.append(Recommendation(
                    title: localization.localized("rec_family_title"),
                    description: localization.localized("rec_family_desc"),
                    icon: "figure.2.and.child.holdinghands",
                    color: .mint,
                    filterType: nil
                ))
            }
        }

        // If user needs interpreter - remind them
        if profile.needsInterpreter {
            recs.append(Recommendation(
                title: localization.localized("rec_interpreter_title"),
                description: localization.localized("rec_interpreter_desc"),
                icon: "bubble.left.and.bubble.right.fill",
                color: .purple,
                filterType: nil
            ))
        }

        // Default if no specific recommendations
        if recs.isEmpty {
            recs.append(Recommendation(
                title: localization.localized("rec_primary_care_title"),
                description: localization.localized("rec_primary_care_desc"),
                icon: "stethoscope",
                color: .blue,
                filterType: .communityHealth
            ))
        }

        // Return first 4 most relevant
        return Array(recs.prefix(4))
    }
}

struct Recommendation {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let filterType: ClinicType?
}

struct RecommendationCard: View {
    let recommendation: Recommendation

    var body: some View {
        NavigationLink(destination: ClinicFinderView()) {
            HStack(spacing: 16) {
                Image(systemName: recommendation.icon)
                    .font(.title2)
                    .foregroundColor(recommendation.color)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.primary)
                    Text(recommendation.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
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
}

// MARK: - Health Tips Card
struct HealthTipsCard: View {
    let profile: UserProfile
    @StateObject private var localization = LocalizationManager.shared
    @State private var currentTip = 0

    var tips: [(String, String)] {
        var allTips = [
            (localization.localized("tip_interpreter"), "bubble.left.and.bubble.right"),
            (localization.localized("tip_emergency"), "cross.case"),
            (localization.localized("tip_fqhc"), "building.2"),
            (localization.localized("tip_vaccines"), "syringe")
        ]

        // Add status-specific tips
        if profile.immigrationStatus == .undocumented {
            allTips.insert((localization.localized("tip_no_immigration_questions"), "checkmark.shield"), at: 0)
        }

        if profile.immigrationStatus == .refugee || profile.immigrationStatus == .asylumSeeker {
            allTips.insert((localization.localized("tip_refugee_programs"), "star.fill"), at: 0)
        }

        if profile.healthConcerns.contains(.pregnancy) {
            allTips.insert((localization.localized("tip_prenatal_free"), "heart.fill"), at: 0)
        }

        return allTips
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text(localization.localized("did_you_know"))
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
                ForEach(0..<min(tips.count, 5), id: \.self) { index in
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
                currentTip = (currentTip + 1) % min(tips.count, 5)
            }
        }
    }
}

// MARK: - Placeholder Views
struct RightsView: View {
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                RightCard(
                    title: localization.localized("right_emergency_title"),
                    description: localization.localized("right_emergency_desc"),
                    icon: "cross.case.fill",
                    color: .red
                )

                RightCard(
                    title: localization.localized("right_interpreter_title"),
                    description: localization.localized("right_interpreter_desc"),
                    icon: "bubble.left.and.bubble.right.fill",
                    color: .purple
                )

                RightCard(
                    title: localization.localized("right_privacy_title"),
                    description: localization.localized("right_privacy_desc"),
                    icon: "lock.shield.fill",
                    color: .blue
                )

                RightCard(
                    title: localization.localized("right_no_discrimination_title"),
                    description: localization.localized("right_no_discrimination_desc"),
                    icon: "hand.raised.fill",
                    color: .green
                )

                RightCard(
                    title: localization.localized("right_fqhc_title"),
                    description: localization.localized("right_fqhc_desc"),
                    icon: "building.2.fill",
                    color: .teal
                )
            }
            .padding()
        }
        .navigationTitle(localization.localized("my_rights"))
    }
}

struct RightCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

struct ProfileView: View {
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        NavigationView {
            List {
                Section(localization.localized("personal_info")) {
                    LabeledContent(localization.localized("name"), value: userProfile.name)
                    LabeledContent(localization.localized("country"), value: userProfile.countryOfOrigin)
                    LabeledContent(localization.localized("status"), value: userProfile.immigrationStatus?.displayName ?? localization.localized("not_set"))
                }

                Section(localization.localized("preferences")) {
                    LabeledContent(localization.localized("language"), value: userProfile.preferredLanguage.displayName)
                    LabeledContent(localization.localized("needs_interpreter"), value: userProfile.needsInterpreter ? localization.localized("yes") : localization.localized("no"))
                }

                Section {
                    Button(localization.localized("reset_onboarding"), role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    }
                }
            }
            .navigationTitle(localization.localized("profile"))
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
