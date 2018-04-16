//
//  OnsetsGen.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import AudioToolbox

public struct OnsetsGen: Sequence, IteratorProtocol {
    var count : Int = 0
    var lengths   : [MusicTimeStamp] = []
    var numevents : Int
    var numOnsets : Int { return lengths.count }
    var onsLength : MusicTimeStamp { return lengths.reduce(0, { $0 + $1 }) }
    
    init(_ vals:[MusicTimeStamp], numevents:Int) {
        self.lengths   = vals
        self.numevents = numevents
    }
    
    mutating public func next() -> MusicTimeStamp? {
        let cDiv = MusicTimeStamp( count / numOnsets )
        let cMod : Int = count % numOnsets
        let tail  = (lengths[0..<cMod]).reduce(0, { $0 + $1 })
        let tally = (onsLength * cDiv) + tail
        
        if count == numevents {
            return nil
        } else {
            defer { count += 1 }
            return tally
        }
    }
    
    public static func makePhrase(_ vals:[MusicTimeStamp], numevents:Int, startTime:MusicTimeStamp = 0) -> (onsets: [MusicTimeStamp], length: MusicTimeStamp) {
        var pOnsets : [MusicTimeStamp] = []
        let onsetGenerator = OnsetsGen(vals, numevents: numevents+1)
        for onset in onsetGenerator { pOnsets.append( onset + startTime ) }
        let pLength = pOnsets.removeLast()
        return (onsets: pOnsets, length: pLength)
    }
}


