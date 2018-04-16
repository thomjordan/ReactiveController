//
//  TimerJS.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/19/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import JavaScriptCore

let timerJSSharedInstance = TimerJS()

@objc protocol TimerJSExport : JSExport {
    
    func setTimeout(_ callback : JSValue,_ ms : Double) -> String
    
    func clearTimeout(_ identifier: String)
    
    func setInterval(_ callback : JSValue,_ ms : Double) -> String
    
}

// Custom class must inherit from `NSObject`
@objc class TimerJS: NSObject, TimerJSExport {
    var timers = [String: Timer]()
    
    static func registerInto(jsContext: JSContext, forKeyedSubscript: String = "timerJS") {
        jsContext.setObject(timerJSSharedInstance,
                            forKeyedSubscript: forKeyedSubscript as (NSCopying & NSObjectProtocol))
        jsContext.evaluateScript(
            "function setTimeout(callback, ms) {" +
                "    return timerJS.setTimeout(callback, ms)" +
                "}" +
                "function clearTimeout(indentifier) {" +
                "    timerJS.clearTimeout(indentifier)" +
                "}" +
                "function setInterval(callback, ms) {" +
                "    return timerJS.setInterval(callback, ms)" +
            "}"
        )
    }
    
    func clearTimeout(_ identifier: String) {
        let timer = timers.removeValue(forKey: identifier)
        timer?.invalidate()
    }
    
    func setInterval(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms, repeats: true)
    }
    
    func setTimeout(_ callback: JSValue, _ ms: Double) -> String {
        return createTimer(callback: callback, ms: ms , repeats: false)
    }
    
    @objc func callJsCallback(_ timer: Timer) {
        guard let callback = timer.userInfo as? JSValue else { return }
        callback.call(withArguments: [])
    }
    
    func createTimer(callback: JSValue, ms: Double, repeats : Bool) -> String {
        let timeInterval  = ms/1000.0
        let uuid = NSUUID().uuidString
        
        // make sure that we are queueing it all in the same executable queue...
        // JS calls are getting lost if the queue is not specified... that's what we believe... ;)
        
         DispatchQueue.main.async(execute: {
        //DispatchQueue.main.async(execute: {
            let timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                             target: self,
                                             selector: #selector(self.callJsCallback(_:)),
                                             userInfo: callback,
                                             repeats: repeats)
            self.timers[uuid] = timer
        })
        return uuid
    }
}


