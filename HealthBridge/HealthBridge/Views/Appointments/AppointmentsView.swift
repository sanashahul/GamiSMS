import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @StateObject private var localization = LocalizationManager.shared
    @State private var showBooking = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
                        onCancel: { appointmentsManager.cancel($0) }
                    )
                } else {
                    PastAppointmentsList(
                        appointments: appointmentsManager.pastAppointments
                    )
                }
            }
            .navigationTitle(localization.localized("appointments"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showBooking = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showBooking) {
                SelectClinicForBookingView()
            }
        }
    }
}

// MARK: - Upcoming Appointments List
struct UpcomingAppointmentsList: View {
    let appointments: [Appointment]
    let onCancel: (Appointment) -> Void

    var body: some View {
        if appointments.isEmpty {
            EmptyAppointmentsView()
        } else {
            List {
                ForEach(appointments) { appointment in
                    AppointmentDetailRow(appointment: appointment, onCancel: onCancel)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Past Appointments List
struct PastAppointmentsList: View {
    let appointments: [Appointment]

    var body: some View {
        if appointments.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                Text("No past appointments")
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

// MARK: - Appointment Detail Row
struct AppointmentDetailRow: View {
    let appointment: Appointment
    let onCancel: (Appointment) -> Void
    @State private var showCancelAlert = false
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
                StatusBadge(status: appointment.status)
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
                    Text(appointment.clinicAddress)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Special needs
            if appointment.needsInterpreter || appointment.needsTransportation {
                HStack(spacing: 12) {
                    if appointment.needsInterpreter {
                        NeedBadge(icon: "bubble.left.and.bubble.right", text: localization.localized("interpreter"), color: .purple)
                    }
                    if appointment.needsTransportation {
                        NeedBadge(icon: "car", text: "Transport", color: .orange)
                    }
                }
            }

            // Actions
            HStack(spacing: 12) {
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

                Button(action: { showCancelAlert = true }) {
                    HStack {
                        Image(systemName: "xmark")
                        Text(localization.localized("cancel"))
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
        .alert(localization.localized("cancel_appointment"), isPresented: $showCancelAlert) {
            Button(localization.localized("keep_appointment"), role: .cancel) {}
            Button(localization.localized("cancel"), role: .destructive) {
                onCancel(appointment)
            }
        } message: {
            Text("Are you sure you want to cancel this appointment?")
        }
    }

    private func callClinic() {
        let number = appointment.clinicPhone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        if let url = URL(string: "tel://\(number)") {
            UIApplication.shared.open(url)
        }
    }
}

struct StatusBadge: View {
    let status: AppointmentStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color).opacity(0.2))
            .foregroundColor(Color(status.color))
            .cornerRadius(8)
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
                StatusBadge(status: appointment.status)
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
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))

            VStack(spacing: 8) {
                Text(localization.localized("no_upcoming_appointments"))
                    .font(.headline)
                Text(localization.localized("schedule_first_appointment"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Select Clinic for Booking
struct SelectClinicForBookingView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var clinicService = ClinicService.shared
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        NavigationView {
            List {
                ForEach(clinicService.allClinics) { clinic in
                    NavigationLink(destination: BookAppointmentView(clinic: clinic)) {
                        HStack(spacing: 12) {
                            Image(systemName: clinic.type.icon)
                                .foregroundColor(Color(clinic.type.color))
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text(clinic.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(clinic.city), \(clinic.state)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(localization.localized("select_clinic"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localized("cancel")) { dismiss() }
                }
            }
        }
    }
}

// MARK: - Book Appointment View
struct BookAppointmentView: View {
    let clinic: Clinic
    @EnvironmentObject var userProfile: UserProfile
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var localization = LocalizationManager.shared

    @State private var selectedType: AppointmentType = .newPatient
    @State private var selectedDate = Date()
    @State private var selectedTime = "9:00 AM"
    @State private var needsInterpreter = false
    @State private var needsTransportation = false
    @State private var notes = ""
    @State private var showConfirmation = false
    @State private var isBooking = false

    let timeSlots = [
        "9:00 AM", "9:30 AM", "10:00 AM", "10:30 AM", "11:00 AM", "11:30 AM",
        "1:00 PM", "1:30 PM", "2:00 PM", "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM"
    ]

    var body: some View {
        Form {
            // Clinic info
            Section {
                HStack(spacing: 12) {
                    Image(systemName: clinic.type.icon)
                        .foregroundColor(Color(clinic.type.color))
                    VStack(alignment: .leading) {
                        Text(clinic.name)
                            .font(.headline)
                        Text(clinic.fullAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
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

            // Special needs
            Section(localization.localized("special_needs")) {
                Toggle(isOn: $needsInterpreter) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.purple)
                        Text(localization.localized("need_interpreter_toggle"))
                    }
                }

                if needsInterpreter {
                    HStack {
                        Text("Language")
                        Spacer()
                        Text(userProfile.preferredLanguage.displayName)
                            .foregroundColor(.secondary)
                    }
                }

                Toggle(isOn: $needsTransportation) {
                    HStack {
                        Image(systemName: "car")
                            .foregroundColor(.orange)
                        Text(localization.localized("need_transportation"))
                    }
                }
            }

            // Notes
            Section(localization.localized("notes_optional")) {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }

            // Book button
            Section {
                Button(action: bookAppointment) {
                    HStack {
                        Spacer()
                        if isBooking {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(localization.localized("book_appointment"))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(isBooking)
                .foregroundColor(.white)
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle(localization.localized("book_appointment"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            needsInterpreter = userProfile.needsInterpreter
            needsTransportation = !userProfile.hasTransportation
        }
        .sheet(isPresented: $showConfirmation) {
            AppointmentConfirmationView(
                clinic: clinic,
                date: selectedDate,
                time: selectedTime,
                appointmentType: selectedType,
                needsInterpreter: needsInterpreter,
                needsTransportation: needsTransportation,
                onDone: {
                    showConfirmation = false
                    dismiss()
                }
            )
        }
    }

    private func bookAppointment() {
        isBooking = true

        // Simulate network delay for realistic feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let appointment = Appointment(
                clinicId: clinic.id,
                clinicName: clinic.name,
                clinicAddress: clinic.fullAddress,
                clinicPhone: clinic.phoneNumber,
                appointmentType: selectedType,
                date: selectedDate,
                time: selectedTime,
                needsInterpreter: needsInterpreter,
                interpreterLanguage: needsInterpreter ? userProfile.preferredLanguage : nil,
                needsTransportation: needsTransportation,
                notes: notes
            )

            appointmentsManager.add(appointment)
            isBooking = false
            showConfirmation = true
        }
    }
}

// MARK: - Appointment Confirmation View
struct AppointmentConfirmationView: View {
    let clinic: Clinic
    let date: Date
    let time: String
    let appointmentType: AppointmentType
    let needsInterpreter: Bool
    let needsTransportation: Bool
    let onDone: () -> Void
    @StateObject private var localization = LocalizationManager.shared

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
            }

            VStack(spacing: 8) {
                Text(localization.localized("appointment_booked"))
                    .font(.title.bold())

                Text(localization.localized("appointment_confirmed"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Appointment details card
            VStack(alignment: .leading, spacing: 16) {
                // Clinic
                HStack(spacing: 12) {
                    Image(systemName: clinic.type.icon)
                        .foregroundColor(Color(clinic.type.color))
                        .frame(width: 40)
                    VStack(alignment: .leading) {
                        Text(clinic.name)
                            .font(.headline)
                        Text(clinic.fullAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Date & Time
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                        .frame(width: 40)
                    VStack(alignment: .leading) {
                        Text(formattedDate)
                            .font(.headline)
                        Text(time)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // Type
                HStack(spacing: 12) {
                    Image(systemName: appointmentType.icon)
                        .foregroundColor(.teal)
                        .frame(width: 40)
                    Text(appointmentType.displayName)
                        .font(.headline)
                }

                // Special needs
                if needsInterpreter || needsTransportation {
                    Divider()
                    HStack(spacing: 12) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.purple)
                            .frame(width: 40)
                        VStack(alignment: .leading) {
                            if needsInterpreter {
                                Text("Interpreter requested")
                                    .font(.subheadline)
                            }
                            if needsTransportation {
                                Text("Transportation assistance requested")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            // Done button
            Button(action: onDone) {
                Text(localization.localized("done"))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
