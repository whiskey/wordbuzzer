//
//  Word.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

typealias ISO639_2LanguageCode = String
struct Word {
    /// simplification: english translation is used as id
    let id: String
    /// the dictionary of translations for this word
    let translations: [ISO639_2LanguageCode: String]
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["text_eng"] as? String else {
            return nil
        }
        self.id = id
        
        // I'm assuming three letter language code as ISO639-2
        var tmp: [ISO639_2LanguageCode: String] = [:]
        dict.forEach { (key: String, value: AnyObject) in
            guard let code = key.components(separatedBy: "_").last else {
                return
            }
            tmp[code] = value as? String
        }
        translations = tmp
    }
}
