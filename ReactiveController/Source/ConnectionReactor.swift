//
//  ConnectionReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/14/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit
import Bond


protocol ConnectionNodeSet : class {
    
    var model        : ConnectionModel!     { get set }
    
    var sourceUnit   : ComponentReactor?    { get set }
    
    var sourceOutput : OutputPointReactor?  { get set }
    
    var targetUnit   : ComponentReactor?    { get set }
    
    var targetInput  : InputPointReactor?   { get set }
    
    init(model: ConnectionModel)
}

protocol ConnectionSignalSet : class {
    
    var liveTask  : SignalTaskType? { get set }
    
    var bag       : DisposeBag      { get }
}


class ConnectionReactor : ConnectionNodeSet, ConnectionSignalSet {
    
    var bag          : DisposeBag = DisposeBag()
    
    weak var model   : ConnectionModel!
    
    var sourceUnit   : ComponentReactor?
    
    var sourceOutput : OutputPointReactor?
    
    var targetUnit   : ComponentReactor?
    
    var targetInput  : InputPointReactor?
    
    
    var cordPath   = NSBezierPath()
    
    var cordRect   = NSBezierPath()
    
    // an invisible wider 'cordRect' to overlay for a more expanded clicking area
    var cordRegion = NSBezierPath()
    
    
    var liveTask  : SignalTaskType?
    
    
    var isSelected : Bool { return model.isSelected }
    
    var isMostRecentSelection : Bool = false
    
    
    required init(model: ConnectionModel) {
        
        self.model = model
        
        populateMembers( model )
        
        completeConnection()
    }
    
    
    private func populateMembers(_ model: ConnectionModel) {
        
        guard let source = App.shared.retrieveComponentByID( model.sourceID ) else { return }
        
        guard let output = source.outputs[model.sourceOutputNum] else { return } 
        
        guard let target = App.shared.retrieveComponentByID( model.targetID ) else { return }
        
        guard let input  = target.inputs[model.targetInputNum] else { return }
        
        sourceUnit   = source
        
        sourceOutput = output
        
        targetUnit   = target
        
        targetInput  = input
    }
    
    private func completeConnection() {
        
        printLog("ConnectionReactor : completeConnection() ")
        
        connectSignalPath()
        
        addOutputConnectionToSource()
        
        assignInputConnectionToTarget()
        
        updateConnectorColor()
        
        sourceUnit?.setBrandNewConnectionSource( true )
    }
    
    
    private func addOutputConnectionToSource() {
        
        sourceOutput?.addOutputConnection(self)
        
    }
    
    
    private func assignInputConnectionToTarget() {
        
        targetInput?.assignInputConnection(self)
        
    }
    
    private func removeOutputConnectionFromSource() {
        
        sourceOutput?.removeOutputConnection(self)
        
    }
    
    private func removeInputConnectionFromTarget() {
        
        targetInput?.removeInputConnection()
    }
    
    
    private func updateConnectorColor() {
        
        sourceOutput?.updateView()
        
        targetInput?.updateView()
    }
    
}


// non-private methods (Internal)

extension ConnectionReactor {
    
    func deconstructConnection() {
        
        removeOutputConnectionFromSource()
        
        disconnectSignalPath()
        
        updateConnectorColor()
        
      //  disposeAllAttributes()
        
        cordPath.removeAllPoints()
        
        cordRect.removeAllPoints()
    }
    
    
    func select() { model.isSelected = true }
    
    func deselect() { model.isSelected = false }
    
    func toggleSelection() {
        model.isSelected = (model.isSelected != true)
    }
    
}

extension ConnectionReactor {
    
    fileprivate func connectSignalPath() {
        
        func tryToBindToValidSignalTask() -> Bool {
            
            // check to see if the source OutputPoint has a reference to a SignalTask whose output type matches one of the target InputPoint's allowable types.
            
            var typeRecognized = false
            
            
            if let source = sourceOutput, let target = targetInput {
                
                if let runTask = source.outputTask {
                    
                    let theTask = runTask()
                    
                    self.liveTask = theTask
                        
                    self.model.codeScript.runnableJSAgent = ConnectionJSAgent(model.codeScript, task: theTask)  
                    
                    let taskPinType = Connecter.detectType(liveTask!.outPin)
                    
                    typeRecognized = matchesASupportedTargetType(taskPinType)
                    
                    
                    if typeRecognized {
                        
                        // if SignalTask's output type matches one of the target InputPoint's allowable types,
                        
                        // (ToDo: and if target component type is also recognized...)
                        
                        //  then attach SignalTask to sourceOutput,
                        
                        // ... and create a Connector pin for the targetInput whose type matches the outPin of the SignalTask.
                        
                        
                        liveTask!.attachTaskTo(source)
                        
                        target.model.pin = liveTask!.outPin.getDuplicate()
                        
                        
                        // bind SignalTask's outPin to the targetInput's ConnectorPin
                        
                        
                        Connecter.makeBindFromTask(self, toTarget: target)?.dispose(in: bag)
                        
                        if let configureTarget = target.refresh { configureTarget() }
                        
                        // printLog("ConnectionReactor: MADE CONNECTION FROM ATTACHED TASK OUTPUT TO TARGET INPUT!!")
                    }
                        
                    else { self.liveTask = nil }
                }
            }
            
            return typeRecognized
        }
        
        
        func tryToBindToMatchingTargetType() -> Bool {
            
            var typeRecognized = false
            
            if let source = sourceOutput, let target = targetInput {
                
                let pinType = Connecter.detectType(source.pin)
                
                // check to see if the sourceOutput type matches any of the targetInput's given types
                
                typeRecognized = matchesASupportedTargetType(pinType)
                
                
                // if so, create a matching type connectorPin for the targetInput and bind the sourceInput to it
                
                if typeRecognized {
                    
                    // printLog("ConnectionReactor: RECOGNIZED TYPE \(source.pin) !!")
                    
                    target.model.pin = source.pin.getDuplicate()
                    
                    Connecter.makeBindFrom(source, toTarget: target)?.dispose(in: bag)
                    
                    if let configureTarget = target.refresh { configureTarget() }
                }
            }
            
            return typeRecognized
        }
        
        
        // --------------------
        
        
        if let source = sourceOutput {
            
            // setup configurations
            
            targetUnit?.establishProcess?()
            
            if source.activeConnections.count == 0 {
                
              //  sourceUnit?.establishOutput?()
                
                if let configureSource = source.refresh { configureSource() } // config source output
            }
            
            
            // first look for a signalTask whose output type matches one of the target's acceptable types
            
            var typeRecognized = tryToBindToValidSignalTask()
            
            
            // if that doesn't work, then try to match and bind our sourceOutput type to one of the TargetInput's acceptable types
            
            if !typeRecognized {
                
                typeRecognized = tryToBindToMatchingTargetType()
            }
            
            if !typeRecognized {
                
                let pinType = Connecter.detectType(source.pin)
                
                // printLog("ConnectionReactor: DID NOT IMMEDIATELY RECOGNIZE TYPE \(pinType), so will now look for a provided SignalTask to attach and deploy.")
            }
        }
            
        else {
            
            // printLog("ConnectionReactor: [ERROR]: the source OutputPoint and/or target InputPoint is missing.")
            
        }
    }
    
    
    
    fileprivate func matchesASupportedTargetType(_ sourcePinType: String) -> Bool {
        
        if let target = targetInput {
            
            let typeInfo = target.model.header.info
            
            // printLog("ConnectionReactor: Trying to match types :: sourceType = \(sourcePinType) ; targetType = \(typeInfo)")
            
            if sourcePinType.uppercased() == typeInfo.uppercased() {
                
                return true
            }
        }
        
        return false
    }
    
    
    fileprivate func disconnectSignalPath() {
        bag.dispose()
    }
}







