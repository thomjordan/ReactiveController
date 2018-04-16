//
//  OctaveKeyscaleStepToggles.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/12/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit


final class OctaveKeyscaleStepToggles : KernelParameterType {
    
    var pname    : String!
    var property : Property<[Bool]>!
    
    var activeSteps : [Int]? {
        var steps : [Int] = []
        let currscale = property.value
        for (index, step) in currscale.enumerated() {
            if step { steps.append(index) }
        }
        let result = steps.count == 0 ? nil : steps
        return result
    }
    
    convenience init(_ pname: String, scale: String = "------------") {
        
        self.init(pname, [false,false,false,false,false,false,false,false,false,false,false,false])
        
        updateValues(to: scale)
    }
    
    subscript(index: Int) -> Bool {
        
        get { return property.value[index % 12] }
        
        set(newValue) {
            
            var temp = property.value
            
            temp[index % 12] = newValue
            
            property.next(temp)
        }
    }
    
    func reset() { updateValues(to: "------------") }
    
    func reset(_ pc: Int) {
        reset()
        self[pc%12] = true
    }
    
    func updateValues(to chars: String) {
        
        var temp = property.value
        
        var index : Int = 0
        
        for char in chars {
            
            if index < 12 {
                
                temp[index] = (char == "0" || char == "-") ? false : true
                
            }
                
            else {
                
                property.next(temp)
                
                return
            }
            
            index += 1
        }
        
        property.next(temp) 
    }
    
    
    func updateValues(to nums: [Int]) {
        
        var temp = property.value
        
        for (index, value) in nums.enumerated() {
            
            if index < 12 {
                
                temp[index] = value == 0 ? false : true
                
            }
                
            else {
                
                property.next(temp)
                
                return
            }
        }
        
        property.next(temp)
    }
}

