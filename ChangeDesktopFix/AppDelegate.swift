//
//  AppDelegate.swift
//  ChangeDesktopFix
//
//  Created by Gerwin van der Lugt on 21-08-16.
//  Copyright © 2016 Gerwin van der Lugt. All rights reserved.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Timeframe after workspace change in which we'll be
    // looking for faulty window activations
    let blockWindowActivationThreshold = 0.1
    
    var backgroundHelper : AppBackgroundHelper? = nil
    
    var lastChangeDesktopActiveWindow : ExtWindow? = nil // Window that should be active after desktop change
    var lastChangeDesktopTime : Double = 0.0             // Timestamp of last workspace change
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        
        // Don't run twice!
        backgroundHelper = AppBackgroundHelper(app: self)
        backgroundHelper!.stopIfAlreadyStarted()
        
        registerHandlers()
    }
    
    func registerHandlers() {
        
        // Fire _didChangeWorkspace_ event when the user switches workspace
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(
            self,
            selector: #selector(didChangeWorkspace),
            name: NSWorkspaceActiveSpaceDidChangeNotification,
            object: NSWorkspace.sharedWorkspace())
        
        // Fire _didActivateApplication_ event when an application is activated
        // e.g. its windows are moved top-most
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(
            self,
            selector: #selector(didActivateApplication),
            name: NSWorkspaceDidActivateApplicationNotification,
            object: NSWorkspace.sharedWorkspace())
    }
    
    func getTopMostWindow() -> ExtWindow? {
        
        // Hackery functions that retrieves a list of windows and
        // uses the order to determine which one is the top-most
        let options = CGWindowListOption(
            arrayLiteral: CGWindowListOption.ExcludeDesktopElements,
            CGWindowListOption.OptionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        let infoList = windowListInfo as NSArray? as? [[String: AnyObject]]
        
        for dict in infoList! {
            let windowName = dict["kCGWindowName"] as! String
            
            // Don't process the Menubar (which is always on top!) or empty
            // window names (there are many for some reason)
            if windowName != "Menubar" && windowName != "" {
                
                // *This* is the top-most window!
                return ExtWindow(
                    name: windowName,
                    number: dict["kCGWindowNumber"] as! Int,
                    ownerPid: dict["kCGWindowOwnerPID"] as! Int)
            }
        }
        return nil
    }
    
    func reactivateLastActiveWindow() {
        
        if lastChangeDesktopActiveWindow != nil {
            
            // Try finding the app that corresponds to the windows'
            // process identifier
            if let app = NSRunningApplication(processIdentifier: Int32(lastChangeDesktopActiveWindow!.ownerPid)) {
                
                // Found! Activate its window
                app.activateWithOptions([.ActivateIgnoringOtherApps,
                    NSApplicationActivationOptions.ActivateAllWindows])
            }
        }
    }
    
    func didChangeWorkspace() {
        
        if let topMostWindow = getTopMostWindow() {
            
            // The workspace was changed. Store the current time and
            // the window that is on top (and should stay on top)
            self.lastChangeDesktopActiveWindow = topMostWindow
            self.lastChangeDesktopTime = NSDate().timeIntervalSince1970;
        }
    }
    
    func didActivateApplication() {
        
        // Detect faulty window activation
        let currentTime = NSDate().timeIntervalSince1970
        if currentTime - lastChangeDesktopTime < blockWindowActivationThreshold {
            if let currentTopMostWindow = getTopMostWindow(), lastTopMostWindow = lastChangeDesktopActiveWindow {
                if currentTopMostWindow.number != lastTopMostWindow.number {
                    
                    // Current active window doesn't match the one it should
                    // be and a workspace switch has recently happened, this
                    // is probably a faulty window activation so we'll undo
                    // it by reactivating the correct window.
                    //
                    // TODO : Find a better way because this generates a
                    //        flash on the users' window.
                    //
                    reactivateLastActiveWindow()
                }
            }
        }
    }
    
}

