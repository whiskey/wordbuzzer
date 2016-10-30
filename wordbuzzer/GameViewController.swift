//
//  GameViewController.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 28/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var solutionLabel: UILabel! {
        didSet {
            solutionLabel.text = nil
        }
    }
    
    @IBOutlet var button_0: UIButton!
    @IBOutlet var button_1: UIButton!
    @IBOutlet var button_2: UIButton!
    @IBOutlet var button_3: UIButton!
    
    private var model: GameModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // cheap replacement for any kind of loading indicator
        wordLabel.text = "Loading…"
        
        let translations = TranslationModel()
        translations.fetchTranslations {
            self.wordLabel.text = nil
            
            self.model = GameModel(words: translations.wordList)
            self.model?.startGame()
            self.onNextRound()
        }
    }
    
    private func onNextRound() {
        guard let round = model?.round else {
            return
        }
        wordLabel.text = round.question
        solutionLabel.text = round.solutions.first
        // TODO: start timer, etc.
    }

    @IBAction func onButton(sender: UIButton) {
        print("Player \(sender.tag + 1)")
    }
}
