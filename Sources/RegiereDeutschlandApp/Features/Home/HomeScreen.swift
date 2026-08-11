import SwiftUI

struct HomeScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Regiere Deutschland")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("2000-2026")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("Deutschland seit 2000 - aber diesmal entscheidest DU.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            }

            NavigationLink {
                GameScreen()
            } label: {
                Text("Neues Spiel")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 12)

            Spacer()
        }
        .padding(24)
        .inlineNavigationTitle()
    }
}
