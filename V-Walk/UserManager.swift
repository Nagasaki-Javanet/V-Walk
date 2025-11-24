import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserManager: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var userPoints: Int = 0
    @Published var userName: String = "" // Added variable for user name
    @Published var coupons: [Coupon] = []
    @Published var completedCourses: [CompletedCourse] = []
    @Published var vipRank: String = "Basic"
    @Published var paymentHistory: [PaymentHistory] = []
    
    // Function to save user data (Name & Points)
    // Call this after Sign Up
    func createNewUser(name: String) {
        guard let user = Auth.auth().currentUser else { return }
        
        let userData: [String: Any] = [
            "name": name,
            "ImageURL": "",
            "points": 0, // Start with 0 points
            "createdAt": FieldValue.serverTimestamp(),
            "coupons": [],
            "completedCourses": [],
            "VIPRank": "Basic",
            "PaymentHistory": []
        
            
        ]
        
        db.collection("users").document(user.uid).setData(userData) { error in
            if let error = error {
                print("Error creating user: \(error)")
            } else {
                print("User created successfully!")
                DispatchQueue.main.async {
                    self.userName = name
                    self.userPoints = 0
                }
            }
        }
    }
   
    func loadUserData() {
        Task{
            
        guard let user = Auth.auth().currentUser else { return }
           
        let userDocRef = db.collection("users").document(user.uid)  // Load user data (Name & Points)
            let document = try await userDocRef.getDocument()
                       if document.exists {
                           let data = document.data()
                           self.userPoints = data?["points"] as? Int ?? 0
                           self.userName = data?["name"] as? String ?? "Unknown"
                       }
            
               
            let couponSnapshot = try await userDocRef.collection("coupons").getDocuments()  // Load coupons data
            self.coupons = couponSnapshot.documents.compactMap { doc in
                try? doc.data(as: Coupon.self)
            }
            
           
            let completedCoursesSnapshot = try await userDocRef.collection("completedCourses").getDocuments()  // load course data
            self.completedCourses = completedCoursesSnapshot.documents.compactMap { doc in
                try? doc.data(as: CompletedCourse.self)
            }
            
            let purchaseHistorySnapshot = try await userDocRef.collection("paymentHistory").getDocuments()
            self.paymentHistory = purchaseHistorySnapshot.documents.compactMap{ doc in
                try? doc.data(as: PaymentHistory.self)}
        
            
            
    }
       
    }
    
    func updateUserPoints( points: Int) {
        guard let user = Auth.auth().currentUser else { return }
        
        db.collection("users").document(user.uid).updateData(["points": points]) { error in
            if let error = error {
                print("Error updating user points: \(error)")
            } else {
                print("User points updated successfully!")
            }
        }
    }
    
    func addCoupon(coupon: Coupon ) {
        guard let user = Auth.auth().currentUser else { return }
        let collection = db.collection("users").document(user.uid).collection("coupons")
      
        try? collection.addDocument(from: coupon)
        
        
    }
    
    func addCompletedCourse(course: CompletedCourse ) {
        guard let user = Auth.auth().currentUser else { return }
        let collection = db.collection("users").document(user.uid).collection("completedCourses")
      
        try? collection.addDocument(from: course)
    }
        
   func addPaymentHistory(history: PaymentHistory ) {
       guard let user = Auth.auth().currentUser else { return }
       let collection = db.collection("users").document(user.uid).collection("paymentHistory")
       
       try? collection.addDocument(from: history)
        
    }
    

}
