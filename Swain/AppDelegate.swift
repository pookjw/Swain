//
//  AppDelegate.swift
//  Swain
//
//  Created by Jinwoo Kim on 1/13/24.
//

import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainWindow: MainWindow = .init()
        mainWindow.isReleasedWhenClosed = false
        mainWindow.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
