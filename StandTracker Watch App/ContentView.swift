import SwiftUI

struct ContentView: View {
    @State private var showWelcomeScreen: Bool = !UserDefaults.standard.bool(forKey: "welcomeScreenShown")
    @State private var weight: Double = UserDefaults.standard.double(forKey: "userWeight")
    
    var body: some View {
        if showWelcomeScreen {
            WeightInput(weight: $weight, showWelcomeScreen: $showWelcomeScreen)
        } else {
            NavigationView {
                List {
                    NavigationLink(destination: StandRecorder()) {
                        VStack(alignment: .leading) {
                            Text("Begin Standing Session")
                                .font(.headline)
                        }
                    }
                    NavigationLink(destination: WeightInput(weight: $weight, showWelcomeScreen: $showWelcomeScreen)) {
                        VStack(alignment: .leading) {
                            Text("Update my weight")
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Main Menu")
            }
        }
    }
}

struct WeightInput: View {
    @Environment(\.dismiss) var dismiss
    @Binding var weight: Double
    @Binding var showWelcomeScreen: Bool

    // Define the weight range as an array of Doubles
    private let weightRange: [Double] = Array(stride(from: 30.0, through: 150.0, by: 1.0))

    var body: some View {
        VStack {
            Text("To correctly track calories")
                .font(.headline)
                .minimumScaleFactor(0.8)
                .lineLimit(1)
            Text("please input your")
                .font(.headline)
                .minimumScaleFactor(0.9)
                .lineLimit(1)

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
        dismiss()
        
        print("Saved weight: \(weight)")
    }
}

#Preview {
    ContentView()
}
