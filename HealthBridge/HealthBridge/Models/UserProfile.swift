import Foundation
import SwiftUI

// MARK: - Immigration Status
enum ImmigrationStatus: String, CaseIterable, Codable, Identifiable {
    case refugee = "refugee"
    case asylumSeeker = "asylum_seeker"
    case undocumented = "undocumented"
    case visa = "visa_holder"
    case greenCard = "green_card"
    case citizen = "citizen"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .refugee: return "Refugee"
        case .asylumSeeker: return "Asylum Seeker"
        case .undocumented: return "Undocumented"
        case .visa: return "Visa Holder"
        case .greenCard: return "Green Card Holder"
        case .citizen: return "Citizen"
        case .other: return "Other / Prefer not to say"
        }
    }

    var description: String {
        switch self {
        case .refugee: return "I came to this country as a refugee"
        case .asylumSeeker: return "I am seeking asylum protection"
        case .undocumented: return "I don't have legal documentation"
        case .visa: return "I have a temporary visa"
        case .greenCard: return "I have permanent residency"
        case .citizen: return "I am a citizen"
        case .other: return "Other situation"
        }
    }

    var icon: String {
        switch self {
        case .refugee: return "figure.walk.arrival"
        case .asylumSeeker: return "shield.lefthalf.filled"
        case .undocumented: return "person.crop.circle.badge.questionmark"
        case .visa: return "doc.text"
        case .greenCard: return "creditcard"
        case .citizen: return "person.crop.circle.badge.checkmark"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Housing Status
enum HousingStatus: String, CaseIterable, Codable, Identifiable {
    case stable = "stable"
    case temporary = "temporary"
    case shelter = "shelter"
    case homeless = "homeless"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .stable: return "Stable Housing"
        case .temporary: return "Temporary Housing"
        case .shelter: return "Shelter"
        case .homeless: return "Currently Homeless"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .stable: return "house.fill"
        case .temporary: return "house"
        case .shelter: return "building.2"
        case .homeless: return "figure.walk"
        case .other: return "ellipsis.circle"
        }
    }
}

// MARK: - Insurance Status
enum InsuranceStatus: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case medicaid = "medicaid"
    case medicare = "medicare"
    case marketplace = "marketplace"
    case employer = "employer"
    case emergencyMedicaid = "emergency_medicaid"
    case unsure = "unsure"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No Insurance"
        case .medicaid: return "Medicaid"
        case .medicare: return "Medicare"
        case .marketplace: return "Marketplace Plan"
        case .employer: return "Employer Insurance"
        case .emergencyMedicaid: return "Emergency Medicaid"
        case .unsure: return "Not Sure"
        }
    }
}

// MARK: - Language
enum PreferredLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case spanish = "es"
    case arabic = "ar"
    case french = "fr"
    case mandarin = "zh"
    case swahili = "sw"
    case ukrainian = "uk"
    case somali = "so"
    case amharic = "am"
    case dari = "prs"
    case pashto = "ps"
    case burmese = "my"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .arabic: return "العربية"
        case .french: return "Français"
        case .mandarin: return "中文"
        case .swahili: return "Kiswahili"
        case .ukrainian: return "Українська"
        case .somali: return "Soomaali"
        case .amharic: return "አማርኛ"
        case .dari: return "دری"
        case .pashto: return "پښتو"
        case .burmese: return "မြန်မာ"
        case .other: return "Other"
        }
    }
}

// MARK: - Health Concerns
enum HealthConcern: String, CaseIterable, Codable, Identifiable {
    case generalCheckup = "general_checkup"
    case mentalHealth = "mental_health"
    case dental = "dental"
    case vision = "vision"
    case pregnancy = "pregnancy"
    case childHealth = "child_health"
    case chronicCondition = "chronic"
    case medications = "medications"
    case vaccinations = "vaccinations"
    case emergency = "emergency"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .generalCheckup: return "General Check-up"
        case .mentalHealth: return "Mental Health Support"
        case .dental: return "Dental Care"
        case .vision: return "Vision / Eye Care"
        case .pregnancy: return "Pregnancy Care"
        case .childHealth: return "Children's Health"
        case .chronicCondition: return "Chronic Condition"
        case .medications: return "Need Medications"
        case .vaccinations: return "Vaccinations"
        case .emergency: return "Urgent Health Issue"
        }
    }

    var icon: String {
        switch self {
        case .generalCheckup: return "stethoscope"
        case .mentalHealth: return "brain.head.profile"
        case .dental: return "mouth"
        case .vision: return "eye"
        case .pregnancy: return "figure.and.child.holdinghands"
        case .childHealth: return "figure.2.and.child.holdinghands"
        case .chronicCondition: return "heart.text.square"
        case .medications: return "pills"
        case .vaccinations: return "syringe"
        case .emergency: return "cross.case"
        }
    }
}

// MARK: - User Profile
class UserProfile: ObservableObject, Codable {
    @Published var name: String = ""
    @Published var dateOfBirth: Date?
    @Published var countryOfOrigin: String = ""
    @Published var arrivalDate: Date?
    @Published var immigrationStatus: ImmigrationStatus?
    @Published var housingStatus: HousingStatus?
    @Published var insuranceStatus: InsuranceStatus = .unsure
    @Published var preferredLanguage: PreferredLanguage = .english
    @Published var spokenLanguages: [PreferredLanguage] = []
    @Published var healthConcerns: [HealthConcern] = []
    @Published var hasChildren: Bool = false
    @Published var numberOfChildren: Int = 0
    @Published var zipCode: String = ""
    @Published var phoneNumber: String = ""
    @Published var needsInterpreter: Bool = true
    @Published var hasTransportation: Bool = false
    @Published var emergencyContactName: String = ""
    @Published var emergencyContactPhone: String = ""
    @Published var allergies: String = ""
    @Published var currentMedications: String = ""
    @Published var medicalHistory: String = ""

    enum CodingKeys: String, CodingKey {
        case name, dateOfBirth, countryOfOrigin, arrivalDate
        case immigrationStatus, housingStatus, insuranceStatus
        case preferredLanguage, spokenLanguages, healthConcerns
        case hasChildren, numberOfChildren, zipCode, phoneNumber
        case needsInterpreter, hasTransportation
        case emergencyContactName, emergencyContactPhone
        case allergies, currentMedications, medicalHistory
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        dateOfBirth = try container.decodeIfPresent(Date.self, forKey: .dateOfBirth)
        countryOfOrigin = try container.decode(String.self, forKey: .countryOfOrigin)
        arrivalDate = try container.decodeIfPresent(Date.self, forKey: .arrivalDate)
        immigrationStatus = try container.decodeIfPresent(ImmigrationStatus.self, forKey: .immigrationStatus)
        housingStatus = try container.decodeIfPresent(HousingStatus.self, forKey: .housingStatus)
        insuranceStatus = try container.decode(InsuranceStatus.self, forKey: .insuranceStatus)
        preferredLanguage = try container.decode(PreferredLanguage.self, forKey: .preferredLanguage)
        spokenLanguages = try container.decode([PreferredLanguage].self, forKey: .spokenLanguages)
        healthConcerns = try container.decode([HealthConcern].self, forKey: .healthConcerns)
        hasChildren = try container.decode(Bool.self, forKey: .hasChildren)
        numberOfChildren = try container.decode(Int.self, forKey: .numberOfChildren)
        zipCode = try container.decode(String.self, forKey: .zipCode)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        needsInterpreter = try container.decode(Bool.self, forKey: .needsInterpreter)
        hasTransportation = try container.decode(Bool.self, forKey: .hasTransportation)
        emergencyContactName = try container.decode(String.self, forKey: .emergencyContactName)
        emergencyContactPhone = try container.decode(String.self, forKey: .emergencyContactPhone)
        allergies = try container.decode(String.self, forKey: .allergies)
        currentMedications = try container.decode(String.self, forKey: .currentMedications)
        medicalHistory = try container.decode(String.self, forKey: .medicalHistory)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(dateOfBirth, forKey: .dateOfBirth)
        try container.encode(countryOfOrigin, forKey: .countryOfOrigin)
        try container.encodeIfPresent(arrivalDate, forKey: .arrivalDate)
        try container.encodeIfPresent(immigrationStatus, forKey: .immigrationStatus)
        try container.encodeIfPresent(housingStatus, forKey: .housingStatus)
        try container.encode(insuranceStatus, forKey: .insuranceStatus)
        try container.encode(preferredLanguage, forKey: .preferredLanguage)
        try container.encode(spokenLanguages, forKey: .spokenLanguages)
        try container.encode(healthConcerns, forKey: .healthConcerns)
        try container.encode(hasChildren, forKey: .hasChildren)
        try container.encode(numberOfChildren, forKey: .numberOfChildren)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(needsInterpreter, forKey: .needsInterpreter)
        try container.encode(hasTransportation, forKey: .hasTransportation)
        try container.encode(emergencyContactName, forKey: .emergencyContactName)
        try container.encode(emergencyContactPhone, forKey: .emergencyContactPhone)
        try container.encode(allergies, forKey: .allergies)
        try container.encode(currentMedications, forKey: .currentMedications)
        try container.encode(medicalHistory, forKey: .medicalHistory)
    }

    func save() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }

    static func load() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            return profile
        }
        return UserProfile()
    }

    // MARK: - Eligibility Helpers
    var mayQualifyForMedicaid: Bool {
        // Refugees, asylees, and some others may qualify
        guard let status = immigrationStatus else { return false }
        return [.refugee, .asylumSeeker, .greenCard, .citizen].contains(status)
    }

    var mayQualifyForEmergencyMedicaid: Bool {
        // Emergency Medicaid available regardless of status
        return true
    }

    var needsHomelessServices: Bool {
        return housingStatus == .homeless || housingStatus == .shelter
    }

    var recommendedClinics: [String] {
        var types: [String] = []

        // Community health centers serve everyone
        types.append("Community Health Center")

        if needsHomelessServices {
            types.append("Healthcare for the Homeless")
        }

        if immigrationStatus == .refugee {
            types.append("Refugee Health Clinic")
        }

        if healthConcerns.contains(.mentalHealth) {
            types.append("Mental Health Services")
        }

        if healthConcerns.contains(.pregnancy) {
            types.append("Prenatal Care")
        }

        if insuranceStatus == .none {
            types.append("Free Clinic")
            types.append("Sliding Scale Clinic")
        }

        return types
    }
}
