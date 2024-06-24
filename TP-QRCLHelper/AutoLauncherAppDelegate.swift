//
//  AppDelegate.swift
//  FullScreenDemoHelper
//
//  Created by imac-3700 on 2024/3/4.
//
// Launch at Login https://jogendra.dev/implementing-launch-at-login-feature-in-macos-apps

import Cocoa

@NSApplicationMain
 class AutoLauncherAppDelegate: NSObject, NSApplicationDelegate {
    
    struct Constants {
        // Bundle Identifier of MainApptication target
        static let mainAppBundlelD = "com.tekpass.tpqrcl"
    }
    
     func applicationDidFinishLaunching(_ aNotification: Notification) {
        let runningApps = NSWorkspace.shared.runningApplications
        let isRunning = runningApps.contains {
            $0.bundleIdentifier == Constants.mainAppBundlelD
        }
        
        if !isRunning {
            var path = Bundle.main.bundlePath as NSString
            for _ in 1 ... 4 {
                path = path.deletingLastPathComponent as NSString
            }
            let applicationPathString = path as String
            guard let pathURL = URL(string: applicationPathString) else { return }
            NSWorkspace.shared.openApplication(at: pathURL,
                                               configuration:NSWorkspace.OpenConfiguration(),
                                               completionHandler: nil)
        }
    }
    
}

