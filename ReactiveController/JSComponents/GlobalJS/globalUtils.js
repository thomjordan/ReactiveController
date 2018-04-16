
var can, ctx, canX, canY, mouseIsDown = 0;

// mouse event hooks for local customization by user:

function mouseUp()   { } 
function mouseDown() { }
function mouseXY()   { } // required for detecting mouse-overs

function mouseUpEvent() {
    mouseIsDown = 0;
    mouseXYEvent();
    mouseUp();
}

function mouseDownEvent() {
    mouseIsDown = 1;
    mouseXYEvent();
    mouseDown();
}

function mouseXYEvent(e) {
    if (!e)
        var e = event;
    canX = e.pageX - can.offsetLeft;
    canY = e.pageY - can.offsetTop;
   // mouseXY(); // comment out for better performance if not otherwise optimized
}

function initCommonSetup() {
    can = document.getElementById("can");
    ctx = can.getContext("2d");
    
    can.addEventListener("mousedown", mouseDownEvent, false);
   // can.addEventListener("mousemove", mouseXYEvent, false); // comment out for better performance if not otherwise optimized
    document.body.addEventListener("mouseup", mouseUpEvent, false);
}


// function relayConfigureJSAgentMessage() {
//     if (inputTypes.length > 0) {
//         window.webkit.messageHandlers.defInputs.postMessage(inputTypes);
//     }
//    // if ((outputs.length == outputTypes.length) && (outputs.length > 0)) {
//    //     window.webkit.messageHandlers.defOutputs.postMessage(outputTypes);
//    // }
// }

// global utils
function constrainRange(val, bound=128) {  
    var limit = bound <= 0 ? 16 : bound;
    var result = val < 0 ? 0 : (val < limit ? val : limit-1);
    return result;
}


/* these might not be needed now..
var numIns = document.getElementById('numInputs');
numIns.setAttribute("onchange", "updateInputs(this.value); reload()");

function numberOfInputs(v) {
    numIns.value=v;
    numIns.dispatchEvent(new Event('change'));
}

var numOuts = document.getElementById('numOutputs');
numOuts.setAttribute("onchange", "updateOutputs(this.value); reload()");

function numberOfOutputs(v) {
    numOuts.value=v;
    numOuts.dispatchEvent(new Event('change'));
}
// numberOfOutputs(2);
*/
