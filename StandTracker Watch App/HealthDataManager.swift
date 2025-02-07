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
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let basalEnergyType = HKQuantityType.quantityType(forIdentifier: .basalEnergyBurned)!
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Request authorization to read body weight, active energy and basal energy
        healthKitStore.requestAuthorization(toShare: nil, read: [weightType, activeEnergyType, basalEnergyType]) { (success, error) in
            if success {
                print("Authorization granted for HealthKit.")
            } else {
                print("Authorization failed with error: \(String(describing: error))")
            }
            completion(success, error)
        }
    }
    
    func getCaloriesBurnedLastHour(timeElapsed: Double, completion: @escaping (Double?, Error?) -> Void) {
        print("hi", timeElapsed)
        let now = Date()
        let oneHourAgo = now.addingTimeInterval(-timeElapsed)
        
        // Predicate to get samples in the last hour
        let predicate = HKQuery.predicateForSamples(withStart: oneHourAgo, end: now, options: .strictStartDate)
        
        // Create a dispatch group to manage multiple queries
        let dispatchGroup = DispatchGroup()
        
        var totalBasalEnergy: Double = 0
        var totalActiveEnergy: Double = 0
        var queryError: Error?

        // Fetch basal energy burned
        dispatchGroup.enter() // Start basal energy query
        let basalEnergyQuery = HKSampleQuery(sampleType: basalEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                queryError = error
            } else if let samples = samples as? [HKQuantitySample] {
                totalBasalEnergy = samples.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            }
            dispatchGroup.leave() // End basal energy query
        }
        
        // Fetch active energy burned
        dispatchGroup.enter() // Start active energy query
        let activeEnergyQuery = HKSampleQuery(sampleType: activeEnergyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            if let error = error {
                queryError = error
            } else if let samples = samples as? [HKQuantitySample] {
                totalActiveEnergy = samples.reduce(0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            }
            dispatchGroup.leave() // End active energy query
        }
        
        // Execute the queries
        healthKitStore.execute(basalEnergyQuery)
        healthKitStore.execute(activeEnergyQuery)
        
        // Notify completion once both queries are finished
        dispatchGroup.notify(queue: .main) {
            if let error = queryError {
                completion(nil, error)
            } else {
                let totalEnergyBurned = totalBasalEnergy + totalActiveEnergy
                completion(totalEnergyBurned, nil)
            }
        }
    }
}

