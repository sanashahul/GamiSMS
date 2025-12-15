import Foundation
import CoreLocation
import MapKit

// MARK: - Resource Category
enum ResourceCategory: String, CaseIterable, Codable, Identifiable {
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
}

// MARK: - Resource Type
enum ResourceType: String, CaseIterable, Codable, Identifiable {
    // Healthcare
    case clinic = "clinic"
    case hospital = "hospital"
    case mentalHealth = "mental_health"
    case dental = "dental"
    case pharmacy = "pharmacy"

    // Employment
    case workforceCenter = "workforce_center"
    case jobTraining = "job_training"
    case dayLabor = "day_labor"
    case careerCenter = "career_center"
    case tempAgency = "temp_agency"

    // Housing
    case shelter = "shelter"
    case housingAuthority = "housing_authority"
    case transitionalHousing = "transitional_housing"
    case socialServices = "social_services"
    case foodBank = "food_bank"

    var id: String { rawValue }

    var category: ResourceCategory {
        switch self {
        case .clinic, .hospital, .mentalHealth, .dental, .pharmacy:
            return .healthcare
        case .workforceCenter, .jobTraining, .dayLabor, .careerCenter, .tempAgency:
            return .employment
        case .shelter, .housingAuthority, .transitionalHousing, .socialServices, .foodBank:
            return .housing
        }
    }

    var displayName: String {
        switch self {
        case .clinic: return "Health Clinic"
        case .hospital: return "Hospital"
        case .mentalHealth: return "Mental Health"
        case .dental: return "Dental Clinic"
        case .pharmacy: return "Pharmacy"
        case .workforceCenter: return "Workforce Center"
        case .jobTraining: return "Job Training"
        case .dayLabor: return "Day Labor Center"
        case .careerCenter: return "Career Center"
        case .tempAgency: return "Temp Agency"
        case .shelter: return "Shelter"
        case .housingAuthority: return "Housing Authority"
        case .transitionalHousing: return "Transitional Housing"
        case .socialServices: return "Social Services"
        case .foodBank: return "Food Bank"
        }
    }

    var icon: String {
        switch self {
        case .clinic: return "cross.case.fill"
        case .hospital: return "building.2.fill"
        case .mentalHealth: return "brain.head.profile"
        case .dental: return "mouth.fill"
        case .pharmacy: return "pills.fill"
        case .workforceCenter: return "building.columns.fill"
        case .jobTraining: return "graduationcap.fill"
        case .dayLabor: return "hammer.fill"
        case .careerCenter: return "briefcase.fill"
        case .tempAgency: return "clock.badge.checkmark.fill"
        case .shelter: return "house.lodge.fill"
        case .housingAuthority: return "building.2.crop.circle.fill"
        case .transitionalHousing: return "arrow.right.circle.fill"
        case .socialServices: return "person.2.fill"
        case .foodBank: return "basket.fill"
        }
    }

    var color: String {
        switch self {
        case .clinic: return "red"
        case .hospital: return "red"
        case .mentalHealth: return "purple"
        case .dental: return "cyan"
        case .pharmacy: return "green"
        case .workforceCenter: return "blue"
        case .jobTraining: return "purple"
        case .dayLabor: return "orange"
        case .careerCenter: return "blue"
        case .tempAgency: return "teal"
        case .shelter: return "green"
        case .housingAuthority: return "blue"
        case .transitionalHousing: return "teal"
        case .socialServices: return "orange"
        case .foodBank: return "yellow"
        }
    }
}

// MARK: - Resource
struct Resource: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: ResourceType
    var address: String
    var city: String
    var state: String
    var zipCode: String
    var phoneNumber: String
    var website: String?
    var latitude: Double
    var longitude: Double
    var description: String
    var services: [String]
    var requirements: [String]
    var hours: String
    var walkInsWelcome: Bool
    var distance: Double?

    var fullAddress: String {
        "\(address), \(city), \(state) \(zipCode)"
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var category: ResourceCategory {
        type.category
    }
}

// MARK: - Resource Service
class ResourceService: ObservableObject {
    static let shared = ResourceService()

    @Published var resources: [Resource] = []
    @Published var isLoading = false
    @Published var nearbyResources: [Resource] = []

    init() {
        loadAllResources()
    }

    private func loadAllResources() {
        resources = employmentResources + housingResources
    }

    // Get resources by category near a location
    func getResources(category: ResourceCategory, near location: CLLocation, radius: Double = 50.0) -> [Resource] {
        return resources
            .filter { $0.category == category }
            .map { resource in
                var updated = resource
                let resourceLocation = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
                updated.distance = location.distance(from: resourceLocation) / 1609.34 // Convert to miles
                return updated
            }
            .filter { ($0.distance ?? 0) <= radius }
            .sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    // Get resources by type near a location
    func getResources(type: ResourceType, near location: CLLocation, radius: Double = 50.0) -> [Resource] {
        return resources
            .filter { $0.type == type }
            .map { resource in
                var updated = resource
                let resourceLocation = CLLocation(latitude: resource.latitude, longitude: resource.longitude)
                updated.distance = location.distance(from: resourceLocation) / 1609.34
                return updated
            }
            .filter { ($0.distance ?? 0) <= radius }
            .sorted { ($0.distance ?? 0) < ($1.distance ?? 0) }
    }

    // Search nearby using MapKit
    func searchNearby(query: String, near location: CLLocation, completion: @escaping ([Resource]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 50000,
            longitudinalMeters: 50000
        )

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                completion([])
                return
            }

            let resources = response.mapItems.compactMap { item -> Resource? in
                guard let name = item.name else { return nil }

                let resourceLocation = CLLocation(
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude
                )
                let distance = location.distance(from: resourceLocation) / 1609.34

                return Resource(
                    id: UUID(),
                    name: name,
                    type: .socialServices,
                    address: item.placemark.thoroughfare ?? "",
                    city: item.placemark.locality ?? "",
                    state: item.placemark.administrativeArea ?? "",
                    zipCode: item.placemark.postalCode ?? "",
                    phoneNumber: item.phoneNumber ?? "Call for info",
                    website: item.url?.absoluteString,
                    latitude: item.placemark.coordinate.latitude,
                    longitude: item.placemark.coordinate.longitude,
                    description: "Found via Apple Maps. Please call to confirm services.",
                    services: [],
                    requirements: [],
                    hours: "Call for hours",
                    walkInsWelcome: false,
                    distance: distance
                )
            }

            completion(resources.sorted { ($0.distance ?? 0) < ($1.distance ?? 0) })
        }
    }

    // MARK: - Employment Resources Database
    let employmentResources: [Resource] = [
        // California - Los Angeles
        Resource(
            id: UUID(),
            name: "DPSS GAIN Services - Southeast LA",
            type: .workforceCenter,
            address: "2155 E 103rd St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90002",
            phoneNumber: "(323) 586-6700",
            website: "https://dpss.lacounty.gov/en/jobs/gain.html",
            latitude: 33.9425,
            longitude: -118.2399,
            description: "Greater Avenues for Independence (GAIN) provides job training, placement services, and support for CalWORKs participants. Free services including resume help, job search, and transportation assistance.",
            services: ["Job placement", "Resume help", "Interview prep", "Transportation assistance", "Childcare assistance", "Work clothing"],
            requirements: ["CalWORKs eligible or low-income"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Goodwill Southern California - Workforce Development",
            type: .jobTraining,
            address: "342 N San Fernando Rd",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90031",
            phoneNumber: "(323) 223-1211",
            website: "https://www.goodwillsocal.org",
            latitude: 34.0734,
            longitude: -118.2137,
            description: "Goodwill offers free job training programs, career counseling, and employment services. Programs include computer training, customer service, warehouse operations, and more.",
            services: ["Computer training", "Job placement", "Career counseling", "Interview coaching", "GED assistance"],
            requirements: ["Open to all job seekers"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "WorkSource California - Downtown LA",
            type: .workforceCenter,
            address: "1055 Wilshire Blvd",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90017",
            phoneNumber: "(213) 744-7300",
            website: "https://www.americasjobcenter.org",
            latitude: 34.0520,
            longitude: -118.2628,
            description: "America's Job Center provides free employment services including job listings, resume assistance, career counseling, and training referrals. Computer access available.",
            services: ["Job listings", "Resume writing", "Career counseling", "Training referrals", "Computer access", "Workshops"],
            requirements: ["Open to all"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "National Day Laborer Organizing Network",
            type: .dayLabor,
            address: "675 S Park View St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90057",
            phoneNumber: "(213) 380-2785",
            website: "https://www.ndlon.org",
            latitude: 34.0593,
            longitude: -118.2783,
            description: "NDLON supports day laborers with worker rights education, wage theft assistance, and connections to fair employers. Safe alternative to street corners.",
            services: ["Day labor jobs", "Worker rights education", "Wage theft help", "English classes", "Skills training"],
            requirements: ["Open to all workers"],
            hours: "Mon-Sat 6am-12pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Chrysalis - Downtown",
            type: .careerCenter,
            address: "522 S Main St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90013",
            phoneNumber: "(213) 806-6300",
            website: "https://www.changelives.org",
            latitude: 34.0442,
            longitude: -118.2487,
            description: "Chrysalis helps homeless and low-income individuals find and keep employment. Services include job readiness workshops, transitional jobs, and ongoing support.",
            services: ["Job readiness", "Transitional employment", "Resume help", "Work clothing", "Phone/voicemail", "Ongoing support"],
            requirements: ["Homeless or at-risk of homelessness"],
            hours: "Mon-Fri 8am-4pm",
            walkInsWelcome: true,
            distance: nil
        ),

        // California - San Francisco Bay Area
        Resource(
            id: UUID(),
            name: "SFDHR - One Stop Career Center",
            type: .workforceCenter,
            address: "3120 Mission St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94110",
            phoneNumber: "(415) 401-4800",
            website: "https://oewd.org/job-seekers",
            latitude: 37.7472,
            longitude: -122.4185,
            description: "San Francisco's One Stop Career Center provides comprehensive employment services including job listings, training, and supportive services for all job seekers.",
            services: ["Job placement", "Career counseling", "Training", "Supportive services", "Youth programs"],
            requirements: ["San Francisco residents prioritized"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Rubicon Programs - Richmond",
            type: .jobTraining,
            address: "2500 Bissell Ave",
            city: "Richmond",
            state: "CA",
            zipCode: "94804",
            phoneNumber: "(510) 412-1725",
            website: "https://www.rubiconprograms.org",
            latitude: 37.9274,
            longitude: -122.3589,
            description: "Rubicon helps formerly incarcerated and low-income individuals build careers through job training, mental health services, and permanent employment.",
            services: ["Job training", "Career counseling", "Mental health support", "Legal aid referrals", "Housing support"],
            requirements: ["Contra Costa County residents"],
            hours: "Mon-Fri 9am-5pm",
            walkInsWelcome: false,
            distance: nil
        ),

        // Illinois - Chicago
        Resource(
            id: UUID(),
            name: "Chicago Cook Workforce Partnership",
            type: .workforceCenter,
            address: "69 W Washington St",
            city: "Chicago",
            state: "IL",
            zipCode: "60602",
            phoneNumber: "(312) 603-0200",
            website: "https://www.chicookworks.org",
            latitude: 41.8832,
            longitude: -87.6314,
            description: "The city's workforce development network offers free job search assistance, training programs, and support services for job seekers throughout Chicago and Cook County.",
            services: ["Job search help", "Training programs", "Career coaching", "Youth employment", "Veteran services"],
            requirements: ["Chicago/Cook County residents"],
            hours: "Mon-Fri 8:30am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Cara Chicago",
            type: .careerCenter,
            address: "237 S Desplaines St",
            city: "Chicago",
            state: "IL",
            zipCode: "60661",
            phoneNumber: "(312) 798-3300",
            website: "https://www.carachicago.org",
            latitude: 41.8778,
            longitude: -87.6440,
            description: "Cara provides job training and placement for people affected by poverty. Their signature Cleanslate transitional jobs program helps build work history.",
            services: ["Job training", "Transitional jobs", "Life skills", "Career placement", "Ongoing support"],
            requirements: ["Referral from partner agencies"],
            hours: "Mon-Fri 8am-4pm",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Albany Park Day Labor Center",
            type: .dayLabor,
            address: "4751 N Kedzie Ave",
            city: "Chicago",
            state: "IL",
            zipCode: "60625",
            phoneNumber: "(773) 509-1980",
            website: nil,
            latitude: 41.9663,
            longitude: -87.7084,
            description: "Worker center connecting day laborers with fair employers. Provides a safe alternative to street corners with worker protections and fair wages.",
            services: ["Day labor matching", "Worker rights", "ESL classes", "Skills training"],
            requirements: ["Open to all workers"],
            hours: "Mon-Sat 6am-11am",
            walkInsWelcome: true,
            distance: nil
        ),

        // New York
        Resource(
            id: UUID(),
            name: "NYC Workforce1 Career Center - Upper Manhattan",
            type: .workforceCenter,
            address: "215 W 125th St",
            city: "New York",
            state: "NY",
            zipCode: "10027",
            phoneNumber: "(718) 960-8200",
            website: "https://www.nyc.gov/workforce1",
            latitude: 40.8094,
            longitude: -73.9505,
            description: "Workforce1 offers free job search assistance, career coaching, and connections to training programs and employers across New York City.",
            services: ["Job listings", "Resume help", "Interview prep", "Career coaching", "Training referrals"],
            requirements: ["NYC residents"],
            hours: "Mon-Fri 8:30am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "The Doe Fund - Ready, Willing & Able",
            type: .careerCenter,
            address: "232 E 84th St",
            city: "New York",
            state: "NY",
            zipCode: "10028",
            phoneNumber: "(212) 628-5207",
            website: "https://www.doe.org",
            latitude: 40.7775,
            longitude: -73.9543,
            description: "The Doe Fund helps homeless and formerly incarcerated individuals achieve independence through paid transitional work, housing, and career training.",
            services: ["Paid transitional work", "Housing", "Career training", "Job placement", "Support services"],
            requirements: ["Homeless or formerly incarcerated"],
            hours: "24/7 program",
            walkInsWelcome: false,
            distance: nil
        ),

        // Texas - Houston
        Resource(
            id: UUID(),
            name: "Workforce Solutions - Southeast",
            type: .workforceCenter,
            address: "8876 Gulf Freeway",
            city: "Houston",
            state: "TX",
            zipCode: "77017",
            phoneNumber: "(713) 645-2201",
            website: "https://www.wrksolutions.com",
            latitude: 29.6644,
            longitude: -95.2932,
            description: "Workforce Solutions provides free employment services including job matching, skills training, and support services for Houston-area job seekers.",
            services: ["Job matching", "Skills training", "Career counseling", "Childcare assistance", "Support services"],
            requirements: ["Gulf Coast region residents"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Career and Recovery Resources",
            type: .careerCenter,
            address: "2525 San Jacinto St",
            city: "Houston",
            state: "TX",
            zipCode: "77002",
            phoneNumber: "(713) 754-7000",
            website: "https://www.careerandrecovery.org",
            latitude: 29.7531,
            longitude: -95.3684,
            description: "Serves homeless individuals and those in recovery with comprehensive services including employment assistance, housing support, and case management.",
            services: ["Job readiness", "Employment placement", "Housing assistance", "Recovery support", "Case management"],
            requirements: ["Homeless or in recovery"],
            hours: "Mon-Fri 7am-4pm",
            walkInsWelcome: true,
            distance: nil
        )
    ]

    // MARK: - Housing Resources Database
    let housingResources: [Resource] = [
        // California - Los Angeles
        Resource(
            id: UUID(),
            name: "LA Family Housing",
            type: .shelter,
            address: "7843 Lankershim Blvd",
            city: "North Hollywood",
            state: "CA",
            zipCode: "91605",
            phoneNumber: "(818) 982-4091",
            website: "https://www.lafh.org",
            latitude: 34.1953,
            longitude: -118.3871,
            description: "LA Family Housing provides emergency shelter, interim housing, and permanent supportive housing. They serve individuals and families experiencing homelessness.",
            services: ["Emergency shelter", "Interim housing", "Permanent housing", "Case management", "Employment services"],
            requirements: ["Homeless individuals and families"],
            hours: "24/7 shelter services",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Union Rescue Mission",
            type: .shelter,
            address: "545 S San Pedro St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90013",
            phoneNumber: "(213) 347-6300",
            website: "https://www.urm.org",
            latitude: 34.0441,
            longitude: -118.2436,
            description: "Largest mission in the United States serving homeless men, women, and children on Skid Row. Provides meals, shelter, and comprehensive programs.",
            services: ["Emergency shelter", "Meals", "Medical care", "Addiction recovery", "Job training", "Childcare"],
            requirements: ["Open to all homeless individuals"],
            hours: "24/7",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Downtown Women's Center",
            type: .shelter,
            address: "442 S San Pedro St",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90013",
            phoneNumber: "(213) 680-0600",
            website: "https://www.downtownwomenscenter.org",
            latitude: 34.0449,
            longitude: -118.2438,
            description: "Provides permanent supportive housing, meals, health care, and wellness programs exclusively for women experiencing homelessness.",
            services: ["Women's shelter", "Day services", "Meals", "Health care", "Housing placement"],
            requirements: ["Women experiencing homelessness"],
            hours: "Day center: 6am-6pm",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "LA County Housing Authority",
            type: .housingAuthority,
            address: "700 W Main St",
            city: "Alhambra",
            state: "CA",
            zipCode: "91801",
            phoneNumber: "(626) 262-4510",
            website: "https://www.lacda.org",
            latitude: 34.0889,
            longitude: -118.1379,
            description: "Administers Section 8 vouchers and public housing programs for LA County. Apply for housing assistance programs.",
            services: ["Section 8 vouchers", "Public housing", "Housing counseling", "Emergency housing vouchers"],
            requirements: ["Income eligible LA County residents"],
            hours: "Mon-Thu 7am-5:30pm",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "PATH (People Assisting The Homeless)",
            type: .transitionalHousing,
            address: "340 N Madison Ave",
            city: "Los Angeles",
            state: "CA",
            zipCode: "90004",
            phoneNumber: "(323) 644-2200",
            website: "https://www.epath.org",
            latitude: 34.0775,
            longitude: -118.2925,
            description: "PATH provides housing and supportive services to help people experiencing homelessness move into stable housing.",
            services: ["Rapid rehousing", "Permanent housing", "Case management", "Employment help", "Mental health"],
            requirements: ["Homeless individuals in LA"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: true,
            distance: nil
        ),

        // California - San Francisco
        Resource(
            id: UUID(),
            name: "SF Navigation Center - Division Circle",
            type: .shelter,
            address: "224 S Van Ness Ave",
            city: "San Francisco",
            state: "CA",
            zipCode: "94103",
            phoneNumber: "(415) 487-3300",
            website: "https://hsh.sfgov.org",
            latitude: 37.7718,
            longitude: -122.4188,
            description: "Low-barrier shelter where people can bring partners, pets, and possessions. Provides intensive case management and housing navigation.",
            services: ["Low-barrier shelter", "Case management", "Housing navigation", "Pet-friendly", "Couples accepted"],
            requirements: ["SF homeless individuals"],
            hours: "24/7",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Glide Memorial - Crisis Services",
            type: .socialServices,
            address: "330 Ellis St",
            city: "San Francisco",
            state: "CA",
            zipCode: "94102",
            phoneNumber: "(415) 674-6000",
            website: "https://www.glide.org",
            latitude: 37.7856,
            longitude: -122.4115,
            description: "Glide provides meals, housing assistance, health care, and crisis services to San Francisco's homeless and low-income residents.",
            services: ["Daily meals", "Housing assistance", "Health care", "Mental health", "Legal aid"],
            requirements: ["Open to all in need"],
            hours: "Meals daily, services Mon-Fri",
            walkInsWelcome: true,
            distance: nil
        ),

        // Illinois - Chicago
        Resource(
            id: UUID(),
            name: "Pacific Garden Mission",
            type: .shelter,
            address: "1458 S Canal St",
            city: "Chicago",
            state: "IL",
            zipCode: "60607",
            phoneNumber: "(312) 492-9410",
            website: "https://www.pgm.org",
            latitude: 41.8636,
            longitude: -87.6394,
            description: "Chicago's oldest continuously operating homeless shelter. Provides emergency shelter, meals, and programs for men, women, and children.",
            services: ["Emergency shelter", "Meals", "Bible program", "Recovery program", "Job training"],
            requirements: ["Open to all homeless"],
            hours: "24/7",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Chicago Housing Authority",
            type: .housingAuthority,
            address: "60 E Van Buren St",
            city: "Chicago",
            state: "IL",
            zipCode: "60605",
            phoneNumber: "(312) 742-8500",
            website: "https://www.thecha.org",
            latitude: 41.8768,
            longitude: -87.6252,
            description: "CHA administers public housing and Section 8 vouchers for Chicago residents. Apply for housing waitlist.",
            services: ["Public housing", "Section 8 vouchers", "Family housing", "Senior housing"],
            requirements: ["Income eligible Chicago residents"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "A Safe Haven",
            type: .transitionalHousing,
            address: "2750 W Roosevelt Rd",
            city: "Chicago",
            state: "IL",
            zipCode: "60608",
            phoneNumber: "(773) 435-8300",
            website: "https://www.asafehaven.org",
            latitude: 41.8661,
            longitude: -87.6948,
            description: "A Safe Haven provides transitional housing with support services for homeless individuals including veterans, families, and those in recovery.",
            services: ["Transitional housing", "Case management", "Job training", "Recovery programs", "Veteran services"],
            requirements: ["Homeless individuals willing to participate in programs"],
            hours: "24/7 residential",
            walkInsWelcome: false,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Greater Chicago Food Depository",
            type: .foodBank,
            address: "4100 W Ann Lurie Pl",
            city: "Chicago",
            state: "IL",
            zipCode: "60632",
            phoneNumber: "(773) 247-3663",
            website: "https://www.chicagosfoodbank.org",
            latitude: 41.8175,
            longitude: -87.7256,
            description: "Chicago's food bank network. Call 211 or use website to find nearest food pantry location.",
            services: ["Food distribution", "Pantry network", "Produce mobile", "Benefits enrollment"],
            requirements: ["Open to anyone in need"],
            hours: "Varies by location",
            walkInsWelcome: true,
            distance: nil
        ),

        // New York
        Resource(
            id: UUID(),
            name: "NYC Department of Homeless Services",
            type: .socialServices,
            address: "33 Beaver St",
            city: "New York",
            state: "NY",
            zipCode: "10004",
            phoneNumber: "311",
            website: "https://www1.nyc.gov/site/dhs",
            latitude: 40.7053,
            longitude: -74.0118,
            description: "NYC's homeless services agency. Call 311 for shelter intake and services. Operates emergency shelters throughout the city.",
            services: ["Emergency shelter", "Assessment", "Street outreach", "Drop-in centers"],
            requirements: ["NYC homeless residents"],
            hours: "24/7 hotline: 311",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "The Bowery Mission",
            type: .shelter,
            address: "227 Bowery",
            city: "New York",
            state: "NY",
            zipCode: "10002",
            phoneNumber: "(212) 674-3456",
            website: "https://www.bowery.org",
            latitude: 40.7211,
            longitude: -73.9931,
            description: "Historic NYC mission providing meals, shelter, and comprehensive programs for homeless men, women, and children since 1879.",
            services: ["Emergency shelter", "Meals", "Residential programs", "Job training", "Addiction recovery"],
            requirements: ["Open to homeless individuals"],
            hours: "Meals daily, shelter by intake",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "NYCHA - Housing Authority",
            type: .housingAuthority,
            address: "250 Broadway",
            city: "New York",
            state: "NY",
            zipCode: "10007",
            phoneNumber: "(718) 707-7771",
            website: "https://www.nyc.gov/nycha",
            latitude: 40.7127,
            longitude: -74.0059,
            description: "NYC Housing Authority manages public housing and Section 8 vouchers. Long waitlist - apply early.",
            services: ["Public housing", "Section 8", "Senior housing", "Accessible housing"],
            requirements: ["Income eligible NYC residents"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: false,
            distance: nil
        ),

        // Texas - Houston
        Resource(
            id: UUID(),
            name: "Star of Hope Mission",
            type: .shelter,
            address: "1811 Ruiz St",
            city: "Houston",
            state: "TX",
            zipCode: "77002",
            phoneNumber: "(713) 227-8900",
            website: "https://www.sohmission.org",
            latitude: 29.7598,
            longitude: -95.3554,
            description: "Houston's largest homeless shelter serving men, women, and families with emergency shelter and transitional programs.",
            services: ["Emergency shelter", "Meals", "Recovery program", "Job readiness", "Women & family shelter"],
            requirements: ["Open to homeless individuals"],
            hours: "24/7",
            walkInsWelcome: true,
            distance: nil
        ),
        Resource(
            id: UUID(),
            name: "Houston Housing Authority",
            type: .housingAuthority,
            address: "2640 Fountain View Dr",
            city: "Houston",
            state: "TX",
            zipCode: "77057",
            phoneNumber: "(713) 260-0500",
            website: "https://www.housingforhouston.com",
            latitude: 29.7410,
            longitude: -95.4674,
            description: "Administers public housing and voucher programs for Houston residents. Apply online for waitlist.",
            services: ["Public housing", "Section 8", "Project-based vouchers", "Mixed income housing"],
            requirements: ["Income eligible Houston residents"],
            hours: "Mon-Fri 8am-5pm",
            walkInsWelcome: false,
            distance: nil
        )
    ]
}
