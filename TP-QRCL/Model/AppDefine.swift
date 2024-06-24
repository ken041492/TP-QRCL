//
//  AppDefine.swift
//  TP-FILE
//
//  Created by imac-3700 on 2023/12/21.
//

import Foundation

struct AppDefine {
    
    static var bundleId: String {
        guard let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
            return ""
        }
        return bundleId
    }
    
    /// 加密 / 解密模式
    enum CryptoOperationMode {
        
        /// 加密
        case encrypt
        
        /// 解密
        case decrypt
    }
}
