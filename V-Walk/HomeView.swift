import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userManager : UserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    
                    // MARK: - 1. VIP Card Section
                    UserRankInfoView()
                        .environmentObject(userManager)
                    .frame(height: 160)
                    .padding(.horizontal)
                    
                    // MARK: - 2.5 Rank Progress
                    // Placed below the card for better visibility
                    RankProgressView(userPoints: userManager.userPoints, userRank: userManager.userRank)
                        .padding(.top, -10) // Pull up slightly to connect visually
                    
                    // MARK: - 3. Stadium Ads Banner
                    StadiumAdsBanner()
                    
                    // MARK: - 4. Recommended Course
                    RecommendedCoursesView()
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Welcome, \(userManager.userName)様")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct UserRankInfoView: View {
    @EnvironmentObject var userManager: UserManager
    var body : some View {
        ZStack {
            // Card Background (Gradient for VIP look)
            RoundedRectangle(cornerRadius: 20)
                .fill(userManager.userRank.backgroundGradient.opacity(0.8))
                .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Image(systemName: "crown.fill")
                                    .foregroundStyle(userManager.userRank == .vip || userManager.userRank == .gold ? .yellow : userManager.userRank.cardContentColor)
                    Text("ランク: \(userManager.userRank.rawValue)")
                                    .font(.headline)
                                    .foregroundStyle(userManager.userRank.cardContentColor)
                    Spacer()
                    Text("V-WALK CARD")
                        .font(.caption)
                        .foregroundStyle(userManager.userRank.cardContentColor.opacity(0.8))
                }
                
                Spacer()
                
                Text("保有ポイント") // "Current Points"
                    .font(.caption)
                    .foregroundStyle(userManager.userRank.cardContentColor.opacity(0.8))
                
                HStack(alignment: .lastTextBaseline) {
                    Text("\(userManager.userPoints)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(userManager.userRank.cardContentColor)
                    Text("P")
                        .font(.title3)
                        .foregroundStyle(userManager.userRank.cardContentColor)
                }
            }
            .padding(20)
        }
    }
}

struct RankProgressView: View {
   let userPoints : Int
   let userRank : UserRank
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. Rank Info & Points Needed
            HStack {
                // Display current rank
                Text(userRank.rawValue)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(userRank.rankColor)
                
                Spacer()
                
                // Display remaining points for next rank
                if userRank != .vip {
                    let needed = userRank.nextRankPoints - userPoints
                    // "Next rank in X points"
                    Text("次のランクまであと \(needed)P")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else {
                    // "Highest Rank Reached"
                    Text("最高ランクです！")
                        .font(.caption)
                        .foregroundStyle(.purple)
                }
            }
            
            // 2. Progress Bar
            // Calculates percentage (0.0 ~ 1.0)
            ProgressView(value: UserRank.progress(currentPoints: userPoints))
                .progressViewStyle(LinearProgressViewStyle(tint:
                                                            userRank == .silver ? .blue : userRank.rankColor))
                .scaleEffect(y: 2) // Make the bar slightly thicker
                .background(userRank.progressBarTrackColor)
                .cornerRadius(4)
            
            // 3. Points Label (Current / Target)
            HStack {
                Text("\(userPoints)")
                Spacer()
                Text("\(userRank.nextRankPoints)")
            }
            .font(.caption2)
            .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.white) // Card background color
        .cornerRadius(15)
        .shadow(radius: 2) // Slight shadow for depth
        .padding(.horizontal)
    }
}


// MARK: - Stadium Ads Banner View
// Carousel style banner with navigation arrows and custom indicators.
struct StadiumAdsBanner: View {
    // Dummy data for ad banners (e.g., image names or URLs)
    let ads = ["ad_banner_1", "ad_banner_2", "ad_banner_3"]
    @State private var currentIndex = 0 // Tracks the current banner index
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header Title
            Text("🏟️ スタジアムニュース") // Stadium News
                .font(.headline)
                .padding(.horizontal)
            
            // 1. Main Banner Area (ZStack to overlay arrows)
            ZStack {
                // 2. Page View (Using TabView for carousel effect)
                TabView(selection: $currentIndex) {
                    ForEach(0..<ads.count, id: \.self) { index in
                        // Banner Content
                        Rectangle()
                            .fill(Color.blue.opacity(0.3)) // Placeholder color (replace with Image)
                            .overlay(
                                Text("広告バナー \(index + 1)") // Advertisement Banner 1, 2, 3...
                                    .font(.largeTitle)
                                    .bold()
                                    .foregroundStyle(.white)
                            )
                            .frame(height: 200) // Fixed height
                            .cornerRadius(15)
                            .padding(.horizontal) // Side padding
                            
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // Hide default dots
                .frame(height: 200) // TabView height
                
           
            }
          
        }
    }
}




// MARK: - 3. Recommended Courses View
struct RecommendedCoursesView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🚶 おすすめの散歩コース")
                .font(.headline)
            

            CourseCard(
                title: "平和公園ヒーリングコース",
                distance: "3.5km",
                time: "40分",
                color: .green
            )
            
            // Course 2
            CourseCard(
                title: "スタジアム一周コース",
                distance: "1.2km",
                time: "15分",
                color: .orange
            )
            
            // Course 3
            CourseCard(
                title: "海岸道路散歩コース",
                distance: "5.0km",
                time: "60分",
                color: .purple
            )
        }
    }
}


// Course Card Design
struct CourseCard: View {
    let title: String
    let distance: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(Image(systemName: "figure.walk").foregroundStyle(color))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                HStack {
                    Text(distance)
                    Text("•")
                    Text(time)
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 1)
    }
}

