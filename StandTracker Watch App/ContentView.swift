import SwiftUI

struct ContentView: View {
    @State private var showWelcomeScreen: Bool = !UserDefaults.standard.bool(forKey: "welcomeScreenShown")
    @State private var weight: Double = UserDefaults.standard.double(forKey: "userWeight")
    
    var body: some View {
        if showWelcomeScreen {
            WelcomeScreen(weight: $weight, showWelcomeScreen: $showWelcomeScreen)
        } else {
            NavigationView {
                List {
                    NavigationLink(destination: StandRecorder()) {
                        VStack(alignment: .leading) {
                            Text("Begin Standing Session")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: StandHistory()) {
                        VStack(alignment: .leading) {
                            Text("History")
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Main Menu")
            }
        }
    }
}

struct WelcomeScreen: View {
    @Binding var weight: Double
    @Binding var showWelcomeScreen: Bool

    // Define the weight range as an array of Doubles
    private let weightRange: [Double] = Array(stride(from: 30.0, through: 150.0, by: 1.0))

    var body: some View {
        VStack {
            Text("Welcome to the StandTracker!")
                .font(.title)
                .padding()

            Text("Please input your weight:")
                .font(.headline)

            // Picker for selecting weight
            Picker("Weight", selection: $weight) {
                ForEach(weightRange, id: \.self) { value in
                    Text("\(Int(value)) kg")
                        .font(.body)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 80) 

            Button(action: {
                saveWeight()
            }) {
                Text("Save")
            }
        }
        .padding()
    }

    private func saveWeight() {
        // Save weight to UserDefaults
        UserDefaults.standard.set(weight, forKey: "userWeight")
        
        // Mark welcome screen as shown
        UserDefaults.standard.set(true, forKey: "welcomeScreenShown")
        
        // Dismiss the welcome screen
        showWelcomeScreen = false
        
        // Debug print
        print("Saved weight: \(weight)")
    }
}

#Preview {
    ContentView()
}
