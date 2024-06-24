//
//  Encodable+Extensions.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation

public extension Encodable {
    
    /// 將 Encodable 轉換成 Dictionary<String, Any>
    func asDictionary() throws -> [String : Any] {
        let data = try JSONEncoder().encode(self)
        
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .allowFragments) as? [String : Any] else {
            throw NSError()
        }
        
        return dictionary
    }
}
