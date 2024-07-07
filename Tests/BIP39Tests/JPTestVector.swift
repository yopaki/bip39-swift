//
//  JPTestVector.swift
//
//
//  Created by Carlos Chida on 09/07/24.
//

import Foundation

internal struct JPTestVector: Decodable {
    var entropy: String
    var mnemonic: String
    var passphrase: String
    var seed: String
    var bip32_xprv: String
}
