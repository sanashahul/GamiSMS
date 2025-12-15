import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userProfile: UserProfile
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home tab - always shown
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Healthcare tab - only if selected
            if userProfile.selectedServiceAreas.contains(.healthcare) {
                ClinicFinderView()
                    .tabItem {
                        Label("Healthcare", systemImage: "cross.case.fill")
                    }
                    .tag(1)
            }

            // Employment tab - only if selected
            if userProfile.selectedServiceAreas.contains(.employment) {
                JobFinderMapView()
                    .tabItem {
                        Label("Jobs", systemImage: "briefcase.fill")
                    }
                    .tag(2)
            }

            // Housing tab - only if selected
            if userProfile.selectedServiceAreas.contains(.housing) {
                ShelterFinderMapView()
                    .tabItem {
                        Label("Housing", systemImage: "house.fill")
                    }
                    .tag(3)
            }

            // Appointments tab - always shown
            AppointmentsView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(4)

            // Profile tab - always shown
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(5)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
