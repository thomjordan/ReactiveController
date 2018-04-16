//
//  PadGrid.swift
//  ReactiveController
//
//  Created by Thom Jordan on 8/23/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import MidiPlex

protocol PadGrid {
    var gridsize : Int { get }
}

enum PadColor {
    case green
    case lime
    case yellow
    case amber
    case salmon
    case orange
    case red
    case none
    
    func toUIPad() -> Int {
        switch self {
        case .lime   : return 1
        case .amber  : return 2
        case .salmon : return 3
        default      : return 0
        }
    }
}


extension PadGrid {
    
    var numpads  : Int { return gridsize * gridsize }
    var padNums  : [Int] { return [Int](0..<numpads) }
    
    func padNumToPadCoords(_ padnum : Int) -> (x: Int, y: Int) {
        let xval = padnum % gridsize
        let yval = (padnum / gridsize) % gridsize
        return ( x: xval, y: yval )
    }
    
    func padCoordsToPadNum(x: Int, y: Int) -> Int {
        let result = y * gridsize + (x % gridsize)
        return result
    }
    
    func calcSingularPad( _ pad: (x: Int, y: Int) ) -> [Int] {
        var result:[Int] = []
        result.append( padNums[(pad.y%gridsize)*gridsize + (pad.x%gridsize)] )
        return result
    }
    
    func calcVerticalPadSeq( _ head: (x: Int, y: Int), _ tail: (x: Int, y: Int) ) -> [Int] {
        let rowSeq:[Int] = head.y < tail.y ? [Int](head.y...tail.y) : [Int]((tail.y...head.y).reversed())
        var result:[Int] = []
        for rownum in rowSeq { result.append( padNums[(rownum%gridsize)*gridsize + (head.x%gridsize)] ) }
        return result
    }
    
    func calcHorizontalPadSeq( _ head: (x: Int, y: Int), _ tail: (x: Int, y: Int) ) -> [Int] {
        let colSeq:[Int] = head.x < tail.x ? [Int](head.x...tail.x) : [Int]((tail.x...head.x).reversed())
        var result:[Int] = []
        for colnum in colSeq { result.append( padNums[(head.y%gridsize)*gridsize + (colnum%gridsize)] ) }
        return result
    }
    
    func calcDiagonalPadSeq( _ head: (x: Int, y: Int), _ tail: (x: Int, y: Int) ) -> [Int] {
        let xseq:[Int] = head.x < tail.x ? [Int](head.x...tail.x) : [Int]((tail.x...head.x).reversed())
        let yseq:[Int] = head.y < tail.y ? [Int](head.y...tail.y) : [Int]((tail.y...head.y).reversed())
        let diagonalSeq = zip(xseq, yseq)
        var result:[Int] = []
        for numpair in diagonalSeq { result.append( padNums[(numpair.1%gridsize)*gridsize + (numpair.0%gridsize)] ) }
        return result
    }
    
    func calcKnightsPadSeq( _ head: (x: Int, y: Int), _ tail: (x: Int, y: Int) ) -> [Int] {
        let xseq:[Int] = head.x < tail.x ? [Int](head.x...tail.x) : [Int]((tail.x...head.x).reversed())
        let yseq:[Int] = head.y < tail.y ? [Int](head.y...tail.y) : [Int]((tail.y...head.y).reversed())
        var result:[Int] = []
        if xseq.count < yseq.count {
            var yLast:Int = 0 ; result = []
            for yval in yseq { result.append( padNums[(yval%gridsize)*gridsize + (xseq[0]%gridsize)] ) ; yLast = yval }
            if result.count > 0 { result.removeLast() }
            for xval in xseq { result.append( padNums[(yLast%gridsize)*gridsize + (xval%gridsize)] ) }
        }
        else {
            var xLast:Int = 0 ; result = []
            for xval in xseq { result.append( padNums[(yseq[0]%gridsize)*gridsize + (xval%gridsize)] ) ; xLast = xval }
            if result.count > 0 { result.removeLast() }
            for yval in yseq { result.append( padNums[(yval%gridsize)*gridsize + (xLast%gridsize)] ) }
        }
        return result
    }
    
    func padNumPairToPadSeq(_ head: Int, _ tail: Int) -> [Int] {
        let head = padNumToPadCoords(head)
        let tail = padNumToPadCoords(tail)
        if head == tail { print("singular pad") ; return calcSingularPad( head ) }
        if head.x == tail.x { print("vertical pad sequence") ; return calcVerticalPadSeq( head, tail ) }
        if head.y == tail.y { print("horizontal pad sequence") ; return calcHorizontalPadSeq( head, tail ) }
        if abs(head.x-tail.x)==abs(head.y-tail.y) {print("diagonal pad sequence"); return calcDiagonalPadSeq(head,tail)}
        else { print("knight's tour pad sequence"); return calcKnightsPadSeq( head, tail ) }
    }
    
    func genPadLightSequence(_ head: Int, _ tail: Int) -> [(pad: Int, color: PadColor)] {
        let padSeq = padNumPairToPadSeq( head, tail )
        var result : [(pad: Int, color: PadColor)] = []
        for padnum in padSeq { result.append( (pad: padnum, color: PadColor.amber) ) }
        if result.count >= 2 {
            result[result.startIndex].color = PadColor.lime
            result[result.endIndex-1].color = PadColor.salmon
        }
        else if result.count == 1 {
            result[result.startIndex].color = PadColor.lime
        }
        return result
    }
    
    func lightSeqToUIPad(_ lightSeq: [(pad: Int, color: PadColor)]) -> [(pad: Int, value: Int)] {
        let result = lightSeq.map { (pad: $0.pad, value: $0.color.toUIPad()) }
        return result
    }
    
    func allLightsOffToUIPad() -> [(pad: Int, value: Int)] {
        let noColor    : PadColor = .none
        let uiNoColor  : Int = noColor.toUIPad()
        var result : [(pad: Int, value: Int)] = []
        for padnum in padNums {
            let newEntry : (pad: Int, value: Int) = (pad: padnum, value: uiNoColor)
            result.append( newEntry )
        }
        return result
    }
    
}

struct LaunchpadGrid : PadGrid {
    
    let gridsize: Int = 8
    
    let padNotenums : [Int] =
        [   0,   1,   2,   3,   4,   5,   6,   7,
            16,  17,  18,  19,  20,  21,  22,  23,
            32,  33,  34,  35,  36,  37,  38,  39,
            48,  49,  50,  51,  52,  53,  54,  55,
            64,  65,  66,  67,  68,  69,  70,  71,
            80,  81,  82,  83,  84,  85,  86,  87,
            96,  97,  98,  99, 100, 101, 102, 103,
            112, 113, 114, 115, 116, 117, 118, 119  ]
    
    func padNumToNoteNum(_ padnum: Int) -> Int {
        let result = padNotenums[ padnum % numpads ]
        return result
    }
    
    func noteNumToPadNum(_ notenum: Int) -> Int? {
        if let index = padNotenums.index(of: notenum) {
            return index
        }
        return nil 
    }
    
    func lightSeqToLaunchpad(_ lightSeq: [(pad: Int, color: PadColor)]) -> [MidiMessage] {
        let result = lightSeq.map {
            MidiMessage(fromVals: MidiType.noteOnVal.rawValue, UInt8(0), UInt8(padNumToNoteNum($0.pad)), UInt8(getLaunchpadCode(for: $0.color)))
        }
        return result
    }
    
    func allLightsOffToLaunchpad() -> [MidiMessage] {
        let noColor : PadColor = .none
        let launchpadNoColor : Int = getLaunchpadCode(for: noColor)
        var result : [MidiMessage] = []
        for padnum in padNums {
            let newMidiMsg = MidiMessage(fromVals: MidiType.noteOnVal.rawValue, UInt8(0), UInt8(padNumToNoteNum(padnum)), UInt8(launchpadNoColor))
            result.append( newMidiMsg )
        }
        return result
    }
    
    func getLaunchpadCode(for color: PadColor) -> Int {
        // tuple = (greenLevel, redLevel)
        // formula: tuple.0 * 16 + tuple.1 + 12
        switch color {
        case .green  : return 60 // (3, 0)
        case .lime   : return 61 // (3, 1)
        case .yellow : return 62 // (3, 2)
        case .amber  : return 63 // (3, 3)
        case .salmon : return 47 // (2, 3)
        case .orange : return 31 // (1, 3)
        case .red    : return 15 // (0, 3)
        case .none   : return 12 // (0, 0)
        }
    }
}


struct TestPad {
    
   let lpGrid = LaunchpadGrid() 
}
