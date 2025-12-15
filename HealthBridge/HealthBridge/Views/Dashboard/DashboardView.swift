import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @State private var selectedTab: ServiceArea?

    private var sortedServiceAreas: [ServiceArea] {
        Array(userProfile.selectedServiceAreas).sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Welcome Header with quick nav
                WelcomeHeader(name: userProfile.name)
                    .padding()

                // Enhanced Service Tabs - always show for quick switching
                if userProfile.selectedServiceAreas.count > 1 {
                    EnhancedServiceTabBar(
                        selectedTab: $selectedTab,
                        services: sortedServiceAreas
                    )
                }

                // Content based on selected tab
                ScrollView {
                    VStack(spacing: 20) {
                        // Emergency card always visible
                        EmergencyCard()
                            .padding(.horizontal)

                        // Upcoming reminders
                        if !appointmentsManager.upcomingAppointments.isEmpty {
                            UpcomingRemindersCard(appointments: appointmentsManager.upcomingAppointments)
                                .padding(.horizontal)
                        }

                        // Quick access to other services (when viewing one)
                        if userProfile.selectedServiceAreas.count > 1 {
                            QuickSwitchBar(
                                currentTab: selectedTab ?? .healthcare,
                                services: sortedServiceAreas,
                                onSelect: { selectedTab = $0 }
                            )
                            .padding(.horizontal)
                        }

                        // Service-specific content
                        if let tab = selectedTab ?? userProfile.selectedServiceAreas.first {
                            switch tab {
                            case .healthcare:
                                HealthcareDashboardContent(profile: userProfile)
                            case .employment:
                                EmploymentDashboardContent(profile: userProfile)
                            case .housing:
                                HousingDashboardContent(profile: userProfile)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("CareConnect")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if selectedTab == nil {
                selectedTab = userProfile.selectedServiceAreas.first
            }
        }
    }
}

// MARK: - Enhanced Service Tab Bar
struct EnhancedServiceTabBar: View {
    @Binding var selectedTab: ServiceArea?
    let services: [ServiceArea]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(services) { service in
                EnhancedTabButton(
                    service: service,
                    isSelected: selectedTab == service,
                    totalTabs: services.count,
                    action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = service
                        }
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

struct EnhancedTabButton: View {
    let service: ServiceArea
    let isSelected: Bool
    let totalTabs: Int
    let action: () -> Void

    var serviceColor: Color {
        switch service {
        case .healthcare: return .red
        case .employment: return .blue
        case .housing: return .green
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: service.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                Text(service.displayName)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
            }
            .foregroundColor(isSelected ? .white : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? serviceColor : Color.clear)
            .cornerRadius(10)
        }
    }
}

// MARK: - Quick Switch Bar
struct QuickSwitchBar: View {
    let currentTab: ServiceArea
    let services: [ServiceArea]
    let onSelect: (ServiceArea) -> Void

    var otherServices: [ServiceArea] {
        services.filter { $0 != currentTab }
    }

    var body: some View {
        if !otherServices.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Quick Access")
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    ForEach(otherServices) { service in
                        QuickSwitchButton(service: service) {
                            withAnimation { onSelect(service) }
                        }
                    }
                }
            }
        }
    }
}

struct QuickSwitchButton: View {
    let service: ServiceArea
    let action: () -> Void

    var serviceColor: Color {
        switch service {
        case .healthcare: return .red
        case .employment: return .blue
        case .housing: return .green
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: service.icon)
                    .font(.caption)
                Text(service.displayName)
                    .font(.caption.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(serviceColor.opacity(0.15))
            .foregroundColor(serviceColor)
            .cornerRadius(20)
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
                Text(name.isEmpty ? "Welcome" : name)
                    .font(.title.bold())
            }
            Spacer()

            Circle()
                .fill(LinearGradient(colors: [.blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
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
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text("Emergency")
                    .font(.headline)
                Spacer()
            }

            HStack(spacing: 12) {
                EmergencyButton(title: "Call 911", subtitle: "Life-threatening", icon: "phone.fill", color: .red) {
                    if let url = URL(string: "tel://911") { UIApplication.shared.open(url) }
                }
                EmergencyButton(title: "988", subtitle: "Crisis Line", icon: "heart.fill", color: .purple) {
                    if let url = URL(string: "tel://988") { UIApplication.shared.open(url) }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
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
            VStack(spacing: 6) {
                Image(systemName: icon)
                Text(title).font(.headline)
                Text(subtitle).font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

// MARK: - Upcoming Reminders Card
struct UpcomingRemindersCard: View {
    let appointments: [Appointment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                Text("Upcoming")
                    .font(.headline)
                Spacer()
                NavigationLink("See All") { AppointmentsView() }
                    .font(.subheadline)
            }

            ForEach(appointments.prefix(2)) { apt in
                HStack(spacing: 12) {
                    VStack {
                        Text(apt.date.formatted(.dateTime.month(.abbreviated)))
                            .font(.caption)
                        Text(apt.date.formatted(.dateTime.day()))
                            .font(.title2.bold())
                    }
                    .frame(width: 50)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(apt.clinicName)
                            .font(.subheadline.weight(.medium))
                        Text(apt.time)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

// MARK: - Healthcare Dashboard Content
struct HealthcareDashboardContent: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 16) {
            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Healthcare")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickActionCard(
                        title: "Find Clinic",
                        icon: "mappin.circle.fill",
                        color: .red,
                        destination: AnyView(ClinicFinderView())
                    )
                    QuickActionCard(
                        title: "My Reminders",
                        icon: "calendar.badge.clock",
                        color: .orange,
                        destination: AnyView(AppointmentsView())
                    )
                }
                .padding(.horizontal)
            }

            // Recommendations
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended for You")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    if profile.insuranceStatus == .none || profile.insuranceStatus == .unsure {
                        RecommendationRow(
                            icon: "dollarsign.circle.fill",
                            color: .green,
                            title: "Get Health Insurance",
                            subtitle: "You may qualify for Medicaid"
                        )
                    }

                    if profile.needsMentalHealthSupport {
                        RecommendationRow(
                            icon: "brain.head.profile",
                            color: .purple,
                            title: "Mental Health Services",
                            subtitle: "Free counseling available"
                        )
                    }

                    if profile.needsDentalCare {
                        RecommendationRow(
                            icon: "mouth.fill",
                            color: .cyan,
                            title: "Dental Care",
                            subtitle: "Low-cost dental clinics nearby"
                        )
                    }

                    if profile.needsMedications {
                        RecommendationRow(
                            icon: "pills.fill",
                            color: .orange,
                            title: "Prescription Help",
                            subtitle: "Get help affording medications"
                        )
                    }

                    RecommendationRow(
                        icon: "cross.case.fill",
                        color: .red,
                        title: "Community Health Centers",
                        subtitle: "Care for everyone, regardless of ability to pay"
                    )
                }
                .padding(.horizontal)
            }

            // Health tip
            TipCard(
                tip: "Community health centers must serve you regardless of ability to pay or insurance status. This is federal law!",
                icon: "lightbulb.fill"
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Employment Dashboard Content
struct EmploymentDashboardContent: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 16) {
            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Employment")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickActionCard(
                        title: "Find Jobs",
                        icon: "magnifyingglass",
                        color: .blue,
                        destination: AnyView(JobFinderMapView())
                    )
                    QuickActionCard(
                        title: "Job Training",
                        icon: "graduationcap.fill",
                        color: .purple,
                        destination: AnyView(JobTrainingView())
                    )
                }
                .padding(.horizontal)
            }

            // Recommendations
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended for You")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    if !profile.hasResume {
                        RecommendationRow(
                            icon: "doc.text.fill",
                            color: .blue,
                            title: "Create a Resume",
                            subtitle: "Free resume help available"
                        )
                    }

                    if profile.needsJobTraining {
                        RecommendationRow(
                            icon: "graduationcap.fill",
                            color: .purple,
                            title: "Job Training Programs",
                            subtitle: "Learn new skills for free"
                        )
                    }

                    if profile.jobBarriers.contains(.transportation) {
                        RecommendationRow(
                            icon: "bus.fill",
                            color: .green,
                            title: "Transportation Help",
                            subtitle: "Bus passes and ride programs"
                        )
                    }

                    if profile.jobBarriers.contains(.noID) {
                        RecommendationRow(
                            icon: "person.text.rectangle",
                            color: .orange,
                            title: "Get Your ID",
                            subtitle: "Help getting documents"
                        )
                    }

                    RecommendationRow(
                        icon: "building.2.fill",
                        color: .blue,
                        title: "Workforce Centers",
                        subtitle: "Free job search assistance"
                    )
                }
                .padding(.horizontal)
            }

            // Employment tip
            TipCard(
                tip: "Many employers hire people without traditional housing. Focus on your skills and show reliability!",
                icon: "star.fill"
            )
            .padding(.horizontal)
        }
    }
}

// MARK: - Housing Dashboard Content
struct HousingDashboardContent: View {
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 16) {
            // Current Situation
            if profile.currentHousingSituation == .street || profile.currentHousingSituation == .vehicle {
                UrgentHousingCard()
                    .padding(.horizontal)
            }

            // Quick Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Housing")
                    .font(.headline)
                    .padding(.horizontal)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    QuickActionCard(
                        title: "Find Shelter",
                        icon: "building.2.fill",
                        color: .green,
                        destination: AnyView(ShelterFinderMapView())
                    )
                    QuickActionCard(
                        title: "Housing Programs",
                        icon: "house.fill",
                        color: .teal,
                        destination: AnyView(HousingProgramsMapView())
                    )
                }
                .padding(.horizontal)
            }

            // Recommendations
            VStack(alignment: .leading, spacing: 12) {
                Text("Recommended for You")
                    .font(.headline)
                    .padding(.horizontal)

                VStack(spacing: 10) {
                    if !profile.isOnHousingWaitlist {
                        RecommendationRow(
                            icon: "list.clipboard.fill",
                            color: .blue,
                            title: "Housing Waitlists",
                            subtitle: "Get on Section 8 and other lists"
                        )
                    }

                    if profile.isVeteran {
                        RecommendationRow(
                            icon: "star.fill",
                            color: .purple,
                            title: "VA Housing Programs",
                            subtitle: "Special programs for veterans"
                        )
                    }

                    if profile.hasChildren {
                        RecommendationRow(
                            icon: "figure.2.and.child.holdinghands",
                            color: .orange,
                            title: "Family Housing",
                            subtitle: "Priority programs for families"
                        )
                    }

                    if profile.needsIDHelp {
                        RecommendationRow(
                            icon: "person.text.rectangle",
                            color: .red,
                            title: "ID Recovery",
                            subtitle: "Get IDs needed for housing"
                        )
                    }

                    RecommendationRow(
                        icon: "dollarsign.circle.fill",
                        color: .green,
                        title: "Rental Assistance",
                        subtitle: "Emergency funds available"
                    )
                }
                .padding(.horizontal)
            }

            // Housing tip
            TipCard(
                tip: "Getting on housing waitlists early is important - some have long waits. Apply to multiple programs!",
                icon: "clock.fill"
            )
            .padding(.horizontal)
        }
    }
}

struct UrgentHousingCard: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.title)
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text("Need Shelter Tonight?")
                    .font(.headline)
                Text("Find emergency shelter near you")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            NavigationLink(destination: ShelterFinderMapView()) {
                Text("Find")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Reusable Components
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
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5)
        }
    }
}

struct RecommendationRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                Text(subtitle)
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
        .shadow(color: .black.opacity(0.03), radius: 3)
    }
}

struct TipCard: View {
    let tip: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)

            Text(tip)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Job Training View (Specialized Training Programs)
struct JobTrainingView: View {
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var resourceService = ResourceService.shared
    @StateObject private var locationService = LocationService.shared
    @State private var trainingResources: [Resource] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Call 211 Banner
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill").foregroundColor(.white)
                    VStack(alignment: .leading) {
                        Text("Need training help?").font(.headline).foregroundColor(.white)
                        Text("Call 211 for local programs").font(.caption).foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Button("Call") {
                        if let url = URL(string: "tel://211") { UIApplication.shared.open(url) }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(.purple)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.purple)
                .cornerRadius(16)
                .padding(.horizontal)

                // Training Categories
                VStack(alignment: .leading, spacing: 12) {
                    Text("Training Programs")
                        .font(.headline)
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        TrainingCard(title: "Computer Skills", description: "Learn basic computer and internet skills", icon: "desktopcomputer")
                        TrainingCard(title: "Food Handler Certification", description: "Get certified for restaurant work", icon: "fork.knife")
                        TrainingCard(title: "Construction Training", description: "OSHA certification and trade skills", icon: "hammer")
                        TrainingCard(title: "Healthcare Training", description: "CNA and caregiving certification", icon: "heart.fill")
                        TrainingCard(title: "Warehouse & Logistics", description: "Forklift certification and inventory", icon: "shippingbox")
                        TrainingCard(title: "Customer Service", description: "Retail and call center training", icon: "person.fill.questionmark")
                    }
                    .padding(.horizontal)
                }

                // Nearby Training Centers (if available)
                if !trainingResources.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Training Centers Near You")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(trainingResources.prefix(3)) { resource in
                            TrainingLocationCard(resource: resource)
                                .padding(.horizontal)
                        }

                        NavigationLink(destination: ResourceFinderView(
                            category: .employment,
                            title: "Job Training",
                            filterTypes: [.jobTraining, .careerCenter]
                        )) {
                            HStack {
                                Text("See All Training Centers")
                                Image(systemName: "arrow.right")
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.purple)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Job Training")
        .onAppear {
            loadTrainingResources()
        }
    }

    private func loadTrainingResources() {
        if let location = locationService.currentLocation {
            trainingResources = resourceService.getResources(type: .jobTraining, near: location, radius: 50)
        }
    }
}

struct TrainingCard: View {
    let title: String
    let description: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.purple)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(description).font(.subheadline).foregroundColor(.secondary)
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

struct TrainingLocationCard: View {
    let resource: Resource

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(.purple)
                Text(resource.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Spacer()
                if let distance = resource.distance {
                    Text(String(format: "%.1f mi", distance))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Text(resource.fullAddress)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)

            Button(action: {
                let number = resource.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
                if let url = URL(string: "tel://\(number)") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text("Call")
                }
                .font(.caption.weight(.medium))
                .foregroundColor(.purple)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5)
    }
}

#Preview {
    DashboardView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
