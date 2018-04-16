//
//  ScriptEditorViewController.swift
//  ReactiveController
//
//  Created by Thom Jordan on 5/15/17.
//  Copyright © 2017 Thom Jordan. All rights reserved.
//

//
//  ScriptEditorViewController.swift
//  ReactiveControlsApp
//
//  Created by Thom Jordan on 2/11/16.
//  Copyright © 2016 Thom Jordan. All rights reserved.
//


import Cocoa
import LiveCodeEditor


@objc class ScriptEditorViewController: NSViewController, NSTextViewDelegate {
    
    var theTextView : NSTextView?
    
    let editor = CodeEditorManager()
    
    var codeModel : CodeScriptModel? {
        didSet { updateCodeViewFromModel() }
    }
    
    let textCellBGColor   = NSColor(calibratedRed: 0.72, green: 0.73, blue: 0.737, alpha: 1.0)
    
    let textCellTextColor = NSColor(calibratedRed: 0.75, green: 0.75, blue: 0.75, alpha: 1)
    
    
    @IBOutlet var codeView: NSView!
    
    @IBOutlet var miniConsoleDisplay: NSTextField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        editor.setDelegate(self)
        
        editor.useSyntax("CoffeeScript")
        
        editor.embed(in: codeView)
        
        editor.setSyntaxColoringDelegate(self)
        
        updateView()
    }
    
    func updateCodeViewFromModel() {
        
        if let cmodel = codeModel {
            
            copyScriptIntoCodeView( cmodel.code.value )
        }
            
        else { copyScriptIntoCodeView("") }
    }
    
   
    func copyScriptIntoCodeView(_ code: String) {
        
        clearConsoleMessage()
        
        clearCodeView()
        
        editor.setText(code)
        
        refreshCodeView()
        
        runScript()
    }
    
    
    func clearCodeView() {
        
        editor.setText("")
        
        refreshCodeView()
    }
    
    
    func textDidChange(_ notification: Notification) {
        
        printLog("ScriptEditorViewController: textDidChange()")
        
        updateCodeModelWithNewText() 
        
        runScript()
    }
    
    
    func updateConsoleMessage(to msg: String) {
        
        miniConsoleDisplay.stringValue = msg
        
        refreshConsoleDisplay()
    }
    
    func clearConsoleMessage() {
        
        updateConsoleMessage(to: "")
    }
    
    func runScript() {
        
        // printLog("ScriptEditorVC: runScript()") 
        
        if let runnableAgent = codeModel?.runnableJSAgent {
            
            runnableAgent.runScript()
            
            updateConsoleMessage(to: runnableAgent.getErrorMessage())
        }
    }
    
    func updateCodeModelWithNewText() {
        
        codeModel?.code.value = editor.getText()
        
        App.shared.documentChanged()
    }
    
    func refreshCodeView() {
        DispatchQueue.main.async { [weak self] in
            self?.codeView.needsDisplay = true
        }
    }
    
    func refreshConsoleDisplay() {
        DispatchQueue.main.async { [weak self] in
            self?.miniConsoleDisplay.needsDisplay = true
        }
    }
    
//    func updateView() {
//        DispatchQueue.main.async { [weak self] in
//            self?.view.needsDisplay = true
//        }
//    }
}


