//
//  ComponentContentView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit



public class ComponentContentView : NSBox {
    
    weak var containerView : ComponentView!
    
    
    init(width: CGFloat, height: CGFloat) {
        
        super.init(frame: NSMakeRect(0,0,width,height))
        
        setup()
    }
    
    
    func setup() {
        
        self.boxType      = .custom
        
        self.borderType   = .lineBorder
        
        self.borderWidth  = 0
        
        self.cornerRadius = 5
        
        self.borderColor  = NSColor.black
        
        self.contentViewMargins = NSMakeSize(0, 0)
    }
    
    
    required public init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setup()
    }

}
