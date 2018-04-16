//
//  KeyscaleJS.swift
//  ReactiveController
//
//  Created by Thom Jordan on 10/24/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

//*

import Cocoa
import ReactiveKit
import Bond
import JavaScriptCore

struct KeyscaleJS : ComponentKind, CanvasContext {
    
    let name: String! = "KeyscaleJS"
    
    let kernelPrototype : KernelModelType? = KeyscaleJSKernelModel()
    
    let mainView: ComponentContentView = ComponentContentView(width: 118.0, height: 66.0)
    
    var canvas: DrawableCanvas?
    
    init() {}
}

extension KeyscaleJS {
    
    func configure(_ model: ComponentModel) {
        
        let kernel = (model.kernel ?? KeyscaleJSKernelModel()) as! KeyscaleJSKernelModel
        
        model.kernel = kernel
        model.reactor = ComponentReactorDefault( model )
        
        model.inputs.addNew(["STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! KeyscaleJSKernelModel,
                                                        model.reactor as! ComponentReactorDefault )
        
        model.reactor.uiView = mainView
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: KeyscaleJSKernelModel,
                               _ reaktor: ComponentReactorDefault) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                // clean all inputs and outputs
                
                input.clean() ; output.clean()
                
                // now start redefining all inputs and outputs
                
                guard let input0  = input[0]  else { return }
                guard let output0 = output[0] else { return }
                
                
                input0.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let inval = msg.intWithBound() {
                            
                            printLog("KeyscaleJS : input[0] observer detects current value : \(inval)")
                            
                            self.processInput(0, inval.k)
                        }
                    }
                }
                
                self.canvas?.outputRoutines[0] = { anymsg in
                    if let msgval = anymsg as? NSNumber {
                        let kval = Int(truncating: msgval)
                        let outcode = EventsWriting.intPairAsBoundedInt(k: kval, x: 128)
                        print("DrawableCanvas:outputRoutines[0] firing as: \(outcode)") 
                        output0.model.assign(outcode)
                    }
                }
            }
            
            
            input[0]?.setRefresh  { reconfigProcess() }
            output[0]?.setRefresh { reconfigProcess() }
        }
    }
    
   // private func configOutputs(_ output: OutputPointReactors) -> () -> () { return { } }
    
}


final class KeyscaleJSKernelModel : KernelModelType {
    
    func publish(to view: ComponentContentView) { }
    
    required init() { }
    
    required init(from decoder: Decoder) throws { }
    
    func encode(to encoder: Encoder) throws { }
}

//*/
