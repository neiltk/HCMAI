//
//  AddTopicView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI
import UniformTypeIdentifiers // Required to filter for audio files!

struct AddTopicView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: LearnViewModel
    
    // We pass this in so the app knows WHICH Raag we are adding a topic to
    let raagId: String 
    
    @State private var title = "Alankars"
    @State private var text = ""
    @State private var requiresLogin = true
    @State private var orderIndex = 2
    
    // File Picker State
    @State private var showFilePicker = false
    @State private var selectedAudioURL: URL?
    
    let topicTypes = ["Intro", "Alankars", "Palta", "Sargam Geet", "Bandish", "Tarana"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Topic Details")) {
                    Picker("Topic Type", selection: $title) {
                        ForEach(topicTypes, id: \.self) { Text($0) }
                    }
                    
                    Stepper(value: $orderIndex, in: 1...10) {
                        Text("Display Order: \(orderIndex)")
                    }
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $text)
                        .frame(height: 100)
                }
                
                Section(header: Text("Audio Recording"), footer: Text("Select an MP3 file from your device.")) {
                    Button(action: { showFilePicker = true }) {
                        HStack {
                            Image(systemName: selectedAudioURL == nil ? "waveform.badge.plus" : "checkmark.circle.fill")
                                .foregroundColor(selectedAudioURL == nil ? .blue : .green)
                            Text(selectedAudioURL == nil ? "Select Audio File" : "Audio Selected")
                                .bold()
                        }
                    }
                }
                
                Section(header: Text("Access Control")) {
                    Toggle("Require Login to Play", isOn: $requiresLogin)
                        .tint(.blue)
                }
            }
            .navigationTitle("Add Recording")
            .navigationBarTitleDisplayMode(.inline)
            // THE FILE PICKER MAGIC
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.audio],
                allowsMultipleSelection: false
            ) { result in
                do {
                    selectedAudioURL = try result.get().first
                } catch {
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Upload") {
                        // Fire the engine!
                        viewModel.uploadTopic(to: raagId, title: title, text: text, localAudioFile: selectedAudioURL, requiresLogin: requiresLogin, orderIndex: orderIndex)
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}