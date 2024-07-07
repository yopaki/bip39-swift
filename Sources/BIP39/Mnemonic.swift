//
//  Mnemonic.swift
//
//
//  Created by Carlos Chida on 07/07/24.
//

import CryptoKit
import Foundation

public struct Mnemonic {
    public enum Error: Swift.Error {
        case configurationError(String)
        case valueError(String)
        case lookupError(String)
        case rng(String)
    }
    
    private let wordlist: Wordlist
    private let delimiter: String
    
    init(wordlist: Wordlist) {
        self.wordlist = wordlist
        switch wordlist {
        case .japanese:
            self.delimiter = "\u{3000}"
        default:
            self.delimiter = " "
        }
    }
    
    public static func normalizeString(txt: String) -> String {
        return txt.decomposedStringWithCompatibilityMapping
    }
    
    static func listLanguages() -> [String] {
        return Wordlist.StandardWordlist.allCases.map { $0.rawValue }
    }
    
    public static func detectLanguage(code: String) throws -> String {
        let normalizedCode = normalizeString(txt: code)
        let words = normalizedCode.components(separatedBy: " ")
        
        
        var possible = Set(Wordlist.StandardWordlist.allCases)
        for word in words {
            possible = Set(possible.filter { $0.symbol.hasWordThatStartWith(possiblePrefix: word) })
            if possible.isEmpty {
                throw Error.configurationError("Language unrecognized for \(word)")
            }
        }
        
        if possible.count == 1 {
            return possible.popFirst()!.rawValue
        }
        
        var complete = Set<Wordlist.StandardWordlist>()
        for word in words {
            let exact = Set(possible.filter { $0.symbol.words.contains(word) })
            if exact.count == 1 {
                complete = complete.union(exact)
            }
        }
        if complete.count == 1 {
            return complete.popFirst()!.rawValue
        }
        
        throw Error.configurationError("Language ambiguous between \(possible)")
    }
    
    public func generate(strength: Int = 128) throws -> String {
        guard [128, 160, 192, 224, 256].contains(strength) else {
            throw Error.valueError("Invalid strength value. Allowed values are [128, 160, 192, 224, 256].")
        }
        
        var bytes = [UInt8](repeating: 0, count: strength / 8)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        guard status == errSecSuccess else {
            throw Error.rng("SecRandomCopyBytes was not successful")
        }
        
        return try toMnemonic(data: bytes)
    }
    
    public func toEntropy(words: String) throws -> [UInt8] {
        return try toEntropy(words: words.components(separatedBy: delimiter))
    }
    
    public func toEntropy(words: [String]) throws -> [UInt8] {
        guard [12, 15, 18, 21, 24].contains(words.count) else {
            throw Error.valueError("Number of words must be one of the following: [12, 15, 18, 21, 24], but it is not (\(words.count)."
            )
        }
        
        var hashBits: UInt8 = 0
        var hashBitsCount: UInt8 = 0
        var bytes = [UInt8]()
        bytes.reserveCapacity(Int((Float(words.count) * 10.99) / 8) + 1)
        
        for word in words {
            guard let index = wordlist[word] else {
                throw Error.lookupError("Unable to find \"\(word)\" in word list.")
            }
            let remainderCount = hashBitsCount + 3
            bytes.append(hashBits + UInt8(index >> remainderCount))
            if remainderCount >= 8 {
                hashBitsCount = remainderCount - 8
                bytes.append(UInt8(truncatingIfNeeded: index >> hashBitsCount))
            } else {
                hashBitsCount = remainderCount
            }
            hashBits = UInt8(truncatingIfNeeded: index << (8 - hashBitsCount))
        }
        if words.count < 24 {
            bytes.append(hashBits)
        }
        
        let checksum = bytes.last!
        let entropy: [UInt8] = bytes.dropLast()
        let calculated = try Mnemonic.calculateChecksumBits(entropy: entropy)
        
        guard checksum == (calculated.checksum << (8 - calculated.bits)) else {
            throw Error.valueError("Failed checksum.")
        }
        
        return entropy
    }
    
    public func toMnemonic(data: [UInt8]) throws -> String {
        guard [16, 20, 24, 28, 32].contains(data.count) else {
            throw Error.valueError("Data length should be one of the following: [16, 20, 24, 28, 32], but it is not {\(data.count)}.")
        }
        
        let (checksum, csBits) = try Self.calculateChecksumBits(entropy: data)
        var bytes = [UInt8]()
        bytes.reserveCapacity(data.count + 1)
        bytes.append(contentsOf: data)
        bytes.append(checksum << (8 - csBits))
        
        var phrase = [String]()
        phrase.reserveCapacity((bytes.count * 8 + csBits) / 11)
        
        var hBits = (UInt16(bytes[0]) << 3)
        var hBitsCount: UInt8 = 8
        bytes.withUnsafeBufferPointer { pointer in
            for byte in pointer.suffix(from: 1) {
                let remainderBitsCount = Int8(hBitsCount) - 3
                
                if remainderBitsCount >= 0 {
                    let index = hBits + (UInt16(byte) >> remainderBitsCount)
                    hBits = UInt16(byte << (8 - remainderBitsCount)) << 3
                    hBitsCount = UInt8(remainderBitsCount)
                    phrase.append(wordlist[index])
                } else {
                    hBits = hBits + (UInt16(byte) << abs(Int32(remainderBitsCount)))
                    hBitsCount += 8
                }
            }
        }
        
        return phrase.joined(separator: delimiter)
    }
    
    public func check(mnemonic: String) -> Bool {
        do {
            let _ = try toEntropy(words: mnemonic)
            
            return true
        } catch {
            return false
        }
    }
    
    public func expandWord(prefix: String) -> String {
        if wordlist.words.contains(prefix) {
            return prefix
        }
        
        let matches = wordlist.words.filter { $0.starts(with: prefix) }
        if matches.count == 1 {
            return matches.first!
        }
        
        return prefix
    }
    
    public func expand(mnemonic: String) -> String {
        return mnemonic.components(separatedBy: " ").map { expandWord(prefix: $0) }.joined(separator: delimiter)
    }
    
    public static func toSeed(mnemonic: String, passphrase: String = "") -> [UInt8] {
        let mnemonic = normalizeString(txt: mnemonic)
        let salt = normalizeString(txt: "mnemonic" + passphrase)
        
        return try! PKCS5.PBKDF2SHA512(password: mnemonic, salt: salt)
    }
    
    private static func calculateChecksumBits(entropy: [UInt8]) throws -> (checksum: UInt8, bits: Int) {
        guard entropy.count > 0, entropy.count <= 32, entropy.count % 4 == 0 else {
            throw Error.valueError("Failed checksum.")
        }
        
        let hash = Data(SHA256.hash(data: entropy))
        let size = entropy.count / 4
        
        return (hash[0] >> (8 - size), size)
    }
}
