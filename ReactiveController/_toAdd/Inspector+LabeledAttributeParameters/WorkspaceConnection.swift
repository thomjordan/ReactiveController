//
//  WorkspaceConnection.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 1/17/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Neon



protocol ConnectionNodeSet : class {
    
    var sourceUnit : ComponentVC!      { get set }
    
    var sourceOutput : OutputPoint!  { get set }
    
    var targetUnit : ComponentVC?      { get set }
    
    var targetInput : InputPoint?    { get set }
    
    init(context: MainCoordinator, source: ComponentVC, outputJack: OutputPoint)
    
    func completeBrandNewConnection(_ theTarget: ComponentVC, inputJack: InputPoint, selected: Bool)
    
    static func createFullConnection(context: MainCoordinator,
        source: ComponentVC, outputJack: OutputPoint,
        theTarget: ComponentVC, inputJack:  InputPoint) -> WorkspaceConnection
}


protocol ConnectionCableSet {
    
    var cordPath   : NSBezierPath!  { get set }
    
    var cordRect   : NSBezierPath!  { get set }
    
    var cordRegion : NSBezierPath!  { get set }
}


protocol ConnectionAttributeSet : class {
    
    var attrModel : ConnectionAttributesViewModelType?  { get set }
    
    var attrView  : ConnectionAttributesView!   { get set }
    
    var disposals : [Disposable]            { get set }
    
    
    func addToDisposal(_ disp: Disposable)
    
    func disposeAllAttributes() 
}


protocol ConnectionSignalSet : class {
    
    var bindingToken : Disposable? { get set }
    
    var liveTask     : SignalTaskType? { get set }
    
    func connectSignalPath()
}


protocol ConnectionCableLayer : ConnectionNodeSet, ConnectionCableSet { }


// MARK: - ConnectionSignalLayer


protocol ConnectionSignalLayer : ConnectionNodeSet, ConnectionSignalSet { }


extension ConnectionSignalLayer {
    
    
    func connectSignalPath() {
        
        func tryToBindToValidSignalTask() -> Bool {
            
            
            // check to see if the source OutputPoint has a reference to a SignalTask whose output type matches one of the target InputPoint's allowable types.
            
            var typeRecognized = false
            
            
            if let source = sourceOutput, let target = targetInput {
                
                if let taskFactory = sourceOutput.outputTask {
                    
                    self.liveTask = taskFactory()
                    
                    let taskPinType = ConnectorPin.detectType(liveTask!.outPin)
                    
                    typeRecognized = matchesASupportedTargetType(taskPinType)
                    
                
                    if typeRecognized {

                        // if SignalTask's output type matches one of the target InputPoint's allowable types,
                        
                        //  then attach SignalTask to sourceOutput,
                        
                        // ... and create a Connector pin for the targetInput whose type matches the outPin of the SignalTask.
                        
                        
                        liveTask!.attachTaskTo(source.connector)
                        
                        target.connector.pin = liveTask!.outPin.getDuplicate()
                        
                  
                        // bind SignalTask's outPin to the targetInput's ConnectorPin
                        
                        
                        bindingToken = ConnectorPin.makeBindFromTask(self, to: target)  //makeBindFrom(source, to: target)
                        
                        if let configureTarget = target.resetConfiguration { configureTarget() }
                        
                        printLog("WorkspaceConnection: MADE CONNECTION FROM ATTACHED TASK OUTPUT TO TARGET INPUT!!")
                    }
                        
                    else { self.liveTask = nil }
                }
            }
            
            return typeRecognized
        }
        
        
        func tryToBindToMatchingTargetType() -> Bool {
            
            var typeRecognized = false
            
            if let source = sourceOutput, let target = targetInput {
                
                let pinType = ConnectorPin.detectType(source.connector.pin)
                
                
                // check to see if the sourceOutput type matches any of the targetInput's given types
                
                typeRecognized = matchesASupportedTargetType(pinType)
                
                
                // if so, create a matching type connectorPin for the targetInput and bind the sourceInput to it
                
                if typeRecognized {
                    
                    printLog("WorkspaceConnection: RECOGNIZED TYPE \(pinType) !!")
                    
                    target.connector.pin = source.connector.pin.getDuplicate()
                    
                    bindingToken = ConnectorPin.makeBindFrom(source, to: target)
                    
                    if let configureTarget = target.resetConfiguration { configureTarget() }
                }
            }
            
            return typeRecognized
        }
        
        
        // --------------------
        
        
        if let source = sourceOutput, let target = targetInput {
            
            // setup configurations
            
            target.hostMediator?.processor?.establishProcessConfiguration()
            
            if source.activeConnections.count == 0 {
                
                source.hostMediator?.processor?.establishOutputConfigurations()
                
                if let configureSource = source.resetConfiguration { configureSource() } // config source output
            }
            
            
            // first look for a signalTask whose output type matches one of the target's acceptable types
            
            var typeRecognized = tryToBindToValidSignalTask()
            
            
            // if that doesn't work, then try to match and bind our sourceOutput type to one of the TargetInput's acceptable types
            
            if !typeRecognized {
                
                typeRecognized = tryToBindToMatchingTargetType()
            }
            
            if !typeRecognized {
                
                let pinType = ConnectorPin.detectType(source.connector.pin)
                
                printLog("WorkspaceConnection: DID NOT IMMEDIATELY RECOGNIZE TYPE \(pinType), so will now look for a provided SignalTask to attach and deploy.")
            }
        }
            
        else { printLog("WorkspaceConnection: [ERROR]: the source OutputPoint and/or target InputPoint is missing.") }
    }

    
    
    
    fileprivate func matchesASupportedTargetType(_ sourcePinType: String) -> Bool {
        
        if let target = targetInput {
            
            if let inputslist = target.hostMediator?.inputs, let targetsInputNum = target.inputNumber {
                
                let typeInfo = inputslist[targetsInputNum].typeInfo
                
                printLog("WorkspaceConnection: Trying to match type :: pinType = \(sourcePinType) ; typenameToMatch = \(typeInfo.label); \(typeInfo.mtype);")
                
                if sourcePinType.uppercased() == typeInfo?.mtype.uppercased() {
                    
                    return true
                }
            }
        }
        
        return false
    }
}


// MARK: - ConnectionAttributesLayer


protocol ConnectionAttributesLayer : ConnectionNodeSet, ConnectionAttributeSet {

    func genConnectionBaseAttributes(_ model: ConnectionAttributesViewModelType)
}


extension ConnectionAttributesLayer {
    
    func genConnectionBaseAttributes(_ model: ConnectionAttributesViewModelType) {
        
        attrModel = model
        
        guard let targetunit = targetUnit else { return }
        
        
        let disp1 = sourceUnit.hostMediator.editedName.observeNext { text in
            
            guard let txt = text else { return }
            
            model.sourceUnitName.value = txt
            
            printLog("ConnectionBase: observed SourceUnit's editedName change to \(txt)")
        }
        
        let disp2 = targetunit.hostMediator.editedName.observeNext { text in
            
            guard let txt = text else { return }
            
            model.targetUnitName.value = txt
            
            printLog("ConnectionBase: observed TargetUnit's editedName change to \(txt)")
        }
        
        model.sourceDataName.value = sourceOutput.name
        
        addToDisposal(disp1)
        
        addToDisposal(disp2)
    }
    
    
    func addToDisposal(_ disp: Disposable) {
        
        disposals.append( disp )
    }
    
    func disposeAllAttributes() {
        
        for d in disposals { d.dispose() }
    }
    
}



// --------------------------------------
//  MARK: - WorkspaceConnection (NSObj)
// --------------------------------------


class WorkspaceConnection : NSObject, ConnectionAttributesLayer, ConnectionSignalLayer {
    
    var theMC : MainCoordinator!
    
    var sourceUnit : ComponentVC!
    
    var sourceOutput : OutputPoint!
    
    var targetUnit : ComponentVC?
    
    var targetInput : InputPoint?
    
    
    var cordPath   = NSBezierPath()
    
    var cordRect   = NSBezierPath()
    
    var cordRegion = NSBezierPath() // an invisible wider 'cordRect' to overlay for a more expanded clicking area.
    
    
    
    var isSelected : Bool = false
    
    var isMostRecentSelection : Bool = false
    
    var bindingToken : Disposable?
    
    var liveTask  : SignalTaskType?
    
    
    var attrModel : ConnectionAttributesViewModelType?
    
    var attrView  : ConnectionAttributesView!
    
    var disposals : [Disposable] = []

    
    required init(context: MainCoordinator, source: ComponentVC, outputJack: OutputPoint) {
        
        self.theMC = context
        
        sourceUnit = source
    
        sourceOutput = outputJack
        
    }
    
    
    // designed expressly for restoring previously existing connections after unarchiving their model representation
    
    static func createFullConnection(context: MainCoordinator,
                                     source: ComponentVC, outputJack: OutputPoint,
                                  theTarget: ComponentVC, inputJack:  InputPoint) -> WorkspaceConnection {
                                    
        let newConnection = WorkspaceConnection(context: context, source: source, outputJack: outputJack)
        
        newConnection.completeConnection(theTarget, inputJack: inputJack)
     
        return newConnection
    }
    
    
    func completeBrandNewConnection(_ theTarget: ComponentVC, inputJack: InputPoint, selected: Bool = true) {
     
        createConnectionModel(theTarget, targetInputJack: inputJack)
        
        completeConnection(theTarget, inputJack: inputJack, selected: selected)
        
        // add any related attributes to the connection model
        
        guard let theSignalTask = liveTask else { return }
        
        if let targetMediator = theTarget.hostMediator, let targetInputNum = inputJack.inputNumber {
            
            if let connModel = targetMediator.model.retrieveIncomingConnectionByInputNumber( targetInputNum ) {
                
                if connModel.cableParameters.isEmpty { // should always be empty since the model was just created
                    
                    // populate the model with the set of LabeledAttributeParameters specified in the SignalTask.
                    
                    for cbparams in theSignalTask.attrParams {
                        
                        connModel.cableParameters.append( cbparams )
                    }
                }
            }
        }
        
        // upon each new connection, restore all existing connections in lexicographic order according to target component's frame value.
        
        theMC.restoreAllConnections()
    }
    
    
    fileprivate func completeConnection(_ theTarget: ComponentVC, inputJack: InputPoint, selected: Bool = true) {
        
        targetUnit = theTarget
        
        targetInput = inputJack
        
        
        connectSignalPath()
        
        
        addOutputConnectionToSource()
        
        assignInputConnectionToTarget()
        
        updateConnectorColor()
        
        sourceUnit.isBrandNewConnectionSource = true
        
        
        synergizeModelAndTaskAttributes(liveTask: liveTask, target: inputJack)
        
        genAttributesView()
    }
    
    
    fileprivate func createConnectionModel(_ target: ComponentVC, targetInputJack: InputPoint) {
        
        let source = sourceUnit.hostMediator.model.idNum
        
        let outnum = sourceOutput.outputNumber
        
        let  innum = targetInputJack.inputNumber
        
        if let onum = outnum, let inum = innum {
            
            let cmodel : ConnectionModel = ConnectionModel(targetInputNum: inum, sourceID: source!, sourceOutputNum: onum)
            
            target.hostMediator.model.incomingConnections.append(cmodel)
        }
    }
    
    
    func deconstructConnection() {
        
        let wsView = theMC.vcGateway?.workspaceVC?.view
        
        removeOutputConnectionFromSource()
        
        removeInputConnectionFromTarget()
        
        disconnectSignalPath()
        
        updateConnectorColor()
        
        disposeAllAttributes()
        
        cordPath.removeAllPoints()
        
        cordRect.removeAllPoints()
        
        wsView?.needsDisplay = true
    }
    
    
    func toggleSelection() {
        
        isSelected = isSelected != true
        
    }
    
    
    func select() {
        
        isSelected = true
    }
    
    func deselect() {
        
        isSelected = false
    }
    
    
    
    
    
    func genAttributesView(_ label : String = "") {
        
        // for now, this assumes that if there is an outputTask then it was attached & deployed:
        
        if let _ = liveTask {
            
            genConnectionBaseAttributes( ConnectionAttributesViewModel(taskArgs: liveTask!.attrParams) )
        }
            
        else { genConnectionBaseAttributes( ConnectionAttributesViewModel(taskArgs: []) ) }
        
        self.attrView = ConnectionAttributesView(hostConnection: self)
        
        printLog("WorkspaceConnection: genAttributesView(): new attributes view created for \(label)")
    }
    
    
    // ----- private -----
    
    fileprivate func addOutputConnectionToSource() {
        
        sourceOutput.addOutputConnection(self)
        
    }
    
    
    fileprivate func assignInputConnectionToTarget() {
        
        targetInput?.assignInputConnection(self)
        
    }
    
    fileprivate func removeOutputConnectionFromSource() {
        
        sourceOutput.removeOutputConnection(self)
        
    }
    
    
    fileprivate func removeInputConnectionFromTarget() {
        
        targetInput?.removeInputConnection()
        
    }
 
    
    fileprivate func disconnectSignalPath() {
        
        bindingToken?.dispose()
        
    }
    
    
    fileprivate func updateConnectorColor() {
        
        sourceOutput.view.needsDisplay = true
        
        targetInput?.view.needsDisplay = true
    }
    
    
    fileprivate func synergizeModelAndTaskAttributes(liveTask: SignalTaskType?, target: InputPoint) {
        
        guard let liveTask = self.liveTask else { return } // this method can only work if there's a liveTask
        
        // if the associated connectionModel's cableParameters array hasn't been written to yet (i.e. is empty)...
        
        if let targetMediator = target.hostMediator, let targetInputNum = target.inputNumber {
            
            if let connModel = targetMediator.model.retrieveIncomingConnectionByInputNumber( targetInputNum ) {
                
                
                if connModel.cableParameters.isEmpty {
                    
                    // then populate it with the set of LabeledAttributeParameters specified in the SignalTask.
                    
                    for cbparams in liveTask.attrParams {
                        
                        connModel.cableParameters.append( cbparams )
                    }
                }
                    
                else {
                    
                    // However, if the model has already been populated then its attributes are the ones in use.
                    
                    // So then replace the attributes of the SignalTask with the now-in-use attributes of the ConnectionModel.
                    
                    liveTask.attrParams = []
                    
                    for ap in connModel.cableParameters {
                        
                        liveTask.attrParams.append( ap )
                    }
                }
            }
        }
    }
    
}

