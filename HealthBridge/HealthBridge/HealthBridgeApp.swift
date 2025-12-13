import SwiftUI

@main
struct HealthBridgeApp: App {
    @StateObject private var userProfile = UserProfile.load()
    @StateObject private var appointmentsManager = AppointmentsManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userProfile)
                .environmentObject(appointmentsManager)
        }
    }
}
