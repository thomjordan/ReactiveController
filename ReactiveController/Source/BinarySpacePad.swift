//
//  BinarySpacePad.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/18/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Cocoa
import ReactiveKit
import Bond
import MidiPlex


struct BinarySpacePad : ComponentKind {
    
    let name: String! = "BinarySpacePad"
    
    let kernelPrototype : KernelModelType? = BinarySpacePadKernelModel()
}

extension BinarySpacePad {
    
    func configure(_ model: ComponentModel) {
        
        let kernel = (model.kernel ?? BinarySpacePadKernelModel()) as! BinarySpacePadKernelModel
        
        model.kernel  = kernel
        let reactor = BinarySpacePadComponentReactor( model )
        model.reactor = reactor
        
        model.inputs.addNew(["STRINGCODE", "STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        kernel, reactor)
        
        model.reactor.uiView = BinarySpacePadUIView( kernel )
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input:  InputPointReactors,
                               _ output: OutputPointReactors,
                               _ kernel: BinarySpacePadKernelModel,
                               _ reaktor: BinarySpacePadComponentReactor) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                // clean all inputs and outputs
                
                input.clean() ; output.clean()
                
                // now start redefining all inputs and outputs
                
              //  guard let input0  = input[0]  else { return }
              //  guard let input1  = input[1]  else { return }
              //  guard let output0 = output[0] else { return }
                
                reaktor.startReceivingMidiFromLaunchpad()
                reaktor.observeAndDisambiguateMidi()
                reaktor.observeKernel()
            }
            
            reaktor.setRefresh { reconfigProcess() }
        }
    }
}


final class BinarySpacePadComponentReactor : ComponentReactor {
    
    var bags: [String : DBag] = [:]
    
    weak var model: ComponentModel!
    
    var inputs: InputPointReactors!
    
    var outputs: OutputPointReactors!
    
    var establishProcess: (() -> ())?
    
    var establishOutputs: (() -> ())?
    
    var uiView: ComponentContentView?
    
    var kernel : BinarySpacePadKernelModel { return model.kernel as! BinarySpacePadKernelModel }
    
    let incomingMidi : Property<MidiMessage> = Property(MidiMessage(fromVals: 0, 0, 0, 0))
    
    
    func startReceivingMidiFromLaunchpad() {
        MidiCenter.shared
            .addMidiReceiveCallback { [weak self] (msg:MidiNodeMessage) in
                guard msg.node == "Launchpad" else { return }
                self?.incomingMidi.next(msg.midi)
            }
    }
    
    func observeAndDisambiguateMidi() {
        
        guard let midiInObserverBag = bags.makeNew("midiInObserver") else { return }
        
        incomingMidi
        
            .filter { $0.isNoteOn() || $0.isNoteOff() }
            .zipPrevious()
            .observeNext { [weak self] msgPair in
                if let prevMsg = msgPair.0, prevMsg.isNoteOn(), msgPair.1.isNoteOn() {
                    let currMsg = msgPair.1
                    if let padnums = self?.notenumsToPads(Int(prevMsg.data1()), Int(currMsg.data1())) {
                       // self?.clearLaunchpad()
                        self?.kernel.startPad.value = padnums.startPad
                        self?.kernel.closePad.value = padnums.closePad
                        self?.clearLaunchpad()
                        self?.commandLaunchpad( padnums.startPad, padnums.closePad )
                    }
                }
            }.dispose(in: midiInObserverBag)
    }
    
    func observeKernel() {
        let _ = combineLatest( kernel.startPad.property, kernel.closePad.property ) { [weak self] startpad, closepad in
            self?.clearLaunchpad()
            self?.commandLaunchpad( startpad, closepad )
        }
    }
    
    func notenumsToPads(_ prevNoteNum: Int, _ currNoteNum: Int) -> (startPad: Int, closePad: Int)? {
        let lpGrid = LaunchpadGrid()
        guard let startPadNum = lpGrid.noteNumToPadNum(prevNoteNum),
            let closePadNum = lpGrid.noteNumToPadNum(currNoteNum) else { return nil }
        return (startPad: startPadNum, closePad: closePadNum)
    }
    
    func clearLaunchpad() {
        let lpGrid = LaunchpadGrid()
        let lpResetSeq = lpGrid.allLightsOffToLaunchpad()
        for msg in lpResetSeq {
            MidiCenter.shared.sendMsg(msg, toTargetNamed: "Launchpad")
        }
    }
    
    func commandLaunchpad(_ startPadNum: Int, _ closePadNum: Int) {
        let lpGrid = LaunchpadGrid()
        let lightSeq = lpGrid.genPadLightSequence(startPadNum, closePadNum)
        let lpLightSeq = lpGrid.lightSeqToLaunchpad(lightSeq)
        for msg in lpLightSeq {
            MidiCenter.shared.sendMsg(msg, toTargetNamed: "Launchpad")
        }
    }
    
//    func initObserverBag() -> DisposeBag? { return bags.makeNew("midiInObserver") }
//    func initKernelBag()   -> DisposeBag? { return bags.makeNew("kernel") }
    
}


final class BinarySpacePadKernelModel : KernelModelType {
    
    var startPad : KernelParameter<Int> = KernelParameter("startPad", 0)
    var closePad : KernelParameter<Int> = KernelParameter("closePad", 0)
    
    required init() {
        self.startPad  = KernelParameter("startPad", 0)
        self.closePad  = KernelParameter("closePad", 0)
    }
    
    func publish(to view: ComponentContentView) {
        startPad.syncView( view )
        closePad.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case startPadNum, closePadNum
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.startPad = KernelParameter("startPad", 0)
        startPad.value = try vals.decode( Int.self, forKey: .startPadNum )
        self.closePad = KernelParameter("closePad", 0)
        closePad.value = try vals.decode( Int.self, forKey: .closePadNum )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( startPad.value, forKey: .startPadNum )
        try bin.encode( closePad.value, forKey: .closePadNum )
    }
}




