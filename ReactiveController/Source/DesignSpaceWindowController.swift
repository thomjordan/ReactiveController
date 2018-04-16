//
//  DesignSpaceWindowController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/16/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

class DesignSpaceWindowController : NSWindowController {
    
    override var windowNibName: NSNib.Name? { return NSNib.Name(rawValue: "DesignSpaceWindowController") }
    
    /// The identifier used for `NSSplitView`'s autosaving and state restoration.
    static let splitViewResorationIdentifier = "DesignSpaceSplitView"

    
    lazy var sidebarVC: ScriptEditorViewController = {
        
        let scriptEditorVC = ScriptEditorViewController()
        

        /*-> add additional configuration here <-*/
        
        
        return scriptEditorVC
    }()
    
    
    lazy var workspaceVC: WorkspaceViewController = WorkspaceViewController()
    
    
    /// The main split view controller used as the `contentViewController` of the window.
    lazy var splitViewController: NSSplitViewController = {
        
        // Create a split view controller to contain split view items.
        
        let splitViewController = NSSplitViewController()
        
        splitViewController.minimumThicknessForInlineSidebars = 992.0
        
        splitViewController.view.wantsLayer = true
        
        
        // Create a sidebar SplitViewItem. This has metrics and behaves like system standard sidebars.
        
        let sidebarSplitViewItem = NSSplitViewItem(sidebarWithViewController: self.sidebarVC)
        
        splitViewController.addSplitViewItem(sidebarSplitViewItem)
        
        
        // Create a standard `NSSplitViewItem`.
        
        let workspaceSplitViewItem = NSSplitViewItem(viewController: self.workspaceVC)
        
        workspaceSplitViewItem.minimumThickness = 300
        
        splitViewController.addSplitViewItem( workspaceSplitViewItem )
        
        
        splitViewController.splitView.autosaveName = NSSplitView.AutosaveName(rawValue: DesignSpaceWindowController.splitViewResorationIdentifier)
        
        splitViewController.splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: DesignSpaceWindowController.splitViewResorationIdentifier ) 
        
        
        return splitViewController
    }()
    
    
    
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        guard let window = window else {
            fatalError("`window` is expected to be non nil by this time.")
        }
        
        // Hide the title, so the toolbar is placed in the titlebar region.
        window.titleVisibility = .visible  //.hidden
        
        /*
         Make sure the `contentViewController`'s view frame size matches the
         restored window size. Setting a window's `contentViewController` will
         update the window frame size from the view frame size.
         */
        let frameSize = window.contentRect(forFrameRect: window.frame).size
        
        splitViewController.view.setFrameSize(frameSize)
        
        window.contentViewController = splitViewController
        
//        setupToolbar(window: window)
    }
    
    
 //   func setupToolbar(window: NSWindow) {
        
      //  guard let toolbar = window.toolbar else { return }
        
      //  toolbar.delegate = MainToolbarDelegate(toolbar: toolbar)
 //   }
    
}




