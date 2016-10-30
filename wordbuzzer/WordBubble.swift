//
//  WordBubble.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 30/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import UIKit

/// Visual representation of a suggested solution
@IBDesignable
class WordBubble: UIView {
    @IBOutlet weak var label:UILabel!

    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
    }
    
    class func bubble(text: String) -> WordBubble {
        guard let bubble = UINib(nibName: "WordBubble", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? WordBubble else {
            preconditionFailure("WordBubble init failed")
        }
        bubble.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        bubble.label.text = text
        return bubble
    }
}
