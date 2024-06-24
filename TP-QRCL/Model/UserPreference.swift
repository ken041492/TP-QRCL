//
//  UserPreference.swift
//  TP-FILE
//
//  Created by imac-3700 on 2023/10/2.
//

import Foundation

class UserPreferences {
    
    static let shared = UserPreferences()
    
    var macAddress: String {
        get { return UserDefaults.standard.string(forKey: "macAddress") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "macAddress") }
    }
    
    var receiver: Data {
        get { return UserDefaults.standard.data(forKey: "receiver")! }
        set { UserDefaults.standard.set(newValue, forKey: "receiver") }
    }
    
    var tokenString: String {
        get { return UserDefaults.standard.string(forKey: "tokenString") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "tokenString") }
    }
    
    var token: Data {
        get { return UserDefaults.standard.data(forKey: "token")! }
        set { UserDefaults.standard.set(newValue, forKey: "token") }
    }
    
    var apex_id: String {
        get { return UserDefaults.standard.string(forKey: "apex_id") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "apex_id") }
    }
    
    var ssotoken: String {
        get { return UserDefaults.standard.string(forKey: "ssotoken") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "ssotoken") }
    }
    
    var ssoid: String {
        get { return UserDefaults.standard.string(forKey: "ssoid") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "ssoid") }
    }
    
    var filePath: URL {
        get { return UserDefaults.standard.url(forKey: "filePath")! }
        set { UserDefaults.standard.set(newValue, forKey: "filePath") }
    }
}
