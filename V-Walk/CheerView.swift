import SwiftUI
import FirebaseFirestore

struct CheerView: View {
    @EnvironmentObject var playerManager : PlayerManager // Data fetcher
    @EnvironmentObject var userManager: UserManager // To access user's choice
    @State private var selectedTab = 0 // 0: Select, 1: Ranking
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - Top Segmented Control
                Picker("Menu", selection: $selectedTab) {
                    Text("選手選択").tag(0) // Player Selection
                    Text("ランキング").tag(1) // Ranking
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // MARK: - Content Area
                if selectedTab == 0 {
                    PlayerSelectionView()
                        .environmentObject(playerManager)
                        .onAppear {
                            playerManager.loadPlayerDatas()
                        }
                } else {
                    RankingListView()
                        .environmentObject(playerManager)
                        .onAppear(){
                            playerManager.loadPlayerDatas()
                        }
                }
            }
            .navigationTitle("応援しよう！") // Let's Cheer!
            .onAppear {
                playerManager.loadPlayerDatas() // Fetch fresh data
            }
        }
        .refreshable {
            playerManager.loadPlayerDatas()
        }
    }
}

// MARK: - Subview: Player Selection
struct PlayerSelectionView: View {
    @EnvironmentObject var playerManager : PlayerManager
    @EnvironmentObject var userManager: UserManager
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 2 columns
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(playerManager.players) { player in
                    PlayerCard(player: player, isSelected: userManager.selectedPlayerID == player.id)
                        .onTapGesture {
                            // Change support player logic
                            guard let playerId = player.id, !playerId.isEmpty else {
                                    print("❌ error:  Can't get player ID.")
                                    return
                                }
                            Task {
                                userManager.changeSupportPlayer(
                                    from: userManager.selectedPlayerID,
                                    to: playerId
                                )
                            }
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Subview: Ranking List


struct RankingListView: View {
    @EnvironmentObject var playerManager : PlayerManager

    var sortedPlayers: [Player] {
        playerManager.players.sorted { (a: Player, b: Player) in
            a.totalPoints > b.totalPoints
        }
    }
    
    var body: some View {
        List {
            ForEach(Array(sortedPlayers.enumerated()), id: \.offset) { (index, player) in
                HStack {
                    // Rank Number
                    Text("\(index + 1)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(index < 3 ? .red : .gray)
                        .frame(width: 30)
                    
                    AsyncImage(url: URL(string: player.playerImageURL ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading) {
                        Text(player.name)
                            .font(.headline)
                        Text(player.team)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Text("\(player.totalPoints) P")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.blue)
                }
                .padding(.vertical, 4)
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - UI Component: Player Card
struct PlayerCard: View {
    let player: Player
    let isSelected: Bool
    
    var body: some View {
        VStack {
            // Player Image
            AsyncImage(url: URL(string: player.playerImageURL ??  "")) { image in
                image.resizable()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .scaledToFill()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
            )
            .shadow(radius: 3)
            
            // Name
            Text(player.name)
                .font(.headline)
                .lineLimit(1)
            
            // Position / Team
            Text("\(player.position) | \(player.team)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            if isSelected {
                Text("応援中") // Supporting
                    .font(.caption)
                    .bold()
                    .padding(4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundStyle(.blue)
                    .cornerRadius(4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

