//
//  StandRecorder.swift
//  StandTracker Watch App
//
//  Created by Ruslan Melnichuk on 4/1/25.
//

import SwiftUI

struct StandRecorder: View {
    @State private var timeElapsed: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Start tracking \nstanding time & calories")
                .frame(width: 200)
                .multilineTextAlignment(.center)
            
            Text(formatTime(timeElapsed))
                .frame(width: 200)
                .font(.largeTitle)
                .multilineTextAlignment(.center)
                
            HStack {
                Button(action: {
                    startStopwatch()
                }) {
                    Text(isRunning ? "Pause" : "Start")
                }
                    .background(isRunning ? Color.orange : Color.green)
                    .cornerRadius(10)
                
                Button(action: {

                }) {
                    Text("Reset")
                }
                .background(Color.red)
                .cornerRadius(10)
            }

        }
    }
    
    private func startStopwatch() {
        if isRunning {
            timer?.invalidate()
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                timeElapsed += 1
            }
        }
        isRunning.toggle()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
