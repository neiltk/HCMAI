//
//  RaagDetailView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI

struct RaagDetailView: View {
    // This view expects a full RaagModel to be passed in
    let raag: RaagModel 
    
    @ObservedObject var viewModel: LearnViewModel
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var showAddTopicSheet = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - METADATA HEADER
                VStack(alignment: .leading, spacing: 10) {
                    Text(raag.description)
                        .font(.body)
                        .italic()
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 15) {
                        Label(raag.thaat, systemImage: "music.note.list")
                        Label(raag.timeOfDay, systemImage: "clock.fill")
                        Label(raag.jati, systemImage: "chart.bar.fill")
                    }
                    .font(.caption)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Divider()
                
                // MARK: - TOPICS LIST
                if viewModel.currentTopics.isEmpty {
                    Text("No recordings uploaded yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.currentTopics) { topic in
                        TopicCardView(topic: topic)
                            .environmentObject(authVM)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(raag.name)
        // Fetch the specific topics the millisecond this screen opens
        .onAppear {
            if let id = raag.id {
                viewModel.fetchTopics(for: id)
            }
        }
        // ADMIN CONTROLS: Upload Recording Button
        .toolbar {
            if authVM.isAdmin {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddTopicSheet = true }) {
                        Image(systemName: "plus.rectangle.on.folder.fill")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddTopicSheet) {
            if let id = raag.id {
                AddTopicView(viewModel: viewModel, raagId: id)
            }
        }
    }
}