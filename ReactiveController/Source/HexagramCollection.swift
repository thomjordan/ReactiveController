//
//  HexagramCollection.swift
//  ReactiveController
//
//  Created by Thom Jordan on 7/31/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond

struct HexagramCollection : ComponentKind {
    
    let name: String! = "HexagramCollection"
    
    let kernelPrototype : KernelModelType? = BezierKnobKernelModel()
}

extension HexagramCollection {
    
    func configure(_ model: ComponentModel) {
        
        // let kernel = (model.kernel ?? HexagramCollectionKernelModel()) as! HexagramCollectionKernelModel
    }
    
}


final class HexagramCollectionKernelModel : KernelModelType {
    
    var rowIndex : KernelParameter<StringCoder> = KernelParameter("rowIndex", "")
    var seqIndex : KernelParameter<StringCoder> = KernelParameter("seqIndex", "")
    
    required init() {
        self.rowIndex  = KernelParameter("rowIndex", "")
        self.seqIndex  = KernelParameter("seqIndex", "")
        rowIndex.value = EventsWriting.intPairAsBoundedInt(k: 0, x: 8)
        seqIndex.value = EventsWriting.intPairAsBoundedInt(k: 0, x: 8)
    }
    
    func publish(to view: ComponentContentView) {
        rowIndex.syncView( view )
        seqIndex.syncView( view )
    }
    
    enum CodingKeys : String, CodingKey {
        case rowIdx, seqIdx
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        self.rowIndex = KernelParameter("rowIndex", "")
        rowIndex.value = try vals.decode( StringCoder.self, forKey: .rowIdx )
        self.seqIndex = KernelParameter("seqIndex", "")
        seqIndex.value = try vals.decode( StringCoder.self, forKey: .seqIdx )
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( rowIndex.value, forKey: .rowIdx )
        try bin.encode( seqIndex.value, forKey: .seqIdx )
    }
}

enum HexagramIndexingType {
    
    case hex, tri, bi, yao
}


