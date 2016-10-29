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
    
    private let model = TranslationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordLabel.text = "Loading…"
        model.fetchTranslations {
            self.wordLabel.text = nil
        }
    }

    @IBAction func onButton(sender: UIButton) {
        print("Player \(sender.tag + 1)")
    }
}
