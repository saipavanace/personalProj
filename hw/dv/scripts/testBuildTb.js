'use strict';

var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var fs = require('fs');
var assert = require('assert');


//*********************************
//      test objects
//*********************************
var myTestObj;
var paramsObj;
var buildTb = require(process.env.WORK_TOP + '/dv/scripts/buildTb.js');


//*********************************
//      run_config_grid tests
//*********************************


describe('buildTb.js', function () {
    initTestObj();
//    it('testGetPkgJson', testGetPkgJson);

//    it('testSingleFilePkgJson', testSingleFilePkgJson);

//    it('testDataInherit', testDataInherit);

//    it('testChildPkgPath', testChildPkgPath);

//    it('testDataOverride', testDataOverride);

//    it('testFlist', testFlist);
//    it('testGetParamsArr', testGetParamsArr);

//    it('testGetLeafParams', testGetLeafParams);
    
});

function testGetLeafParams() {
    var testObj = myTestObj['testGetLeafParams'];
    var pkgParams = paramsObj['testGetLeafParams']

    var leafParams = buildTb.getLeafParams({}, 'objName', pkgParams.arr1[0]);
    assert.equal(leafParams.name, "obj1");
    assert.equal(leafParams.BlockId, "objName");
    
}

function testGetParamsArr() {
    var testObj = myTestObj['testGetParamsArr'];
    var pkgParams = paramsObj['testGetParamsArr'];
    var pkgArr = buildTb.genPkg(pkgParams,testObj.pkgJson.parent,"parent","",testObj);

    pkgArr.forEach(function(pkgObj) {
	var params = buildTb.getParamsArr(pkgObj, pkgObj.name, "arr1", pkgParams);
	var hasArray = 0;
	params.forEach(function(paramObj,i) {
	    hasArray = 1;
            assert.equal(paramObj.name, "obj" + (i + 1), "paramObj.name");
	    assert.equal(paramObj.BlockId, pkgObj.name + i, "paramObj.BlockId");
	});
	assert.equal(hasArray, 1, "hasArray not equal to 1");
    });

    
}

function testFlist() {
    var testObj = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		"child",
	    ]
	},
	"parent/child" : {
		"name" : "child",
		"data" : "childData",
		"formatScript" : "childScript",
		"flist" : [
		    "child.sv"
		]
	}
    }
    testObj.ffunc = {};    
}
function testChildPkgPath() {
    var testObj = myTestObj['testChildPkgPath'];
    var pkgs = buildTb.genPkg({},testObj.pkgJson.parent,"parent","",testObj);
    var childPkg;
    var numChildPkgObjs = 0;
    pkgs.forEach(function(pkgObj) {
	if(pkgObj.name == "child") {
	    childPkg = pkgObj;
	    numChildPkgObjs += 1;
	}
    });
    assert.equal(childPkg.name, "child");

}
function testDataOverride() {
    var testObj = myTestObj['testDataOverride'];

    var pkgs = buildTb.genPkg({},testObj.pkgJson.parent,"parent","",testObj);
    var childPkg;
    var numChildPkgObjs = 0;
    pkgs.forEach(function(pkgObj) {
	if(pkgObj.name == "parent_child") {
	    childPkg = pkgObj;
	    numChildPkgObjs += 1;
	}
    });

    assert.equal(childPkg.name, "parent_child");
    assert.notEqual(childPkg.name, "child");
    assert.equal(childPkg.data, "childData");
    
}


function testDataInherit() {
    var testObj = myTestObj['testDataInherit'];

    var pkgs = buildTb.genPkg({},testObj.pkgJson.parent,"parent","",testObj);
    var childPkg;
    var numChildPkgObjs = 0;
    pkgs.forEach(function(pkgObj) {
	if(pkgObj.name == "child") {
	    childPkg = pkgObj;
	    numChildPkgObjs += 1;
	}
    });
    assert.equal(childPkg.data, "data");
    assert.equal(childPkg.formatScript, "parent/parentScript.js");
    
}

function testSingleFilePkgJson() {
    var testObj = myTestObj['testSingleFilePkgJson'];
	
    var pkgs = buildTb.genPkg({},testObj.pkgJson.parent,"","",testObj);

    var childPkg;
    var numChildPkgObjs = 0;
    pkgs.forEach(function(pkgObj) {
	if(pkgObj.name == "child") {
	    childPkg = pkgObj;
	    numChildPkgObjs += 1;
	}
    });
    assert.equal(childPkg.name, "child");
    assert.equal(childPkg.data, "data");
    assert(childPkg.flist.indexOf("child.sv") >= 0);
    assert(numChildPkgObjs == 1);

}

function testGetPkgJson() {
    var testObj = myTestObj['testGetPkgJson'];

    var pkgJson = buildTb.getPkgJson("parent",testObj);

    assert.equal(pkgJson.name, "name");
}

function initTestObj() {
    myTestObj   = {};
    paramsObj = {};
    //**********testGetLeafParams**********

    var testObj = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		"child",
	    ]
	},
	"parent/child" : {
		"name" : "child",
		"data" : "childData",
		"formatScript" : "childScript",
		"flist" : [
		    "child.sv"
		]
	}
    }
    testObj.ffunc = {};
    myTestObj['testGetLeafParams'] = testObj;
    paramsObj['testGetLeafParams'] = {
	"arr1" : [
	    {
		"name" : "obj1"
	    },
	    {
		"name" : "obj2"
	    }
	],
	"param2" : 1,
	"param3" : 2
    };

    //**********testGetParamsArr**********
    var tempTestObj = {};
    tempTestObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		"child",
	    ]
	},
	"parent/child" : {
	    "name" : "child",
	    "data" : "childData",
	    "formatScript" : "childScript",
	    "flist" : [
		"child.sv"
	    ]
	}
    }
    tempTestObj.ffunc = {};
    myTestObj['testGetParamsArr'] = tempTestObj;
    paramsObj['testGetParamsArr'] = {
	"arr1" : [
	    {
		"name" : "obj1"
	    },
	    {
		"name" : "obj2"
	    }
	],
	"param2" : 1,
	"param3" : 2
    };

    //**********testChildPkgPath**********
    var testObj = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		"child",
	    ]
	},
	"parent/child" : {
		"name" : "child",
		"data" : "childData",
		"formatScript" : "childScript",
		"flist" : [
		    "child.sv"
		]
	}
    }
    testObj.ffunc = {};
    myTestObj['testChildPkgPath'] = testObj;

    //**********testDataOverride**********    
    var testObj = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",

	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		{
		    "path" : "child",
		    "name" : "parent_child"
		}

	    ]
	},
	"parent/child" : {
		"name" : "child",
		"data" : "childData",
		"formatScript" : "childScript",
		"flist" : [
		    "child.sv"
		]
	}
    }
    testObj.ffunc = {};    
    myTestObj['testDataOverride'] = testObj;


    //
    //**********testDataInherit**********
    //

    var testObj = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "formatScript" : "parentScript.js",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		{
		    "path" : "child",
		    "data" : ""
		}

	    ]
	},
	"parent/child" : {
		"name" : "child",
		"data" : "childData",
		"formatScript" : "childScript",
		"flist" : [
		    "child.sv"
		]
	}
    }
    testObj.ffunc = {};    

    myTestObj['testDataInherit'] = testObj;

    //
    //**********testSingleFilePkgJson**********
    //
    var testObj = {};
    testObj.pkgJson = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		{
		    "name" : "child",
		    "data" : "data",
		    "flist" : [
			"child.sv"
		    ]
		}
	    ]
	}
    }

    testObj.ffunc = {};

    myTestObj['testSingleFilePkgJson'] = testObj;

    //
    //**********testSingleFilePkgJson**********
    //

    var testObj = {};
    testObj.pkgJson = {};

    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "format" : "format.js",
	    "pkgs" : [
	    ]
	}
    }
    myTestObj['testGetPkgJson'] = testObj;    
}
/*function testDataInherit() {
   var testObj = {};
    testObj.pkgJson = {};
    testObj.pkgJson = {
	"parent" : {
	    "name" : "name",
	    "data" : "data",
	    "formatScript" : "parentScript.js",
	    "flist" : [
		"parent.sv"
	    ],
	    "pkgs" : [
		{
		    "name" : "child",
		    "data" : "",
		    "flist" : [
			"child.sv"
		    ]
		}
	    ]
	},
    }


    testObj.ffunc = {};
    //function genPkg(params,obj,pkgPath, destPath, testObj)
   var pkgs = buildTb.genPkg({},testObj.pkgJson.parent,"pkgPath","",testObj);
    var childPkg;
    var numChildPkgObjs = 0;
    pkgs.forEach(function(pkgObj) {
	if(pkgObj.name == "child") {
	    childPkg = pkgObj;
	    numChildPkgObjs += 1;
	}
    });
    assert.equal(childPkg.data, "data");
    assert.equal(childPkg.formatScript, "pkgPath/parentScript.js");


}
*/
