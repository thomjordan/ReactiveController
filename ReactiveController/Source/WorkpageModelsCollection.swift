//
//  WorkpageModelsCollection.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/20/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol IDGeneratable {
    func generateNewID() -> Int
}


class WorkpageModelsCollection : PagesCollectable, ComponentBuilderMixin, Codable {
    
    private(set) var loadedWorkpages   : [WorkpageModel]?
    private(set) var loadedSelection   : Int?
    private(set) var decodedDataLoader : ( () -> () )?
    
    var selectedPageNum : Property<Int> = Property(0)
    
    var thePages  : MutableObservableArray<WorkpageModel> = MutableObservableArray( [] )
    
    required init() { } 
    
    func observeCollection(with observer: @escaping (ObservableArrayEvent<WorkpageModel>) -> Void) -> Disposable {
        
        let disp = thePages
            
            .observeNext(with: observer)
        
        return disp
    }
    
    func observeSelection(with observer: @escaping (Int) -> Void) -> Disposable {
        
        let disp = selectedPageNum
            
            .observeNext(with: observer)
        
        return disp
    }
    
    enum CodingKeys : String, CodingKey {
        case pages
        case pagenum
    }
    
    required init(from decoder: Decoder) throws {
        let vals = try decoder.container(keyedBy: CodingKeys.self)
        
        self.thePages = MutableObservableArray( Array<WorkpageModel>() )
        self.selectedPageNum = Property(0)
        
        self.loadedWorkpages = try vals.decode( [WorkpageModel].self, forKey: .pages )
        self.loadedSelection = try vals.decode( Int.self, forKey: .pagenum )
        
        self.decodedDataLoader = {
            guard let wkpages = self.loadedWorkpages, let pagenum = self.loadedSelection else { return }
            for page in wkpages { self.addPage(page) }
            self.selectPage(at: pagenum)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var bin = encoder.container(keyedBy: CodingKeys.self)
        try bin.encode( thePages.array, forKey: .pages )
        try bin.encode( selectedPageNum.value, forKey: .pagenum )
    }
}


extension WorkpageModelsCollection : IDGeneratable {
    
    func generateNewID() -> Int {
        
        var newID : Int = 1
        
        var idnums : [Int] = []
        
        
        for pageSlot in thePages.array {
            
            for component in pageSlot.components.array {
                
                if let num = component.idNum { idnums.append( num ) }
            }
        }
        
        if idnums.count > 0 {
            
            newID = idnums.sorted().reversed()[0] + 1
        }
        
        return newID
    }

}

