//
//  ConcentrationGame.swift
//  Concentration Game
//
//  Created by IS 543 on 10/13/25.
//

import Foundation

struct ConcentrationGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    var indexOfTheOneAndOnlyFaceUpCard: Int?
    
    var score: Int {
        cards.reduce(0) { $0 + $1.score }
    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = []
        
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            
            cards.append(Card(content: content))
            cards.append(Card(content: content))
        }
        
        cards.shuffle()
    }
    
    mutating func choose(card: Card) {
        if let chosenIndex = cards.firstIndex(matching: card),
            !cards[chosenIndex].isFaceUp,
            !cards[chosenIndex].isMatched {
            
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[potentialMatchIndex].content == cards[chosenIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
                
                indexOfTheOneAndOnlyFaceUpCard = nil
            } else {
                for index in cards.indices where cards[index].isMatched == false {
                    cards[index].isFaceUp = false
                }
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
            
            cards[chosenIndex].viewCount += 1
            cards[chosenIndex].isFaceUp.toggle()
        }
    }
    
    struct Card: Identifiable {
        
        // MARK: - Properties
        
        var id = UUID()
        fileprivate(set) var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        fileprivate(set) var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        fileprivate(set) var viewCount = 0
        fileprivate(set) var content: CardContent
        
        fileprivate(set) var bonusTimeLimit: TimeInterval = Score.maxBonusTime
        fileprivate(set) var lastFaceUpTime: Date?
        fileprivate(set) var pastFaceUpTime: TimeInterval = 0
        
        // MARK: - Computed Properties
        
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        var score: Int {
            if isMatched {
                return 3 - viewCount
            }
            
            if viewCount > 0 {
                return -viewCount + 1
            }
            
            return 0
        }
        
        // MARK: - Private Helpers
        
        private var bonusRemainingPercent: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0)
            ? bonusTimeRemaining / bonusTimeLimit
            : 0
        }
        
        private var bonusScore: Int {
            Int(bonusRemainingPercent * Score.bonusFactor)
        }
        
        private var faceUpTime: TimeInterval {
            if let lastFaceUpTime {
                pastFaceUpTime +  Date().timeIntervalSince(lastFaceUpTime)
            } else {
                pastFaceUpTime
            }
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime && lastFaceUpTime == nil {
                lastFaceUpTime = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            pastFaceUpTime = faceUpTime
            lastFaceUpTime = nil
        }
    }
}

// MARK: - Constants

private struct Score {
    static let baseMatchValue = 3
    static let bonusFactor = 5.0
    static let maxBonusTime = 12.0
}
