//
//  KernelParameter.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/6/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

protocol KernelParameterType {
    
    associatedtype V
    
    var pname : String! { get set }
    
    var property : Property<V>! { get set }
    
    init()
    
    init( _ pname: String, _ initialEvent: V )
}

extension KernelParameterType {
    
    var value : V {
        
        get { return property.value }
        
        set { property.value = newValue }
    }
    
    init( _ pname: String, _ initialEvent: V ) {
        
        self.init()
        
        self.property = Property( initialEvent )
        
        self.pname = pname
    }
    
    func syncView(_ view: NSView) {
        
        property
            
            .observeOn(.main)
            
            .observeNext { _ in
                
                view.updateSelf() 
                
               // view.setNeedsDisplay(view.bounds)
                
            }.dispose(in: view.bag)
    }
}


final class KernelParameter<V> : KernelParameterType {
    
    var pname    : String!
    
    var property : Property<V>!
    
}


extension Property {
    
    func syncView(_ view: NSView) {
        
        self.observeOn(.main)
            
        .observeNext { _ in
            
            view.updateSelf()
                
           // view.setNeedsDisplay(view.bounds)
                
        }.dispose(in: view.bag)
    }
}

