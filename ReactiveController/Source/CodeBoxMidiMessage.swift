//
//  CodeBoxMidiMessage.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 4/20/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore
import MidiPlex

// NoteOn/NoteOff; AfterTouch; ControlChange; ProgramChange; ChannelPressure; PitchWheel ( (data2<<7)|data1 )

// type, channel, data1, data2


@objc protocol MidiMessageExtension : JSExport {
    
    func isNoteOn()          -> Bool
    
    func isNoteOff()         -> Bool
    
    func isControlChange()   -> Bool
    
    func isProgramChange()   -> Bool
    
    func isAftertouch()      -> Bool
    
    func isChannelPressure() -> Bool
    
    func isPitchWheel()      -> Bool
    
    
    var noteNumber  : UInt8 { get }
    
    var velocity    : UInt8 { get }
    
    var ccnumber    : UInt8 { get }
    
    var ccvalue     : UInt8 { get }
    
    var aftertouch  : UInt8 { get }
    
    var progChange  : UInt8 { get }
    
    var chanPress   : UInt8 { get }
    
    var pitchWheel  : UInt8 { get }
    
    var midiChannel : UInt8 { get }
}


extension MidiMessage : MidiMessageExtension {
    
    func isNoteOn() -> Bool {
        
        return type() == MidiType.noteOnVal.rawValue && data2() > 0
    }
    
    func isNoteOff() -> Bool {
        
        return ( type() == MidiType.noteOnVal.rawValue && data2() == 0 ) || type() == MidiType.noteOffVal.rawValue
    }
    
    func isControlChange() -> Bool {
        
        return type() == MidiType.controlChangeVal.rawValue
    }
    
    func isProgramChange() -> Bool {
        
        return type() == MidiType.programChangeVal.rawValue
    }
    
    func isAftertouch() -> Bool {
        
        return type() == MidiType.afterTouchVal.rawValue
    }
    
    func isChannelPressure() -> Bool {
        
        return type() == MidiType.channelPressureVal.rawValue
    }
    
    func isPitchWheel() -> Bool {
        
        return type() == MidiType.pitchWheelVal.rawValue
    }
    
    var noteNumber  : UInt8 { return data1() }
    
    var velocity    : UInt8 { return data2() }
    
    var ccnumber    : UInt8 { return data1() }
    
    var ccvalue     : UInt8 { return data2() }
    
    var aftertouch  : UInt8 { return data1() }
    
    var progChange  : UInt8 { return data1() }
    
    var chanPress   : UInt8 { return data1() }
    
    var pitchWheel  : UInt8 { return (data2()<<7)|data1() }
    
    var midiChannel : UInt8 { return channel() }
    
}

// 0x80	note off
// 0x90	note on
// 0xA0	afterTouch (key pressure)
// 0xB0	control change
// 0xC0	program (patch) change
// 0xD0	channel pressure
// 0xE0	pitch wheel


@objc protocol CodeBoxMidiMessageMakerProtocol : JSExport {
    
  //  func makeNote() -> MidiMessage
    
  //  func makeNote(notenum: Int) -> MidiMessage
    
  //  func makeNote(notenum: Int, _ velocity: Int) -> MidiMessage
    
    func makeNoteOn(_ notenum: Int, _ velocity: Int, _ channel: Int) -> MidiMessage
    
    func makeNoteOff(_ notenum: Int, _ channel: Int) -> MidiMessage
}

@objc class CodeBoxMidiMessageMaker : NSObject, CodeBoxMidiMessageMakerProtocol {
    
    var delegate : CodeBoxJSAgent!
    
    init(delegate: CodeBoxJSAgent ) {
        
        super.init()
        
        self.delegate = delegate
    }
    
    /*
    func makeNote() -> MidiMessage {
        
        return makeNote(60, 127, 0)
    }
    
    func makeNote(notenum: Int, _ velocity: Int) -> MidiMessage {
        
        return makeNote(notenum, velocity, 0)
    }
    
    func makeNote(notenum: Int) -> MidiMessage {
        
        return makeNote(notenum, 127, 0)
    }
    */
    
    func makeNoteOn(_ notenum: Int, _ velocity: Int = 108, _ channel: Int = 1) -> MidiMessage {
        
        var chan = channel
        chan = (chan >= 1 && chan <= 16) ? chan-1 : 0
        
        let noteMsg = MidiMessage(fromVals: MidiType.noteOnVal.rawValue, UInt8(chan), UInt8(notenum), UInt8(velocity))

        return noteMsg 
    }
    
    func makeNoteOff(_ notenum: Int, _ channel: Int = 1) -> MidiMessage {
        
        var chan = channel
        chan = (chan >= 1 && chan <= 16) ? chan-1 : 0
        
        let noteMsg = MidiMessage(fromVals: MidiType.noteOffVal.rawValue, UInt8(chan), UInt8(notenum), UInt8(0))
        
        return noteMsg
    }

}

