//
//  ParameterProperty.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/30/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


class ParameterProperty {
    
    var paramName  : String!
    
    var paramValue : ParameterValue!
    
    var linkedPropertyUpdater : ((ParameterValue) -> Void)?
    
    
    init( _ paramName: String, _ paramValue: ParameterValue ) {
        
        self.paramName  = paramName
        
        self.paramValue = paramValue
    }
    
    func toCodeString() -> String {
        
        let pname = paramName != nil ? paramName! : "foo"
        
        let pval  = paramValue.toString()
        
        let codeStr  = "\(pname) = \(pval)"
        
        return codeStr
    }
    
    func updateParameterAndLinkedProperty(_ pval: ParameterValue) {
        
        self.paramValue = pval
        
        linkedPropertyUpdater?(pval)
        
        printLog("ParameterProperty : updateParameterAndLinkedProperty() : \(pval)")
    }
}


enum ParameterValue {
    
    case intValue( Int? )
    
    case floatValue( Float64? )
    
    case boolValue( Bool? )
    
    case intArrayValue( [Int]? )
    
    case stringValue( String )
    
    
    static func newIntValue(_ val: String = "") -> ParameterValue {
        
        let result = Int(val)
        
        return .intValue( result )
        
    }
    
    static func newIntValue(_ val: Int) -> ParameterValue {
        
        return .intValue( val )
        
    }
    
    static func newFloatValue(_ val: String = "") -> ParameterValue {
        
        let result = Float64(val)
        
        return .floatValue( result )
        
    }
    
    static func newFloatValue(_ val: Float64) -> ParameterValue {
        
        return .floatValue( val )
        
    }
    
    static func newBoolValue(_ val: String) -> ParameterValue {
        
        let result = Bool(val)
        
        return .boolValue( result )
        
    }
    
    static func newBoolValue(_ val: Bool) -> ParameterValue {
        
        return .boolValue( val )
        
    }
    
    static func newIntArrayValue(_ val: String = "") -> ParameterValue {
        
        let result = val.toIntArray()
        
        return .intArrayValue( result )
        
    }
    
    static func newIntArrayValue(_ val: [Int]) -> ParameterValue {
        
        return .intArrayValue( val )
        
    }
    
    static func newStringValue(_ val: String) -> ParameterValue {
        
        return .stringValue( val )
        
    }
    
    
    func asIntValue() -> Int? {
        
        if case let .intValue( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func asFloatValue() -> Float64? {
        
        if case let .floatValue( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func asBoolValue() -> Bool? {
        
        if case let .boolValue( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func asIntArrayValue() -> [Int]? {
        
        if case let .intArrayValue( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func asStringValue() -> String? {
        
        if case let .stringValue( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func toString() -> String {
        
        var result : String = ""
        
        switch self {
            
        case let .intValue( val ):
            
            result = val != nil ? val!.asString : ""
            
        case let .floatValue( val ):
            
            result = val != nil ? val!.asString : ""
            
        case let .boolValue( val ):
            
            result = val != nil ? val!.description : ""
            
        case let .intArrayValue( val ):
            
            result = val != nil ? String(describing: val!) : ""
            
        case let .stringValue( val ):
            
            result = val
        }
        
        return result
    }
    
}



extension Array where Element == ParameterProperty {
    
    mutating func addAttribute(_ attr: ParameterProperty) {
        
        self.append(attr)
    }
    
    func getParameterNamed(_ pName: String) -> ParameterProperty? {
        
        for attr in self {
            
            if attr.paramName == pName {
                
                return attr
            }
        }
        
        return nil
    }
    
    func updateParameter(_ pName: String, to val: Int) {
        
        guard let attr = getParameterNamed(pName) else { return }
        
        if let currval = attr.paramValue.asIntValue(), currval != val {
            
            attr.updateParameterAndLinkedProperty( .intValue( val ) )
        }
    }
    
    func updateParameter(_ pName: String, to val: Float64) {
        
        guard let attr = getParameterNamed(pName) else { return }
        
        if let currval = attr.paramValue.asFloatValue(), currval != val {
            
            attr.updateParameterAndLinkedProperty( .floatValue( val ) )
        }
    }
    
    func updateParameter(_ pName: String, to val: Bool) {
        
        guard let attr = getParameterNamed(pName) else { return }
        
        if let currval = attr.paramValue.asBoolValue(), currval != val {
            
            attr.updateParameterAndLinkedProperty( .boolValue( val ) )
        }
    }
    
    func updateParameter(_ pName: String, to val: Array<Int>) {
        
        guard let attr = getParameterNamed(pName) else { return }
        
        if let currval = attr.paramValue.asIntArrayValue(), currval != val {
            
            attr.updateParameterAndLinkedProperty( .intArrayValue( val ) )
        }
    }
    
    func updateParameter(_ pName: String, to val: String) {
        
        guard let attr = getParameterNamed(pName) else { return }
        
        if let currval = attr.paramValue.asStringValue(), currval != val {
            
            attr.updateParameterAndLinkedProperty( .stringValue( val ) )
        }
    }
}



extension String {
    
    func toIntArray() -> [Int]? {
        
        let result = self.filter { $0 != "[" && $0 != "]" }.replacingOccurrences(of: " ", with: "").components(separatedBy: ",").flatMap { Int( $0 ) }
        
        guard result.count > 0 else { return nil }
        
        return result
    }
}


