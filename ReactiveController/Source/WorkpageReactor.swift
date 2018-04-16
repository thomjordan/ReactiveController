//
//  WorkpageReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


class WorkpageReactor : Reactor, Selectable, HasModifiers {
    
    var isSelected : Bool = false 
    
    weak var workpageModel : WorkpageModel!
    
    var componentReactors : [ComponentReactor]        = []
    var componentVCs      : [ComponentViewController] = []
    
    let editModeUpdater : Property<Bool>            = Property<Bool>(true)
    let mouseDownEvent  : Property<MouseDownEvent?> = Property<MouseDownEvent?>(nil)
    let mouseDragEvent  : Property<MouseDragEvent?> = Property<MouseDragEvent?>(nil)
    let   mouseUpEvent  : Property<MouseUpEvent?>   = Property<MouseUpEvent?>(nil)
    let deleteKeyEvent  : Property<NSEvent?>        = Property<NSEvent?>(nil)
    let addComponent    : Property<ComponentKind?>  = Property<ComponentKind?>(nil)
    
    // outputs to view
    let refreshView : SafePublishSubject<Void> = SafePublishSubject<Void>()
    
    init(_ workpageModel: WorkpageModel) {
        
        super.init()
        
        self.workpageModel = workpageModel
    }
    
    var windowHitLocation : NSPoint? = nil
    
    var cordWasHit : Bool = false
    
    var clickedOutputPointLocation : NSPoint? = nil
    
    var currentLineDragEndLocation : NSPoint? = nil
    
    var connectionInProgress : (source: ComponentReactor, output: OutputPointReactor)? = nil

    
    var workpageView : WorkpageView? = nil 
    
    func toggleEditMode() {
        
        guard isSelected else { return }
        
        workpageModel.gridIsActive.value = workpageModel.gridIsActive.value != true
        
        updateView()
    }
}

extension WorkpageReactor {
    
    var isDraggable : Bool { return workpageModel.gridIsActive.value }
}


extension WorkpageReactor {
    
    func createScene() -> WorkpageView {
        
        let pageView = WorkpageView(frame: NSMakeRect(0, 0, 2000, 1250))
        
        pageView.reactor = self 
        
      //  pageView.bgColor = NSColor.makeRandom()
        
        workpageModel.observeComponents { [weak self] componentsArray in
            
            switch componentsArray.change {
                
            case .inserts(let indices):
                
                for index in indices.reversed() {
                    
                    // printLog("WorkpageReactor:workpageModel.observeComponents detected an insert at index \(index)")
                    
                    guard let componentReactor = self?.workpageModel.components[index].reactor else { return }
                    
                    guard let rmodel = componentReactor.model else { return }
                    
                    let uiFrame : NSRect = rmodel.header.getFrameAtOrigin()
                    
                    let componentVC = componentReactor.createScene(uiFrame)
                    
                    componentVC.uiView.frame = rmodel.header.getFrameAtOrigin()
                    
                    
                    self?.componentVCs.insert( componentVC, at: index)
                    
                    self?.componentReactors.insert( componentReactor, at: index)
                    
                    pageView.addSubview( componentVC.view ) // should be placed into location index+1
                    
                    pageView.updateView()
                }
                
            case .deletes(let indices):
                
                for index in indices.reversed() {
                    
                    var compReactor : ComponentReactor? = self?.componentReactors.remove(at: index)
                    
                    compReactor?.close()
                    
                    compReactor = nil 
                    
                    let _ = self?.componentVCs.remove(at: index)
                    
                    pageView.subviews[index+1].removeFromSuperview()
                    
                    pageView.updateView()
                }
                
            default: break
                
            }}.dispose(in: bag)
        
        
        
        workpageModel.gridIsActive
            
            .observeNext { [weak self] newState in
            
            pageView.gridState = newState
            
            self?.editModeUpdater.value = newState
            
        }.dispose(in: bag)
        
        
        update( pageView, when: refreshView )
        
        react(to: mouseDownEvent )
        react(to: mouseDragEvent )
        react(to: mouseUpEvent   )
        react(to: deleteKeyEvent )
        
        self.workpageView = pageView // try to refactor out
        
        return pageView 
    }
}


extension WorkpageReactor {
    
    var currentComponents : [ComponentReactor] { return componentReactors.filter { $0.model != nil} }
    
    var currentlySelectedComponents : [ComponentReactor] {
        return (componentReactors.filter { $0.model != nil}).filter { $0.model!.isSelected }
    }
    
    var currentComponentsOrderedByLocation : [ComponentReactor] {
        
        return currentComponents.sorted() {
            
            guard let compView0 = $0.compView, let compView1 = $1.compView else { return false }
            
            if compView0.frame.origin.x < compView1.frame.origin.x { return true }
                
            else if compView0.frame.origin.x == compView1.frame.origin.x {
                
                if compView0.frame.origin.y > compView1.frame.origin.y { return true }
            }
            
            return false
        }
    }
    
    var currentConnections : [ConnectionReactor] {
        return currentComponentsOrderedByLocation.flatMap { $0.inputs.contents.flatMap { $0.activeConnection } }
    }
    
    var currentConnectionModels : [ConnectionModel] {
        return currentConnections.flatMap { $0.model }
    }
    
    var currentlySelectedConnections : [ConnectionReactor] {
        return currentConnections.filter { $0.isSelected }
    }
    
    
    var singlySelectedComponent : Bool {
        return ( currentlySelectedComponents.count == 1 ) && ( currentlySelectedConnections.count == 0 )
    }
    
    var singlySelectedConnection : Bool {
        return ( currentlySelectedComponents.count == 0 ) && ( currentlySelectedConnections.count == 1 )
    }
    
    var newConnectionIsInProgress : Bool {
        return clickedOutputPointLocation != nil  &&  connectionInProgress != nil
    }
}





extension WorkpageReactor {
    
    func react(to mouseDown: Property<MouseDownEvent?> ) {
        
        mouseDown
            
            .observeNext { [weak self] ev in
            
            if let event = ev {
                
                self?.interpretMouseDown( event )
            }

        }.dispose(in: bag)
    }
    
    func react(to mouseDrag: Property<MouseDragEvent?> ) {
        
        mouseDrag
            
            .observeNext { [weak self] ev in
            
            if let event = ev {
                
                self?.interpretMouseDrag( event )
            }
            
        }.dispose(in: bag)
    }
    
    
    func react(to mouseUp: Property<MouseUpEvent?> ) {
        
        mouseUp
            
            .observeNext { [weak self] ev in
            
            if let event = ev {
                
                self?.interpretMouseUp( event )
            }
            
        }.dispose(in: bag)
    }
    
    
    func react(to deleteKey: Property<NSEvent?>) {
        
        deleteKey
            .executeOn(.global(qos: .userInitiated))
            .observeOn(.main)
            .observeNext { [weak self] ev in
                
                if let _ = ev {
                    self?.deleteSelectedComponents()
                    self?.deleteSelectedConnections()
                }
                
            }.dispose(in: bag)
    }
    
    
    func update(_ pageView: WorkpageView, when refreshViewSignal: SafePublishSubject<Void>) {
        
        refreshViewSignal
            
            .observeNext { _ in
                
                pageView.updateView()
                
            }.dispose(in: bag)
        
    }
    
    func refresh() { self.refreshView.next( () ) }
    
    
    func runCodeForAllJSAgents() {
        
        for connection in currentConnections {
            
            connection.model.codeScript.runnableJSAgent?.runScript()
        }
        
        for component in currentComponents {
            
            component.model.codeScript.runnableJSAgent?.runScript()
        }
        
    }
}




// ------------------------------------------------------------------
//  MARK: - extension: WorkpageReactor - interpreting mouseDownEvents:
// ------------------------------------------------------------------


extension WorkpageReactor {
    
    
    func interpretMouseDown(_ event: MouseDownEvent) {
        
        // printLog("WorkspaceReactor: react(to: mouseDownSignal) called.")
        
        windowHitLocation = event.winloc
        
        cordWasHit = false
        
        
        for cord in currentConnections {
            
            if cord.cordRegion.contains(event.viewloc) {
                
                cordWasHit = true
                
                // if isInDraggableMode {
                
                if modifiers(event.sender, excludes: [NSEvent.ModifierFlags.shift]) {
                    
                    deselectAllOtherConnections(cord)
                    
                    deselectAllComponents()
                    
                    cord.toggleSelection()
                }
                    
                else { cord.toggleSelection() }
                
                cordSelectionDidChange()
                
                updateView()
                
                // printLog("WorkspaceReactor: hit detected on a connection path ")
            }
        }
        
        
        func interpretClick(_ unit: ComponentReactor) {
            
            guard let unitModel = unit.model else { return }
            
            if modifiers(event.sender, includes: [NSEvent.ModifierFlags.command]) {
                
                if unitModel.isSpecialSelected { unit.specialDeselect() }
                
                else { unit.specialSelect() }
                
                return
            }
            
            if unitModel.isSelected {
                
                unit.setWasSelected( true )
                
                if unitModel.isBrandNewConnectionSource {
                    
                    unit.setBrandNewConnectionSource( false )
                }
            }
                
            else {
                
                if modifiers(event.sender, excludes: [NSEvent.ModifierFlags.shift]) {
                    
                    deselectAllComponents()
                    
                    deselectAllConnections()
                }
                
                unit.setWasSelected( false ) 
                
                unit.select()
            }
        }
        
        let views_and_units = currentComponents.flatMap { ($0, $0.compView!) }
        
        
        for tuple in views_and_units {
            
            if let contentView = tuple.1.viewContent {
                let cPoint = contentView.convert(event.winloc, from: nil)
                if contentView.bounds.contains(cPoint) {
                    printLog("MouseDown detected within contentView area of \(tuple.0.model.kind.name)")
                    // unit.interpretMouseUp(event)
                    return
                }
            }
            
            if tuple.1.frame.contains(event.viewloc) {
                
                if isDraggable {
                    
                    probeForNewStartingConnection(tuple.0, location: event.viewloc)
                    
                    cacheFramesForComponents()
                }
                
                
                interpretClick(tuple.0)
                
                determineSelected()
                
                return
            }
        }
        
        guard let wkpageView = self.workpageView else { return }

         
        // point is within the general workspace area, not a component
         
        if wkpageView.bounds.contains(event.viewloc) {
         
            if modifiers(event.sender, includes: [NSEvent.ModifierFlags.command]) {
                
                toggleEditMode()
            }
            
            if modifiers(event.sender, excludes: [NSEvent.ModifierFlags.shift]) {
                
                deselectAllComponents()
                
                
                if !cordWasHit {
                    
                    deselectAllConnections()
                    
                    updateView()
                }
 
            }
            
            App.shared.window?.makeFirstResponder(workpageView)
        }
        
        determineSelected()

        
    }
    
    
    
    func cacheFramesForComponents() {
        
        for unit in currentComponents {
            // printLog("WorkpageReactor:cacheFramesForComponents about to capture frame.")
            unit.captureFrame()
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
    
    
    func deselectAllOtherConnections(_ cordOfInterest: ConnectionReactor) {
        
        for cord in currentConnections {
            
            if cord !== cordOfInterest {
                
                cord.deselect()
            }
        }
        
        cordSelectionDidChange()
    }
    
    
    func cordSelectionDidChange() {
        
        workpageView?.display()
    }
    
    func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.workpageView?.needsDisplay = true
        }
    }
    
    
    func probeForNewStartingConnection(_ source: ComponentReactor, location: NSPoint) {
        
        for output in source.outputs.contents {  // look for the start of a possible connection cord
            
            guard let outputVC = output.vc else { return }
            
            if let connectionStarted = (workpageView?.convert(outputVC.view.frame, from: source.compView?.connectorsView).contains(location)) {
                
                if connectionStarted {
                    
                    clickedOutputPointLocation = location
                    
                    if let _ = outputVC.center {
                        
                        connectionInProgress = (source: source, output: output) 
                        
                        deselectAllComponents()
                        
                        source.select()
                        
                        workpageView?.changeCurrentConnectionToSelectionColor()
                        
                        // printLog("Output \(output.portnum) was clicked on.")
                        
                    }
                    
                    return
                }
            }
        }
    }
    
    // used exclusively for syncing codeScript data with current selected ( component or connection )
    // try to refactor codeScript functionality out to its own bounded context
     
    internal func determineSelected() {
     
        let scriptEditor = App.shared.scriptEditor
        
        if singlySelectedComponent {
            let component = currentlySelectedComponents[0]
            scriptEditor.codeModel = component.model.codeScript
        }
            
        else if singlySelectedConnection {
            let connection = currentlySelectedConnections[0]
            scriptEditor.codeModel = connection.model.codeScript
        }
            
        else {
            scriptEditor.codeModel = nil // clears codeWindow when no model is present
        }
    }
    
}



// ------------------------------------------------------------------
//  MARK: - extension: WorkpageReactor - interpreting mouseDragEvents:
// ------------------------------------------------------------------



extension WorkpageReactor {

    func interpretMouseDrag(_ event: MouseDragEvent) {
        
        func dragComponent(_ unit: ComponentReactor) {
            
            let cvPoint = event.winloc // unit.uiView.mouseLocationInWindow()
            
            unit.setWasDragged( true )
            
            guard let hitFrame = unit.frame, let windowHitPoint = windowHitLocation else { return }
            
            unit.compView?.frame = NSOffsetRect( hitFrame, cvPoint.x - windowHitPoint.x, cvPoint.y - windowHitPoint.y )
            
            unit.compView?.updateView()
            
            refresh()
            
            documentChanged()
        }

        
        for sourceUnit in currentComponents {
            
            if let sourceUnitModel = sourceUnit.model {
                
                /*
                if let contentView = sourceUnit.compView?.viewContent {
                    let cPoint = contentView.convert(event.winloc, from: nil)
                    if contentView.bounds.contains(cPoint) {
                        printLog("MouseDragged detected within contentView area of \(sourceUnit.model.kind.name)")
                        // unit.interpretMouseUp(event)
                        return
                    }
                }
                */ 
                
                if isDraggable {
                    
                    if newConnectionIsInProgress {
                        
                        selectSourceInProgess()
                        
                        drawConnectionCordInProgress(event.sender)
                        
                        let _ = probeForPossibleEndpointOfConnection()
                        
                        return
                    }
                    
                    if sourceUnitModel.isSelected {
                        
                        if sourceUnitModel.isBrandNewConnectionSource {
                            
                            sourceUnit.setBrandNewConnectionSource( false )
                            
                            sourceUnit.deselect()
                            
                        } else {
                            
                            dragComponent(sourceUnit)
                        }
                    }
                }
            }
        }
    }
    
    

    func selectSourceInProgess() {
        
        deselectAllComponents()
        
        connectionInProgress?.source.select()
        
        workpageView?.changeCurrentConnectionToSelectionColor()
        
    }
    
    
    func drawConnectionCordInProgress(_ sender: NSEvent) {
        
        // dragging an in-progress connection cord from an existing component output
        
        currentLineDragEndLocation = workpageView?.localizePoint(sender)
    }
    
    
    func probeForPossibleEndpointOfConnection() -> (theTarget:ComponentReactor, inputNumber:Int)? {
        
        guard let currentEndLoc = currentLineDragEndLocation else { return nil }
        
        guard let cnxInProgress = connectionInProgress else { return nil }
        
        guard let wkpageView = workpageView else { return nil }
        
        // check all current components besides the one we started the connection from..
        
        for targetUnit in currentComponents {
            
            if targetUnit !== cnxInProgress.source {
                
                if let targetView = targetUnit.compView {
                    
                    if targetView.frame.contains(currentEndLoc) {
                        
                        for input in targetUnit.inputs.contents {  // detect any proximal endpoint for a connection cord in progress
                            
                            if let inputVC = input.vc {
                                
                                if wkpageView.convert(inputVC.view.frame, from: targetView.connectorsView).contains(currentEndLoc) {
                                    
                                    //  if let endpointTouched = (wkpageView.convert(input.vc.view.frame, from: targetUnit.compView.connectorsView).contains(currentEndLoc)) {
                                    
                                    //    if endpointTouched {
                                    
                                    if !input.isOccupied { targetUnit.select() }
                                    
                                    let inputNum = input.model.portnum
                                    
                                    return (theTarget: targetUnit, inputNumber: inputNum)
                                    //   }
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
        
        workpageView?.changeCurrentConnectionToStandardColor()
        
        return nil
    }
    
}



// ------------------------------------------------------------------
//  MARK: - extension: WorkpageReactor - interpreting mouseUpEvents:
// ------------------------------------------------------------------

extension WorkpageReactor {
    
    func interpretMouseUp(_ event: MouseUpEvent) {
        
        // printLog("WorkspaceReactor: react(to: mouseUpSignal) called.")
        
        if isDraggable {
            
            tryToCompleteTheConnection()
            
            cleanUpScaffolding()
        }
        
        
        for unit in currentComponents {
            
            if let unitModel = unit.model {
                
                unit.captureFrame()
                
                if let contentView = unit.compView?.viewContent {
                    let cPoint = contentView.convert(event.winloc, from: nil)
                    if contentView.bounds.contains(cPoint) {
                        printLog("MouseUp detected within contentView area of \(unit.model.kind.name)")
                        unit.interpretMouseUp(event)
                        return
                    }
                }
                
                if isDraggable {
                    
                    if unitModel.wasSelected {
                        
                        if !unitModel.wasDragged { unit.deselect() }
                            
                        else {
                            
                            //unit.writeFrameToModel()
                            
                            // unit.captureFrame()
                            
                            unit.setWasDragged( false )
                            
                            unit.setWasSelected( false )
                        }
                    }
                }
            }
        }
    }
    
    
    func tryToCompleteTheConnection() {
        
        guard let result = probeForPossibleEndpointOfConnection() else { return }
        
        guard let input = result.theTarget.inputs[result.inputNumber] else { return }
        
        guard let connectorInProgress = connectionInProgress else { return }
        
        guard let sourceModel = connectorInProgress.source.model else { return }
        guard let targetModel = result.theTarget.model else { return }
        
       // guard let targetReactor = result.theTarget else { return }
        
        if !input.isOccupied {
            
            let cmodel = ConnectionModel(targetID: targetModel.idNum, targetInputNum: result.inputNumber, sourceID: sourceModel.idNum, sourceOutputNum: connectorInProgress.output.model.portnum )
            
            targetModel.inwardConnections.append( cmodel )
            
            // App.shared.workspaceReactor.restoreIncomingConnections(result.theTarget) // GOAL: Achieve correct results with this instead of above line
            
            App.shared.workspaceReactor.restoreWorkpageConnections(self)
            
            // App.shared.restoreAllConnections() //Upon each new connection, restore all existing connections in lexicographic order of target frames
            
            guard let cReactor = result.theTarget.inputs[result.inputNumber]?.activeConnection else { return }
            
            deselectAllOtherConnections(cReactor)
            
            selectThisConnection(cReactor)
            
            updateView()
            
            documentChanged()
            
            // printLog("Successfully connected output to compatible input!")
        }
            
        else {
            
            currentLineDragEndLocation = nil
            
            updateView()
            
        } 
    }
    
    
    func cleanUpScaffolding() {
        
        clickedOutputPointLocation = nil
        
        currentLineDragEndLocation = nil
        
        connectionInProgress      = nil
    }
    
    func selectThisConnection(_ cord: ConnectionReactor) {
        
        cord.select()
        
        cordSelectionDidChange()
    }
    
}

// ------------------------------------------------------------------
//  MARK: - extension: WorkpageReactor - Components Deletion
// ------------------------------------------------------------------


extension WorkpageReactor {
    
    
    func deleteSelectedConnections() {
        
        guard isDraggable else { return }
        
        let _ = currentlySelectedConnections.map { closeAndDeleteConnection( $0 ) }
        
        cordSelectionDidChange()
        
        updateView()
        
        documentChanged()
    }
    
    
    func deleteSelectedComponents() {
        
        guard isDraggable else { return }
        
        let _ = currentComponents.enumerated().reversed()
            
            .filter { $0.1.isSelected }.map {
                
                removeAssociatedConnections( $0.1 )
                workpageModel.components.remove(at: $0.0)
        }
        
        updateView()
        
        documentChanged()
    }
    
    
    func removeAssociatedConnections( _ unit: ComponentReactor ) {
        
        let _ = currentConnections
            
            .filter {  $0.sourceUnit === unit || $0.targetUnit === unit }
            
            .map { closeAndDeleteConnection( $0 ) }
        
        updateView()
        
        documentChanged()
    }
    
    
    func closeAndDeleteConnection(_ c: ConnectionReactor) {
        
        var connection : ConnectionReactor? = c
        let component  = connection?.targetUnit
        let input      = connection?.targetInput
        
        connection?.deconstructConnection()
        input?.activeConnection = nil
        connection = nil
        
        if let inputnum = input?.portnum, let inputReaktors = component?.inputs {
            
            if inputnum < inputReaktors.count {
                
                inputReaktors[inputnum]?.model.pin.asStringCoder()?.value = "NULL_INPUT"
                
                component?.model?.inputs[inputnum]?.incomingConnection = nil
                component?.model?.deleteIncomingConnectionByInputNumber(inputnum)
                
            }
        }
    }
    
}


