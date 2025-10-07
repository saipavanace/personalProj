//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

/********************************************************************************
 
Utilities Library:  Shortcut functions for common ACHL tasks.
 
How to use it:
    
// 1. Require the library, and initialize it.  Please use the local varibale "u", so that
//    we can do search and replace in the future.  Note that this line must go inside your 
//    module's function declaration.

function my_achl_module() {

  var u = require("../../lib/src/utils.js").init(this);

// 2. Use it!

u.param ("my_param", "int", 1 4");       // Declare a parameter with (optional) 
// min & max
u.input("my_input", 8);                  // Declare an input port.
u.output("my_output");                   // Declare an output port.
u.outstate("the_out", 4, 0); // Declare a registered output port with resetval of 0
u.outstate4("the_out", "s_the_state", 4); // Declare an output port with 
// matching state.  The state gets 
// connected to the port automatically.

u.signal("my_sig", 8);
u.state("my_state", 6, 0);               // State declaration using default 
// clk & reset. The reset vector (decimal 
// or javascript hex notation) is 
// automatically set to the correct width.

********************************************************************************/

'use strict';
var memFunctions = require('@arteris/memgen').memCalc;

module.exports.init = function (mm, name){
  
    //-------------------------------------------------------------------------
    // Initialization Routine
    //-------------------------------------------------------------------------
    if (name != undefined) {
        var s = "=== "+name+" ";
        for (var i = 0; i < (60 - name.length); i++) {
            s += "=";
        }
    }
    
    // Define an empty function
    function o() {
    };

    // Create an (empty) object from the function.
    var u = Object.create(o);

    // Attachd the pass-edin module to it.
    u.m = mm;

    // Add the utils library as a member of the module (for convenience)
    u.m.u = u;

    //-------------------------------------------------------------------------
    // Utility Functions
    //-------------------------------------------------------------------------

    /************************************************************
     * 
     * 
     *
     */
    u.log = function(text) {
        var string = this.m.address+": "+text;
        this.m.info(string);
//        console.log(string);
    };


    u.logInfo = function(text) {
        var string = this.m.address+": "+text;
        this.m.info(string);
    };

    u.logWarning = function(text) {
        var string = this.m.address+": "+text;
        this.m.warning(string);
    };

    u.logError = function(text) {
        var string = this.m.address+": "+text;
        this.m.error(string);
    };

    u.die = function(text) {
        var e = new Error(text);
        console.log(e.stack);
        throw e;
    }

    /************************************************************
     * Define an input port.  Width is optional (defaults to 1)
     *
     * @arg {number} width - the width of the input port.  Width
     *                       is optional (defaults to 1).
     */
    u.input = function(name, width) {
        if(typeof width === "undefined") {
            width = 1;
        }
        this.m.definePort( {name: name, type: this.m.bit, size: width, direction: 'input' } );
    };
    
    /************************************************************
     * Define an output port.  Width is optional (defaults to 1)
     *
     * @arg {number} width - the width of the input port.  Width
     *                       is optional (defaults to 1).
     */
    u.output = function(name, width) {
        if(typeof width === "undefined") {
            width = 1;
        }
        this.m.definePort( {name: name, type: this.m.bit, size: width, direction: 'output' } );
    };

    /************************************************************
     * Declare a signal.
     *
     * @arg {string} name - the name of the signal.
     * @arg {number} width - the width of the input port.  Width
     *                       is optional (defaults to 1).
     */
    u.signal = function(name, width) {
        if(typeof width === "undefined") {
            width = 1;
        }
        if (width > 0) { // TODO: delete this if
            //        u.log("this.m.defineSig( {name: "+name+", type: this.m.bit, size: "+width+"} );");
            this.m.defineSig( {name: name, type: this.m.bit, size: width} );
        }
    };

    /************************************************************
     * Declare a "state" signal.  
     *
     * @arg {number} name  - the name of the state element.
     * @arg {number} width - the width of the state element.
     * @arg {number} resetvalue - the value to reset the state 
     *                        element to.  The reset value will
     *                        be correctly sized.  This is required.
     * @arg {boolean} nonresettable - if true, the designer is 
     *                        indicating that this flop does not 
     *                        need to be reset.  The end user may 
     *                        still elect to reset all flops, so a 
     *                        reset value is still required. 
     *                        This is optional.
     */
    u.state = function(name, width, resetvalue, nonresettable) {
        if (resetvalue == undefined) {
            u.log("Utils Error: State Definition: "+name+": reset value is required. ");
        }

        if (width == undefined) {
            u.log("Utils Error: State Definition: "+name+": width value is required. ");
        }

        var r = {name: 'reset_n', polarity: 'activeLow' };

        if (nonresettable != undefined) {
            if (nonresettable) {  
                // u.log("Utils Info: Non-resettable flop: "+name+". ");
                // r = {};  // TODO:  For now, this makes all flops resettable.
            }
        }

        this.m.defineState({clock: {name: 'clk', edge: 'risingEdge' }, reset: r},
        {name: name, type: this.m.bit, size: width, resetValue: resetvalue.toString().d(width)} );


    };

    /************************************************************
     * Declare a output port, and drive it by a state element.  
     * This emulates the verilog capability of having registers 
     * that are output ports.
     *
     * This is the old 4-argument version of this function.
     *
     * This declares both an output port and a state element of 
     * the same width, and drives the state element's value to 
     * the output port.
     *
     * @arg {string} portname - the name of the output port.
     * @arg {string} statename - the name of the state element.
     * @arg {number} width - width of the state element & output port.
     * @arg {number} resetvalue - the value to reset the state 
     *                            element to.  The reset value will
     *                            be correctly sized.
     */
    u.outstate4 = function(portname, statename, width, resetvalue) {

        this.m.statename = statename;
        this.m.portname = portname;

        this.m.definePort(
            {name: portname, type: this.m.bit, size: width, direction: 'output'} 
        );

        u.state(statename, width, resetvalue);

        this.m.always(function(){
            $this.portname$ = $this.statename$;
        });

    };

    /************************************************************
     * Declare a output port, and drive it by a state element.  
     * This emulates the verilog capability of having registers 
     * that are output ports.
     *
     * This declares a registered output port
     * without creating an intermediate name for the state element.
     *
     * @arg {string} portname - the name of the output port and state element.
     * @arg {number} width - width of the state element & output port.
     * @arg {number} resetvalue - the value to reset the state 
     *                            element to.  The reset value will
     *                            be correctly sized.
     */
    u.outstate = function(portname, width, resetvalue) {
        if (resetvalue == undefined) {
            u.log("Utils Error: OutState Definition: "+name+": reset value is required. ");
        }

        if (width == undefined) {
            u.log("Utils Error: OutState Definition: "+name+": width value is required. ");
        }

        var r = {name: 'reset_n', polarity: 'activeLow' };

        this.m.portname = portname;

        this.m.defineOutState(
            {clock: {name: 'clk', edge: 'risingEdge' }, reset: r},
            {name: portname, type: this.m.bit, size: width, resetValue: resetvalue.toString().d(width)} );
    };

    /************************************************************
     * Define a parameter.
     *
     * @arg {string} name - the name of the parameter.
     * @arg {string} type - the type of the parameter: bit, int, boolean, or string.
     * @arg {number} min  - the parameter's mimimum allowed value.
     * @arg {number} max  - the parameter's maximum allowed value.
     * @arg {number} pow2 - if set, the parameter must be a power of 2.
     * 
     * Notes:
     *    - min & max are optional.
     *    - if a list is passed for min, then that is treated as 
     *      the allowed ranges for the parameter.
     *
     * Examples:
     *  u.param("param1", "int", 0, 4);        // Between 0 & 4.
     *  u.param("param2", "int", 0);           // Min of 0, no Max
     *  u.param("param3", "int", , 4);         // Max of 100, no min.
     *  u.param("param4", "int", [8, 16, 32]); // Must be one of 8, 16, 32
     *
     */
    u.param = function(name, type, min, max, pow2) {  
	u.paramDefault(name, type, null, min, max, pow2);
    }

    u.paramDefault = function(name, type, def, min, max, pow2) {  

        var p = {};
        p.name = name;
	if (def !== null) {
	    p.default = def;
	}


        // Types
        if (type == undefined) {
            u.log("Utils Error: Parameter Definition: "+name+": type is undefined @ "+this.m.address);
            u.die("ParameterDefinitionTypeUndefined: "+name);
            return;
        }

        if (type == "int") { 
            p.type = this.m.integer; 
        }
        if (type == "bit") { 
            p.type = this.m.bit;   
        }  
        if (type == "string") { 
            p.type = this.m.string; 
        }
        if (type == "object") { 
            p.type = this.m.object; 
        }
        if (type == "array") { 
            p.type = this.m.array; 
        }

        if (type == "boolean") {
            p.type = this.m.integer;

            if (min != undefined) {
                u.log("Utils Error: Parameter Definition: "+name+": Cannot pass range values for boolean.");
            }

            min = 0;
            max = 1;
        }

        // Is a range provided?
        if (min != undefined || max != undefined) {
            p.checks = {};
            if (min != undefined) {
                if (min.constructor === Array) {
                    if (max == undefined) {
                        p.checks.validSet = min;
                    } else {
                        u.log("Utils Error: Parameter Definition: "+name+": The 4th argument must be undefined if a list of allowed values is provided");
                    }
                } else {
                    p.checks.lowerLimit = min;
                }
            }

            if (max != undefined) {
                p.checks.upperLimit = max;
            }
        }

        // Check that we haven't already defined this.
        if (this.m.paramSchema.properties != null) {
            if (this.m.paramSchema.properties[name] != null) {
                u.log("Utils Error: Parameter "+name+" has been defined twice.");
                // throw "ParameterDefinedTwice";  //TODO: Uncomment
            }
        }   

        // Call the official defineParam() method.
        this.m.defineParam(p);

//        // Complain if there's no value provided.
//        if (this.m.param[name] == undefined) {
//            if(!name.match("\.")) {  // Skip the check if it's a dotted parameter name
//                u.log("Utils Error: Parameter Definition: "+name+": Parameter isn't set @ "+this.m.address);
//            }
//        } else {
//            // Otherwise, check for legal values
//            var val = this.m.param[name];
//            if (p.checks) {
//                if (p.checks.upperLimit) {
//                    if (val > p.checks.upperLimit) {
//                        u.paramError("Value for "+name+" ("+val+") is above Max ("+p.checks.upperLimit+").");
//                    }
//                }
//                if (p.checks.lowerLimit) {
//                    if (val < p.checks.lowerLimit) {
//                        u.paramError("Value for "+name+" ("+val+") is below Min ("+p.checks.lowerLimit+").");
//                    }
//                }
//                if (p.checks.validSet) {
//                    if (p.checks.validSet.indexOf(val) == -1) {
//                        //                if (p.checks.validSet) {
//                        //                    var seenVal = 0;
//                        //                    for (let setMember of p.checks.validSet) {
//                        //                        if (setMember == val) {
//                        //                            seenVal;
//                        //                        }
//                        //                    }
//                        //                    if (seenVal==0) {
//                        u.paramError("Value for "+name+" ("+val+") is not within the legal range ("+p.checks.validSet+").");
//                        //                    }
//                    }
//                }
//            }
//        }

    };

    /************************************************************
     * Throw a Parameter error with a message.
     *
     * @arg {string} text - the text to display.
     * 
     *
     */
    u.paramError = function(text) {  
        u.log("Parameter Error: "+text);
//        throw new Error("Parameter Error: "+text);
    };


    /************************************************************
     * Accepts two objects, and returns the union of the two.
     * 
     * @arg {object} obj1, obj2 - the objects to merge.
     */
    u.merge = function (obj1, obj2) {
        var obj3 = {};
        for (var attrname in obj1) { 
            obj3[attrname] = obj1[attrname]; 
        }
        for (var attrname in obj2) { 
            obj3[attrname] = obj2[attrname]; 
        }
        return obj3;
    };

    /************************************************************
     * Returns a list of the parameters that match the regular 
     * expression.
     *
     * @arg {string} regexAsString - the regular expression to match.
     */
    u.getParamsByPrefix = function (regexAsString ) {

        var obj  = this.m.param;
        var r    = new RegExp(regexAsString+"(.*)");
        var obj2 = {};
        
        for (var list in obj){
            var matches = list.match(r);
            if (matches)  {
                obj2[matches[1]]=obj[list];
            }        
        }        
        return obj2;
    };
    
    /************************************************************
     * Uses a mapping object to get the unit parameters from a 
     * top-level parameters object.
     *
     * @arg {object} Glbparam - the top-level parameter object.
     * @arg {object} Fetchlist - the mapping object.
     * @arg {number} num - used to get the correct parameters 
     *                     for the Nth AIU/DCE/DMI when there 
     *                     is more than one.
     */
    u.getUnitParams = function (Glbparam , Fetchlist, num ) {

        var outlist = {};
        
        for (var list in Fetchlist )  {
            var matches = list.match(/\[(.*)\]/);
            if(matches) { 
                var looper= eval(matches[1]);
                for(i=0; i<looper;i++) {
                    var loopstring =  Fetchlist[list].replace("[x]","[i]");
                    var keystring = list.replace(matches[0],i);
                    outlist[keystring] = eval(loopstring);
                    if (outlist[keystring] == undefined) {
                        u.log("Utils Error: Expected parameter: "+keystring+" is undefined. ");
                    }
                }
            } else {
                if(typeof(Fetchlist[list])=='string') {
                    var loopstring = Fetchlist[list].replace("[x]","[num]");
                    outlist[list] = eval(loopstring);
                    if (outlist[list] == undefined) {
                        u.log("Utils Error: Expected parameter: "+list+" is undefined. ");
                    }
                } else {
                    outlist[list] = Fetchlist[list];
                    if (outlist[list] == undefined) {
                        u.log("Utils Error: Expected parameter: "+list+" is undefined. ");
                    }
                }                
            }
        }

        // Here's where we'll add any calculated params for all the units.
//        var sfiPriv = require("../../top/src/sfipriv_calc.js")(this.m, u);
    var sfiPriv = m.param.Derived.sfiPriv;
        outlist.wSfiPriv = sfiPriv.width;
        outlist.sfiPriv  = sfiPriv;

        return outlist ;
    };

    u.getUnitParams2 = function (Fetchlist, num ) {
        var p = this.m.param;
        var out = u.getUnitParams(p, Fetchlist, num);
        u.log("Params2:"+JSON.stringify(out));
        return out;



    };


    /************************************************************
     * Defines top-level params based on a parameter mapping 
     * file.
     *
     * @arg {object} Glbparam - the top-level parameter object.
     * @arg {object} Fetchlist - the mapping object.
     * @arg {number} num - used to get the correct parameters 
     *                     for the Nth AIU/DCE/DMI when there 

     *                     is more than one.
     */
    u.defineTopParamsForUnit = function (Glbparam , Fetchlist, num ) {

        for (var list in Fetchlist )  {
            var rhs = Fetchlist[list];
            if(typeof(Fetchlist[list])=='string') {
                var matches = rhs.match(/\[(.*)\]/);
                if(matches) {
                    rhs = rhs.replace(matches[0], "["+num+"]");
                }
                rhs = rhs.replace("Glbparam.", "");
                u.param(rhs, "int");
            }
        }
    };


    /************************************************************
     * Adds an assertion to the module.
     *
     * @arg {string} assert_name - The name of the assertion
     * @arg {string} condition - The condition that triggers 
     *                           the assertion.
     *
     */
    u.assert = function(assert_name, condition) {
        this.m.svProperty( 
            {genAssert: true, genCover: false}, 
            {name: assert_name, cond: condition}
        );
    };
    u.assert2 = function(acd, assert_name, condition, reportstring) {
        if ((acd == undefined) || (acd == NaN)) {
            u.log("Utils Error: Assertion Control Descriptor value is illegal.");
            u.die("AssertionDescriptorIllegal");
        }
        if (acd.emit_assertions) {
            var opengate  = '';
            var closegate = '';
            if (acd.gate_type === 'CARBON') {
                opengate  = '`ifndef CARBON';
                closegate = '`endif';
            }
            this.m.comment(`
${opengate}
property ${assert_name};
${condition};
endproperty
a_${assert_name}: assert property (${assert_name})
 else begin \$error("${reportstring}"); \ #1000 $finish; end
${closegate}`);
        }        
    };

    /************************************************************
     * Adds a coverpoint to the module.
     *
     * @arg {string} name - The name of the cover point
     * @arg {string} condition - The condition that triggers 
     *                           the assertion.
     *
     */
    u.cover = function(name, condition) {
        this.m.svProperty( 
            {genAssert: false, genCover: true}, 
            {name: assert_name, cond: condition}
        )
    };

    /************************************************************
     * Turns off coverage checking tool.
     *
     *
     */
    u.coverage_off = function() {
//      this.m.comment(` pragma coverage off`);
        this.m.comment(` coverage off`);
    };

    /************************************************************
     * Turns on coverage checking tool.
     *
     *
     */
    u.coverage_on = function() {
//      this.m.comment(` pragma coverage on`);
        this.m.comment(` coverage on`);
    };

    /************************************************************
     * Adds a comment othe module.  This supports multi-line 
     * comments.  This can only be used outside an always block.
     *
     * @arg {string} text - The text to put in a comment.
     *
     */
    u.comment = function(test) {
        var list = test.split("\n");
        for( var i = 0; i<list.length; i++){
            this.m.comment(list[i]);
        }
    };

    /************************************************************
     * Returns a table showing the module's parameter usage.  
     * This shows what's been defined as well as what's been 
     * provided.  This is intended to help debugging.
     */
    u.paramReport = function() {
        for (var p in this.m.param) {
            if (this.m.paramSchema.properties[p] == null) {
                this.m.paramSchema.properties[p] = {};
                this.m.paramSchema.properties[p].type = "UNDEFINED";
            }
            this.m.paramSchema.properties[p].value = this.m.param[p];
        }
        for (var p in this.m.paramSchema.properties) {
            if (this.m.param[p] == null) {
                this.m.paramSchema.properties[p].value = "UNDEFINED";
            }
        }

        function printSpace(str, w, sep){
            if ( typeof str != "string" ) {
                str = str.toString();
            }
            var spaces = w - str.length;
            var s = " "+ str;
            for (var i = 0; i<spaces; i++){ s += " " };
            s += sep;
            return s;
        }

        s =  " ----------------------------------------------------------------------------------------------\n";
        s += "|  Parameter Report for "+this.m.address+"\n";
        s += "|----------------------------------------------------------------------------------------------|\n";
        var x = this.m.paramSchema.properties;
        s += "|"+printSpace("Name", 25, "|");
        s += printSpace("Value", 25, "|");
        s += printSpace("Type", 10, "|");
        s += printSpace("Min", 8, "|");
        s += printSpace("Max", 17, "|");
        s += "\n";
        s += "|----------------------------------------------------------------------------------------------|\n";
        for (var p in this.m.paramSchema.properties) {
            if (x[p].type==null) x[p].type = "";
            if (x[p].minimum==null) x[p].minimum = "";
            if (x[p].maximum==null) x[p].maximum = "";

            s += "|"+printSpace(p, 25, "|");
            s += printSpace(x[p].value, 25, "|");
            s += printSpace(x[p].type, 10, "|");
            s += printSpace(x[p].minimum, 8, "|");
            s += printSpace(x[p].maximum, 17, "|");
            s += "\n";
        }
        s += " ----------------------------------------------------------------------------------------------";
        return s;
    }

    /************************************************************
     * declareMemoryParams
     * includeParamsInStructure
     * propagateMemorySignalsTop
     * propagateMemorySignals
     * declareAndPropagateMemorySignals
     *
     * Functions used to propagate memory parameters and signals 
     * through the code with a minimal footprint
     */
    u.declareMemoryParams = function(memoryName) {
        u.param(memoryName + 'rtlPrefixString', 'string');
        u.param(memoryName + 'memoryType', 'string');
        u.param(memoryName + 'nSignals', 'int');
        for (var i = 0; i<u.getParam(memoryName + 'nSignals'); i++) {
            u.param(memoryName + 'signal'+i+'name', 'string');
            u.param(memoryName + 'signal'+i+'width', 'int');
            u.param(memoryName + 'signal'+i+'direction', 'string');
        }
    };

    u.includeParamsInStructure = function(memoryName, targName, structure) {
        structure[targName + 'rtlPrefixString'] = u.getParam(memoryName + 'rtlPrefixString');
        structure[targName + 'memoryType'] = u.getParam(memoryName + 'memoryType');
        structure[targName + 'nSignals'] = u.getParam(memoryName + 'nSignals');
        for (var i = 0; i<u.getParam(memoryName + 'nSignals'); i++) {
            structure[targName + 'signal'+i+'name'] = u.getParam(memoryName + 'signal'+i+'name');
            structure[targName + 'signal'+i+'width'] = u.getParam(memoryName + 'signal'+i+'width');
            structure[targName + 'signal'+i+'direction'] = u.getParam(memoryName + 'signal'+i+'direction');
        }
    }

    u.propagateMemorySignalsTop = function(memoryName, child, params, num, root, name) {
        if ((!params[memoryName + 'rtlPrefixString']) || params[memoryName + 'memoryType'] === 'none') {
            for (var i = 0; i < params[memoryName + 'nSignals']; i++) {
                delete params[memoryName + 'signal'+i+'name'];
                delete params[memoryName + 'signal'+i+'width'];
                delete params[memoryName + 'signal'+i+'direction'];
            }
            params[memoryName + 'rtlPrefixString'] = name;
            params[memoryName + 'memoryType'] = 'none';
            params[memoryName + 'nSignals'] = 0;
        }
        if (params[memoryName + 'rtlPrefixString'] && params[memoryName + 'memoryType'] !== 'none') {
            var rtlPrefixString = params[memoryName + 'rtlPrefixString'];
            var signals = {};
            for (var i = 0; i < params[memoryName + 'nSignals']; i++) {
                if (params[memoryName + 'signal'+i+'direction'] === 'in') {
                    signals[params[memoryName + 'signal'+i+'name']] = 0 - params[memoryName + 'signal'+i+'width'];
                } else {
                    signals[params[memoryName + 'signal'+i+'name']] = params[memoryName + 'signal'+i+'width'];
                }
            }
            if (rtlPrefixString) {
                u.defineMasterPortsFromInterface(rtlPrefixString + num + '_', signals);
                if (root) {
                    u.addConnectionfromInterface(child + '.' + rtlPrefixString + num + '_', rtlPrefixString + num + '_', signals);
                } else {
                    u.addConnectionfromInterface(child + '.' + rtlPrefixString + '_', rtlPrefixString + num + '_', signals);
                }
            }
        }
    }

    u.propagateMemorySignalsTopV2 = function(dataStructure, child, num, root) {
        var rtlPrefixString = dataStructure.rtlPrefixString;
        var signals = dataStructure.signals;
        if (rtlPrefixString) {
            u.defineMasterPortsFromInterface(child + rtlPrefixString + num + '_', signals);
            if (root) {
                u.addConnectionfromInterface(child + '.' + rtlPrefixString + num + '_', child + rtlPrefixString + num + '_', signals);
            } else {
                u.addConnectionfromInterface(child + '.' + rtlPrefixString + '_', child + rtlPrefixString + num + '_', signals);
            }
        }
    }

    u.propagateMemorySignals = function(memoryName, child) {
        if (this.m.param[memoryName + 'rtlPrefixString'] && u.getParam(memoryName + 'memoryType') !== 'none') {
            var rtlPrefixString = u.getParam(memoryName + 'rtlPrefixString');
            var signals = {};
            for (var i = 0; i < u.getParam(memoryName + 'nSignals'); i++) {
                if (u.getParam(memoryName + 'signal'+i+'direction') === 'in') {
                    signals[u.getParam(memoryName + 'signal'+i+'name')] = 0 - u.getParam(memoryName + 'signal'+i+'width');
                } else {
                    signals[u.getParam(memoryName + 'signal'+i+'name')] = u.getParam(memoryName + 'signal'+i+'width');
                }
            }
            if (rtlPrefixString) {
                u.defineMasterPortsFromInterface(rtlPrefixString + '_', signals);
                u.addConnectionfromInterface(child + '.' + rtlPrefixString + '_', rtlPrefixString + '_', signals);
            }
        }
    };

    u.declareAndPropagateMemorySignals = function(memoryName, targName, child, structure) {
        u.declareMemoryParams(memoryName);
        u.includeParamsInStructure(memoryName, targName, structure);
        u.propagateMemorySignals(memoryName, child);
    };

    /************************************************************
     * declareMemoryControlParams
     * propagateMemoryControlSignals
     *
     * Functions used to propagate memory parameters and control
     * signals through the code
     */

    u.declareMemoryControlParams = function (structureName) {
        u.param(structureName, 'object');
        u.param(structureName + '.controlSignals', 'object');
    }

    u.getMemoryControlInterface = function(structureName) {
        var rtlPrefixString = u.getParam(structureName).rtlPrefixString;
        var signals = {};
        for (var signal in u.getParam(structureName).controlSignals) {
            signals[signal] = u.getParam(structureName).controlSignals[signal];
        }
        return signals;
    };

    /************************************************************
     * Given an interface object, defines all the input and 
     * output ports for the interface, where the interface is 
     * used as an master.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    u.defineMasterPortsFromInterface = function(prefix, intfDesc) {

        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (width > 0) {
                // This is master -> slave direction, so an output for masters.
                u.output(prefix+signal, width);
            } else  if (width < 0) {
                // This is master -> slave direction, so an input for masters.
                u.input(prefix+signal, (0-width));
            } else {
                u.log("Utils Error:defineMasterPorts ("+this.m.address+"): Interface signal "+signal+" width "+width);
            }
        }
    };


    /************************************************************
     * Given an interface object, defines all the input and 
     * output ports for the interface, where the interface is 
     * used as a slave.
     *
     * @arg {string} prefix - the prefix to use for all port names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    u.defineSlavePortsFromInterface = function(prefix, intfDesc) {
        
        for (var signal in intfDesc) {            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (width > 0) {
                // This is master -> slave direction, so an input for slaves.
                u.input(prefix+signal, width);
            } else  if (width < 0) {
                // This is master -> slave direction, so an output for slaves.
                u.output(prefix+signal, (0-width));
            } else {
                u.log("Utils Error:defineSlavePortsFromInterface ("+this.m.address+"): Interface signal "+signal+" width "+width);
            }
        }
    };

    /************************************************************
     * Given an interface object, defines all the internal 
     * signals for an interface.
     *
     * @arg {string} prefix - the prefix to use for all signal names.
     * @arg {object} intfDesc - the interface descriptor object
     *
     */
    u.defineSignalsFromInterface = function(prefix, intfDesc) {

        for (var signal in intfDesc) {
            var width = intfDesc[signal];
            if (width == 0) {
                // Do nothing.
            } else if (width > 0) {
                u.signal(prefix+signal, width);
            } else  if (width < 0) {
                u.signal(prefix+signal, (0-width));
            } else {
                u.log("Utils Error:defineSignals: Interface signal "+signal+" has zero width.");
            }
        }
    };

    /************************************************************
     * Given an interface object, makes all the wire-level 
     * connections to connect two points.
     *
     * @arg {string} masterPrefix - the prefix to use for the 
     *                              master side of the connection.
     * @arg {string} slavePrefix - the prefix to use for the 
     *                             slave side of the connection.
     * @arg {object} intfDesc - the interface descriptor object
     *
     * Note:
     *   - If a prefix is of the for "module.prefix_", the 
     *     connection will be two/from the ports of a submodule.
     *
     */
    u.addConnectionfromInterface = function(masterPrefix, slavePrefix, intfDesc) {

        module = this.m;
        module.fn_intfDesc     = intfDesc;
        module.fn_masterPrefix = masterPrefix;
        module.fn_slavePrefix  = slavePrefix;

//        u.die();

        module.always (function () {
            /*!
              var signal;

              var intfDesc   = this.fn_intfDesc;
              var masterPrefix = this.fn_masterPrefix;
              var slavePrefix  = this.fn_slavePrefix;

              for (signal in intfDesc) {
              var width = intfDesc[signal];
              var wm1 = Math.abs(width) - 1;
              if (width == 0) {                                         
              } else if (width == -1) {                                         */
            $masterPrefix$$signal$[0] = $slavePrefix$$signal$;
            /*! } else if (width == 1) {                                 */
            $slavePrefix$$signal$[0] = $masterPrefix$$signal$;
            /*! } else if (width <-1   ) {                               */
            $masterPrefix$$signal$[$wm1$,0] = $slavePrefix$$signal$;
            /*! } else if (width >1  ) {                                 */
            $slavePrefix$$signal$[$wm1$,0] = $masterPrefix$$signal$;
            /*! }}                                                       */
        });
    };

    /************************************************************
     * Given an CSR object, makes all the CSR wire-level 
     * connections to connect two points.
     *
     * @arg {string}    masterPrefix -  the prefix to use for the 
     *                                  master side of the connection.
     * @arg {string}    slavePrefix -   the prefix to use for the 
     *                                  slave side of the connection.
     * @arg {integer}   CsrPageNum -    Page number group of the unit
     *                                  This is the SfiSlvID of the first
     *                                  AIU/DCE/DMI unit 
     * @arg {string}    CsrRegName -    {optional} specify the name of the
     *                                  register to make connection for; 
     *                                  if not specified, make connection for
     *                                  all registers
     *
     */

    u.addCsrConnection = function(masterPrefix, slavePrefix, CsrType, CsrRegName) {

        var CSRPARAM =      require("../../top/src/csr.js");

        module = this.m;
        module.fn_masterPrefix =    masterPrefix;
        module.fn_slavePrefix =     slavePrefix;
        module.fn_CsrInfo =         CSRPARAM.CsrInfo;

        if (CsrType == 'AgentAIU') {
            module.fn_CsrPageNum =  0x00;
        } else if (CsrType == 'BridgeAIU') {
            module.fn_CsrPageNum =  0x60;
        } else if (CsrType == 'DCE') {
            module.fn_CsrPageNum =  0x80;
        } else if (CsrType == 'DMI') {
            module.fn_CsrPageNum =  0xC0;
        } else if (CsrType == 'Sub') {
            module.fn_CsrPageNum =  0xFF;
        } else {
            module.fn_CsrPageNum =  CsrType;
        }

        module.fn_CsrRegName =      CsrRegName;

        module.always (function () {

        /*! var temp; */
        /*! var hasAlias; */
        /*! var masterPrefix =  this.fn_masterPrefix; */
        /*! var slavePrefix =   this.fn_slavePrefix; */
        /*! var CsrInfo =       this.fn_CsrInfo; */
        /*! var CsrPageNum =    this.fn_CsrPageNum; */
        /*! var CsrRegName =    this.fn_CsrRegName; */

        /*! Object.keys(CsrInfo).forEach(function(key, i) { */

            /*! hasAlias = 0; */
            /*! Object.keys(CsrInfo).forEach(function(key2, j) { */
                /*! if (CsrInfo[key].prefix == CsrInfo[key2].alias) { */
                    /*! hasAlias = 1; */
                /*! } */
            /*! }); */

            /*! for (var i=0; i<=CsrInfo[key].regnumhi-CsrInfo[key].regnumlo; i++) { */

                /*! temp = CsrInfo[key].regnumlo + i; */

                /*! if ((CsrInfo[key].name == CsrRegName) || (CsrRegName == undefined)) { */


                    /*! if ((CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].access != 'RO') && (CsrInfo[key].pagelo == CsrPageNum)) { */

                        /*! if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) { */
                            $slavePrefix$o_$CsrInfo[key].name$_$i$_en =     $masterPrefix$o_$CsrInfo[key].name$_$i$_en;
                        /*! } else { */
                            $slavePrefix$o_$CsrInfo[key].name$_en =         $masterPrefix$o_$CsrInfo[key].name$_en;
                        /*! } */

                    /*! } */

                    /*! if ((CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].pagelo == CsrPageNum) & (CsrInfo[key].alias == 'None')) { */

                        /*! if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) { */
                            $slavePrefix$o_$CsrInfo[key].name$_$i$ =        $masterPrefix$o_$CsrInfo[key].name$_$i$;
                        /*! } else { */
                            $slavePrefix$o_$CsrInfo[key].name$ =            $masterPrefix$o_$CsrInfo[key].name$;
                        /*! } */

                    /*! } */

                    /*! if ((CsrInfo[key].hardware == 'WO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].pagelo == CsrPageNum) & (CsrInfo[key].alias == 'None')) { */

                        /*! if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) { */
                            $masterPrefix$i_$CsrInfo[key].name$_$i$ =       $slavePrefix$i_$CsrInfo[key].name$_$i$;
                            /*! if (CsrInfo[key].access != 'RO' || CsrInfo[key].access == 'RO' && hasAlias) { */
                            $masterPrefix$i_$CsrInfo[key].name$_$i$_en =    $slavePrefix$i_$CsrInfo[key].name$_$i$_en;
                            /*! } */
                        /*! } else { */
                            $masterPrefix$i_$CsrInfo[key].name$ =           $slavePrefix$i_$CsrInfo[key].name$;
                            /*! if (CsrInfo[key].access != 'RO' || CsrInfo[key].access == 'RO' && hasAlias) { */
                            $masterPrefix$i_$CsrInfo[key].name$_en =        $slavePrefix$i_$CsrInfo[key].name$_en;
                            /*! } */
                        /*! } */

                    /*! } */

                /*! } */

            /*! } */

        /*! }); */

        });

    };

    /************************************************************
     * Given an CSR object, makes all the CSR wire-level 
     * connections to connect two points.
     *
     * @arg {string}    masterPrefix -  the prefix to use for the 
     *                                  master side of the connection.
     * @arg {string}    slavePrefix -   the prefix to use for the 
     *                                  slave side of the connection.
     * @arg {string}    IOType -        I/O/IO
     * @arg {string}    CsrType -       AgentAIU/BridgeAIU/DCE/DCE0/DMI
     * @arg {string}    CsrRegName -    {optional} specify the name of the
     *                                  register to make connection for; 
     *                                  if not specified, make connection for
     *                                  all registers
     *
     */

    u.addCsrConnection_v2 = function(masterPrefix, slavePrefix, IOType, CsrType, CsrRegName) {

        var CSRPARAM =      require("../../top/src/csr.js");

        module = this.m;
        module.fn_masterPrefix =    masterPrefix;
        module.fn_slavePrefix =     slavePrefix;
        module.fn_IOType =          IOType;
        module.fn_CsrInfo =         CSRPARAM.CsrInfo;

        if (CsrType == 'AgentAIU') {
            var CsrPageNum =    0x00;
        } else if (CsrType == 'BridgeAIU') {
            var CsrPageNum =    0x60;
        } else if ((CsrType == 'DCE') | (CsrType == 'DCE0')) {
            var CsrPageNum =    0x80;
        } else if (CsrType == 'DMI') {
            var CsrPageNum =    0xC0;
        } else {
            var CsrPageNum =    CsrType;
        }

        function matchingPageNum(key) {
            if (CSRPARAM.CsrInfo[key].pagelo == CsrPageNum) { 
                return true;
            } else if ((CsrType == "DCE0") & (CSRPARAM.CsrInfo[key].pagelo == 0xFF)) {
                return true;
            }
            return false;
        }

        module.fn_CsrRegName =      CsrRegName;

        module.always (function () {

        /*! var temp; */
        /*! var masterPrefix =  this.fn_masterPrefix; */
        /*! var slavePrefix =   this.fn_slavePrefix; */
        /*! var IOType =        this.fn_IOType; */
        /*! var CsrInfo =       this.fn_CsrInfo; */
        /*! var CsrRegName =    this.fn_CsrRegName; */

        /*! Object.keys(CsrInfo).forEach(function(key, i) { */

            /*! for (var i=0; i<=CsrInfo[key].regnumhi-CsrInfo[key].regnumlo; i++) { */

                /*! temp = CsrInfo[key].regnumlo + i; */

                /*! if ((CsrInfo[key].name == CsrRegName) || (CsrRegName == undefined)) { */

                    /*! if ((CsrInfo[key].access != 'RO') && matchingPageNum(key) && (IOType == 'IO' || IOType == 'O')) { */

                        /*! if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) { */
                            $slavePrefix$o_$CsrInfo[key].name$_$i$_en =     $masterPrefix$o_$CsrInfo[key].name$_$i$_en;
                            $slavePrefix$o_$CsrInfo[key].name$_$i$ =        $masterPrefix$o_$CsrInfo[key].name$_$i$;
                        /*! } else { */
                            $slavePrefix$o_$CsrInfo[key].name$_en =         $masterPrefix$o_$CsrInfo[key].name$_en;
                            $slavePrefix$o_$CsrInfo[key].name$ =            $masterPrefix$o_$CsrInfo[key].name$;
                        /*! } */

                    /*! } */

                    /*! if ((CsrInfo[key].access != 'RO' || (CsrInfo[key].access == 'RO' && ((CsrInfo[key].hardware == 'WO' || CsrInfo[key].hardware == 'RW') || isNaN(CsrInfo[key].resetvalue) && (CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'IG')))) && matchingPageNum(key) && (IOType == 'IO' || IOType == 'I')) { */

                        /*! if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) { */
                            $masterPrefix$i_$CsrInfo[key].name$_$i$ =       $slavePrefix$i_$CsrInfo[key].name$_$i$;
                        /*! } else { */
                            $masterPrefix$i_$CsrInfo[key].name$ =           $slavePrefix$i_$CsrInfo[key].name$;
                        /*! } */

                    /*! } */

                /*! } */

            /*! } */

        /*! }); */

        });

    };

    /************************************************************
     * Given an CSR object, declare all the CSR related I/Os 
     *
     * @arg {integer}   direction -     0: same I/O direction as CSR block
     *                                  1: opposite I/O direction as CSR block
     *                                  master side of the connection.
     * @arg {integer}   CsrPageNum -    Page number group of the unit
     *                                  This is the SfiSlvID of the first
     *                                  AIU/DCE/DMI unit 
     * @arg {string}    CsrRegName -    {optional} specify the name of the
     *                                  register to make connection for; 
     *                                  if not specified, make connection for
     *                                  all registers
     *
     */

    u.addCsrIO = function(direction, CsrType, CsrRegName) {

        var CSRPARAM =  require("../../top/src/csr.js");
        var CsrInfo =   CSRPARAM.CsrInfo
        var temp;
        var hasAlias;

        if (CsrType == 'AgentAIU') {
            var CsrPageNum =    0x00;
        } else if (CsrType == 'BridgeAIU') {
            var CsrPageNum =    0x60;
        } else if (CsrType == 'DCE') {
            var CsrPageNum =    0x80;
        } else if (CsrType == 'DMI') {
            var CsrPageNum =    0xC0;
        } else if (CsrType == 'Sub') {
            var CsrPageNum =    0xFF;
        } else {
            var CsrPageNum =    CsrType;
        }

        Object.keys(CsrInfo).forEach(function(key, i) { 

            hasAlias = 0;
            Object.keys(CsrInfo).forEach(function(key2, j) { 
                if (CsrInfo[key].prefix == CsrInfo[key2].alias) {
                    hasAlias = 1;
                }
            });

            for (var i=0; i<=CsrInfo[key].regnumhi-CsrInfo[key].regnumlo; i++) { 

                temp = CsrInfo[key].regnumlo + i;

                if ((CsrInfo[key].name == CsrRegName) || (CsrRegName == undefined)) {

                    if ((CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].access != 'RO') & (CsrInfo[key].pagelo == CsrPageNum)) {

                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                            }
                        } else {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_en', 1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_en', 1);
                            }
                        }

                    }

                    if ((CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].pagelo == CsrPageNum) && (CsrInfo[key].alias == 'None')) {

                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        } else {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        }

                    }

                    if ((CsrInfo[key].hardware == 'WO' || CsrInfo[key].hardware == 'RW') && (CsrInfo[key].pagelo == CsrPageNum) && (CsrInfo[key].alias == 'None')) {
                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.input ('i_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.output ('i_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                            if (CsrInfo[key].access != 'RO' || CsrInfo[key].access == 'RO' && hasAlias) {

                                if (direction) {
                                    u.input ('i_'+CsrInfo[key].name+'_'+i+'_en', 1);
                                } else {
                                    u.output ('i_'+CsrInfo[key].name+'_'+i+'_en', 1);
                                }
                            }
                        } else {
                            if (direction) {
                                u.input ('i_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.output ('i_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                            if (CsrInfo[key].access != 'RO' || CsrInfo[key].access == 'RO' && hasAlias) {

                                if (direction) {
                                    u.input ('i_'+CsrInfo[key].name+'_en', 1);
                                } else {
                                    u.output ('i_'+CsrInfo[key].name+'_en', 1);
                                }
                            }
                        }
                    }

                }

            }

        });

    };

    /************************************************************
     * Given an CSR object, declare all the CSR related I/Os 
     *
     * @arg {integer}   direction -     0: same I/O direction as CSR block
     *                                  1: opposite I/O direction as CSR block
     *                                  master side of the connection.
     * @arg {string}    IOType -        I/O/IO
     * @arg {string}    CsrType -       AgentAIU/BridgeAIU/DCE/DCE0/DMI
     * @arg {string}    CsrRegName -    {optional} specify the name of the
     *                                  register to make connection for; 
     *                                  if not specified, make connection for
     *                                  all registers
     *
     */

    u.addCsrIO_v2 = function(direction, IOType, CsrType, CsrRegName) {

        var CSRPARAM =  require("../../top/src/csr.js");
        var CsrInfo =   CSRPARAM.CsrInfo
        var temp;

        if (CsrType == 'AgentAIU') {
            var CsrPageNum =    0x00;
        } else if (CsrType == 'BridgeAIU') {
            var CsrPageNum =    0x60;
        } else if ((CsrType == 'DCE') | (CsrType == 'DCE0')) {
            var CsrPageNum =    0x80;
        } else if (CsrType == 'DMI') {
            var CsrPageNum =    0xC0;
        } else {
            var CsrPageNum =    CsrType;
        }

        function matchingPageNum(key) {
            if (CSRPARAM.CsrInfo[key].pagelo == CsrPageNum) { 
                return true;
            } else if ((CsrType == "DCE0") & (CSRPARAM.CsrInfo[key].pagelo == 0xFF)) {
                return true;
            }
            return false;
        }

        Object.keys(CsrInfo).forEach(function(key, i) { 

            for (var i=0; i<=CsrInfo[key].regnumhi-CsrInfo[key].regnumlo; i++) { 

                temp = CsrInfo[key].regnumlo + i;

                if ((CsrInfo[key].name == CsrRegName) || (CsrRegName == undefined)) {

                    if ((CsrInfo[key].access != 'RO') && matchingPageNum(key) && (IOType == 'IO' || IOType == 'O')) {

                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                                u.output ('o_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                                u.input ('o_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        } else {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_en', 1);
                                u.output ('o_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_en', 1);
                                u.input ('o_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        }

                    }

                    if ((CsrInfo[key].access != 'RO' || (CsrInfo[key].access == 'RO' && ((CsrInfo[key].hardware == 'WO' || CsrInfo[key].hardware == 'RW') || isNaN(CsrInfo[key].resetvalue) && (CsrInfo[key].hardware == 'RO' || CsrInfo[key].hardware == 'IG')))) && matchingPageNum(key) && (IOType == 'IO' || IOType == 'I')) {
                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.input ('i_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.output ('i_'+CsrInfo[key].name+'_'+i, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        } else {
                            if (direction) {
                                u.input ('i_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            } else {
                                u.output ('i_'+CsrInfo[key].name, CsrInfo[key].msb-CsrInfo[key].lsb+1);
                            }
                        }
                    }

                }

            }

        });

    };

    /************************************************************
     * Given an CSR object, declare all the CSR enable related I/Os 
     *
     * @arg {integer}   direction -     0: same I/O direction as CSR block
     *                                  1: opposite I/O direction as CSR block
     *                                  master side of the connection.
     * @arg {string}    IOType -        I/O/IO
     * @arg {string}    CsrType -       AgentAIU/BridgeAIU/DCE/DCE0/DMI
     * @arg {string}    CsrRegName -    {optional} specify the name of the
     *                                  register to make connection for; 
     *                                  if not specified, make connection for
     *                                  all registers
     *
     */

    u.addCsrIO_en_v2 = function(direction, IOType, CsrType, CsrRegName) {

        var CSRPARAM =  require("../../top/src/csr.js");
        var CsrInfo =   CSRPARAM.CsrInfo
        var temp;

        if (CsrType == 'AgentAIU') {
            var CsrPageNum =    0x00;
        } else if (CsrType == 'BridgeAIU') {
            var CsrPageNum =    0x60;
        } else if ((CsrType == 'DCE') | (CsrType == 'DCE0')) {
            var CsrPageNum =    0x80;
        } else if (CsrType == 'DMI') {
            var CsrPageNum =    0xC0;
        } else {
            var CsrPageNum =    CsrType;
        }

        function matchingPageNum(key) {
            if (CSRPARAM.CsrInfo[key].pagelo == CsrPageNum) { 
                return true;
            } else if ((CsrType == "DCE0") & (CSRPARAM.CsrInfo[key].pagelo == 0xFF)) {
                return true;
            }
            return false;
        }

        Object.keys(CsrInfo).forEach(function(key, i) { 

            for (var i=0; i<=CsrInfo[key].regnumhi-CsrInfo[key].regnumlo; i++) { 

                temp = CsrInfo[key].regnumlo + i;

                if ((CsrInfo[key].name == CsrRegName) || (CsrRegName == undefined)) {

                    if ((CsrInfo[key].access != 'RO') && matchingPageNum(key) && (IOType == 'IO' || IOType == 'O')) {

                        if (CsrInfo[key].regnumhi-CsrInfo[key].regnumlo>0) {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_'+i+'_en', 1);
                            }
                        } else {
                            if (direction) {
                                u.output ('o_'+CsrInfo[key].name+'_en', 1);
                            } else {
                                u.input ('o_'+CsrInfo[key].name+'_en', 1);
                            }
                        }

                    }

                }

            }

        });

    };
   
    /************************************************************
     * Unresettable flop.
     *
     * @arg {string} qout - the name of the flop's output.
     * @arg {string} din - the flop's input. This can be an expression.
     * @arg {number} width - thie width of the flop.
     *
     * Note that the end user can make all flops resettable, so a reset value is still required.
     */
    u.dff = function(qout, din, width, resetvalue) {

        this.m.din  = din;
        this.m.qout = qout;

        u.state(qout, width, resetvalue, 1);  

//        this.m.defineState(
//            { clock: {name: 'clk', edge: 'risingEdge' }, reset: { } },
//            { name: qout, type: this.m.bit, size: width}) ;

        this.m.always(function(){
            $this.qout$ <<= $this.din$;
        });

    };

    /************************************************************
     * Unresettable flop with enable
     *
     * @arg {string} qout - the name of the flop's output.
     * @arg {string} din - the flop's input. This can be an expression.
     * @arg {string} enable - the expression to drive the flop's enable input.
     * @arg {number} width - thie width of the flop.
     *
     * Note that the end user can make all flops resettable, so a reset value is still required.
     */
    u.dffe = function(qout, din, enable, width, resetvalue) {

        this.m.din    = din;
        this.m.qout   = qout;
        this.m.enable = enable;

        u.state(qout, width, resetvalue, 1);  
//      this.m.defineState(
//          { clock: {name: 'clk', edge: 'risingEdge' }, reset: { } },
//
//         { name: qout, type: this.m.bit, size: width}) ;

        this.m.always(function(){
            $this.qout$ <<= $this.enable$ ? $this.din$ : $this.qout$;
        });

    };

    /************************************************************
     * Resettable flop 
     *
     * @arg {string} qout - the name of the flop's output.
     * @arg {string} din - the flop's input. This can be an expression.
     * @arg {number} width - the width of the flop.
     * @arg {number} resetvalue - the value to reset the flop to.
     *
     */
    u.dffr = function(qout, din, width, resetvalue) {

        this.m.din  = din;
        this.m.qout = qout;
        if(width > 0) {
            u.state(qout, width, resetvalue);

            this.m.always(function(){
                $this.qout$ <<= $this.din$;
            });
        }
    };
    
    /************************************************************
     * Resettable flop with enable
     *
     * @arg {string} qout - the name of the flop's output.
     * @arg {string} din - the flop's input. This can be an expression.
     * @arg {string} enable - the expression to drive the flop's enable input.
     * @arg {number} width - thie width of the flop.
     * @arg {number} resetvalue - the value to reset the flop to.
     *
     */
    u.dffre = function(qout, din, enable, width, resetvalue) {

        this.m.din    = din;
        this.m.qout   = qout;
        this.m.enable = enable;
        
        if(width >0){

            u.state(qout, width, resetvalue);

            this.m.always(function(){
                $this.qout$ <<= $this.enable$ ? $this.din$ : $this.qout$;
            });
        }
    };
    
    /************************************************************
     * Resettable flop with set and clear
     *
     * @arg {string} qout - the name of the flop's output.
     * @arg {string} din - the flop's input. This can be an expression.
     * @arg {string} enable - the expression to drive the flop's enable input.
     * @arg {number} width - thie width of the flop.
     * @arg {number} resetvalue - the value to reset the flop to.
     *
     */
    u.dffrsetclear = function(qout, din, set, clear, width, resetvalue) {

        this.m.din    = din;
        this.m.qout   = qout;
        this.m.set    = set;
        this.m.clear  = clear;
        this.m.width  = width;

        
        if(width >0){

            u.dffre(qout, din , qout+'_en' ,width, resetvalue);
            u.signal(qout+'_en');
            u.signal(qout+din+'_in',width);
            this.m.always(function(){
                $this.qout$_en = $this.set$ | $this.clear$ ;    
                $this.qout$$this.din$_in = $this.set$ ? $this.din$ : '0'.b("this.width");
            });
        }
    };
    
    /************************************

    /************************************************************


    /************************************************************
     * Wire with assignment.
     *
     * @arg {string} cout - the name of the wire.
     * @arg {string} cin - the expression to assign to the wire.
     * @arg {number} width - the width of the wire.  Assumed to 
     *                       be 1 if omitted.
     */
    u.wire = function(cout, cin, width) {
        if(typeof width === "undefined") {
            width = 1;
        }

        this.m.cin  = cin;
        this.m.cout = cout;

        u.signal(cout, width);

        this.m.always(function(){
            $this.cout$ = $this.cin$;
        });

    };

    /************************************************************
     * Safe way to get parameter values.  This checks that the 
     * parameter is defined before returning it.
     *
     * @arg {string} paramName - the name of the parameter to get.
     */
    u.getParam = function(paramName) {


        // Check parameter value
        if ((this.m.param[paramName] == undefined) || (this.m.param[paramName] == NaN)) {
            this.m.error("Utils Error: Parameter "+paramName+" value ("+this.m.param[paramName]+")is illegal.");
            u.die("ParameterIllegal");
        }

        // Check that parameter has been defined before it's used.
        if (this.m.paramSchema.properties == null) {
            this.m.error("Utils Error: No Parameters have been defined.");
            u.die("NoParametersDefined");
        }
        if (this.m.paramSchema.properties[paramName] == null) {
            this.m.error("Utils Error: Parameter "+paramName+" hasn't been defined.");
            u.die("ParameterNotDefined");
        }

        return this.m.param[paramName];
    };
 
    /************************************************************
     * Safe way to get parameter values.  This checks that the 
     * parameter is defined before returning it.
     *
     * @arg {object} p - the parameter object
     * @arg {string} paramName - the name of the parameter to get.
     */
    u.getParamFromObject = function(p, paramName) {

        // Check parameter value
        if ((p[paramName] == undefined) || (p[paramName] == NaN)) {
            u.log("Utils Error: Parameter "+paramName+" value ("+p[paramName]+")is illegal.");
            u.die("ParameterIllegal");
        }

        return p[paramName];
    };
 
    /************************************************************
     * 
     * 
     *
     * 
     */
    u.find_first = function(value,invec,outvec,width) {
        this.m.value= value;
        this.m.invec = invec;
        this.m.outvec = outvec;
        this.m.width = width;
        this.m.outwidth = this.m.log2ceil(width);

        u.signal(outvec ,this.m.width)  
        
        this.m.always (function () {
           switch ('$this.value$'.b(1)) {
               /*! for (var i=0; i<this.width; i++) { */
               case ($this.invec$[$i$]): $this.outvec$ = ('1'.b("this.width") << $i$); break;
                   //'$i$'.d("this.log2ceil(this.width)"); break;
               /*! } */
               default : $this.outvec$ =   '0'.b("this.width");
                   //'$i$'.d("this.log2ceil(this.width)");
           }
        });
    };       

    u.find_first_reverse = function(value,invec,outvec,width) {
        this.m.value= value;
        this.m.invec = invec;
        this.m.outvec = outvec;
        this.m.width = width;
        this.m.outwidth = this.m.log2ceil(width);

        u.signal(outvec ,this.m.width)  
        
        this.m.always (function () {
           switch ('$this.value$'.b(1)) {
               /*! for (var i= this.width-1; i >= 0; i--) { */
               case ($this.invec$[$i$]): $this.outvec$ = ('1'.b("this.width") << $i$); break;
                   //'$i$'.d("this.log2ceil(this.width)"); break;
               /*! } */
               default : $this.outvec$ =   '0'.b("this.width");
                   //'$i$'.d("this.log2ceil(this.width)");
           }
        });
    };       



 u.find_first_first_fast = function(invec,outvec,width) {
        this.m.invec = invec;
        this.m.outvec = outvec;
        this.m.width = width;
        u.signal(outvec,width);  
        if(width>1) { 
        u.signal(invec+"_therm",width);  
        this.m.ffs(invec+"_therm", invec, this.m.width);
        this.m.always (function () {
        $this.outvec$ = ([ $this.invec$_therm["this.width-2",0] ,'0'.b(1)].concat) ^ $this.invec$_therm ;
        });}
        else
        {
        this.m.always (function () {
        $this.outvec$ = $this.invec$;
        });}
        
    };              



    u.encoder = function(invector, outdecode, width) {
        this.m.invector  = invector;
        this.m.outdecode = outdecode;
        this.m.width     = width;
    u.signal( outdecode,Math.max(1,this.m.log2ceil(width)) );    
        this.m.always(function() {
            switch($this.invector$) {
                /*! for (var j=0; j < this.width; j++) {                  */
            case '1'.b("this.width") << $j$: $this.outdecode$ = '"j"'.d("Math.max(1,this.log2ceil(this.width))"); break;
                /*! }                                                            */
            default:  $this.outdecode$ = '0'.b("Math.max(1,this.log2ceil(this.width))");
            }
        });
    };



     
    /************************************************************
     * An easy way to do a multiple-operand infix operator.
     * 
     * @arg {array/string} list_of_things - The list of things to operate on
     * @arg {string} op - The operand
     * @return {string} - The string that reopresents the combination.
     *
     * Example:
     *    u.list_op(["a","b","c"], "|") ==>  "a | b | c"
     */
    u.list_op = function(list_of_things, op) {

        var out = "";
        for (var i = 0; i < list_of_things.length; i++) {
            if (i > 0) {
                out += " "+op+" "
            }
            out += list_of_things[i];
        }
        return out;
    };

    /************************************************************
     * Returns the number of bits required for error encoding.
     *
     * @arg {string} fnErrDetectCorrect - error encoding type.
     * @arg {Number} width - data width before encoding.
     * @return {Number} - The number of bits required for the error code.
     */
    u.getErrorEncodingWidth = memFunctions.getErrorEncodingWidth;

    /************************************************************
     * Returns a vector of block widths that are as close as possible
     *
     * @arg {string} fnErrDetectCorrect - error encoding type.
     * @arg {Number} width - data width before encoding.
     * @arg {Number} extraBits - extra number of bits to be added to the first element
     * @return [{Number1},{Number2}...] - The vector of block widths.
     */
    u.getEvenBlockWidths = memFunctions.getEvenBlockWidths;

    /************************************************************
     * 
     * 
     *
     * 
     */
    u.find_first_encode = function(value,invec,outvec,width) {
        this.m.value= value;
        this.m.invec = invec;
        this.m.outvec = outvec;
        this.m.width = width;
        this.m.outwidth = Math.max(1, this.m.log2ceil(width));

        //u.signal(outvec ,this.m.outwidth)  
        
        this.m.always (function () {
           switch ('$this.value$'.b(1)) {
               /*! for (var i=0; i<this.width; i++) { */
               case ($this.invec$[$i$]): $this.outvec$ = ('"i"'.d("this.outwidth") ); break;
                   //'$i$'.d("this.log2ceil(this.width)"); break;
               /*! } */
               default : $this.outvec$ =   '0'.d("this.outwidth");
                   //'$i$'.d("this.log2ceil(this.width)");
           }
        });
    };              

    u.counter = function (out,up,down,count) {
    this.m.out = out;
    this.m.up  = up;
    this.m.down = down;
    this.m.count = count;
    this.m.width = Math.max(1,this.m.log2ceil(count+1));  
    var powoftwo = 0;
   //  if (count & (count-1) == 0) {powoftwo = 1;} 

   
    u.signal(out+"_cnt_in", this.m.width);
    u.signal(out+"_cnt_en");
    u.dffre( out , out+"_cnt_in" , out+"_cnt_en"  ,this.m.width, 0); // free running counter

  //    if(powoftwo){
      this.m.always (function () {
      $this.out$_cnt_en = $this.up$ ^ $this.down$;
      $this.out$_cnt_in = [$this.up$].repeat("this.width") & ($this.out$ + '1'.b("this.width")) | 
                          [$this.down$].repeat("this.width") & ($this.out$ - '1'.b("this.width")) ;
       });
   //   }else{
    };
   
    u.counterwithreset = function (out,up,down,clear,count) {
    this.m.out = out;
    this.m.up  = up;
    this.m.down = down;
    this.m.clear = clear;
    this.m.count = count;
    this.m.width = Math.max(1,this.m.log2ceil(count+1));  
    var powoftwo = 0;
   
    u.signal(out+"_cnt_in", this.m.width);
    u.signal(out+"_cnt_in_withreset", this.m.width);
    u.signal(out+"_cnt_en");
    u.dffre( out , out+"_cnt_in_withreset" , out+"_cnt_en"  ,this.m.width, 0); // free running counter

      this.m.always (function () {
      $this.out$_cnt_en = ($this.up$ ^ $this.down$) | $this.clear$ ;
      $this.out$_cnt_in = [$this.up$].repeat("this.width") & ($this.out$ + '1'.b("this.width")) | 
                          [$this.down$].repeat("this.width") & ($this.out$ - '1'.b("this.width")) ;
       $this.out$_cnt_in_withreset = $this.clear$ ? '0'.b("this.width") : $this.out$_cnt_in ; 
      
      });
    };

    u.risingedgedetect = function (out,sigin) {
    this.m.out = out ;
    this.m.sigin = sigin ;
    
    u.dffr( sigin+"_d" , sigin ,1, 0); // free running counter
      this.m.always (function () {
      $this.out$ = $this.sigin$  & ~$this.sigin$_d; 
      });
    
    }


    u.debugmux32 = function ( muxout ,bus, word_sel ,struct_sel,struct_id ,bus_width) {
       this.m.muxout             = muxout;
       this.m.bus                = bus   ;
       this.m.word_sel           = word_sel   ;
       this.m.struct_sel         = struct_sel   ;
       this.m.struct_id          = struct_id   ;
       this.m.width              = bus_width ;
       this.m.alignzero          = (32-(bus_width%32))%32;
       this.m.width_num_mux_legs = Math.max(0,this.m.log2ceil(bus_width/32));
       this.m.num_mux_legs       = Math.ceil(bus_width/32);
       
       u.signal(muxout,32); 
       u.signal(word_sel + struct_id +"_onehot", this.m.num_mux_legs);
       u.signal(bus + "_aligned", this.m.num_mux_legs*32);
       u.signal(struct_sel+struct_id+"_en");

       this.m.always (function () {
         $struct_sel$$this.struct_id$_en = ( $this.struct_sel$ == '"this.struct_id"'.d(6) ) ;
         $bus$_aligned = ['0'.b("this.alignzero"),$bus$].concat;
         $word_sel$$this.struct_id$_onehot = '1'.b("this.num_mux_legs") << $this.word_sel$["this.width_num_mux_legs",0] ;
         $this.muxout$ =  '0'.b("32")    
               /*! for (var i=0; i<this.num_mux_legs; i++) { */
              | [$word_sel$$this.struct_id$_onehot["i"] & $struct_sel$$this.struct_id$_en].repeat(32) & $bus$_aligned["(i+1)*32- 1","i*32"]
               /*! } */
              ;



       });
    }

    /************************************************************
     * 
     * 
     *
     */
    u.fifo = function(name, width, depth, options) {

        // u.log("FIFO:"+name+" "+width+" "+depth+" "+options);
        if (options == undefined) {
            options = {};
        }
        
        var p = options;
        p.depth = depth;
        p.width = width;
        if (options.push_type == undefined)        { p.push_type        = 'RdyVld'; }
        if (options.pop_type == undefined)         { p.pop_type         = 'RdyVld'; }
        if (options.async == undefined)            { p.async            = 0;        }
        // TODO: Ensure we don't have extra options.

        if(options.number_of_inputs > 1) {
            var FIFO  = require('../../lib/src/multiport_fifo.achl');
            if (options.number_of_inputs == undefined) { p.number_of_inputs = 1;        }
            this.m.instance({ name: name, moduleName: FIFO, params: p });
        } else {
            if (options.bypass_mode == undefined)      { p.bypass_mode      = 0;        }

            var FIFO  = require('../../lib/src/fifo.achl');
            this.m.instance({ name: name, moduleName: FIFO, params: p });
        }

    };

    /************************************************************
     * 
     * 
     *
     */
    u.muxarb = function(name, width, number_of_inputs, options) {

        if (options == undefined) {
            options = {};
        }
        
        var p = options;
        p.width = width;
        p.number_of_inputs = number_of_inputs;

        if (options.sink_type == undefined)    { p.sink_type = 'RdyVld';     }
        if (options.pipeline == undefined)     { p.pipeline       = 0;            }
        if (options.arb_priority == undefined) { p.arb_priority   = 'RoundRobin'; }
        if (options.sfi_compliant == undefined) { p.sfi_compliant = 0; }
        // TODO: Ensure we don't have extra options.

        var MUX_ARB = require('../../lib/src/muxarb.achl');

        this.m.instance({ name: name, moduleName: MUX_ARB, params: p });

    };


    u.synchronize = function(inSignalName, width) {

        if (width == undefined) {
            width=1;
        }
        
        var p = {};
        p.width = width;

        var SYNCH = require('../../lib/src/synchronizer.achl');

        this.m.instance({ name: inSignalName+"_synchronizer", moduleName: SYNCH, params: p });
        u.signal(inSignalName+"_sync", width);
        this.m.always(function(){
            $inSignalName$_synchronizer.in_data = $inSignalName$;
            $inSignalName$_sync = $inSignalName$_synchronizer.out_data;
        });

    };

    /************************************************************
     * Defines all the parameters that are part of a selectInfo group.
     * 
     * @arg {string} prefix - the hierarchichal prefix for the selectparams group.
     *
     */
    u.defineSelectParams = function(prefix) {
        u.param(prefix+".nSelectBits"   , "int"); // TODO: Validate
        u.param(prefix+".SelectBits[]"  , "int"); // TODO: Validate
        u.param(prefix+".HashBits[]"    , "int"); // TODO: Validate
        u.param(prefix+".SelectTable[]" , "int"); // TODO: Validate
    }

    /************************************************************
     * 
     * 
     *
     */
    u.sfiPrivDebug = function(signalName) {

        var p = this.m.param; 

        this.m.utilsSignalName = signalName;

        u.signal("DBG_"+signalName+"_msgtype",    p.sfiPriv.msgType.width);
        u.signal("DBG_"+signalName+"_st",         p.sfiPriv.ST.width);
        u.signal("DBG_"+signalName+"_sd",         p.sfiPriv.SD.width);       
        u.signal("DBG_"+signalName+"_so",         p.sfiPriv.SO.width);       
        u.signal("DBG_"+signalName+"_ss",         p.sfiPriv.SS.width);       
        u.signal("DBG_"+signalName+"_errresult",  p.sfiPriv.ErrResult.width);
        u.signal("DBG_"+signalName+"_aceexokay",  p.sfiPriv.AceExOkay.width);
        u.signal("DBG_"+signalName+"_aiutransid", p.sfiPriv.aiuTransId.width);
        u.signal("DBG_"+signalName+"_aiuid",      p.sfiPriv.aiuId.width);
        u.signal("DBG_"+signalName+"_aiuprocid",  p.sfiPriv.aiuProcId.width);
        u.signal("DBG_"+signalName+"_acelock",    p.sfiPriv.aceLock.width);
        u.signal("DBG_"+signalName+"_acecache",   p.sfiPriv.aceCache.width);
        u.signal("DBG_"+signalName+"_aceprot",    p.sfiPriv.aceProt.width);
        u.signal("DBG_"+signalName+"_aceqos",     p.sfiPriv.aceQoS.width);
        u.signal("DBG_"+signalName+"_aceregion",  p.sfiPriv.aceRegion.width);
        u.signal("DBG_"+signalName+"_aceuser",    p.sfiPriv.aceUser.width);
        u.signal("DBG_"+signalName+"_acedomain",  p.sfiPriv.aceDomain.width);
        u.signal("DBG_"+signalName+"_aceunique",  p.sfiPriv.aceUnique.width);

        this.m.always(function(){
            /*! var p = this.param;            */
            /*! var s = this.utilsSignalName; */
            DBG_$s$_msgtype     = $s$["p.sfiPriv.msgType.msb",    "p.sfiPriv.msgType.lsb"];        
            DBG_$s$_st          = $s$["p.sfiPriv.ST.msb",         "p.sfiPriv.ST.lsb"];          
            DBG_$s$_sd          = $s$["p.sfiPriv.SD.msb",         "p.sfiPriv.SD.lsb"];          
            DBG_$s$_so          = $s$["p.sfiPriv.SO.msb",         "p.sfiPriv.SO.lsb"];          
            DBG_$s$_ss          = $s$["p.sfiPriv.SS.msb",         "p.sfiPriv.SS.lsb"];          
            DBG_$s$_errresult   = $s$["p.sfiPriv.ErrResult.msb",  "p.sfiPriv.ErrResult.lsb"];   
            DBG_$s$_aceexokay   = $s$["p.sfiPriv.AceExOkay.msb",  "p.sfiPriv.AceExOkay.lsb"];   
            DBG_$s$_aiutransid  = $s$["p.sfiPriv.aiuTransId.msb", "p.sfiPriv.aiuTransId.lsb"];  
            DBG_$s$_aiuid       = $s$["p.sfiPriv.aiuId.msb",      "p.sfiPriv.aiuId.lsb"];       
            DBG_$s$_aiuprocid   = $s$["p.sfiPriv.aiuProcId.msb",  "p.sfiPriv.aiuProcId.lsb"];   
            DBG_$s$_acelock     = $s$["p.sfiPriv.aceLock.msb",    "p.sfiPriv.aceLock.lsb"];     
            DBG_$s$_acecache    = $s$["p.sfiPriv.aceCache.msb",   "p.sfiPriv.aceCache.lsb"];    
            DBG_$s$_aceprot     = $s$["p.sfiPriv.aceProt.msb",    "p.sfiPriv.aceProt.lsb"];     
            DBG_$s$_aceqos      = $s$["p.sfiPriv.aceQoS.msb",     "p.sfiPriv.aceQoS.lsb"];      
            DBG_$s$_aceregion   = $s$["p.sfiPriv.aceRegion.msb",  "p.sfiPriv.aceRegion.lsb"];   
            DBG_$s$_aceuser     = $s$["p.sfiPriv.aceUser.msb",    "p.sfiPriv.aceUser.lsb"];     
            DBG_$s$_acedomain   = $s$["p.sfiPriv.aceDomain.msb",  "p.sfiPriv.aceDomain.lsb"];   
            DBG_$s$_aceunique   = $s$["p.sfiPriv.aceUnique.msb",  "p.sfiPriv.aceUnique.lsb"];   
        });

    };

    /************************************************************
     * 
     * 
     *
     */

    u.generateDebugDocument = function(debugParams, filePath) {

        // Declare variables
        var fs = require('fs');
        var tempStruct;
        var tempField;
        var outputStringTxt = "";
        var outputStringCsv = "";
        var lsb;
        var msb;

        // Declare output text width
        var wName = 20;
        var wDescription = 50;
        var wWidth = 6;
        var wLSB = 4;
        var wMSB = 4;
        var wMaxLength = wDescription;


        var padSpaces = Array(wMaxLength).join(' ');

        Object.keys(debugParams).forEach(function(key) { 

            tempStruct = debugParams[key];
            lsb = 0;
            msb = -1;

            // Output text file
            outputStringTxt = outputStringTxt + "\n" + tempStruct.structureName + " - (Structure ID: " + tempStruct.structureId + ", " + tempStruct.nEntries + " entries)" + "\n\n" + 
                                                String("Field Name" + padSpaces).slice(0, wName) + 
                                                String("Width" + padSpaces).slice(0, wWidth) + 
                                                String("LSB" + padSpaces).slice(0, wLSB) + 
                                                String("MSB" + padSpaces).slice(0, wMSB) + 
                                                String("Description" + padSpaces).slice(0, wDescription) + "\n";

            outputStringTxt = outputStringTxt + String("----------" + padSpaces).slice(0, wName) + 
                                                String("-----" + padSpaces).slice(0, wWidth) + 
                                                String("---" + padSpaces).slice(0, wLSB) + 
                                                String("---" + padSpaces).slice(0, wMSB) + 
                                                String("-----------" + padSpaces).slice(0, wDescription) + "\n";

            Object.keys(tempStruct).forEach(function(key2) { 

                tempField = tempStruct[key2];
                lsb = msb + 1;

                if ((Object.keys(tempField).length > 0) && (typeof(tempField) != "string")) { // Parse to output only the fields

                    msb = msb + tempField.width;

                    // Output text file
                    outputStringTxt = outputStringTxt + String(tempField.name + padSpaces).slice(0, wName) + 
                                                        String(tempField.width + padSpaces).slice(0, wWidth) + 
                                                        String(lsb + padSpaces).slice(0, wLSB) + 
                                                        String(msb + padSpaces).slice(0, wMSB) + 
                                                        String(tempField.description + padSpaces).slice(0, wDescription) + "\n";

                    // Output CSV file

                    outputStringCsv = outputStringCsv + tempStruct.structureName + "," + 
                                                        tempStruct.structureId + "," + 
                                                        tempField.name + "," + 
                                                        tempField.width + "," + 
                                                        lsb + "," + 
                                                        msb + "," + 
                                                        tempField.description + "," + "\n";

                }

            });

        });

        fs.writeFile(filePath+".txt", outputStringTxt, function(err) {
            if(err) {
                return console.log(err);
            }
        }); 

        fs.writeFile(filePath+".csv", outputStringCsv, function(err) {
            if(err) {
                return console.log(err);
            }
        }); 

    };

    //------------------------------------------------------------
    // 
    //------------------------------------------------------------
    
//    u.log('----- Utils initialized. -----');

    //------------------------------------------------------------
    // Return the fully formed utilities object.
    //------------------------------------------------------------
    return u;



}
