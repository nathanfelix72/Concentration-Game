//
//  CardView.swift
//  Concentration Game
//
//  Created by Stephen Liddle on 9/29/23.
//

import SwiftUI

struct CardView: View {
    let card: ConcentrationGame<String>.Card

    @State private var animatedBonusRemaining = 0.0

    var body: some View {
        GeometryReader { geometry in
            if !card.isMatched || card.isFaceUp {
                ZStack {
                    let animation = Animation.linear(duration: 0.5).repeatForever(autoreverses: false)
                    Group {
                        if card.isConsumingBonusTime {
                            Pie(
                                startAngle: angle(for: 0),
                                endAngle: angle(for: -animatedBonusRemaining)
                            )
                            .onAppear {
                                animatedBonusRemaining = card.bonusRemainingPercent
                                withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                    animatedBonusRemaining = 0
                                }
                            }
                        } else {
                            Pie(
                                startAngle: angle(for: 0),
                                endAngle: angle(for: -card.bonusRemainingPercent)
                            )
                        }
                    }
                    .opacity(Card.pieOpacity)
                    .padding(geometry.size.width * Card.paddingScaleFactor)
                    Text(card.content)
                        .font(systemFont(for: geometry.size))
                        .rotationEffect(Angle(degrees: card.isMatched ? 360 : 0))
                        .animation(animation, value: card.isMatched)
                }
                .cardify(isFaceUp: card.isFaceUp)
                .transition(.scale)
                .foregroundStyle(.orange)
            }
        }
        .aspectRatio(Card.aspectRatio, contentMode: .fit)
    }

    // MARK: - Helpers

    private func angle(for percentOfCircle: Double) -> Angle {
        Angle.degrees(percentOfCircle * 360 - 90)
    }

    private func systemFont(for size: CGSize) -> Font {
        .system(size: min(size.width, size.height) * Card.fontScaleFactor)
    }

    // MARK: - Drawing constants

    private struct Card {
        static let aspectRatio = 5.0 / 7.0
        static let cornerRadius = 10.0
        static let fontScaleFactor = 0.75
        static let paddingScaleFactor = 0.04
        static let pieOpacity = 0.4
    }
}

#Preview {
    CardView(card: ConcentrationGame<String>.Card(isFaceUp: true, content: "🐶") )
        .padding(50)
}
