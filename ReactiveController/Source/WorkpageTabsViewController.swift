//
//  DocPageTabViewController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/19/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkpageTabsViewController: NSViewController {
    
    let api = WorkpageTabsViewAPI()
    
    var tabsView: WorkpageTabsView { return self.view as! WorkpageTabsView }
    
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func viewDidLoad() {
        self.tabsView.tabsController = self
    }
    
    // methods to change the view - responding to changes in the model
    
    func addTabsViewItem() {
        
        tabsView.addTVItem()
        
        // printLog("WorkpageTabsViewController: addTabsViewItem()")
    }
    
    func removeTabsViewItem(at index: Int) {
        
        tabsView.removeTVItem(at: index)
        
        // printLog("WorkpageTabsViewController: removeTabsViewItem(at: \(index))")
    }
    
    func selectTabsViewItem(at index: Int) {
        
        tabsView.updateSelection( index )
        
        // printLog("WorkpageTabsViewController: selectTabsViewItem( \(index) )")
    }

    // action methods initiated by segmentedControl

    @objc func addTab(_ sender: AnyObject) {  // triggered by '+' button,
        
        let selectedTabNum = tabsView.segmentedControl.selectedSegment
        
        api._addTabRequest.next( selectedTabNum )
        
        // printLog("WorkpageTabsViewController: addTab() called.")
    }
    
    @objc func removeTab(_ sender: AnyObject) {
        
        let selectedTabNum = tabsView.segmentedControl.selectedSegment
        
        api._removeTabRequest.next( selectedTabNum )
        
        // printLog("WorkpageTabsViewController: removeTab() called on tab \(selectedTabNum)")
    }
    
    @objc func ctrlSelected(_ sender: AnyObject) {
        
        let segnum = tabsView.segmentedControl.selectedSegment
        
        api._selectTabRequest.next( segnum )
        
        // printLog("WorkpageTabsViewController: ctrlSelected(): Request being sent out to select workpage \(segnum).")
    }
    
}



 

// ---------------  API  ---------------

// signals relaying commands from user-triggered actions

class WorkpageTabsViewAPI : ReactiveExtensionsProvider {
    
    fileprivate let _addTabRequest    = PublishSubject< Int, NoError >()
    
    fileprivate let _removeTabRequest = PublishSubject< Int, NoError >()
    
    fileprivate let _selectTabRequest = PublishSubject< Int, NoError >()
}

extension ReactiveExtensions where Base: WorkpageTabsViewAPI {
    
    var addTabRequest: SafeSignal<Int> {
        
        return base._addTabRequest.toSignal()
    }
    
    var removeTabRequest: SafeSignal<Int> {
        
        return base._removeTabRequest.toSignal()
    }
    
    var selectTabRequest: SafeSignal<Int> {
        
        return base._selectTabRequest.toSignal()
    }
}


