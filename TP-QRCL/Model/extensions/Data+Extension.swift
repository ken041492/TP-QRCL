//
//  Data+Extension.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation

public extension Data {
    
    /// Hexadecimal string representation of `Data` object.
    var hexadecimal: String {
        return map { String(format: "%02x", $0) }.joined()
    }
    
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
    
    static func random(length: Int) throws -> Data {
        return Data((0 ..< length).map { _ in
            UInt8.random(in: UInt8.min ... UInt8.max)
        })
    }
}
