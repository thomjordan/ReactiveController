//
//  UserSpaceInstaller.swift
//  ReactiveController
//
//  Created by Thom Jordan on 10/24/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import Cocoa
import DrawableCanvasKit 


class UserSpaceInstaller {
    
    static let singleton = UserSpaceInstaller()
    
    let libpath = "Application Support/Ratiotechne/ReactiveControl/CustomDevices"

    var customDevicesURL : URL? {
        return FileManager.default.getURLForUserLibrarySubfolder(at: libpath)
    }
    
    var deviceDataURLs : [URL] {
        guard let devicesURL = customDevicesURL else { return [] }
        return devicesURL.contents.map { $0 }
    }
    
    var customDeviceNames : [String] {
        return deviceDataURLs.map { $0.lastPathComponent }
    }
    
    func establishContextsMenu() {
        let contextsItem = NSMenuItem(title: "Contexts", action: nil, keyEquivalent: "")
        let contextsMenu = NSMenu(title: "Contexts")
        for deviceDataURL in deviceDataURLs {
            let deviceName = deviceDataURL.lastPathComponent
            let newItem = NSMenuItem(title: deviceName, action: #selector(App.shared.genUserComponent(_:)), keyEquivalent: "")
            newItem.representedObject = deviceDataURL
            contextsMenu.addItem(newItem)
        }
        contextsItem.submenu = contextsMenu
        NSApp.mainMenu?.insertItem(contextsItem, at: 5)
    }
    
    public static func performInstall() {
        singleton.establishContextsMenu()
    }
    
}



