//
//  FlippedScrollView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa



class FlippedScrollView : NSScrollView {
    
    override var isFlipped:Bool {
        
        get { return false }
    }
    
    override init(frame frameRect: NSRect) {
        
        super.init(frame: frameRect)
        
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
    }
}



