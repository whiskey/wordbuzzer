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
}


class GameModel {
    var wordList: WordList
    var players: [Player] = Array(repeating: Player(), count: 4)
    private(set) var round: Round?
    
    /// (fixed) ISO 639-2 language code for the origin language 'english'
    private let sourceLanguage = "eng"
    /// (fixed) ISO 639-2 language code for the destination language 'spanish'
    private let targetLanguage = "spa"
    
    
    init(words: WordList) {
        self.wordList = words
    }
    
    func startGame(/* TODO: flexible language selection, i.e. en -> sp */) {
        // reset
        round = nil
        nextRound()
    }
    
    func nextRound() -> Void {
        // a random word
        let random = Int(arc4random_uniform(UInt32(wordList.count)))
        let w = wordList[random]
        assert(w.translations[sourceLanguage] != nil)
        
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
        dump(s)
        print("\(w.translations[sourceLanguage]!) --> \(w.translations[targetLanguage]!)")
        
        // the next round
        round = Round(turn: (round?.turn ?? 0) + 1,
                      word: w,
                      question:w.translations[sourceLanguage]!,
                      solutions: s)
    }
}
