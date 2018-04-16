//
//  EndpointModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiPlex

enum ConnectorKind {
    case input
    case output
}

protocol ConnecterInterface : DisposeBagProvider {
    var pin : Connecter! { get set }
    var bag : DisposeBag { get }
    func dispose()
}

// extension ConnecterInterface {func dispose() { bag.dispose() } }


class ConnectorInfo {  // make this a struct (e.g. a Swift replacement for a 'lens')
    
    var portkind : ConnectorKind!
    
    var portnum  : Int!
    
    var name : String = ""
    
    var info : String = ""
    
    
    init(_ kind: ConnectorKind, _ num: Int, _ info: String) {
        
        self.portkind = kind
        
        self.portnum  = num
        
        self.info     = info
    }
    
    
    static func genInput(_ num: Int, _ info: String = "") -> ConnectorInfo {
        
        let info = ConnectorInfo( .input, num, info )
        
        return info
    }
    
    static func genOutput(_ num: Int, _ info: String = "") -> ConnectorInfo {
        
        let info = ConnectorInfo( .output, num, info )
        
        return info
    }
}


protocol ConnecterModel : ConnecterInterface {
    
    var header   : ConnectorInfo! { get set }
    
    var pin      : Connecter!  { get set }
    
    var bag      : DisposeBag  { get }
    
    
    var refresh  : ( () -> () )? { get set }
    

    init(_ pin: Connecter, _ num: Int, _ info: String)
}


extension ConnecterModel {
    
    var portnum : Int { return header.portnum }
}


extension ConnecterInterface {
    
    func clearConnecter() {
        
        dispose()
        
        pin = nil
    }
    
    func toStringCoder() {
        
        clearConnecter()
        
        pin = Connecter.newStringCoder()
    }
    
    func toMidiMessage() {
        
        clearConnecter()
        
        pin = Connecter.newMidiMessage() 
    }
    
}


extension ConnecterInterface {
    
    func dispose() { bag.dispose() }
    
    // used for inputs -- when input argument is a Property<EventType>
    
    func assign(_ f: (Property<StringCoder>) -> Disposable) {
        
        if let aPin = pin.asStringCoder() {
            
            f( aPin ).dispose(in: bag)
        }
    }
    
    // used for outputs -- when input argument is simply an EventType
    
    func assign(_ str: StringCoder) {
        
        if let aPin = pin.asStringCoder() {
            
            aPin.value = str
            
           // bint.count > 0 ? // printLog("StringCoder rcvd: k = \(bint[0].k), n = \(bint[0].n)") : ()
        }
    }
    
    
    func assign(_ mm: MidiMessage) {
        
        if let aPin = pin.asMidiMessage() {
            
            aPin.value = mm
            
            // printLog("MidiMessage rcvd: data1 = \(mm.data1()), data2 = \(mm.data2())")
        }
    }
}

