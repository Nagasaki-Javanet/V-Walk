import SwiftUI
import MapKit
import CoreLocation

struct NavigationMapView: View {
    @EnvironmentObject var routeSelection: RouteSelection
    @EnvironmentObject var userManager: UserManager
    @State var checkpoints: [Checkpoint] = []
    // MARK: - Properties
    @StateObject var locationManager = LocationManager()
    @StateObject var routeManager = RouteManager()
    

    
    // マップカメラ位置
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    // 計測用状態変数
    @State private var isRunning = false     // 計測中かどうか
    @State private var elapsedTime: TimeInterval = 0 // 経過時間
    @State private var timer: Timer? = nil

    // MARK: - Body
    var body: some View {
        ZStack {
            // ------------------------------------------------
            // 1. マップレイヤー
            // ------------------------------------------------
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                // チェックポイントマーカー
                ForEach(checkpoints) { point in
                    Annotation(point.name, coordinate: point.coordinate) {
                        Image(systemName: point.isVisited ? "flag.checkered.circle.fill" : "flag.circle.fill")
                            .resizable()
                            .foregroundStyle(point.isVisited ? .green : .red)
                            .frame(width: 30, height: 30)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                
                // 通過済みルート (グレー)
                // 実際に移動した軌跡がここに描画されます
                if routeManager.passedCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeManager.passedCoordinates)
                        .stroke(.gray, lineWidth: 5)
                }
                
                // 残りのルート (青)
                if routeManager.remainingCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeManager.remainingCoordinates)
                        .stroke(.blue, lineWidth: 5)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea(.all)
            .onAppear {
                checkpoints = routeSelection.selectedCheckpoints
                routeManager.fetchFullRoute(checkpoints: checkpoints)
            }
            .onChange(of: locationManager.userLocation) { newLocation in
                guard let userLoc = newLocation else { return }
                
                // 常に現在地の更新は行う（カーソル表示のため）
                routeManager.updateUserLocation(userLoc)
                
                // ✅ 計測中(isRunning)の場合のみ、距離計算用に座標を記録する
                if isRunning {
                    // 拡張機能に追加したメソッドで座標を保存
                    routeManager.appendPassedLocation(userLoc)
                    
                    // 到着判定
                    checkArrival(userLocation: userLoc)
                    if checkAllArrived() {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        userManager.updateUserPoints(points: Int(0.1*routeManager.caloriesBurned))
                    }
                }
            }
            
            // ------------------------------------------------
            // 2. UI オーバーレイレイヤー
            // ------------------------------------------------
            VStack {
                // 上部：データ表示 (Dashboard)
                DashboardView
                    .padding(.top, 60)
                
                Spacer()
                
                // 下部：コントロールボタン
                ControlButtons
                    .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Subviews (UI Components)
    
    /// 上部のデータ表示パネル
    var DashboardView: some View {
        HStack(spacing: 20) {
            // TIME
            DataCell(
                title: "TIME",
                value: routeManager.formattedTime(elapsedTime),
                fontDesign: .monospaced
            )
            
            Divider().frame(height: 30)
            
            // DISTANCE
            DataCell(
                title: "DIST (km)",
                value: String(format: "%.2f", routeManager.totalDistance / 1000),
                fontDesign: .rounded
            )
            
            Divider().frame(height: 30)
            
            // CALORIES
            DataCell(
                title: "KCAL",
                value: String(format: "%.0f", routeManager.caloriesBurned),
                fontDesign: .rounded
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
    
    func DataCell(title: String, value: String, fontDesign: Font.Design) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.title3, design: fontDesign))
                .fontWeight(.bold)
                .contentTransition(.numericText(value: 1.0))
        }
        .frame(minWidth: 70)
    }

    /// 下部の操作ボタン群
    var ControlButtons: some View {
        HStack(spacing: 12) {
            // START
            Button(action: startTracking) {
                Label("Start", systemImage: "play.fill")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(isRunning ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isRunning)
            
            // PAUSE
            Button(action: stopTracking) {
                Label("Pause", systemImage: "pause.fill")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            // RESET
            Button(action: resetTracking) {
                Label("Reset", systemImage: "arrow.counterclockwise")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
    
    // MARK: - Logic Functions
    
    /// 計測開始
    func startTracking() {
        routeManager.startDemo()
        // ✅ 修正: デモモード(routeManager.startDemo())は呼ばない
        // これにより、自動ではなく実際のGPS移動のみをカウントします
        isRunning = true
        
        // タイマー開始
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedTime += 1
            }
        }
    }
    
    /// 計測一時停止
    func stopTracking() {
        routeManager.stopDemo()
        isRunning = false
        // routeManager.stopDemo() // デモを使っていないので不要ですが、呼んでも害はありません
        
        timer?.invalidate()
        timer = nil
    }
    
    /// 計測リセット
    func resetTracking() {
        routeManager.resetDemo()
        stopTracking()
        elapsedTime = 0
        
        // 記録した移動履歴（passedCoordinates）をクリアする処理が必要ならここに追加
        // routeManager.passedCoordinates.removeAll() // プロパティが操作可能であれば
        
        // チェックポイントリセット
        for i in checkpoints.indices {
            checkpoints[i].isVisited = false
        }
    }
    
    func checkArrival(userLocation: CLLocation) {
        for index in checkpoints.indices {
            if checkpoints[index].isVisited { continue }
            
            let targetLoc = CLLocation(
                latitude: checkpoints[index].coordinate.latitude,
                longitude: checkpoints[index].coordinate.longitude
            )
            
            let distance = userLocation.distance(from: targetLoc)
            
            if distance < 20.0 {
                checkpoints[index].isVisited = true
                print("🎉 \(checkpoints[index].name) arrived!")
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
            }
        }
    }
    func checkAllArrived() -> Bool {
        checkpoints.allSatisfy(\.isVisited)
    }
}

// MARK: - RouteManager Extensions

extension RouteManager {
    
    // ✅ 追加: 実際のGPS座標をルート履歴に追加するメソッド
    func appendPassedLocation(_ location: CLLocation) {
        // 直前の位置からある程度(例: 5m)離れている場合のみ追加するとデータの肥大化を防げます
        let newCoord = location.coordinate
        
        // 重複チェックなどは必要に応じて実装してください
        // ここでは単純に追加します
        passedCoordinates.append(newCoord)
    }
    
    /// 走行距離 (メートル) の計算
    /// passedCoordinates に蓄積された座標間の距離を合算します
    var totalDistance: Double {
        guard passedCoordinates.count > 1 else { return 0 }
        var dist: Double = 0
        
        for i in 0..<passedCoordinates.count - 1 {
            let loc1 = CLLocation(latitude: passedCoordinates[i].latitude, longitude: passedCoordinates[i].longitude)
            let loc2 = CLLocation(latitude: passedCoordinates[i+1].latitude, longitude: passedCoordinates[i+1].longitude)
            dist += loc1.distance(from: loc2)
        }
        return dist
    }
    
    /// 消費カロリー (kcal) の簡易計算
    var caloriesBurned: Double {
        let distanceKm = totalDistance / 1000.0
        let weightKg = 60.0
        return distanceKm * weightKg * 1.036
    }
    
    /// 時間フォーマット
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
}
