//
//  FirebaseRealtimeDatabase.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation
import FirebaseDatabase
import CryptoKit
import FirebaseAuth

class FirebaseRealtimeDatabase: NSObject {
    
    static let shared = FirebaseRealtimeDatabase()
    
    var databaseRef: DatabaseReference!
    
    /// 監聽 Firebase Realtime Database 資料
    /// Firebase Realtime Database 架構
    ///   - sso:
    ///     - MAC位置:TPFILE
    ///       - sso_id
    ///       - sso_token
    ///       - timestamp
    func authVerify(finish: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: "aw@tekpass.com.tw",
                           password: "A!8k6kC%$42o67@J4#K!") { result, error in
            if error != nil {
                print(error)
                finish(.failure(error!))
            } else {
                finish(.success("s"))
            }
        }
    }
    
    func listen(finish: @escaping (Result<String,Error>) -> Void) {
        
        UserPreferences.shared.ssoid = ""
        UserPreferences.shared.ssotoken = ""
        UserPreferences.shared.apex_id = ""
        
        databaseRef = Database.database().reference().child("sso")
        
        databaseRef.child(UserPreferences.shared.macAddress).observe(.value, with: { snapshot in
            // 這裡的 snapshot 是一個 DataSnapshot 的實例
            // 你可以遍歷這個 snapshot 來獲取你需要的數據
            print(snapshot)
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot {
                    switch childSnapshot.key {
                    case "sso_id":
                        UserPreferences.shared.ssoid = childSnapshot.value as! String
                        print(UserPreferences.shared.ssoid)
                    case "sso_token":
                        UserPreferences.shared.ssotoken = childSnapshot.value as! String
                        print(UserPreferences.shared.ssotoken)
                    case "timestamp":
                        let timestamp: Double = childSnapshot.value as! Double
                        if Date().timeIntervalSince1970 - timestamp/1000 > 300 {
                            UserPreferences.shared.ssoid = ""
                            UserPreferences.shared.ssotoken = ""
                        }
                    default:
                        break
                    }
                }
            }
            
            if !UserPreferences.shared.ssoid.isEmpty && !UserPreferences.shared.ssotoken.isEmpty {
                self.getApexID { result in
                    switch result {
                    case .success(_):
                        finish(.success("s"))
                    case .failure(let response):
                        print("fail")
//                        finish(.failure(response))
                    }
                }
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func stopListen() {
        databaseRef = Database.database().reference().child("sso")
        databaseRef.child(UserPreferences.shared.macAddress).removeAllObservers()
    }
    
    func getApexID(finish: @escaping (Result<String, Error>) -> Void) {

        // 從產生的 token 取得 key iv
        let keyData = UserPreferences.shared.token.subdata(in: 0 ..< 32)
        let ivData = UserPreferences.shared.token.subdata(in: 32 ..< 48)


        let key = SymmetricKey(data: keyData)
        let iv = try! AES.GCM.Nonce(data: ivData)

        let cipherData = Data(base64Encoded: UserPreferences.shared.ssoid.base64urlToBase64())
        print(cipherData)
        var ciphertext: Data?
        var authTag: Data?
        if cipherData!.count < 43 {
            ciphertext = cipherData
            authTag = Data(count: 16)
        } else {
            ciphertext = cipherData?.subdata(in: 0 ..< cipherData!.endIndex - 16)
            authTag = cipherData?.suffix(16)
        }

        print(ciphertext)
        print(authTag)
        
        UserPreferences.shared.apex_id = CryptoManager.aesGCMDecrypt(ciphertext:ciphertext!,
                                                                     nonce: iv,
                                                                     tag: authTag!,
                                                                     key: key) ?? ""
        print(UserPreferences.shared.apex_id)

        Task {
            do {
                try await NetworkManager.callVerifyApexSSO()
                finish(.success("s"))
            } catch {
                print(error)
                finish(.failure(error))
            }
        }
    }
}

