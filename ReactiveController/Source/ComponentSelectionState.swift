//
//  ComponentSelectionState.swift
//  ReactiveController
//
//  Created by Thom Jordan on 6/13/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Foundation


enum MultiState {
    
    case selected
    
    case specialSelected
    
    case bothSelected
    
    case noneSelected
    
}

struct ComponentSelectionState {
    
    var isSelected        : Bool = false
    
    var isSpecialSelected : Bool = false
    
    func getMultiState() -> MultiState {
        
        var mstate : MultiState = .noneSelected
        
        if isSelected {
            
            if isSpecialSelected { mstate = .bothSelected }
                
            else { mstate = .selected }
        }
            
        else {
            
            if isSpecialSelected { mstate = .specialSelected }
                
            else { mstate = .noneSelected }
        }
        
        return mstate
    }
}
