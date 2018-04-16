//
//  TriggerPlayer.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/8/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

// numbeats = 16
// ppqn     = 1024
// pattern  = [243, 269]
// shift    = 0

// numbeats_2 = 16
// ppqn_2     = 1024
// pattern_2  = [243, 269]
// shift_2    = 0

struct TriggerPlayer : ComponentKind {
    
    let name: String! = "TriggerPlayer"
    
    let kernelPrototype : KernelModelType? = TriggerPlayerKernelModel()
}


extension TriggerPlayer {
    
    func configure(_ model: ComponentModel) {
        
        let kernel = (model.kernel ?? TriggerPlayerKernelModel()) as! TriggerPlayerKernelModel
        
        let uiView = TriggerPlayerUIView( kernel )
        
        model.kernel  = kernel
        
        let reaktor : TriggerPlayerComponentReactor = TriggerPlayerComponentReactor( model )
        model.reactor = reaktor
        
        model.inputs.addNew(["STRINGCODE"])
        model.outputs.addNew(["STRINGCODE"])
        
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! TriggerPlayerKernelModel,
                                                        model.reactor as! TriggerPlayerComponentReactor )
        
        model.reactor.uiView = uiView
        
        let params = genParams(from: kernel)
        
        model.codeScript.runnableJSAgent = ComponentContextJSAgent(model.codeScript, params)
        
        model.reactor.observeSelectionStatus()
    }
    
    func genParams(from kernel: TriggerPlayerKernelModel) -> [ParameterProperty] {
        
        var params : [ParameterProperty] = []
        
        let numbeatsParam = ParameterProperty( "numbeats", .intValue(kernel.numbeats.value))
        let ppqnParam     = ParameterProperty( "ppqn",     .intValue(kernel.ppqn.value))
        let patternParam  = ParameterProperty( "pattern",  .intArrayValue(kernel.pattern.value))
        let shiftParam    = ParameterProperty( "shift",    .intValue(kernel.shift.value))
        
        numbeatsParam.linkedPropertyUpdater = { p in if let v = p.asIntValue()      { kernel.numbeats.next(v) }}
        ppqnParam.linkedPropertyUpdater     = { p in if let v = p.asIntValue(), v>0 { kernel.ppqn.next(v)     }}
        patternParam.linkedPropertyUpdater  = { p in if let v = p.asIntArrayValue() { kernel.pattern.next(v)  }}
        shiftParam.linkedPropertyUpdater    = { p in if let v = p.asIntValue()      { kernel.shift.next(v)    }}
        
        params.addAttribute( numbeatsParam )
        params.addAttribute( ppqnParam )
        params.addAttribute( patternParam )
        params.addAttribute( shiftParam )
        
        printLog("TriggerPlayer : genParams()")
        
        return params
    }
    
    
    private func configProcess(_ input   : InputPointReactors,
                               _ output  : OutputPointReactors,
                               _ kernel  : TriggerPlayerKernelModel,
                               _ reaktor : TriggerPlayerComponentReactor) -> () -> () {
        
        return {
            
            func reconfigProcess() {
                
                input.clean() ; output.clean()
                
                reaktor.restartObservers { str in
                    
                    output[0]?.setStringCode( str )
                }
            }
            
            reaktor.setRefresh { reconfigProcess() } 
          //  output[0]?.setRefresh { reconfigProcess() }
        }
    }
}



final class TriggerPlayerKernelModel : KernelModelType {
    
    var numbeats :  Property<Int>  = Property(16)
    var ppqn     :  Property<Int>  = Property(1024)
    var pattern  :  Property<[Int]> = Property([246, 266, 243, 269])
    var shift    :  Property<Int>  = Property(0)
    
    var numevents : Int {
        let patlen = pattern.value.reduce( 0, { $0 + $1 })
        let events = (numbeats.value * ppqn.value * pattern.value.count) / patlen
        return Int(events)
    }
    
   // var beatlens : [Float64] { return pattern.value.map { Float64($0) / Float64(ppqn.value) }}
    
   // /*
    var beatlens : [Float64]? {
        let ticksPerBeat : Float64 = Float64(ppqn.value)
        guard ticksPerBeat > 0 else { return nil }
        return pattern.value.map { Float64($0) / ticksPerBeat }
    }
   // */
    
    required init() { }
    
    func publish(to view: ComponentContentView) {
      //  numbeats.syncView( view )
      //  ppqn.syncView( view )
      //  pattern.syncView( view )
      //  shift.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case numbeats, ppqn, pattern, shift
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        numbeats.value = try vals.decode(  Int.self,  forKey: .numbeats )
        ppqn.value     = try vals.decode(  Int.self,  forKey: .ppqn     )
        pattern.value  = try vals.decode( [Int].self, forKey: .pattern  )
        shift.value    = try vals.decode(  Int.self,  forKey: .shift    )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( numbeats.value, forKey: .numbeats )
        try bin.encode( ppqn.value,     forKey: .ppqn     )
        try bin.encode( pattern.value,  forKey: .pattern  )
        try bin.encode( shift.value,    forKey: .shift    )
    }
}


final class TriggerPlayerUIView : ComponentContentView {
    
    weak var kernel : TriggerPlayerKernelModel!
    
    
    init(_ model: TriggerPlayerKernelModel) {
        
        super.init(width: 50.0, height: 32.0)
        
        self.kernel = model
        
        self.kernel.publish(to: self)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
}


final class TriggerPlayerComponentReactor : ComponentReactor {
    
    var bags = DisposeBagStore()
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    //
    
    let simpleSeq : SimpleSequencer = SimpleSequencer(numtracks: 1)
    
    var kernel : TriggerPlayerKernelModel { return model.kernel as! TriggerPlayerKernelModel }
    
    let transportControl : Property<TransportControlStateModel.TransportStatus> = Property( .defaultState )
    
    
    func restartObservers(_ outputRoutine: ((String) -> Void)? = nil) {
        
        confirm( self.simpleSeq.defUserCallback(proc: nil, outputProc: outputRoutine) )
        
        guard let playerParamsBag = bags.makeNew("PlayerParams") else { return }
        
        kernel.numbeats
            
            .observeNext {[weak self] _ in self?.sequenceTriggers()}.dispose(in: playerParamsBag)
        
        kernel.ppqn
            
            .observeNext {[weak self] _ in self?.sequenceTriggers()}.dispose(in: playerParamsBag)
        
        kernel.pattern
            
            .observeNext {[weak self] _ in self?.sequenceTriggers()}.dispose(in: playerParamsBag)
        
        kernel.shift
            
            .observeNext {[weak self] _ in self?.sequenceTriggers()}.dispose(in: playerParamsBag)
        
        restartTransportObserver()
        
        guard let currentTransportMode = App.shared.transportMode else { return }
        
        if currentTransportMode == .playing { startPlayingMidCycle() }
    }
    
    func sequenceTriggers(_ tracknum: Int = 0) {
        
        guard (tracknum < simpleSeq.tracks.count) && (tracknum >= 0) else {
            
            printLog("TriggerPlayerComponentReactor : sequenceTriggers() : guard test FAILED.")
            
            return }
        
        guard let beatlens = kernel.beatlens else { return }
        
        printLog("TriggerPlayerComponentReactor : sequenceTriggers() : passed guard SUCCESSFULLY.")
        
        let idx = tracknum
        let trk = simpleSeq.tracks[idx]
        
        let looplen  = Float64(kernel.numbeats.value)
        let stepnums = Array(0..<kernel.numevents).rotated(kernel.shift.value)
        
        trk.clearTrack()
        
        let phrase = OnsetsGen.makePhrase( beatlens, numevents: kernel.numevents )
        
        trk.formatLoop( looplen ) // sets track/loop length, removes existing events
        
        for (step, onset) in zip(stepnums, phrase.onsets) {
            let expr = EventsWriting.intPairAsBoundedInt(k: step, x: kernel.numevents)
            simpleSeq.addUserData( expr, onTracK: idx, atTime: onset)
            printLog("TriggerPlayerComponentReactor : sequenceTriggers() : \(expr)")
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
        printLog("~&*~&*~&*~ A NEW TriggerPlayer, CREATED WITH TRANSPORT RUNNING, starts playing from \(cuePoint) in its cycle. ~*&~*&~*&~")
    }
    
    
    func restartTransportObserver() {
        
        guard let transportStatusBag  = bags.makeNew("TransportStatus")  else { return }
        guard let transportControlBag = bags.makeNew("TransportControl") else { return }
        guard let aLinkResponseBag    = bags.makeNew("ALinkResponse")    else { return }
        
        App.shared.toolbarCxt?.tempoModel.linkUpdater
            
            .observeNext { [weak self] params in
                
                self?.setBeat( params.beat, withBPM: params.bpm )
                
            }.dispose(in: aLinkResponseBag)
        
        
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
                 // only fires when a new TriggerPlayer is created while the transport is playing
                 // starts the new TriggerPlayer from a location in its loop cycle
                 // most relative to the master cycle's current location
                 case ( .some(.defaultState), .playEngaged  ) :
                 guard let masterCycleLocation = App.shared.toolbarDelegate?.readCurrentBeatLocation() else { return }
                 guard let theLocalCycleLength = self?.simpleSeq.getLengthOfLongestTrack() else { return }
                 let cuePoint = masterCycleLocation.truncatingRemainder(dividingBy: theLocalCycleLength)
                 self?.simpleSeq.cue( cuePoint )
                 self?.simpleSeq.play()
                 printLog("~&*~&*~&*~ A NEW TriggerPlayer, CREATED WITH TRANSPORT RUNNING, starts playing from \(cuePoint) in its cycle. ~*&~*&~*&~")
                 self?.simpleSeq.cue()
                 */
                
                default: ()
            }
            
        }.dispose(in: transportControlBag)
    }
    
//    func initObserverBag()         -> DisposeBag? { return bags.makeNew("PlayerParams") }
//    func initTransportStatusBag()  -> DisposeBag? { return bags.makeNew("TransportStatus") }
//    func initTransportControlBag() -> DisposeBag? { return bags.makeNew("TransportControl") }
//    func initALinkResponseBag()    -> DisposeBag? { return bags.makeNew("ALinkResponse") }
    
    func close() {
        disposeAll()
        simpleSeq.closeSequencer()
    }
    
    func setTempo(_ bpm: Float64) {
        simpleSeq.defineTempo(bpm)
    }
    
    func setBeat(_ beat: Float64, withBPM: Float64) {
        simpleSeq.defineTempo(withBPM)
        simpleSeq.player.setTime(beat)
    }

}



