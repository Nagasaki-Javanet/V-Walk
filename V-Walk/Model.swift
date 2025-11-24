import Foundation
import FirebaseFirestore

// Coupon Model
struct Coupon: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var expiryDate: Date
    var isUsed: Bool
    
    // Helper to format date
    var expiryString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: expiryDate)
    }
}

// Payment History Model
struct PaymentHistory: Identifiable, Codable {
    @DocumentID var id: String?
    var itemName: String
    var price: Int
    var date: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    var priceString: String {
        return "¥\(price)"
    }
}

// Completed Course Model
struct CompletedCourse: Identifiable, Codable {
    @DocumentID var id: String?
    var courseTitle: String
    var completedDate: Date
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd 完了"
        return formatter.string(from: completedDate)
    }
}

// Player Model
struct Player: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var backNumber: Int
    var team: String
    var position: String
    var playerImageURL: String
    var totalPoints: Int

    
}
