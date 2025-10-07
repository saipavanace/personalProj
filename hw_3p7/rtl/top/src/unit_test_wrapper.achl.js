//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

var UNIT = require('./unit_test.achl.js');


module.exports = function tb_unit_test() {

    var u = require("../../lib/src/utils.js").init(this);                                                                

    this.defineName('tb_unit_test');

    this.blah = "Parent!";

    this.instance ({ name: 'unit_test', moduleName: UNIT, params: {
        p1: 1,
        p2: 2,
        p3: 3
    } });

    u.signal("a");
    u.signal("c", 12); //ERR
    u.signal("r");
    u.signal("p");

    this.always( function(){
	unit_test.b = '1'.b(1);
	unit_test.d = '1'.b(14);

	a = unit_test.a;
	c = unit_test.c;
	r = unit_test.r;
	p = unit_test.p;
    });

};
//* eslint no-undef:0 *   /
