//
//  GlobalDocumentController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 4/6/18.
//  Copyright © 2018 Thom Jordan. All rights reserved.
//

import Cocoa


//var docController : GlobalDocumentController { return GlobalDocumentController.shared as! GlobalDocumentController }
//
//
//
//class GlobalDocumentController: NSDocumentController {
//
//    var trailingCompletion: (() -> Void)?
//
//    override func beginOpenPanel(completionHandler: @escaping ([URL]?) -> Void) {
//
//        super.beginOpenPanel { urls in
//
//            if let _ = urls {
//                self.trailingCompletion = { completionHandler(urls) }
//                self.closeAllDocuments(withDelegate: nil, didCloseAllSelector: #selector(docController.proceedToOpen(_:)), contextInfo: nil)
//            }
//
//            else { completionHandler(urls) }
//
//        }
//    }
//
//    @objc func proceedToOpen(_ allDocsClosed: Bool) {
//
//        print(" ############## proceedToOpen() called --- allDocsClosed = \(allDocsClosed) ##############")
//
//        if allDocsClosed { trailingCompletion?() }
//    }
//}


//fileprivate extension Selector {
//    static let openSelected = #selector(docController.proceedToOpen(_:))
//}


class GlobalDocumentController: NSDocumentController {
    
    override func beginOpenPanel(completionHandler: @escaping ([URL]?) -> Void) {
        
        super.beginOpenPanel { urls in
            
            if let _ = urls {
                self.closeAllDocuments(withDelegate: nil, didCloseAllSelector: nil, contextInfo: nil)
            }
            
            completionHandler(urls)
        }
    }
    
    override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
        
        self.closeAllDocuments(withDelegate: nil, didCloseAllSelector: nil, contextInfo: nil)
        
        let newdoc = try! super.openUntitledDocumentAndDisplay(displayDocument)
        
        return newdoc
    }
}


