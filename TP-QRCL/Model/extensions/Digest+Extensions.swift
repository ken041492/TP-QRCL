//
//  Digest+extensions.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation
import CryptoKit

public extension Digest {
    
    var bytes: [UInt8] { Array(makeIterator()) }
    
    var data: Data { Data(bytes) }

    var hexStr: String {
        bytes.map { String(format: "%02X", $0) }.joined()
    }
}
