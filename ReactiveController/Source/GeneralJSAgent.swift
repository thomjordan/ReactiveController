//
//  GeneralJSAgent.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/30/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import JavaScriptCore


class GeneralJSAgent : RunnableJSAgent {
    
    var bag: DisposeBag = DisposeBag()
    
    weak var codeModel : CodeScriptModel!
    
    var errorInfo : JSValue? = nil
    
    let context = JSContext()!
    
    init(_ cModel: CodeScriptModel) {
        
        codeModel = cModel
        
        registerAddedFunctionsIntoJS()
    }
     
    
    func loadScript() {
        
        errorInfo = nil
        
        let code = codeModel.code.value
        
        guard let generatedJS = Scripting.coffeeScriptToJavaScript( code ) else {
            printLog(" ### GUARD FAILED ### : In GeneralJSAgent::loadScript(), coffeeScriptToJavaScript() returned no value")
            return
        }
        
        context.evaluateScript( generatedJS )
        
        printLog(" ~*~*~*~ GeneralJSAgent::loadScript() completed successfully. ~*~*~*~ ") // ; printLog( "\(generatedJS)" )
    }
    
    func runScript() {  // an overridable hook for adding functionality in subclasses
        
        loadScript()
    }
    
    
    func registerAddedFunctionsIntoJS() {
        
        Scripting.addExceptionLogging(to: context) { [weak self] jsval in
            self?.errorInfo = jsval
        }
        
        TimerJS.registerInto(jsContext: context)
    }
    
    
    
    func getErrorMessage() -> String {
        if let errInfo = errorInfo { return " \(errInfo.description)" }
        else { return " 😄 " }
    }
    
    func clean() { bag.dispose() }
    
    
    func stringValueForProperty(_ prop: String) -> String? {
        
        let result = context.stringValueForProperty(prop)
        
        return result
    }
    
    
    func insertDefaultCode(for parameters: [ParameterProperty]) {
        
        if self.codeModel.isEmpty {
            
            var defaultCode : String = ""
            
            for param in parameters {
                
                let codeLine = "\(param.toCodeString()) \n"
                
                defaultCode.append( codeLine )
            }
            
            self.codeModel.code.value = defaultCode
        }
    }
    
    func updateParameterPropertyValuesFromJSContext(for parameters: [ParameterProperty]) {
        
        // ToDo: add cases for Float/Float64, Int array, Float64 array, Bool array, String array
        //       then refactor into a more supple / less brittle approach, utilizing parametric polymorphism if possible
        
        for param in parameters {
            
            if let codeVal = self.context.stringValueForProperty( param.paramName ) {
                
                // switch param.paramValue { }
                
                if let _ = param.paramValue.asIntValue() {
                    
                    if let codeIntVal = Int(codeVal) {
                        
                        parameters.updateParameter( param.paramName, to: codeIntVal )
                    }
                    
                } else if let _ = param.paramValue.asFloatValue() {
                    
                    if let codeFloatVal = Float64(codeVal) {
                        
                        parameters.updateParameter( param.paramName, to: codeFloatVal )
                    }
                    
                } else if let _ = param.paramValue.asBoolValue() {
                    
                    if let codeBoolVal = Bool(codeVal) {
                        
                        parameters.updateParameter( param.paramName, to: codeBoolVal )
                    }
                    
                } else if let _ = param.paramValue.asIntArrayValue() {
                    
                    if let codeIntArrayVal = codeVal.toIntArray() {
                        
                        parameters.updateParameter( param.paramName, to: codeIntArrayVal )
                    }
                    
                } else if let _ = param.paramValue.asStringValue() {
                    
                    let codeStringVal = String(codeVal)
                    
                    parameters.updateParameter( param.paramName, to: codeStringVal )
                }
            }
        }
    }
}


