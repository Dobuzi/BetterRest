//
//  ContentView.swift
//  BetterRest
//
//  Created by 김종원 on 2020/10/20.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var sleepTime: String {
        return calculateBedtime()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("the ideal bed time")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                ) {
                    HStack {
                        Spacer()
                        Image(systemName: "moon.zzz.fill")
                        Spacer()
                        Text("\(sleepTime)")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .font(.title3)
                    .foregroundColor(.accentColor)
                }
                Section(
                    header: Text("When do you want to wake up?")
                        .font(.subheadline)
                ) {
                    DatePicker(
                        "Please enter a date",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                }
                Section(
                    header: Text("Desired amout of sleep")
                        .font(.subheadline)
                ) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    .accessibility(value: Text("\(sleepAmount, specifier: "%g") hours"))
                }
                Section(
                    header: Text("Daily coffee intake: ")
                        .font(.subheadline)
                ) {
                    Text("\(coffeeAmount) cup\(coffeeAmount < 2 ? "" : "s")")
                    Picker(
                        selection: $coffeeAmount,
                        label: Text("")
                    ) {
                        ForEach(1..<22) { i in
                            Text("\(i-1)").tag(i)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
            }
            .alert(isPresented: $showingAlert, content: {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })
            .padding()
            .navigationBarTitle("Better Rest")
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime() -> String {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime"
            showingAlert = true
            return ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
