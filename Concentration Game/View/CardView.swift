//
//  CardView.swift
//  Concentration Game
//
//  Created by IS 543 on 10/14/25.
//

import SwiftUI

struct CardView: View {
    let card: ConcentrationGame<String>.Card
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !card.isMatched || card.isFaceUp {
                    Pie(startAngle: Angle(degrees: 360-90), endAngle: Angle(degrees: 105-90))
                        .opacity(0.4)
                        .foregroundColor(.orange)
                        .padding()
                    Text(card.content)
                        .font(systemFont(for: geometry.size))
                }
                
            }
            .cardify(isFaceUp: card.isFaceUp)
            .foregroundColor(.blue)
        }
        .aspectRatio(Card.aspectRatio, contentMode: .fit)
    }
    
    // MARK: - Drawing Constants
    
    private struct Card {
        static let aspectRatio = 2.0 / 3.0
        static let cornerRadius = 10.0
        static let fontScaleFactor = 0.75
    }
    
    private func systemFont(for size: CGSize) -> Font {
        .system(size: min(size.width, size.height) * Card.fontScaleFactor)
    }
}

#Preview {
    CardView(card: ConcentrationGame<String>.Card(isFaceUp: true, content: String("🐶")) )
        .padding(50)
}
