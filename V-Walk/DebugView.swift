
import Foundation
import SwiftUI
import FirebaseAuth

struct DebugView: View {
    @EnvironmentObject var userManager : UserManager
    @EnvironmentObject var playerManager : PlayerManager

    var body: some View {
        VStack{
            Button {
                userManager.addCoupon(coupon: Coupon(title: "Demo Coupon \(userManager.coupons.count)", expiryDate:Date(), isUsed: false))

            } label: {
                Text("Add Coupon")
            .padding()
            }
            
            Button {
                userManager.addPaymentHistory(history: PaymentHistory(itemName: "Demo \(userManager.paymentHistory.count)", price: Int.random(in: 100...1000), date: Date()))
            } label: {
                Text("Add Purchase History")
                    .padding()
            }
            
            Button {
                userManager.addCompletedCourse(course: CompletedCourse(courseTitle: "Demo Course \(userManager.completedCourses.count)", completedDate: Date()))
            } label: {
                Text("Add Completed Course")
                    .padding()
            }
            
            Button {
                userManager.updateUserPoints(points: userManager.userPoints + 100)
                
            } label: {
                Text("Add 100 Points")
                    .padding()
            }
            
            Button {
                playerManager.addPlayer(player: Player(name: "Demo Player \(playerManager.players.count)"
                                                       
                                                       ,backNumber: playerManager.players.count, team: "Demo Team", position: "Demo Position",playerImageURL:"",
                                                      totalPoints: 0))
            } label: {
                Text("Add Player")
                    .padding()
            }
            Button {
                
                try? Auth.auth().signOut()
                userManager.isLoggedIn = false
            } label: {
                Text("Sign Out")
                    .padding()
            }
        }.onAppear() {
            
            userManager.loadUserData()
        }
        
    }
    
}

#Preview {
    DebugView()
}
