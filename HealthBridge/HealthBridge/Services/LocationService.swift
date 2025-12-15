import Foundation
import CoreLocation
import MapKit

// MARK: - Location Service
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published var currentLocation: CLLocation?
    @Published var currentCity: String = ""
    @Published var currentState: String = ""
    @Published var currentZipCode: String = ""
    @Published var isLoading = false
    @Published var hasLocation = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation() {
        isLoading = true
        errorMessage = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        case .denied, .restricted:
            isLoading = false
            errorMessage = "Location access denied. Please enable in Settings."
        @unknown default:
            isLoading = false
        }
    }

    func geocodeZipCode(_ zipCode: String, completion: @escaping (CLLocation?) -> Void) {
        geocoder.geocodeAddressString(zipCode) { placemarks, error in
            if let location = placemarks?.first?.location {
                DispatchQueue.main.async {
                    self.currentLocation = location
                    self.currentZipCode = zipCode
                    self.hasLocation = true
                    self.reverseGeocode(location)
                    completion(location)
                }
            } else {
                completion(nil)
            }
        }
    }

    func reverseGeocode(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    self?.currentCity = placemark.locality ?? ""
                    self?.currentState = placemark.administrativeArea ?? ""
                    self?.currentZipCode = placemark.postalCode ?? ""
                }
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        if let location = locations.first {
            currentLocation = location
            hasLocation = true
            reverseGeocode(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Could not get your location. Please enter your ZIP code."
        print("Location error: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            if isLoading {
                locationManager.requestLocation()
            }
        }
    }
}

// MARK: - Clinic Service
class ClinicService: ObservableObject {
    static let shared = ClinicService()

    @Published var clinics: [Clinic] = []
    @Published var isLoading = false
    @Published var nearbyMapKitClinics: [Clinic] = []
    @Published var combinedClinics: [Clinic] = []
    @Published var searchComplete = false
    @Published var isSearchingMapKit = false

    private let minimumStaticClinics = 3 // Trigger MapKit if fewer than this many static results
    private let defaultSearchRadius: Double = 50.0 // miles

    // MARK: - Main Entry Point: Get clinics for any location
    // This is the primary method that ClinicFinderView should use
    func loadClinics(near location: CLLocation, radius: Double = 50.0) {
        isLoading = true
        searchComplete = false

        // First, get static database clinics
        let staticClinics = getClinicsFromDatabase(near: location, radius: radius)

        // If we have enough static clinics, use them
        if staticClinics.count >= minimumStaticClinics {
            DispatchQueue.main.async {
                self.combinedClinics = staticClinics
                self.isLoading = false
                self.searchComplete = true
            }
        } else {
            // Not enough static clinics - search MapKit for more
            isSearchingMapKit = true
            searchNearbyHealthCenters(near: location) { [weak self] mapKitClinics in
                guard let self = self else { return }

                DispatchQueue.main.async {
                    // Combine static and MapKit results, avoiding duplicates
                    var combined = staticClinics

                    for mapClinic in mapKitClinics {
                        // Check if this clinic is already in static results (by name similarity)
                        let isDuplicate = staticClinics.contains { existingClinic in
                            self.areClinicsLikelySame(existingClinic, mapClinic)
                        }
                        if !isDuplicate {
                            combined.append(mapClinic)
                        }
                    }

                    // Sort by distance
                    combined.sort { ($0.distance ?? 999) < ($1.distance ?? 999) }

                    self.combinedClinics = combined
                    self.isLoading = false
                    self.isSearchingMapKit = false
                    self.searchComplete = true
                }
            }
        }
    }

    // Check if two clinics are likely the same (to avoid duplicates)
    private func areClinicsLikelySame(_ clinic1: Clinic, _ clinic2: Clinic) -> Bool {
        // Check if names are similar
        let name1 = clinic1.name.lowercased()
        let name2 = clinic2.name.lowercased()

        if name1 == name2 { return true }
        if name1.contains(name2) || name2.contains(name1) { return true }

        // Check if addresses are similar
        let addr1 = clinic1.address.lowercased()
        let addr2 = clinic2.address.lowercased()

        if !addr1.isEmpty && !addr2.isEmpty && addr1 == addr2 { return true }

        // Check geographic proximity (within 0.1 miles)
        if let dist1 = clinic1.distance, let dist2 = clinic2.distance {
            let latDiff = abs(clinic1.latitude - clinic2.latitude)
            let lonDiff = abs(clinic1.longitude - clinic2.longitude)
            if latDiff < 0.001 && lonDiff < 0.001 { return true }
        }

        return false
    }

    // Search for nearby health centers using MapKit (expanded search)
    func searchNearbyHealthCenters(near location: CLLocation, completion: @escaping ([Clinic]) -> Void) {
        var allMapKitClinics: [Clinic] = []
        let searchGroup = DispatchGroup()

        // Multiple search queries to find more clinics
        let searchQueries = [
            "community health center",
            "free clinic",
            "federally qualified health center",
            "family health clinic",
            "urgent care clinic"
        ]

        for query in searchQueries {
            searchGroup.enter()

            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = MKCoordinateRegion(
                center: location.coordinate,
                latitudinalMeters: 80000, // ~50 miles for wider search
                longitudinalMeters: 80000
            )

            let search = MKLocalSearch(request: request)
            search.start { [weak self] response, error in
                defer { searchGroup.leave() }

                guard let self = self, let response = response else { return }

                let clinics = response.mapItems.compactMap { item -> Clinic? in
                    guard let name = item.name else { return nil }

                    // Filter out non-health facilities
                    let nameLower = name.lowercased()
                    let excludeTerms = ["pharmacy", "cvs", "walgreens", "rite aid", "walmart", "target", "hospital emergency"]
                    if excludeTerms.contains(where: { nameLower.contains($0) }) {
                        return nil
                    }

                    let clinicLocation = CLLocation(
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude
                    )
                    let distance = location.distance(from: clinicLocation) / 1609.34

                    // Determine clinic type from name
                    var clinicType: ClinicType = .communityHealth
                    if nameLower.contains("free") {
                        clinicType = .freeClinic
                    } else if nameLower.contains("urgent") {
                        clinicType = .urgentCare
                    } else if nameLower.contains("dental") {
                        clinicType = .dental
                    } else if nameLower.contains("mental") || nameLower.contains("behavioral") {
                        clinicType = .mentalHealth
                    }

                    return Clinic(
                        id: UUID(),
                        name: name,
                        type: clinicType,
                        address: item.placemark.thoroughfare ?? item.placemark.name ?? "",
                        city: item.placemark.locality ?? "",
                        state: item.placemark.administrativeArea ?? "",
                        zipCode: item.placemark.postalCode ?? "",
                        phoneNumber: item.phoneNumber ?? "Call for information",
                        website: item.url?.absoluteString,
                        email: nil,
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude,
                        services: ClinicServices(
                            acceptsUninsured: true,
                            slidingScale: true,
                            freeServices: clinicType == .freeClinic,
                            interpreterAvailable: true,
                            languages: [.english, .spanish],
                            walkInsAccepted: clinicType == .urgentCare,
                            telehealth: false,
                            transportationHelp: false,
                            mentalHealth: clinicType == .mentalHealth,
                            dental: clinicType == .dental,
                            vision: false,
                            prenatal: false,
                            pediatric: true,
                            vaccinations: true,
                            emergencyMedicaid: false
                        ),
                        hours: self.defaultHours,
                        description: "Community health center found via Apple Maps. As a health center, they may offer sliding scale fees based on income. Please call to confirm services, hours, and payment options.",
                        specialNotes: "📞 Call ahead to confirm:\n• Acceptance of uninsured patients\n• Sliding scale fees available\n• Languages spoken\n• Services offered",
                        rating: nil,
                        reviewCount: 0,
                        distance: distance
                    )
                }

                allMapKitClinics.append(contentsOf: clinics)
            }
        }

        searchGroup.notify(queue: .main) { [weak self] in
            // Remove duplicates from MapKit results
            var uniqueClinics: [Clinic] = []
            for clinic in allMapKitClinics {
                let isDuplicate = uniqueClinics.contains { existing in
                    self?.areClinicsLikelySame(existing, clinic) ?? false
                }
                if !isDuplicate {
                    uniqueClinics.append(clinic)
                }
            }

            // Sort by distance
            uniqueClinics.sort { ($0.distance ?? 999) < ($1.distance ?? 999) }

            self?.nearbyMapKitClinics = uniqueClinics
            completion(uniqueClinics)
        }
    }

    private var defaultHours: [OperatingHours] {
        [
            OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
            OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
            OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
            OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
            OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
            OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
            OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
        ]
    }

    // Get clinics from static database near a location
    func getClinicsFromDatabase(near location: CLLocation, radius: Double = 50.0) -> [Clinic] {
        return allClinics.map { clinic in
            var updatedClinic = clinic
            let clinicLocation = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            updatedClinic.distance = location.distance(from: clinicLocation) / 1609.34
            return updatedClinic
        }
        .filter { ($0.distance ?? 0) <= radius }
        .sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    // Legacy method for backward compatibility
    func getClinics(near location: CLLocation, radius: Double = 50.0) -> [Clinic] {
        return getClinicsFromDatabase(near: location, radius: radius)
    }

    // Filter clinics for uninsured patients
    func filterClinicsForUninsured(_ clinics: [Clinic]) -> [Clinic] {
        return clinics.filter { clinic in
            clinic.services.acceptsUninsured &&
            (clinic.services.freeServices || clinic.services.slidingScale || clinic.services.emergencyMedicaid)
        }.sorted { clinic1, clinic2 in
            // Prioritize free services
            if clinic1.services.freeServices && !clinic2.services.freeServices { return true }
            if !clinic1.services.freeServices && clinic2.services.freeServices { return false }
            return (clinic1.distance ?? 0) < (clinic2.distance ?? 0)
        }
    }

    // Get clinics by ZIP code
    func getClinics(forZipCode zipCode: String) -> [Clinic] {
        // Match by first 3 digits of ZIP (same area)
        let areaCode = String(zipCode.prefix(3))
        let exactMatch = allClinics.filter { String($0.zipCode.prefix(3)) == areaCode }
        if !exactMatch.isEmpty {
            return exactMatch
        }

        // Get state from ZIP code range
        let state = getStateFromZip(zipCode)
        return allClinics.filter { $0.state == state }
    }

    private func getStateFromZip(_ zip: String) -> String {
        guard let zipInt = Int(zip.prefix(3)) else { return "" }
        switch zipInt {
        case 900...961: return "CA"
        case 100...149: return "NY"
        case 770...799: return "TX"
        case 606...629: return "IL"
        case 330...349: return "FL"
        case 850...865: return "AZ"
        case 980...994: return "WA"
        default: return ""
        }
    }

    // MARK: - Comprehensive California Clinic Database
    // All FQHCs and free clinics serve patients regardless of immigration status
    let allClinics: [Clinic] = [
        // ============================================
        // CALIFORNIA - LOS ANGELES COUNTY (Extensive)
        // ============================================
        Clinic(
            id: UUID(),
            name: "UMMA Community Clinic",
            type: .freeClinic,
            address: "711 W Florence Ave",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90044",
            phoneNumber: "(323) 789-6862",
            website: "https://www.ummaclinic.org",
            email: "info@ummaclinic.org",
            latitude: 33.9831,
            longitude: -118.2987,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish, .arabic],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "08:00", closeTime: "14:00")
            ],
            description: "UMMA Community Clinic provides FREE comprehensive healthcare to uninsured and underserved residents of South Los Angeles. We DO NOT ask about immigration status. Services include primary care, dental, vision, mental health, and health education.",
            specialNotes: "✓ FREE for uninsured patients\n✓ No immigration questions asked\n✓ Arabic & Spanish interpreters\n✓ Walk-ins welcome",
            rating: 4.8,
            reviewCount: 523
        ),

        Clinic(
            id: UUID(),
            name: "Saban Community Clinic",
            type: .freeClinic,
            address: "8405 Beverly Blvd",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90048",
            phoneNumber: "(323) 653-1990",
            website: "https://www.sabancommunityclinic.org",
            email: nil,
            latitude: 34.0761,
            longitude: -118.3699,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "13:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Saban Community Clinic (formerly LA Free Clinic) has provided free and low-cost healthcare since 1967. We serve ALL patients regardless of immigration status or ability to pay.",
            specialNotes: "✓ Serving LA since 1967\n✓ No documentation required\n✓ Sliding scale fees\n✓ LGBTQ+ affirming care",
            rating: 4.7,
            reviewCount: 412
        ),

        Clinic(
            id: UUID(),
            name: "St. John's Well Child and Family Center - Compton",
            type: .communityHealth,
            address: "2115 N Wilmington Ave",
            city: "Compton",
            state: "CA",
            zipCode: "90222",
            phoneNumber: "(310) 631-5953",
            website: "https://www.wellchild.org",
            email: nil,
            latitude: 33.8958,
            longitude: -118.2353,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "13:00")
            ],
            description: "St. John's is a Federally Qualified Health Center serving South LA and Compton. As an FQHC, we serve ALL patients regardless of immigration status with sliding scale fees based on income.",
            specialNotes: "✓ FQHC - serves everyone\n✓ Medi-Cal enrollment help\n✓ WIC program on site\n✓ Transportation assistance",
            rating: 4.5,
            reviewCount: 345
        ),

        Clinic(
            id: UUID(),
            name: "APLA Health - Los Angeles",
            type: .communityHealth,
            address: "3743 S La Brea Ave",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90016",
            phoneNumber: "(323) 330-8000",
            website: "https://aplahealth.org",
            email: nil,
            latitude: 34.0138,
            longitude: -118.3435,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: false,
                prenatal: false,
                pediatric: false,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 3, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 4, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 5, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 6, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "APLA Health provides comprehensive healthcare regardless of immigration status. Specializing in HIV/AIDS services, primary care, mental health, and dental care for underserved communities.",
            specialNotes: "✓ HIV/PrEP services\n✓ LGBTQ+ affirming\n✓ No immigration questions\n✓ Case management available",
            rating: 4.6,
            reviewCount: 289
        ),

        Clinic(
            id: UUID(),
            name: "AltaMed Health Services - East LA",
            type: .communityHealth,
            address: "5427 E Whittier Blvd",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90022",
            phoneNumber: "(877) 462-2582",
            website: "https://www.altamed.org",
            email: nil,
            latitude: 34.0235,
            longitude: -118.1569,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 3, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 4, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "08:00", closeTime: "14:00")
            ],
            description: "AltaMed is the largest FQHC in California, providing culturally sensitive care to Latino communities. We accept all patients regardless of immigration status and offer sliding scale fees.",
            specialNotes: "✓ Largest Latino health network\n✓ 40+ locations in LA/OC\n✓ Medi-Cal enrollment\n✓ Evening & weekend hours",
            rating: 4.4,
            reviewCount: 567
        ),

        // ============================================
        // CALIFORNIA - SAN FRANCISCO BAY AREA
        // ============================================
        Clinic(
            id: UUID(),
            name: "La Clínica de La Raza - Fruitvale",
            type: .communityHealth,
            address: "1515 Fruitvale Ave",
            city: "Oakland",
            state: "CA",
            zipCode: "94601",
            phoneNumber: "(510) 535-4000",
            website: "https://www.laclinica.org",
            email: nil,
            latitude: 37.7746,
            longitude: -122.2241,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "La Clínica de La Raza has been serving the Bay Area's Latino community since 1971. As an FQHC, we provide care to ALL patients regardless of immigration status or ability to pay.",
            specialNotes: "✓ Serving community since 1971\n✓ FQHC - no immigration questions\n✓ 35+ locations in Bay Area\n✓ Full service health home",
            rating: 4.7,
            reviewCount: 423
        ),

        Clinic(
            id: UUID(),
            name: "San Francisco Free Clinic",
            type: .freeClinic,
            address: "4900 California St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94118",
            phoneNumber: "(415) 750-9894",
            website: "https://www.sffc.org",
            email: nil,
            latitude: 37.7849,
            longitude: -122.4636,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: false,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish, .mandarin],
                walkInsAccepted: true,
                telehealth: false,
                transportationHelp: false,
                mentalHealth: false,
                dental: false,
                vision: false,
                prenatal: false,
                pediatric: false,
                vaccinations: true,
                emergencyMedicaid: false
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "17:30", closeTime: "21:00"),
                OperatingHours(dayOfWeek: 3, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 4, openTime: "17:30", closeTime: "21:00"),
                OperatingHours(dayOfWeek: 5, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "San Francisco Free Clinic provides FREE primary care to uninsured adults. We never ask about immigration status or require ID. Evening hours available.",
            specialNotes: "✓ 100% FREE services\n✓ No ID required\n✓ No immigration questions\n✓ Evening clinic hours",
            rating: 4.8,
            reviewCount: 234
        ),

        Clinic(
            id: UUID(),
            name: "Clínica de la Comunidad - San Jose",
            type: .communityHealth,
            address: "725 E Santa Clara St",
            city: "San Jose",
            state: "CA",
            zipCode: "95112",
            phoneNumber: "(408) 288-5855",
            website: "https://www.clinica.org",
            email: nil,
            latitude: 37.3412,
            longitude: -121.8781,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .vietnamese],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Clínica de la Comunidad serves Silicon Valley's immigrant community. As an FQHC, we provide comprehensive healthcare regardless of immigration status with bilingual staff.",
            specialNotes: "✓ FQHC status\n✓ Trilingual staff\n✓ Medi-Cal enrollment help\n✓ Same-day appointments",
            rating: 4.5,
            reviewCount: 312
        ),

        // ============================================
        // CALIFORNIA - SAN DIEGO
        // ============================================
        Clinic(
            id: UUID(),
            name: "Family Health Centers of San Diego",
            type: .communityHealth,
            address: "823 Gateway Center Way",
            city: "San Diego",
            state: "CA",
            zipCode: "92102",
            phoneNumber: "(619) 515-2300",
            website: "https://www.fhcsd.org",
            email: nil,
            latitude: 32.7157,
            longitude: -117.1611,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 3, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 4, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "08:00", closeTime: "14:00")
            ],
            description: "Family Health Centers of San Diego is the largest FQHC in San Diego County. We serve ALL patients regardless of immigration status, insurance, or ability to pay.",
            specialNotes: "✓ 30+ locations county-wide\n✓ No immigration questions\n✓ Refugee health services\n✓ Extended hours",
            rating: 4.6,
            reviewCount: 534
        ),

        Clinic(
            id: UUID(),
            name: "San Ysidro Health - Main Campus",
            type: .communityHealth,
            address: "1601 Precision Park Lane",
            city: "San Diego",
            state: "CA",
            zipCode: "92173",
            phoneNumber: "(619) 662-4100",
            website: "https://www.syhealth.org",
            email: nil,
            latitude: 32.5564,
            longitude: -117.0355,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "San Ysidro Health serves the US-Mexico border region. As an FQHC near the border, we specialize in serving immigrant families and cross-border patients regardless of status.",
            specialNotes: "✓ Border community expertise\n✓ Binational health services\n✓ Immigration-friendly\n✓ 40+ locations",
            rating: 4.5,
            reviewCount: 478
        ),

        // ============================================
        // CALIFORNIA - CENTRAL VALLEY
        // ============================================
        Clinic(
            id: UUID(),
            name: "Clinica Sierra Vista - Fresno",
            type: .communityHealth,
            address: "1455 E Floradora Ave",
            city: "Fresno",
            state: "CA",
            zipCode: "93706",
            phoneNumber: "(559) 457-5200",
            website: "https://www.clinicasierravista.org",
            email: nil,
            latitude: 36.7578,
            longitude: -119.7739,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Clinica Sierra Vista is the largest FQHC in the Central Valley, serving agricultural communities. We welcome ALL patients regardless of immigration status.",
            specialNotes: "✓ Farmworker health specialist\n✓ Mobile clinics for rural areas\n✓ Interpreter services\n✓ No ID required",
            rating: 4.4,
            reviewCount: 356
        ),

        Clinic(
            id: UUID(),
            name: "Golden Valley Health Centers - Modesto",
            type: .communityHealth,
            address: "735 McHenry Ave",
            city: "Modesto",
            state: "CA",
            zipCode: "95350",
            phoneNumber: "(209) 527-1900",
            website: "https://www.gvhc.org",
            email: nil,
            latitude: 37.6391,
            longitude: -120.9969,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Golden Valley Health Centers serves the Central Valley with 40+ locations. As an FQHC, we provide care to everyone regardless of immigration status.",
            specialNotes: "✓ 40+ locations\n✓ Farmworker outreach\n✓ Same-week appointments\n✓ All are welcome",
            rating: 4.3,
            reviewCount: 287
        ),

        // ============================================
        // CALIFORNIA - ORANGE COUNTY
        // ============================================
        Clinic(
            id: UUID(),
            name: "AltaMed Health Services - Santa Ana",
            type: .communityHealth,
            address: "1400 N Main St",
            city: "Santa Ana",
            state: "CA",
            zipCode: "92701",
            phoneNumber: "(877) 462-2582",
            website: "https://www.altamed.org",
            email: nil,
            latitude: 33.7595,
            longitude: -117.8684,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .vietnamese],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 3, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 4, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "08:00", closeTime: "14:00")
            ],
            description: "AltaMed Santa Ana serves Orange County's diverse population. We welcome ALL patients regardless of immigration status with comprehensive services.",
            specialNotes: "✓ California's largest FQHC\n✓ Vietnamese interpreters\n✓ Medi-Cal enrollment\n✓ Extended hours",
            rating: 4.5,
            reviewCount: 423
        ),

        Clinic(
            id: UUID(),
            name: "Share Our Selves - Costa Mesa",
            type: .freeClinic,
            address: "1550 Superior Ave",
            city: "Costa Mesa",
            state: "CA",
            zipCode: "92627",
            phoneNumber: "(949) 270-2100",
            website: "https://www.shareourselves.org",
            email: nil,
            latitude: 33.6469,
            longitude: -117.9130,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: false,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: false,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: false
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "12:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Share Our Selves provides FREE healthcare to uninsured residents of Orange County. We do NOT ask about immigration status and serve all community members.",
            specialNotes: "✓ FREE services\n✓ No immigration questions\n✓ Food pantry on site\n✓ Social services available",
            rating: 4.8,
            reviewCount: 356
        ),

        // ============================================
        // ILLINOIS - CHICAGO (Comprehensive)
        // ============================================
        Clinic(
            id: UUID(),
            name: "Erie Family Health Centers - Humboldt Park",
            type: .communityHealth,
            address: "2750 W North Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60647",
            phoneNumber: "(312) 666-3494",
            website: "https://www.eriefamilyhealth.org",
            email: nil,
            latitude: 41.9103,
            longitude: -87.6946,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "13:00")
            ],
            description: "Erie Family Health Centers has served Chicago since 1957. As an FQHC, we serve ALL patients regardless of immigration status. We are a leader in serving the Latino community.",
            specialNotes: "✓ Serving Chicago since 1957\n✓ FQHC - no immigration questions\n✓ 13 locations citywide\n✓ Evening hours available",
            rating: 4.6,
            reviewCount: 567
        ),

        Clinic(
            id: UUID(),
            name: "Heartland Alliance Health - Refugee Health",
            type: .homelessHealth,
            address: "4411 N Ravenswood Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60640",
            phoneNumber: "(773) 751-8800",
            website: "https://www.heartlandalliance.org",
            email: nil,
            latitude: 41.9612,
            longitude: -87.6745,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .arabic, .french, .swahili, .somali, .burmese],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: false,
                vision: false,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "09:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Heartland Alliance Health specializes in healthcare for refugees, asylum seekers, and immigrants. We provide trauma-informed care and help navigate the US healthcare system.",
            specialNotes: "✓ Refugee & immigrant specialists\n✓ 20+ language interpreters\n✓ Torture survivor program\n✓ Cultural navigators on staff",
            rating: 4.9,
            reviewCount: 312
        ),

        Clinic(
            id: UUID(),
            name: "Alivio Medical Center",
            type: .communityHealth,
            address: "2355 S Western Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60608",
            phoneNumber: "(773) 254-1400",
            website: "https://www.aliviomedicalcenter.org",
            email: nil,
            latitude: 41.8495,
            longitude: -87.6856,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Alivio Medical Center serves Chicago's Pilsen and Little Village neighborhoods. As an FQHC, we provide care to ALL patients regardless of immigration status.",
            specialNotes: "✓ Pilsen community anchor\n✓ Bilingual staff\n✓ WIC program\n✓ Medi-Cal enrollment help",
            rating: 4.5,
            reviewCount: 423
        ),

        Clinic(
            id: UUID(),
            name: "PCC Community Wellness Center - Austin",
            type: .communityHealth,
            address: "5425 W Lake St",
            city: "Chicago",
            state: "IL",
            zipCode: "60644",
            phoneNumber: "(773) 378-6200",
            website: "https://www.pccwellness.org",
            email: nil,
            latitude: 41.8855,
            longitude: -87.7610,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: false,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "PCC Community Wellness Center serves Chicago's West Side communities. As an FQHC, we welcome everyone regardless of immigration status or ability to pay.",
            specialNotes: "✓ West Side community health\n✓ No immigration questions\n✓ Transportation assistance\n✓ Social services",
            rating: 4.4,
            reviewCount: 289
        ),

        Clinic(
            id: UUID(),
            name: "Near North Health Service Corporation",
            type: .communityHealth,
            address: "1276 N Clybourn Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60610",
            phoneNumber: "(312) 337-1073",
            website: "https://www.nearnorthhealth.org",
            email: nil,
            latitude: 41.9052,
            longitude: -87.6519,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "12:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Near North Health serves Chicago's North Side. As an FQHC, we provide healthcare to all patients regardless of immigration status, insurance, or ability to pay.",
            specialNotes: "✓ Multiple North Side locations\n✓ FQHC - serves everyone\n✓ Sliding scale fees\n✓ Pediatric specialty",
            rating: 4.5,
            reviewCount: 345
        ),

        Clinic(
            id: UUID(),
            name: "Lawndale Christian Health Center",
            type: .communityHealth,
            address: "3860 W Ogden Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60623",
            phoneNumber: "(773) 843-3000",
            website: "https://www.lawndale.org",
            email: nil,
            latitude: 41.8575,
            longitude: -87.7219,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Lawndale Christian Health Center serves Chicago's West Side with compassionate, whole-person care. We welcome ALL patients regardless of immigration status.",
            specialNotes: "✓ Holistic care approach\n✓ Social services on site\n✓ Youth programs\n✓ Community focused",
            rating: 4.7,
            reviewCount: 456
        ),

        Clinic(
            id: UUID(),
            name: "CommunityHealth - Free Clinic",
            type: .freeClinic,
            address: "2611 W Chicago Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60622",
            phoneNumber: "(773) 292-4455",
            website: "https://www.communityhealth.org",
            email: nil,
            latitude: 41.8956,
            longitude: -87.6910,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: false,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: false,
                transportationHelp: false,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: false,
                pediatric: false,
                vaccinations: true,
                emergencyMedicaid: false
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "09:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "13:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "CommunityHealth provides FREE healthcare to uninsured adults in Chicago. We NEVER ask about immigration status and serve everyone who needs care.",
            specialNotes: "✓ 100% FREE services\n✓ No immigration questions\n✓ No ID required\n✓ Volunteer physicians",
            rating: 4.8,
            reviewCount: 234
        ),

        // ============================================
        // NEW YORK (Comprehensive)
        // ============================================
        Clinic(
            id: UUID(),
            name: "Ryan Health - Refugee Health Program",
            type: .homelessHealth,
            address: "110 W 97th St",
            city: "New York",
            state: "NY",
            zipCode: "10025",
            phoneNumber: "(212) 749-1820",
            website: "https://www.rfrhealth.org",
            email: nil,
            latitude: 40.7942,
            longitude: -73.9679,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .arabic, .french, .mandarin],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: false,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "08:30", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:30", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:30", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:30", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:30", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Ryan Health's Refugee Health Program provides specialized healthcare services for newly arrived refugees and asylum seekers in New York City.",
            specialNotes: "✓ Refugee specialists\n✓ 30+ language interpreters\n✓ Cultural navigators",
            rating: 4.9,
            reviewCount: 267
        ),

        Clinic(
            id: UUID(),
            name: "Avenue 360 Health & Wellness",
            type: .communityHealth,
            address: "2120 Alabama St",
            city: "Houston",
            state: "TX",
            zipCode: "77004",
            phoneNumber: "(713) 426-0027",
            website: "https://www.avenue360.org",
            email: nil,
            latitude: 29.7394,
            longitude: -95.3805,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: true,
                mentalHealth: true,
                dental: true,
                vision: true,
                prenatal: true,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: true
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 3, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 4, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 5, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 6, openTime: "07:00", closeTime: "19:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "14:00")
            ],
            description: "Avenue 360 provides comprehensive healthcare to Houston's underserved communities regardless of immigration status.",
            specialNotes: "✓ No one turned away\n✓ Transportation help\n✓ HIV services",
            rating: 4.7,
            reviewCount: 356
        )
    ]
}
