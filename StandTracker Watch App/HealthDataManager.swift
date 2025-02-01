//
//  HealthDataManager.swift
//  StandTracker Watch App
//
//  Created by Ruslan Melnichuk on 6/1/25.
//

import Foundation
import HealthKit

class HealthDataManager {
    private let healthKitStore = HKHealthStore()
    private let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    private let activityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Request authorization to read body weight
        healthKitStore.requestAuthorization(toShare: nil, read: [weightType, activityType]) { (success, error) in
            if success {
                print("Authorization granted for HealthKit.")
            } else {
                print("Authorization failed with error: \(String(describing: error))")
            }
            completion(success, error)
        }
    }
    
    func fetchCaloriesBurnedLastHour(completion: @escaping (Double?, Error?) -> Void) {
            let now = Date()
            let oneHourAgo = now.addingTimeInterval(-3600)  // 1 hour ago
            
            // Predicate to get activities in the last hour
            let predicate = HKQuery.predicateForSamples(withStart: oneHourAgo, end: now, options: .strictStartDate)
            
            // Query to fetch calories burned during activity
            let query = HKSampleQuery(sampleType: activityType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                var totalCaloriesBurned: Double = 0
                if let samples = samples as? [HKQuantitySample] {
                    for sample in samples {
                        totalCaloriesBurned += sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                    }
                }
                completion(totalCaloriesBurned, nil)
            }
            healthKitStore.execute(query)
        }


}
