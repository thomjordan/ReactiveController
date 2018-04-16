//
//  WorkspaceViewControl.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/17/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit



// --------------------------------------------
// MARK: - protocol: DraggableHosting
// --------------------------------------------


protocol DraggableHosting { // identifies an NSView or controller as a superview/surface/controller which hosts draggable views
    
    var isInDraggableMode : Bool           { get }
    
    var windowHitLocation : NSPoint?       { get set }
    
    var wsViewHitLocation : NSPoint?       { get set }
    
    var currentComponents : [ComponentVC]  { get }
    
    func cacheFramesForComponents()
    
}

  

// --------------------------------------
//  MARK: - WorkspaceViewControl
// --------------------------------------



final class WorkspaceViewControl : NSViewController, DraggableHosting {
    
    @IBOutlet weak var tabView: DocStyleTabView!
    
    var tabVC: DocStyleTabViewControl!
    
    weak var theMC : MainCoordinator? {
        
        didSet { tabVC.theMC = theMC }
    }
 
//    var gridSize : CGFloat = 6
    
    
    // DraggableHosting properties
    
    var isInDraggableMode : Bool { return isLockOpen() }
    
    var windowHitLocation : NSPoint? = nil
    
    var wsViewHitLocation : NSPoint? = nil

    var currentComponents : [ComponentVC] {
        
        get {
            
            guard let mediators = theMC?.presenter.workpagesMediatorStore?.selectedPage?.pageContents else { return [] }
            
            let allComponentsExist = mediators.reduce(true) { aggregate, mediator in aggregate && mediator.componentVC != nil }
            
            let components = allComponentsExist ? mediators.map { $0.componentVC! } : []
            
            return components
            
        }
    }
    
    var currentComponentsWithAuxView : [ComponentVC] {
        
        return currentComponents.filter { $0.hostMediator.auxView != nil }
    }
    
    var currentComponentsOrderedByLocation : [ComponentVC] {
        
        return currentComponents.sorted() {
            
            if $0.uiView.frame.origin.x < $1.uiView.frame.origin.x { return true }
            
            else if $0.uiView.frame.origin.x == $1.uiView.frame.origin.x {
                
                if $0.uiView.frame.origin.y > $1.uiView.frame.origin.y { return true }
            }
            
            return false
        }
    }
    
    var currentlySelectedComponents : [ComponentVC] {
        
        return currentComponents.filter { comp in comp.isSelected }
    }
    
    var currentComponentsToolbarViews : [NSView?]? {
        
        return currentComponents.map { $0.toolbarPopoverVC?.contentViewController.view }
    }
    
    var clickedOutputPointLocation : NSPoint? = nil
    
    var currentLineDragEndLocation : NSPoint? = nil
    
    var connectionInProgress : WorkspaceConnection? = nil
    
    var currentConnections : [WorkspaceConnection] {
        
        return currentComponentsOrderedByLocation.flatMap { $0.hostMediator.inputs.flatMap { $0.inputConnection } }
    }
    
    var newConnectionIsInProgress : Bool {
        
        return clickedOutputPointLocation != nil  &&  connectionInProgress != nil
        
    }
    
    var currentlySelectedConnections : [WorkspaceConnection] {
        
        return currentConnections.filter { conn in conn.isSelected }
    }
    
    var cordWasHit : Bool = false
    
    var cordSelectionChangedNotifications : [() -> ()] = []
    
    var numComponentsChangedNotifications : [() -> ()] = []
    
    
    
    var hostScrollView : FlippedScrollView? {
        
        return self.view.subviews[0] as? FlippedScrollView
    }
    
    var wsContentView  : NSClipView!
    
    var workpageViews  : WorkpagesViewModel?
    
    var defaultWorkspaceView : WorkspaceView!
    
    var workspaceView  : WorkspaceView {
        
        get {
            
            if let _ = workpageViews?.selectedPage {
                
                if let wkViews = workpageViews {
                    
                    if wkViews.pageNumIsValid() {
                        
                        let pagenum = workpageViews!.selectedPageNum
                        
                        return workpageViews!.workspaceViews[pagenum]
                    }
                }
            }
            
            return defaultWorkspaceView
        }
        
        set {
            
            if let _ = workpageViews?.selectedPage {
                
                if let wkViews = workpageViews {
                    
                    if wkViews.pageNumIsValid() {
                        
                        let pagenum = workpageViews!.selectedPageNum
                        
                        workpageViews!.workspaceViews[pagenum] = newValue
                    }
                }
            }
        }
    }
    
    
 
    
    //  MARK: viewDidLoad()
    
    override func viewDidLoad() {
        
        printLog("WorkspaceViewControl: viewDidLoad() called.")
        
        defaultWorkspaceView = WorkspaceView(frame: NSMakeRect(0, 0, 2000, 1250), vc: self)

        setupTabViewControl()
    }
    
    
    func setupMemberViews() {
        
        let _ = self.view
        
        let numSubviews = self.view.subviews.count
        
        guard numSubviews > 1 else { return }
        
        printLog("WorkspaceViewControl: viewDidLoad(): self.view correctly has more than one subview ( \(numSubviews) in fact ).")
        
        updateWorkspaceViewFocus()
        

    }
    
    
    fileprivate func updateWorkspaceViewFocus() {
        
        hostScrollView!.documentView = workspaceView
        
        wsContentView = hostScrollView!.contentView
        
        wsContentView.needsDisplay = true
    }
    
    
    func setupTabViewControl() {
        
        guard let tabView = tabView else { return }
        
        tabVC = DocStyleTabViewControl(tabView)
        
        tabView.tabVC = tabVC
    }

    
    func isLockOpen() -> Bool {
        
        if let status = theMC?.vcGateway?.toolbarVC?.toolbarLockIconView.lockIsOpen {
            
            return status
        }
        
        return false
    }
    
    
    func toggleWorkspaceLock() {
        
        theMC?.vcGateway?.toolbarVC?.toolbarLockIconView.toggleLock()
    }
    
    
    func unlockWorkspaceLock() {
        
        if let toolbarIcon = theMC?.vcGateway?.toolbarVC?.toolbarLockIconView {
            
            if toolbarIcon.lockIsOpen { return }
            
            toolbarIcon.toggleLock()
        }
    }
    
    
    
    func addCallbacksToToolbarLockButton() {
        
        guard let lockButton = theMC?.vcGateway?.toolbarVC?.toolbarLockIconView else {
            
            printLog("WorkspaceViewControl: addCallbacksToToolbarLockButton() FAILED at guard statement ( theMC?.vcGateway?.toolbarVC?.toolbarLockIconView ). ")
            
            return
        }
        
        lockButton.addCallback( workpageViews!.defineGridState )
        
        lockButton.addCallback( { (p:Bool) in self.deselectAllComponents() } )
        
        printLog("WorkspaceViewControl: addCallbacksToToolbarLockButton() called. ")
    }

    
    func getSelectedComponents() -> [ComponentVC] {
        
        var results : [ComponentVC] = []

        for unit in currentComponents {
            
            if unit.isSelected { results.append( unit ) }
        }
        
        return results
    }
    
    
    func refreshView() {
        
        updateWorkspaceViewFocus()
        
        theMC?.vcGateway?.inspectorPanelVC?.updateAttributesViewsDisplay()
        
        // theMC?.vcGateway?.detailAreaVC?.updateAuxViewsDisplay()
    }
    
    
    func addComponentToWorkspace(_ aComponent: ComponentVC?) {
        
        guard let component = aComponent else { return }
        
        (component.view as! ComponentView).sizeToFit()
        
        component.view.frame.origin = NSPoint(x:500, y:500) // target
        
        component.establishConnectorsViews()
        
//      component.addLocalToolbar(name)
        
        workspaceView.addSubview(component.view)
        
        deselectAllComponents()
        
        numComponentsDidChange()
        
        unlockWorkspaceLock()
        
        workspaceView.needsDisplay = true
    }
}



// ------------------------------------------------------------------------------------------
// MARK: - extension: WorkspaceViewControl - Components Selection, Connections, & Dragging
// ------------------------------------------------------------------------------------------


extension WorkspaceViewControl {
    
    
    func selectThisConnection(_ cord: WorkspaceConnection) {
        
        cord.select()
        
        cordSelectionDidChange()
    }
    
    func removeConnectionsAtIndexes(_ indexes: [Int]) {
        
        for i in indexes { currentConnections[i].deconstructConnection() }
        
        cordSelectionDidChange()
    }
    
    
    func selectAllInputConnectionsForUnit(_ unit: ComponentVC) {
        
        for input in unit.inputs {
            
            if input.activeConnections.count > 0 {
                
                input.activeConnections[0].select()
            }
        }
        
        cordSelectionDidChange()
    }
    
    
    
    // MARK: mouseDown()
    
    
    override func mouseDown(with sender: NSEvent) {
        
        printLog("WorkspaceViewControl: mouseDown() called.")
        
        cordWasHit = false
        
        windowHitLocation = wsContentView!.mouseLocationInWindow()
        
        wsViewHitLocation = wsContentView!.localizePoint(sender)
        
        guard let hitPoint = wsViewHitLocation else { return }
        
        
               
        printLog("WorkspaceViewControl: detected mouse click at [ x: \(hitPoint.x), y: \(hitPoint.y) ]")
        
        
        for cord in currentConnections {
            
            if cord.cordRegion.contains(hitPoint) {
                
                cordWasHit = true
                
                // if isInDraggableMode {
                
                if modifiers(sender, excludes: .ShiftKeyMask) {
                    
                    deselectAllOtherConnections(cord)
                    
                    deselectAllComponents() 
                    
                    cord.toggleSelection()
                }
                
                else { cord.toggleSelection() }
                
                cordSelectionDidChange()
                
                view.needsDisplay = true

                //if cord.isSelected { makeMostRecentlySelectedCord(cord) }
                    
                printLog("WorkspaceViewControl: hit detected on a connection path ")
                    
               // }
            }
        }
        

        
        func interpretClick(_ unit: ComponentVC) {
            
            if modifiers(sender, includes: .CommandKeyMask) {
                
                unit.isSpecialSelected = unit.isSpecialSelected != true
                
                return 
            }
            
            if unit.isSelected {
                
                unit.wasSelected = true
                
                if unit.isBrandNewConnectionSource {
                    
                    unit.isBrandNewConnectionSource = false 
                }
                
            }
                
            else {
                
                if modifiers(sender, excludes: .ShiftKeyMask) {
                    
                    deselectAllComponents()
                    
                    deselectAllConnections()
                }
                
                unit.wasSelected = false
                
                unit.select()
            }
        }
        
        
        
        for unit in currentComponents {
            
            if unit.uiView.frame.contains(hitPoint) {
                
                
                if unit.isDraggable {
                    
                    probeForNewStartingConnection(unit, location: hitPoint)
                    
                    cacheFramesForComponents()
                }
                
                
                interpretClick(unit)
                
                determineSelected()
                
                return
            }
        }
        
        
        
        if wsContentView.bounds.contains(hitPoint) { // point is within the general workspace area, not a component
            
            if modifiers(sender, includes: .CommandKeyMask) {
                
                theMC?.vcGateway?.toolbarVC?.toolbarLockIconView.toggleLock()
                
            }
            
            if modifiers(sender, excludes: .ShiftKeyMask) {
                
                deselectAllComponents()
                
                if !cordWasHit {
                    
                    deselectAllConnections()
                    
                    wsContentView.needsDisplay = true // view.needsDisplay
                }
            }
         
            theMC?.documentWindow?.makeFirstResponder(view) // workspaceView; view
        }
        
        determineSelected()
    }
    
    
    
    // MARK: mouseDragged()
    
    
    override func mouseDragged(with sender: NSEvent) {
        
        for sourceUnit in currentComponents {
            
            if sourceUnit.isDraggable {
                
                if newConnectionIsInProgress {
                    
                    selectSourceInProgess()
                    
                    drawConnectionCordInProgress(sender)
                    
                    probeForPossibleEndpointOfConnection()
                    
                    return
                }
                
                
                if sourceUnit.isSelected {
                    
                    if sourceUnit.isBrandNewConnectionSource {
                        
                        sourceUnit.isBrandNewConnectionSource = false
                        
                        sourceUnit.deselect()
                        
                    } else {
                        
                        dragComponent(sourceUnit)
                    }
                }
            }
        }
    }
    
    
    // MARK: mouseUp()
    
    override func mouseUp(with sender: NSEvent) {
        
        if isInDraggableMode {
            
            tryToCompleteTheConnection()
            
            cleanUpScaffolding()
            
        }
        
        
        for unit in currentComponents {
            
            if unit.isDraggable {
                
                if unit.wasSelected {
                    
                    if !unit.wasDragged { unit.deselect() }
                        
                    else {
                        
                        //unit.writeFrameToModel()
                        
                        unit.wasDragged  = false
                        
                        unit.wasSelected = false
                    }
                    
                }
                
            }
            
        }
        
    }
    

    func cacheFramesForComponents() {
        
        for unit in currentComponents {
            
            unit.frameWhenHit = unit.uiView.frame
        }
        
    }
    
    
    
    func deselectAllComponents() {
        
        for unit in currentComponents {
            
            unit.deselect()
        }
    }
    
    
    func deselectAllConnections() {
        
        for cord in currentConnections {
            
            cord.deselect()
            
        }
        
        cordSelectionDidChange()
    }
    
    
    func deselectAllOtherConnections(_ cordOfInterest: WorkspaceConnection) {
        
        for cord in currentConnections {
            
            if cord != cordOfInterest {
                
                cord.deselect()
            }
        }
        
        cordSelectionDidChange()
    }
    
    
    
    func addSelectionChangedNotification(_ block: @escaping () -> ()) {
        
        cordSelectionChangedNotifications.append(block)
    }
    
    
    func cordSelectionDidChange() {
        
        for scn in cordSelectionChangedNotifications { scn() }
        
        view.display()
        
//        hostScrollView?.needsDisplay = true
        
//        workspaceView?.needsDisplay = true
    }
    
    func addNumComponentsChangedNotification(_ block: @escaping () -> ()) {
        
        numComponentsChangedNotifications.append(block)
    }

    
    func numComponentsDidChange() { // component(s) were added or deleted to workspace
        
        for nccn in numComponentsChangedNotifications { nccn() }
    }
    
    
    
    // MARK:  private methods:
    
    
    
    // mouseDown():
    
    
    fileprivate func probeForNewStartingConnection(_ source: ComponentVC, location: NSPoint) {
        
        let doc = view.window?.windowController?.document as? RCDocument
        
        guard let theDoc = doc else { return }
        
        for output in source.outputs {  // look for the start of a possible connection cord
            
            if wsContentView.convert(output.view.frame, from: source.uiView.connectorsView).contains(location) { // view.convertRect ...
                
                clickedOutputPointLocation = location
                
                if let _ = output.center {
                    
                    connectionInProgress = WorkspaceConnection(context: theDoc.theMC, source: source, outputJack: output)
                    
                    deselectAllComponents()
                    
                    source.select()
                    
                    workspaceView.changeCurrentConnectionToSelectionColor()
                    
                    //printLine("Output \(output.outputNumber) was clicked on.")
                    
                }
                
                return
            }
        }
    }
    
    
    fileprivate func determineSelected() {
        
        theMC?.vcGateway?.scriptEditorVC?.removeMenuForSelectingScripts()
        
        if currentlySelectedComponents.count == 1 { // && selectedConnections.count == 0 {
            
            let component = currentlySelectedComponents[0]
            
            component.isUniquelySelected.value = true
            
            theMC?.vcGateway?.scriptEditorVC?.compModel = component.hostMediator.model
            
            theMC?.vcGateway?.scriptEditorVC?.updateCodeViewFromModel()
            
            if let _ = component.hostMediator.model as? CodeBoxModel {
                
                theMC?.vcGateway?.scriptEditorVC?.addMenuForSelectingScripts()
                
//                theMC?.vcGateway?.scriptEditorVC?.cacheAllScriptFilesInCurrentDirectory()
            }
        }
            
        else {
            
            for comp in currentComponents {
                
                comp.isUniquelySelected.value = false
            }
            
            theMC?.vcGateway?.scriptEditorVC?.compModel = nil // for clearing codeWindow when no model is present
            
            theMC?.vcGateway?.scriptEditorVC?.removeMenuForSelectingScripts()
        }
    }
    
    
    // mouseDragged():
    
    
    fileprivate func selectSourceInProgess() {
        
        deselectAllComponents()
        
        connectionInProgress?.sourceUnit.select()
        
        workspaceView.changeCurrentConnectionToSelectionColor()
        
    }
    
    
    fileprivate func drawConnectionCordInProgress(_ sender: NSEvent) {
        
        // dragging an in-progress connection cord from an existing component output
        
        // currentLineDragEndLocation = view.convertPoint(view.mouseLocationInWindow(), fromView: nil)
        
 //       let wkspaceView = view.subviews[0] //else { return }
        
        currentLineDragEndLocation = wsContentView.localizePoint(sender) // view.localizePoint
    }
    
    
    fileprivate func probeForPossibleEndpointOfConnection() -> (theTarget:ComponentVC, inputNumber:Int)? {
        
        guard let currentEndLoc = currentLineDragEndLocation else { return nil }
        
        guard let cnxInProgress = connectionInProgress else { return nil }
        
        // check all current components besides the one we started the connection from..
        
        for targetUnit in currentComponents {
            
            if targetUnit != cnxInProgress.sourceUnit {
                
                if targetUnit.uiView.frame.contains(currentEndLoc) {
                    
                    for input in targetUnit.inputs {  // detect any proximal endpoint for a connection cord in progress
                        
                        if wsContentView.convert(input.view.frame, from: targetUnit.uiView.connectorsView).contains(currentEndLoc) {  // view.convertRect ...
                            
                            if !input.isOccupied { targetUnit.select() }
                            
                            guard let inputNum = input.inputNumber else { return nil }
                            
                            return (theTarget: targetUnit, inputNumber: inputNum)
                            
                        }
                    }
                }
            }
        }
        
        workspaceView.changeCurrentConnectionToStandardColor()
        
        return nil
    }
    
    
    fileprivate func dragComponent(_ unit: ComponentVC) {
        
        let cvPoint = unit.uiView.mouseLocationInWindow()
        
        unit.wasDragged = true
        
        guard let hitFrame = unit.frameWhenHit, let windowHitPoint = windowHitLocation else { return }
        
        unit.uiView.frame = NSOffsetRect( hitFrame, cvPoint.x - windowHitPoint.x, cvPoint.y - windowHitPoint.y )
        
        unit.uiView.needsDisplay = true
        
        view.needsDisplay = true
        
        theMC?.vcGateway?.upperAreaSplitVC?.view.display()
    }
    
    
    
    // mouseUp():
    
    
    fileprivate func tryToCompleteTheConnection() {
        
        let result = probeForPossibleEndpointOfConnection()
        
        if let _ = result {
            
            let input = result!.theTarget.inputs[result!.inputNumber]
            
            guard let connectorInProgress = connectionInProgress else { return }
            
            
            if !input.isOccupied {
                
                connectorInProgress.completeBrandNewConnection( result!.theTarget, inputJack: input )
                
                selectThisConnection(connectorInProgress)
                
                deselectAllOtherConnections(connectorInProgress)
                
                // upon each new connection, restore all existing connections in lexicographic order according to target component's frame value.
                
                theMC?.restoreAllConnections() 
                
                hostScrollView?.needsDisplay = true
                
                workspaceView.needsDisplay = true
                
                printLog("Successfully connected output to compatible input!")
            }
                
            else {
                
                currentLineDragEndLocation = nil
                
                hostScrollView?.needsDisplay = true
                
                workspaceView.needsDisplay = true
            }
        }
        
    }
        
    
    fileprivate func cleanUpScaffolding() {
        
        clickedOutputPointLocation = nil
        
        currentLineDragEndLocation = nil
        
        connectionInProgress = nil
    }
    
    
}





// ------------------------------------------------------------------
//  MARK: - extension: WorkspaceViewControl - Components Deletion
// ------------------------------------------------------------------


extension WorkspaceViewControl {
    
    
    func deleteSelectedComponents() { // THIS NEEDS TO BE REFACTORED INTO A BOUNDARY-CROSSING REQUEST-MODEL MESSAGE
        
        guard isInDraggableMode else { return }
        
        guard let docModelManager = theMC?.interactor.theCompModelMaker.theDocComponentManager else { return }
        
        var deletionIndexes : [Int] = []
        
        for (index, unit) in currentComponents.enumerated() {
            
            if unit.isSelected {
                
                unit.closingComponent()
                
                removeAssociatedConnections(unit)  // REFACTOR -- move to DocumentModelManager
                
                deletionIndexes.append(index)
            }
        }
        
        for index in deletionIndexes.sorted().reversed() {
            
            let selectedPagenum = docModelManager.workpagesModelStore.selectedPageNum.value
            
            docModelManager.workpagesModelStore.pageSlots[selectedPagenum].page.removeAtIndex(index) // add "selectedPage" property to WorkpageModelsStore
        }
        
        numComponentsDidChange()
        
        theMC?.documentChanged()
        
        refreshView()
        
//        performerVC.view.needsDisplay = true
    }
    
    
    func deleteSelectedConnections() {
        
        guard isInDraggableMode else { return }
        
        var deletionIndexes : [Int] = []
        
        for (index, cord) in currentConnections.enumerated() {
            
            if cord.isSelected {
                
                deletionIndexes.append(index)
            }
        }
        
        removeConnectionsAtIndexes(deletionIndexes)
        
        hostScrollView?.needsDisplay = true
        
//        workspaceView?.needsDisplay = true
    }
    
    
    
    
    func removeAssociatedConnections( _ unit: ComponentVC ) {
        
        //var deletionIndexes : [Int] = []
        
        for connection in currentConnections {
            
            if connection.sourceUnit == unit || connection.targetUnit == unit {
                
                connection.deconstructConnection()
            }
        }
        
        hostScrollView?.needsDisplay = true
        
//        workspaceView?.needsDisplay = true
        
    }
}


/*
extension WorkspaceViewControl {
    
    func addFrameDidChangeObserver() {
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserverForName("NSViewBoundsDidChangeNotification", object: self.hostScrollView.contentView, queue: nil) { notification in
            
            let _ = self.currentComponentsToolbarViews.map {
                
                self.jiggleComponentViews()
                
                $0?.superview?.needsDisplay = true
            }
            
            printLog("WorkspaceViewControl: addFrameDidChangeObserver(): NOTIFICATION \(notification.name): \(notification.userInfo ?? [:]) WAS TRIGGERED.")
        }
    }
    
    
    func jiggleComponentViews() {
        
        for c in currentComponents {
            
            let cf = c.uiView.frame
            
            c.uiView.frame = NSMakeRect(cf.origin.x, cf.origin.y-0.001, cf.size.width, cf.size.height)
            c.uiView.frame = NSMakeRect(cf.origin.x, cf.origin.y+0.001, cf.size.width, cf.size.height)
            
            c.uiView.needsDisplay = true
        }
    }
}
*/



