//
//  BezierKnobUIView.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/1/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

struct BezierKnob : ComponentKind {
    
    let name: String! = "BezierKnob"
    
    let kernelPrototype : KernelModelType? = BezierKnobKernelModel()
}


extension BezierKnob {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        let kernel = (model.kernel ?? BezierKnobKernelModel()) as! BezierKnobKernelModel

    //    let uiView = BezierKnobUIView( kernel )
        
        model.kernel  = kernel
        model.reactor = ComponentReactorDefault( model )
        
        model.inputs.addNew(["STRINGCODE", "STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel as! BezierKnobKernelModel)
        
     //   model.reactor.establishOutputs = configOutputs( model.reactor!.outputs )
        
        model.reactor.uiView = BezierKnobUIView( kernel ) // uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: BezierKnobKernelModel) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                // clean all inputs and outputs
            
                input.clean() ; output.clean()
                
                // now start redefining all inputs and outputs
                
                guard let input0  = input[0]  else { return }
                guard let input1  = input[1]  else { return }
                guard let output0 = output[0] else { return }
                
                
                input0.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let temp = msg.intWithBound() {
                            
                            printLog("BezierKnob : input[0] observer detects current value : \(temp)")
                            
                            kernel.knobLevel.value = msg 
                        }
                    }
                }
                
                input1.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let temp = msg.intWithBound() {
                            
                            printLog("BezierKnob : input[1] observer detects current value : \(temp)")
                            
                            kernel.inputValue.value = msg
                        }
                    }
                }
                
                
                func deployOutput(_ val: Int) {
                    
                    let outval  = constrainRange(val)
                    let outcode = EventsWriting.intPairAsBoundedInt(k: outval, x: 128)
                    
                    output0.model.assign(outcode)
                }
                
                
                if input1.isOccupied {
                    
                    kernel.inputValue.property
                        
                        .observeNext { str in
                        
                        if let inval = str.intWithBound(), let knob = kernel.knobLevel.value.intWithBound() {
                            
                            deployOutput( knob.k + inval.k )
                        }
                        
                    }.dispose(in: output0.bag)
                    
                }
                
                else {
                    
                    kernel.knobLevel.property

                        .observeNext { str in
                        
                        if let knob = str.intWithBound() {
                            
                            deployOutput( knob.k )
                        }
                        
                    }.dispose(in: output0.bag)
                }
            }
            
            input[0]?.setRefresh  { reconfigProcess() }
            input[1]?.setRefresh  { reconfigProcess() }
            output[0]?.setRefresh { reconfigProcess() }
        }    
    }
    
    private func configOutputs(_ output: OutputPointReactors) -> () -> () {
    
        return { }
    }
}


final class BezierKnobKernelModel : KernelModelType {
    
    var knobLevel  : KernelParameter<StringCoder> = KernelParameter("knobLevel", "")
    var inputValue : KernelParameter<StringCoder> = KernelParameter("inputValue", "")
    
    required init() {
        self.knobLevel   = KernelParameter("knobLevel", "")
        self.inputValue  = KernelParameter("inputValue", "")
        knobLevel.value  = EventsWriting.intPairAsBoundedInt(k: 78, x: 128)
        inputValue.value = EventsWriting.intPairAsBoundedInt(k:  0, x: 128)
    }
    
    func publish(to view: ComponentContentView) {
        knobLevel.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case knobval, inval
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.knobLevel   = KernelParameter("knobLevel", "")
        self.inputValue  = KernelParameter("inputValue", "")
        knobLevel.value  = try vals.decode( StringCoder.self, forKey: .knobval )
        inputValue.value = try vals.decode( StringCoder.self, forKey: .inval   )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( knobLevel.value,  forKey: .knobval )
        try bin.encode( inputValue.value, forKey: .inval   )
    }
}



final class BezierKnobUIView : ComponentContentView {
    
    weak var kernel : BezierKnobKernelModel!
    
    
    init(_ model: BezierKnobKernelModel) {
        
        super.init(width: 30.0, height: 30.0)
    
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    
    override func draw(_ dirtyRect: NSRect) {
        
        guard let knobLevel_ = kernel.knobLevel.value.intWithBound() else {
            
            printLog("BezierKnobUIView : draw() : FAILED to recognize kernel.knobLevel.value.intWithBound()")
            
            return }
        
        let val = CGFloat( knobLevel_.k ) / CGFloat( knobLevel_.x )
        
        printLog("BezierKnobUIView : draw() : SUCCESSFULLY recognized kernel.knobLevel.value.intWithBound(), as: \(knobLevel_)")
        
        RegularKnobStyleKit.drawSizableRegularKnob(moveLevel: val, knobScale: 0.25)
    }
    
}



