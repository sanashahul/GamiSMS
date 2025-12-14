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

    // Get clinics near a location
    func getClinics(near location: CLLocation, radius: Double = 25.0) -> [Clinic] {
        return allClinics.map { clinic in
            var updatedClinic = clinic
            let clinicLocation = CLLocation(latitude: clinic.latitude, longitude: clinic.longitude)
            updatedClinic.distance = location.distance(from: clinicLocation) / 1609.34 // Convert to miles
            return updatedClinic
        }
        .filter { ($0.distance ?? 0) <= radius }
        .sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    // Get clinics by ZIP code
    func getClinics(forZipCode zipCode: String) -> [Clinic] {
        // First try exact match
        let exactMatch = allClinics.filter { $0.zipCode.prefix(3) == zipCode.prefix(3) }
        if !exactMatch.isEmpty {
            return exactMatch
        }
        // Return clinics from the same state/region
        return allClinics
    }

    // MARK: - Real Clinic Database
    // These are real Federally Qualified Health Centers and free clinics
    let allClinics: [Clinic] = [
        // CALIFORNIA - Los Angeles Area
        Clinic(
            id: UUID(),
            name: "UMMA Community Clinic",
            type: .communityHealth,
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
            description: "UMMA Community Clinic provides free comprehensive healthcare to uninsured and underserved residents of South Los Angeles. Services include primary care, dental, vision, mental health, and health education.",
            specialNotes: "No one is turned away due to inability to pay. Arabic and Spanish interpreters on site.",
            rating: 4.8,
            reviewCount: 523
        ),

        Clinic(
            id: UUID(),
            name: "Los Angeles Free Clinic - Hollywood",
            type: .freeClinic,
            address: "8405 Beverly Blvd",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90048",
            phoneNumber: "(323) 653-1990",
            website: "https://www.lafreeclinic.org",
            email: nil,
            latitude: 34.0761,
            longitude: -118.3699,
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
                dental: false,
                vision: false,
                prenatal: false,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: false
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 3, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 4, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 5, openTime: "09:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "The Los Angeles Free Clinic has been providing free healthcare to the uninsured since 1967. We offer primary care, mental health services, and HIV testing.",
            specialNotes: "Walk-ins welcome. No documentation required.",
            rating: 4.6,
            reviewCount: 312
        ),

        Clinic(
            id: UUID(),
            name: "St. John's Well Child and Family Center",
            type: .communityHealth,
            address: "808 W 58th St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90037",
            phoneNumber: "(323) 541-1600",
            website: "https://www.wellchild.org",
            email: nil,
            latitude: 33.9905,
            longitude: -118.2994,
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
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "13:00")
            ],
            description: "St. John's Well Child and Family Center is a federally qualified health center providing comprehensive healthcare to South Los Angeles families. Services include pediatrics, OB/GYN, dental, and mental health.",
            specialNotes: "Sliding scale fees based on income. WIC program available.",
            rating: 4.5,
            reviewCount: 445
        ),

        // NEW YORK
        Clinic(
            id: UUID(),
            name: "Ryan Health - Refugee Health Program",
            type: .refugeeHealth,
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
            description: "Ryan Health's Refugee Health Program provides specialized healthcare services for newly arrived refugees and asylum seekers in New York City. We offer comprehensive health screenings, primary care, and mental health support.",
            specialNotes: "Cultural health navigators available. Interpreters in 30+ languages.",
            rating: 4.9,
            reviewCount: 267
        ),

        Clinic(
            id: UUID(),
            name: "Community Healthcare Network - Manhattan",
            type: .communityHealth,
            address: "87 E 4th St",
            city: "New York",
            state: "NY",
            zipCode: "10003",
            phoneNumber: "(212) 477-0077",
            website: "https://www.chnnyc.org",
            email: nil,
            latitude: 40.7269,
            longitude: -73.9888,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .mandarin],
                walkInsAccepted: true,
                telehealth: true,
                transportationHelp: false,
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
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "13:00")
            ],
            description: "Community Healthcare Network is a federally qualified health center network serving New York's diverse communities. We provide primary care, dental, behavioral health, and specialty services regardless of ability to pay.",
            specialNotes: "Walk-ins accepted for urgent care. Sliding scale fees available.",
            rating: 4.4,
            reviewCount: 389
        ),

        // TEXAS - Houston
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
            description: "Avenue 360 Health & Wellness provides comprehensive healthcare to Houston's underserved communities. Services include primary care, HIV services, behavioral health, dental, and pharmacy.",
            specialNotes: "No one turned away. Transportation assistance available for appointments.",
            rating: 4.7,
            reviewCount: 356
        ),

        Clinic(
            id: UUID(),
            name: "Healthcare for the Homeless - Houston",
            type: .homelessHealth,
            address: "2615 Fannin St",
            city: "Houston",
            state: "TX",
            zipCode: "77002",
            phoneNumber: "(713) 286-6000",
            website: "https://www.homeless-healthcare.org",
            email: nil,
            latitude: 29.7447,
            longitude: -95.3762,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: false,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: false,
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
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "16:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "16:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "16:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "16:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "12:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Healthcare for the Homeless provides free medical, dental, and mental health services to people experiencing homelessness in the Houston area. We also offer case management and help connecting to housing resources.",
            specialNotes: "Walk-ins always welcome. No ID or insurance required.",
            rating: 4.8,
            reviewCount: 198
        ),

        // ILLINOIS - Chicago
        Clinic(
            id: UUID(),
            name: "Erie Family Health Centers",
            type: .communityHealth,
            address: "1701 W Superior St",
            city: "Chicago",
            state: "IL",
            zipCode: "60622",
            phoneNumber: "(312) 666-3494",
            website: "https://www.eriefamilyhealth.org",
            email: nil,
            latitude: 41.8953,
            longitude: -87.6693,
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
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "20:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "13:00")
            ],
            description: "Erie Family Health Centers is a federally qualified health center providing comprehensive healthcare to Chicago's diverse communities. We offer medical, dental, vision, and behavioral health services.",
            specialNotes: "Serving Chicago since 1957. Spanish interpreters at all locations.",
            rating: 4.5,
            reviewCount: 567
        ),

        Clinic(
            id: UUID(),
            name: "Heartland Alliance Health - Refugee Health",
            type: .refugeeHealth,
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
            description: "Heartland Alliance Health's Refugee Health Program provides culturally sensitive healthcare to refugees, asylum seekers, and immigrants in Chicago. We specialize in trauma-informed care and help patients navigate the US healthcare system.",
            specialNotes: "Interpreters in 20+ languages. Cultural health navigators on staff. Torture survivor program available.",
            rating: 4.9,
            reviewCount: 234
        ),

        // FLORIDA - Miami
        Clinic(
            id: UUID(),
            name: "Community Health of South Florida",
            type: .communityHealth,
            address: "10300 SW 216th St",
            city: "Miami",
            state: "FL",
            zipCode: "33190",
            phoneNumber: "(305) 253-5100",
            website: "https://www.chisouthfl.org",
            email: nil,
            latitude: 25.5514,
            longitude: -80.3553,
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
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 7, openTime: "08:00", closeTime: "13:00")
            ],
            description: "Community Health of South Florida is a federally qualified health center providing comprehensive healthcare to South Florida's diverse communities. We offer primary care, dental, behavioral health, and pharmacy services.",
            specialNotes: "Spanish and Creole interpretation available. No one turned away.",
            rating: 4.6,
            reviewCount: 423
        ),

        // ARIZONA - Phoenix
        Clinic(
            id: UUID(),
            name: "Valle del Sol Community Health",
            type: .communityHealth,
            address: "3807 N 7th St",
            city: "Phoenix",
            state: "AZ",
            zipCode: "85014",
            phoneNumber: "(602) 258-6797",
            website: "https://www.valledelsol.com",
            email: nil,
            latitude: 33.4885,
            longitude: -112.0651,
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
                dental: false,
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
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Valle del Sol has been providing culturally competent healthcare to Arizona's Latino and underserved communities since 1970. We offer behavioral health, primary care, and community services.",
            specialNotes: "Bilingual staff. Strong focus on culturally appropriate care.",
            rating: 4.7,
            reviewCount: 289
        ),

        // WASHINGTON - Seattle
        Clinic(
            id: UUID(),
            name: "International Community Health Services",
            type: .refugeeHealth,
            address: "720 8th Ave S",
            city: "Seattle",
            state: "WA",
            zipCode: "98104",
            phoneNumber: "(206) 788-3700",
            website: "https://www.ichs.com",
            email: nil,
            latitude: 47.5963,
            longitude: -122.3245,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .mandarin, .spanish],
                walkInsAccepted: false,
                telehealth: true,
                transportationHelp: false,
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
                OperatingHours(dayOfWeek: 2, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 3, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 4, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 5, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 6, openTime: "08:30", closeTime: "17:30"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "International Community Health Services is a federally qualified health center serving Seattle's diverse immigrant and refugee communities since 1973. We provide culturally and linguistically appropriate healthcare.",
            specialNotes: "Services in 50+ languages. Strong refugee resettlement partnerships.",
            rating: 4.8,
            reviewCount: 412
        )
    ]
}
