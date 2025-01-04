//
//  ContentView.swift
//  StandTracker Watch App
//
//  Created by Ruslan Melnichuk on 3/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ScreenOne()) {
                    VStack(alignment: .leading) {
                        Text("Begin Standing Session")
                            .font(.headline)
                    }
                }
                NavigationLink(destination: ScreenTwo()) {
                    VStack(alignment: .leading) {
                        Text("Standing Sessions History")
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Main Menu")
        }
    }
}

#Preview {
    ContentView()
}
