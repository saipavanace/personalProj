/*
  Author: David Clarino
  Date:   6/2/16

*/


var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var spawnSync = require('child_process').spawnSync;
var proc = require('child_process');
var fs =require('fs');
var path= require('path');
var numnoreport = 0;

module.exports = {
    bucketize         : bucketize,
    partial_bucketize : partial_bucketize
}

function bucketize(directory, test_results, keep_dirs) {
    var parse_results             = {};
    var buckets                   = {};
    var configs                   = {};
    var return_obj                = {};
    var compiles                  = {};
    numnoreport                   = 0;
    test_results.forEach( function(result) {
	var cur_label = result.label;
	if(result.run_type == 'test') {
	    if((cur_label === '') || (cur_label === undefined)) {
		cur_label = 'UNLABELED'
	    }
	    if(configs[cur_label] === undefined) {
		parse_results[cur_label] = {};
		parse_results[cur_label].num_tests       = 0;
		parse_results[cur_label].fail_configs    = [];

		configs[cur_label] = {};
		buckets[cur_label] = {};
	    }

	    if(configs[cur_label][result.config_name] === undefined) {
		configs[cur_label][result.config_name]                   = {};
		configs[cur_label][result.config_name].test_passes       = [];
		configs[cur_label][result.config_name].test_fails        = [];
		configs[cur_label][result.config_name].wall_time         = 0;
		configs[cur_label][result.config_name].sim_time          = 0;
		configs[cur_label][result.config_name].env_name          = result.env_name;
		if(compiles[result.config_name] === undefined) {
		    var cur_config = configs[cur_label][result.config_name];
		    var check_config = cur_config;
		    var compile_logs = fs.readdirSync(directory + '/debug/' + result.env_name + '/' + result.config_name).toString();
		    if((compile_logs.indexOf('full_compile.out') >= 0) || (compile_logs.indexOf('full_compile.err') >= 0)) {
			result.is_full = 1;
		    } else {
			result.is_full = 0;
		    }
		    var check_config = check_compiles(directory, cur_config, result);
		    cur_config.compile_passfail = check_config.compile_passfail;
		    // var err = new Error("ERROR! There wasn't a compile for config" + result.config_name + " in this regression!");
		    // throw err;
		} else {
		    configs[cur_label][result.config_name].compile_passfail  = compiles[result.config_name].compile_passfail;
		    configs[cur_label][result.config_name].achl_passfail     = compiles[result.config_name].achl_passfail;
		    configs[cur_label][result.config_name].prep_passfail     = compiles[result.config_name].prep_passfail;
		    if(compiles[result.config_name].lint_pass !== undefined) {
			configs[cur_label][result.config_name].lint_pass = compiles[result.config_name].lint_pass;
		    }
		}
	    }
	    var cur_config = configs[cur_label][result.config_name];
	} else {
	    if((cur_label === '') || (cur_label === undefined)) {
		cur_label = 'UNLABELED'
	    }
	    if(result.run_type == 'lint') {
		if(configs[cur_label] === undefined) {
		    parse_results[cur_label] = {};
		    parse_results[cur_label].num_tests       = 0;
		    parse_results[cur_label].fail_configs    = [];

		    configs[cur_label] = {};
		    buckets[cur_label] = {};
		}
	    }
	    if(compiles[result.config_name] === undefined) {
		compiles[result.config_name]                   = {};
		compiles[result.config_name].compile_passfail  = 0;
		compiles[result.config_name].env_name          = result.env_name;
		compiles[result.config_name].achl_passfail     = 0;
		compiles[result.config_name].prep_passfail     = 0;
		compiles[result.config_name].wall_time         = 0;
		compiles[result.config_name].sim_time         = 0;
	    }
	}



	if(result.run_type == 'test') {
	    configs[cur_label][result.config_name] = check_tests(directory, cur_config, result, buckets[cur_label],keep_dirs);
	    parse_results[cur_label].num_tests++;
	} else if(result.run_type == 'lint') {
	    
	    compiles[result.config_name] = check_lint(directory, compiles[result.config_name], result);
	} else if(result.run_type == 'compile') {
	    compiles[result.config_name] = check_compiles(directory, compiles[result.config_name], result);
	    if((compiles[result.config_name].achl_passfail == 0) || (compiles[result.config_name].prep_passfail == 0) || (compiles[result.config_name].compile_passfail == 0)) {
		for(var label in configs) {
		    parse_results[label].fail_configs.push(result);
		}
	    }
	}
    });
    
    for(var label in parse_results) {
	parse_results[label].buckets = buckets[label];
	parse_results[label].configs = configs[label];
    }

    return_obj.parse_results = parse_results;
    return_obj.compiles      = compiles;
    return return_obj;
}

function partial_bucketize(directory,run_jobs) {
    execSync('sleep 5s');
    var new_results = bucketize(directory, run_jobs, 1);
}

function merge_results(new_results, old_results) {

}

function check_lint(directory, cur_config,result) {
    has_lint=1
    var lint_pass=1
    var exe_dir = directory + '/debug/' + result.env_name + '/' + result.config_name
    try {
	var lintContents = fs.readFileSync(exe_dir + '/lint.log').toString();
    } catch(err) {
	if(err) {
	    lint_pass = 0;
	    var lintContents = ""
	}
    }
    var lintContents_lines = lintContents.split(/\n/);
    lintContents_lines.forEach( function(line,cur_line) {
	if(line.match(/(\s+)?Error\s+/) || line.match(/FATAL/)) {
	    lint_pass=0
	}
    });
    cur_config.lint_pass = lint_pass
    return cur_config;
}
function check_compiles(directory, cur_config,result) {

    if(result.is_full) {
	try {
	    var fileContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/compile.out', 'utf8').toString();
	} catch(err) {
	    if(err)
		var fileContents = ""
	}
	// ==== CHECK ACHL ====
	if(fileContents.match(/VCS\ compile\ successful/)) {
	    cur_config.compile_passfail = 1;
	    cur_config.achl_passfail = 1;
	    cur_config.prep_passfail=1;
//	    var cmd_str = "/engr/dev/tools/script/tarf/tlog.js -s passed -c \"" + result.cmd + "\" -r " + result.run_name + " -t " + result.env_name + '/' + result.config_name + '/compile' + " -e " + process.env.HOSTNAME +  " -u " + process.env.USER + " -p \"" + directory + "\"";
//	    execSync(cmd_str);
	}

    } else {
	try {
	    var fileContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/compile.out', 'utf8').toString();
	} catch(err) {
	    if(err)
		var fileContents = ""
	}

	if((result.has_vcs == 1) || (result.run_type !== 'compile')) {
	    if(fileContents.match(/VCS\ compile\ successful/))
		cur_config.compile_passfail = 1;
	    // ==== CHECK PREP ====
	    if (fileContents.match(/Successfully\ generated\ dv\ files/))
		cur_config.prep_passfail=1;

	} else {
	    cur_config.compile_passfail = 1;	    
	    cur_config.prep_passfail=1;
	}

	// ==== CHECK ACHL ====
	if((result.has_achl == 0) || (fileContents.match(/ACHL compile successful/))) {
	    cur_config.achl_passfail = 1;
	}
	if (fileContents.match(/Successfully\ generated\ dv\ files/))
	    cur_config.prep_passfail=1;

	if((cur_config.compile_passfail == 0) || (cur_config.achl_passfail == 0) || (cur_config.prep_passfail == 0)) {
//	    var cmd_str = "/engr/dev/tools/script/tarf/tlog.js -s failed -c \"" + result.cmd + "\" -r " + result.run_name + " -t " + result.env_name + '/' + result.config_name + '/compile' + " -e " + process.env.HOSTNAME +  " -u " + process.env.USER + " -p \"" + directory + "\"";
//	    execSync(cmd_str);

	} else {
//	    var cmd_str = "/engr/dev/tools/script/tarf/tlog.js -s passed -c \"" + result.cmd + "\" -r " + result.run_name + " -t " + result.env_name + '/' + result.config_name + '/compile' + " -e " + process.env.HOSTNAME +  " -u " + process.env.USER + " -p \"" + directory + "\"";
//	    execSync(cmd_str);
	}
    }    
    return cur_config;
}

function check_tests(directory, cur_config, result,buckets,keep_dirs) {
    var node_run = '';
    try {
	var fileContents = fs.readFileSync(result.dest_dir + '/vcs.log').toString();
    } catch(err) {
	if(err)
	    var fileContents = ""
    }
    var lines = fileContents.split('\n');

    var check_config = check_compiles(directory, cur_config, result);
    cur_config.compile_passfail = check_config.compile_passfail;
    var total_wall_time = 0;
    if(cur_config.compile_passfail) {
	var saw_passed = 0
	if(fileContents.match(/UVM\ PASSED/)) {
	    saw_passed = 1
	} else {
	    cur_config.test_fails.push(result);
	}

	var found_error = 0;
	var assert_error = 0;
	var assert_bucket = 0;
	var next_line_is_time = 0;
	lines.forEach(function(cur_line) {
	    if(cur_line.match(/total\:\s+wall\s+time/)) {
		cur_config.wall_time += getWallTime(cur_line, result.is_questa);
	    }
	    if(cur_line.match(/Elapsed\ Wallclock\ Time\:/)) {
		cur_config.wall_time += getWallTime(cur_line, result.is_questa);
	    }
	    if((next_line_is_time == 1) || cur_line.match(/^\$finish\s+at\s+simulation\s+time/)) {
		cur_config.sim_time += getSimTime(cur_line);
		next_line_is_time = 0;
	    }
	    if(cur_line.match(/^\*\*\s+Note\:\s+\$finish/)) {
		next_line_is_time = 1;
	    }
	    if((found_error  == 0) && (assert_error == 0) && (cur_line.match(/^UVM_ERROR\ [@/]/) || cur_line.match(/^UVM_FATAL\ [@/]/))) {

	        var bucket      = '[' + cur_line.split('[')[1].substring(0,99);
		var display_val = bucket.substring(0,50);
	        if(bucket.length < 51) {
		    for(var i = 0; i < 51 - bucket.length;i++) {
			display_val += ' ';
		    }
		}
		if(buckets[bucket] === undefined) {
		    add_bucket(buckets,bucket,display_val,result.dest_dir);
		}
		incr_bucket(buckets, bucket, result.config_name, result.dest_dir);

		found_error = 1;
	} else if((found_error == 0) && (assert_error == 0) && (((cur_line.match(/^\*\*\ Fatal\:/) || cur_line.match(/^\*\*\ Error\:/)) && !(cur_line.match(/XPROP/))) || cur_line.match(/Offending/))) {
		 assert_bucket      = cur_line;
		 assert_error = 1;
	     }
         });
        if(found_error == 0) {
	    if(assert_error == 1) {
		var bucket = assert_bucket.replace(/^\s+/, '');
	        var display_val = bucket.substring(0,50);
		if(buckets[bucket] === undefined) {
		    add_bucket(buckets,display_val,display_val,result.dest_dir);
		}
		incr_bucket(buckets,display_val,result.config_name,result.dest_dir);
	    } else if(saw_passed == 1) {
		try {
		    var chkr_log   = fs.readFileSync(result.dest_dir + '/checker.log').toString();
		    var chkr_lines = chkr_log.split('\n');
		    var found_first_err = 0;
		    chkr_lines.forEach(function(chkr_line) {
			if(chkr_line.match(/CHKRERROR/) && (found_first_err != 1)) {
			    bucket      = chkr_line.substring(0,79);
			    found_first_err = 1;
			}
		    });

		} catch(err) {
		    var chkr_log   = "";
		    var found_first_err = 0;
		}
		if(found_first_err) {
	            var display_val = bucket.substring(0,50);
		    if(buckets[display_val] === undefined) {
			add_bucket(buckets,display_val,display_val,result.dest_dir);

		    }
		    incr_bucket(buckets,display_val,result.config_name,result.dest_dir);
		} else {
		    cur_config.test_passes.push(result.dest_dir);
		    if(keep_dirs == 0) {
			var files = fs.readdirSync(result.dest_dir);
			files.forEach(function(filename) {
			    if(!filename.match(/simv\.vdb/) && !filename.match(/ucdb/))
				fs.unlinkSync(result.dest_dir + '/' + filename);
			});
		    }
		}
	    } else {
		var bucket = numnoreport;
		numnoreport += 1;
		add_bucket(buckets,bucket,"Test didn't report pass or fail",result.dest_dir);
		incr_bucket(buckets, bucket,result.config_name,result.dest_dir);
	    }
	}
    }    
    cur_config.wall_time += total_wall_time;
    return cur_config;
}
function add_bucket(buckets, bucket_name, display_val, suggested) {
    if(typeof bucket_name != "string")
	bucket_name = bucket_name.toString();
    buckets[bucket_name]             = {};
    buckets[bucket_name].display_val = bucket_name;
    buckets[bucket_name].configs     = {};
    buckets[bucket_name].num_fails   = 0;
    if(bucket_name.match(/CHKRERROR/)) {
	buckets[bucket_name].suggested   = suggested + '/checker.log';
    } else {
	buckets[bucket_name].suggested   = suggested + '/vcs.log';
    }
    buckets[bucket_name].faildirs    = []

}

function incr_bucket(buckets, bucket_name, config_name, dest_dir) {
    if(buckets[bucket_name].configs[config_name] === undefined) 
	buckets[bucket_name].configs[config_name] = 1;
    else 
	buckets[bucket_name].configs[config_name]++;
    buckets[bucket_name].num_fails++;
    buckets[bucket_name].faildirs.push(dest_dir);
}

function get_bucket(cur_line, result) {
    var bucket      = '[' + cur_line.split('[')[1].substring(0,99);

//    var bucket      = cur_line.split('[')[0].substring(0,79);
    if(bucket.match(/Checker\ Error/)) {
	var chkr_log   = fs.readFileSync(result.dest_dir + '/checker.log').toString();
	var chkr_lines = chkr_log.split('\n');
	var found_first_err = 0;
	chkr_lines.forEach(function(chkr_line) {
	    if(chkr_line.match(/CHKRERROR/) && (found_first_err != 1)) {
		bucket      = chkr_line.substring(0,79);
		found_first_err = 1;
	    }
	});
    }
    return bucket;
}
function record_fail(result,bucket) {
//    var cmd_str = "/engr/dev/tools/script/tarf/tlog.js -s failed -c \"" + result.cmd + "\" -r " + result.run_name + " -t " + result.env_name + '/' + result.config_name + '/test' + result.id + " -e " + process.env.HOSTNAME +  " -u " + process.env.USER + " -p \"" + directory + "\" -d \"" + bucket + "\"\n";
//    execSync(cmd_str);
    execSync('sleep 1s');
}
function record_pass(result) {
//    var cmd_str = "/engr/dev/tools/script/tarf/tlog.js -s passed -c \"" + result.cmd + "\" -r " + result.run_name + " -t " + result.env_name + '/' + result.config_name + '/test' + result.id + " -e " + process.env.HOSTNAME +  " -u " + process.env.USER + " -p \"" + directory + "\"\n";
//    execSync(cmd_str);
    execSync('sleep 1s');
}
function getWallTime(cur_line, is_questa) {
    if(is_questa) {
	var return_str = cur_line.replace(/.*total.*\:\s+wall\s+time\s+/, '');
	return_str = return_str.replace(/\s+s/, '');	
    } else {
	var return_str = cur_line.replace(/Elapsed\s+Wallclock\s+Time\:/,'')
	return_str = return_str.replace(/\s+seconds.*/,'');
    }

    var return_int = parseFloat(return_str);
    return return_int;
}
function getSimTime(cur_line) {
    if(cur_line.match(/^\$finish\s+at\s+simulation\s+time/)) {
	var return_str = cur_line.replace(/^\$finish\s+at\s+simulation\s+time/, '');
    } else {
	var return_str = cur_line.replace(/^\s+Time\:\s+/, '');
	return_str = return_str.replace(/\s+[munp]*s.*/, '');
    }
    if(cur_line.match(/[0-9]*\s+ns/))
	var cycle_multiplier = 1
    else if(cur_line.match(/[0-9]*\s+ps/))
	var cycle_multiplier =  .001
    else if(cur_line.match(/[0-9]*\s+us/))
	var cycle_multiplier = 1000
    else if(cur_line.match(/[0-9]*\s+ms/))
	var cycle_multiplier = 1000000
    else if(cur_line.match(/[0-9]*\s+s/))
	var cycle_multiplier = 1000000000
    
    var return_int = Math.ceil(parseInt(return_str) * cycle_multiplier);
    return return_int;
}

function parseTest(result) {
    
}
