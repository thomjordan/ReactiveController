//
//  SafeIndexObservableArray.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol SafeIndexObservableArray {
    
    associatedtype Element
    
    var contents : MutableObservableArray<Element> { get set }
    
    var count : Int { get }
    
    subscript(num: Int) -> Element? { get }
    
    func clear()
    
}


extension SafeIndexObservableArray {
    
    var count : Int { return contents.count }
    
    subscript(num: Int) -> Element? { 
        
        guard num < contents.count && num >= 0 else { return nil }
        
        return contents[num]
    }
    
    func clear() { contents.removeAll() }
}



extension SafeIndexObservableArray where Element : ConnecterModel {
    
    func addNew_(_ info: String = "") {
        
        let newElementNum = count
        
        let newElement = Element.self.init( .null, newElementNum, info )
        
        switch info.uppercased() {
            
            case "STRINGCODE" : newElement.toStringCoder()
            
            case "MIDIMESSAGE": newElement.toMidiMessage()
            
            default: break
        }
        
        contents.append( newElement )
    }
    
    func addNew(_ n: Int = 1) {
        
        for _ in 0..<n { addNew_() }
    }
    
    func addNew(_ strings: [String]) {
        
        for str in strings { addNew_(str) }
    }
    
    func observeCollection(with observer: @escaping (ObservableArrayEvent<Element>) -> Void) -> Disposable {
        
        let disp = contents
            
            .observeNext(with: observer)
        
        return disp
    }
}

