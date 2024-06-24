//
//  Random.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import CryptoKit
import Foundation

class Random {
    
    static func randonToken() {
        let tokenData = try! Data.random(length: 64)
        UserPreferences.shared.token = tokenData
        let token = tokenData.base64EncodedString().base64ToBase64url()
        UserPreferences.shared.tokenString = token
        print(token)
    }
    
    private static func randomPassword(pwdLength: Int) -> String {
        let pwdLetters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var passWord = ""
        for _ in 0 ..< pwdLength {
            passWord.append(pwdLetters.randomElement()!)
        }
        return passWord
    }
    
    static func randonEncKey() -> (password: String, key: Data, iv: Data) {
        let password = Random.randomPassword(pwdLength: 6)
        let paswordData = password.data(using: .utf8)
        let key = SHA256.hash(data: paswordData!).data
        let iv = Insecure.MD5.hash(data: paswordData!).data
        return(password, key, iv)
    }
}
