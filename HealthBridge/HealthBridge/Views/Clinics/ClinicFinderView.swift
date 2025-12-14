import SwiftUI
import MapKit

struct ClinicFinderView: View {
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var clinicService = ClinicService.shared
    @StateObject private var locationService = LocationService.shared
    @StateObject private var localization = LocalizationManager.shared

    @State private var searchText = ""
    @State private var selectedFilter: ClinicType?
    @State private var showFilters = false
    @State private var selectedClinic: Clinic?
    @State private var showMap = false
    @State private var hasLoadedClinics = false
    @FocusState private var isSearchFocused: Bool

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), // LA default
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    var allClinics: [Clinic] {
        // Use combined clinics from service (static + MapKit)
        if !clinicService.combinedClinics.isEmpty {
            return clinicService.combinedClinics
        }

        // Fallback while loading
        if let location = locationService.currentLocation {
            return clinicService.getClinics(near: location, radius: 100)
        } else if !userProfile.zipCode.isEmpty {
            return clinicService.getClinics(forZipCode: userProfile.zipCode)
        }
        return clinicService.allClinics
    }

    var filteredClinics: [Clinic] {
        var clinics = allClinics

        if let filter = selectedFilter {
            clinics = clinics.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            clinics = clinics.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText)
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
                        TextField(localization.localized("search_clinics"), text: $searchText)
                            .focused($isSearchFocused)
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
                                title: localization.localized("all"),
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
                                    Text(localization.localized("more_filters"))
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

                // Results count and loading state
                HStack {
                    if clinicService.isLoading {
                        HStack(spacing: 8) {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text(clinicService.isSearchingMapKit ?
                                 localization.localized("searching_nearby") :
                                 localization.localized("loading"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("\(filteredClinics.count) \(localization.localized("clinics_found"))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    // Location indicator
                    if let city = locationService.currentCity, !city.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(city)
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                // Toggle between list and map
                Picker("View", selection: $showMap) {
                    Text(localization.localized("list")).tag(false)
                    Text(localization.localized("map")).tag(true)
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
            .navigationTitle(localization.localized("find_care"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedClinic) { clinic in
                ClinicDetailView(clinic: clinic)
            }
            .sheet(isPresented: $showFilters) {
                FilterSheetView(selectedFilter: $selectedFilter)
            }
            .onTapGesture {
                isSearchFocused = false
            }
            .onAppear {
                loadClinicsForCurrentLocation()
                updateMapRegion()
            }
            .onChange(of: locationService.currentLocation) { newLocation in
                // Reload clinics when location changes
                if let location = newLocation, !hasLoadedClinics {
                    loadClinicsForLocation(location)
                }
            }
            .onChange(of: userProfile.zipCode) { newZip in
                // Reload when ZIP code changes (if no GPS location)
                if locationService.currentLocation == nil && newZip.count == 5 {
                    loadClinicsForZipCode(newZip)
                }
            }
        }
    }

    // MARK: - Clinic Loading Methods

    private func loadClinicsForCurrentLocation() {
        if let location = locationService.currentLocation {
            loadClinicsForLocation(location)
        } else if !userProfile.zipCode.isEmpty && userProfile.zipCode.count == 5 {
            loadClinicsForZipCode(userProfile.zipCode)
        }
    }

    private func loadClinicsForLocation(_ location: CLLocation) {
        hasLoadedClinics = true
        clinicService.loadClinics(
            near: location,
            forStatus: userProfile.immigrationStatus,
            radius: 50.0
        )
        updateMapRegion()
    }

    private func loadClinicsForZipCode(_ zipCode: String) {
        // Geocode ZIP code first, then load clinics
        locationService.geocodeZipCode(zipCode) { location in
            if let location = location {
                loadClinicsForLocation(location)
            }
        }
    }

    private func updateMapRegion() {
        if let location = locationService.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
        } else if let firstClinic = filteredClinics.first {
            region = MKCoordinateRegion(
                center: firstClinic.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
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
    @StateObject private var clinicService = ClinicService.shared
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        if clinicService.isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text(clinicService.isSearchingMapKit ?
                     localization.localized("searching_nearby") :
                     localization.localized("loading"))
                    .font(.headline)
                Text(localization.localized("finding_best_clinics"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if clinics.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "building.2")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text(localization.localized("no_clinics_found"))
                    .font(.headline)
                Text(localization.localized("try_adjusting_filters"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Suggestion to enable location
                VStack(spacing: 8) {
                    Text(localization.localized("enable_location_tip"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(localization.localized("open_settings"))
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            ScrollView {
                // Info banner for MapKit-sourced clinics
                if clinicService.nearbyMapKitClinics.count > 0 && clinicService.combinedClinics.count > 0 {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text(localization.localized("mapkit_clinics_note"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

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
}

// MARK: - Clinic Card
struct ClinicCard: View {
    let clinic: Clinic
    @StateObject private var localization = LocalizationManager.shared

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
                        .lineLimit(2)
                    Text(clinic.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if clinic.isOpenNow {
                        Text(localization.localized("open"))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    } else {
                        Text(localization.localized("closed"))
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }

                    if let distance = clinic.distance {
                        Text(String(format: "%.1f mi", distance))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Address
            HStack {
                Image(systemName: "mappin")
                    .foregroundColor(.secondary)
                Text(clinic.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Services badges
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if clinic.services.freeServices {
                        ServiceBadge(text: localization.localized("free"), color: .green)
                    }
                    if clinic.services.slidingScale {
                        ServiceBadge(text: localization.localized("sliding_scale"), color: .blue)
                    }
                    if clinic.services.interpreterAvailable {
                        ServiceBadge(text: localization.localized("interpreter"), color: .purple)
                    }
                    if clinic.services.walkInsAccepted {
                        ServiceBadge(text: localization.localized("walk_ins_ok"), color: .orange)
                    }
                    if clinic.services.telehealth {
                        ServiceBadge(text: "Telehealth", color: .teal)
                    }
                }
            }

            // Rating and actions
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
                        Text(localization.localized("call"))
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
                    Button(action: {
                        selectedFilter = nil
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("All Clinics")
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedFilter == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }

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
    @StateObject private var localization = LocalizationManager.shared

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

                            Spacer()

                            if let rating = clinic.rating {
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", rating))
                                        .font(.headline)
                                }
                            }
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
                        ActionButton(title: localization.localized("call"), icon: "phone.fill", color: .green) {
                            callClinic()
                        }
                        ActionButton(title: localization.localized("directions"), icon: "map.fill", color: .blue) {
                            openDirections()
                        }
                    }

                    // Special notes
                    if let notes = clinic.specialNotes {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Important Information")
                                    .font(.headline)
                            }
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localized("about"))
                            .font(.headline)
                        Text(clinic.description)
                            .foregroundColor(.secondary)
                    }

                    // Services
                    VStack(alignment: .leading, spacing: 12) {
                        Text(localization.localized("services"))
                            .font(.headline)

                        ServicesGrid(services: clinic.services)
                    }

                    // Languages
                    if !clinic.services.languages.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Languages Available")
                                .font(.headline)

                            FlowLayout(spacing: 8) {
                                ForEach(clinic.services.languages) { language in
                                    Text(language.displayName)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }

                    // Hours
                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.localized("hours"))
                            .font(.headline)

                        ForEach(clinic.hours, id: \.dayOfWeek) { hours in
                            HStack {
                                Text(hours.dayName)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.subheadline)
                                if hours.isClosed {
                                    Text("Closed")
                                        .foregroundColor(.red)
                                        .font(.subheadline)
                                } else {
                                    Text("\(hours.openTime) - \(hours.closeTime)")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Call to schedule section - emphasize calling
                    VStack(spacing: 16) {
                        // Info banner
                        HStack(spacing: 12) {
                            Image(systemName: "phone.arrow.up.right")
                                .foregroundColor(.green)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localization.localized("call_to_schedule"))
                                    .font(.subheadline.weight(.medium))
                                Text(localization.localized("call_clinic_to_book"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)

                        // Call button - primary action
                        Button(action: callClinic) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text(localization.localized("call_now"))
                                Text(clinic.phoneNumber)
                                    .fontWeight(.regular)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        // Website button if available
                        if let website = clinic.website, let url = URL(string: website) {
                            Button(action: { UIApplication.shared.open(url) }) {
                                HStack {
                                    Image(systemName: "globe")
                                    Text(localization.localized("visit_website"))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .foregroundColor(.blue)
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localized("done")) { dismiss() }
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

// MARK: - Flow Layout for Languages
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let positions = layout(sizes: sizes, proposal: proposal).positions

        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + positions[index].x, y: bounds.minY + positions[index].y), proposal: .unspecified)
        }
    }

    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for size in sizes {
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
            totalHeight = y + maxHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
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
            if services.transportationHelp {
                ServiceItem(icon: "car", text: "Transportation Help", available: true)
            }
            if services.mentalHealth {
                ServiceItem(icon: "brain.head.profile", text: "Mental Health", available: true)
            }
            if services.dental {
                ServiceItem(icon: "mouth", text: "Dental", available: true)
            }
            if services.vision {
                ServiceItem(icon: "eye", text: "Vision", available: true)
            }
            if services.prenatal {
                ServiceItem(icon: "figure.and.child.holdinghands", text: "Prenatal Care", available: true)
            }
            if services.pediatric {
                ServiceItem(icon: "figure.2.and.child.holdinghands", text: "Pediatric", available: true)
            }
            if services.vaccinations {
                ServiceItem(icon: "syringe", text: "Vaccinations", available: true)
            }
            if services.emergencyMedicaid {
                ServiceItem(icon: "cross.case", text: "Emergency Medicaid", available: true)
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
