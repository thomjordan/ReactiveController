//
//  CodeBoxMidiOutput.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 4/20/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore
import MidiPlex 

@objc protocol CodeBoxMidiOutputProtocol : JSExport {
    
    func sendMsg(_ msg:MidiMessage)
    
    func sendNote(_ notenum: Int, _ velocity: Int, _ duration: Int, _ channel: Int)
}



@objc class CodeBoxMidiOutput : NSObject, CodeBoxMidiOutputProtocol {
    
    var delegate : CodeBoxJSAgent!
    
    init(delegate: CodeBoxJSAgent ) {
        super.init()
        self.delegate = delegate
    }
    
    func sendMsg(_ msg:MidiMessage) { delegate.midiOutStream?.value = msg }
   
    
    func sendNote(_ notenum: Int, _ velocity: Int, _ duration: Int, _ channel: Int) {
        
        var chan = channel
        chan = (chan >= 1 && chan <= 16) ? chan-1 : 0
        
        let noteOn  = MidiMessage(fromVals: MidiType.noteOnVal.rawValue, UInt8(chan), UInt8(notenum), UInt8(velocity))
        
        let noteOff = MidiMessage(fromVals: MidiType.noteOffVal.rawValue, UInt8(chan), UInt8(notenum), UInt8(0))
        
        sendMsg(noteOn)
        self.perform(#selector(CodeBoxMidiOutput.sendMsg(_:)), with: noteOff, afterDelay: TimeInterval(duration)/1000.0)
    }
}

