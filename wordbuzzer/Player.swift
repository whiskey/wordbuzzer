//
//  Player.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

class Player: Hashable, CustomStringConvertible {
    let id: Int
    var score: Int = 0
    
    var hashValue: Int {
        return id.hashValue
    }
    
    var description:String {
        return "Player \(id); score: \(score)"
    }
    
    /// I son't care for proper ID management in this demo
    init(_ id: Int) {
        self.id = id
    }
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.id == rhs.id
}
