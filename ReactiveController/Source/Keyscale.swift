//
//  Keyscale.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/12/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

struct Keyscale : ComponentKind {
    
    let name: String! = "Keyscale"
    
    let kernelPrototype : KernelModelType? = KeyscaleKernelModel()
}


extension Keyscale {
    
    func configure(_ model: ComponentModel) {
        
        let kernel = (model.kernel ?? KeyscaleKernelModel()) as! KeyscaleKernelModel
        
        let uiView = KeyscaleUIView( kernel )
        
        model.kernel  = kernel
        
        let reaktor : KeyscaleComponentReactor = KeyscaleComponentReactor( model, uiView )
        model.reactor = reaktor
        
        model.inputs.addNew(["STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! KeyscaleKernelModel,
                                                        model.reactor as! KeyscaleComponentReactor )
        
        model.reactor.uiView = uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input   : InputPointReactors,
                               _ output  : OutputPointReactors,
                               _ kernel  : KeyscaleKernelModel,
                               _ reaktor : KeyscaleComponentReactor) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                input.clean() ; output.clean()
                
                guard let input0  = input[0]  else { return }
                guard let output0 = output[0] else { return }
                
                input0.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let invals = msg.intWithBound() {
                            
                            printLog("Keyscale : input[0] observer : \(invals)")
                            
                            if let activeSteps = kernel.scaleSteps.activeSteps {
                                
                                let octave = invals.k / activeSteps.count
                                let pcstep = activeSteps[invals.k % activeSteps.count]
                                
                                let outnum = constrainRange( pcstep + (octave * 12) )
                                let outstr = EventsWriting.intPairAsBoundedInt(k: outnum, x: 128)
                                
                                output0.model.assign( outstr )
                                
                                kernel.holdingSteps.reset(pcstep)
                            }
                        }
                    }
                }
            }
            
            input[0]?.setRefresh  { reconfigProcess() }
            output[0]?.setRefresh { reconfigProcess() }
        }
    }
}


final class KeyscaleComponentReactor : ComponentReactor {
    
    var bags = DisposeBagStore()
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    var keyscaleUI : KeyscaleUIView {
        get { return uiView as! KeyscaleUIView }
        set(newValue) { uiView = newValue }
    }
    
    convenience init(_ model: ComponentModel, _ ui: KeyscaleUIView) {
        self.init(model)
        self.keyscaleUI = ui
    }
    
    func interpretMouseUp(_ event: MouseUpEvent) {
        keyscaleUI.interpretMouseUp(with: event.sender)
        printLog("ComponentReactor:interpretMouseUp() called.")
    }
    
//    func initObserverBag() -> DisposeBag? { return bags.makeNew("Params") }
}


final class KeyscaleKernelModel : KernelModelType {
    
    var scaleSteps   : OctaveKeyscaleStepToggles
    var holdingSteps : OctaveKeyscaleStepToggles
    
    required init() {
        self.scaleSteps   = OctaveKeyscaleStepToggles("scaleSteps", scale: "1-11-1-11-1-")
        self.holdingSteps = OctaveKeyscaleStepToggles("holdingSteps")
    }
    
    func publish(to view: ComponentContentView) {
        scaleSteps.syncView( view )
        holdingSteps.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case scale //, holding
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.scaleSteps   = OctaveKeyscaleStepToggles("scaleSteps", scale: "1-11-1-11-1-")
        self.holdingSteps = OctaveKeyscaleStepToggles("holdingSteps")
        scaleSteps.value  = try vals.decode( [Bool].self, forKey: .scale )
      //  holdingSteps.value = try vals.decode( OctaveKeyscaleStepToggles.self, forKey: .holding )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( scaleSteps.value, forKey: .scale )
      //  try bin.encode( holdingSteps.value, forKey: .holding )
    }
}
