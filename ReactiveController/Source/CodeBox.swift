//
//  CodeBox.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/6/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiPlex



struct CodeBox : ComponentKind {
    
    let name: String! = "CodeBox"
    
    let kernelPrototype : KernelModelType? = CodeBoxKernelModel()
    
}


extension CodeBox {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        model.codeScript.runnableJSAgent = CodeBoxJSAgent(model.codeScript)
        
        let kernel = (model.kernel ?? CodeBoxKernelModel()) as! CodeBoxKernelModel
        
        let uiView = CodeBoxUIView( kernel )
        
        model.kernel  = kernel
        model.reactor = ComponentReactorDefault( model )
        
        model.inputs.addNew(["MIDIMESSAGE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        kernel,
                                                        model )
        
        //   model.reactor.establishOutputs = configOutputs( model.reactor!.outputs )
        
        model.reactor.uiView = uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: CodeBoxKernelModel,
                               _ model:  ComponentModel) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                guard let context = model.codeScript.runnableJSAgent as? CodeBoxJSAgent else { return }
                
                context.clean()
                  input.clean()
                 output.clean()
                
                if let pin = input[0]?.pin.asMidiMessage() {
                    
                    context.midiInStream  = pin
                    context.midiOutStream = Property( MidiMessage() )
                    
                    context.midiOutStream!

                        .observeNext { (m: MidiMessage) in
                        
                          //  MidiCenter.shared.midiTargets[0].sendMsg( ImplicitlyUnwrappedOptional(m) )
                            
                            MidiCenter.shared.sendMsg( m, toTargetIndex: 0 )
                        
                        }.dispose(in: context.bag)
                }
            }
            
            input[0]?.setRefresh { reconfigProcess() }
        }
        
    }
    
  //  private func configOutputs(_ output: OutputPointReactors) -> () -> () { return { } }
}



final class CodeBoxKernelModel : KernelModelType {
    
    var input : KernelParameter<StringCoder> = KernelParameter("input", "")
    
    required init() {
        self.input = KernelParameter("input", "")
    }
    
    func publish(to view: ComponentContentView) {
        input.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case input
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.input = KernelParameter("input", "")
        input.value = try vals.decode( StringCoder.self, forKey: .input )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( input.value, forKey: .input )
    }
}



final class CodeBoxUIView : ComponentContentView {
    
    weak var kernel : CodeBoxKernelModel!
    
    
    init(_ model: CodeBoxKernelModel) {
        
        super.init(width: 50.0, height: 32.0)
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
 
}


 

