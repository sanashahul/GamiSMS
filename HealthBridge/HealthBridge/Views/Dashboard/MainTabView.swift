import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ClinicFinderView()
                .tabItem {
                    Label("Find Care", systemImage: "mappin.circle.fill")
                }
                .tag(1)

            AppointmentsView()
                .tabItem {
                    Label("Appointments", systemImage: "calendar")
                }
                .tag(2)

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserProfile())
        .environmentObject(AppointmentsManager())
}
