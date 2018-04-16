//
//  MidiSourceOutputRoutines.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/9/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import MidiPlex

protocol ComponentOutputAPI : class {
    
    associatedtype X  ; associatedtype Y
    
    var source : Property<X>! { get set }
    
    var output : OutputPointReactor? { get set }
    
    init(source: Property<X>, output: OutputPointReactor?)
    
    func makeConnecter()  -> Connecter
    
    func applyFilter(_ msg: X) -> Bool
    
    func applyMap(_ msg: X) -> Y
    
    func deployOutput(_ msg: Y)
    
    func performRoutine()
}


protocol OutputRoutineType : class, ComponentOutputAPI { }


// ----------------------------------------------------------------------------------
//  MARK: -  StandardOutput prototypes ( StandardOutputBase, StandardOutputRoutine )
// ----------------------------------------------------------------------------------


protocol StandardOutputRoutine : class, OutputRoutineType {  }


extension StandardOutputRoutine {
    
    func performRoutine() {
        
        // printLog("performRoutine() has been called.")
        
        if let disp = output?.bag { disp.dispose() }
        
        output?.setPin( makeConnecter() )
        
        let disp = source
            
            .filter  { msg in self.applyFilter(msg)  }
            
            .map     { msg in self.applyMap(msg)     }
            
            .observeNext { msg in self.deployOutput(msg) }
        
        output?.addToBag( disp )
    }
}



// --------------------------------------------------
//  MARK: -  MidiNoteSource assets
// --------------------------------------------------


protocol MidiNoteSource  : StandardOutputRoutine { }



final class MidiNoteSourceRoutine : MidiNoteSource {
    
    typealias X = MidiMessage
    
    typealias Y = StringCoder
    
    var source : Property<X>!
    
    var output : OutputPointReactor?
    
    
    required init(source: Property<X>, output: OutputPointReactor?) {
        
        self.source = source
        
        self.output = output
        
    }
    
    func makeConnecter() -> Connecter {
        
        return Connecter.stringCoder( Property("") )
    }
    
    
    func applyFilter(_ msg: MidiMessage) -> Bool  {
        
        return msg.type() == MidiType.noteOnVal.rawValue || msg.type() == MidiType.noteOffVal.rawValue
    }
    
    
    func applyMap(_ msg: MidiMessage) -> StringCoder {
        
        let data2 = msg.type() == MidiType.noteOffVal.rawValue ? UInt8( 0 ) : msg.data2() ;
        
        let result = EventsWriting.intPairToNNumVelPair(n: Int(msg.data1()), v: Int(data2))
        
        return result
    }
    
    
    func deployOutput(_ msg: StringCoder) {
        
        guard let out = output?.model else { return }
        
        out.assign( msg )
        
        if let pin = output?.pin.asStringCoder() {
            pin.value = msg
            if msg.count > 0 {
                // printLog("MidiSource.output1:IntToggle rcvd: notenum = \(msg[0].k), limit = \(msg[0].n)")
            }
        }
    }
}



/*
// --------------------------------------------------
//  MARK: -  MidiVelocityOutput assets
// --------------------------------------------------


protocol MidiVelocityOutput  : StandardOutputRoutine { }



final class MidiVelocityOutputRoutine : MidiVelocityOutput {
    
    typealias X = MidiMessage
    
    typealias Y = StringCoder
    
    var source : Property<X>!
    
    var output : OutputPointReactor?
    
    
    required init(source: Property<X>, output: OutputPointReactor?) {
        
        self.source = source
        
        self.output = output
        
    }
    
    
    func makeConnecter() -> Connecter {
        
        return Connecter.stringCoder( Property("") )
    }
    
    
    func applyFilter(_ msg: MidiMessage) -> Bool  {
        
        return msg.type() == MidiType.noteOnVal.rawValue
    }
    
    
    func applyMap(_ msg: MidiMessage) -> StringCoder {
        
        return StringCoder( msg.data2(), 128 )
    }
    
    
    func deployOutput(_ msg: StringCoder) {
        
        guard let out = output?.model else { return }
        
        out.assign( [msg] )
        
        if let pin = output?.pin.asStringCoder() {
            pin.value = [msg]
          //  if msg.count > 0 {
                // printLog("MidiSource.output2[0]:IntValue rcvd: velocity = \(msg.k), limit = \(msg.n)")
          //  }
        }
    }
}
 
*/


// --------------------------------------------------
//  MARK: -  MidiCCOutput assets
// --------------------------------------------------


protocol MidiCCOutput  : StandardOutputRoutine { }


final class MidiCCOutputRoutine : MidiCCOutput {
    
    typealias X = MidiMessage
    
    typealias Y = StringCoder
    
    var source : Property<X>!
    
    var output : OutputPointReactor?
    
    
    required init(source: Property<X>, output: OutputPointReactor?) {
        
        self.source = source
        
        self.output = output
        
    }
    
    func makeConnecter() -> Connecter {
        
        return Connecter.stringCoder( Property("") )
    }
    
    
    func applyFilter(_ msg: MidiMessage) -> Bool  {
        
        return msg.type() == MidiType.controlChangeVal.rawValue
    }
    
    
    func applyMap(_ msg: MidiMessage) -> StringCoder {
        
        let controlMsg = EventsWriting.midiMsgToCNumValPair(msg: msg) ?? ""
        
        return controlMsg
    }
    
    
    func deployOutput(_ msg: StringCoder) {
        
        guard let out = output?.model else { return }
        
        out.assign( msg )
        
      //  if let pin = output?.pin.asStringCoder() {
      //      pin.value = msg
            //// printLog("MidiSource output3[0]: CCIntPair rcvd: ccnum = \(msg.k1), ccval = \(msg.k2), limit (ccnum) = \(msg.n1), limit (ccval) = \(msg.n2)")
      //  }
    }
}



// --------------------------------------------------
//  MARK: -  MidiSourceOutput assets
// --------------------------------------------------


protocol MidiSourceOutput  : StandardOutputRoutine { }



final class MidiSourceOutputRoutine : MidiSourceOutput {
    
    typealias X = MidiMessage
    
    typealias Y = MidiMessage
    
    var source : Property<X>!
    
    var output : OutputPointReactor?
    
    
    required init(source: Property<X>, output: OutputPointReactor?) {
        
        self.source = source
        
        self.output = output
        
    }
    
    func makeConnecter() -> Connecter {
        
        return Connecter.midiMessage( Property( MidiMessage() ))
    }
    
    
    func applyFilter(_ msg: MidiMessage) -> Bool  {
        
        return true
    }
    
    
    func applyMap(_ msg: MidiMessage) -> MidiMessage {
        
        return msg
    }
    
    
    func deployOutput(_ msg: MidiMessage) {
        
        guard let out = output?.model else { return }
        
        out.assign( msg )
    }
}




