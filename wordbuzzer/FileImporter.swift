//
//  FileImporter.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

class FileImporter: TranslationImporter {
    func fetchWordList(completion: (ImportResult<WordList>) -> Void) {
        guard let
            url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            preconditionFailure("developer error; check structure & file reference!")
        }
        
        do {
            let jsonData = try Data(contentsOf: url, options: .dataReadingMapped)
            guard let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as? [[String: AnyObject]] else {
                return
            }
            let words = json.flatMap({ return Word(dict: $0) })
            completion(ImportResult.Success(words))
        } catch {
            let e = ModelError.importFauilure
            completion(ImportResult.Failure(e))
        }
    }
}
