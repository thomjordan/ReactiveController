//
//  UserDefinedComponent.swift
//  ReactiveController
//
//  Created by Thom Jordan on 10/28/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation
import Cocoa
import ReactiveKit
import Bond
import DrawableCanvasKit 


class UserDefinedComponent : ComponentKind, CanvasContext {

    let name: String! = "UserDefinedComponent"
    
    let kernelPrototype : KernelModelType? = UserDefinedComponentKernelModel()
    
    let inView: ComponentContentView = ComponentContentView(width: 118.0, height: 66.0)
    
    var canvas: DrawableCanvas!
    
    var inputTypes  : [String] = ["STRINGCODE"]
    var outputTypes : [String] = ["STRINGCODE"]
    
    
    required public init(url: URL) {
        
        applyUserSpec(at: url)
        
        canvas = DrawableCanvas(frame: inView.frame)
       // canvas.reifyUserSpecs()
        canvas.addScripts(from: url)
        inView.addSubview(canvas.canvasView)
    }
    
    func applyUserSpec(at url: URL) {
        guard let spec = UserSpec.fromJSON(at: url) else { return }
        inputTypes  = spec.inputs  ?? inputTypes
        outputTypes = spec.outputs ?? outputTypes
    }

}

extension UserDefinedComponent {
    
    func configure(_ model: ComponentModel) {
        
        canvas.setupUI()
        
        let kernel = (model.kernel ?? UserDefinedComponentKernelModel()) as! UserDefinedComponentKernelModel
        
        model.kernel  = kernel
        model.reactor = ComponentReactorDefault( model )
        
        // TO DO: add user-defined types from JS
//        for _ in 0..<numinputs  { model.inputs.addNew(["STRINGCODE"])  }
//        for _ in 0..<numoutputs { model.outputs.addNew(["STRINGCODE"]) }
//        for inputType  in inputTypes   {  model.inputs.addNew( [inputType ] ) }
//        for outputType in outputTypes  { model.outputs.addNew( [outputType] ) }
        
        model.inputs.addNew(inputTypes)
        model.outputs.addNew(outputTypes)
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! UserDefinedComponentKernelModel,
                                                        model.reactor as! ComponentReactorDefault )
        
        model.reactor.uiView = inView
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: UserDefinedComponentKernelModel,
                               _ reaktor: ComponentReactorDefault) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                // clean all inputs and outputs
                
                input.clean() ; output.clean()
                
                guard let input0  = input[0]  else { return }
              //  guard let output0 = output[0] else { return }
                let inputnum = 0
                
               // for inputnum in 0..<input.count {
                
                   // input[inputnum]?.model.assign { (c) in c
                
                    input0.model.assign { (c) in c
                        
                        .filter  { $0.count >= 1 }
                        
                        .observeNext { msg in
                            
                            printLog("UserDefinedComponent : input[\(inputnum)] observer detects input")
                            
                            if let inval = msg.intWithBound() {
                                
                                printLog("UserDefinedComponent : input[\(inputnum)] observer detects current value : \(inval)")
                                
                                // DispatchQueue.global(qos: .userInteractive).async
                                DispatchQueue.main.async { [weak self] in
                                    self?.processInput(inputnum, inval.k)
                                }
                            }
                        }
                    }
                
               // }

                
                for outputnum in 0..<output.count {
                    
                    self.canvas.outputRoutines[outputnum] = { anymsg in
                        if let msgval = anymsg as? NSNumber {
                            let kval = Int(truncating: msgval)
                            let outcode = EventsWriting.intPairAsBoundedInt(k: kval, x: 128)
                            print("DrawableCanvas:outputRoutines[\(outputnum)] firing as: \(outcode)")
                            output[outputnum]?.model.assign(outcode)
                        }
                    }
                    
                    output[outputnum]?.setRefresh { reconfigProcess() }
                }
            }
            
            input[0]?.setRefresh  { reconfigProcess() }
            output[0]?.setRefresh { reconfigProcess() }
        }
    }    
}


final class UserDefinedComponentKernelModel : KernelModelType {
    
    func publish(to view: ComponentContentView) { }
    
    required init() { }
    
    required init(from decoder: Decoder) throws { }
    
    func encode(to encoder: Encoder) throws { }
}
