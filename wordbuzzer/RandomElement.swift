//
//  RandomElement.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 30/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

extension Array {
    
    /// Pick a random element. Returns `nil` if the given array is empty.
    func randomItem() -> Element? {
        guard count > 0 else { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
