//
//  ScanQrcodeViewController.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/30.
//

import Cocoa

enum Action {
    
    case open
    
    case close
}

class ScanQrcodeViewController: NSViewController {
    
    var action: Action = .open
    
    @IBOutlet weak var lbTitle: NSTextField!
    
    @IBOutlet weak var lbIP: NSTextField!
    
    @IBOutlet weak var imgQrcode: NSImageView!
        
    override func viewDidAppear() {
        
        view.window?.level = .mainMenu
        view.window?.collectionBehavior = [ .stationary, .canJoinAllSpaces]
        view.window?.styleMask = [ .nonactivatingPanel]
        view.window?.setFrame(NSScreen.main!.frame, display: false, animate: false)
        view.window?.orderFrontRegardless()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        generateQRcodeAndWaitAuth()
    }
    
    func setupUI() {
        
        imgQrcode.isHidden = true
        lbTitle.stringValue = "身份驗證中..."
        lbIP.stringValue = ""
    }
    
    func generateQRcodeAndWaitAuth () {
        Random.randonToken()
        // 先進行firebase auth 再做後續生成
        FirebaseRealtimeDatabase.shared.authVerify { result in
            switch result {
            case .success(_):
                QRCredentialManager.generateQRCode { qrcode  in
                    if let qrcodeImage = qrcode {
                        
                        self.imgQrcode.isHidden = false
                        self.imgQrcode.image = qrcodeImage
                        self.lbTitle.stringValue = "請透過TekPass App進行掃描"
                        self.lbIP.stringValue = "等待接收認證資訊"
                        // 等待驗證
                        FirebaseRealtimeDatabase.shared.listen { result in
                            
                            switch result {
                            case .success(_):
                                DispatchQueue.main.async {
                                    self.lbTitle.stringValue = "驗證成功!!!"
                                    self.imgQrcode.isHidden = true
                                    self.lbIP.isHidden = true
                                    
                                    if self.action == .open {
                                        let nextVC = LockViewController()
                                        self.view.window?.contentViewController = nextVC
                                    } else {
                                        NSApplication.shared.terminate(nil)
                                    }
                                }
                                
                            case .failure(let response):
                                DispatchQueue.main.async {
                                    self.lbTitle.stringValue = "驗證失敗"
                                    self.imgQrcode.isHidden = true
                                    self.lbIP.isHidden = true
                                    let alertController = NSAlert()
                                    // 設置警告圖案
                                    alertController.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
                                    // 增加按鈕
                                    alertController.addButton(withTitle: "確定")
                                    // 警告的訊息
                                    alertController.messageText = response.localizedDescription
                                    // 執行
                                    alertController.runModal()
                                }
                            }
                        }
                    } else {
                        self.lbIP.stringValue = "無網路，請確認網路"
                        self.lbIP.isHidden = true
                    }
                }
            case .failure(let response):
                DispatchQueue.main.async {
                    self.lbTitle.stringValue = "驗證失敗"
                    self.imgQrcode.isHidden = true
                    self.lbIP.isHidden = true
                    let alertController = NSAlert()
                    // 設置警告圖案
                    alertController.icon = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: nil)
                    // 增加按鈕
                    alertController.addButton(withTitle: "確定")
                    // 警告的訊息
                    alertController.messageText = response.localizedDescription
                    // 執行
                    alertController.runModal()
                }
            }
        }
    }
}

class CustomWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
}
