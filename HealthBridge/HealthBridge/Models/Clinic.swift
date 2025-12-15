import Foundation
import CoreLocation

// MARK: - Clinic Type
enum ClinicType: String, CaseIterable, Codable, Identifiable {
    case communityHealth = "community_health"
    case freeClinic = "free_clinic"
    case homelessHealth = "homeless_health"
    case urgentCare = "urgent_care"
    case emergency = "emergency"
    case mentalHealth = "mental_health"
    case dental = "dental"
    case vision = "vision"
    case prenatal = "prenatal"
    case pediatric = "pediatric"
    case pharmacy = "pharmacy"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .communityHealth: return "Community Health Center"
        case .freeClinic: return "Free Clinic"
        case .homelessHealth: return "Healthcare for the Homeless"
        case .urgentCare: return "Urgent Care"
        case .emergency: return "Emergency Room"
        case .mentalHealth: return "Mental Health"
        case .dental: return "Dental Clinic"
        case .vision: return "Vision Center"
        case .prenatal: return "Prenatal Care"
        case .pediatric: return "Pediatric Care"
        case .pharmacy: return "Pharmacy"
        }
    }

    var icon: String {
        switch self {
        case .communityHealth: return "building.2"
        case .freeClinic: return "cross.case"
        case .homelessHealth: return "hand.raised"
        case .urgentCare: return "staroflife"
        case .emergency: return "cross.circle.fill"
        case .mentalHealth: return "brain.head.profile"
        case .dental: return "mouth"
        case .vision: return "eye"
        case .prenatal: return "figure.and.child.holdinghands"
        case .pediatric: return "figure.2.and.child.holdinghands"
        case .pharmacy: return "pills"
        }
    }

    var color: String {
        switch self {
        case .communityHealth: return "blue"
        case .freeClinic: return "green"
        case .homelessHealth: return "orange"
        case .urgentCare: return "red"
        case .emergency: return "red"
        case .mentalHealth: return "teal"
        case .dental: return "cyan"
        case .vision: return "indigo"
        case .prenatal: return "pink"
        case .pediatric: return "mint"
        case .pharmacy: return "green"
        }
    }
}

// MARK: - Clinic Language (specific to clinics, more options than user preference)
enum ClinicLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case spanish = "es"
    case mandarin = "zh"
    case vietnamese = "vi"
    case tagalog = "tl"
    case korean = "ko"
    case arabic = "ar"
    case french = "fr"
    case russian = "ru"
    case portuguese = "pt"
    case somali = "so"
    case swahili = "sw"
    case burmese = "my"
    case dari = "prs"
    case pashto = "ps"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .mandarin: return "中文"
        case .vietnamese: return "Tiếng Việt"
        case .tagalog: return "Tagalog"
        case .korean: return "한국어"
        case .arabic: return "العربية"
        case .french: return "Français"
        case .russian: return "Русский"
        case .portuguese: return "Português"
        case .somali: return "Soomaali"
        case .swahili: return "Kiswahili"
        case .burmese: return "မြန်မာဘာသာ"
        case .dari: return "دری"
        case .pashto: return "پښتو"
        case .other: return "Other"
        }
    }
}

// MARK: - Clinic Services
struct ClinicServices: Codable {
    var acceptsUninsured: Bool = false
    var slidingScale: Bool = false
    var freeServices: Bool = false
    var interpreterAvailable: Bool = false
    var languages: [ClinicLanguage] = []
    var walkInsAccepted: Bool = false
    var telehealth: Bool = false
    var transportationHelp: Bool = false
    var mentalHealth: Bool = false
    var dental: Bool = false
    var vision: Bool = false
    var prenatal: Bool = false
    var pediatric: Bool = false
    var vaccinations: Bool = false
    var emergencyMedicaid: Bool = false
}

// MARK: - Operating Hours
struct OperatingHours: Codable {
    var dayOfWeek: Int // 1 = Sunday, 7 = Saturday
    var openTime: String
    var closeTime: String
    var isClosed: Bool = false

    var dayName: String {
        let days = ["", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek]
    }
}

// MARK: - Clinic
struct Clinic: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: ClinicType
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var phoneNumber: String
    var website: String?
    var email: String?
    var latitude: Double
    var longitude: Double
    var services: ClinicServices
    var hours: [OperatingHours]
    var description: String
    var specialNotes: String?
    var rating: Double?
    var reviewCount: Int = 0
    var distance: Double? // in miles, calculated dynamically

    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var isOpenNow: Bool {
        let calendar = Calendar.current
        let now = Date()
        let dayOfWeek = calendar.component(.weekday, from: now)

        guard let todayHours = hours.first(where: { $0.dayOfWeek == dayOfWeek }),
              !todayHours.isClosed else {
            return false
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let currentTime = formatter.string(from: now)

        return currentTime >= todayHours.openTime && currentTime <= todayHours.closeTime
    }

    // Sample clinics for development
    static let samples: [Clinic] = [
        Clinic(
            id: UUID(),
            name: "Community Care Health Center",
            type: .communityHealth,
            address: "123 Main Street",
            city: "Chicago",
            state: "IL",
            zipCode: "60601",
            phoneNumber: "(312) 555-0100",
            website: "https://example.com",
            email: "info@example.com",
            latitude: 41.8781,
            longitude: -87.6298,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .arabic],
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
                OperatingHours(dayOfWeek: 2, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 3, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 4, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 5, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 6, openTime: "08:00", closeTime: "18:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "14:00")
            ],
            description: "A federally qualified health center providing comprehensive primary care services to all community members regardless of ability to pay.",
            specialNotes: "Health screening available. Call for interpreter services.",
            rating: 4.5,
            reviewCount: 234
        ),
        Clinic(
            id: UUID(),
            name: "Free Health Clinic of Hope",
            type: .freeClinic,
            address: "456 Oak Avenue",
            city: "Chicago",
            state: "IL",
            zipCode: "60602",
            phoneNumber: "(312) 555-0200",
            website: nil,
            email: nil,
            latitude: 41.8819,
            longitude: -87.6278,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: false,
                freeServices: true,
                interpreterAvailable: true,
                languages: [.english, .spanish],
                walkInsAccepted: true,
                telehealth: false,
                transportationHelp: false,
                mentalHealth: false,
                dental: false,
                vision: false,
                prenatal: false,
                pediatric: true,
                vaccinations: true,
                emergencyMedicaid: false
            ),
            hours: [
                OperatingHours(dayOfWeek: 1, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 2, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 3, openTime: "17:00", closeTime: "21:00"),
                OperatingHours(dayOfWeek: 4, openTime: "09:00", closeTime: "17:00", isClosed: true),
                OperatingHours(dayOfWeek: 5, openTime: "17:00", closeTime: "21:00"),
                OperatingHours(dayOfWeek: 6, openTime: "09:00", closeTime: "14:00"),
                OperatingHours(dayOfWeek: 7, openTime: "09:00", closeTime: "17:00", isClosed: true)
            ],
            description: "Volunteer-run free clinic providing basic healthcare services to uninsured community members.",
            specialNotes: "No appointment needed. First come, first served.",
            rating: 4.8,
            reviewCount: 89
        ),
        Clinic(
            id: UUID(),
            name: "Homeless Health Services Center",
            type: .homelessHealth,
            address: "789 Unity Boulevard",
            city: "Chicago",
            state: "IL",
            zipCode: "60603",
            phoneNumber: "(312) 555-0300",
            website: "https://example.com",
            email: "contact@example.com",
            latitude: 41.8755,
            longitude: -87.6244,
            services: ClinicServices(
                acceptsUninsured: true,
                slidingScale: true,
                freeServices: false,
                interpreterAvailable: true,
                languages: [.english, .spanish, .somali, .swahili, .arabic],
                walkInsAccepted: true,
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
            description: "Specialized health services for people experiencing homelessness, including health screenings, mental health support, and case management.",
            specialNotes: "Interpreters available. Walk-ins welcome. No ID required.",
            rating: 4.9,
            reviewCount: 156
        )
    ]
}
