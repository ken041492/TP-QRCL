//
//  CheckUpdate.swift
//  TP-QRCL
//
//  Created by imac-3570 on 2025/5/14.
//

import Foundation
import AppKit


// MARK: - Enum Errors

enum VersionError: Error {
    
    case invalidBundleInfo, invalidResponse, dataError
    
}

// MARK: - Models

struct LookupResult: Decodable {
    
    let data: [TestFlightInfo]?
    
    let results: [AppInfo]?
}

struct TestFlightInfo: Decodable {
    
    let type: String
    
    let attributes: Attributes
}

struct Attributes: Decodable {
    
    let version: String
    
    let expired: String
}

struct AppInfo: Decodable {
    
    let version: String
    
    let trackViewUrl: String
}

// MARK: - Check Update Class

class CheckUpdate: NSObject {
    
    // MARK: - Singleton
    
    static let shared = CheckUpdate()
    
    // MARK: - TestFlight variable
    
    var isTestFlight: Bool = false
    
    // Id Example
    static let appStoreId = "6502514601"

    func showUpdate(withConfirmation: Bool, isTestFlight: Bool = false) {
        self.isTestFlight = isTestFlight
        DispatchQueue.global().async {
            self.checkVersion(force: !withConfirmation)
        }
    }

    private func checkVersion(force: Bool) {
        guard let currentVersion = getBundle(key: "CFBundleShortVersionString") else {
            print("無法取得 App 當前的版本")
            return
        }
        
        print("CurrentVersion: \(currentVersion)")

        _ = getAppInfo { (data, info, error) in
            let store = self.isTestFlight ? "TestFlight" : "AppStore"
            if let appStoreAppVersion = info?.version {
                if appStoreAppVersion > currentVersion {
                    DispatchQueue.main.async {
                        self.showAppUpdateAlert(version: appStoreAppVersion, force: force, appURL: info?.trackViewUrl ?? "", isTestFlight: self.isTestFlight)
                    }
                }
            } else {
                print("找不到 App 在 \(store) 的版本")
            }
        }
    }

    @MainActor
    private func showAppUpdateAlert(version: String, force: Bool, appURL: String, isTestFlight: Bool) {
        let alert = NSAlert()
        alert.messageText = "有新版本"
        alert.informativeText = "有新的 TP-QRCL 可在 \(isTestFlight ? "TestFlight" : "AppStore") 進行更新，是否要進行更新？"
        alert.addButton(withTitle: "現在更新")
        
        if !force {
            alert.addButton(withTitle: "先不要")
        }
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: appURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    private func getUrl(from identifier: String) -> String {
        let testflightURL = "https://api.appstoreconnect.apple.com/v1/apps/\(CheckUpdate.appStoreId)/builds"
        
        // 需要注意 App 在哪一個地區，這邊以台灣為主，**/tw/**
        let appStoreURL = "http://itunes.apple.com/tw/lookup?bundleId=\(identifier)"
        
        return isTestFlight ? testflightURL : appStoreURL
    }
    
    private func getAppInfo(completion: @escaping (TestFlightInfo?, AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        
        guard let identifier = self.getBundle(key: "CFBundleIdentifier"),
              let url = URL(string: getUrl(from: identifier)) else {
            DispatchQueue.main.async {
                completion(nil, nil, VersionError.invalidBundleInfo)
            }
            return nil
        }
        
        // 需要產生授權 token 存取 TestFlight 版本並直接取代 JWT token 的 ```***```.
        // https://developer.apple.com/documentation/appstoreconnectapi/generating_tokens_for_api_requests
        
        let authorization = "Bearer ***"
        var request = URLRequest(url: url)
        
        // 要存取 TestFlight 版本的話，需要新增一個 authorization header
        if self.isTestFlight {
            request.setValue(authorization, forHTTPHeaderField: "Authorization")
        }
        
        // 打請求
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            do {
                if let error = error {
                    print(error)
                    throw error
                }
                guard let data = data else { throw VersionError.invalidResponse }
                
                let result = try JSONDecoder().decode(LookupResult.self, from: data)
                print(result)
                
                if self.isTestFlight {
                    let info = result.data?.first
                    completion(info, nil, nil)
                } else {
                    let info = result.results?.first
                    completion(nil, info, nil)
                }
            } catch {
                completion(nil, nil, error)
            }
        }
        
        task.resume()
        return task
        
    }

    private func getBundle(key: String) -> String? {
        guard let value = Bundle.main.infoDictionary?[key] as? String else {
            fatalError("Couldn't find key '\(key)' in 'Info.plist'.")
        }
        return value
    }
}

