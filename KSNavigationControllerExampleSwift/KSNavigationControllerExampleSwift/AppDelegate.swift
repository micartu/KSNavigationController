//
//  AppDelegate.swift
//  KSNavigationControllerExampleSwift
//
//  Created by Alex on 8/4/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        self.window = NSWindow()
        self.window.center()
        
        let vc1 = TestViewController()
        let navigationController = KSNavigationController(rootViewController: vc1)
        navigationController?.view.frame = NSMakeRect(0.0, 0.0, 480.0, 272.0)
        
        self.window.contentViewController = navigationController
        self.window.orderFrontRegardless()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
