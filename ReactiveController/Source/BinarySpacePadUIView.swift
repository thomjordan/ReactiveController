//
//  BinarySpacePadUIView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/18/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


final class BinarySpacePadUIView : ComponentContentView {
    
    weak var kernel : BinarySpacePadKernelModel!
    
    let kingWenSeq : [Int] = [Int](1...64)
    
  //  let hitZones : KeyscaleViewHitZones! = KeyscaleViewHitZones(scale: 1.0)
    
    
    init(_ model: BinarySpacePadKernelModel) {
        
        super.init(width: 288, height: 288)
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func draw(_ dirtyRect: NSRect) {
        for (index, value) in kingWenSeq.enumerated() {
            drawHexgramPad(padNumber: index, padValue: value)
        }
    }
    
    func drawHexgramPad(padNumber: Int, padValue: Int) {
        
        let gridSize : Int = 8
        let padSize  : CGFloat = 35.0
        let padRow   : CGFloat = CGFloat( gridSize - (padNumber / gridSize) - 1 )
        let padCol   : CGFloat = CGFloat( padNumber % gridSize )
        let xPadding : CGFloat = 3
        let yPadding : CGFloat = 3
        let padFrame : NSRect  = NSRect(x: padCol * padSize + xPadding, y: padRow * padSize + yPadding, width: padSize, height: padSize)
        
        HexagramsStyleKit.drawHexagramPad(frame: padFrame, wenSelector: CGFloat(padValue))
    }
    
    
    func interpretMouseUp(with theEvent: NSEvent) {
        
        /*
        let flags = theEvent.modifierFlags
        
        guard !flags.contains(.command) else { super.mouseUp(with: theEvent) ; return }
        
        let eventLocation = theEvent.locationInWindow
        let xy            = self.convert(eventLocation, from: nil)
        
        // toggles state for clicked area
        
        updateView()
        */
        
        printLog("BinarySpacePad mouseUp() detected.")
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.needsDisplay = true
//        }
//    }
    
}
