//
//  StepPattern.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/6/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


struct StepPattern : ComponentKind {
    
    let name: String! = "StepPattern"
    
    let kernelPrototype : KernelModelType? = StepPatternKernelModel()
}


extension StepPattern {
    
    func configure(_ model: ComponentModel) {
        
        // printLog("configure() : \(self)")
        
        let kernel = (model.kernel ?? StepPatternKernelModel()) as! StepPatternKernelModel
        
        model.kernel   = kernel
        let reaktor    = StepPatternComponentReactor( model )
        reaktor.updateParams(0)
        model.reactor  = reaktor
        
        model.inputs.addNew( ["STRINGCODE", "STRINGCODE"] )
        model.outputs.addNew(["STRINGCODE", "STRINGCODE"] )
        
        model.reactor.establishProcess = configProcess( model.reactor!.inputs,
                                                        model.reactor!.outputs,
                                                        model.kernel  as! StepPatternKernelModel,
                                                        model.reactor as! StepPatternComponentReactor )
        
        reaktor.uiView = StepPatternUIView( reaktor )
        reaktor.restartObservers() // necessary for when a StepPattern is used without inputs
        
        model.reactor.observeSelectionStatus()
    }
    
    private func configProcess(_ input   : InputPointReactors,
                               _ output  : OutputPointReactors,
                               _ kernel  : StepPatternKernelModel,
                               _ reaktor : StepPatternComponentReactor) -> () -> ()  {
        
        return {
            
            func reconfigProcess() {
                
                input.clean() ; output.clean()
                
                guard let output0 = output[0], let output1 = output[1] else { return }
                
                guard let theView = reaktor.uiView as? StepPatternUIView else {
                    
                    printLog("StepPattern.reconfigProcess() DID NOT PASS guard successfully.")
                    
                    return }
                
                printLog("StepPattern.reconfigProcess() passed guard successfully.")
                
                input[0]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let incomingBoundedInt = msg.intWithBound() {
                            
                            var outgoingBoundedInt : String = ""
                            
                            if incomingBoundedInt.x == 4 {
                                
                                outgoingBoundedInt = EventsWriting.intPairAsBoundedInt(k: (incomingBoundedInt.k)%4, x: 4) }
                                
                            else { outgoingBoundedInt = EventsWriting.intPairAsBoundedInt(k: (incomingBoundedInt.k)%24, x: 24) }
                            
                            kernel.inputnum.value = outgoingBoundedInt
                            
                            theView.updateView()
                            
                            // printLog("k: \(msg[0].k)  n: \(msg[0].n)")
                        }
                    }
                }
                
                input[1]?.model.assign { (c) in c
                    
                    .filter  { $0.count >= 1 }
                    
                    .observeNext { msg in
                        
                        if let incomingBoundedInt = msg.intWithBound() {
                            
                            // refactor '16' into an abstraction that can easily be used with other lengths of stepPatterns
                            let outgoingBoundedInt : StringCoder = EventsWriting.intPairAsBoundedInt(k: (incomingBoundedInt.k)%16, x: 16)
                            
                            kernel.stepIndex.value = outgoingBoundedInt
                            
                            theView.updateView()
                        }
                    }
                }
                
                /*
                reaktor.permutedSteps
                    
                    .observeNext { steps in
                    
                    guard steps.count >= 1 else { return }
                    
                    let bound = steps.count
                    
                    let stepsWithBound = EventsWriting.intStepsWithBound(steps: steps, x: bound)
                    
                    output[0]?.setStringCode( stepsWithBound )
                    
                }.dispose(in: output0.bag)
                
                
                reaktor.stepIndex
                    
                    .observeNext { stepIdx in
                    
                    guard let indexWithBound = stepIdx.intWithBound(), indexWithBound.k >= 0 else { return }
                    
                    let stepPattern = reaktor.permutedSteps.value
                    
                    guard stepPattern.count > 0 else { return }
                    
                    let index = indexWithBound.k % stepPattern.count
                    
                    let outputValue = stepPattern[index]
                    
                    let intValueWithBound = EventsWriting.intPairAsBoundedInt(k: outputValue, x: indexWithBound.x )
                    
                    output[1]?.setStringCode(intValueWithBound)
                    
                }.dispose(in: output1.bag)
                */ 
                
                reaktor.restartObservers()
            }
            
            input[0]?.setRefresh { reconfigProcess() }
            input[1]?.setRefresh { reconfigProcess() }
        }
    
    }
}



final class StepPatternComponentReactor : ComponentReactor {
    
    var bags = DisposeBagStore()
    
    weak var model : ComponentModel!
    
    var inputs  : InputPointReactors!
    
    var outputs : OutputPointReactors!
    
    var establishProcess : (() -> ())?
    
    var establishOutputs : (() -> ())?
    
    var uiView : ComponentContentView?
    
    var kernel : StepPatternKernelModel { return model.kernel as! StepPatternKernelModel }
    
    var stepIndex : Property<StringCoder> { return kernel.stepIndex.property }
    
    var selectedStep : Int? {
        guard let stepIndexVal = stepIndex.value.intWithBound()?.k else { return nil }
        // refactor '16' into an abstraction that can easily be used with other lengths of stepPatterns
        return stepIndexVal % 16
    }
    
    var permutedSteps : Property<PermutationShape> = Property( P4.make4x4Perm(0) )
    var stepwiseMoves : StepwiseMoveList = P4.getStepwiseMoves(0)
    
    var cubeStates    : [P4CubeState] = []
    
   // init() { }
    
    func parseInputAndProcess(_ boundedInt : (k: Int, x: Int)) {
        if boundedInt.x < 24 {
            let index = boundedInt.x % 4
            switch index {
            case 0: updateParams(kernel.yangpnum)
            case 1: updateParams(kernel.prevpnum)
            case 2: updateParams(kernel.yinpnum)
            default: updateParams(kernel.currpnum)
            }
        }
        else { updateParams( boundedInt.k % 24 ) }
    }
    
    func updateParams(_ pn:PermutationNumber = 0) {
        let inversionSet_  = P4.getInversionSet(pn)
        let stepwiseMoves_ = P4.getStepwiseMoves(pn)
        
        if pn != kernel.currpnum {
            let yangyinnums = stepwiseMoves_.filter { $0 != -1 && $0 != kernel.currpnum }.sorted()
            guard yangyinnums.count >= 2 else { return }
            kernel.yangpnum = yangyinnums[0]
            kernel.prevpnum = kernel.currpnum
            kernel.yinpnum  = yangyinnums[1]
            kernel.currpnum = pn
            printLog("StepPattern:updateParams: \(kernel.yangpnum) \(kernel.prevpnum) \(kernel.yinpnum) \(kernel.currpnum) : (yangpnum, prevpnum, yinpnum, currpnum)")
        }
        
        self.cubeStates          = calc4WayCubeColorState( stepwiseMoves_, inversionSet_ )
        self.stepwiseMoves       = stepwiseMoves_
        self.permutedSteps.value = P4.make4x4Perm(pn)
        
        printLog("StepPatternComponentReactor:updateParams(val) called with val = \(pn)")
    }
    
    func restartObservers() {
        
        guard let spParamsBag = bags.makeNew("StepPatternParams") else { return }
        
        let kernel = model.kernel as! StepPatternKernelModel
        
        kernel.inputnum.property
            
            .observeNext { [weak self] pval in
            
            if let boundedInt = pval.intWithBound() {
                
                self?.parseInputAndProcess( boundedInt )
            }
            
        }.dispose(in: spParamsBag)
        
        guard let theView = self.uiView as? StepPatternUIView else {
            
            printLog("StepPatternComponentReactor:restartObservers() DID NOT PASS guard successfully.")
            
            return }
        
        printLog("StepPatternComponentReactor:restartObservers() passed guard successfully.")
        
        
        self.permutedSteps
            
            .observeNext { [weak self] steps in
            
                printLog("StepPatternComponentReactor:restartObservers() permutedSteps.observeNxt(steps) called with steps = \(steps)")
                
                
                
                guard steps.count >= 1 else { return }
                
                let bound = steps.count
                
                let stepsWithBound = EventsWriting.intStepsWithBound(steps: steps, x: bound)
                
                self?.outputs[0]?.setStringCode( stepsWithBound )
                
                
            
                let currStepIndex: Int = self?.selectedStep ?? 0
            
                theView.stepView.updateDesign( steps, currStepIndex )
            
                theView.updateView()
            
            }.dispose(in: spParamsBag)
        
        
        
        self.stepIndex
            
            .observeNext { [weak self] stepIdx in
            
                printLog("StepPatternComponentReactor:restartObservers() kernel.stepIndex.property.observeNxt(steps) called with steps = \(stepIdx)")
                
                
                
                guard let indexWithBound = stepIdx.intWithBound(), indexWithBound.k >= 0 else { return }
                
                guard let stepPattern = self?.permutedSteps.value else { return }
                
                guard stepPattern.count > 0 else { return }
                
                let index = indexWithBound.k % stepPattern.count
                
                let outputValue = stepPattern[index]
                
                let intValueWithBound = EventsWriting.intPairAsBoundedInt(k: outputValue, x: indexWithBound.x )
                
                self?.outputs[1]?.setStringCode(intValueWithBound)
                
                
            
                let theStepPattern: [Int] = self?.permutedSteps.value ?? [Int](0..<16)
                let currStepIndex:   Int  = stepIdx.intWithBound()?.k ?? 0
            
                theView.stepView.updateDesign( theStepPattern, currStepIndex )
            
                theView.updateView()
            
            }.dispose(in: spParamsBag)
    }
    
//    func initStepPatternParamsObserverBag() -> DisposeBag? { return bags.makeNew("StepPatternParams") }
    
    func close() { disposeAll() }
    
    // HANDLE INCOMING EVENTS SENT FROM VIEW (WHICH CUBE WAS CLICKED)
    
    func handleCubeSelection(_ cubenum: Int) {
        
        let kernel = model.kernel as! StepPatternKernelModel
        
        let newPermNum = stepwiseMoves[cubenum]
        
        // printLog("handleCubeSelection(): nextMove is: \(newPermNum)")
        
        if newPermNum != -1 {
            kernel.inputnum.value = EventsWriting.intPairAsBoundedInt(k: Int(newPermNum), x: 24)
        }
            
        else { printLog("ERROR: cube is inactive (the view should show this)") }
    }
    
    
    func calc4WayCubeColorState(_ moves: StepwiseMoveList, _ inversions: InversionSet) -> [P4CubeState] {
        
        // returns a length-6 vector denoting 6-cube coloring state
        //  -1: yang | 0: yin | 1: chyang | 2: chyin
        
        var v:[Int] = [ 0, 0, 0, 0, 0, 0 ]
        
        for i in 0..<6 {
            if moves[i] != 0 {
                v[i] = signToTrival( moves[i] ) + inversions[i]
            } else {
                v[i] = 1 + ( inversions[i] )
            }
        }
        
        let rv = v.map { P4CubeState.gen( $0 ) }
        
        // printLog("4-WAY COLOR KEY is: [ \(rv[0]), \(rv[1]), \(rv[2]), \(rv[3]), \(rv[4]), \(rv[5]) ]")
        return rv
    }
    
    func interpretMouseUp(_ event: MouseUpEvent) {
        printLog("StepPatternComponentReactor:interpretMouseUp() called.")
        guard let theView = uiView as? StepPatternUIView else { return }
        theView.cubeView.interpretMouseUp(event)
    }
}


final class StepPatternKernelModel : KernelModelType {
    
    var inputnum : KernelParameter<StringCoder> = KernelParameter("permutationNumber", EventsWriting.intPairAsBoundedInt(k: 0, x: 24))
    
    var stepIndex : KernelParameter<StringCoder> = KernelParameter("stepIndex", EventsWriting.intPairAsBoundedInt(k: 0, x: 16))
    
    // default starting values corresponding to the normal form permutation (0)
    var yangpnum : Int = 1
    var prevpnum : Int = 2
    var yinpnum  : Int = 6
    var currpnum : Int = 0
    
    required init() {}
    
    func publish(to view: ComponentContentView) { }
    
    enum CodingKeys : String, CodingKey {
        case inputnum, stepIndex, yangpnum, prevpnum, yinpnum, currpnum
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        yangpnum = try vals.decode( Int.self, forKey: .yangpnum)
        prevpnum = try vals.decode( Int.self, forKey: .prevpnum)
        yinpnum  = try vals.decode( Int.self, forKey: .yinpnum )
        currpnum = try vals.decode( Int.self, forKey: .currpnum)
        inputnum.value = try vals.decode( StringCoder.self, forKey: .inputnum)
        stepIndex.value = try vals.decode( StringCoder.self, forKey: .stepIndex)
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( inputnum.value,  forKey: .inputnum  )
        try bin.encode( stepIndex.value, forKey: .stepIndex )
        try bin.encode( yangpnum, forKey: .yangpnum )
        try bin.encode( prevpnum, forKey: .prevpnum )
        try bin.encode( yinpnum,  forKey: .yinpnum  )
        try bin.encode( currpnum, forKey: .currpnum )
        
    }
}


final class StepPatternUIView : ComponentContentView {
    
    weak var kernel  : StepPatternKernelModel!
    weak var reactor : StepPatternComponentReactor!
    
    var stepView : StepPatternView!
    var cubeView : P4PermutationCubesView!
    
    init(_ reaktor: StepPatternComponentReactor) {
        
        super.init(width: 372, height: 88)
        
        self.reactor = reaktor
        
        let (leftFrame, rightFrame) = calcSplitFrameHorizontal(self.frame, leftRatio: ( 1, 3 ))
        
        self.cubeView = P4PermutationCubesView(frame: leftFrame, reaktor: reaktor)
        self.stepView = StepPatternView(frame: rightFrame, initialSteps: reaktor.permutedSteps.value)
        
        addSubview(cubeView)
        addSubview(stepView)
    }
    
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func updateView() {
        DispatchQueue.main.async { [weak self] in
            self?.cubeView.needsDisplay = true
            self?.stepView.needsDisplay = true
            self?.needsDisplay = true
        }
    }
}
