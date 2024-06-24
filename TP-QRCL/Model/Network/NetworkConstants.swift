//
//  NetworkConstants.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Foundation

public struct NetworkConstants {
    
    public static let baseUrl = "https://"
    
    public static let tekPassUrl = "tekpass.com.tw/sso?"
    
    public static let receiverUrl = "receiver="
    
    public static let tokenUrl = "&token="
    
    public static let userKey = "HsWHbfqtCPcVMRxvVwqP8NeUpTbF4sz6"
    
    public enum HttpHeaderField: String {
        case authentication = "Authorization"
        case contentType = "Content-Type"
        case acceptType = "Accept"
        case acceptEncoding = "Accept-Encoding"
        case userKey = "User-Key"
    }
    
    public enum ContentType: String {
        case json = "application/json"
        case xml = "application/xml"
        case textPlain = "text/plain"
        case x_www_form_urlencoded = "application/x-www-form-urlencoded"
    }
}

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public enum RequestError: Error {
    
    /// HTTP Status Code 400
    case badRequest
    
    /// HTTP Status Code 401
    case authorizationError
    
    /// HTTP Status Code 404
    case notFound
    
    /// HTTP Status Code 500
    case internalError
    
    /// HTTP Status Code 502
    case badGateway
    
    /// HTTP Status Code 503
    case serverUnavailable
    
    /// Unknown Error
    case unknownError(Error)
    
    /// ConnectionError
    case connectionError
    
    /// invalidResponse
    case invalidResponse
    
    /// JSON Decode Failed
    case jsonDecodeFailed(Error)
}


public enum ApiPathConstants: String {
    
    case verifyApexSSOServer = "apex.cmoremap.com.tw/pm_apex/apex_sso_for_test.php"
    
    case routerSec = "/cgi-bin/TekpassResult"
}
