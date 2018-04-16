//
//  BufferPlayer.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond
import MidiToolbox
import AudioToolbox


struct BufferPlayer : ComponentKind {
    
    let name: String! = "BufferPlayer"
    
    let kernelPrototype : KernelModelType? = BufferPlayerKernelModel()
}


extension BufferPlayer {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        let kernel = (model.kernel ?? BufferPlayerKernelModel()) as! BufferPlayerKernelModel
        
        let uiView = BufferPlayerUIView( kernel )
        
        model.kernel  = kernel
        let reaktor : BufferPlayerComponentReactor = BufferPlayerComponentReactor( model )
        
        model.reactor = reaktor
        
        model.inputs.addNew(["STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! BufferPlayerKernelModel,
                                                        model.reactor as! BufferPlayerComponentReactor )
        
        model.reactor.uiView = uiView
        
        model.reactor.observeSelectionStatus()
    }
    
    
    private func configProcess(_ input   : InputPointReactors,
                               _ output  : OutputPointReactors,
                               _ kernel  : BufferPlayerKernelModel,
                               _ reaktor : BufferPlayerComponentReactor) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                input.clean() ; output.clean()
                
     //           guard let outpin = output[0]?.pin.asStringCoder() else { return }
                
                input[0]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        printLog("BufferPlayer:reconfigProcess() observer detects: \(msg)")
                        
                        kernel.stepPattern1.value = msg
                        
     //                   outpin.value = msg
                        
                        // printLog("k: \(msg[0].k)  n: \(msg[0].n)")
                    }
                }
                
                reaktor.restartObservers { str in
                    
                    output[0]?.setStringCode( str )
                }
            }
            
            input[0]?.setRefresh { reconfigProcess() }
        }
    }
}


final class BufferPlayerComponentReactor : ComponentReactor {
    
    var bags = DisposeBagStore()
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    let simpleSeq : SimpleSequencer = SimpleSequencer(numtracks: 1) 
    
    var kernel : BufferPlayerKernelModel!
    
    let transportControl : Property<TransportControlStateModel.TransportStatus> = Property( .defaultState )
    
    
    func restartObservers(_ outputRoutine: ((String) -> Void)? = nil) {
        
        confirm( self.simpleSeq.defUserCallback(proc: nil, outputProc: outputRoutine) )
        
        self.kernel = model.kernel as! BufferPlayerKernelModel
        
        guard let playerParamsBag = bags.makeNew("PlayerParams") else { return }
        
        kernel.stepPattern1.property
            
            .observeNext { [weak self] steps in
                
                self?.addSteps( steps, toTrack: 0 )
                
            }.dispose(in: playerParamsBag)
        
        restartTransportObserver()
        
        guard let currentTransportMode = App.shared.transportMode else { return }
        
        if currentTransportMode == .playing { startPlayingMidCycle() }
    }
    
    func addSteps(_ steps:StringCoder, toTrack tracknum: Int = 0) {
        
        guard (tracknum < simpleSeq.tracks.count) && (tracknum >= 0) else { return }
        
        let idx = tracknum
        let trk = simpleSeq.tracks[idx]
        
        trk.clearTrack()
        
        guard let stepsListWithBound = steps.intStepsListWithBound() else { return }
        
        let theSteps = stepsListWithBound.steps
        let theBound = stepsListWithBound.x
        
        
        let phrase = OnsetsGen.makePhrase(self.kernel.defaultLengths, numevents: theSteps.count)
        
        trk.formatLoop( phrase.length ) // sets track/loop length, removes existing events
        
        for (step, onset) in zip(theSteps, phrase.onsets) {
            let expr = EventsWriting.intPairAsBoundedInt(k: step, x: theBound)
            simpleSeq.addUserData( expr, onTracK: idx, atTime: onset)
        }
    }
    
    func startPlayingMidCycle() {
        guard simpleSeq.tracks.count > 0 else { return }
        let theLocalCycleLength = simpleSeq.tracks[0].trackLength
        guard theLocalCycleLength > 0 else { return }
       // guard let theLocalCycleLength_ = simpleSeq.getLengthOfLongestTrack() else { return }
        
        let factor : Float64 = 1000.0
        // read the current beat location as close as possible to the modulo operation
        guard let masterCycleLocation  = App.shared.toolbarCxt?.readCurrentBeatLocation() else { return }
        let cuePoint = Float64(Int( masterCycleLocation * factor ) % Int( theLocalCycleLength * factor )) / factor
       // let cuePoint = masterCycleLocation.truncatingRemainder(dividingBy: theLocalCycleLength)
        
        simpleSeq.cue( cuePoint )
        simpleSeq.preroll()
        simpleSeq.play()
        printLog("~&*~&*~&*~ A NEW BufferPlayer, CREATED WITH TRANSPORT RUNNING, starts playing from \(cuePoint) in its cycle. ~*&~*&~*&~")
    }
    
    
    func restartTransportObserver() {
        
        guard let transportStatusBag  = bags.makeNew("TransportStatus")  else { return }
        guard let transportControlBag = bags.makeNew("TransportControl") else { return }
        
        App.shared.transportState?
            
            .observeNext { [weak self] state in
                
                self?.transportControl.value = state
                
            }.dispose(in: transportStatusBag)
        
        self.transportControl.zipPrevious()
            
            .observeNext { [weak self] eventPair in
            
                switch eventPair {
                
                case ( .some(.stopClicked),  .defaultState ) : self?.simpleSeq.stop() ; self?.simpleSeq.cue()
                case ( .some(.playClicked),  .playEngaged  ) : self?.simpleSeq.play()
                case ( .some(.restartPlay),  .playEngaged  ) : self?.simpleSeq.cue()
                case ( .some(.stoppingPlay), .defaultState ) : self?.simpleSeq.stop()
                
                    /*
                     // only fires when a new BufferPlayer is created while the transport is playing
                     // starts the new BufferPlayer from a location in its loop cycle
                     // most relative to the master cycle's current location
                     case ( .some(.defaultState), .playEngaged  ) :
                     guard let masterCycleLocation = App.shared.toolbarDelegate?.readCurrentBeatLocation() else { return }
                     guard let theLocalCycleLength = self?.simpleSeq.getLengthOfLongestTrack() else { return }
                     let cuePoint = masterCycleLocation.truncatingRemainder(dividingBy: theLocalCycleLength)
                     self?.simpleSeq.cue( cuePoint )
                     self?.simpleSeq.play()
                     printLog("~&*~&*~&*~ A NEW BufferPlayer, CREATED WITH TRANSPORT RUNNING, starts playing from \(cuePoint) in its cycle. ~*&~*&~*&~")
                     self?.simpleSeq.cue()
                     */
                
                default: ()
            }
            
        }.dispose(in: transportControlBag)
    }
    
//    func initObserverBag()         -> DisposeBag? { return bags.makeNew("PlayerParams") }
//    func initTransportStatusBag()  -> DisposeBag? { return bags.makeNew("TransportStatus") }
//    func initTransportControlBag() -> DisposeBag? { return bags.makeNew("TransportControl") }
    
    func close() {
        disposeAll()
        simpleSeq.closeSequencer() 
    }
}



final class BufferPlayerKernelModel : KernelModelType {
    
    let defaultLengths : [MusicTimeStamp] = [0.618, 0.382]
    var stepPattern1 : KernelParameter<StringCoder> = KernelParameter("stepPattern1", "")
    
    required init() {
        self.stepPattern1 = KernelParameter("stepPattern1", "")
    }
    
    func publish(to view: ComponentContentView) {
       // stepPattern1.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case pattern1
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.stepPattern1 = KernelParameter("stepPattern1", "")
        stepPattern1.value = try vals.decode( StringCoder.self, forKey: .pattern1 )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( stepPattern1.value, forKey: .pattern1 )
    }
}



final class BufferPlayerUIView : ComponentContentView {
    
    weak var kernel : BufferPlayerKernelModel!
    
    
    init(_ model: BufferPlayerKernelModel) {
        
        super.init(width: 50.0, height: 32.0)
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
}

