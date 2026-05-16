//
//  TopicCardView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI
import AVFoundation // Required for streaming web audio

struct TopicCardView: View {
    let topic: TopicModel
    @EnvironmentObject var authVM: AuthViewModel
    
    // Audio Player State
    @State private var player: AVPlayer?
    @State private var isPlaying = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(topic.title)
                .font(.title3)
                .bold()
                .foregroundColor(.blue)
            
            Text(topic.text)
                .font(.body)
                .foregroundColor(.primary)
            
            // AUDIO PLAYER LOGIC
            if let audioStr = topic.audioUrl, let url = URL(string: audioStr) {
                Divider()
                
                // Check Access Control
                if topic.requiresLogin && !authVM.isAuthenticated {
                    HStack {
                        Image(systemName: "lock.fill").foregroundColor(.red)
                        Text("Log in to access this premium recording.")
                            .font(.footnote).foregroundColor(.red)
                    }
                } else {
                    // Safe to Play
                    HStack {
                        Button(action: { toggleAudio(url: url) }) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(isPlaying ? .red : .green)
                        }
                        Text(isPlaying ? "Playing..." : "Listen to Recording")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func toggleAudio(url: URL) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            if player == nil {
                player = AVPlayer(url: url) // Streams directly from Firebase Storage!
            }
            player?.play()
            isPlaying = true
        }
    }
}