import Foundation
import FirebaseFirestore
import Combine

class PlayerManager : ObservableObject {
    let db = Firestore.firestore()
    @Published var players: [Player] = []

    func addPlayer(player: Player) {
        // Ensure we have a non-optional ID to use as the document ID
        if let id = player.id, !id.isEmpty {
                
                try? db.collection("players").document(id).setData(from: player)
                print("Completed Player Update")
            } else {
                
                try? db.collection("players").addDocument(from: player)
                print("New Player Added")
            }
    }
    func loadPlayerDatas() {
        Task{
            let snapshot = try await db.collection("players").getDocuments()  // Load coupons data
            self.players = snapshot.documents.compactMap { doc in
                do {

                        return try doc.data(as: Player.self)
                    } catch {
                        print("⚠️ Decoding Error (Document ID: \(doc.documentID)): \(error)")
                        return nil
                    }
          
            }
        }
    }
    
}
