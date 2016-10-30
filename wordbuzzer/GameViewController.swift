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
        let PADDING = CGFloat(80)
        return [
            CGPoint(x: PADDING, y: PADDING),
            CGPoint(x: view.bounds.width - PADDING, y: PADDING),
            CGPoint(x: view.bounds.width - PADDING, y: view.bounds.height - PADDING),
            CGPoint(x: PADDING, y: view.bounds.height - PADDING),
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
            self.gameLoop(inRound: round)
        }
    }
    
    private func gameLoop(inRound round: Round) {
        // handle a race condition that leads to multiple visible bubbles
        self.bubble?.removeFromSuperview()
        
        let solutionText = round.solutions.randomItem()!
        self.bubble = self.spawnBubble(withText: solutionText)
        
        // task was to have a delay of 1-3s; I expanded this a little bit to fit into my ui concept
        // now: 2-4s
        let timeout = DispatchTime.now() + max(2.0, drand48() * 4)
        DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
            if self.bubble?.superview != nil {
                self.despawnBubble(bubble: self.bubble!, completion: {
                    // next solution
                    self.gameLoop(inRound: round)
                })
            }
        })
    }
    

    @IBAction func onButton(sender: UIButton) {
        guard
            let bubble = bubble,
            let suggestion = bubble.label.text,
            let player = model?.players[sender.tag]
            else {
                assertionFailure("invalid state, check this!")
                return
        }
        
        if model!.suggest(translation: suggestion, fromPlayer: player) {
            // lock buttons
            buttons.forEach({ $0.isEnabled = false })
            
            // visual feedback & cleanup
            bubble.backgroundColor = UIColor.green
            
            // present solution
            let snap = UISnapBehavior(item: bubble, snapTo: sender.center)
            animator.addBehavior(snap)
            
            // present correct solution
            let timeout = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
                // cleanup
                self.despawnBubble(bubble: self.bubble!, completion: {
                    self.onNextRound()
                })
            })
        } else {
            // nope…
            let originalBackground = bubble.backgroundColor
            UIButton.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .beginFromCurrentState], animations: {
                self.bubble!.backgroundColor = UIColor.red
            }, completion: { finished in
                self.bubble!.backgroundColor = originalBackground
            })
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
        // magnitude is the 'speed' of the bubble
        push.setAngle(angle, magnitude: 1.2)
        animator.addBehavior(push)
        
        // fade in
        UIView.animate(withDuration: 0.3, animations: {
            bubble.alpha = 1
        })
        
        return bubble
    }
    
    /// remove a solution bubble from the screen
    fileprivate func despawnBubble(bubble:WordBubble, completion:@escaping () -> Void) {
        // remove from dynamics
        self.itemProperties.removeItem(bubble)
        self.collision.removeItem(bubble)
        // remove the all additional behaviors
        for temp in self.animator.behaviors.filter({
            return ($0 is UICollisionBehavior || $0 is UIDynamicItemBehavior) == false
        }) {
            self.animator.removeBehavior(temp)
        }
        assert(self.animator.behaviors.count == 2)
        
        UIView.animate(withDuration: 0.3, animations: {
            bubble.alpha = 0
        }, completion: { finished in
            bubble.removeFromSuperview()
            completion()
        })
    }
}
