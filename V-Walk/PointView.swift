import SwiftUI

struct PointView: View {
    // Observe UserManager to update UI automatically
    @StateObject var userManager = UserManager()
    
    var body: some View {
        VStack(spacing: 30) {
            // Display User Name
            Text("ようこそ、\(userManager.userName)さん！") // "Welcome, [Name]!"
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Display Current Points
            VStack(spacing: 10) {
                Text("現在のポイント") // "Current Points"
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                
                Text("\(userManager.userPoints) P")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 15) {
                Button {
                    // Add 100 points
                    userManager.updateUserPoints(points: userManager.userPoints + 100)
                    userManager.loadUserData()
                } label: {
                    Text("ポイント獲得 (+100)") // "Earn Points (+100)"
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                
               
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            // Load user data (points & name) when view appears
            userManager.loadUserData()
        }
    }
}

#Preview {
    PointView()
}
