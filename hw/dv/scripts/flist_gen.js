var fs =require('fs');
var path= require('path');
//var OUTPUT_DIR_PATH = '/scratch/kkanth/ncore4.0/work1/hw-ncr/debug/'
function recurseHierarchy(hJson /*hierarchy json*/, key, regex) { 
    // Perform DFS on hierarchy json from a given key and (optional) filename format
    const exp  = regex ? RegExp(regex) : undefined;
    visited = {}, result = [];
    function recurse(key) {
        if (! visited[key]) {
            visited[key] = 1;
        }
        if (hJson[key] !== undefined) {
            for(k of hJson[key].includesModules){
                if (! visited[k]) {
                    recurse(k);
                }
            }
        }
    result.push(key);
    }
    recurse(key);

    if (exp) {
        return result.filter(function(v){
            return exp.test(v);
        });
    }

    return result;
}
function genBlockFList(configList) {
    var hpath = configList.exe_dir + '/output/rtl/design/hierarchy.json';
    var hJson = JSON.parse(fs.readFileSync(hpath, "utf8"));
    if(configList["instance"]) {
	var modules = [configList.params.instanceMap[configList["instance"]]];
    }
    else if(configList.cli && configList.cli.instanceName){
      var modules = [configList.params.instanceMap[configList.cli.instanceName]];

    }
    else {
	var modules = [];
	for(var i = 0; i < configList.params.AiuInfo.length; i ++) {
	    modules.push(configList.params.AiuInfo[i].strRtlNamePrefix);
	}
	for(var i = 0; i < configList.params.DceInfo.length; i ++) {
	    modules.push(configList.params.DceInfo[i].strRtlNamePrefix);
	}
	for(var i = 0; i < configList.params.DiiInfo.length; i ++) {
	    modules.push(configList.params.DiiInfo[i].strRtlNamePrefix);
	}
	for(var i = 0; i < configList.params.DmiInfo.length; i ++) {
	    modules.push(configList.params.DmiInfo[i].strRtlNamePrefix);
	}

    }
	

    //-------------------------------Block level flist generation -----------------------------------------------------------------//

    for (blk of modules) {
	mArray = [];
	ext = '.v';
	moduleArray = recurseHierarchy(hJson, blk);

	moduleArray.forEach(function(m){
            mArray.push(m);
	});

	flist = mArray.join(ext + '\n');
	flist += ext;
	fs.writeFileSync(path.resolve(configList.rtl_dir, blk + '.flist'),flist,'utf8');
    }
}
module.exports = {
    genBlockFlist : genBlockFList
}
