 
//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';


module.exports = function top() {
    this.defineName('unit_test');

    var u = require("../../lib/src/utils.js").init(this);


    this.blah = "Child!";

    u.input("b");	
    u.input("d", 4);
    u.input("xxx", 4); // The parent doesn't drive this signal...

    u.output("a");
    u.output("c", 4);
    u.output("r");
    u.output("rr", 4, "r+1");

    u.state("bb", 1, 0xF);
    u.state("dd", 4, 0);

	 this.defineState(
	     { clock: {name: 'clk', edge: 'risingEdge' }, 
	       reset: {name: 'reset_n', polarity: 'activeLow' } 
	     },
	     {name: "onebblank", type: this.bit, size: 4, resetValue: '1'.b()},
	     {name: "oneb4", type: this.bit, size: 4, resetValue: '1'.b(4)},
	     {name: "oneb1", type: this.bit, size: 4, resetValue: '1'.b(1)}
	 )
	;


    this.always( function(){

        onebblank = '0'.b(4);
        oneb1 = '0'.b(4);
        oneb4 = '0'.b(4);

});

    u.signal("q");

    u.outstate("p", "st_p", 1, 0);

    u.param("p1", "int", 0, 4);
    u.param("p4", "int", 0, 4);
    
    u.comment ("verilog // Comment!");


    // this.defineState(
    //     { clock: {name: 'clk', edge: 'risingEdge' }, 
    //       reset: {name: 'reset_n', polarity: 'activeLow' } 
    //     },
    //     {name: "bb", type: this.bit, size: 4, resetValue: "7".d(4) }
    // );

//    u.param("param_a", "int");
//    u.param("param_b", "bit");
//    u.param("param_c", "string");


    this.always(function(){
        /*! var x = "\"b\""  */
        //--verilog $display();
        //-- Hi
	bb = b;
	dd = d;
	st_p = b;
    });

    this.always(function(){
	a = bb;
	c = dd;
	q = bb;
	r = q;
    });

    u.signal("sum", 1, "a+b");
    u.state("s_sum",5,0x13,"sum");

    //this.svProperty( {genAssert: true, genCover: false}, {name: 'test1', cond:'!(a&&b)'});

//    u.assert( 'assert1', '!(a&&b)');
//    u.cover( 'cover1', '(a&&b)');

    this.paramSchema.properties["p2"]={};
    this.paramSchema.properties["p2"].value=3;
    u.comment(u.paramReport());

};
//* eslint no-undef:0 *   /
