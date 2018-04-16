//
//  ComponentModel.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/23/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


public class ComponentModel : Codable {
    
    var bag: DisposeBag = DisposeBag()
    
    var kind  : ComponentKind!
    
    var idNum : Int!
    
    var header = ComponentHeader()
    
    var kernel  : KernelModelType?
    
    var codeScript : CodeScriptModel = CodeScriptModel()
    
    var refresh : ( () -> () )? 
    
    var inputs  : InputPointModels  = InputPointModels()
    
    var outputs : OutputPointModels = OutputPointModels()
    
    var reactor : ComponentReactor! 
    
    var selectionState : Property<ComponentSelectionState> = Property(ComponentSelectionState())
    
    var frame : NSRect? { return header.frame }
    
    var isBrandNewConnectionSource : Bool = false
    
    var wasDragged   : Bool = false
    
    var wasSelected  : Bool = false
    
    var inwardConnections  = Array<ConnectionModel>()
    
    init(_ kind: ComponentKind, id: Int) {
        
        self.kind  = kind
        
        self.idNum = id
        
        self.inwardConnections = Array<ConnectionModel>()
        
        self.kind.configure(self)
    }
    
    func configure() { self.kind.configure(self) }
    
    enum CodingKeys : String, CodingKey {
        case kindname
        case idnum
        case frame
        case origin 
        case kernel
        case selected
        case altselected
        case activeInputConnections
        case code
    }
    
    required public init(from decoder: Decoder) throws {
        
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        
        let kname = try vals.decode( String.self, forKey: .kindname )
        
        
        self.kind = getComponentKind(of: kname)
        
        self.idNum = try vals.decode( Int.self, forKey: .idnum )
        
        self.header = ComponentHeader()
        self.header.frame  = try vals.decode( NSRect.self,  forKey: .frame  )
        self.header.origin = try vals.decode( NSPoint.self, forKey: .origin )
        
        self.kernel = self.kind.kernelPrototype?.decodeDynamicKernelType(vals)
        
        // if let k = self.kernel { printLog("~/~/~ ComponentModel:init(from: decoder) has successfully decoded kernel model \(k)") }
        
        let selstate = try vals.decode( Bool.self, forKey: .selected )
        let altstate = try vals.decode( Bool.self, forKey: .altselected )
        
        self.selectionState.value = ComponentSelectionState( isSelected: selstate, isSpecialSelected: altstate )
        
        self.inwardConnections = try vals.decode( Array<ConnectionModel>.self, forKey: .activeInputConnections )
        
        self.codeScript = try vals.decode( CodeScriptModel.self, forKey: .code )
        
        self.kind.configure(self)
    }
    
    
    public func encode(to encoder: Encoder) throws {
        
        var bin = encoder.container(keyedBy: CodingKeys.self)
        
        try bin.encode( kind.name, forKey: .kindname )
        try bin.encode( idNum, forKey: .idnum)
        try bin.encode( header.frame, forKey: .frame)
        try bin.encode( header.origin, forKey: .origin)
        
        if let kmodel = self.kernel {
            kmodel.encodeDynamicKernelType(bin)
        }
        
        try bin.encode( selectionState.value.isSelected, forKey: .selected)
        try bin.encode( selectionState.value.isSpecialSelected, forKey: .altselected)
        
        try bin.encode( inwardConnections, forKey: .activeInputConnections )
        try bin.encode( codeScript, forKey: .code )
    }
}


protocol ComponentKind {

    var name: String! { get }
    
    var kernelPrototype : KernelModelType? { get }
    
    func configure(_ model: ComponentModel)
}

protocol ComponentHeaderType {
    
    var frame  : NSRect  { get set }
    
    var origin : NSPoint { get set }
    
    func getFrameAtOrigin() -> NSRect
}

class ComponentHeader : ComponentHeaderType {
    
    var frame  : NSRect = NSMakeRect( 0, 0, 100, 62 )
    
    var origin : NSPoint = NSMakePoint( 10, 10 )
    
    func getFrameAtOrigin() -> NSRect { return NSMakeRect( origin.x, origin.y, frame.width, frame.height ) }
    
    required init() { }
}


extension ComponentModel {
    
    func deleteIncomingConnectionByInputNumber(_ inputNum: Int) {
        
        var deletionIndexes : [Int] = []
        
        for (index, connectionModel) in inwardConnections.enumerated() {
            
            if connectionModel.targetInputNum == inputNum {
                
                deletionIndexes.append(index)
            }
        }
        
        for delIndex in deletionIndexes.sorted(by: >) {
            inwardConnections.remove(at: delIndex)
        }
    }
}


extension ComponentModel {  // selection state
    
    var isSelected        : Bool { return selectionState.value.isSelected        }
    var isSpecialSelected : Bool { return selectionState.value.isSpecialSelected }
    
    func select() {
        
        let currstate = selectionState
        
        let newstate = ComponentSelectionState(isSelected: true, isSpecialSelected: currstate.value.isSpecialSelected)
        
        selectionState.value = newstate
    }
    
    func deselect() {
        
        let currstate = selectionState
        
        let newstate = ComponentSelectionState(isSelected: false, isSpecialSelected: currstate.value.isSpecialSelected)
        
        selectionState.value = newstate
    }
    
    func specialSelect() {
        
        let currstate = selectionState
        
        let newstate = ComponentSelectionState(isSelected: currstate.value.isSelected, isSpecialSelected: true)
        
        selectionState.value = newstate
    }
    
    func specialDeselect() {
        
        let currstate = selectionState
        
        let newstate = ComponentSelectionState(isSelected: currstate.value.isSelected, isSpecialSelected: false)
        
        selectionState.value = newstate
    }
}


extension ComponentModel {
    
    // inner class -- AutoCoder
    
    class AutoCoder<ObjectType: KernelModelType> {
        
        func encodeDynamicKernelType(_ container: KeyedEncodingContainer<ComponentModel.CodingKeys>, _ objectType: ObjectType) {
            var theContainer = container
            printLog("Encoding \(objectType) via \(ObjectType.self)")
            do { try theContainer.encode( objectType, forKey: .kernel ) }
            catch { }
        }
        
        func decodeDynamicKernelType(_ container: KeyedDecodingContainer<ComponentModel.CodingKeys>, _ objectType: ObjectType) -> KernelModelType? {
            let decoded = try? container.decode( type(of: objectType).self, forKey: .kernel )
            if decoded != nil { printLog(" ~|~|~ AutoCoder successfully decoded kernelModel as \( type(of: objectType).self )") }
            return decoded
        }
    }
}

extension KernelModelType {
    
    // ComponentModel.AutoCoder<Self> provides a concrete type for the existential type.
    
    func encodeDynamicKernelType(_ container: KeyedEncodingContainer<ComponentModel.CodingKeys>) {
        let theCoder = ComponentModel.AutoCoder<Self>()
        theCoder.encodeDynamicKernelType(container, self)
    }
    func decodeDynamicKernelType(_ container: KeyedDecodingContainer<ComponentModel.CodingKeys>) -> KernelModelType? {
        var decoded : KernelModelType?
        let theCoder = ComponentModel.AutoCoder<Self>()
        decoded = theCoder.decodeDynamicKernelType(container, self)
        if let d = decoded { return d }
        return nil
    }
}




















