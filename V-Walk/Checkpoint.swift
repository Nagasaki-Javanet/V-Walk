//
//  Checkpoint.swift
//  HealthTest
//
//  Created by 강효민 on 11/29/25.
//


// Checkpoint.swift
import CoreLocation

struct Checkpoint: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    var isVisited: Bool = false
}

let sampleCheckpoints = [
    Checkpoint(name: "始点: 長崎スタジアムシティ", coordinate: CLLocationCoordinate2D(latitude: 32.7596, longitude: 129.8647)),
    Checkpoint(name: "チェクポイント１: 水辺の森", coordinate: CLLocationCoordinate2D(latitude: 32.7398, longitude: 129.8738)),
    Checkpoint(name: "チェクポイント２：シーボルト記念館", coordinate: CLLocationCoordinate2D(latitude: 32.7491909, longitude: 129.8823076)),
    Checkpoint(name: "終点: 浦上天主堂", coordinate: CLLocationCoordinate2D(latitude: 32.7596, longitude: 129.8647))
]
