//
//  Hindustani_Classical_MusicApp.swift
//  Hindustani Classical Music
//
//  Created by user291866 on 3/21/26.
//

import SwiftUI
import FirebaseCore // 1. Bring in the Firebase toolkit
import SwiftData

@main
struct Hindustani_Classical_MusicApp: App {
        // 2. This 'init' function runs the exact millisecond the app opens
        init() {
            FirebaseApp.configure() // 3. This tells the app to read the .plist file!
        }

    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
    }
}
