import SwiftUI
import RegiereDeutschlandCore

struct ElectoralCollegeCard: LocalizedGameView {
    @Environment(GamePresentation.self) var gamePresentation
    let votes: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: L("Electoral College"), systemImage: "building.columns.fill", accessory: L("270 to win"))
            HStack(alignment: .firstTextBaseline) {
                Text("\(votes)").font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundStyle(votes >= 270 ? GameTheme.green : GameTheme.red)
                Text(L("/ 538 electoral votes")).font(.subheadline).foregroundStyle(GameTheme.secondaryText)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(GameTheme.blue.opacity(0.35))
                    Capsule().fill(GameTheme.gold)
                        .frame(width: geometry.size.width * CGFloat(votes) / 538)
                    Rectangle().fill(Color.white).frame(width: 2)
                        .offset(x: geometry.size.width * 270 / 538)
                }
            }
            .frame(height: 12)
            Text(L("Opposition: \(538 - votes) electoral votes. A 269–269 tie ends this campaign because no majority was secured."))
                .font(.caption).foregroundStyle(GameTheme.secondaryText)
            Text(L("Simplified alternate-history model: state margins move with the national vote. Census-era electoral totals are used; Maine and Nebraska are modeled statewide. This is not a real election forecast."))
                .font(.caption2).foregroundStyle(GameTheme.tertiaryText)
        }
        .gameCard(padding: 18)
    }
}
