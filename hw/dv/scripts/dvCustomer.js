'use strict;'

var fs = require('fs');
var proc = require('child_process').exec;

function dvCustomer(v1, v2) {
    var conrt = function(f1, data, action) {
        var arr = f1.split('/');
        arr.shift(); //remove first blank
        arr.pop();
        var initPath = '/';

        function createDir(arg1, _arr, f1, data, action) {
            if(_arr.length === 0) {
                action(f1, data);

            } else {
                var path  = arg1 + _arr.shift();
                fs.stat(path, function(err, stats) {
                    if(err) {
                        //console.log('mkdir: ' + path);      
                        proc('mkdir ' + path, function(err, stdout, stderr) {
                            createDir((path + '/'), _arr, f1, data, action);
                        });
                    } else if(stats.isDirectory()) {
                        //console.log('DirExists: ' + path);
                        createDir((path + '/'), _arr, f1, data, action);
                    }
                });
            }
        }
        createDir(initPath, arr, f1, data, action);
    };

    if(!process.env.WORK_TOP) {
        console.log('environment variable $WORK_TOP not defined');
        throw('err');
    }

    var val = require(process.env.WORK_TOP + '/tb');
    var p = require(v1);
    //require('/scratch2/anippuleti/fullsys_12_08_15/debug/psys/psys13/psys_13FullAchlParams.json');
    var tbBundle = val.tbgen(p);
//    console.log(JSON.stringify(tbBundle));
    //var str = JSON.stringify(p, null, '\t');
    //fs.writeFileSync('cfg.json', str, 'utf8');
    //throw 'err';

    var fname = v2 + '/';

    
    for(var key in tbBundle) {
        var wrFile = fname + key;

        conrt(wrFile, tbBundle[key], function(f1, data) {
	    if(typeof data === "object"){
		var wdata = data.data;
		var fdata = data.encoding;
	    } else {
		var wdata = data;
		var fdata = 'utf8'
	    }

            fs.writeFile(f1, wdata, fdata, function(err) {

                if(err)
                    console.log("Unable to generate file: " + f1);
            });
        });
    }

}

if(process.argv.length != 4) {
    console.log('ERROR');
    console.log("command to execute script 'node dvCustomer.js <achlParams> <outputDirectory>'");
    throw 'err';
} else {
    console.log('dvCustomer');
    dvCustomer(process.argv[2], process.argv[3]);
}
