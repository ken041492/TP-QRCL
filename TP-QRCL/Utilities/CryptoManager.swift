//
//  CryptoManager.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import CommonCrypto
import CryptoKit
import Foundation

class CryptoManager {
    
    static func aesGCMEncrypt(plaintext: String,
                              key: SymmetricKey,
                              nonce: AES.GCM.Nonce) -> (ciphertext: Data,
                                                        nonce: AES.GCM.Nonce,
                                                        tag: Data)? {
        guard let plaintextData = plaintext.data(using: .utf8) else {
            return nil
        }
        
        do {
            let sealedBox = try AES.GCM.seal(plaintextData, using: key, nonce: nonce)
            return (sealedBox.ciphertext, sealedBox.nonce, sealedBox.tag)
        } catch {
            print("加密錯誤: \(error)")
            return nil
        }
    }
    
    static func aesGCMDecrypt(ciphertext: Data,
                              nonce: AES.GCM.Nonce,
                              tag: Data,
                              key: SymmetricKey) -> String? {
        
        do {
            let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertext, tag: tag)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("解密錯誤: \(error)")
            return nil
        }
    }
    
    static func aesCBCEncrypt(plain: Data, key: Data, iv: Data) -> Data? {
        
        let plain = plain as NSData
        let key = key as NSData
        let iv = iv as NSData
        
        let bufferSize = plain.length + kCCBlockSizeAES128
        let buffer =  NSMutableData(length: bufferSize)!
        
        var numBytesEncrypted :size_t = 0
        
        let status = CCCrypt(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             key.bytes,
                             key.length,
                             iv.bytes,
                             plain.bytes,
                             plain.length,
                             buffer.mutableBytes,
                             bufferSize,
                             &numBytesEncrypted)
        
        if status == kCCSuccess {
            buffer.length = numBytesEncrypted
            return buffer as Data
        } else {
            return nil
        }
    }
    
    static func aesCBCDecrypt(cipher: Data, key: Data, iv: Data) -> Data? {
        
            let cipher = cipher as NSData
            let key = key as NSData
            let iv = iv as NSData
            
            let bufferSize = cipher.length + kCCBlockSizeAES128
            let buffer =  NSMutableData(length: bufferSize)!
 
            var numBytesEncrypted :size_t = 0
            
            let status = CCCrypt(CCOperation(kCCDecrypt),
                                 CCAlgorithm(kCCAlgorithmAES),
                                 CCOptions(kCCOptionPKCS7Padding),
                                 key.bytes,
                                 key.length,
                                 iv.bytes,
                                 cipher.bytes,
                                 cipher.length,
                                 buffer.mutableBytes,
                                 bufferSize,
                                 &numBytesEncrypted)
            
            if status == kCCSuccess {
                buffer.length = numBytesEncrypted
                return buffer as Data
            } else {
                return nil
            }
    }
    
    static func encryptFile(path: URL, fileKey: Data, fileIV: Data) -> Data? {
        do {
            let fileD = try Data(contentsOf: path)
            guard let encryptData = CryptoManager.aesCBCEncrypt(plain: fileD,
                                                                key: fileKey,
                                                                iv: fileIV) else {
                return nil
            }
            return encryptData
        } catch {
            print(error)
            return nil
        }
    }
    
    static func decryptFile(path: URL, password: String) -> Data? {
        do {
            // tpf 檔由 檔案密文 ＋ 鑰匙密文組成
            let CipherD = try Data(contentsOf: path)
            if CipherD.count < 64 { return nil }
            
            // 取得檔案密文（fileCipher）
            let fileCipher = CipherD.subdata(in: 0 ..< CipherD.endIndex - 64)
            
            // 取得鑰匙密文（filekeyCipher）
            let fileKeyD = CipherD.suffix(64)
            let filekeyCipher = Data(base64Encoded: fileKeyD)
            
            // 使用者輸入的密碼轉換成 key iv
            let paswordData = password.data(using: .utf8)
            let key = SHA256.hash(data: paswordData!).data
            let iv = Insecure.MD5.hash(data: paswordData!).data
            
            // 將 key iv 用aes256cbc解密 鑰匙密文（filekeyCipher）取得 fileKey
            guard let fileKey = CryptoManager.aesCBCDecrypt(cipher: filekeyCipher!, key: key, iv: iv) else {
                return nil
            }
            
            // fileIV 固定 "Emt89TekPass0830"
            let fileIV = "Emt89TekPass0830".data(using: .utf8)
            
            // 將 fileKey fileIV 用aes256cbc解密檔案取得 檔案明文（filePlain）
            guard let filePlain = CryptoManager.aesCBCDecrypt(cipher: fileCipher, key: fileKey, iv: fileIV!) else {
                return nil
            }
            
            return filePlain
        } catch {
            print(error)
            return nil
        }
    }


    
}
