//
//  QRCredentialManager.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Cocoa
import CoreImage.CIFilterBuiltins
import Foundation
import Network

class QRCredentialManager {
    
    static func generateQRCode(finish: @escaping(NSImage?) -> Void) {
        
        let baseUrl = NetworkConstants.baseUrl
        let tekpassUrl = NetworkConstants.tekPassUrl
        let receiverUrl = NetworkConstants.receiverUrl
        
        if let intfIterator = NetworkManager.shared.findEthernetInterfaces() {
            if let macAddress = NetworkManager.shared.getMACAddress(intfIterator: intfIterator) {
                let macAddressAsString = macAddress.map( { String(format:"%02x", $0) } ).joined(separator: ":")
                UserPreferences.shared.macAddress = macAddressAsString + ":TPQRCL"
                print(UserPreferences.shared.macAddress)
                IOObjectRelease(intfIterator)
                
                let tokenUrl = NetworkConstants.tokenUrl
                let token = UserPreferences.shared.tokenString
                let urlString = baseUrl + tekpassUrl + receiverUrl +  "fcm://" + macAddressAsString + ":TPQRCL" + tokenUrl + token
                let data = urlString.data(using: String.Encoding.ascii)
                
                let filter = CIFilter.qrCodeGenerator()
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                
                if let output = filter.outputImage?.transformed(by: transform) {
                    finish(convertCIImageToNSImage(ciImage: output))
                }
            }
        }
    }
    
    static func convertCIImageToNSImage(ciImage: CIImage) -> NSImage {
        let rep = NSCIImageRep(ciImage: ciImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
}

