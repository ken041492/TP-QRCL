//
//  RouterSecResponse.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation

public struct RouterSecResponse: Decodable {
        
    public var sso_id: String // 加密後的使用者的 apex_id
    
    public var sso_token: String // SSO
}
