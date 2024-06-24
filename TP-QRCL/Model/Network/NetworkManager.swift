//
//  NetworkManager.swift
//  FullScreenDemo
//
//  Created by imac-3700 on 2024/3/11.
//

import Foundation
import SwiftyPing

class NetworkManager: NSObject {
    static let shared = NetworkManager()
    
    func getLocalIPAddress(finish: @escaping(String?) -> Void) {
        let ping = try? SwiftyPing(host: "8.8.8.8",
                                   configuration: PingConfiguration(interval: 0.5, with: 5),
                                   queue: .global())
        ping!.observer = { response in
            if let destAddr = response.ipHeader?.destinationAddress {
                let getip = "\(destAddr.0).\(destAddr.1).\(destAddr.2).\(destAddr.3)"
                print("ip:\(getip)")
                finish(getip)
            } else {
                print("get ip error")
                finish(nil)
            }
        }
        ping?.targetCount = 1
        try! ping?.startPinging()
    }
    
    public static func callVerifyApexSSO() async throws {
        let request = VerifyApexSSO(id: UserPreferences.shared.apex_id,
                                    sso: UserPreferences.shared.ssotoken)
        do {
            try await NetworkManager.shared.requestData(method: .post,
                                                        path: .verifyApexSSOServer,
                                                        parameters: request)
        } catch {
            print(error)
            throw RequestError.badRequest
        }
    }
    
    func findEthernetInterfaces() -> io_iterator_t? {
        
        let matchingDictUM = IOServiceMatching("IOEthernetInterface");
        // Note that another option here would be:
        // matchingDict = IOBSDMatching("en0");
        // but en0: isn't necessarily the primary interface, especially on systems with multiple Ethernet ports.
        
        if matchingDictUM == nil {
            return nil
        }
        let matchingDict = matchingDictUM! as NSMutableDictionary
        matchingDict["IOPropertyMatch"] = [ "IOPrimaryInterface" : true]
        
        var matchingServices : io_iterator_t = 0
        if IOServiceGetMatchingServices(kIOMasterPortDefault, matchingDict, &matchingServices) != KERN_SUCCESS {
            return nil
        }
        
        return matchingServices
    }

    // Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
    // If no interfaces are found the MAC address is set to an empty string.
    // In this sample the iterator should contain just the primary interface.
    func getMACAddress(intfIterator : io_iterator_t) -> [UInt8]? {
        
        var macAddress : [UInt8]?
        
        var intfService = IOIteratorNext(intfIterator)
        while intfService != 0 {
            
            var controllerService : io_object_t = 0
            if IORegistryEntryGetParentEntry(intfService, "IOService", &controllerService) == KERN_SUCCESS {
                
                let dataUM = IORegistryEntryCreateCFProperty(controllerService, "IOMACAddress" as CFString, kCFAllocatorDefault, 0)
                if dataUM != nil {
                    let data = dataUM!.takeRetainedValue() as! NSData
                    macAddress = [0, 0, 0, 0, 0, 0]
                    data.getBytes(&macAddress!, length: macAddress!.count)
                }
                IOObjectRelease(controllerService)
            }
            
            IOObjectRelease(intfService)
            intfService = IOIteratorNext(intfIterator)
        }
        
        return macAddress
    }


    
    
    public func requestData<E: Encodable>(method: HTTPMethod,
                                          path: ApiPathConstants,
                                          parameters: E) async throws {
        let urlRequest = handleHTTPMethod(method: method, path: path, parameters: parameters)
        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            guard let response = (response as? HTTPURLResponse) else {
                throw RequestError.invalidResponse
            }
            let statusCode = response.statusCode
            guard (200 ... 299).contains(statusCode) else {
                switch statusCode {
                case 400:
                    print("fail")
                    throw RequestError.badRequest
                case 401:
                    throw RequestError.authorizationError
                case 404:
                    throw RequestError.notFound
                case 500:
                    throw RequestError.internalError
                case 502:
                    throw RequestError.badGateway
                case 503:
                    throw RequestError.serverUnavailable
                default:
                    throw RequestError.invalidResponse
                }
            }
        } catch {
            throw RequestError.unknownError(error)
        }
    }
    
    private func handleHTTPMethod<E: Encodable>(method: HTTPMethod,
                                                path: ApiPathConstants,
                                                parameters: E) -> URLRequest {
        let baseURL = NetworkConstants.baseUrl
        let url = URL(string: baseURL + path.rawValue)!
        
        var urlRequest = URLRequest(url: url)
        let httpType = NetworkConstants.ContentType.x_www_form_urlencoded.rawValue
        let userKey = NetworkConstants.userKey
        
        urlRequest.allHTTPHeaderFields = [
            NetworkConstants.HttpHeaderField.contentType.rawValue : httpType
        ]
        
        urlRequest.httpMethod = method.rawValue
        
        let dict1 = try? parameters.asDictionary()
        
        switch method {
        case .get:
            let parameters = dict1 as? [String : String]
            urlRequest.url = requestWithURL(urlString: urlRequest.url?.absoluteString ?? "",
                                            parameters: parameters ?? [:])
        case .post:
            let parameters = dict1 as? [String : String]
            urlRequest.httpBody = requestWithURLQueryItem(parameters: parameters ?? [:])
        default:
            break
        }
        return urlRequest
    }
    
    private func requestWithURL(urlString: String,
                                parameters: [String : String]?) -> URL? {
        guard var urlComponents = URLComponents(string: urlString) else {
            return nil
        }
        urlComponents.queryItems = []
        parameters?.forEach { (key, value) in
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        return urlComponents.url
    }
    
    func requestWithURLQueryItem(parameters: [String : String]) -> Data? {
        var urlComponents = URLComponents()
        urlComponents.queryItems = []
        parameters.forEach { (key, value) in
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        return urlComponents.query?.data(using: .utf8)
    }
}
