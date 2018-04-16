//
//  SafeIndexArray.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol SafeIndexArray {
    
    associatedtype Element
    
    var contents : Array<Element> { get set }
    
    var count : Int { get }
    
    subscript(num: Int) -> Element? { get set }
    
}


extension SafeIndexArray {
    
    var count : Int { return contents.count }
    
    subscript(num: Int) -> Element? {
        
        get {
            
            guard num < contents.count && num >= 0 else { return nil }
            
            return contents[num]
        }
        
        set(newVal) {
            
            guard num <= contents.count && num >= 0 else { return }
            
            contents[num] = newVal! 
        }
    }
}



