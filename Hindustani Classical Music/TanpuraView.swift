import SwiftUI
import AVFoundation

// MARK: - THE AUDIO MANAGER (Moved here!)
class AudioPlayerManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    // We update this function to accept the name of the scale
    func setupAudio(scale: String) {
            // 1. Replace the sharp symbol
            var safeName = scale.replacingOccurrences(of: "#", with: "sharp")
            
            // 2. Handle the dot (this catches both ways the computer might type it)
            safeName = safeName.replacingOccurrences(of: "\u{0323}", with: "_lower")
            safeName = safeName.replacingOccurrences(of: "Ạ", with: "A_lower")
            safeName = safeName.replacingOccurrences(of: "Ḅ", with: "B_lower")
            
            let fileName = "tanpura_\(safeName)"
            
            // 3. Search for the file
            if let path = Bundle.main.path(forResource: fileName, ofType: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                    audioPlayer?.numberOfLoops = -1
                    audioPlayer?.prepareToPlay()
                    
                    #if os(iOS)
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                    #endif
                    
                } catch {
                    print("Error loading audio: \(error.localizedDescription)")
                }
            } else {
                // THE FIX: If the file is missing, clear the player so we don't play a ghost track!
                print("❌ Could not find file named: \(fileName).mp3")
                audioPlayer = nil
                isPlaying = false
            }
        }
    
    
    func togglePlay() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            print("Audio Paused")
        } else {
            player.play()
            isPlaying = true
            print("Audio Playing")
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        isPlaying = false
    }
}

// MARK: - THE TANPURA SCREEN
struct TanpuraView: View {
    @StateObject private var audioManager = AudioPlayerManager()
    
    // This variable tracks which scale the user clicked
    @State private var selectedScale: String = "C"
    
    // The 15 scales of the harmonium/tanpura
    let scales = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B", "Ạ", "Ạ#", "Ḅ",]
    
    // This tells the grid to make 3 columns
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Daily Riyaz")
                .font(.largeTitle)
                .bold()
                .padding(.top, 40)
            
            Spacer()
            
            // 1. THE MASSIVE PLAY BUTTON
            Button(action: {
                audioManager.togglePlay()
            }) {
                Image(systemName: audioManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(audioManager.isPlaying ? .red : .green)
                    .shadow(radius: 10)
            }
            
            Text("Selected Scale: \(selectedScale)")
                .font(.title2)
                .foregroundColor(.gray)
                .padding(.top, 10)
            
            // 2. THE 3x5 SCALE GRID
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(scales, id: \.self) { scale in
                    Button(action: {
                        // When a new scale is tapped, stop the old audio and load the new one
                        audioManager.stop()
                        selectedScale = scale
                        audioManager.setupAudio(scale: scale)
                    }) {
                        Text(scale)
                            .font(.title2)
                            .bold()
                            .frame(width: 80, height: 60)
                            // Highlight the button if it's the currently selected scale
                            .background(selectedScale == scale ? Color.green : Color.gray.opacity(0.2))
                            .foregroundColor(selectedScale == scale ? .white : .black)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
        // Load the default "C" audio when the screen first opens
        .onAppear {
            audioManager.setupAudio(scale: selectedScale)
        }
    }
}

#Preview {
    TanpuraView()
}
