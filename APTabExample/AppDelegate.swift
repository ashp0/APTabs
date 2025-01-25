//
//  AppDelegate.swift
//  APTab
//
//  Created by Ashwin Paudel on 2025-01-25.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let window = AXWindow()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        window.contentViewController = ViewController()
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool
    {
        return true
    }

}
