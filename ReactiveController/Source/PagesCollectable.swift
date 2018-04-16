//
//  PagesCollectable.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/20/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

import Cocoa
import ReactiveKit
import Bond


protocol Selectable : class {
    
    var isSelected : Bool { get set }
}

extension Selectable {
    
    func select()   { isSelected = true  }
    
    func deselect() { isSelected = false }
}



protocol PagesCollectable : class {
    
    associatedtype PageType : Selectable
    
    var  selectedPageNum : Property<Int> { get set }
    
    var  thePages : MutableObservableArray<PageType> { get set }
    
    func addPage(_ page: PageType)
    
    func insertPage(_ page: PageType, at index: Int)
    
    func removePage(at index: Int) -> PageType?
    
    func selectPage(at index: Int)
    
    func getSelected() -> PageType?
    
    func setSelected(_ newpage: PageType)
}



extension PagesCollectable {
    
    var selectedPage : PageType? {
        
        var result : PageType? = nil
        
        let pagenum = selectedPageNum.value
        
        if pagenum < thePages.count {
            
            result = thePages[pagenum]
        }
        
        return result
    }
    
    var pageCount : Int { return thePages.count }
    
    
    func addPage(_ page: PageType) {
        
        insertPage( page, at: thePages.count )
    }
    
    
    func insertPage(_ page: PageType, at index: Int) {
        
        guard thePages.count >= 0 && index <= thePages.count else { return }
        
        thePages.insert( page, at: index)
    }
    
    
    func removePage(at index: Int) -> PageType? {
        
        var aPage : PageType? = nil
        
        guard thePages.count > 1 && index < thePages.count else { return nil }
        
        aPage = thePages[index]
        
        thePages.remove(at:index)
        
        return aPage
    }
    
    
    func selectPage(at index: Int) {
        
        guard thePages.count >= 1 && index < thePages.count else { return }
        
        deselectAllPages()
        
        selectedPageNum.value = index
        
        selectedPage?.isSelected = true
    }
    
    
    func getSelected() -> PageType? {
        
        var result : PageType? = nil
        
        let index = selectedPageNum.value
        
        if index < thePages.count {
            
            result = thePages[index]
        }
        
        return result
    }
    
    
    func setSelected(_ newpage: PageType) {
        
        let index = selectedPageNum.value
        
        if index <= thePages.count {
            
            thePages[index] = newpage
        }
    }
    
    func deselectAllPages() {
        
        for page in thePages.array {
            
            page.deselect()
        }
    }
}


