import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @StateObject private var localization = LocalizationManager.shared
    @State private var showAddAppointment = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Info banner - emphasize this is a tracker, not booking
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text(localization.localized("appointment_tracker_info"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)

                // Segment picker
                Picker("Appointments", selection: $selectedSegment) {
                    Text(localization.localized("upcoming")).tag(0)
                    Text(localization.localized("past")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                if selectedSegment == 0 {
                    UpcomingAppointmentsList(
                        appointments: appointmentsManager.upcomingAppointments,
                        onDelete: { appointmentsManager.cancel($0) }
                    )
                } else {
                    PastAppointmentsList(
                        appointments: appointmentsManager.pastAppointments
                    )
                }
            }
            .navigationTitle(localization.localized("my_appointments"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddAppointment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAppointment) {
                AddAppointmentReminderView()
            }
        }
    }
}

// MARK: - Upcoming Appointments List
struct UpcomingAppointmentsList: View {
    let appointments: [Appointment]
    let onDelete: (Appointment) -> Void
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        if appointments.isEmpty {
            EmptyAppointmentsView()
        } else {
            List {
                ForEach(appointments) { appointment in
                    AppointmentReminderRow(appointment: appointment, onDelete: onDelete)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Past Appointments List
struct PastAppointmentsList: View {
    let appointments: [Appointment]
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        if appointments.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text(localization.localized("no_past_appointments"))
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(appointments) { appointment in
                    PastAppointmentRow(appointment: appointment)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Appointment Reminder Row
struct AppointmentReminderRow: View {
    let appointment: Appointment
    let onDelete: (Appointment) -> Void
    @State private var showDeleteAlert = false
    @State private var showEditSheet = false
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                VStack(alignment: .leading) {
                    if appointment.isToday {
                        Text(localization.localized("today"))
                            .font(.caption.weight(.bold))
                            .foregroundColor(.red)
                    } else if appointment.isTomorrow {
                        Text(localization.localized("tomorrow"))
                            .font(.caption.weight(.bold))
                            .foregroundColor(.orange)
                    } else {
                        Text(appointment.formattedDate.uppercased())
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                    Text(appointment.time)
                        .font(.title2.bold())
                }
                Spacer()

                // Reminder badge
                HStack(spacing: 4) {
                    Image(systemName: "bell.fill")
                        .font(.caption)
                    Text(localization.localized("reminder"))
                        .font(.caption.weight(.medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .foregroundColor(.blue)
                .cornerRadius(8)
            }

            Divider()

            // Clinic info
            HStack(spacing: 12) {
                Image(systemName: appointment.appointmentType.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.appointmentType.displayName)
                        .font(.headline)
                    Text(appointment.clinicName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if !appointment.clinicAddress.isEmpty {
                        Text(appointment.clinicAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Special needs
            if appointment.needsInterpreter || appointment.needsTransportation {
                HStack(spacing: 12) {
                    if appointment.needsInterpreter {
                        NeedBadge(icon: "bubble.left.and.bubble.right", text: localization.localized("interpreter"), color: .purple)
                    }
                    if appointment.needsTransportation {
                        NeedBadge(icon: "car", text: localization.localized("transport"), color: .orange)
                    }
                }
            }

            // Notes
            if !appointment.notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    Text(appointment.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }

            // Actions
            HStack(spacing: 12) {
                if !appointment.clinicPhone.isEmpty {
                    Button(action: { callClinic() }) {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text(localization.localized("call_clinic"))
                        }
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }

                Button(action: { showDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text(localization.localized("delete"))
                    }
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .foregroundColor(.red)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5)
        .alert(localization.localized("delete_reminder"), isPresented: $showDeleteAlert) {
            Button(localization.localized("keep"), role: .cancel) {}
            Button(localization.localized("delete"), role: .destructive) {
                onDelete(appointment)
            }
        } message: {
            Text(localization.localized("delete_reminder_confirm"))
        }
    }

    private func callClinic() {
        let number = appointment.clinicPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

struct NeedBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(8)
    }
}

// MARK: - Past Appointment Row
struct PastAppointmentRow: View {
    let appointment: Appointment
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: appointment.appointmentType.icon)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.appointmentType.displayName)
                    .font(.subheadline.weight(.medium))
                Text(appointment.clinicName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(appointment.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(localization.localized("completed"))
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State
struct EmptyAppointmentsView: View {
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))

            VStack(spacing: 8) {
                Text(localization.localized("no_upcoming_reminders"))
                    .font(.headline)
                Text(localization.localized("add_appointment_after_calling"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Helpful tip
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text(localization.localized("how_to_use"))
                        .font(.subheadline.weight(.medium))
                }

                VStack(alignment: .leading, spacing: 8) {
                    HowToStep(number: "1", text: localization.localized("step_find_clinic"))
                    HowToStep(number: "2", text: localization.localized("step_call_clinic"))
                    HowToStep(number: "3", text: localization.localized("step_add_reminder"))
                }
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct HowToStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.blue)
                .clipShape(Circle())
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Add Appointment Reminder View
struct AddAppointmentReminderView: View {
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var localization = LocalizationManager.shared

    @State private var clinicName = ""
    @State private var clinicAddress = ""
    @State private var clinicPhone = ""
    @State private var selectedType: AppointmentType = .general
    @State private var selectedDate = Date()
    @State private var selectedTime = "9:00 AM"
    @State private var needsInterpreter = false
    @State private var needsTransportation = false
    @State private var notes = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case clinicName, address, phone, notes
    }

    let timeSlots = [
        "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
        "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM",
        "4:00 PM", "4:30 PM", "5:00 PM"
    ]

    var body: some View {
        NavigationView {
            Form {
                // Instruction banner
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "phone.arrow.up.right")
                            .foregroundColor(.green)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(localization.localized("call_to_schedule"))
                                .font(.subheadline.weight(.medium))
                            Text(localization.localized("add_reminder_after"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Clinic information
                Section(localization.localized("clinic_info")) {
                    TextField(localization.localized("clinic_name"), text: $clinicName)
                        .focused($focusedField, equals: .clinicName)

                    TextField(localization.localized("address_optional"), text: $clinicAddress)
                        .focused($focusedField, equals: .address)

                    TextField(localization.localized("phone_optional"), text: $clinicPhone)
                        .focused($focusedField, equals: .phone)
                        .keyboardType(.phonePad)
                }

                // Appointment type
                Section(localization.localized("type_of_visit")) {
                    Picker("Visit Type", selection: $selectedType) {
                        ForEach(AppointmentType.allCases) { type in
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Date and time
                Section(localization.localized("when")) {
                    DatePicker(localization.localized("date"), selection: $selectedDate, in: Date()..., displayedComponents: .date)

                    Picker(localization.localized("time"), selection: $selectedTime) {
                        ForEach(timeSlots, id: \.self) { time in
                            Text(time).tag(time)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                // Reminders for yourself
                Section(localization.localized("reminders_for_visit")) {
                    Toggle(isOn: $needsInterpreter) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .foregroundColor(.purple)
                            Text(localization.localized("bring_interpreter_or_request"))
                        }
                    }

                    Toggle(isOn: $needsTransportation) {
                        HStack {
                            Image(systemName: "car")
                                .foregroundColor(.orange)
                            Text(localization.localized("arrange_transportation"))
                        }
                    }
                }

                // Notes
                Section(localization.localized("notes_optional")) {
                    TextField(localization.localized("notes_placeholder"), text: $notes, axis: .vertical)
                        .focused($focusedField, equals: .notes)
                        .lineLimit(3...6)
                }

                // Add button
                Section {
                    Button(action: addReminder) {
                        HStack {
                            Spacer()
                            Text(localization.localized("add_reminder"))
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .disabled(clinicName.isEmpty)
                    .foregroundColor(clinicName.isEmpty ? .gray : .white)
                    .listRowBackground(clinicName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                }
            }
            .navigationTitle(localization.localized("add_appointment"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localized("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .keyboard) {
                    Button(localization.localized("done")) {
                        focusedField = nil
                    }
                }
            }
            .onAppear {
                needsInterpreter = userProfile.needsInterpreter
                needsTransportation = !userProfile.hasTransportation
            }
        }
    }

    private func addReminder() {
        let appointment = Appointment(
            clinicId: UUID(),
            clinicName: clinicName,
            clinicAddress: clinicAddress,
            clinicPhone: clinicPhone,
            appointmentType: selectedType,
            date: selectedDate,
            time: selectedTime,
            needsInterpreter: needsInterpreter,
            interpreterLanguage: needsInterpreter ? userProfile.preferredLanguage : nil,
            needsTransportation: needsTransportation,
            notes: notes
        )

        appointmentsManager.add(appointment)
        dismiss()
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
