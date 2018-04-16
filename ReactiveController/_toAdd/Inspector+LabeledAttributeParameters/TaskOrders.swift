//
//  TaskOrders.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 2/5/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit


enum AttributeParameter {
    
    case IntBind( Property<String?> )
    
    case BoolBind( Property<Bool?> )
    
    case StringBind( Property<String?> )
    
    
    static func newIntBind(_ val: String? = nil) -> AttributeParameter {
        
        return .IntBind(Property( val ))
        
    }
    
    static func newBoolBind(_ val: Bool? = false) -> AttributeParameter {
        
        return .BoolBind(Property( val ))
        
    }
    
    static func newStringBind(_ val: String? = "") -> AttributeParameter {
        
        return .StringBind(Property( val ))
        
    }
    
    
    func intBind() -> Property<String?>? {
        
        if case let .IntBind( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func boolBind() -> Property<Bool?>? {
        
        if case let .BoolBind( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func stringBind() -> Property<String?>? {
        
        if case let .StringBind( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
}


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
    
    var attrParams : [LabeledAttributeParameter]  { get set }
    
    var outPin     : ConnectorPin!                { get }
    
    func attachTaskTo(_ inJack: Connector)
    
    func addAttribute(_ attr: LabeledAttributeParameter)

}

extension SignalTaskType {
    
    func addAttribute(_ attr: LabeledAttributeParameter) {
        
        attrParams.append(attr)
    }
    
}


class SignalTask<A: AssociatedTypes5> : SignalTaskAPIType, SignalTaskType {
    
    typealias P = A.P; typealias Q = A.Q ; typealias R = A.R
    typealias S = A.S ; typealias T = A.T

    
    var attrParams : [LabeledAttributeParameter] = []
    
    var filter   : ((Q) -> Bool)? = nil
    
    var mapper   : ((R) -> S)?    = nil
    
    var observer : ((T) -> ())?   = nil
    
    var outPin : ConnectorPin!
    
    init(args: [LabeledAttributeParameter]) {
    
        attrParams = args
    }
    
    func attachTaskTo(_ inJack: Connector) {}
}



class CCFilterTaskAssocTypes : AssociatedTypes5 {
    
    typealias P = Int
    
    typealias Q = [IntWithMax]
    
    typealias R = [IntWithMax]
    
    typealias S = [IntWithMax]
    
    typealias T = [IntWithMax]
}



class CCFilter : SignalTask<CCFilterTaskAssocTypes> {
    
    override init(args: [LabeledAttributeParameter]) {
        
        super.init(args: args)
        
        attrParams = args
        
        filter     = { (arr:[IntWithMax]) -> Bool in
            
            if let param = self.attrParams[0].param.intBind() {
                
                if let pval = param.value {
                    
                    if arr.count >= 2 {
                        
                        return arr[0].k == Int(pval) // this String->Int cast could be reified and placed within a viewModel
                    }
                }
            }
            
            return false
        }
        
        mapper   = { (arr:[IntWithMax]) -> [IntWithMax] in [(arr[1].k)/128] }
        
        outPin   = ConnectorPin.newIntWithMaxList()
        
        observer = { (msg:[IntWithMax]) -> () in
        
            if let pin = self.outPin.intWithMaxList() {
                
                pin.value = msg
            }
        }
    }
    
    
    override func attachTaskTo(_ inJack: Connector) {
        
        guard let pin = inJack.pin.intWithMaxList() else { return }
        
        inJack.disposable = pin
            
            .filter  { msg in self.filter!(msg) }
        
            .map     { msg in self.mapper!(msg) }
        
            .observeNext { msg in self.observer!(msg) }
    }
}





