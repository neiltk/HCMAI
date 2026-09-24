//
//  TopicCardView.swift
//  Hindustani Classical Music
//
//  Created by Advik Thakre on 2026-04-18.
//


import SwiftUI
import AVFoundation // Required for streaming web audio
import FirebaseStorage

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
            if let audioPath = topic.audioPath {
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
                            Button(action: { toggleAudio(path: audioPath) }) {
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
    
    private func toggleAudio(path: String) {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            let storageRef = Storage.storage().reference(withPath: path)
            storageRef.write(toFile: FileManager.default.temporaryDirectory.appendingPathComponent("hcmai-\(UUID().uuidString).mp3")) { url, error in
                guard let url, error == nil else { return }
                DispatchQueue.main.async {
                    player = AVPlayer(url: url)
                    player?.play()
                    isPlaying = true
                }
            }
        }
    }
}