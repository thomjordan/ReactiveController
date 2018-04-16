//
//  CodeBoxJSAgent.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 4/16/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import MidiPlex 
import JavaScriptCore



class CodeBoxJSAgent : GeneralJSAgent {
    
    var midiInStream  : Property<MidiMessage>? {
        
        didSet { runScript() }
    }
    
    var midiOutStream : Property<MidiMessage>? {
        
        didSet { runScript() }
    }
    
    var theMidiInput  : CodeBoxMidiInput!
    
    var theMidiOutput : CodeBoxMidiOutput!
    
    var theMidiMessageMaker : CodeBoxMidiMessageMaker!
    
    
    override init(_ cModel: CodeScriptModel) {
        
        super.init(cModel)
        
        theMidiInput        = CodeBoxMidiInput(delegate: self)
        
        theMidiOutput       = CodeBoxMidiOutput(delegate: self)
        
        theMidiMessageMaker = CodeBoxMidiMessageMaker(delegate: self)
        
        registerMidiClassesIntoJS()
        
        runScript()
    }
    

    func registerMidiClassesIntoJS() {
        
        // context.setObject( theMidiInput, forKeyedSubscript: "MidiInput" )
        
        context.setObject( theMidiOutput, forKeyedSubscript: "MidiOutput" as (NSCopying & NSObjectProtocol)! )
        
        context.setObject( theMidiMessageMaker, forKeyedSubscript: "MidiMessage" as (NSCopying & NSObjectProtocol)! )
    }
    
    override func runScript() {
        registerMidiClassesIntoJS()
        super.runScript()
        theMidiInput.restartMidiInputProcessing()
    }
    
}

