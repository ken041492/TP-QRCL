//
//  TestVieewController.swift
//  TP-QRCL
//
//  Created by imac-3373 on 2024/5/31.
//

import Cocoa

class TestVieewController: NSViewController {

    override func viewDidAppear() {
        view.window?.level = .mainMenu
        view.window?.collectionBehavior = [ .stationary, .canJoinAllSpaces]
        view.window?.styleMask = [ .nonactivatingPanel]
        view.window?.setFrame(NSScreen.main!.frame, display: false, animate: false)
        view.window?.orderFrontRegardless()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
}
