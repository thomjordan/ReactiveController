//
//  MainToolbarDelegate.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/19/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa

class MainToolbarDelegate : NSObject, NSToolbarDelegate {
    
    weak var toolbar : NSToolbar!
    
    var toggleSidebarButton : NSToolbarItem { return toolbar.items[0] }
    var tempoTextField      : NSToolbarItem { return toolbar.items[2] }
    var transportButton     : NSToolbarItem { return toolbar.items[3] }
    var editModeButton      : NSToolbarItem { return toolbar.items[5] }
    
    init(toolbar: NSToolbar) {
        super.init()
        self.toolbar = toolbar
    }
    
    func updateTempoField() {
        DispatchQueue.main.async { [weak self] in
            self?.tempoTextField.view?.needsDisplay = true
        }
    }
}
