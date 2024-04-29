//
//  ContentView.swift
//  AnimationDemo
//


import SwiftUI

struct ContentView: View
{
    @State
    var level: Double = 0
    
    var body: some View
    {
        VStack
        {
            Spacer()
            GaugeView(level: $level)
            Spacer()
            controlsView()
            Spacer()
        }
        
    }
    
    @State
    private var enteredLevel: String = ""
    private func controlsView() -> some View
    {
        let retVal =
        VStack
        {
            Spacer()
            Text("\(String(format: "%3.1f", level))")
            
            HStack
            {
                Spacer()
                TextField("Level", text: $enteredLevel)
                    .onSubmit {
                        if let newValue = Double(enteredLevel)
                        {
                            updateLevel(newValue: newValue)
                        }
                        enteredLevel = ""
                    }
                    .padding()
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            HStack
            {
                Spacer()
                Button
                {
                    var newValue = level
                    if newValue < 10
                    {
                        newValue = (360 + level)
                    }
                    newValue -= 10
                    updateLevel(newValue: newValue)
                }label: {
                    Text("-10")
                        .font(.title)
                }
                
                Spacer()
                Text("\(String(format: "%3.1f", level))")
                    .font(.title)
                    .foregroundColor(.white)
                    .animation(nil, value: level)
                Spacer()
                
                Button
                {
                    var newValue = level
                    if newValue > 350
                    {
                        newValue = 360 - level
                    }
                    newValue += 10
                    updateLevel(newValue: newValue)
                    
                }label: {
                    Text("+10")
                        .font(.title)
                }
                Spacer()
            }
            .background(Color.white)
            
            HStack
            {
                Spacer()
                Button
                {
                    let newLevel = Double.random(in: 0 ... 360)
                    updateLevel(newValue: newLevel)
                } label: {
                    Text("Random")
                        .font(.title)
                }
                Spacer()
            }
        }
        return retVal
    }
    
    private func updateLevel(newValue: Double)
    {
        level = newValue
    }
}

#Preview
{
    ContentView()
}

