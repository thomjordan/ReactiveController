//
//  AppServices.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/4/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation


protocol AppServices {
    
    var allComponents   : [ComponentReactor] { get }

    
}


extension App : AppServices {
    
    var allComponents : [ComponentReactor] {
        
        let comps = workpageReactors?.thePages.array.flatMap { $0.currentComponents }
        
        let result : [ComponentReactor] = comps != nil ? comps! : []
        
        return result
    }
    
    
    func retrieveComponentByID(_ id: Int) -> ComponentReactor? {
        
        var result : ComponentReactor? = nil
        
        for component in allComponents {
            
            if let compModel = component.model {
                
                if compModel.idNum == id {
                    
                    result = component
                    
                    break
                }
            }
        }
        
        return result
    }
    
    
    func updateWorkpageView() {
        DispatchQueue.main.async { [weak self] in
            self?.workpageViews?.selectedPage?.needsDisplay = true
        }
    }
}
