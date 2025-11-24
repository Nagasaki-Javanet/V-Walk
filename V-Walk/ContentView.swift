import SwiftUI

struct ContentView: View {
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
            

            UserView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("User")
                }
            DebugView()
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
