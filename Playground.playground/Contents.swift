
import Cocoa
import ReactiveKit
import Bond
//import LiveCodeEditor

let p1 = Property(1)
p1.value
p1.next(75)
p1.value


var thePages  : MutableObservableArray<Int> = MutableObservableArray( [] )

//let editor = CodeEditorManager()
