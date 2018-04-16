//
//  CodeBoxMidiInput.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 4/20/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore
import MidiPlex 

@objc class CodeBoxMidiInput : NSObject {
    
    var delegate : CodeBoxJSAgent!
    
    var token : Disposable?
    
    var midiTriggerFunction  : JSValue?
    
    var midiProcessFunction : JSValue?
    
    
    init(delegate: CodeBoxJSAgent ) {
        
        super.init()
        
        self.delegate = delegate
    }
    
    func restartMidiInputProcessing() {
        
        token?.dispose()
        
        midiTriggerFunction = delegate.context.objectForKeyedSubscript("midiTrigger")
        
        midiProcessFunction = delegate.context.objectForKeyedSubscript("midiProcess")
        
        guard let midiIn = delegate.midiInStream else {
            
            // printLog("CodeBoxMidiInput: restartMidiInputProcessing() guard failed.")
            
            return
        }
        
        token = midiIn
            
            .filter      { msg in self.triggerDetect(msg)    }
            
            .observeNext { msg in self.performProcess(msg) }
    }
    
    
    func triggerDetect( _ msg: MidiMessage ) -> Bool {
        
        var result : Bool = true
        
        let jsMsg = JSValue(object: msg, in: delegate.context)
        
        if let theTrigger = self.midiTriggerFunction, let msg = jsMsg {
            
            result = theTrigger.call(withArguments: [msg]).toBool()
        }
        
        return result
    }
    
    func performProcess( _ msg: MidiMessage ) {
        
        let jsMsg = JSValue(object: msg, in: delegate.context)
        
        if let theProcess = self.midiProcessFunction, let msg = jsMsg {
            
            theProcess.call(withArguments: [msg])
        }
    }
    
}

