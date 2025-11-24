//
//  LocationManager.swift
//  HealthTest
//
//  Created by 강효민 on 11/29/25.
//


// LocationManager.swift
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var manager = CLLocationManager()
    
    // Current Location
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // 1. Location Permission Request
        manager.startUpdatingLocation()         // 2. Location Traking Start
    }
    
    // Function that is called every time the location is updated
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location // Save Current Location
    }
}
