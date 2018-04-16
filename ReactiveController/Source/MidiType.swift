//
//  MidiType.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/9/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import MidiPlex


public typealias Byte = UInt8


public enum MidiType : Byte {
    
    case noteOffVal         = 0x80  //	+2 data bytes
    
    case noteOnVal          = 0x90  //	+2 data bytes
    
    case afterTouchVal      = 0xA0  //	+2 data bytes
    
    case controlChangeVal   = 0xB0  //	+2 data bytes
    
    case programChangeVal   = 0xC0  //	+1 data byte
    
    case channelPressureVal = 0xD0  //	+1 data byte
    
    case pitchWheelVal      = 0xE0  //	+2 data bytes
    
}


public enum Midi {
    
    public static func makeNoteOn(_ notenum: Int, _ velocity: Int, _ channel: Int) -> MidiMessage {
        
        let noteMsg = MidiMessage(fromVals: MidiType.noteOnVal.rawValue, UInt8(channel), UInt8(notenum), UInt8(velocity))
        
        return noteMsg
    }
    
    public static func makeNoteOff(_ notenum: Int, _ channel: Int) -> MidiMessage {
        
        let noteMsg = MidiMessage(fromVals: MidiType.noteOffVal.rawValue, UInt8(channel), UInt8(notenum), UInt8(0)) 
        
        return noteMsg
    }
}

