//
//  TaskOrders.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/6/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

//
//  TaskOrders.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 2/5/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


protocol AssociatedTypes5 {
    
    associatedtype P ; associatedtype Q ; associatedtype R
    associatedtype S ; associatedtype T
    
}

protocol SignalTaskAPIType {
    
    associatedtype Q ; associatedtype R
    associatedtype S ; associatedtype T
    
    var filter   : ((Q) -> Bool)?           { get }
    
    var mapper   : ((R) -> S)?              { get }
    
    var observer : ((T) -> ())?             { get }
}



protocol SignalTaskType : class {
    
    var attrParams : [ParameterProperty]  { get set }
    
    var outPin     : Connecter!           { get }
    
    func attachTaskTo(_ inJack: OutputPointReactor)
}


class SignalTask<A: AssociatedTypes5> : SignalTaskAPIType, SignalTaskType {
    
    typealias P = A.P; typealias Q = A.Q ; typealias R = A.R
    typealias S = A.S ; typealias T = A.T
    
    
    var attrParams : [ParameterProperty] = []
    
    var filter   : ((Q) -> Bool)? = nil
    
    var mapper   : ((R) -> S)?    = nil
    
    var observer : ((T) -> ())?   = nil
    
    var outPin : Connecter!
    
    init(args: [ParameterProperty]) {
        
        attrParams = args
    }
    
    func attachTaskTo(_ inJack: OutputPointReactor) {}
}



class CCFilterTaskAssocTypes : AssociatedTypes5 {
    
    typealias P = Int
    
    typealias Q = StringCoder
    
    typealias R = StringCoder
    
    typealias S = StringCoder
    
    typealias T = StringCoder
}



class CCFilter : SignalTask<CCFilterTaskAssocTypes> {
    
    override init(args: [ParameterProperty]) {
        
        super.init(args: args)
        
        attrParams = args
        
        filter     = { (arr:StringCoder) -> Bool in
            
            if let param = self.attrParams[0].paramValue.asIntValue() {
                
                if let controlVals = arr.intPairCtrlVal() {
                    
                    return controlVals.cc == param
                }
            }
            return false
        }
        
        mapper   = { (arr:StringCoder) -> StringCoder in
            
            printLog("MidiSource : FilterCC task : post-filter output :  \(arr)")
            
            if let controlVals = arr.intPairCtrlVal() {
                
                let result = EventsWriting.intPairAsBoundedInt(k: controlVals.cv, x: 128)
                
                printLog("post-mapper result:  \(result)")
                
                return result
            }
            
            return ""
        }
        
        outPin   = Connecter.newStringCoder()
        
        observer = { (msg:StringCoder) -> () in
            
            if let pin = self.outPin.asStringCoder() {
                
                pin.value = msg
            }
        }
    }
    
    
    override func attachTaskTo(_ inJack: OutputPointReactor) {
        
        guard let pin = inJack.pin.asStringCoder() else {
            
            // printLog("TaskOrders: could NOT attach CCFilter task to output \(inJack.portnum)")
            
            return }
        
        // printLog("TaskOrders: successfully attached CCFilter task to output \(inJack.portnum)")
        
        pin
            .filter      { msg in self.filter!(msg) }
            
            .map         { msg in self.mapper!(msg) }
            
            .observeNext { msg in self.observer!(msg) }.dispose(in: inJack.bag)
        }
    
}


