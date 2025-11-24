//
//  Health.swift
//  V-Walk
//
//  Created by 강효민 on 11/29/25.
//

import SwiftUI

struct Health: View {
    @StateObject var healthManager = HealthManager()
    
    var body: some View {
        VStack() {
            Text("\(healthManager.stepCount)")
        }
        .onAppear(){
            healthManager.fetchTodayStepCount()
        }
    }
        
}

