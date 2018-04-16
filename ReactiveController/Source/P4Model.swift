//
//  SymmetricGroupValues.swift
//  InteractiveMusicAgentObjC
//
//  Created by Thom Jordan on 11/15/14.
//  Copyright (c) 2014 Thom Jordan. All rights reserved.
//


// Symmetric Group (e.g. S4, etc.)
// Permutations, Inversion Sets, and valid adjacent moves

import Cocoa
import AppKit

typealias PermutationNumber =  Int
typealias Permutation       = [Int]
typealias InversionSet      = [Int]
typealias StepwiseMoveList  = [PermutationNumber]  // [PermutationNumber?]
typealias PermutationShape  = [Int]


enum P4CubeState {
    case yang, yin, chyang, chyin
    
    static func gen(_ rval: Int) -> P4CubeState {
        switch rval {
        case -1: return P4CubeState.yang   // case -1
        case  0: return P4CubeState.yin    // case  0
        case  1: return P4CubeState.chyang // case  1
        default: return P4CubeState.chyin  // case  2
        }
    }
}

class P4_LiteralData {
    
    static let singleton = P4_LiteralData() 
    
    var permut_data:[Permutation]      = []
    var invset_data:[InversionSet]     = []
    var stpmov_data:[StepwiseMoveList] = []
    
    init() {
        permut_data.append([ 1, 2, 3, 4 ])
        permut_data.append([ 2, 1, 3, 4 ])
        permut_data.append([ 1, 3, 2, 4 ])
        permut_data.append([ 3, 1, 2, 4 ])
        permut_data.append([ 2, 3, 1, 4 ])
        permut_data.append([ 3, 2, 1, 4 ])
        permut_data.append([ 1, 2, 4, 3 ])
        permut_data.append([ 2, 1, 4, 3 ])
        permut_data.append([ 1, 4, 2, 3 ])
        permut_data.append([ 4, 1, 2, 3 ])
        permut_data.append([ 2, 4, 1, 3 ])
        permut_data.append([ 4, 2, 1, 3 ])
        permut_data.append([ 1, 3, 4, 2 ])
        permut_data.append([ 3, 1, 4, 2 ])
        permut_data.append([ 1, 4, 3, 2 ])
        permut_data.append([ 4, 1, 3, 2 ])
        permut_data.append([ 3, 4, 1, 2 ])
        permut_data.append([ 4, 3, 1, 2 ])
        permut_data.append([ 2, 3, 4, 1 ])
        permut_data.append([ 3, 2, 4, 1 ])
        permut_data.append([ 2, 4, 3, 1 ])
        permut_data.append([ 4, 2, 3, 1 ])
        permut_data.append([ 3, 4, 2, 1 ])
        permut_data.append([ 4, 3, 2, 1 ])
        
        invset_data.append([ 0, 0, 0, 0, 0, 0 ])
        invset_data.append([ 1, 0, 0, 0, 0, 0 ])
        invset_data.append([ 0, 1, 0, 0, 0, 0 ])
        invset_data.append([ 1, 0, 0, 1, 0, 0 ])
        invset_data.append([ 0, 1, 0, 1, 0, 0 ])
        invset_data.append([ 1, 1, 0, 1, 0, 0 ])
        invset_data.append([ 0, 0, 1, 0, 0, 0 ])
        invset_data.append([ 1, 0, 1, 0, 0, 0 ])
        invset_data.append([ 0, 1, 0, 0, 0, 1 ])
        invset_data.append([ 1, 0, 0, 1, 1, 0 ])
        invset_data.append([ 0, 1, 0, 1, 0, 1 ])
        invset_data.append([ 1, 1, 0, 1, 1, 0 ])
        invset_data.append([ 0, 0, 1, 0, 0, 1 ])
        invset_data.append([ 1, 0, 1, 0, 1, 0 ])
        invset_data.append([ 0, 1, 1, 0, 0, 1 ])
        invset_data.append([ 1, 0, 1, 1, 1, 0 ])
        invset_data.append([ 0, 1, 0, 1, 1, 1 ])
        invset_data.append([ 1, 1, 0, 1, 1, 1 ])
        invset_data.append([ 0, 0, 1, 0, 1, 1 ])
        invset_data.append([ 1, 0, 1, 0, 1, 1 ])
        invset_data.append([ 0, 1, 1, 0, 1, 1 ])
        invset_data.append([ 1, 0, 1, 1, 1, 1 ])
        invset_data.append([ 0, 1, 1, 1, 1, 1 ])
        invset_data.append([ 1, 1, 1, 1, 1, 1 ])
        
        stpmov_data.append([  1,  2,  6, -1, -1, -1 ])
        stpmov_data.append([  0, -1,  7,  3, -1, -1 ])
        stpmov_data.append([ -1,  0, -1,  4, -1,  8 ])
        stpmov_data.append([ -1,  5, -1,  1,  9, -1 ])
        stpmov_data.append([  5, -1, -1,  2, -1, 10 ])
        stpmov_data.append([  4,  3, -1, -1, 11, -1 ])
        stpmov_data.append([  7, -1,  0, -1, -1, 12 ])
        stpmov_data.append([  6, -1,  1, -1, 13, -1 ])
        stpmov_data.append([ -1, -1, 14, 10, -1,  2 ])
        stpmov_data.append([ -1, 11, 15, -1,  3, -1 ])
        stpmov_data.append([ -1, -1, -1,  8, 16,  4 ])
        stpmov_data.append([ -1,  9, -1, -1,  5, 17 ])
        stpmov_data.append([ -1, 14, -1, -1, 18,  6 ])
        stpmov_data.append([ -1, -1, -1, 15,  7, 19 ])
        stpmov_data.append([ -1, 12,  8, -1, 20, -1 ])
        stpmov_data.append([ -1, -1,  9, 13, -1, 21 ])
        stpmov_data.append([ 17, -1, 22, -1, 10, -1 ])
        stpmov_data.append([ 16, -1, 23, -1, -1, 11 ])
        stpmov_data.append([ 19, 20, -1, -1, 12, -1 ])
        stpmov_data.append([ 18, -1, -1, 21, -1, 13 ])
        stpmov_data.append([ -1, 18, -1, 22, 14, -1 ])
        stpmov_data.append([ -1, 23, -1, 19, -1, 15 ])
        stpmov_data.append([ 23, -1, 16, 20, -1, -1 ])
        stpmov_data.append([ 22, 21, 17, -1, -1, -1 ])
    }
}




// unchanging data; P4 class passed-by-reference
class P4 {
    static let permutations :[Permutation]      =  P4_LiteralData.singleton.permut_data
    static let inversionSets:[InversionSet]     =  P4_LiteralData.singleton.invset_data
    static let stepwiseMoves:[StepwiseMoveList] =  P4_LiteralData.singleton.stpmov_data
    
    class func   getPermutation( _ pnum: PermutationNumber ) -> Permutation      { return  permutations[pnum] }
    class func  getInversionSet( _ pnum: PermutationNumber ) -> InversionSet     { return inversionSets[pnum] }
    class func getStepwiseMoves( _ pnum: PermutationNumber ) -> StepwiseMoveList { return stepwiseMoves[pnum] }
    
    class func make4x4Perm( _ pnum: PermutationNumber ) -> PermutationShape {
        return makeSquaredPerm( getPermutation( pnum ))
    }
    
    class func makeSquaredPerm(_ lst:Permutation) -> PermutationShape {
        let n = lst.count
        return ( lst.flatMap { (y) -> [Int] in lst.map{ $0 + y * n - n - 1 } } )
    }
}


protocol P4Permutation {
    var  pnum:PermutationNumber!  { get set }
    func getPerm4()   -> Permutation
    func getPerm4x4() -> PermutationShape
    
   // init(pnum:PermutationNumber)
}

protocol P4PermutationCubes : P4Permutation {
    func getInversionSet()  -> InversionSet
    func getStepwiseMoves() -> StepwiseMoveList
}

extension P4Permutation {
    func getPerm4() -> Permutation {
        return P4.getPermutation(pnum)
    }
    func getPerm4x4() -> PermutationShape {
        return P4.makeSquaredPerm(getPerm4())
    }
}

extension P4PermutationCubes {
    func getInversionSet() -> InversionSet {
        return P4.getInversionSet(pnum)
    }
    func getStepwiseMoves() -> StepwiseMoveList {
        return P4.getStepwiseMoves(pnum)
    }
}



typealias P4GroupElement = Int

extension P4GroupElement {
    var pnum: P4GroupElement { return self % 24 }
    
}





class P4Model {
    
    var inversionSet     : InversionSet!
    var stepwiseMoves    : StepwiseMoveList!
    var permutation      : Permutation!
    var permutationShape : PermutationShape!

    
    var pnum:PermutationNumber    = 0 {
        didSet {
            self.pnum = pnum%24
            self.permutation      = P4.getPermutation(pnum)
            self.inversionSet     = P4.getInversionSet(pnum)
            self.stepwiseMoves    = P4.getStepwiseMoves(pnum)
            self.permutationShape = P4.make4x4Perm(pnum)
        }
    }
    
    init(pnum:PermutationNumber = 0) {
        self.pnum        = pnum%24
        permutation      = P4.getPermutation(pnum)
        inversionSet     = P4.getInversionSet(pnum)
        stepwiseMoves    = P4.getStepwiseMoves(pnum)
        permutationShape = P4.make4x4Perm(pnum)
    }
    
    func get4x4Perm(_ pnum: PermutationNumber) -> PermutationShape {
        return PermutationShape(P4.make4x4Perm(pnum)[0...15])
    }
    
    struct S4_frame {
        var pnum:PermutationNumber         = 0
        var permutation:Permutation        = [0, 0, 0, 0]
        var inversionSet:InversionSet      = [0, 0, 0, 0, 0, 0]
        var stepwiseMoves:StepwiseMoveList = [1, 2, 6, -1, -1, -1] // default values not really needed, just here as an example
    }
    
    func getFrame(_ p: Int) -> S4_frame {
        var frame = S4_frame()
        let pnum:PermutationNumber = p % 24
        frame.pnum                 = pnum
        frame.permutation          = P4.getPermutation(pnum)
        frame.inversionSet         = P4.getInversionSet(pnum)
        frame.stepwiseMoves        = P4.getStepwiseMoves(pnum)
        return frame
    }
    
    func getPermutation(_ pnum: PermutationNumber) -> Permutation {
        return P4.getPermutation(pnum)
    }

}


// notes: model Lie Algebras, Coxeter Groups, Reflection Groups, Quaternions, and other structures within "Poiesis & Enchantment in Topological Matter", "The Topos of Music", and others.
