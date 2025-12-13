import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var appointmentsManager: AppointmentsManager
    @State private var showBooking = false
    @State private var selectedSegment = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segment picker
                Picker("Appointments", selection: $selectedSegment) {
                    Text("Upcoming").tag(0)
                    Text("Past").tag(1)
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
            .navigationTitle("Appointments")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date header
            HStack {
                VStack(alignment: .leading) {
                    if appointment.isToday {
                        Text("TODAY")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.red)
                    } else if appointment.isTomorrow {
                        Text("TOMORROW")
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
                        NeedBadge(icon: "bubble.left.and.bubble.right", text: "Interpreter", color: .purple)
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
                        Text("Call Clinic")
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
                        Text("Cancel")
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
        .alert("Cancel Appointment?", isPresented: $showCancelAlert) {
            Button("Keep Appointment", role: .cancel) {}
            Button("Cancel Appointment", role: .destructive) {
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
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Upcoming Appointments")
                    .font(.headline)
                Text("Schedule your first appointment to get started with your healthcare journey.")
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

    var body: some View {
        NavigationView {
            List {
                ForEach(Clinic.samples) { clinic in
                    NavigationLink(destination: BookAppointmentView(clinic: clinic)) {
                        HStack(spacing: 12) {
                            Image(systemName: clinic.type.icon)
                                .foregroundColor(Color(clinic.type.color))
                                .frame(width: 30)

                            VStack(alignment: .leading) {
                                Text(clinic.name)
                                    .font(.subheadline.weight(.medium))
                                Text(clinic.type.displayName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Clinic")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
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

    @State private var selectedType: AppointmentType = .newPatient
    @State private var selectedDate = Date()
    @State private var selectedTime = "9:00 AM"
    @State private var needsInterpreter = false
    @State private var needsTransportation = false
    @State private var notes = ""

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
            Section("Type of Visit") {
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
            Section("When") {
                DatePicker("Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)

                Picker("Time", selection: $selectedTime) {
                    ForEach(timeSlots, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .pickerStyle(.navigationLink)
            }

            // Special needs
            Section("Special Needs") {
                Toggle(isOn: $needsInterpreter) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.purple)
                        Text("I need an interpreter")
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
                        Text("I need help with transportation")
                    }
                }
            }

            // Notes
            Section("Notes (Optional)") {
                TextEditor(text: $notes)
                    .frame(height: 100)
            }

            // Book button
            Section {
                Button(action: bookAppointment) {
                    HStack {
                        Spacer()
                        Text("Book Appointment")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .foregroundColor(.white)
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle("Book Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            needsInterpreter = userProfile.needsInterpreter
            needsTransportation = !userProfile.hasTransportation
        }
    }

    private func bookAppointment() {
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
        dismiss()
    }
}

#Preview {
    AppointmentsView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
