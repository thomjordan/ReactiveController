//
//  ComponentViewController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit


class ComponentViewController : NSViewController { //, ComponentProtocol { //, Selectable, Draggable, Connectable {
    
    var uiView : ComponentView {
        
        get { return self.view as! ComponentView }
        
        set( newValue ) { self.view = newValue }
    }
    
    
    var inputVCs  : [ConnectorPointViewController] = []
    var outputVCs : [ConnectorPointViewController] = []
    
    
    var tokens : [Disposable] = []
    
    
    let patchPointRadius : CGFloat = 4
    
    
    
    init(_ compView: ComponentView, frame: NSRect? = nil)  {
        
        super.init( nibName: nil, bundle: nil )
        
        self.uiView = compView
        
        self.uiView.vc = self  
        
        if let fr = frame { self.uiView.frame = fr }
        
        // observeSelectionStatus()
        
        // establishCodeScriptViewLoader()
    }
    
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    deinit { for tok in tokens { tok.dispose() } }
    
    
    
    func establishConnectorsViews() {
        
        for inputPoint  in  inputVCs { establishInputView(inputPoint)   }
        for outputPoint in outputVCs { establishOutputView(outputPoint) }
        
        if generatesOwnInput { placeOutputPointModelsAtFrameBottom() }
            
        else { placeInputPointModelsAtFrameLeft(); placeOutputPointModelsAtFrameRight(); centerContentView() }
        
        uiView.sizeToFit()
    }
    

    func establishInputView(_ inpoint: ConnectorPointViewController) {
        
        uiView.addSubview( inpoint.view )
    }
    
    
    func establishOutputView(_ outpoint: ConnectorPointViewController) {
        
        uiView.addSubview( outpoint.view )
    }
    
    
   // func closingComponent() { view.removeFromSuperview() }
    
    
    var generatesOwnInput : Bool {
        
        if inputVCs.count == 0 { return true }
            
        else { return false }
    }
    
    var generatesOwnOutput : Bool {
        
        if outputVCs.count == 0 { return true }
            
        else { return false }
    }
    
    
    fileprivate func placeInputPointModelsAtFrameLeft() {
        
        let xLoc : CGFloat  = uiView.connectorsView.bounds.origin.x + patchPointRadius*2
        
        let yDiff : CGFloat = uiView.connectorsView.bounds.height / CGFloat(inputVCs.count+1)
        
        let yMax = uiView.connectorsView.bounds.height
        
        for i in 0..<inputVCs.count {
            
            inputVCs[i].placeConnectorInFrame(center: NSMakePoint(xLoc, yMax - yDiff*CGFloat(i+1)), radius: patchPointRadius)
            
        }
        
    }
    
    fileprivate func placeOutputPointModelsAtFrameRight() {
        
        let xLoc : CGFloat  = uiView.connectorsView.bounds.width - patchPointRadius*2 //6.0
        
        let yDiff : CGFloat = uiView.connectorsView.bounds.height / CGFloat(outputVCs.count+1)
        
        let yMax = uiView.connectorsView.bounds.height
        
        for i in 0..<outputVCs.count {
            
            outputVCs[i].placeConnectorInFrame(center: NSMakePoint(xLoc, yMax - yDiff*CGFloat(i+1)), radius: patchPointRadius)
            
        }
        
    }
    
    fileprivate func placeOutputPointModelsAtFrameBottom() {
        
        let xDiff : CGFloat = uiView.connectorsView.bounds.width / CGFloat(outputVCs.count+1)
        
        let yLoc  : CGFloat = uiView.connectorsView.bounds.origin.y + patchPointRadius*2 //6.0
        
        for i in 0..<outputVCs.count {
            
            outputVCs[i].placeConnectorInFrame(center: NSMakePoint(xDiff*CGFloat(i+1), yLoc), radius: patchPointRadius)
            
        }
    }
    
    fileprivate func centerContentView() {
        
        guard let contentView = uiView.contentView else { return }
        
    // let offsetX = contentView.frame.origin.x + (uiView.bounds.width - contentView.bounds.width)
    // let offsetX = (uiView.bounds.width - contentView.bounds.width) / 2
    // guard let offsetX = uiView.contentView?.frame.origin.x + (uiView.bounds.width - uiView.contentView?.bounds.width) else { return }
        
        let sameY = contentView.frame.origin.y
        
        uiView.contentView?.frame.origin = NSMakePoint( 25, sameY )
    }
    
}
