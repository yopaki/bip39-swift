//
//  PKCS5.swift
//
//
//  Created by Carlos Chida on 07/07/24.
//

import Foundation
import CryptoKit
import CommonCrypto

internal struct PKCS5 {
    internal enum Error: Swift.Error {
        case invalidInput
    }
    
    public static func PBKDF2SHA512(password: String, salt: String, rounds: Int = 2048, keyByteCount: Int = 64) throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: keyByteCount)
        try bytes.withUnsafeMutableBytes { (outputBytes: UnsafeMutableRawBufferPointer) in
            let status = CCKeyDerivationPBKDF(
                CCPBKDFAlgorithm(kCCPBKDF2),
                password,
                password.utf8.count,
                salt,
                salt.utf8.count,
                CCPBKDFAlgorithm(kCCPRFHmacAlgSHA512),
                UInt32(rounds),
                outputBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                keyByteCount
            )
            
            guard status == kCCSuccess else {
                throw Error.invalidInput
            }
        }
        
        return bytes
    }
}
