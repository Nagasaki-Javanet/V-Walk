import MapKit
import Combine

class RouteManager: ObservableObject {
    @Published var routes: [MKRoute] = []
    @Published var passedCoordinates: [CLLocationCoordinate2D] = [] // Passed route coordinates
    @Published var remainingCoordinates: [CLLocationCoordinate2D] = [] // Remaining route coordinates

    @Published var demoUserLocation: CLLocationCoordinate2D? // Demo user location
    private var demoTimer: Timer? // Timer for demo mode
    private var demoIndex: Int = 0 // Current demo index
    
    private var fullRouteCoordinates: [CLLocationCoordinate2D] = [] // All route coordinates
    private var currentProgressIndex: Int = 0 // Current progress index (prevents going backward)
    
    // Fetch full route from checkpoints
    func fetchFullRoute(checkpoints: [Checkpoint]) {
        print(checkpoints.count)
        guard checkpoints.count >= 2 else {
            routes = []
            fullRouteCoordinates = []
            passedCoordinates = []
            remainingCoordinates = []
            currentProgressIndex = 0
            demoUserLocation = nil
            demoIndex = 0
            stopDemo()
            return
        }
        
        // Use dictionary to maintain order
        var routeDict: [Int: MKRoute] = [:]
        let group = DispatchGroup()
        
        for i in 0..<(checkpoints.count - 1) {
            group.enter()
            
            let start = checkpoints[i].coordinate
            let end = checkpoints[i+1].coordinate
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
            request.transportType = .walking
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let route = response?.routes.first {
                    // Store with index to maintain order
                    routeDict[i] = route
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Sort by index and convert to array
            self.routes = routeDict.keys.sorted().compactMap { routeDict[$0] }
            self.extractFullRouteCoordinates()
        }
    }
    
    // Extract all coordinates from routes into a single array
    private func extractFullRouteCoordinates() {
        fullRouteCoordinates = []
        
        for route in routes {
            let pointCount = route.polyline.pointCount
            let points = route.polyline.points()
            
            for i in 0..<pointCount {
                let coord = points[i].coordinate
                
                // Skip duplicate coordinates at connection points
                if let last = fullRouteCoordinates.last,
                   last.latitude == coord.latitude && last.longitude == coord.longitude {
                    continue
                }
                fullRouteCoordinates.append(coord)
            }
        }
        
        remainingCoordinates = fullRouteCoordinates
        currentProgressIndex = 0 // Reset progress
        print("✅ Total route coordinates: \(fullRouteCoordinates.count)")
    }
    
    // Update user location and split route into passed/remaining
    func updateUserLocation(_ userLocation: CLLocation) {
        guard !fullRouteCoordinates.isEmpty else { return }
        
        // Search only forward from current position (prevents jumping back on overlapping routes)
        let searchRange = 50 // Search within next 50 coordinates
        let searchStart = currentProgressIndex
        let searchEnd = min(currentProgressIndex + searchRange, fullRouteCoordinates.count)
        
        var minDistance = Double.infinity
        var closestIndex = currentProgressIndex
        
        // Find closest point within search range
        for index in searchStart..<searchEnd {
            let coord = fullRouteCoordinates[index]
            let routePoint = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = userLocation.distance(from: routePoint)
            
            if distance < minDistance {
                minDistance = distance
                closestIndex = index
            }
        }
        
        // Only update progress if within acceptable distance (prevents route deviation issues)
        if minDistance < 50 {
            currentProgressIndex = closestIndex
        }
        
        // Split route: passed (gray) and remaining (blue)
        passedCoordinates = Array(fullRouteCoordinates.prefix(currentProgressIndex + 1))
        remainingCoordinates = Array(fullRouteCoordinates.suffix(from: currentProgressIndex))
    }
    
    // Start demo mode - automatically move along the route
    func startDemo() {
        guard !fullRouteCoordinates.isEmpty else {
            print("⚠️ No route available")
            return
        }
        
        demoTimer?.invalidate()
        
        // Move to next coordinate every 0.3 seconds
        demoTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.demoIndex < self.fullRouteCoordinates.count {
                let coord = self.fullRouteCoordinates[self.demoIndex]
                self.demoUserLocation = coord
                
                // Directly set progress index for demo (bypasses search logic)
                self.currentProgressIndex = self.demoIndex
                self.passedCoordinates = Array(self.fullRouteCoordinates.prefix(self.demoIndex + 1))
                self.remainingCoordinates = Array(self.fullRouteCoordinates.suffix(from: self.demoIndex))
                
                self.demoIndex += 1
                print("📍 Demo progress: \(self.demoIndex)/\(self.fullRouteCoordinates.count)")
            } else {
                self.stopDemo()
                print("🏁 Demo completed!")
            }
        }
    }
    
    // Stop demo mode
    func stopDemo() {
        demoTimer?.invalidate()
        demoTimer = nil
    }
    
    // Reset demo to initial state
    func resetDemo() {
        stopDemo()
        demoIndex = 0
        currentProgressIndex = 0 // Reset progress index
        demoUserLocation = fullRouteCoordinates.first
        passedCoordinates = []
        remainingCoordinates = fullRouteCoordinates
    }
}
