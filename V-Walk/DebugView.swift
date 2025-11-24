
import Foundation
import SwiftUI

struct DebugView: View {
    @StateObject var userManager = UserManager()

    var body: some View {
        VStack{
            Button {
                userManager.addCoupon(coupon: Coupon(title: "Demo Coupon \(userManager.coupons.count)", expiryDate:Date(), isUsed: false))
                userManager.loadUserData()

            } label: {
                Text("Add Coupon")
            .padding()
            }
            
            Button {
                userManager.addPaymentHistory(history: PaymentHistory(itemName: "Demo \(userManager.paymentHistory.count)", price: Int.random(in: 100...1000), date: Date()))
                userManager.loadUserData()
            } label: {
                Text("Add Purchase History")
                    .padding()
            }
            
            Button {
                userManager.addCompletedCourse(course: CompletedCourse(courseTitle: "Demo Course \(userManager.completedCourses.count)", completedDate: Date()))
                userManager.loadUserData()
            } label: {
                Text("Add Completed Course")
                    .padding()
            }
            
            Button {
                userManager.updateUserPoints(points: userManager.userPoints + 100)
                userManager.loadUserData()
                
            } label: {
                Text("Add 100 Points")
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
