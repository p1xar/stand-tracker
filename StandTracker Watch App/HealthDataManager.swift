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
    private let workoutType = HKObjectType.workoutType()
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        // Request authorization to read body weight, active energy and basal energy
        healthKitStore.requestAuthorization(toShare: [workoutType, activeEnergyType], read: [weightType, activeEnergyType, basalEnergyType, workoutType]) { (success, error) in
            if success {
                print("Authorization granted for HealthKit.")
            } else {
                print("Authorization failed with error: \(String(describing: error))")
            }
            completion(success, error)
        }
    }
    
    func recordCustomWorkout(calories: Double, duration: TimeInterval) {
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-duration)
        
        print("startDate: \(startDate), endDate: \(endDate)")

        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .unknown

        let builder = HKWorkoutBuilder(healthStore: healthKitStore, configuration: workoutConfiguration, device: .local())

        builder.beginCollection(withStart: startDate) { success, error in
            guard success else {
                print("Error starting workout collection: \(String(describing: error?.localizedDescription))")
                return
            }

            let energyQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: calories)
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            let energySample = HKCumulativeQuantitySample(type: energyType, quantity: energyQuantity, start: startDate, end: endDate)

            builder.add([energySample]) { success, error in
                guard success else {
                    print("Error adding energy sample: \(String(describing: error?.localizedDescription))")
                    return
                }

                builder.endCollection(withEnd: endDate) { success, error in
                    guard success else {
                        print("Error ending workout collection: \(String(describing: error?.localizedDescription))")
                        return
                    }

                    builder.finishWorkout { workout, error in
                        if let workout = workout {
                            print("Workout saved successfully: \(workout)")
                        } else {
                            print("Error finishing workout: \(String(describing: error?.localizedDescription))")
                        }
                    }
                }
            }
        }
    }
}

