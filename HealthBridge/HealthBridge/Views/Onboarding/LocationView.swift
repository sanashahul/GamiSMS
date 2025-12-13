import SwiftUI
import CoreLocation

struct LocationView: View {
    @EnvironmentObject var userProfile: UserProfile
    let onContinue: () -> Void

    @State private var showLocationAlert = false
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                Text("Where are you located?")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Text("This helps us find clinics and services near you.")
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
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .foregroundColor(.white)

                        VStack(alignment: .leading) {
                            Text("Use My Current Location")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("We'll find clinics nearby")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()

                        if locationManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(16)
                }

                Text("or")
                    .foregroundColor(.secondary)

                // Enter ZIP code
                VStack(alignment: .leading, spacing: 8) {
                    Text("Enter your ZIP code")
                        .font(.subheadline.weight(.medium))

                    TextField("ZIP Code", text: $userProfile.zipCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: userProfile.zipCode) { newValue in
                            // Limit to 5 digits
                            if newValue.count > 5 {
                                userProfile.zipCode = String(newValue.prefix(5))
                            }
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
                            Text("I need an interpreter")
                                .font(.headline)
                            Text("We'll find clinics with language services")
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

            // Continue button
            Button(action: onContinue) {
                HStack {
                    Text("Continue")
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
        .alert("Location Access", isPresented: $showLocationAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable location access in Settings to find clinics near you, or enter your ZIP code manually.")
        }
    }

    private var canContinue: Bool {
        userProfile.zipCode.count == 5 || locationManager.hasLocation
    }

    private func requestLocation() {
        locationManager.requestLocation()
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var location: CLLocation?
    @Published var isLoading = false
    @Published var hasLocation = false
    @Published var error: Error?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation() {
        isLoading = true
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isLoading = false
        location = locations.first
        hasLocation = location != nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        self.error = error
    }
}

#Preview {
    LocationView(onContinue: {})
        .environmentObject(UserProfile())
}
