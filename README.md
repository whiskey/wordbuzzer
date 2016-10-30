# Word Buzzer

Playground App for UIDynamics in Swift 3.x.

## Some remarks on the code
* no external frameworks/libraries! As a consequence
    * no special logging mechanism like XCLogger(?); `print` & `dump` are ok for this case
    * no Fastlane
    * no git-flow
    * no [RxSwift](https://github.com/ReactiveX/RxSwift) and other fancy stuff
* UIKit & Dynamics in favor of SpriteKit
* no persistency via CoreData or Realm
* better handling of the language codes (NSLocale's ISO 639-1 vs the given -2)
* fail fast principle
    * forced unwraps == developer errors on crash
    * `precondition` for stuff that might even crash in production apps to prevent an invalid state
    * `assert` for checks during development time

## For UX
* solution bubble don’t rotate; players on top edge might have a handicap to read labels
* only rudimentary eye candy for the game ui
* no reset of the game state other than hard app restart
* no player selection

## Possible improvements
* real multiplayer session via `MultipeerConnectivity` for up to 8 players
* Apple TV support (with `MultipeerConnectivity`)
* Game Center (with `MultipeerConnectivity`)
* flexible language selection _from -> to_
