var run_dir = process.argv[2];
var test_results = require(run_dir + '/test_results.json');

//var test_results = require(process.argv[2]);
var outputDir    = process.argv[3];
var proc         = require('child_process');
var fs           = require('fs');
var path_str     = [];
console.log(process.argv[1]);
var configs = {};
test_results.forEach(function(config) {
    var config_name = config.env_name + '_' + config.config_name
    if(config.run_type == "compile") {
	if(configs[config_name] === undefined) {
	    configs[config_name] = {};
	    configs[config_name].total    = 0;
	    configs[config_name].finished = 0;
	    configs[config_name].test_dirs = [];
	    configs[config_name].compile = config;
	}
    } else if(config.run_type == "test") {
	if(fs.existsSync(config.dest_dir + '/vcs.log')) {
	    configs[config_name].finished++;
	    configs[config_name].test_dirs.push(config.dest_dir);
	}
	configs[config_name].total++;

    }
});

for(var config in configs) {
    if(configs[config].finished == configs[config].total) {
	console.log(config + ' DONE')
	configs[config].done = 1;
    } else {
	console.log(config + ' Ongoing or Incomplete regression -- total num of test cases: ' + configs[config].total + ' finished num of test cases: ' + configs[config].finished)
	configs[config].done = 0;
    }

}
for(var config in configs) {

    var compile_dir = process.argv[2] + '/debug/' + configs[config].compile.env_name + '/' + configs[config].compile.config_name
    var merged_ucdb = outputDir + '/' + config + '_merged.ucdb';
    //if(configs[config].done) {
	console.log(compile_dir);
	if(!fs.existsSync(merged_ucdb) && 0) {
	    configs[config].test_dirs.forEach(function(test_dir) {
		var exec_cmd ='vcover merge -out ' + merged_ucdb + ' ' + test_dir + '/*.ucdb';
		//	    console.log(exec_cmd);
		var ucdb_arr = fs.readdirSync(test_dir).filter(fn => fn.endsWith('.ucdb'));
		var ucdb_file = (ucdb_arr.length > 0) ? ucdb_arr : '0.ucdb';
		console.log(ucdb_file);
		if(ucdb_file !== undefined)
		    console.log('ucdb_file ' + ucdb_file);
		if(fs.existsSync(test_dir + '/' + ucdb_file))
		    proc.execSync(exec_cmd);
	    });
	}
	if(fs.existsSync(compile_dir + '/coverage')) {
	    var ucdb_arr = fs.readdirSync(compile_dir + '/coverage/').filter(fn => fn.endsWith('.ucdb'));
	    var ucdb_file = (ucdb_arr.length > 0) ? ucdb_arr : '0.ucdb';
	    var source_ucdb = compile_dir + '/coverage/' + ucdb_file;
	    console.log(source_ucdb);
	    if(fs.existsSync(source_ucdb)) {
		//	    var vcov_cmd = 'vcover report -instance=dut -recursive -code scef -cvg -output ' + outputDir + '/' + config + '_coverage_totals.txt ' + outputDir + '/' + config + '_merged.ucdb';
		//generate dofile
		proc.execSync('mkdir -p ' + outputDir + '/' + config + '_coverage');
		var cc_file = generateCCDoFile(configs[config],config,source_ucdb);
		//run qverify
		push_dir(outputDir + '/' + config + '_coverage');
		if((configs[config].compile.env_name !== "fsys") && !fs.existsSync(outputDir +'/' + config + "_coverage/log_top")) {

		    if(!fs.existsSync(outputDir + '/' + config + '_coverage/work'))
			proc.execSync('ln -s ' + run_dir + '/debug/' + configs[config].compile.env_name + '/' + configs[config].compile.config_name + '/exe/work work');

		    var qverify_cmd = 'qverify -c +0in_licq -od log_top -do ' + cc_file;
		    var qverify_arr = qverify_cmd.split
		    try {
			fs.writeFileSync(outputDir + '/' + config + '_coverage/qverify_cmd',qverify_cmd,'utf-8');
			var str = proc.execSync(qverify_cmd);
		    } catch(err) {
			if(err) {
			    console.log(err.toString());
			    throw err;
			}
		    }

		    //	    var exclude_cmd = "vsim -c -viewcov " + merged_ucdb + " -do \"do log_top/merged_" + config + "_exclude.do"
		}
		pop_dir();

		//run merge
		var merge_file = generateMergeDoFile(configs[config],config,merged_ucdb,outputDir + '/' + config + '_coverage');
		var exclude_cmd = "vsim -c -viewcov " + source_ucdb + " -do " + merge_file;
		var str = proc.execSync(exclude_cmd);

//		console.log(str.toString());
		var vcov_cmd = 'vcover report -instance=/tb_top/dut -recursive -code sbcef -cvg -output ' + outputDir + '/' + config + '_code_coverage_totals.txt ' + merged_ucdb;
		proc.execSync(vcov_cmd);
		var vcov_cmd = 'vcover report -cvg -output ' + outputDir + '/' + config + '_func_coverage_totals.txt ' + merged_ucdb;
		proc.execSync(vcov_cmd);
	    }
	}
    //}
}
function generateMergeDoFile(config_obj,config_name,merged_ucdb,cover_dir) {
    var str = "";
    str += "do " + outputDir + "/merged_" + config_name + "_exclude.do\n"
    str += "coverage save " + merged_ucdb + "\n";
    str += "quit -f";
    var merge_file = outputDir + '/' + config_name + '_coverage/merge_' + config_name + '.do';
    fs.writeFileSync(merge_file,str,'utf-8');
    return merge_file;
}

function generateCCDoFile(config_obj,config_name,merged_ucdb) {
    var top_file;
//    var merged_ucdb = outputDir + '/' + config_name + '_merged.ucdb';
    top_file = topFile(config_obj);
    var str = ""
    str += "# CoverCheck Section\n"
    str += "onerror {exit 1}\n"
    str += "###### add directives\n"
    str += "set DUT " + top_file + "\n"
    str += "netlist blackbox *_mem_*\n"
    str += "#netlist blackbox *fifo_*\n"
    str += "#netlist blackbox dfrre_a\n"
    str += "###### Run CoverCheck\n"
    str += "#If user loads ucdb, CoverCheck tool will autmatically take coverage spec from ucdb file\n"
    str += "#If user does not want to load ucdb or want to run CC on certain Coverage spec, here is the example\n"
    str += "covercheck disable\n"
    str += "covercheck enable -module $DUT -recursive\n"
    str += "#covercheck enable -type statement branch condition expression\n"
    str += "#User can run CC on any level of hierarchy\n"
    str += "#covercheck compile -d gen_wrapper\n"
    str += "covercheck compile -d ${DUT}\n"
    str += "#Loading of previously generated ucdb file is highly recommended but CC can also run without it\n"
    str += "#CC tool ignore what has already been covered by Simulation and will focus on missed coverage only if ucdb is loaded\n"
    str += "covercheck load ucdb " + merged_ucdb + " -mergedesigndiffs\n"
    str += "#covercheck load ucdb test0ucdb\n"
    str += "#-timeout to control CC run-time; User expects to get more inclusive if CC runs for very short time\n"
    str += "covercheck verify -timeout 30m\n"
    str += "#Command to create covderage exclusion file, User should validate exclusion before applying to Questa\n"
    str += "covercheck generate exclude " + outputDir + "/merged_" + config_name + "_exclude.do\n"
    str += "exit 0"
    var cc_file = outputDir + '/' + config_name + '_coverage/run_cc_' + config_name + '.do';
    fs.writeFileSync(cc_file,str,'utf-8');
    return cc_file;
}
function topFile(config_obj) {
    var cmd_arr = config_obj.compile.cmd.split(' ');
    var instance_name_index = cmd_arr.indexOf('-i');
    var instance_name = (instance_name_index >= 0) ? cmd_arr[instance_name_index + 1] : 'top';
    var instanceMap = require(run_dir + '/debug/' + config_obj.compile.env_name + '/' + config_obj.compile.config_name + '/exe/output/rtl/design/instanceMap.json');
    return instanceMap[instance_name];
    
}

//console.log(JSON.stringify(configs,null,' '));
		     
function push_dir(dst_dir) {

    path_str.push(process.cwd());

    try {
        process.chdir(dst_dir);
        //console.log('New: ' + process.cwd());

    } catch (err) {
        throw err;
    }

}
function pop_dir() {
    var dst_dir;

    if (path_str.length !== 0) {
        dst_dir = path_str.pop();
        try {
            process.chdir(dst_dir);
            //console.log('New: ' + process.cwd());

        } catch (err) {
            throw err;
        }
    }
}
