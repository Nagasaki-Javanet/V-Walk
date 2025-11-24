import Foundation
import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class UserManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var isLoggedIn: Bool = false
    @Published var userPoints: Int = 0
    @Published var userName: String = "" // Added variable for user name
    @Published var coupons: [Coupon] = []
    @Published var completedCourses: [CompletedCourse] = []
    @Published var userRank: UserRank = .basic
    @Published var paymentHistory: [PaymentHistory] = []
    @Published var selectedPlayerID: String = ""
    
    init() {
        if Auth.auth().currentUser != nil {
                   self.isLoggedIn = true
                   Task { await loadUserData() }
               }
           }
    
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
            "userRank": "Basic",
            "PaymentHistory": [],
            "SelectedPlayerID": ""
        
            
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
                           let rankString = data?["rank"] as? String ?? "Basic"
                           self.userRank = UserRank(rawValue: rankString) ?? .basic
                           self.selectedPlayerID = data?["SelectedPlayerID"] as? String ?? ""
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
        
        let newRank = UserRank.getRank(for: self.userPoints + points)
        
        let userRef = db.collection("users").document(user.uid)
        let updateUserData: [String: Any] = [
            "points": FieldValue.increment(Int64(points)),
                    "rank": newRank.rawValue ]
        
        
        let playerRef = db.collection("players").document(self.selectedPlayerID)
        let safePlayerId = (self.selectedPlayerID.isEmpty == true) ? nil : self.selectedPlayerID
        print("\(safePlayerId)")
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 1. Update user's points
            transaction.updateData(
                updateUserData,
                forDocument: userRef
            )
            
            // 2. Update player's total points (same amount)
            if safePlayerId != nil {
                transaction.updateData(
                    ["totalPoints": FieldValue.increment(Int64(points))],
                    forDocument: playerRef
                )
            }
            
            return nil
        })  { (object, error) in
            if let error = error {
                print("Transaction failed: \(error.localizedDescription)")
            } else {
             
                     self.loadUserData()
                
            }
        }
        
    }
    
    func addCoupon(coupon: Coupon ) {
        guard let user = Auth.auth().currentUser else { return }
        let collection = db.collection("users").document(user.uid).collection("coupons")
      
        try? collection.addDocument(from: coupon)

             self.loadUserData()

        
        
    }
    
    func addCompletedCourse(course: CompletedCourse ) {
        guard let user = Auth.auth().currentUser else { return }
        let collection = db.collection("users").document(user.uid).collection("completedCourses")
      
        try? collection.addDocument(from: course)

             self.loadUserData()

    }
        
   func addPaymentHistory(history: PaymentHistory ) {
       guard let user = Auth.auth().currentUser else { return }
       let collection = db.collection("users").document(user.uid).collection("paymentHistory")
       
       try? collection.addDocument(from: history)
 
            self.loadUserData()

        
    }
    
    // MARK: - Change Support Player
    /// Changes the player that the user supports, transferring points from old player to new player
    func changeSupportPlayer(from oldPlayerId: String?, to newPlayerId: String) {
        
        // 1. Check if the user is logged in.
        guard let user = Auth.auth().currentUser else {
            print("❌ Error: User not logged in.")
            return
        }
        
        // Sanitize oldPlayerId: treat empty string "" as nil
        let safeOldId = (oldPlayerId?.isEmpty == true) ? nil : oldPlayerId
        
        // 2. Defensive coding: Prevent duplicate selection.
        // Check both the passed argument (safeOldId) and the current state (self.selectedPlayerId).
        if safeOldId == newPlayerId {
            print("ℹ️ Already supporting this player (Argument Check).")
            return
        }
        
        if self.selectedPlayerID == newPlayerId {
            print("ℹ️ Already supporting this player (State Check).")
            return
        }
        
        let userRef = db.collection("users").document(user.uid)
        let newPlayerRef = db.collection("players").document(newPlayerId)
        
        // Use current user points for transfer.
        let myPoints = self.userPoints
        print("💰 Transferring \(self.userName)'s \(myPoints) points.")
        
        // Run Firestore Transaction for atomicity.
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            
            // 3. Subtract points from the old player ONLY if a valid oldId exists.
            // If safeOldId is nil (first time selection), this block is skipped, preventing crashes.
            if let oldId = safeOldId {
                let oldPlayerRef = self.db.collection("players").document(oldId)
                
                // Subtract points from the old player.
                // FieldValue.increment is efficient as it doesn't require reading the document first.
                transaction.updateData(["totalPoints": FieldValue.increment(Int64(-myPoints))], forDocument: oldPlayerRef)
            }
            
            // 4. Add points to the new player.
            // This is always executed, whether it's a change or a first-time selection.
            transaction.updateData(["totalPoints": FieldValue.increment(Int64(myPoints))], forDocument: newPlayerRef)
            
            // 5. Update the user's selected player ID in the 'users' collection.
            // Note: Ensure the field name matches your Firestore DB (e.g., "selected_player_id").
            transaction.updateData(["SelectedPlayerID": newPlayerId], forDocument: userRef)
            
            return nil
            
        }) { (object, error) in
            if let error = error {
                // 6. Log error details if the transaction fails.
                print("❌ Transaction failed! Crash prevented.")
                print("   Error details: \(error.localizedDescription)")
            } else {
                print("✅ Player change successful: \(safeOldId ?? "None") -> \(newPlayerId)")
                
                // 7. Update UI state on the main thread.
                // Using DispatchQueue.main.async is safer for @Published property updates.
                Task {
                    self.selectedPlayerID = newPlayerId
                }
            }
        }
    }


}

