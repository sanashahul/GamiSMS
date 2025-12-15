import Foundation
import SwiftUI

// MARK: - Service Areas
enum ServiceArea: String, CaseIterable, Codable, Identifiable {
    case healthcare = "healthcare"
    case employment = "employment"
    case housing = "housing"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .healthcare: return "Healthcare"
        case .employment: return "Employment"
        case .housing: return "Housing"
        }
    }

    var icon: String {
        switch self {
        case .healthcare: return "cross.case.fill"
        case .employment: return "briefcase.fill"
        case .housing: return "house.fill"
        }
    }

    var color: String {
        switch self {
        case .healthcare: return "red"
        case .employment: return "blue"
        case .housing: return "green"
        }
    }

    var description: String {
        switch self {
        case .healthcare: return "Find clinics, get care, manage your health"
        case .employment: return "Job search, training, career resources"
        case .housing: return "Shelters, housing programs, rental assistance"
        }
    }
}

// MARK: - Healthcare Questions
enum InsuranceStatus: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case medicaid = "medicaid"
    case medicare = "medicare"
    case marketplace = "marketplace"
    case employer = "employer"
    case unsure = "unsure"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No Insurance"
        case .medicaid: return "Medicaid"
        case .medicare: return "Medicare"
        case .marketplace: return "Marketplace Plan"
        case .employer: return "Employer Insurance"
        case .unsure: return "Not Sure"
        }
    }
}

enum UrgentHealthNeed: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case illness = "illness"
    case injury = "injury"
    case pain = "pain"
    case prescription = "prescription"
    case mentalHealth = "mental_health"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "No urgent needs"
        case .illness: return "I'm feeling sick"
        case .injury: return "I have an injury"
        case .pain: return "I'm in pain"
        case .prescription: return "I need medication refill"
        case .mentalHealth: return "Mental health crisis"
        }
    }
}

enum ChronicCondition: String, CaseIterable, Codable, Identifiable {
    case none = "none"
    case diabetes = "diabetes"
    case heartDisease = "heart"
    case asthma = "asthma"
    case hypertension = "hypertension"
    case mentalHealth = "mental_health"
    case hiv = "hiv"
    case hepatitis = "hepatitis"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .diabetes: return "Diabetes"
        case .heartDisease: return "Heart Disease"
        case .asthma: return "Asthma/COPD"
        case .hypertension: return "High Blood Pressure"
        case .mentalHealth: return "Mental Health Condition"
        case .hiv: return "HIV/AIDS"
        case .hepatitis: return "Hepatitis"
        case .other: return "Other condition"
        }
    }
}

// MARK: - Employment Questions
enum EmploymentStatus: String, CaseIterable, Codable, Identifiable {
    case employed = "employed"
    case partTime = "part_time"
    case unemployedLooking = "unemployed_looking"
    case unemployedNotLooking = "unemployed_not_looking"
    case disabled = "disabled"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .employed: return "Employed Full-Time"
        case .partTime: return "Employed Part-Time"
        case .unemployedLooking: return "Unemployed, Looking for Work"
        case .unemployedNotLooking: return "Unemployed, Not Currently Looking"
        case .disabled: return "Unable to Work (Disability)"
        }
    }
}

enum WorkType: String, CaseIterable, Codable, Identifiable {
    case anyWork = "any"
    case laborConstruction = "labor"
    case retail = "retail"
    case foodService = "food"
    case warehouse = "warehouse"
    case healthcare = "healthcare"
    case office = "office"
    case driving = "driving"
    case tech = "tech"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .anyWork: return "Any work available"
        case .laborConstruction: return "Labor / Construction"
        case .retail: return "Retail / Customer Service"
        case .foodService: return "Food Service / Restaurant"
        case .warehouse: return "Warehouse / Logistics"
        case .healthcare: return "Healthcare / Caregiving"
        case .office: return "Office / Administrative"
        case .driving: return "Driving / Delivery"
        case .tech: return "Tech / Computer Work"
        }
    }
}

enum JobBarrier: String, CaseIterable, Codable, Identifiable {
    case transportation = "transportation"
    case childcare = "childcare"
    case noID = "no_id"
    case criminalRecord = "criminal_record"
    case noAddress = "no_address"
    case noPhone = "no_phone"
    case healthIssues = "health"
    case noExperience = "no_experience"
    case language = "language"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .transportation: return "No reliable transportation"
        case .childcare: return "Need childcare"
        case .noID: return "No ID documents"
        case .criminalRecord: return "Criminal record"
        case .noAddress: return "No stable address"
        case .noPhone: return "No phone"
        case .healthIssues: return "Health issues"
        case .noExperience: return "No work experience"
        case .language: return "Language barrier"
        }
    }
}

// MARK: - Housing Questions
enum CurrentHousingSituation: String, CaseIterable, Codable, Identifiable {
    case street = "street"
    case shelter = "shelter"
    case vehicle = "vehicle"
    case temporaryWithOthers = "temp_others"
    case motel = "motel"
    case transitionHousing = "transition"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .street: return "Outdoors / Street"
        case .shelter: return "Shelter"
        case .vehicle: return "Vehicle"
        case .temporaryWithOthers: return "Staying with friends/family"
        case .motel: return "Motel / Hotel"
        case .transitionHousing: return "Transitional housing"
        }
    }

    var icon: String {
        switch self {
        case .street: return "figure.walk"
        case .shelter: return "building.2"
        case .vehicle: return "car"
        case .temporaryWithOthers: return "person.2"
        case .motel: return "bed.double"
        case .transitionHousing: return "house"
        }
    }
}

enum HousingBarrier: String, CaseIterable, Codable, Identifiable {
    case noIncome = "no_income"
    case lowIncome = "low_income"
    case evictionHistory = "eviction"
    case criminalRecord = "criminal"
    case noID = "no_id"
    case badCredit = "credit"
    case noReferences = "no_references"
    case pets = "pets"
    case familySize = "family_size"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .noIncome: return "No current income"
        case .lowIncome: return "Income too low"
        case .evictionHistory: return "Past eviction"
        case .criminalRecord: return "Criminal record"
        case .noID: return "No ID documents"
        case .badCredit: return "Poor credit history"
        case .noReferences: return "No rental references"
        case .pets: return "Have pets"
        case .familySize: return "Large family size"
        }
    }
}

enum IDDocumentStatus: String, CaseIterable, Codable, Identifiable {
    case haveAll = "have_all"
    case someDocuments = "some"
    case noDocuments = "none"
    case needHelp = "need_help"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .haveAll: return "I have all my IDs (license, SSN, birth cert)"
        case .someDocuments: return "I have some documents"
        case .noDocuments: return "I don't have ID documents"
        case .needHelp: return "I need help getting documents"
        }
    }
}

// MARK: - Family Status
enum FamilyStatus: String, CaseIterable, Codable, Identifiable {
    case single = "single"
    case couple = "couple"
    case familyWithChildren = "family_children"
    case singleParent = "single_parent"
    case unaccompaniedYouth = "youth"
    case veteran = "veteran"
    case senior = "senior"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .single: return "Single adult"
        case .couple: return "Couple without children"
        case .familyWithChildren: return "Family with children"
        case .singleParent: return "Single parent with children"
        case .unaccompaniedYouth: return "Youth (under 25)"
        case .veteran: return "Veteran"
        case .senior: return "Senior (60+)"
        }
    }
}

// MARK: - Language (simplified for homeless services)
enum PreferredLanguage: String, CaseIterable, Codable, Identifiable {
    case english = "en"
    case spanish = "es"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .spanish: return "Español"
        case .other: return "Other"
        }
    }
}

// MARK: - User Profile
class UserProfile: ObservableObject, Codable {
    // Basic Info
    @Published var name: String = ""
    @Published var preferredLanguage: PreferredLanguage = .english
    @Published var zipCode: String = ""

    // Selected Service Areas
    @Published var selectedServiceAreas: Set<ServiceArea> = []

    // Healthcare Questions (6)
    @Published var insuranceStatus: InsuranceStatus = .unsure
    @Published var urgentHealthNeeds: UrgentHealthNeed = .none
    @Published var chronicConditions: [ChronicCondition] = []
    @Published var needsMentalHealthSupport: Bool = false
    @Published var needsDentalCare: Bool = false
    @Published var needsMedications: Bool = false

    // Employment Questions (6)
    @Published var employmentStatus: EmploymentStatus = .unemployedLooking
    @Published var preferredWorkTypes: [WorkType] = []
    @Published var hasResume: Bool = false
    @Published var hasWorkExperience: Bool = false
    @Published var needsJobTraining: Bool = false
    @Published var jobBarriers: [JobBarrier] = []

    // Housing Questions (6)
    @Published var currentHousingSituation: CurrentHousingSituation = .shelter
    @Published var isOnHousingWaitlist: Bool = false
    @Published var hasIncomeForRent: Bool = false
    @Published var housingBarriers: [HousingBarrier] = []
    @Published var idDocumentStatus: IDDocumentStatus = .someDocuments
    @Published var familyStatus: FamilyStatus = .single

    // Additional common info
    @Published var hasTransportation: Bool = false
    @Published var hasPhone: Bool = true
    @Published var needsInterpreter: Bool = false

    enum CodingKeys: String, CodingKey {
        case name, preferredLanguage, zipCode, selectedServiceAreas
        case insuranceStatus, urgentHealthNeeds, chronicConditions
        case needsMentalHealthSupport, needsDentalCare, needsMedications
        case employmentStatus, preferredWorkTypes, hasResume
        case hasWorkExperience, needsJobTraining, jobBarriers
        case currentHousingSituation, isOnHousingWaitlist, hasIncomeForRent
        case housingBarriers, idDocumentStatus, familyStatus
        case hasTransportation, hasPhone, needsInterpreter
    }

    init() {}

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        preferredLanguage = try container.decodeIfPresent(PreferredLanguage.self, forKey: .preferredLanguage) ?? .english
        zipCode = try container.decodeIfPresent(String.self, forKey: .zipCode) ?? ""
        selectedServiceAreas = try container.decodeIfPresent(Set<ServiceArea>.self, forKey: .selectedServiceAreas) ?? []
        insuranceStatus = try container.decodeIfPresent(InsuranceStatus.self, forKey: .insuranceStatus) ?? .unsure
        urgentHealthNeeds = try container.decodeIfPresent(UrgentHealthNeed.self, forKey: .urgentHealthNeeds) ?? .none
        chronicConditions = try container.decodeIfPresent([ChronicCondition].self, forKey: .chronicConditions) ?? []
        needsMentalHealthSupport = try container.decodeIfPresent(Bool.self, forKey: .needsMentalHealthSupport) ?? false
        needsDentalCare = try container.decodeIfPresent(Bool.self, forKey: .needsDentalCare) ?? false
        needsMedications = try container.decodeIfPresent(Bool.self, forKey: .needsMedications) ?? false
        employmentStatus = try container.decodeIfPresent(EmploymentStatus.self, forKey: .employmentStatus) ?? .unemployedLooking
        preferredWorkTypes = try container.decodeIfPresent([WorkType].self, forKey: .preferredWorkTypes) ?? []
        hasResume = try container.decodeIfPresent(Bool.self, forKey: .hasResume) ?? false
        hasWorkExperience = try container.decodeIfPresent(Bool.self, forKey: .hasWorkExperience) ?? false
        needsJobTraining = try container.decodeIfPresent(Bool.self, forKey: .needsJobTraining) ?? false
        jobBarriers = try container.decodeIfPresent([JobBarrier].self, forKey: .jobBarriers) ?? []
        currentHousingSituation = try container.decodeIfPresent(CurrentHousingSituation.self, forKey: .currentHousingSituation) ?? .shelter
        isOnHousingWaitlist = try container.decodeIfPresent(Bool.self, forKey: .isOnHousingWaitlist) ?? false
        hasIncomeForRent = try container.decodeIfPresent(Bool.self, forKey: .hasIncomeForRent) ?? false
        housingBarriers = try container.decodeIfPresent([HousingBarrier].self, forKey: .housingBarriers) ?? []
        idDocumentStatus = try container.decodeIfPresent(IDDocumentStatus.self, forKey: .idDocumentStatus) ?? .someDocuments
        familyStatus = try container.decodeIfPresent(FamilyStatus.self, forKey: .familyStatus) ?? .single
        hasTransportation = try container.decodeIfPresent(Bool.self, forKey: .hasTransportation) ?? false
        hasPhone = try container.decodeIfPresent(Bool.self, forKey: .hasPhone) ?? true
        needsInterpreter = try container.decodeIfPresent(Bool.self, forKey: .needsInterpreter) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(preferredLanguage, forKey: .preferredLanguage)
        try container.encode(zipCode, forKey: .zipCode)
        try container.encode(selectedServiceAreas, forKey: .selectedServiceAreas)
        try container.encode(insuranceStatus, forKey: .insuranceStatus)
        try container.encode(urgentHealthNeeds, forKey: .urgentHealthNeeds)
        try container.encode(chronicConditions, forKey: .chronicConditions)
        try container.encode(needsMentalHealthSupport, forKey: .needsMentalHealthSupport)
        try container.encode(needsDentalCare, forKey: .needsDentalCare)
        try container.encode(needsMedications, forKey: .needsMedications)
        try container.encode(employmentStatus, forKey: .employmentStatus)
        try container.encode(preferredWorkTypes, forKey: .preferredWorkTypes)
        try container.encode(hasResume, forKey: .hasResume)
        try container.encode(hasWorkExperience, forKey: .hasWorkExperience)
        try container.encode(needsJobTraining, forKey: .needsJobTraining)
        try container.encode(jobBarriers, forKey: .jobBarriers)
        try container.encode(currentHousingSituation, forKey: .currentHousingSituation)
        try container.encode(isOnHousingWaitlist, forKey: .isOnHousingWaitlist)
        try container.encode(hasIncomeForRent, forKey: .hasIncomeForRent)
        try container.encode(housingBarriers, forKey: .housingBarriers)
        try container.encode(idDocumentStatus, forKey: .idDocumentStatus)
        try container.encode(familyStatus, forKey: .familyStatus)
        try container.encode(hasTransportation, forKey: .hasTransportation)
        try container.encode(hasPhone, forKey: .hasPhone)
        try container.encode(needsInterpreter, forKey: .needsInterpreter)
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

    // MARK: - Service-specific Helpers

    var needsHealthcare: Bool {
        selectedServiceAreas.contains(.healthcare)
    }

    var needsEmployment: Bool {
        selectedServiceAreas.contains(.employment)
    }

    var needsHousing: Bool {
        selectedServiceAreas.contains(.housing)
    }

    var hasUrgentHealthNeeds: Bool {
        urgentHealthNeeds != .none
    }

    var isVeteran: Bool {
        familyStatus == .veteran
    }

    var hasChildren: Bool {
        familyStatus == .familyWithChildren || familyStatus == .singleParent
    }

    var isYouth: Bool {
        familyStatus == .unaccompaniedYouth
    }

    var isSenior: Bool {
        familyStatus == .senior
    }

    var needsIDHelp: Bool {
        idDocumentStatus == .noDocuments || idDocumentStatus == .needHelp
    }

    // Priority services based on profile
    var priorityHealthcareServices: [String] {
        var services: [String] = []
        if insuranceStatus == .none || insuranceStatus == .unsure {
            services.append("Free Clinic")
            services.append("Medicaid Enrollment")
        }
        if needsMentalHealthSupport {
            services.append("Mental Health Services")
        }
        if needsDentalCare {
            services.append("Dental Clinic")
        }
        if needsMedications {
            services.append("Prescription Assistance")
        }
        if urgentHealthNeeds != .none {
            services.insert("Urgent Care", at: 0)
        }
        return services
    }

    var priorityEmploymentServices: [String] {
        var services: [String] = []
        if !hasResume {
            services.append("Resume Help")
        }
        if needsJobTraining {
            services.append("Job Training Programs")
        }
        if jobBarriers.contains(.transportation) {
            services.append("Transportation Assistance")
        }
        if jobBarriers.contains(.noID) {
            services.append("ID Recovery Services")
        }
        if jobBarriers.contains(.criminalRecord) {
            services.append("Reentry Employment Programs")
        }
        services.append("Job Placement Services")
        return services
    }

    var priorityHousingServices: [String] {
        var services: [String] = []
        if currentHousingSituation == .street || currentHousingSituation == .vehicle {
            services.append("Emergency Shelter")
        }
        if !isOnHousingWaitlist {
            services.append("Housing Waitlist Signup")
        }
        if isVeteran {
            services.append("VA Housing Programs")
        }
        if hasChildren {
            services.append("Family Shelters")
        }
        if needsIDHelp {
            services.append("ID Recovery Services")
        }
        services.append("Rental Assistance Programs")
        return services
    }
}
