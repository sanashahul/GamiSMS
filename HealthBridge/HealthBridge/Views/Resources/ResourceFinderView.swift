import SwiftUI
import MapKit
import CoreLocation

// MARK: - Resource Finder View
struct ResourceFinderView: View {
    let category: ResourceCategory
    let title: String
    let filterTypes: [ResourceType]

    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var resourceService = ResourceService.shared
    @StateObject private var locationService = LocationService.shared

    @State private var searchText = ""
    @State private var selectedFilter: ResourceType?
    @State private var selectedResource: Resource?
    @State private var showMap = false
    @State private var isLoading = true
    @State private var resources: [Resource] = []

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    )

    var filteredResources: [Resource] {
        var result = resources

        if let filter = selectedFilter {
            result = result.filter { $0.type == filter }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.address.localizedCaseInsensitiveContains(searchText) ||
                $0.city.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search \(title.lowercased())...", text: $searchText)
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
                if filterTypes.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ResourceFilterChip(
                                title: "All",
                                isSelected: selectedFilter == nil,
                                color: categoryColor
                            ) {
                                selectedFilter = nil
                            }

                            ForEach(filterTypes) { type in
                                ResourceFilterChip(
                                    title: type.displayName,
                                    icon: type.icon,
                                    isSelected: selectedFilter == type,
                                    color: Color(type.color)
                                ) {
                                    selectedFilter = type
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))

            // Results count and location
            HStack {
                if isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Finding resources...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("\(filteredResources.count) \(filteredResources.count == 1 ? "location" : "locations") found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()

                if let city = locationService.currentCity, !city.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(city)
                            .font(.caption)
                    }
                    .foregroundColor(categoryColor)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 4)

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
                ResourceMapView(
                    resources: filteredResources,
                    selectedResource: $selectedResource,
                    region: $region,
                    categoryColor: categoryColor
                )
            } else {
                ResourceListView(
                    resources: filteredResources,
                    selectedResource: $selectedResource,
                    isLoading: isLoading,
                    categoryColor: categoryColor
                )
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource, categoryColor: categoryColor)
        }
        .onAppear {
            loadResources()
            updateMapRegion()
        }
    }

    private var categoryColor: Color {
        switch category {
        case .healthcare: return .red
        case .employment: return .blue
        case .housing: return .green
        }
    }

    private func loadResources() {
        isLoading = true

        if let location = locationService.currentLocation {
            resources = resourceService.getResources(category: category, near: location, radius: 100)
            isLoading = false
            updateMapRegion()
        } else if !userProfile.zipCode.isEmpty {
            locationService.geocodeZipCode(userProfile.zipCode) { location in
                if let location = location {
                    resources = resourceService.getResources(category: category, near: location, radius: 100)
                } else {
                    // Use all resources if location not available
                    resources = resourceService.resources.filter { $0.category == category }
                }
                isLoading = false
                updateMapRegion()
            }
        } else {
            // Show all resources in category
            resources = resourceService.resources.filter { $0.category == category }
            isLoading = false
        }
    }

    private func updateMapRegion() {
        if let location = locationService.currentLocation {
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
        } else if let firstResource = filteredResources.first {
            region = MKCoordinateRegion(
                center: firstResource.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
        }
    }
}

// MARK: - Resource Filter Chip
struct ResourceFilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let color: Color
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
            .background(isSelected ? color : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

// MARK: - Resource Map View
struct ResourceMapView: View {
    let resources: [Resource]
    @Binding var selectedResource: Resource?
    @Binding var region: MKCoordinateRegion
    let categoryColor: Color

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: resources) { resource in
            MapAnnotation(coordinate: resource.coordinate) {
                Button(action: { selectedResource = resource }) {
                    VStack(spacing: 0) {
                        Image(systemName: resource.type.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.fromName(resource.type.color))
                            .clipShape(Circle())
                            .shadow(radius: 3)

                        // Triangle pointer
                        Image(systemName: "triangle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color.fromName(resource.type.color))
                            .rotationEffect(.degrees(180))
                            .offset(y: -3)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// MARK: - Resource List View
struct ResourceListView: View {
    let resources: [Resource]
    @Binding var selectedResource: Resource?
    let isLoading: Bool
    let categoryColor: Color

    var body: some View {
        if isLoading {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Finding resources near you...")
                    .font(.headline)
                Text("Using your location to find the closest options")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if resources.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "map")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("No resources found")
                    .font(.headline)
                Text("Try adjusting your filters or enabling location services")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Enable Location")
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(categoryColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(resources) { resource in
                        ResourceCard(resource: resource, categoryColor: categoryColor)
                            .onTapGesture {
                                selectedResource = resource
                            }
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Resource Card
struct ResourceCard: View {
    let resource: Resource
    let categoryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: resource.type.icon)
                    .font(.title2)
                    .foregroundColor(Color.fromName(resource.type.color))

                VStack(alignment: .leading, spacing: 2) {
                    Text(resource.name)
                        .font(.headline)
                        .lineLimit(2)
                    Text(resource.type.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if resource.walkInsWelcome {
                        Text("Walk-ins OK")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                    }

                    if let distance = resource.distance {
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
                Text(resource.fullAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Services preview
            if !resource.services.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(resource.services.prefix(3), id: \.self) { service in
                            Text(service)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(categoryColor.opacity(0.15))
                                .foregroundColor(categoryColor)
                                .cornerRadius(8)
                        }
                        if resource.services.count > 3 {
                            Text("+\(resource.services.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            // Hours and call button
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(resource.hours)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                Spacer()

                Button(action: { callResource(resource) }) {
                    HStack {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .font(.subheadline.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(categoryColor)
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

    private func callResource(_ resource: Resource) {
        let number = resource.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Resource Detail View
struct ResourceDetailView: View {
    let resource: Resource
    let categoryColor: Color
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: resource.type.icon)
                                .font(.title)
                                .foregroundColor(Color.fromName(resource.type.color))
                            Text(resource.type.displayName)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            if resource.walkInsWelcome {
                                Text("Walk-ins OK")
                                    .font(.caption.weight(.medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .foregroundColor(.green)
                                    .cornerRadius(8)
                            }
                        }
                        Text(resource.name)
                            .font(.title.bold())
                    }

                    // Quick info
                    VStack(spacing: 12) {
                        ResourceInfoRow(icon: "mappin", text: resource.fullAddress)
                        ResourceInfoRow(icon: "phone", text: resource.phoneNumber)
                        ResourceInfoRow(icon: "clock", text: resource.hours)
                        if let website = resource.website {
                            ResourceInfoRow(icon: "globe", text: website)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Action buttons
                    HStack(spacing: 12) {
                        Button(action: callResource) {
                            VStack(spacing: 8) {
                                Image(systemName: "phone.fill")
                                    .font(.title2)
                                Text("Call")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(categoryColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: openDirections) {
                            VStack(spacing: 8) {
                                Image(systemName: "map.fill")
                                    .font(.title2)
                                Text("Directions")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        Text(resource.description)
                            .foregroundColor(.secondary)
                    }

                    // Services
                    if !resource.services.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Services")
                                .font(.headline)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(resource.services, id: \.self) { service in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text(service)
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }

                    // Requirements
                    if !resource.requirements.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Requirements")
                                .font(.headline)

                            ForEach(resource.requirements, id: \.self) { req in
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                    Text(req)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // Call to action
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "phone.arrow.up.right")
                                .foregroundColor(categoryColor)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Call to confirm availability")
                                    .font(.subheadline.weight(.medium))
                                Text("Services and hours may vary")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(categoryColor.opacity(0.1))
                        .cornerRadius(12)

                        Button(action: callResource) {
                            HStack {
                                Image(systemName: "phone.fill")
                                Text("Call Now")
                                Text(resource.phoneNumber)
                                    .fontWeight(.regular)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(categoryColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
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

    private func callResource() {
        let number = resource.phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }

    private func openDirections() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: resource.coordinate))
        mapItem.name = resource.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}

struct ResourceInfoRow: View {
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

// MARK: - Convenience Views for Each Category

struct ShelterFinderMapView: View {
    var body: some View {
        ResourceFinderView(
            category: .housing,
            title: "Find Shelter",
            filterTypes: [.shelter, .transitionalHousing, .socialServices, .foodBank]
        )
    }
}

struct JobFinderMapView: View {
    var body: some View {
        ResourceFinderView(
            category: .employment,
            title: "Find Jobs",
            filterTypes: [.workforceCenter, .jobTraining, .dayLabor, .careerCenter, .tempAgency]
        )
    }
}

struct HousingProgramsMapView: View {
    var body: some View {
        ResourceFinderView(
            category: .housing,
            title: "Housing Programs",
            filterTypes: [.housingAuthority, .transitionalHousing, .socialServices]
        )
    }
}

#Preview {
    NavigationView {
        ShelterFinderMapView()
            .environmentObject(UserProfile())
    }
}
