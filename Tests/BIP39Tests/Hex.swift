//
//  Hex.swift
//
//
//  Created by Carlos Chida on 07/07/24.
//

import Foundation

internal extension Data {
    init?(hex: String) {
        let hexString = hex.replacingOccurrences(of: " ", with: "").dropFirst(hex.hasPrefix("0x") ? 2 : 0)
        let len = hexString.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hexString.index(hexString.startIndex, offsetBy: i*2)
            let k = hexString.index(j, offsetBy: 2)
            let bytes = hexString[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }
    
    var hex: String {
        self.map { String(format: "%02x", $0) }.joined(separator: " ")
    }
}

internal extension String {
    var hex: Data? {
        return Data(hex: self)
    }
}
