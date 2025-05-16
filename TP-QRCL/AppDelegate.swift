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
import CoreGraphics
import Sparkle


@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var window: NSWindow!

    var statusItem: NSStatusItem?
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var testItem: NSMenuItem?

    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        FirebaseApp.configure()
//        CheckUpdate.shared.showUpdate(withConfirmation: true, isTestFlight: true)
        var updater = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil).updater
        
        updater.checkForUpdates()
        
        mirrorDisplays()
        
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
        var config: CGDisplayConfigRef? = nil
        
        if CGBeginDisplayConfiguration(&config) == .success {
            let mainDisplay = CGMainDisplayID()
            let maxDisplayCount: UInt32 = 16
            var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplayCount))
            var displayCount: UInt32 = 0
            
            if CGGetOnlineDisplayList(maxDisplayCount, &onlineDisplays, &displayCount) == .success {
                for display in onlineDisplays {
                    if display != mainDisplay {
                        CGConfigureDisplayMirrorOfDisplay(config, display, kCGNullDirectDisplay)
                    }
                }
                print("Stopping mirroring")
                CGCompleteDisplayConfiguration(config, .permanently)
            } else {
                CGCancelDisplayConfiguration(config)
            }
        }
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
    
    func mirrorDisplays() {
        // 獲取所有顯示器
        let screenArray = NSScreen.screens
        
        // 檢查是否有多個顯示器
        guard screenArray.count > 1 else {
            print("只有一個顯示器，無法進行鏡像顯示。")
            return
        }
        
        // 獲取內建的顯示器 (通常是第一個)
        guard let mainDisplayId = screenArray.first?.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID else {
            print("無法獲取內建顯示器。")
            return
        }
        
        // 將其他顯示器設置為鏡像顯示
        for screen in screenArray.dropFirst() {
            if let displayId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID {
                var config: CGDisplayConfigRef? = nil
                
                guard CGBeginDisplayConfiguration(&config) == .success else {
                    print("無法開始顯示配置。")
                    continue
                }
                
                CGConfigureDisplayMirrorOfDisplay(config, displayId, mainDisplayId)
                
                guard CGCompleteDisplayConfiguration(config, .permanently) == .success else {
                    print("無法完成顯示配置。")
                    continue
                }
                
                print("Display \(displayId) 已鏡像到 \(mainDisplayId)。")
            }
        }
    }
    
}

