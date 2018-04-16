//
//  ComponentReactor.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

// Current ComponentReactor specialized subclasses in use for:
// Keyscale, TriggerPlayer, MidiSource, StepPattern, BufferPlayer


protocol ComponentReactor : class {
    
    var bags : DisposeBagStore { get set }
    
    var model : ComponentModel! { get set }
    
    var inputs  : InputPointReactors!  { get set }
    
    var outputs : OutputPointReactors! { get set }
    
    var establishProcess : (() -> ())? { get set }
    
    var establishOutputs : (() -> ())? { get set }
    
    var uiView : ComponentContentView? { get set }
    
    
    init()
    
    init(_ model: ComponentModel)
    
    
  //  func observeSelectionStatus()
    func interpretMouseUp(_ event: MouseUpEvent)
    func close()
}


extension ComponentReactor {
    
    init(_ model: ComponentModel) {
        
        self.init()
        
        self.model = model
        
        self.inputs  = InputPointReactors(  model.inputs  )
        
        self.outputs = OutputPointReactors( model.outputs )
        
        printLog("ComponentReactor:init() called for \(model.kind.name)")
    }
}



extension ComponentReactor {
    
    func createScene(_ uiFrame : NSRect? = nil) -> ComponentViewController {
        
        establishProcess?()
        establishOutputs?()
        
        printLog("$$$ ComponentReactor::createScene() invoked for \(model.kind.name) $$$")
        
        let vc = ComponentViewController( ComponentView( uiView! ) )
        
        vc.inputVCs  =  inputs.contents.map { $0.createScene() }
        vc.outputVCs = outputs.contents.map { $0.createScene() }
        
        vc.uiView.setup() 
        
        vc.establishConnectorsViews()
        
        establishProcess?()
        establishOutputs?()
        
        model?.header.frame = vc.uiView.frame
        
        model?.refresh?()
        
        return vc
    }
    
    
    func setRefresh(newBlock: @escaping (() -> ()) ) { model.refresh = newBlock }
}



final class ComponentReactorDefault : ComponentReactor {
    
    var bags = DisposeBagStore() 
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    var outputRoutines : [Int : (Any) -> Void] = [:]
    
    
    init() { }
    
  //  func close() { disposeAll() }
}



extension ComponentReactor {  // selection state
    
    var selectionState : Property<ComponentSelectionState> { return model.selectionState }
    
    var isSelected        : Bool { return selectionState.value.isSelected        }
    var isSpecialSelected : Bool { return selectionState.value.isSpecialSelected }
    
    var frame : NSRect? { return model.frame }
    
    var isBrandNewConnectionSource : Bool { return model.isBrandNewConnectionSource }
    
    var wasDragged  : Bool { return model.wasDragged  }
    
    var wasSelected : Bool { return model.wasSelected }
    
    var compView : ComponentView? { return uiView?.containerView }
    
    func captureFrame() {
        if let fr = compView?.frame {
            // printLog("ComponentReactor:captureFrame() capturing rect: \(fr)")
            model.header.frame = fr
            model.header.origin = NSMakePoint( fr.origin.x, fr.origin.y )
        }
    }
    
    func setBrandNewConnectionSource(_ val: Bool) {
        model.isBrandNewConnectionSource = val
    }
    
    func setWasDragged(_ val: Bool) {
        model.wasDragged = val
    }
    
    func setWasSelected(_ val: Bool) {
        model.wasSelected = val
    }
    
    func select() {
        model.select()
    }
    
    func deselect() {
        model.deselect()
    }
    
    func specialSelect() {
        model.specialSelect()
    }
    
    func specialDeselect() {
        model.specialDeselect()
    }
    
    func observeSelectionStatus() {
        
        guard let selectionBag = bags.makeNew("selection") else { return }
        
        selectionState
            
            .observeOn(.main)
            
            .observeNext { [unowned self] newstate in
                
                let mstate = newstate.getMultiState()
                
                // refactor local to uiView
                
                var theState : ComponentBoxHighlightState = .noneSelected
                
                switch mstate { // refactor local to uiView
                    
                case .selected:        theState = .selected
                    
                case .specialSelected: theState = .specialSelected
                    
                case .bothSelected:    theState = .bothSelected
                    
                case .noneSelected:    theState = .noneSelected
                    
                }
                
                // printLog("Component: observeSelectionStatus(): observeNext() triggered from a selection state change.")
                
                self.compView?.highlightBox(theState)
                
                self.compView?.updateView() 
                
            }.dispose(in: selectionBag)
    }
    
//    func initSelectionObserverBag() -> DisposeBag? { return bags.makeNew("selection") }
    
    
    func disposeAll() {
        for key in bags.keys { bags[key]?.dispose() }
    }
    
    
    func interpretMouseUp(_ event: MouseUpEvent) {
        printLog("ComponentReactor:interpretMouseUp() called.")
    }
    
    func close() { disposeAll() }

    
    // ---------------------------------
    
    
    /*
    
    var inwardConnections : [ConnectionReactor] {
        
        let connections = inputs.contents.flatMap { $0.activeConnection }
        
        return connections
    }
    
    
    func retrieveIncomingConnectionByInputNumber(_ inputNum: Int) -> ConnectionReactor? {
        
        var result : ConnectionReactor? = nil
        
        for connection in inwardConnections {
            
            if connection.model?.targetInputNum == inputNum {
                
                result = connection
                
                break
            }
        }
        
        return result
    }
    
    
    func deleteIncomingConnectionByInputNumber(_ inputNum: Int) {
        
        var deletionIndexes : [Int] = []
        
        for (index, connection) in inwardConnections.enumerated() {
            
            if connection.model?.targetInputNum == inputNum {
                
                deletionIndexes.append(index)
            }
        }
        
        // inwardConnections.remove(indexes:deletionIndexes)  ??????
        
        for index in deletionIndexes.sorted().reversed() {
            
            // inwardConnections[index].model = nil  ??????
            
            // printLog("D'OH!")
        }
    }
 
     */
}
