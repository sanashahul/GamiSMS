import SwiftUI
import CoreLocation

struct LocationView: View {
    @EnvironmentObject var userProfile: UserProfile
    @StateObject private var localization = LocalizationManager.shared
    @StateObject private var locationService = LocationService.shared
    let onContinue: () -> Void

    @State private var showLocationAlert = false
    @State private var locationSuccess = false
    @FocusState private var isZipFocused: Bool

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text(localization.localized("where_located"))
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text(localization.localized("location_desc"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Spacer()

            // Location options
            VStack(spacing: 16) {
                // Use current location
                Button(action: requestLocation) {
                    HStack(spacing: 16) {
                        Image(systemName: locationSuccess ? "checkmark.circle.fill" : "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)

                        VStack(alignment: .leading) {
                            Text(localization.localized("use_my_location"))
                                .font(.headline)
                                .foregroundColor(.white)
                            if locationSuccess && !locationService.currentCity.isEmpty {
                                Text("\(locationService.currentCity), \(locationService.currentState)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            } else {
                                Text(localization.localized("find_clinics_nearby"))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        Spacer()

                        if locationService.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else if locationSuccess {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(locationSuccess ? Color.green : Color.blue)
                    .cornerRadius(16)
                }

                Text(localization.localized("or"))
                    .foregroundColor(.secondary)

                // Enter ZIP code
                VStack(alignment: .leading, spacing: 8) {
                    Text(localization.localized("enter_zip"))
                        .font(.subheadline.weight(.medium))

                    TextField("ZIP Code", text: $userProfile.zipCode)
                        .keyboardType(.numberPad)
                        .focused($isZipFocused)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userProfile.zipCode.count == 5 ? Color.green : Color.clear, lineWidth: 2)
                        )
                        .onChange(of: userProfile.zipCode) { newValue in
                            // Limit to 5 digits and only numbers
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered.count > 5 {
                                userProfile.zipCode = String(filtered.prefix(5))
                            } else if filtered != newValue {
                                userProfile.zipCode = filtered
                            }

                            // Auto-validate when 5 digits entered
                            if userProfile.zipCode.count == 5 {
                                isZipFocused = false
                            }
                        }

                    if userProfile.zipCode.count == 5 {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Valid ZIP code")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .padding(.horizontal, 30)

            Spacer()

            // Interpreter preference
            VStack(spacing: 16) {
                Toggle(isOn: $userProfile.needsInterpreter) {
                    HStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .foregroundColor(.purple)
                        VStack(alignment: .leading) {
                            Text(localization.localized("need_interpreter"))
                                .font(.headline)
                            Text(localization.localized("interpreter_desc"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .tint(.purple)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 30)

            Spacer()

            // Error message
            if let error = locationService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }

            // Continue button
            Button(action: {
                isZipFocused = false
                onContinue()
            }) {
                HStack {
                    Text(localization.localized("continue"))
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(canContinue ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(16)
            }
            .disabled(!canContinue)
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut, value: locationSuccess)
        .animation(.easeInOut, value: userProfile.zipCode.count)
        .contentShape(Rectangle())
        .onTapGesture {
            isZipFocused = false
        }
        .alert("Location Access", isPresented: $showLocationAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location access in Settings to find clinics near you, or enter your ZIP code manually.")
        }
        .onChange(of: locationService.hasLocation) { hasLocation in
            if hasLocation {
                locationSuccess = true
                if !locationService.currentZipCode.isEmpty {
                    userProfile.zipCode = locationService.currentZipCode
                }
            }
        }
        .onChange(of: locationService.authorizationStatus) { status in
            if status == .denied || status == .restricted {
                showLocationAlert = true
            }
        }
    }

    private var canContinue: Bool {
        userProfile.zipCode.count == 5 || locationService.hasLocation
    }

    private func requestLocation() {
        isZipFocused = false
        locationService.requestLocation()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    LocationView(onContinue: {})
        .environmentObject(UserProfile())
}

// Alias for the new onboarding flow
typealias LocationInputView = LocationView
