//
//  SimpleSequencer.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//


import Foundation
import Cocoa
import ReactiveKit
import MidiToolbox
import AudioToolbox


class SimpleSequencer: MTMusicSequence {
    
    var tracks:[MTMusicTrack] = []
    var player = MTMusicPlayer()
    
    var tempo:Float64 = Constants.mainTempo // 108.0
    
    override init() {
        super.init()
        player.setSequence(self)
        stopSequence()
        printLog("SimpleSequencer : init() ")
    }
    
    convenience init(numtracks: Int) { 
        self.init()
        for _ in 0..<numtracks {
            let _ = self.newTrack()
        }
        defineTempo(self.tempo) 
    }
    
    override func newTrack() -> MTMusicTrack {
        let trk = super.newTrack()
        tracks.append(trk)
        return trk
    }
    
    func defineTempo(_ bpm:Float64) {
        self.getTempoTrack()?.newExtendedTempoEvent(0.0, bpm: bpm) // newExtendedTempoEvent
        tempo = bpm
    }
    
    func play() {
        player.start()
        printLog("SimpleSequencer: play() called.")
    }
    
    func stop() {
        player.stop()
        printLog("SimpleSequencer: stop() called.")
    }
    
    func cue(_ loc: MusicTimeStamp = 0.0) {
        player.setTime( loc )
        printLog("SimpleSequencer: setTime( \(loc) ) called.")
    }
    
    func preroll() {
        player.preroll()
        printLog("SimpleSequencer: preroll() called.")
    }
    
    func read() -> MusicTimeStamp {
        let loc = player.getTime()
        printLog("SimpleSequencer: read() called, with result: \(loc) ")
        return loc
    }
    
    /*
    func readFromLongestTrack() -> MusicTimeStamp? {
        let tracksWithLengths : [(MTMusicTrack, MusicTimeStamp)] = tracks.map { ($0, $0.trackLength) }
        guard let longest = tracksWithLengths.sorted(by: { $0.1 > $1.1 } ).first else { return nil }
        let currLoc = getTime
        return nil
    }*/ 
    
    func playSequence() {
        player.stop()
        player.setTime(0.0)
        player.preroll()
        player.start()
        printLog("SimpleSequencer:playSequence() started sequence.")
    }
    
    func stopSequence() {
        player.stop()
        printLog("SimpleSequencer:stopSequence() stopped sequence.")
    }
    
    func closeSequencer() {
        for trk in tracks {
            trk.clearTrack()
            disposeTrack(trk)
        }
        player.disposePlayer()
        disposeSequence()
    }
    
    func getLengthOfLongestTrack() -> MusicTimeStamp? {
        let       trackLengths  = tracks.map { $0.trackLength }
        guard let longestLength = trackLengths.sorted().last else { return nil }
        return longestLength
    }
    
}


extension MTMusicTrack {
    
    func formatLoop(_ length: MusicTimeStamp) {
        printLog("MTMusicTrack:formatLoop() to length: \(length)")
        changeTrackLength( length )
        changeLoopDuration( length )
        changeNumberOfLoops( 0 ) // repeats indefinitely
    }
    
    func clearTrack() {
        guard let trk = track else { return }
        clear(0, endTime: MusicTimeStamp(8192.0))
        printLog("SimpleSequencer: clearTrack()")
    }
}


