//
//  MainViewController.swift
//  FullScreenDemo
//
//  Created by imac-3700 on 2024/3/11.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidAppear() {
        view.window?.level = .mainMenu
        view.window?.collectionBehavior = [ .stationary, .canJoinAllSpaces]
        view.window?.styleMask = [ .nonactivatingPanel]
        view.window?.setFrame(NSScreen.main!.frame, display: false, animate: false)
        view.window?.orderFrontRegardless()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        openWindow()
        // Do view setup here.
    }
    
    
    func openWindow() {
        
    }
    @IBAction func AdminBtnClicked(_ sender: NSButton) {
        let nextVC = ScanQrcodeViewController()
        nextVC.action = .close
        self.view.window?.contentViewController = nextVC
    }
    
}

