//
//  GameViewController.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 28/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    private let model = TranslationModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model.fetchTranslations {
            //
        }
    }

}
