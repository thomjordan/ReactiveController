//
//  Document.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa


class Document: NSDocument {
    
    let theEncoder = JSONEncoder() // PropertyListEncoder()
    let theDecoder = JSONDecoder() // PropertyListDecoder()
    let designSpaceWindowController = DesignSpaceWindowController()
    var loadedWorkpageCollection : WorkpageModelsCollection? = nil
    var app : App!

    override init() { super.init() }
    override func awakeFromNib() { designSpaceWindowController.showWindow(nil) }
    
  //  override class var autosavesInPlace  : Bool { return true }
  //  override class var preservesVersions : Bool { return true }
    
    override func makeWindowControllers() {
        self.addWindowController( designSpaceWindowController )
        beginApp(wc: designSpaceWindowController)
    }
    
    func beginApp(wc: DesignSpaceWindowController) {
        app = App(wc: designSpaceWindowController, loadedModel: loadedWorkpageCollection)
    }
    
    
    override func data(ofType typeName: String) throws -> Data {
        
        var data : Data? = nil
        
        if let workpages = app.workpageModels {
            data = try? theEncoder.encode( workpages )
        }
        
        guard let theData = data else {
            // printLog("Document:data -- error when saving")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // printLog("Document:data saving now...")
        
        return theData
    }

    
    override func read(from data: Data, ofType typeName: String) throws {
    //*
        guard let workpages = try? theDecoder.decode( WorkpageModelsCollection.self, from: data ) else {
            // printLog("Document:read -- Decoding unsuccessful.")
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        
        // printLog("Document:read ~~ Decoding was successful ! ~~ ")
        
        self.loadedWorkpageCollection = workpages
   // */
    }
    
    override func close() {
        app.shutdown()
        super.close()
    }
    
}


