//
//  Player.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

struct Player: Hashable {
    let id: String = NSUUID().uuidString
    var score: Int = 0
    
    var hashValue: Int {
        return id.hashValue
    }
}

func ==(lhs: Player, rhs: Player) -> Bool {
    return lhs.id == rhs.id
}
