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
    
    @IBOutlet var buttons: [UIButton]! {
        didSet {
            // disable all buttons on startup
            buttons.forEach({ $0.isEnabled = false })
        }
    }
    
    private var model: GameModel? = nil
    
    /// possible spawn points in all screen edges
    fileprivate var spawnPoints: [CGPoint] {
        let PADDING = CGFloat(60)
        return [
            CGPoint(x: PADDING, y: PADDING),
            CGPoint(x: view.bounds.width - PADDING, y: PADDING),
            CGPoint(x: view.bounds.width - PADDING, y: view.bounds.height - PADDING),
            CGPoint(x: PADDING, y: PADDING),
        ]
    }
    
    /// the currently active solution bubble floating around
    private var bubble: WordBubble? = nil
    
    fileprivate lazy var animator: UIDynamicAnimator = UIDynamicAnimator(referenceView: self.view)
    fileprivate lazy var collision: UICollisionBehavior = {
        let c = UICollisionBehavior()
        c.translatesReferenceBoundsIntoBoundary = true
        return c
    }()
    fileprivate lazy var itemProperties: UIDynamicItemBehavior = {
        let prop = UIDynamicItemBehavior()
        prop.elasticity = 1.0
        prop.density = 1.0
        prop.friction = 0.2
        prop.allowsRotation = false
        return prop
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // preparing UI dynamics
        animator.addBehavior(collision)
        animator.addBehavior(itemProperties)
        
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
        guard let round = model?.nextRound() else {
            return
        }
        print("=== Round \(round.turn) ===")
        wordLabel.text = round.question
        
        // delay round start for some time
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            // game ready, activate buttons
            self.buttons.forEach({ $0.isEnabled = true })
            
            // present first solution
            let solutionText = round.solutions.randomItem()!
            self.bubble = self.spawnBubble(withText: solutionText)
        }
    }

    @IBAction func onButton(sender: UIButton) {
        guard
            let suggestion = bubble?.label.text,
            let player = model?.players[sender.tag]
            else {
                assertionFailure("invalid state, check this!")
                return
        }
        
        if model!.suggest(translation: suggestion, fromPlayer: player) {
            // yay
            // TODO: visual feedback
            print("CORRECT ANSWER! \\o/")
            
            buttons.forEach({ $0.isEnabled = false })
            despawnBubble(bubble: self.bubble!, completion: { 
                self.onNextRound()
            })
        } else {
            // nope…
            // TODO: visual feedback
            print("WRONG ANSWER")
        }
        print(player)
    }
}

extension GameViewController {
    // MARK: UI Dynamics
    
    fileprivate func spawnBubble(withText text: String) -> WordBubble {
        // pick a random spwan point
        let bubble = WordBubble.bubble(text: text)
        bubble.center = spawnPoints.randomItem()!
        bubble.alpha = 0
        
        // insert bubble behind buttons; this could be done better but works for now
        view.insertSubview(bubble, at: 0)
        
        // dynamics
        itemProperties.addItem(bubble)
        collision.addItem(bubble)
        
        // push bubble towards drop zone
        let push = UIPushBehavior(items: [bubble], mode: .instantaneous)
        let o = view.center
        let b = bubble.center
        let angle = atan2(o.y-b.y, o.x-b.x)// move towards screen center
        push.setAngle(angle, magnitude: 1.5)
        animator.addBehavior(push)
        
        // fade in
        UIView.animate(withDuration: 0.3, animations: {
            bubble.alpha = 1
        })
        
        return bubble
    }
    
    /// remove a solution bubble from the screen
    fileprivate func despawnBubble(bubble:WordBubble, completion:@escaping () -> Void) {
        UIView.animate(withDuration: 0.3, animations: {
            bubble.alpha = 0
        }, completion: { finished in
            bubble.removeFromSuperview()
            
            // remove from dynamics
            self.itemProperties.removeItem(bubble)
            self.collision.removeItem(bubble)
            
            completion()
        })
    }
}
