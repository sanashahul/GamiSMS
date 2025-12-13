import Foundation

// MARK: - Appointment Status
enum AppointmentStatus: String, Codable {
    case scheduled = "scheduled"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"

    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "Missed"
        }
    }

    var color: String {
        switch self {
        case .scheduled: return "blue"
        case .confirmed: return "green"
        case .completed: return "gray"
        case .cancelled: return "red"
        case .noShow: return "orange"
        }
    }
}

// MARK: - Appointment Type
enum AppointmentType: String, CaseIterable, Codable, Identifiable {
    case newPatient = "new_patient"
    case followUp = "follow_up"
    case checkup = "checkup"
    case urgent = "urgent"
    case vaccination = "vaccination"
    case mentalHealth = "mental_health"
    case dental = "dental"
    case vision = "vision"
    case prenatal = "prenatal"
    case pediatric = "pediatric"
    case specialist = "specialist"
    case telehealth = "telehealth"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .newPatient: return "New Patient Visit"
        case .followUp: return "Follow-up Visit"
        case .checkup: return "Regular Check-up"
        case .urgent: return "Urgent Care"
        case .vaccination: return "Vaccination"
        case .mentalHealth: return "Mental Health"
        case .dental: return "Dental Appointment"
        case .vision: return "Eye Exam"
        case .prenatal: return "Prenatal Care"
        case .pediatric: return "Child's Appointment"
        case .specialist: return "Specialist Visit"
        case .telehealth: return "Telehealth / Video Call"
        }
    }

    var icon: String {
        switch self {
        case .newPatient: return "person.badge.plus"
        case .followUp: return "arrow.clockwise"
        case .checkup: return "stethoscope"
        case .urgent: return "staroflife"
        case .vaccination: return "syringe"
        case .mentalHealth: return "brain.head.profile"
        case .dental: return "mouth"
        case .vision: return "eye"
        case .prenatal: return "figure.and.child.holdinghands"
        case .pediatric: return "figure.2.and.child.holdinghands"
        case .specialist: return "person.badge.clock"
        case .telehealth: return "video"
        }
    }

    var estimatedDuration: Int { // in minutes
        switch self {
        case .newPatient: return 60
        case .followUp: return 30
        case .checkup: return 45
        case .urgent: return 45
        case .vaccination: return 15
        case .mentalHealth: return 60
        case .dental: return 45
        case .vision: return 30
        case .prenatal: return 30
        case .pediatric: return 45
        case .specialist: return 45
        case .telehealth: return 30
        }
    }
}

// MARK: - Appointment
struct Appointment: Identifiable, Codable {
    let id: UUID
    var clinicId: UUID
    var clinicName: String
    var clinicAddress: String
    var clinicPhone: String
    var appointmentType: AppointmentType
    var date: Date
    var time: String
    var status: AppointmentStatus
    var needsInterpreter: Bool
    var interpreterLanguage: PreferredLanguage?
    var needsTransportation: Bool
    var notes: String
    var reminderSet: Bool
    var createdAt: Date
    var updatedAt: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedTime: String {
        time
    }

    var isPast: Bool {
        date < Date()
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(date)
    }

    var isUpcoming: Bool {
        date >= Date() && status == .scheduled || status == .confirmed
    }

    init(
        id: UUID = UUID(),
        clinicId: UUID,
        clinicName: String,
        clinicAddress: String,
        clinicPhone: String,
        appointmentType: AppointmentType,
        date: Date,
        time: String,
        status: AppointmentStatus = .scheduled,
        needsInterpreter: Bool = false,
        interpreterLanguage: PreferredLanguage? = nil,
        needsTransportation: Bool = false,
        notes: String = "",
        reminderSet: Bool = true
    ) {
        self.id = id
        self.clinicId = clinicId
        self.clinicName = clinicName
        self.clinicAddress = clinicAddress
        self.clinicPhone = clinicPhone
        self.appointmentType = appointmentType
        self.date = date
        self.time = time
        self.status = status
        self.needsInterpreter = needsInterpreter
        self.interpreterLanguage = interpreterLanguage
        self.needsTransportation = needsTransportation
        self.notes = notes
        self.reminderSet = reminderSet
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // Sample appointments for development
    static let samples: [Appointment] = [
        Appointment(
            clinicId: UUID(),
            clinicName: "Community Care Health Center",
            clinicAddress: "123 Main Street, Chicago, IL",
            clinicPhone: "(312) 555-0100",
            appointmentType: .newPatient,
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            time: "10:00 AM",
            needsInterpreter: true,
            interpreterLanguage: .arabic
        ),
        Appointment(
            clinicId: UUID(),
            clinicName: "Refugee Wellness Center",
            clinicAddress: "789 Unity Boulevard, Chicago, IL",
            clinicPhone: "(312) 555-0300",
            appointmentType: .mentalHealth,
            date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            time: "2:30 PM",
            needsInterpreter: true,
            interpreterLanguage: .somali,
            notes: "First counseling session"
        )
    ]
}

// MARK: - Appointments Manager
class AppointmentsManager: ObservableObject {
    @Published var appointments: [Appointment] = []

    private let saveKey = "savedAppointments"

    init() {
        load()
    }

    var upcomingAppointments: [Appointment] {
        appointments
            .filter { $0.isUpcoming }
            .sorted { $0.date < $1.date }
    }

    var pastAppointments: [Appointment] {
        appointments
            .filter { $0.isPast || $0.status == .completed }
            .sorted { $0.date > $1.date }
    }

    var todayAppointments: [Appointment] {
        appointments.filter { $0.isToday && $0.isUpcoming }
    }

    func add(_ appointment: Appointment) {
        appointments.append(appointment)
        save()
    }

    func update(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            var updated = appointment
            updated.updatedAt = Date()
            appointments[index] = updated
            save()
        }
    }

    func cancel(_ appointment: Appointment) {
        if let index = appointments.firstIndex(where: { $0.id == appointment.id }) {
            var updated = appointment
            updated.status = .cancelled
            updated.updatedAt = Date()
            appointments[index] = updated
            save()
        }
    }

    func delete(_ appointment: Appointment) {
        appointments.removeAll { $0.id == appointment.id }
        save()
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(appointments) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Appointment].self, from: data) {
            appointments = decoded
        }
    }
}
