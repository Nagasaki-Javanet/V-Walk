import SwiftUI
import FirebaseAuth

struct UserView: View {
    // Observe UserManager for dynamic data (Name, Points)
    @EnvironmentObject var userManager : UserManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - 1. Profile Section (Photo, Name, Email)
                    VStack(spacing: 10) {
                        // Profile Image (Placeholder)
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(.gray)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                        
                        // User Name
                        Text(userManager.userName.isEmpty ? "ゲスト" : userManager.userName)
                            .font(.title2)
                            .bold()
                        
                        // User Email (Get from Firebase Auth)
                        if let email = Auth.auth().currentUser?.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.top)
                    
              
                    // MARK: - 2. Coupons (Discount Tickets)
                    VStack(alignment: .leading) {
                        Text("保有クーポン") // "My Coupons"
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if userManager.coupons.isEmpty {
                            // Case: No Coupons
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "ticket")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray.opacity(0.5))
                                    Text("利用可能なクーポンはありません") // "No available coupons"
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(height: 100)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(userManager.coupons) { coupon in
                                        CouponCard(title: coupon.title, expiry: coupon.expiryString)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: - 3. Payment History
                    VStack(alignment: .leading, spacing: 15) {
                        Text("長崎スタジアムシティ 決済履歴") // "Payment History"
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if userManager.paymentHistory.isEmpty {
                            Text("まだ履歴がありません") // "No history yet"
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        } else {
                            VStack(spacing: 0) {
                                ForEach(userManager.paymentHistory) { history in
                                    HistoryRow(date: history.dateString, item: history.itemName, price: history.priceString)
                                    Divider() // Add divider for better readability
                                }
                            }
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }

                    // MARK: - 4. Completed Courses
                    VStack(alignment: .leading, spacing: 15) {
                        Text("完了したコース") // "Completed Courses"
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if userManager.completedCourses.isEmpty {
                            // Case: No Completed Courses
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "flag.slash")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray.opacity(0.5))
                                    Text("完了したコースはまだありません") // "No completed courses yet"
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .frame(height: 100)
                            .background(Color(uiColor: .secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(userManager.completedCourses) { course in
                                    CourseRow(title: course.courseTitle, date: course.dateString)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .navigationTitle("マイページ") // "My Page"
            .navigationBarTitleDisplayMode(.inline)
            .refreshable {
                userManager.loadUserData()
            }
            .onAppear {
                userManager.loadUserData()
            }
            
        }
    }
}



// MARK: - Helper Views (Components)

// Coupon Card Component
struct CouponCard: View {
    let title: String
    let expiry: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .bold()
                .lineLimit(2)
            Spacer()
            Text("有効期限: \(expiry)") // "Expiry Date"
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .padding()
        .frame(width: 160, height: 100)
        .background(Color.orange.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 1, dash: [5]))
        )
        .cornerRadius(12)
    }
}

// Payment History Row Component
struct HistoryRow: View {
    let date: String
    let item: String
    let price: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item)
                    .font(.subheadline)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Text(price)
                .font(.subheadline)
                .bold()
        }
        .padding()
    }
}

// Completed Course Row Component
struct CourseRow: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(.green)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}


