//
//  AppBackgroundHelper.swift
//  ChangeDesktopFix
//
//  Created by Gerwin van der Lugt on 21-08-16.
//  Copyright © 2016 Gerwin van der Lugt. All rights reserved.
//

import AppKit

class AppBackgroundHelper {
    
    let app : AppDelegate
    
    init(app : AppDelegate) {
        self.app = app
    }
 
    func stopIfAlreadyStarted() {
        let myPid = NSProcessInfo.processInfo().processIdentifier
        let myBundleIdentifier = NSBundle.mainBundle().bundleIdentifier
        
        for runningApp in NSWorkspace.sharedWorkspace().runningApplications {
            if runningApp.processIdentifier != myPid &&
               runningApp.bundleIdentifier == myBundleIdentifier {
                NSApp.terminate(nil)
            }
        }
    }
    
}
