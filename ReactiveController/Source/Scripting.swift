//
//  CoffeeScriptAPI.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/26/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import JavaScriptCore


enum Scripting {
    
   // static let coffeeScriptCompilerURL = Bundle.main.url(forResource: "coffeeScript", withExtension: "js")
   // static let coffeeScriptExamplesURL = Bundle.main.url(forResource: "examples", withExtension: "coffee")
    
    static func loadJavaScript(at url: URL?, into jsContext: JSContext) {
        guard let theURL = url else {
            printLog(" ### GUARD FAILED ### : In Scripting.loadJavaScript(), input argument url: was nil")
            return }
        let js = try? String(contentsOf: theURL)
        guard let javascript = js else {
            printLog(" ### GUARD FAILED ### : In Scripting.loadJavaScript(), try? String(contentsOf: theURL) yielded no JS code")
            return }
        jsContext.evaluateScript( javascript )
        printLog(" ~*~*~*~ Scripting.loadJavaScript() completed successfully, evaluating JS in jsContext ~*~*~*~ ")
    }
    
    static func getCoffeeScriptCompiler() -> JSValue? {
        guard let coffeescriptCompilationContext = JSContext() else { return nil }
        guard let csCompilerURL = Bundle.main.url(forResource: "coffeeScript", withExtension: "js") else {
            printLog(" ### GUARD FAILED ### : In Scripting.getCoffeeScriptCompiler() Bundle.main.url(forResource: \"coffeeScript\", withExtension: \"js\") returned no URL to a coffeeScript compiler")
            return nil
        }
        loadJavaScript(at: csCompilerURL, into: coffeescriptCompilationContext)
        let coffee = coffeescriptCompilationContext.objectForKeyedSubscript("CoffeeScript")
        guard let compiler = coffee?.objectForKeyedSubscript("compile") else {
            printLog(" ### GUARD FAILED ### : In Scripting.getCoffeeScriptCompiler(), coffeeScript compiler could not be retrieved")
            return nil
        }
        printLog(" ~*~*~*~ Scripting.getCoffeeScriptCompiler() completed successfully, returning CS compiler as JSValue ~*~*~*~ ")
        return compiler
    }
    
    static func getCode(at url: URL?) -> String? {
        guard let theURL = url else {
            printLog(" ### GUARD FAILED ### : In Scripting.getCode(), input argument url: was nil")
            return nil }
        let cs = try? String(contentsOf: theURL)
        guard let code = cs else {
            printLog(" ### GUARD FAILED ### : In Scripting.getCode(), String(contentsOf: theURL) returned nil")
            return nil }
        printLog(" ~*~*~*~ Scripting.getCode() completed successfully, returning code at url ~*~*~*~ ")
        return code
    }
    
    static func coffeeScriptToJavaScript(_ code: String) -> String? {
        guard let csCompiler = getCoffeeScriptCompiler() else {
            printLog(" ### GUARD FAILED ### : In Scripting.coffeeScriptToJavaScript(), getCoffeeScriptCompiler() returned no compiler")
            return nil }
        guard let generatedJavaScript = csCompiler.call(withArguments: [code]).toString() else {
            printLog(" ### GUARD FAILED ### : In Scripting.coffeeScriptToJavaScript(), csCompiler.call(...) returned no generated JS")
            return nil }
        printLog("\nScripting.coffeeScriptToJavaScript() has generated this JS code: ")
        printLog("\n\(generatedJavaScript)\n\n")
        guard let truncatedJS = removeSurroundingFunction( generatedJavaScript ) else {
            printLog(" ### GUARD FAILED ### : In Scripting.coffeeScriptToJavaScript(), removeSurroundingFunction() returned no truncated JS")
            return nil }
        printLog(" ~*~*~*~ Scripting.coffeeScriptToJavaScript() completed successfully. ~*~*~*~ ")
        return truncatedJS 
    }
    
    static func jsCodeFromCoffeeScriptFile(at url: URL?) -> String? {
        guard let coffeeScriptCode = getCode(at: url) else {
            printLog(" ### GUARD FAILED ### : In Scripting.jsCodeFromCoffeeScriptFile(), getCode() returned no coffeeScript code")
            return nil }
        guard let generatedJavaScript = coffeeScriptToJavaScript(coffeeScriptCode) else {
            printLog(" ### GUARD FAILED ### : In Scripting.jsCodeFromCoffeeScriptFile(), coffeeScriptToJavaScript() returned no generated JS code")
            return nil
        }
        printLog(" ~*~*~*~ Scripting.jsCodeFromCoffeeScriptFile() completed successfully. ~*~*~*~ ")
        return generatedJavaScript
    }
    
    
    static func addExceptionLogging(to context: JSContext, _ outproc: ((JSValue?) -> Void)? = nil ) {
        context.exceptionHandler = { ( context: JSContext?, exception: JSValue? ) in
            outproc?(exception)
            printLog("JS Error: \(exception?.description ?? "unknown error")")
        }
    }
    
    static func addConsoleLog(to context: JSContext) {
        guard let newObj = JSValue(newObjectIn: context) else { return }
        context.setObject(newObj, forKeyedSubscript: "console" as NSCopying & NSObjectProtocol)
        guard let console = context.objectForKeyedSubscript("console") else { return }
        let callback : (JSValue) -> () = { (msg:JSValue) in
            printLog("console.log from \(JSContext.current()) : \(msg) ")
        }
        console.setObject(callback, forKeyedSubscript: "log" as NSCopying & NSObjectProtocol)
    }
    
    static func removeSurroundingFunction(_ code: String?) -> String? {
        guard var jsCode = code else { return nil }
        guard jsCode.count > 33 else { return nil }
        let suffix = jsCode.index(jsCode.endIndex, offsetBy: -16)..<jsCode.endIndex
        jsCode.removeSubrange(suffix)
        let prefix = jsCode.startIndex..<jsCode.index(jsCode.startIndex, offsetBy: 16)
        jsCode.removeSubrange(prefix)
        return jsCode
    }
    
}


// let localJSContext = JSContext()!
// Scripting.addExceptionLogging(to: localJSContext)
// Scripting.addConsoleLog(to: localJSContext)
// let generatedJS = Scripting.jsCodeFromCoffeeScriptFile(at: coffeeScriptExamplesURL, into: localJSContext)
// generatedJS!

