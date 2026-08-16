import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeScreen()
        }
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
    }
}
