//
//  VerifyApexSSO.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation

public struct VerifyApexSSO: Codable {

    var id: String
    
    var sso: String
    
    public init(id: String, sso: String) {
        self.id = id
        self.sso = sso
    }
}
