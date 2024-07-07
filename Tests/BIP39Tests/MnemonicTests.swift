//
//  MnemonicTests.swift
//
//
//  Created by Carlos Chida on 07/07/24.
//

import CommonCrypto
import CryptoKit
import XCTest
@testable import BIP39

func generateRandomBytes(count: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)
    let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
    guard status == errSecSuccess else {
        fatalError("SecRandomCopyBytes was not successful")
    }
    
    return bytes
}

final class MnemonicTests: XCTestCase {
    private func assertTrezorTestVecor(wordlist: Wordlist, vectors: [[String]], language: String) {
        let mnemonic = Mnemonic(wordlist: wordlist)
        for vector in vectors {
            let code = try! mnemonic.toMnemonic(data: Array(vector[0].hex!))
            let seed = Mnemonic.toSeed(mnemonic: code, passphrase: "TREZOR")
//            let xprv = Mnemonic.toHDMasterKey(seed)
            
            XCTAssertEqual(vector[1], code, language)
            XCTAssertEqual(Array(vector[2].hex!), seed, language)
//            XCTAssertEqual(vector[3], xprv)
        }
    }
    
    private func assertJPTestVector(vector: JPTestVector) {
        let mnemonic = Mnemonic(wordlist: .japanese)
        
        let code = try! mnemonic.toMnemonic(data: Array(vector.entropy.hex!))
        let seed = Mnemonic.toSeed(mnemonic: code, passphrase: vector.passphrase)
        
        XCTAssertEqual(vector.mnemonic, code)
        XCTAssertEqual(Array(vector.seed.hex!), seed)
    }
    
    func testTrezorVectors() {
        let url = Bundle.module.url(forResource: "vectors", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let o = try! JSONDecoder().decode(TrezorTestCaseVectors.self, from: data)
        
        assertTrezorTestVecor(wordlist: .chineseSimplified, vectors: o.chinese_simplified, language: "chinese_simplified")
        assertTrezorTestVecor(wordlist: .chineseTraditional, vectors: o.chinese_traditional, language: "chinese_traditional")
        assertTrezorTestVecor(wordlist: .czech, vectors: o.czech, language: "czech")
        assertTrezorTestVecor(wordlist: .english, vectors: o.english, language: "english")
        assertTrezorTestVecor(wordlist: .french, vectors: o.french, language: "french")
        assertTrezorTestVecor(wordlist: .italian, vectors: o.italian, language: "italian")
        assertTrezorTestVecor(wordlist: .japanese, vectors: o.japanese, language: "japanese")
        assertTrezorTestVecor(wordlist: .korean, vectors: o.korean, language: "korean")
        assertTrezorTestVecor(wordlist: .portuguese, vectors: o.portuguese, language: "portuguese")
        // Enable when test vectors are available
//        checkList(wordlist: .russian, vectors: o.russian, language: "russian")
        assertTrezorTestVecor(wordlist: .spanish, vectors: o.spanish, language: "spanish")
        // Enable when test vectors are available
//        checkList(wordlist: .turkish, vectors: o.turkish, language: "turkish")
        
    }
    
    func testBIP32JPVectors() {
        let url = Bundle.module.url(forResource: "test_JP_BIP39", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let testVectors = try! JSONDecoder().decode([JPTestVector].self, from: data)
        
        for vector in testVectors {
            assertJPTestVector(vector: vector)
        }
    }
    
    func testFailedChecksum() {
        let code = "bless cloud wheel regular tiny venue bird web grief security dignity zoo"
        let mnemo = Mnemonic(wordlist: .english)
        XCTAssertFalse(mnemo.check(mnemonic: code))
    }
    
    func testDetection() {
        XCTAssertEqual("english", try! Mnemonic.detectLanguage(code: "security"))
        
        
        XCTAssertEqual("english", try! Mnemonic.detectLanguage(code: "fruit wave dwarf")) // Ambiguous up to wave
        XCTAssertEqual("english", try! Mnemonic.detectLanguage(code: "fru wago dw")) // Ambiguous French/English up to dwarf prefix
        XCTAssertEqual("french", try! Mnemonic.detectLanguage(code: "fru wago dur enje")) // Ambiguous French/English up to enjeu prefix
       
        XCTAssertThrowsError(try Mnemonic.detectLanguage(code: "jaguar xxxxxxx"))  // Unrecognized in any known language
        XCTAssertThrowsError(try Mnemonic.detectLanguage(code: "jaguar jaguar")) // Ambiguous after examining all words
        
        // Allowing word prefixes in language detection presents ambiguity issues. Require exactly one language that matches all prefixes, or one language matching some word(s) exactly.
        XCTAssertEqual("english", try! Mnemonic.detectLanguage(code: "jaguar security"))
        XCTAssertEqual("french", try! Mnemonic.detectLanguage(code: "jaguar aboyer"))
        XCTAssertEqual("english", try! Mnemonic.detectLanguage(code: "abandon about"))
        XCTAssertEqual("french", try! Mnemonic.detectLanguage(code: "abandon aboutir"))
        XCTAssertEqual("french", try! Mnemonic.detectLanguage(code: "fav financer"))
        XCTAssertEqual("czech", try! Mnemonic.detectLanguage(code: "fav finance"))
        XCTAssertThrowsError(try Mnemonic.detectLanguage(code: "favor finan"))
        XCTAssertEqual("czech", try! Mnemonic.detectLanguage(code: "flanel"))
        XCTAssertEqual("portuguese", try! Mnemonic.detectLanguage(code: "flanela"))
        XCTAssertThrowsError(try Mnemonic.detectLanguage(code: "flane"))
        
        // Extra (missing languages)
        XCTAssertEqual("chinese_simplified", try! Mnemonic.detectLanguage(code: "个"))
        XCTAssertEqual("chinese_traditional", try! Mnemonic.detectLanguage(code: "國"))
        XCTAssertEqual("italian", try! Mnemonic.detectLanguage(code: "abbaglio"))
        XCTAssertEqual("japanese", try! Mnemonic.detectLanguage(code: "あいさ"))
        XCTAssertEqual("korean", try! Mnemonic.detectLanguage(code: "가"))
        XCTAssertEqual("russian", try! Mnemonic.detectLanguage(code: "а")) // This is NOT a latin 'a'
        XCTAssertEqual("spanish", try! Mnemonic.detectLanguage(code: "á"))
        XCTAssertEqual("turkish", try! Mnemonic.detectLanguage(code: "abaj"))
    }
    
    func testUtf8NFKD() {
        //# The same sentence in various UTF-8 forms
        let words_nfkd = "Pr\u{030c}i\u{0301}s\u{030c}erne\u{030c} z\u{030c}lut\u{030c}ouc\u{030c}ky\u{0301} ku\u{030a}n\u{030c} u\u{0301}pe\u{030c}l d\u{030c}a\u{0301}belske\u{0301} o\u{0301}dy za\u{0301}ker\u{030c}ny\u{0301} uc\u{030c}en\u{030c} be\u{030c}z\u{030c}i\u{0301} pode\u{0301}l zo\u{0301}ny u\u{0301}lu\u{030a}"
        let words_nfc = "P\u{0159}\u{ed}\u{0161}ern\u{011b} \u{017e}lu\u{0165}ou\u{010d}k\u{fd} k\u{016f}\u{0148} \u{fa}p\u{011b}l \u{010f}\u{e1}belsk\u{e9} \u{f3}dy z\u{e1}ke\u{0159}n\u{fd} u\u{010d}e\u{0148} b\u{011b}\u{017e}\u{ed} pod\u{e9}l z\u{f3}ny \u{fa}l\u{016f}"
        let words_nfkc = "P\u{0159}\u{ed}\u{0161}ern\u{011b} \u{017e}lu\u{0165}ou\u{010d}k\u{fd} k\u{016f}\u{0148} \u{fa}p\u{011b}l \u{010f}\u{e1}belsk\u{e9} \u{f3}dy z\u{e1}ke\u{0159}n\u{fd} u\u{010d}e\u{0148} b\u{011b}\u{017e}\u{ed} pod\u{e9}l z\u{f3}ny \u{fa}l\u{016f}"
        let words_nfd = "Pr\u{030c}i\u{0301}s\u{030c}erne\u{030c} z\u{030c}lut\u{030c}ouc\u{030c}ky\u{0301} ku\u{030a}n\u{030c} u\u{0301}pe\u{030c}l d\u{030c}a\u{0301}belske\u{0301} o\u{0301}dy za\u{0301}ker\u{030c}ny\u{0301} uc\u{030c}en\u{030c} be\u{030c}z\u{030c}i\u{0301} pode\u{0301}l zo\u{0301}ny u\u{0301}lu\u{030a}"

        let  passphrase_nfkd = "Neuve\u{030c}r\u{030c}itelne\u{030c} bezpec\u{030c}ne\u{0301} hesli\u{0301}c\u{030c}ko"
        let passphrase_nfc = "Neuv\u{011b}\u{0159}iteln\u{011b} bezpe\u{010d}n\u{e9} hesl\u{ed}\u{010d}ko"
        let passphrase_nfkc = "Neuv\u{011b}\u{0159}iteln\u{011b} bezpe\u{010d}n\u{e9} hesl\u{ed}\u{010d}ko"
        let passphrase_nfd = "Neuve\u{030c}r\u{030c}itelne\u{030c} bezpec\u{030c}ne\u{0301} hesli\u{0301}c\u{030c}ko"

        let seed_nfkd = Mnemonic.toSeed(mnemonic: words_nfkd, passphrase: passphrase_nfkd)
        let seed_nfc = Mnemonic.toSeed(mnemonic: words_nfc, passphrase: passphrase_nfc)
        let seed_nfkc = Mnemonic.toSeed(mnemonic: words_nfkc, passphrase: passphrase_nfkc)
        let seed_nfd = Mnemonic.toSeed(mnemonic: words_nfd, passphrase: passphrase_nfd)

        XCTAssertEqual(seed_nfkd, seed_nfc)
        XCTAssertEqual(seed_nfkd, seed_nfkc)
        XCTAssertEqual(seed_nfkd, seed_nfd)
    }
    
    func testToEntropy() {
        let m = Mnemonic(wordlist: .english)
        
        var data =  [[UInt8]](repeating: [UInt8](repeating: 0, count: 32), count: 1025)
        for i in 0..<1024 {
            data[i] = generateRandomBytes(count: 32)
        }
        data[1024] = Array("Lorem ipsum dolor sit amet amet.".utf8)
        
        for d in data {
            XCTAssertEqual(try! m.toEntropy(words: m.toMnemonic(data: d)), d)
        }
    }
    
    func testExpandWord() {
        let m = Mnemonic(wordlist: .english)
        
        XCTAssertEqual("", m.expandWord(prefix: ""))
        XCTAssertEqual(" ", m.expandWord(prefix: " "))
        XCTAssertEqual("access", m.expandWord(prefix: "access")) // word in list
        XCTAssertEqual("access", m.expandWord(prefix: "acce")) // unique prefix expanded to word in list
        XCTAssertEqual("acb", m.expandWord(prefix: "acb")) // not found at all
        XCTAssertEqual("acc", m.expandWord(prefix: "acc")) // multi-prefix match
        XCTAssertEqual("act", m.expandWord(prefix: "act")) // exact three-letter match
        XCTAssertEqual("action", m.expandWord(prefix: "acti")) // unique prefix expanded to word in list
    }
    
    func testExpand() {
        let m = Mnemonic(wordlist: .english)
        
        XCTAssertEqual("access", m.expand(mnemonic: "access"))
        XCTAssertEqual("access access acb acc act action", m.expand(mnemonic: "access acce acb acc act acti"))
    }
}
