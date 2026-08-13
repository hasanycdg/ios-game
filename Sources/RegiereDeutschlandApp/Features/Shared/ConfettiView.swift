import SwiftUI

/// Leichte Konfetti-Animation für Siegesmomente.
struct ConfettiView: View {
    var pieceCount: Int = 44

    private let colors: [Color] = [
        GameTheme.gold, GameTheme.goldBright, GameTheme.red, GameTheme.green, GameTheme.blue
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(0..<pieceCount, id: \.self) { index in
                    ConfettiPiece(color: colors[index % colors.count], canvas: geo.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct ConfettiPiece: View {
    let color: Color
    let canvas: CGSize

    @State private var x: CGFloat = 0
    @State private var y: CGFloat = -40
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 7, height: 12)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(x: x, y: y)
            .onAppear {
                x = CGFloat.random(in: 0...max(1, canvas.width))
                let duration = Double.random(in: 1.6...2.8)
                let delay = Double.random(in: 0...0.7)
                withAnimation(.easeIn(duration: duration).delay(delay)) {
                    y = canvas.height + 60
                    rotation = Double.random(in: 220...900)
                }
                withAnimation(.easeIn(duration: 0.4).delay(delay + duration - 0.4)) {
                    opacity = 0
                }
            }
    }
}
