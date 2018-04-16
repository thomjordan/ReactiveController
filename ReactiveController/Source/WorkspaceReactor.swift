//
//  WorkspaceReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/19/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkspaceReactor : Reactor {
    
    var workpageModels : WorkpageModelsCollection? { return App.shared.workpageModels }
    
    let addPage    : Property<Int?> = Property<Int?>(nil)
    let removePage : Property<Int?> = Property<Int?>(nil)
    let selectPage : Property<Int?> = Property<Int?>(nil)
    
    let editModeChanged : Property<Bool> = Property<Bool>(false)
    var mouseDownEvent : Property<MouseDownEvent?> = Property<MouseDownEvent?>(nil)
    var mouseDragEvent : Property<MouseDragEvent?> = Property<MouseDragEvent?>(nil)
    var   mouseUpEvent : Property<MouseUpEvent?>   = Property<MouseUpEvent?>(nil)
    var deleteKeyEvent : Property<NSEvent?>        = Property<NSEvent?>(nil)
    let addComponent   : Property<ComponentKind?>  = Property<ComponentKind?>(nil)
    
    let selectedPageIsEditable : Property<Bool> = Property(true)
    
    override init() {
        
        super.init()
        
        addPage
            
            .observeNext { val in
            
            guard let index = val else { return }
            
            let newPage = WorkpageModel()
            
            let newIndex = index+1
            
            self.workpageModels?.insertPage( newPage, at: newIndex )
        
            self.workpageModels?.selectPage(at: newIndex)
                
            documentChanged()
            
        }.dispose(in: bag)
        
        
        removePage
            
            .observeNext { val in
            
            guard let index = val else { return }
            
            let _ = self.workpageModels?.removePage(at: index)
            
            let selectionIndex = (index == 0) ? index : index-1
            
            self.workpageModels?.selectPage(at: selectionIndex)
                
            documentChanged()
            
        }.dispose(in: bag)
        
        
        selectPage
            
            .observeNext { val in
            
            guard let index = val else { return }
            
            self.workpageModels?.selectPage(at: index)
            
        }.dispose(in: bag)
        
        // instead of reacting here, bind addComponent to the addComponent in each WorkpageModel
        // where a WorkpageModel will only react if its isSelected property is true
        
        addComponent
            
            .observeNext { val in
                guard let kind = val else { return }
                self.workpageModels?.addComponent( kind )
            }.dispose(in: bag)
    
    }
}


// SCENE

extension WorkspaceReactor {
    
    func createScene() {
        
        var workpageViews    : WorkpageViewsCollection?    { return App.shared.workpageViews    }
        var workpageReactors : WorkpageReactorsCollection? { return App.shared.workpageReactors }
        var workspaceVC      : WorkspaceViewController     { return App.shared.workspaceVC      }
        
        var editButton : NSButton? { return App.shared.toolbar?.items[5].view as? NSButton }
        
        guard let tabsVC = workspaceVC.workpageTabsVC else { return }
       
        var forwardingMouseDownEvent : MouseDownEvent? {
            get { return workpageReactors?.selectedPage?.mouseDownEvent.value }
            set(newValue) { workpageReactors?.selectedPage?.mouseDownEvent.value = newValue }
        }
        
        var forwardingMouseDragEvent : MouseDragEvent? {
            get { return workpageReactors?.selectedPage?.mouseDragEvent.value }
            set(newValue) { workpageReactors?.selectedPage?.mouseDragEvent.value = newValue }
        }
        
        var forwardingMouseUpEvent : MouseUpEvent? {
            get { return workpageReactors?.selectedPage?.mouseUpEvent.value }
            set(newValue) { workpageReactors?.selectedPage?.mouseUpEvent.value = newValue }
        }
        
        var forwardingDeleteKeyEvent : NSEvent? {
            get { return workpageReactors?.selectedPage?.deleteKeyEvent.value }
            set(newValue) { workpageReactors?.selectedPage?.deleteKeyEvent.value = newValue }
        }
        
        
        func updateForSelectedPage() {
            
            if let currPage = workpageReactors?.selectedPage {
                
                currPage.editModeUpdater.disposeBag.dispose()
                
                currPage.editModeUpdater
                    
                    .observeNext { [weak self] newValue in
                    
                    self?.selectedPageIsEditable.value = newValue
                    
                }.dispose(in: currPage.editModeUpdater.disposeBag)
            }
        }
        
        
        // inputs
        
        tabsVC.api.reactive.addTabRequest.bind(to: self.addPage)
        tabsVC.api.reactive.removeTabRequest.bind(to: self.removePage)
        tabsVC.api.reactive.selectTabRequest.bind(to: self.selectPage)
        
        editButton?.reactive.state.toSignal()
            .map { $0.rawValue == 0 ? false : true  }
            .bind(to: editModeChanged)
        
        App.shared.api.reactive.addComponent.bind(to: self.addComponent)
        
        workspaceVC.api.reactive.mouseDownEvent.bind( to: self.mouseDownEvent )
        workspaceVC.api.reactive.mouseDragEvent.bind( to: self.mouseDragEvent )
        workspaceVC.api.reactive.mouseUpEvent.bind(   to: self.mouseUpEvent   )
        workspaceVC.api.reactive.deleteKeyEvent.bind( to: self.deleteKeyEvent )
        
        // outputs
        
        updateForSelectedPage()
        
        
        workpageModels?.observeCollection { [weak self] pagesArray in
            
            switch pagesArray.change {
                
            case .inserts(let indices):
                
                for index in indices.reversed() {
                    
                    tabsVC.addTabsViewItem()
                    
                    guard let wkpageModel = self?.workpageModels?.thePages[index] else { return }
                    
                    let workpageReactor = WorkpageReactor( wkpageModel )
                    
                    let workpageView = workpageReactor.createScene()
                    
                    workpageViews?.insertPage(workpageView, at: index)
                    
                    workpageReactors?.insertPage(workpageReactor, at: index)
                    
                    wkpageModel.componentsLoader?()
                    
                    workpageReactor.determineSelected() 
                }
                
            case .deletes(let indices):
                
                for index in indices.reversed() {
                    
                    tabsVC.removeTabsViewItem(at: index)
                    
                    workpageViews?.deletePage(at: index)
                    
                    workpageReactors?.deletePage(at: index)
                }
                
            default: break
                
            }}.dispose(in: bag)
        
        
        workpageModels?.observeSelection { index in
            
            tabsVC.selectTabsViewItem(at: index)
            
            workpageReactors?.selectPage(at: index)
            
            workspaceVC.selectPageView(at: index)
            
            updateForSelectedPage() 
            
        }.dispose(in: bag)
        
        
        
        editModeChanged
            
            .observeNext { newState in
                
                self.workpageModels?.selectedPage?.gridIsActive.value = newState
                
            }.dispose(in: bag)
        
        
        
        selectedPageIsEditable
            
            .map { $0 == false ? 0 : 1  }
            
            .observeNext { newState in
                
                // printLog("~~~~~~~~~~~ selectedPageIsEditable.observeNext() ~~~~~~~~~~~")
                
                editButton?.state = NSControl.StateValue(rawValue: newState)
                
            }.dispose(in: bag)
        
        
        mouseDownEvent
            
            .observeNext { event in
            
            forwardingMouseDownEvent = event
            
        }.dispose(in: bag)
        
        
        mouseDragEvent
            
            .observeNext { event in
            
            forwardingMouseDragEvent = event
            
        }.dispose(in: bag)
        
        
        mouseUpEvent
            
            .observeNext { event in
            
            forwardingMouseUpEvent = event
            
        }.dispose(in: bag)
        
        
        deleteKeyEvent
            .executeOn(.global(qos: .userInitiated))
            .observeOn(.main)
            .observeNext { event in
            
            if let e = event {
                forwardingDeleteKeyEvent = e
            }

        }.dispose(in: bag)
        
      //  workpageModels?.createPage() // provide an initial page to start with
    }
    
}


extension WorkspaceReactor {
    
    func restoreAllConnections() {
        
        guard let workpageReactors = App.shared.workpageReactors else { return }
        
        let pagenum = workpageReactors.selectedPageNum.value
        
        for wkpage in workpageReactors.thePages.array {
            
            for component in wkpage.currentComponentsOrderedByLocation {
                
                restoreIncomingConnections(component)
            }
        }
        
        // printLog("WorkspaceReactor: restoreAllConnections() SUCCESSFULLY RESTORED ALL CONNECTIONS.")
        
        workpageReactors.selectedPageNum.value = pagenum
        
        App.shared.updateView()
    }
    
    
    func restoreWorkpageConnections(_ wkpage: WorkpageReactor) {
        
        for component in wkpage.currentComponentsOrderedByLocation {
            
            restoreIncomingConnections(component)
        }
        
        App.shared.updateView()
    }
    
    
    func restoreIncomingConnections(_ reaktor: ComponentReactor) {
        
        guard let compModel = reaktor.model else { return }
        
        for cmodel in compModel.inwardConnections {
            
            let inputnum = cmodel.targetInputNum
            
            if (inputnum < compModel.inputs.count) && (inputnum < reaktor.inputs.count) {
                
                compModel.inputs[inputnum]?.incomingConnection = cmodel
                
                reaktor.inputs[inputnum]?.activeConnection = ConnectionReactor(model: cmodel)
                
                // printLog("WorkspaceReactor:restoreIncomingConnections() ACTIVATED A CONNECTION")
            }
        }
    }
    
    func runCodeForAllJSAgents() {
        
        guard let workpageReactors = App.shared.workpageReactors else { return }
        
        for wkpage in workpageReactors.thePages.array {
            
            wkpage.runCodeForAllJSAgents()
        }
    }
    
}













