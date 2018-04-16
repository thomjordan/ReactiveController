//
//  App.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/16/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import AbletonLinkShim

class App : NSResponder {
    
    static var shared : App!
    
    var loadedWorkpageCollection : WorkpageModelsCollection? 
    
    // header
    
    let api = AppAPI()
    
    var windowController : DesignSpaceWindowController!
    
    var window : NSWindow? { return windowController.window }
    
    var scriptEditor : ScriptEditorViewController { return windowController.sidebarVC }
    
    var toolbarContext : MainToolbarContext?
    
    var toolbar : NSToolbar? { return toolbarContext?.toolbar }
    var toolbarDelegate : MainToolbarDelegate? { return toolbarContext?.toolbarDelegate }
    var toolbarCxt      : MainToolbarContext?  { return toolbarContext }
    
    var transportState : Property<TransportControlStateModel.TransportStatus>? { return toolbarCxt?.transportModel.transportState_ }
    var transportMode  : TransportControlStateModel.RunningMode? { return toolbarCxt?.transportModel.transportMode }
    
//    var abletonLinkService : AbletonLinkService?
    
    // main
    
    var workspaceReactor : WorkspaceReactor!
    
    var workpageModels   : WorkpageModelsCollection?
    var workpageViews    : WorkpageViewsCollection?
    var workpageReactors : WorkpageReactorsCollection?
    
    // convenience properties
    
    var workspaceVC : WorkspaceViewController { return windowController.workspaceVC }
    
    // transport callbacks
    
  //  var transportPlayCallbacks : [(() -> Void)?] = []
  //  var transportStopCallbacks : [(() -> Void)?] = []
    
    // model
    
    
    init(wc: DesignSpaceWindowController, loadedModel: WorkpageModelsCollection? = nil) {
        
        super.init()
        
        setupGCDQueues()
        
        loadedWorkpageCollection = loadedModel 
        
        populate()
        
        deploySingleton()
        
        windowController = wc
        
        customizeWindow()
        
        adjustResponderChain()
        
        createMainToolbarContext() 
        
        createWorkspace()
        
        setupAbletonLinkService()
        
        startWorkspace()
        
        restoreAllConnections()
        
        runCodeForAllJSAgents()
        
        UserSpaceInstaller.performInstall() 
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    func setupGCDQueues() { let _ = Dispatch() }
    
    func populate() {
        
        // printLog("App:populate() called.")
        
        let wmc = WorkpageModelsCollection()
        
        workpageModels = loadedWorkpageCollection ?? wmc
        
//        let usingLoadedModel = workpageModels === loadedWorkpageCollection
//        let usingNewestModel = workpageModels === wmc
        
        // printLog(" ")
        // printLog("usingLoadedModel = \(usingLoadedModel)")
        // printLog("usingNewestModel = \(usingNewestModel)")
        // printLog(" ")
        
        workpageViews    = WorkpageViewsCollection()
        workpageReactors = WorkpageReactorsCollection()
    }
    
    
    func customizeWindow() {
        
        window?.titlebarAppearsTransparent = false // true 
    }
    
    
    func createMainToolbarContext() {
       
        guard let toolbar = window?.toolbar else { return }
        
        self.toolbarContext = MainToolbarContext(with: toolbar)
        
    }
    
    func createWorkspace() {
        self.workspaceReactor = WorkspaceReactor()
    }
    
    func startWorkspace() {
        let deserializedPagesSet = workpageModels?.decodedDataLoader
        let blankPageToStartWith = { self.workspaceReactor.addPage.next(-1) }
        workspaceReactor.createScene()
        let constructInitialPages = deserializedPagesSet ?? blankPageToStartWith
        constructInitialPages()
    }
    
    func deploySingleton() {
        App.shared = self
    }
    
    func runCodeForAllJSAgents() {
        workspaceReactor.runCodeForAllJSAgents()
    }
    
    func shutdown() {
        removeAbletonLinkService()
    }
}

// "Globally-accessible" functions

extension App {
    
    func restoreAllConnections() {
        workspaceReactor.restoreAllConnections()
    }
    
    func adjustResponderChain() {
        nextResponder = window?.nextResponder
        window?.nextResponder = self
    }
    
    func documentChanged() {
        let currDoc = windowController.document as! NSDocument
        currDoc.updateChangeCount(.changeDone)
    }
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.workspaceVC.view.needsDisplay = true
        }
    }

}



// user-initiated actions

extension App {
    
    // selected menu-item initiated commands
    
    @IBAction func genComponent(_ sender: AnyObject) {
        let componentName : String = sender.title
        guard let kind = getComponentKind(of: componentName) else { return }
        api._addComponent.next( kind )
    }
    
    @IBAction func genUserComponent(_ sender: AnyObject) {
        guard let url = sender.representedObject as? URL else { return }
        let kind = UserDefinedComponent(url: url)
        api._addComponent.next( kind )
    }
}


// ---------------  API  ---------------

// signals relaying commands from user-triggered actions

class AppAPI : ReactiveExtensionsProvider {
    
    fileprivate let _addComponent = PublishSubject< ComponentKind, NoError >()
}

extension ReactiveExtensions where Base: AppAPI {
    
    var addComponent: SafeSignal<ComponentKind> {
        
        return base._addComponent.toSignal()
    }
}



private extension App {
    
    func setupAbletonLinkService() {
        AbletonLinkService.API.setupLink(for: self)
    }
    
    func removeAbletonLinkService() {
        AbletonLinkService.API.removeLink()
       // abletonLinkService = nil
    }
}
