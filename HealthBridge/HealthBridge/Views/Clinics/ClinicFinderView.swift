import SwiftUI
import MapKit

struct ClinicFinderView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var searchText = ""
    @State private var selectedFilter: ClinicType?
    @State private var showFilters = false
    @State private var selectedClinic: Clinic?
    @State private var showMap = false

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var filteredClinics: [Clinic] {
        var clinics = Clinic.samples

        if let filter = selectedFilter {
            clinics = clinics.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            clinics = clinics.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText)
            }
        }

        return clinics
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search clinics...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: selectedFilter == nil,
                                action: { selectedFilter = nil }
                            )

                            ForEach(recommendedFilters, id: \.self) { type in
                                FilterChip(
                                    title: type.displayName,
                                    icon: type.icon,
                                    isSelected: selectedFilter == type,
                                    action: { selectedFilter = type }
                                )
                            }

                            Button(action: { showFilters = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "line.3.horizontal.decrease")
                                    Text("More")
                                }
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(20)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Toggle between list and map
                Picker("View", selection: $showMap) {
                    Text("List").tag(false)
                    Text("Map").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Content
                if showMap {
                    MapView(clinics: filteredClinics, selectedClinic: $selectedClinic, region: $region)
                } else {
                    ClinicListView(clinics: filteredClinics, selectedClinic: $selectedClinic)
                }
            }
            .navigationTitle("Find Care")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedClinic) { clinic in
                ClinicDetailView(clinic: clinic)
            }
            .sheet(isPresented: $showFilters) {
                FilterSheetView(selectedFilter: $selectedFilter)
            }
        }
    }

    var recommendedFilters: [ClinicType] {
        var filters: [ClinicType] = [.communityHealth, .freeClinic]

        if userProfile.immigrationStatus == .refugee || userProfile.immigrationStatus == .asylumSeeker {
            filters.insert(.refugeeHealth, at: 0)
        }

        if userProfile.housingStatus == .homeless || userProfile.housingStatus == .shelter {
            filters.insert(.homelessHealth, at: 0)
        }

        if userProfile.healthConcerns.contains(.mentalHealth) {
            filters.append(.mentalHealth)
        }

        if userProfile.healthConcerns.contains(.dental) {
            filters.append(.dental)
        }

        return Array(filters.prefix(4))
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Clinic List View
struct ClinicListView: View {
    let clinics: [Clinic]
    @Binding var selectedClinic: Clinic?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(clinics) { clinic in
                    ClinicCard(clinic: clinic)
                        .onTapGesture {
                            selectedClinic = clinic
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Clinic Card
struct ClinicCard: View {
    let clinic: Clinic

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: clinic.type.icon)
                    .font(.title2)
                    .foregroundColor(Color(clinic.type.color))

                VStack(alignment: .leading, spacing: 2) {
                    Text(clinic.name)
                        .font(.headline)
                    Text(clinic.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if clinic.isOpenNow {
                    Text("Open")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(8)
                }
            }

            // Address
            HStack {
                Image(systemName: "mappin")
                    .foregroundColor(.secondary)
                Text(clinic.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Services badges
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if clinic.services.freeServices {
                        ServiceBadge(text: "Free", color: .green)
                    }
                    if clinic.services.slidingScale {
                        ServiceBadge(text: "Sliding Scale", color: .blue)
                    }
                    if clinic.services.interpreterAvailable {
                        ServiceBadge(text: "Interpreter", color: .purple)
                    }
                    if clinic.services.walkInsAccepted {
                        ServiceBadge(text: "Walk-ins OK", color: .orange)
                    }
                }
            }

            // Rating and distance
            HStack {
                if let rating = clinic.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline.weight(.medium))
                        Text("(\(clinic.reviewCount))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Call button
                Button(action: { callClinic(clinic) }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 10)
    }

    private func callClinic(_ clinic: Clinic) {
        let number = clinic.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

struct ServiceBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - Map View
struct MapView: View {
    let clinics: [Clinic]
    @Binding var selectedClinic: Clinic?
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: clinics) { clinic in
            MapAnnotation(coordinate: clinic.coordinate) {
                Button(action: { selectedClinic = clinic }) {
                    VStack {
                        Image(systemName: clinic.type.icon)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color(clinic.type.color))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Filter Sheet
struct FilterSheetView: View {
    @Binding var selectedFilter: ClinicType?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                Section("Clinic Type") {
                    ForEach(ClinicType.allCases) { type in
                        Button(action: {
                            selectedFilter = type
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: type.icon)
                                    .foregroundColor(Color(type.color))
                                    .frame(width: 30)
                                Text(type.displayName)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedFilter == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Clinic Detail View
struct ClinicDetailView: View {
    let clinic: Clinic
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: clinic.type.icon)
                                .font(.title)
                                .foregroundColor(Color(clinic.type.color))
                            Text(clinic.type.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Text(clinic.name)
                            .font(.title.bold())
                    }

                    // Quick info
                    VStack(spacing: 12) {
                        InfoRow(icon: "mappin", text: clinic.fullAddress)
                        InfoRow(icon: "phone", text: clinic.phoneNumber)
                        if let website = clinic.website {
                            InfoRow(icon: "globe", text: website)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Action buttons
                    HStack(spacing: 12) {
                        ActionButton(title: "Call", icon: "phone.fill", color: .green) {
                            callClinic()
                        }
                        ActionButton(title: "Directions", icon: "map.fill", color: .blue) {
                            openDirections()
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(clinic.description)
                            .foregroundColor(.secondary)
                    }

                    // Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Services")
                            .font(.headline)

                        ServicesGrid(services: clinic.services)
                    }

                    // Hours
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hours")
                            .font(.headline)

                        ForEach(clinic.hours, id: \.dayOfWeek) { hours in
                            HStack {
                                Text(hours.dayName)
                                    .frame(width: 100, alignment: .leading)
                                if hours.isClosed {
                                    Text("Closed")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("\(hours.openTime) - \(hours.closeTime)")
                                }
                            }
                            .font(.subheadline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Book appointment button
                    NavigationLink(destination: BookAppointmentView(clinic: clinic)) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Book Appointment")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func callClinic() {
        let number = clinic.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }

    private func openDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: clinic.coordinate))
        mapItem.name = clinic.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct ServicesGrid: View {
    let services: ClinicServices

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            if services.acceptsUninsured {
                ServiceItem(icon: "checkmark.seal", text: "Accepts Uninsured", available: true)
            }
            if services.slidingScale {
                ServiceItem(icon: "dollarsign.circle", text: "Sliding Scale Fees", available: true)
            }
            if services.freeServices {
                ServiceItem(icon: "gift", text: "Free Services", available: true)
            }
            if services.interpreterAvailable {
                ServiceItem(icon: "bubble.left.and.bubble.right", text: "Interpreter Available", available: true)
            }
            if services.walkInsAccepted {
                ServiceItem(icon: "figure.walk", text: "Walk-ins Accepted", available: true)
            }
            if services.telehealth {
                ServiceItem(icon: "video", text: "Telehealth", available: true)
            }
            if services.mentalHealth {
                ServiceItem(icon: "brain.head.profile", text: "Mental Health", available: true)
            }
            if services.dental {
                ServiceItem(icon: "mouth", text: "Dental", available: true)
            }
            if services.prenatal {
                ServiceItem(icon: "figure.and.child.holdinghands", text: "Prenatal Care", available: true)
            }
            if services.vaccinations {
                ServiceItem(icon: "syringe", text: "Vaccinations", available: true)
            }
        }
    }
}

struct ServiceItem: View {
    let icon: String
    let text: String
    let available: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(available ? .green : .secondary)
            Text(text)
                .font(.caption)
                .foregroundColor(available ? .primary : .secondary)
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(available ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ClinicFinderView()
        .environmentObject(UserProfile())
}
