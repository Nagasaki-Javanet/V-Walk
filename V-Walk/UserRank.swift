import SwiftUI

enum UserRank: String, Codable {
    case basic = "Basic"   // Changed from Bronze to Basic
    case silver = "Silver"
    case gold = "Gold"
    case vip = "VIP"
    
    // Minimum points required for each rank
    var minPoints: Int {
        switch self {
        case .basic: return 0
        case .silver: return 500
        case .gold: return 1000
        case .vip: return 2000
        }
    }
    
    // Target points for next rank
    var nextRankPoints: Int {
        switch self {
        case .basic: return UserRank.silver.minPoints  // 500
        case .silver: return UserRank.gold.minPoints   // 1000
        case .gold: return UserRank.vip.minPoints      // 2000
        case .vip: return 2000 // Max level
        }
    }
    
    // Calculate progress (0.0 to 1.0)
    static func progress(currentPoints: Int) -> Double {
        let currentRank = getRank(for: currentPoints)
        if currentRank == .vip { return 1.0 }
        
        let start = Double(currentRank.minPoints)
        let end = Double(currentRank.nextRankPoints)
        let current = Double(currentPoints)
        
        if end - start == 0 { return 0.0 }
        return (current - start) / (end - start)
    }
    
    // Determine rank based on points
    static func getRank(for points: Int) -> UserRank {
        if points >= UserRank.vip.minPoints { return .vip }
        if points >= UserRank.gold.minPoints { return .gold }
        if points >= UserRank.silver.minPoints { return .silver }
        return .basic // Default is Basic
    }
    
    // Card Background Gradient
    var backgroundGradient: LinearGradient {
        switch self {
        case .basic:
            // Basic: Clean Blue
            return LinearGradient(
                colors: [Color.blue, Color.cyan], // Blue to Cyan
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .silver:
            // Silver: Metallic Gray
            return LinearGradient(
                colors: [Color(white: 0.6), Color(white: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gold:
            // Gold: Shiny Yellow/Orange
            return LinearGradient(
                colors: [Color(red: 0.8, green: 0.6, blue: 0.0), Color(red: 1.0, green: 0.85, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vip:
            // VIP: Premium Purple/Blue
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.0, blue: 0.5), Color(red: 0.0, green: 0.0, blue: 0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    // Text/Icon Color for UI elements
    var rankColor: Color {
        switch self {
        case .basic: return Color.blue
        case .silver: return Color.gray
        case .gold: return Color.orange
        case .vip: return Color.purple
        }
    }
    // Text/Icon Color ON THE CARD (Contrast Color)
    var cardContentColor: Color {
        switch self {
        case .basic,.gold, .vip:
            return .white // Dark background -> White text
        case .silver:
            return .black.opacity(0.8) // Light background -> Dark text
        }
    }
    
    // Progress Bar Background Color (Track Color)
    var progressBarTrackColor: Color {
        switch self {
        case .basic, .gold, .vip:
            return Color.white.opacity(0.3) // Semi-transparent white
        case .silver:
            return Color.black.opacity(0.1) // Semi-transparent black
        }
    }
}
