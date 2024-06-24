//
//  NSData+Extension.swift
//  TP-FILE
//
//  Created by imac-3700 on 2023/11/1.
//

import Foundation

extension NSData {
    static func randomData(ofLength length: Int) -> NSData? {
        var data = Data(count: length)
        let result = data.withUnsafeMutableBytes { bytes -> Int32 in
            SecRandomCopyBytes(kSecRandomDefault, length, bytes.baseAddress!)
        }
        return (result == errSecSuccess) ? NSData(data: data) : nil
    }
}
