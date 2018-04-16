//
//  ConnectorPointView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa



class ConnectorPointView : NSView {
    
    weak var vc : ConnectorPointViewController!
    
    init(vc: ConnectorPointViewController) {
        
        super.init(frame: NSMakeRect(0,0,2,2))
        
        self.vc = vc
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        let jack = NSBezierPath(ovalIn: self.bounds)
        
        NSGraphicsContext.saveGraphicsState()
        
        vc.connectorColor().set()
        
        jack.fill()
        
        NSGraphicsContext.restoreGraphicsState()
    }

}
