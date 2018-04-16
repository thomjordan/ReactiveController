//
//  AppDelegate.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let docController = GlobalDocumentController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        print("APP DELEGATE has AWAKENED from NIB !!")
    }
}

