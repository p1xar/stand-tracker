//
//  StandRecorder.swift
//  StandTracker Watch App
//
//  Created by Ruslan Melnichuk on 4/1/25.
//

import SwiftUI

struct StandRecorder: View {
    @State private var timeElapsed: Int = 3600
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var showConfirmation = false
    @State private var showAlert = false
    var healthKitDataManager = HealthDataManager()
    
    var body: some View {
        VStack(alignment: .center) {
            Text(formatTime(timeElapsed))
                .frame(width: 200)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            
            HStack {
                Button(action: {
                    startTimer()
                }) {
                    Text(isRunning ? "Pause" : "Start")
                }
                .buttonStyle(BorderedButtonStyle(tint: isRunning ? Color.mint : Color.green))
                
                Button(action: {
                    resetTimer()
                }) {
                    Text("Reset")
                        .foregroundColor(.white)
                }
                .buttonStyle(BorderedButtonStyle(tint: Color.gray))
            }
            
            Button(action: {
                showAlert = true
            }) {
                Text("End")
            }
            .buttonStyle(BorderedButtonStyle(tint: Color.red))
            .disabled(!isRunning)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Do you want to finish standing session and record a workout?"),
                    primaryButton: .default(Text("Yes")) {
                        endWorkout()
                    },
                    secondaryButton: .cancel()
                )
            }
            
        }
        .navigationTitle("Tracking")
    }
    
    private func startTimer() {
        if isRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                timeElapsed += 1
            }
        }
        isRunning.toggle()
    }
    
    private func resetTimer() {
        if timeElapsed > 0 {
            timeElapsed = 0
            timer?.invalidate()
            if isRunning {
                isRunning.toggle()
            }
        }
    }
    
    private func endWorkout() {
        // 1.5 is a MET for standing, 0.0175 is a constant converts MET values and body weight to calories burned per minute
        let userWeight = UserDefaults.standard.double(forKey: "userWeight")
        let caloriesPerMinute = 1.5 * userWeight * 0.0175
        let minutes = timeElapsed / 60
        let totalStandingCaloriesBurnt = caloriesPerMinute * Double(minutes)
        healthKitDataManager.requestAuthorization { (success, error) in
            if success {
                healthKitDataManager.getCaloriesBurnedLastHour(timeElapsed: Double(timeElapsed)) { (totalEnergyBurnt, error) in
                    if let error = error {
                        print("Error calculating calories burned: \(error.localizedDescription)")
                    } else if let totalEnergyBurnt = totalEnergyBurnt {
                        print("Total calories burned in the last hour: \(totalEnergyBurnt) kcal")
                        let caloriesToRecord = totalStandingCaloriesBurnt - totalEnergyBurnt
                        print("sub", caloriesToRecord)
                    }
                }
                
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
//        resetTimer()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}



