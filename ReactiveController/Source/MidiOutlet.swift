//
//  MidiOutput.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/25/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiPlex

 
struct MidiOutput : ComponentKind {
    
    let name: String! = "MidiOutput"
    
    let kernelPrototype : KernelModelType? = MidiOutputKernelModel() 
}

extension MidiOutput {
    
    func configure(_ model: ComponentModel) {
        
        let uiView = MidiOutputUIView()
        
        model.reactor = ComponentReactorDefault( model )
        
        model.inputs.addNew(["STRINGCODE", "STRINGCODE", "STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs)
        
        model.reactor.uiView = uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                input.clean()
                
                func makeRoutine(mchan: Int) -> (Property<StringCoder>) -> Disposable {
                    
                    return { (c) in c
                        
                        .filter  { $0.count >= 1 }

                        .observeNext { msg in
                            
                            if let temp = msg.intWithBound() {
                                
                                let duration = bpmTo8thInMs( Constants.mainTempo )
                                
                                let nnum = temp.k + 24
                                
                                let  onMsg = Midi.makeNoteOn( nnum, 127, mchan )
                                let offMsg = Midi.makeNoteOff( nnum, mchan )
                                
                                MidiCenter.shared.sendMsg( onMsg, toTargetIndex: 0 )
                                
                                delay( duration ) { MidiCenter.shared.sendMsg( offMsg, toTargetIndex: 0 ) }
                            }
                            
                            printLog("MidiOutput received StringCode command: \(msg)")
                        }
                    }
                }
                
                let routine1 = makeRoutine(mchan: 1)
                let routine2 = makeRoutine(mchan: 2)
                let routine3 = makeRoutine(mchan: 3)
                
                input[0]?.model.assign { (c) in routine1(c) }
                input[1]?.model.assign { (c) in routine2(c) }
                input[2]?.model.assign { (c) in routine3(c) }
            }
            
            input[0]?.setRefresh { reconfigProcess() }
            input[1]?.setRefresh { reconfigProcess() }
            input[2]?.setRefresh { reconfigProcess() }
        }
    }
}


final class MidiOutputKernelModel : KernelModelType {
    func publish(to view: ComponentContentView) { }
}


final class MidiOutputUIView : ComponentContentView {
    
  //  weak var kernel : MidiOutputKernelModel!
    
    init() {
        
      //  init(_ model: BufferPlayerKernelModel) {
        
        super.init(width: 50.0, height: 32.0)
        
      //  self.kernel = model
      //  self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
}
