import SwiftUI

struct MainAppView: View {
    var body: some View {
        TabView {
            // Tab 1: The Landing Screen
            TanpuraView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Practice")
                }
            
            // Tab 2: The Notepad Screen
            NotationView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Compose")
                }
            
            //Tab 3: The Learn Raag Screen
            LearnDirectoryView()
                            .tabItem {
                                Image(systemName: "books.vertical.fill")
                                Text("Learn")
                            }        }
        .accentColor(.blue)
    }
}

#Preview {
    MainAppView()
}
 
