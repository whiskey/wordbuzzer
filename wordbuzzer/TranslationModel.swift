//
//  TranslationModel.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import Foundation

enum ModelError: Error {
    case importFauilure
    case emptyWordList
    // TODO: add network errors, etc. …
}

/// the raw array of word-dictionaries
typealias WordList = [Word]

enum ImportResult<WordList> {
    case Success(WordList)
    case Failure(ModelError)
}
protocol TranslationImporter: class {
    func fetchWordList(completion: (ImportResult<WordList>) -> Void)
}


class TranslationModel {
    /// primary data source for the word list
    let importer: TranslationImporter
    private(set) var wordList: WordList = []
    
    
    init(importer: TranslationImporter = FileImporter()) {
        self.importer = importer
    }
    
    func fetchTranslations(completion: @escaping () -> Void) {
        importer.fetchWordList { [weak self] (result) in
            switch result {
            case .Success(let wordList):
                self?.wordList = wordList
            case .Failure(let error):
                if self?.importer is FileImporter {
                    // fallback solution (static file) failed; this needs to work or it's a dev error!
                    debugPrint(error)
                    preconditionFailure("could not fetch local word list; check this!")
                } else {
                    // TODO: setup file importer as fallback
                }
            }
            completion()
        }
    }
    
    func randomWord() throws -> Word {
        guard wordList.count > 0 else {
            throw ModelError.emptyWordList
        }
        let random = Int(arc4random_uniform(UInt32(wordList.count)))
        return wordList[random]
    }
}
