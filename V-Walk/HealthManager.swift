//
//  HealthManager.swift
//  V-Walk
//
//  Created by 강효민 on 11/29/25.
//


import HealthKit
import Combine

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var stepCount: Int = 0
    
    init() {
        requestAuthorization()
    }
    
    // 1. 권한 요청
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let typesToRead: Set = [stepType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.fetchTodayStepCount() // 권한 받자마자 오늘 걸음 수 가져오기
            }
        }
    }
    
    // 2. 오늘 걸음 수 가져오기
    func fetchTodayStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            
            DispatchQueue.main.async {
                // 'count' 단위로 변환해서 Int로 저장
                self.stepCount = Int(sum.doubleValue(for: HKUnit.count()))
            }
        }
        
        healthStore.execute(query)
    }
}
