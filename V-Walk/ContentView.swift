import SwiftUI
import Combine
class RouteSelection: ObservableObject {
    @Published var selectedCheckpoints: [Checkpoint] = []
}

struct ContentView: View {
    @StateObject var routeSelection = RouteSelection()
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var playerManager: PlayerManager
    @State private var selectedTab = 0
    var body: some View {
        
        TabView(selection: $selectedTab) {
        
            HomeView(selectedTab: $selectedTab)
                .environmentObject(routeSelection)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            NavigationMapView()
                .environmentObject(routeSelection)
                .tabItem {
                    Image(systemName: "shoeprints.fill")
                    Text("Walk")
                }
                .tag(1)
            CheerView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Player")
                }
                .tag(2)

            UserView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("User")
                }
                .tag(3)
//            DebugView()
//                .tabItem {
//                    Image(systemName: "ladybug.circle")
//                    Text("Debug")
//                }
        }
    }
}
