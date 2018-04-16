//
//  ConnecterModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/5/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiPlex

// MARK: - Connecter

enum Connecter {
    
    case null
    
    case stringCoder( Property<StringCoder> )
    
    case midiMessage( Property<MidiMessage> )
    
    
    static func newStringCoder(_ inlist: StringCoder = "") -> Connecter {
        
        return .stringCoder(Property( inlist ))
    }
    
    static func newMidiMessage() -> Connecter {
        
        return .midiMessage(Property( MidiMessage() ))
    }
    
    
    // ---------
    
    
    func asStringCoder() -> Property<StringCoder>? {
        
        if case let .stringCoder( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    func asMidiMessage() -> Property<MidiMessage>? {
        
        if case let .midiMessage( propertyValue ) = self { return propertyValue }
            
        else { return nil }
    }
    
    
    func getDuplicate() -> Connecter {
        
        switch self {
            
        case .stringCoder : return .stringCoder(Property(""))
            
        case .midiMessage : return .midiMessage(Property( MidiMessage() ))
            
            
        default : return .null
            
        }
    }
    
    
    static func detectType(_ pin: Connecter) -> String {
        
        switch pin {
            
        case .stringCoder: return "STRINGCODE"
            
        case .midiMessage: return "MIDIMESSAGE"
            
        case .null:        return "NULL"
            
        }
    }
    
    
    static func makeBindFrom(_ source: OutputPointReactor, toTarget: InputPointReactor) -> Disposable? {
        
       // let target : InputPointReactor = to
        
        if let sourcePin = source.model.pin.asStringCoder() {
            
            toTarget.model.pin = Connecter.newStringCoder()
            
            if let targetPin = toTarget.model.pin.asStringCoder() {
                
                // printLog("Source to target binding established of type StringCoder.")
                
                return sourcePin
                    .executeOn(.global(qos: .userInteractive))
                    .observeOn(.main)
                    .observeNext { val in targetPin.value = val }
            }
        }
        
        else if let sourcePin = source.model.pin.asMidiMessage() {
            
            toTarget.model.pin = Connecter.newMidiMessage()
            
            if let targetPin = toTarget.model.pin.asMidiMessage() {
                
                // printLog("Source to target binding established of type MidiMessage.")
                
                return sourcePin
                    .executeOn(.global(qos: .userInteractive))
                    .observeOn(.main)
                    .observeNext { val in targetPin.value = val }
            }
        }
        
        // printLog("Source to target binding COULD NOT BE established because of type NULL.")
        
        return nil
    }
    
    
    
    static func makeBindFromTask(_ connection: ConnectionReactor, toTarget: InputPointReactor) -> Disposable? {
        
        guard let taskOutPin = connection.liveTask?.outPin else { return nil }
        
      //  let target = to
        
        if let sourcePin = taskOutPin.asStringCoder() {
            
            toTarget.model.pin = Connecter.newStringCoder()
            
            if let targetPin = toTarget.pin.asStringCoder() {
                
                // printLog("Source to target binding established of type StringCoder.")
                
                return sourcePin
                    .executeOn(.global(qos: .userInteractive))
                    .observeOn(.main)
                    .observeNext { val in targetPin.value = val }
            }
            
        }
        
        if let sourcePin = taskOutPin.asMidiMessage() {
            
            toTarget.model.pin = Connecter.newMidiMessage()
            
            if let targetPin = toTarget.pin.asMidiMessage() {
                
                // printLog("Source to target binding established of type MidiMessage.")
                
                return sourcePin
                    .executeOn(.global(qos: .userInteractive))
                    .observeOn(.main)
                    .observeNext { val in targetPin.value = val }
                
            }
            
        }
        
        // printLog("Source to target binding COULD NOT BE established because of type NULL.")
        
        return nil
    }
  
}





