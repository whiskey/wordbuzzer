//
//  GameModel.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

// a game round
struct Round {
    let turn: Int
    let word: Word
    
    let question: String
    let solutions: [String]
    let correctAnswer: String
}


class GameModel {
    private(set) var wordList: WordList
    var players = [Player(1), Player(2), Player(3), Player(4)]
    private(set) var round: Round?
    
    /// (fixed) ISO 639-2 language code for the origin language 'english'
    private let sourceLanguage = "eng"
    /// (fixed) ISO 639-2 language code for the destination language 'spanish'
    private let targetLanguage = "spa"
    
    
    init(words: WordList) {
        self.wordList = words
    }
    
    func startGame(/* TODO: flexible language selection, i.e. en -> sp */) {
        // reset scores
        players.forEach({ $0.score = 0 })
    }
    
    func nextRound() -> Round {
        // a random word
        let random = Int(arc4random_uniform(UInt32(wordList.count)))
        let w = wordList[random]
        // check for edge cases
        assert(w.translations[sourceLanguage] != nil, "word does not exist in source language; question will be nil!")
        assert(w.translations[targetLanguage] != nil, "word does not exist in target language; answer will be nil!")
        
        // ...plus nine wrong 'solutions'
        var tmp = Set<String>()
        while tmp.count < 9 {
            let random = Int(arc4random_uniform(UInt32(wordList.count)))
            let fake = wordList[random]
            if let wrong = fake.translations[targetLanguage], fake.id != w.id {
                tmp.insert(wrong)
            }
        }
        // ...add the correct solution
        tmp.insert(w.translations[targetLanguage]!)
        // 1 + 9 solutions
        let s = Array(tmp).shuffled()
        
        // the next round
        round = Round(turn: (round?.turn ?? 0) + 1,
                      word: w,
                      question:w.translations[sourceLanguage]!,
                      solutions: s, correctAnswer: w.translations[targetLanguage]!)
        return round!
    }
    
    /**
     Validates a given suggestion from a player and returns wether it's correct or not.
     Also, increases or decreases player's score.
     
     - parameter translation: the suggested translation string for the current round
     - parameter player: the player that suggests the translation
     
     - returns: correct answer `true`/`false`
    */
    func suggest(translation: String, fromPlayer player: Player) -> Bool {
        if translation == round?.correctAnswer {
            // correct answer 🎉
            player.score += 1
            return true
        } else {
            // wrong anser 💩
            player.score -= 1
            return false
        }
    }
}
