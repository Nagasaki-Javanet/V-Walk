import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var playerManager: PlayerManager
    var body: some View {
        
        TabView {
        
            Text("Home")
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
                .environmentObject(userManager)
                .environmentObject(playerManager)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Player")
                }

            UserView()
                .environmentObject(userManager)
                .environmentObject(playerManager)
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("User")
                }
            DebugView()
                .environmentObject(userManager)
                .environmentObject(playerManager)
                .tabItem {
                    Image(systemName: "ladybug.circle")
                    Text("Debug")
                }
        }
    }
}

#Preview {
    ContentView()
}
