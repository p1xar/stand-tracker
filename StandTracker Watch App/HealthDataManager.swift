//
//  HealthDataManager.swift
//  StandTracker Watch App
//
//  Created by Ruslan Melnichuk on 6/1/25.
//

import Foundation
import HealthKit

class HealthDataManager {
    let healthKitStore = HKHealthStore()
    let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    
    func test() {
        fetchWeightData()
    }
    
    func requestAuthToHealthKit() {
        healthKitStore.requestAuthorization(toShare: nil, read: [weightType]) { (success, error) in
            if success {
                print("Authorization granted")
            } else {
                print("Authorization failed with error: \(String(describing: error))")
            }
        }
    }
    
    func fetchWeightData() {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            if let sample = samples?.first as? HKQuantitySample {
                let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                print("Latest weight: \(weightInKilograms) kg")
            } else {
                print("Error fetching weight data: \(String(describing: error))")
            }
        }
        healthKitStore.execute(query)
    }

}
