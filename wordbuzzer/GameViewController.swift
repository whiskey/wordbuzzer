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
    @IBOutlet var scoreLabels: [UILabel]! {
        didSet {
            scoreLabels.forEach({ $0.text = nil })
        }
    }
    
    private lazy var numberFormatter = NumberFormatter()
    
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
    private var bubble: WordBubble? {
        return view.subviews.filter({ return $0 is WordBubble }).first as? WordBubble
    }
    
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
        wordLabel.text = NSLocalizedString("Loading…", comment: "a loading text")
        
        let translations = TranslationModel()
        translations.fetchTranslations {
            self.wordLabel.text = nil
            
            self.model = GameModel(words: translations.wordList)
            self.model?.startGame()
            self.onNextRound()
            self.updateScores()
        }
    }
    
    private func updateScores() {
        model?.players.forEach({ player in
            // attention: player ids start with 1!
            guard let label = self.scoreLabels.filter({ $0.tag == (player.id-1) }).first else {
                preconditionFailure()
            }
            label.text = self.numberFormatter.string(from: NSNumber(integerLiteral: player.score))
        })
    }
    
    private func onNextRound() {
        guard let round = model?.nextRound() else {
            return
        }
        self.bubble?.removeFromSuperview()
        
        wordLabel.text = round.question
        print("=== Round \(round.turn) \"\(wordLabel.text!)\"===")
        
        // delay round start for some time
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            // game ready, activate buttons
            self.buttons.forEach({ $0.isEnabled = true })
            self.gameLoop(inRound: round)
        }
    }
    
    private func gameLoop(inRound round: Round) {
        let solutionText = round.solutions.randomItem()!
        let b = self.spawnBubble(withText: solutionText)
        
        // task was to have a delay of 1-3s; I expanded this a little bit to fit into my ui concept
        // now: 2-4s
        let timeout = DispatchTime.now() + max(2.0, drand48() * 4)
        DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
            self.despawnBubble(bubble: b, completion: {
                // round still active? I'm using the button states to check this
                if (self.buttons.first?.isEnabled)! {
                    // next solution
                    self.gameLoop(inRound: round)
                }
            })
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
        
        // handle result: correct/incorrect answer
        if model!.suggest(translation: suggestion, fromPlayer: player) {
            // handle race condition on multiple correct answers by checking the button enabled states
            if buttons.first!.isEnabled == false {
                // somebody else was faster :-/
                return
            }
            // lock buttons -> round halted
            buttons.forEach({ $0.isEnabled = false })
            
            // visual feedback & cleanup
            bubble.backgroundColor = UIColor.green
            
            // present solution
            let nearestSpawnPoint = self.spawnPoints.sorted(by: { (p1, p2) -> Bool in
                let h1 = hypot(p1.x - sender.center.x, p1.y - sender.center.y)
                let h2 = hypot(p2.x - sender.center.x, p2.y - sender.center.y)
                return h1 < h2
            }).first!
            
            let snap = UISnapBehavior(item: bubble, snapTo: nearestSpawnPoint)
            animator.addBehavior(snap)
            
            let timeout = DispatchTime.now() + 2
            DispatchQueue.main.asyncAfter(deadline: timeout, execute: {
                // cleanup
                self.despawnBubble(bubble: bubble, completion: {
                    self.onNextRound()
                })
            })
        } else {
            // nope…
            let originalBackground = bubble.backgroundColor
            UIButton.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .beginFromCurrentState], animations: {
                bubble.backgroundColor = UIColor.red
            }, completion: { finished in
                bubble.backgroundColor = originalBackground
            })
        }
        updateScores()
    }
}

extension GameViewController {
    // MARK: UI Dynamics
    
    fileprivate func spawnBubble(withText text: String) -> WordBubble {
        // pick a random spwan point
        let bubble = WordBubble.bubble(text: text)
        bubble.center = spawnPoints.randomItem()!
        bubble.alpha = 0
        
        // insert bubble behind buttons; this could be done better 
        // (i.e. multiple game-/ui-layers) but works for now
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
