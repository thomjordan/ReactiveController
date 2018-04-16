//
//  ComponentBuilderMixin.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/31/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation

protocol ComponentBuilderMixin {  }


extension ComponentBuilderMixin where Self: PagesCollectable & IDGeneratable {
    
    func addComponent(_ kind: ComponentKind) {
        
        let newID = generateNewID()
        
        let model = ComponentModel( kind, id: newID )
        
        let pagenum = selectedPageNum.value
        
        guard let currPage = thePages[pagenum] as? WorkpageModel else { return } 
        
        currPage.components.append( model )
        
        documentChanged()
        
        // TODO: change to a store + reducer architecture
        //then incorporate undo/redo and event history, etc.
        
        // printLog("ComponentBuilderMixin: addComponent(): adding a \(kind) component model to Workpage #\(pagenum).")
    }
}
