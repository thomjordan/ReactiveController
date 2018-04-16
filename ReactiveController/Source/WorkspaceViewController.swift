//
//  WorkspaceViewController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkspaceViewController : NSViewController {
    
    @IBOutlet weak var tabView: WorkpageTabsView!
    
    @IBOutlet weak var scrollView: FlippedScrollView!
    
    @IBOutlet weak var clipView: NSClipView!
    
    
    var workpageTabsVC : WorkpageTabsViewController? { return tabView.tabsController   }
    
    var workpageViews  : WorkpageViewsCollection?    { return App.shared.workpageViews }

    
    var workpageView: WorkpageView? {
        
        get { return clipView.documentView as! WorkpageView? }
        
        set {
            
            clipView.documentView = newValue
            
            updateView() // updateViews()
        }
    }

    var defaultWorkpageView : WorkpageView!

    let api = WorkspaceViewAPI()
    
    

    required init() { super.init(nibName: nil, bundle: nil) }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func viewDidLoad() {
        
        // printLog("WorkspaceViewController: viewDidLoad() called.")
        
        defaultWorkpageView = WorkpageView(frame: NSMakeRect(0, 0, 2000, 1250))
        
        workpageView = defaultWorkpageView
        
        updateView() // updateViews()
    }
    
    // methods to change the view - responding to changes in the model
    
    func selectPageView(at index: Int) {
        
        workpageViews?.selectPage(at: index)
        
        guard let selectedView = workpageViews?.getSelected() else { return }
        
        // printLog("#### WorkspaceViewController: selectPageView(at: \(index)) called with bgColor \(selectedView.bgColor) ####")
        
        defaultWorkpageView = selectedView
        
        workpageView = selectedView
    }
    
//    override func updateViews() {
//        DispatchQueue.main.async { [weak self] in
//            self?.scrollView.needsDisplay = true
//            self?.clipView.needsDisplay = true
//            self?.view.needsDisplay = true
//        }
//    }
}


// user-initiated actions

extension WorkspaceViewController {
    
    override func mouseDown(with sender: NSEvent) {

        let winPoint = clipView.mouseLocationInWindow()
        let vuePoint = clipView.localizePoint(sender)
        let event: MouseDownEvent = (sender: sender, winloc: winPoint, viewloc: vuePoint)
        
        api._mouseDownEvent.next( event )
        printLocations( "mouseDown: ", winPoint, vuePoint )
    }
    
    
    override func mouseDragged(with sender: NSEvent) {
        
        let winPoint = clipView.mouseLocationInWindow()
        let vuePoint = clipView.localizePoint(sender)
        let event: MouseDragEvent = (winloc: winPoint, viewloc: vuePoint, sender: sender)
        
        api._mouseDragEvent.next( event )
        printLocations( "mouseDrag: ", winPoint, vuePoint )
    }
    
    override func mouseUp(with sender: NSEvent) {
        
        let winPoint = clipView.mouseLocationInWindow()
        let vuePoint = clipView.localizePoint(sender)
        let event: MouseUpEvent = (viewloc: vuePoint, sender: sender, winloc: winPoint)
        
        api._mouseUpEvent.next( event )
        printLocations( "  mouseUp: ", winPoint, vuePoint )
    }
    
    /*
    override func deleteBackward(_ sender: Any?) {
        guard let event = sender else { return }
        // printLog("Delete key pressed: \(event)")
        api._deleteKeyEvent.next( event )
    }
    */
    
    override func keyDown(with theEvent: NSEvent) {
        guard let chars = theEvent.characters else { return }
        // printLog("KeyDown detected: " + chars + " : keyCode = \(theEvent.keyCode)")
        let backspaceKey = 51;  let deleteKey = 117
        if theEvent.keyCode == backspaceKey || theEvent.keyCode == deleteKey {
            api._deleteKeyEvent.next( theEvent )
        }
    }
}


extension WorkspaceViewController {
    
    func printLocations(_ prefix: String = "", _ winPoint: NSPoint, _ vuePoint: NSPoint) {
        
        // printLog("\(prefix) [ x: \(winPoint.x), y: \(winPoint.y) ] in Window.")
        // printLog("\(prefix) [ x: \(vuePoint.x), y: \(vuePoint.y) ] in Viewer.")
    }
}


// ---------------  API  ---------------

// signals relaying commands from user-triggered actions

class WorkspaceViewAPI : ReactiveExtensionsProvider {
    
    fileprivate let _mouseDownEvent = SafePublishSubject<MouseDownEvent>()
    fileprivate let _mouseDragEvent = SafePublishSubject<MouseDragEvent>()
    fileprivate let   _mouseUpEvent = SafePublishSubject<MouseUpEvent>()
    
    fileprivate let _deleteKeyEvent = SafePublishSubject<NSEvent>()
}

extension ReactiveExtensions where Base: WorkspaceViewAPI {
    
    var mouseDownEvent : SafeSignal<MouseDownEvent> { return base._mouseDownEvent.toSignal() }
    var mouseDragEvent : SafeSignal<MouseDragEvent> { return base._mouseDragEvent.toSignal() }
    var   mouseUpEvent : SafeSignal<MouseUpEvent>   { return   base._mouseUpEvent.toSignal() }
    
    var deleteKeyEvent : SafeSignal<NSEvent> { return base._deleteKeyEvent.toSignal() }
}










