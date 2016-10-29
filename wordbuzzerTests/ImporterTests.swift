//
//  ImporterTests.swift
//  wordbuzzer
//
//  Created by Carsten Witzke on 29/10/2016.
//  Copyright © 2016 staticline.de. All rights reserved.
//

import XCTest

class ImporterTests: XCTestCase {
    
    /**
     Test the default file import
    */
    func testFileImport() {
        let asyncExpectation = expectation(description: "wordlist import")
        
        var words: WordList? = nil
        
        let importer = FileImporter()
        importer.fetchWordList { (result) in
            switch result {
            case .Success(let wordList):
                words = wordList
                XCTAssert(wordList.count > 0, "exptected non-empty word list")
            case .Failure(let error):
                XCTFail("import error: \(error)")
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(words)
        }
    }
    
    /**
     Test the random word fetch mechanism
    */
    func testRandomWordFetch() {
        let importer = FileImporter()
        let model = TranslationModel(importer: importer)
        
        let asyncExpectation = expectation(description: "random word fetch")
        model.fetchTranslations {
            XCTAssert(model.wordList.count > 0)
            
            for _ in [0..<10] {
                XCTAssertNotNil(try? model.randomWord())
            }
            asyncExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
        }
    }
    
}
