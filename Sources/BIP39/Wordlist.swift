//
//  Wordlist.swift
//  
//
//  Created by Carlos Chida on 07/07/24.
//

import Foundation

internal struct Wordlist: Equatable {
    public let words: [String]
    public let indexes: [String: UInt16]
    
    public init(words: [String]) {
        precondition(words.count == 2048, "Wordlist must contain 2048 words")
        
        let indexTuples = words.enumerated().map { ($0.element, UInt16($0.offset)) }
        
        self.words = words
        self.indexes = Dictionary(uniqueKeysWithValues: indexTuples)
    }
    
    public subscript(index: UInt16) -> String { words[Int(index)] }
    public subscript(word: String) -> UInt16? { indexes[word] }
    
    public func hasWordThatStartWith(possiblePrefix: String) -> Bool {
        for word in words {
            if word.starts(with: possiblePrefix) {
                return true
            }
        }
        
        return false
    }
}

extension Wordlist {
    private static func loadWordsFromTxt(name: String) -> [String] {
        let path = Bundle.module.path(forResource: name, ofType: "txt")!
        let data = try! String(contentsOfFile: path, encoding: .utf8)
        
        return data.components(separatedBy: "\n").dropLast()
    }
    
    static var chineseSimplified = Self(words: Self.loadWordsFromTxt(name: "chinese_simplified"))
    static var chineseTraditional = Self(words: Self.loadWordsFromTxt(name: "chinese_traditional"))
    static var czech = Self(words: Self.loadWordsFromTxt(name: "czech"))
    static var english = Self(words: Self.loadWordsFromTxt(name: "english"))
    static var french = Self(words: Self.loadWordsFromTxt(name: "french"))
    static var italian = Self(words: Self.loadWordsFromTxt(name: "italian"))
    static var japanese = Self(words: Self.loadWordsFromTxt(name: "japanese"))
    static var korean = Self(words: Self.loadWordsFromTxt(name: "korean"))
    static var portuguese = Self(words: Self.loadWordsFromTxt(name: "portuguese"))
    static var russian = Self(words: Self.loadWordsFromTxt(name: "russian"))
    static var spanish = Self(words: Self.loadWordsFromTxt(name: "spanish"))
    static var turkish = Self(words: Self.loadWordsFromTxt(name: "turkish"))
    
}

extension Wordlist {
    public enum StandardWordlist: String, CaseIterable {
        case chineseSimplified = "chinese_simplified"
        case chineseTraditional = "chinese_traditional"
        case czech
        case english
        case french
        case italian
        case japanese
        case korean
        case portuguese
        case russian
        case spanish
        case turkish
        
        var symbol: Wordlist {
            switch self {
            case .chineseSimplified:
                return .chineseSimplified
            case .chineseTraditional:
                return .chineseTraditional
            case .czech:
                return .czech
            case .english:
                return .english
            case .french:
                return .french
            case .italian:
                return .italian
            case .japanese:
                return .japanese
            case .korean:
                return .korean
            case .portuguese:
                return .portuguese
            case .russian:
                return .russian
            case .spanish:
                return .spanish
            case .turkish:
                return .turkish
            }
        }
    }
}

