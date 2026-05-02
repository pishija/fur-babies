import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Text("Profile")
                .tabItem { Label("Profile", systemImage: "pawprint.fill") }
            Text("AI Friend")
                .tabItem { Label("AI Friend", systemImage: "sparkles.rectangle.stack.fill") }
            Text("Map")
                .tabItem { Label("Map", systemImage: "map.fill") }
            Text("Social")
                .tabItem { Label("Social", systemImage: "heart.fill") }
            Text("Me")
                .tabItem { Label("Me", systemImage: "person.fill") }
        }
        .tint(Theme.Colors.primary)
    }
}

#Preview {
    MainTabView()
}
