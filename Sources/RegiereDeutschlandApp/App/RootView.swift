import SwiftUI

struct RootView: View {
    @Environment(UpdateReminder.self) private var reminder
    @State private var navigationID = UUID()

    var body: some View {
        @Bindable var reminder = reminder
        NavigationStack {
            HomeScreen()
        }
        .id(navigationID)
        .tint(GameTheme.gold)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $reminder.showFutureUpdate) {
            FutureUpdateView()
        }
        .onChange(of: reminder.showFutureUpdate) { _, isPresented in
            // Close a prior game before the notification page can resume its save.
            if isPresented { navigationID = UUID() }
        }
    }
}
