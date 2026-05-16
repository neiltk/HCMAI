//
//  AddRaagView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI

struct AddRaagView: View {
    @Environment(\.dismiss) var dismiss
    
    // We pass the existing ViewModel in so we can use its 'addRaag' function
    @ObservedObject var viewModel: LearnViewModel
    
    // Form State Variables
    @State private var name = ""
    @State private var thaat = "Bhairav"
    @State private var jati = "Sampurna"
    @State private var timeOfDay = "Morning"
    @State private var prahar = 1
    @State private var description = ""
    @State private var isPublished = false // Default to false so you can draft it safely
    
    // Picker Options
    let thaats = ["Bilawal", "Kalyan", "Khamaj", "Bhairav", "Marwa", "Kafi", "Asavari", "Bhairavi", "Todi", "Purvi"]
    let jatis = ["Audav-Audav", "Shadav-Shadav", "Sampurna", "Audav-Sampurna", "Shadav-Sampurna", "Audav-Shadav"]
    let times = ["Morning", "Afternoon", "Evening", "Night"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Details")) {
                    TextField("Raag Name (e.g., Bhairav)", text: $name)
                    
                    Picker("Thaat", selection: $thaat) {
                        ForEach(thaats, id: \.self) { Text($0) }
                    }
                    
                    Picker("Jati", selection: $jati) {
                        ForEach(jatis, id: \.self) { Text($0) }
                    }
                }
                
                Section(header: Text("Timing")) {
                    Picker("Time of Day", selection: $timeOfDay) {
                        ForEach(times, id: \.self) { Text($0) }
                    }
                    
                    Stepper(value: $prahar, in: 1...8) {
                        Text("Prahar: \(prahar)")
                    }
                }
                
                Section(header: Text("Description & Mood")) {
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section(header: Text("Visibility"), footer: Text("If unpublished, this Raag will not appear to standard users.")) {
                    Toggle("Publish to Directory", isOn: $isPublished)
                }
            }
            .navigationTitle("New Raag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // 1. Fire the data to Firebase
                        viewModel.addRaag(name: name, thaat: thaat, jati: jati, timeOfDay: timeOfDay, prahar: prahar, description: description, isPublished: isPublished)
                        // 2. Close the sheet
                        dismiss()
                    }
                    .disabled(name.isEmpty) // Prevent saving if the name is blank!
                    .bold()
                }
            }
        }
    }
}