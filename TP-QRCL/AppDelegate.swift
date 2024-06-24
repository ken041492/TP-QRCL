//
//  AppDelegate.swift
//  FullScreenDemo
//
//  Created by imac-3700 on 2024/3/4.
//

import Cocoa
import ServiceManagement
import FirebaseCore
import FirebaseMessaging


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    var statusItem: NSStatusItem?
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var testItem: NSMenuItem?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        FirebaseApp.configure()
        
        Task {
           try SMAppService().register()
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(systemSymbolName: "lock", accessibilityDescription: nil)
        if let menu = menu {
           statusItem?.menu = menu
       }
        
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(openWindow),
                                                            name: NSNotification.Name(rawValue: "com.apple.screenIsUnlocked"),
                                                            object: nil)
        let vc = ScanQrcodeViewController()
        window.contentViewController = vc
        
    }
    
    @IBAction func testItemClicked(_ sender: NSMenuItem) {
        if sender.state == .on {
            Task {
               try SMAppService().unregister()
            }
            sender.state = .off
        } else {
            Task {
               try SMAppService().register()
            }
            sender.state = .on
        }
    }
    
    @objc func openWindow() {
        let vc = LockViewController()
        window.contentViewController = vc
        window.level = .mainMenu
        window.collectionBehavior = [ .stationary, .canJoinAllSpaces]
        window.styleMask = [ .nonactivatingPanel]
        
        window.setFrame(NSScreen.main!.frame, display: true, animate: true)
        window.orderFrontRegardless()
        
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    @IBAction func cancelBtnClicked(_ sender: NSButton) {
        window.close()
    }
    
    
    
    func windowWillClose(_ notification: Notification) {
        FirebaseRealtimeDatabase.shared.stopListen()
    }

}

