//
//  TransportControlButtonView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//
 
import Cocoa
import ReactiveKit
import Bond
 
class TransportControlButtonView : NSView {
    
    var model            : TransportControlStateModel!
    let stopButtonRegion : NSRect = NSMakeRect(0, 0, 31, 23)
    let playButtonRegion : NSRect = NSMakeRect(31, 0, 31, 23)
    
    init( origin: NSPoint = NSZeroPoint, model: TransportControlStateModel ) {
        super.init(frame: NSMakeRect( origin.x, origin.y, 62, 23 ))
        self.model = model
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    

    override func draw(_ dirtyRect: NSRect) {
        TransportControlButtonStyleKit.drawTransportButtonPair(transportState: CGFloat(model.transportState.rawValue))
    }
    
    fileprivate func stopButtonClicked(_ theEvent: NSEvent) -> Bool {
        if stopButtonRegion.contains( localizePoint(theEvent) ) { return true }
        return false
    }
    
    fileprivate func playButtonClicked(_ theEvent: NSEvent) -> Bool {
        if playButtonRegion.contains( localizePoint(theEvent) ) { return true }
        return false
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        if      playButtonClicked(theEvent) { model.playButtonClicked() }
        else if stopButtonClicked(theEvent) { model.stopButtonClicked() }
        updateView()
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        model.mouseReleased()
        updateView()
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
}



