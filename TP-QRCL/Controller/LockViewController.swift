//
//  LockViewController.swift
//  FullScreenDemo
//
//  Created by imac-3700 on 2024/3/11.
//

import Cocoa
import Network

class LockViewController: NSViewController {
    
    @IBOutlet weak var labelCheckNetwork: NSTextField!
    
    override func viewDidAppear() {
        view.window?.level = .mainMenu
        view.window?.collectionBehavior = [ .stationary, .canJoinAllSpaces]
        view.window?.styleMask = [ .nonactivatingPanel]
        view.window?.setFrame(NSScreen.main!.frame, display: true, animate: true)
        view.window?.orderFrontRegardless()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let monitor = NWPathMonitor()
        // Do view setup here.
        let spinner = NSProgressIndicator()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.labelCheckNetwork.stringValue = "網路已連結"
                    spinner.removeFromSuperview()
                    spinner.stopAnimation(self)
                }
            } else {
                DispatchQueue.main.async {
                    
                    spinner.style = .spinning
                    spinner.frame = NSRect(x:700, y:300, width:50, height:50)
                    self.view.window?.contentView?.addSubview(spinner)
                    spinner.startAnimation(self)
                    self.labelCheckNetwork.stringValue = "網路無法使用，請在狀態列設定網路"
                }
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
        
    }
    
    @IBAction func adminBtnClicked(_ sender: NSButton) {
        
        let nextVC = ScanQrcodeViewController()
        nextVC.action = .close
        self.view.window?.contentViewController = nextVC
    }
}
