import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var playerManager: PlayerManager
    var body: some View {
        
        TabView {
        
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            Text("Map")
                .tabItem {
                    Image(systemName: "shoeprints.fill")
                    Text("Walk")
                }
            CheerView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Player")
                }

            UserView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("User")
                }
//            DebugView()
//                .tabItem {
//                    Image(systemName: "ladybug.circle")
//                    Text("Debug")
//                }
        }
    }
}
