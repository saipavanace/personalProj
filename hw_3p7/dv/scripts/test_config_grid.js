/*
  Author: David Clarino
  Date:   1/9/16

  Usage:
  test_config_grid.js <testlist> <directory>
*/
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var spawnSync = require('child_process').spawnSync;
var proc = require('child_process');
var fs =require('fs');
var path= require('path');


var run_grid = require(process.env.WORK_TOP + '/dv/scripts/run_config_grid.js');
var testlist = process.argv[2];
var directory = process.argv[3];
var test_results = run_grid.run_grid(testlist,directory,0);
fs.writeFileSync(directory + '/test_results.json', JSON.stringify(test_results), 'utf8');
//var test_results = require(directory + '/test_results.json').test_results;
console.log(test_results);
try {
    fs.unlinkSync(directory + '/lslist');
} catch(err){};

var num_tests = 0
var test_string="\n"
var files = fs.readdirSync(directory);
var failing_compiles = [];
var failing_lint = [];
var has_lint = 0
test_results.forEach( function(result) {

    if(result.run_type == 'test') {
	test_string += result.dest_dir + '\n'
	num_tests++;
    }
    if(result.run_type == 'lint') {
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
	    if(line.match(/(\s+)?Error\s+/)) {
		lint_pass=0
	    }
	});

	if(lint_pass == 0)
	    failing_lint.push(result.env_name + '_' + result.config_name + ' Lint FAILED\nPlease see ' + exe_dir + '/lint.log for information on Lint failures');
	
    }
    if(result.run_type == 'compile') {
//	var filename = directory + '/' + result.env_name + '_' + result.config_name + '_compile.o' + result.job_no
	var exe_dir = directory + '/debug/' + result.env_name + '/' + result.config_name


	var achl_pass = 0;
	var vcs_pass = 0;
	if(result.is_full) {
	    var filename = exe_dir + '/compile.out'
	    var file_contents = fs.readFileSync(filename).toString();
	    if(file_contents.match(/VCS\ compile\ successful/)) {
		vcs_pass = 1;
		achl_pass = 1;
	    }
	} else {
	    var filename = exe_dir + '/compile.out'
	    var file_contents = fs.readFileSync(filename).toString().split('\n');
	    file_contents.forEach(function(line) {
		if(line.match(/ACHL\ compile\ successful/)) {
		    achl_pass = 1;
		}
		if(line.match(/VCS\ compile\ successful/)) {
		    vcs_pass = 1;
		}
	    });
	}
	if(achl_pass == 0)
	    failing_compiles.push(result.env_name + '_' + result.config_name + ' ACHL compile FAILED\nPlease see ' + exe_dir + '/compile.err for information on ACHL or Prep failures');

	if((vcs_pass == 0) && (result.has_vcs == 1)) 
	    failing_compiles.push(result.env_name + '_' + result.config_name + ' VCS compile FAILED\nPlease see ' + exe_dir + '/compile.out for information on VCS failures');

    }
});
console.log('\n\n')
console.log('\n\n')
//FIXME make better bucketize
fs.writeFileSync(directory + '/lslist', test_string,'utf8');
var report_str = execSync('python $WORK_TOP/dv/scripts/bucketize.py +run_dir=' + directory + ' +latest_only +num_tests=' + num_tests).toString();
var has_failure = 0;
if(failing_compiles.length == 0) {
    report_str += "\n************************************************";
    report_str += "\n             ALL COMPILES SUCCESSFUL            ";
    report_str += "\n************************************************";    
} else {
    report_str += "\n************************************************";
    report_str += "\n             BELOW COMPILES FAILED              ";
    report_str += "\n************************************************";    

    failing_compiles.forEach(function(line) {
	report_str += '\n' + line;
    });
    has_failure=1
}
if(has_lint) {
    if(failing_lint.length == 0) {
	report_str += "\n************************************************";
	report_str += "\n             ALL LINT SUCCESSFUL                ";
	report_str += "\n************************************************";    
    } else {
	report_str += "\n************************************************";
	report_str += "\n             BELOW LINT FAILED                  ";
	report_str += "\n************************************************";    

	failing_lint.forEach(function(line) {
	    report_str += '\n' + line;
	});
	has_failure=1
    }
}
fs.writeFileSync(directory + '/test_report', report_str,'utf8');
console.log(report_str);
process.on('exit', function() {
    process.exit(has_failure);
})

