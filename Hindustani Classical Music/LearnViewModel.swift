import Foundation
import FirebaseFirestore
import FirebaseStorage

// MARK: - 1. THE DATA BLUEPRINT
struct RaagModel: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var thaat: String
    var jati: String
    var timeOfDay: String
    var prahar: Int
    var description: String
    var isPublished: Bool
}
// MARK: - THE TOPIC BLUEPRINT
struct TopicModel: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var text: String
    var audioUrl: String? // Optional, because an "Intro" might just be text!
    var requiresLogin: Bool
    var orderIndex: Int
}

// MARK: - 2. THE FIREBASE ENGINE
class LearnViewModel: ObservableObject {
    // This array holds the data, and @Published tells the UI to update when it changes
    @Published var raags: [RaagModel] = []

    // 1. A dedicated array to hold the topics for whichever Raag is currently on screen
        @Published var currentTopics: [TopicModel] = []
        
        // 2. The live fetcher
        func fetchTopics(for raagId: String) {
            // We use addSnapshotListener instead of getDocuments.
            // This creates a "live pipe." If the Admin uploads a file, it instantly appears on screen without refreshing!
            db.collection("raags").document(raagId).collection("topics")
                .order(by: "orderIndex")
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        print("Error fetching topics: \(error.localizedDescription)")
                        return
                    }
                    if let documents = snapshot?.documents {
                        self.currentTopics = documents.compactMap { try? $0.data(as: TopicModel.self) }
                    }
                }
        }
    
    private var db = Firestore.firestore()
    
    func fetchRaags() {
        // Fetch only Raags that are marked as "Published" by the Admin
        db.collection("raags")
            .whereField("isPublished", isEqualTo: true)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error fetching raags: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents {
                    // This magically translates the Firebase JSON into our Swift RaagModel
                    self.raags = documents.compactMap { doc in
                        try? doc.data(as: RaagModel.self)
                    }
                }
            }
    } // <--- This was the missing curly brace!
    
    // Add Raag is now safely its own independent function
    func addRaag(name: String, thaat: String, jati: String, timeOfDay: String, prahar: Int, description: String, isPublished: Bool) {
        
        // 1. Package the inputs into our blueprint
        let newRaag = RaagModel(name: name, thaat: thaat, jati: jati, timeOfDay: timeOfDay, prahar: prahar, description: description, isPublished: isPublished)
        
        // 2. Safely push it to the cloud
        do {
            try db.collection("raags").addDocument(from: newRaag)
            print("Successfully saved \(name) to Firestore!")
            
            // 3. Immediately refresh the list so the new Raag shows up in the UI
            self.fetchRaags()
        } catch {
            print("Error saving Raag: \(error.localizedDescription)")
        }
    }
    
    // MARK: - AUDIO & TOPIC UPLOADER
    func uploadTopic(to raagId: String, title: String, text: String, localAudioFile: URL?, requiresLogin: Bool, orderIndex: Int) {
        let topicRef = db.collection("raags").document(raagId).collection("topics").document()
        
        // Scenario A: Text only, no audio file
        guard let localAudioFile = localAudioFile else {
            let newTopic = TopicModel(id: topicRef.documentID, title: title, text: text, audioUrl: nil, requiresLogin: requiresLogin, orderIndex: orderIndex)
            try? topicRef.setData(from: newTopic)
            print("Text topic saved!")
            return
        }
        
        // Scenario B: We have an audio file to upload!
        // 1. Gain secure access to the iOS file system
        guard localAudioFile.startAccessingSecurityScopedResource() else { return }
        defer { localAudioFile.stopAccessingSecurityScopedResource() }
        
        let storageRef = Storage.storage().reference().child("audio/\(topicRef.documentID).mp3")
        
        // 2. Upload the binary data
        storageRef.putFile(from: localAudioFile, metadata: nil) { metadata, error in
            if let error = error { print("Upload failed: \(error.localizedDescription)"); return }
            
            // 3. Ask Google for the public download link
            storageRef.downloadURL { url, error in
                guard let downloadUrl = url?.absoluteString else { return }
                
                // 4. Save the text AND the new audio link to Firestore
                let newTopic = TopicModel(id: topicRef.documentID, title: title, text: text, audioUrl: downloadUrl, requiresLogin: requiresLogin, orderIndex: orderIndex)
                try? topicRef.setData(from: newTopic)
                print("Audio successfully uploaded and linked!")
            }
        }
    }
}
