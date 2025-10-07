//////////////////////////////////////////////
// Author : David Clarino
// Date   : 7/12/16
//////////////////////////////////////////////

//////////////////////////////////////////////
// General Variables
//////////////////////////////////////////////
var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var spawnSync = require('child_process').spawnSync;
var proc = require('child_process');
var fs =require('fs');
var path= require('path');
var cli = require('commander');


//////////////////////////////////////////////
// export functions
//////////////////////////////////////////////
module.exports = {
    runRegr : runRegr
}

//////////////////////////////////////////////
// import functions
//////////////////////////////////////////////
var run_grid = require(process.env.WORK_TOP + '/dv/scripts/run_config_grid.js').run_grid;
var getConsoleStr = require(process.env.WORK_TOP + '/dv/scripts/genReports.js').getConsoleStr;
var getHtmlStr = require(process.env.WORK_TOP + '/dv/scripts/genReports.js').getHtmlStr;
var bucketize = require(process.env.WORK_TOP + '/dv/scripts/bucketize.js').bucketize;

//////////////////////////////////////////////
// environment variables
//////////////////////////////////////////////

var scripts_dir = "/home/dclarino"
var codegen_branches = {
    "release/v1.5" : "v1.5.42"
}
//////////////////////////////////////////////
// functions
//////////////////////////////////////////////

function runRegr(branch, tags, env, label, directory, mail, workdir,keep) {
    if(env === "sys") {
	var env_dir = "sub_sys";
    } else {
	var env_dir = env
    }
    var dest_dir         = workdir + '/workdir_' + label;
    
    //******** SETUP WORK DIRECTORIES AND SET WORK_TOP ********
    console.log('Setting up ' + dest_dir + '...');
    console.log('This might take some time');
//    execSync(scripts_dir + '/setup_regr -d ' + workdir + ' -l ' + label + ' -h ' + branch + ' -c ' + codegen_branches[branch]);
    process.env['WORK_TOP'] = dest_dir + '/hw' ;
    process.chdir(process.env.WORK_TOP);

    //******** GENERATE TESTLIST ********
    console.log(tags);
    var gen_list_cmd     = 'node $WORK_TOP/dv/scripts/gen_my_regr.js -e ' + env + ' -t ' + tags
    process.chdir(process.env.WORK_TOP + '/dv/' + env_dir + '/tb')
    try {
	execSync(gen_list_cmd);
    } catch(err) {
	console.log(err);
    }

//    fs.mkdirSync(directory);

    //******** RUN TESTLIST ********
    
    var test_results = run_grid(process.env.WORK_TOP + '/dv/' + env_dir + '/tb/reglist.sh', directory,1);
    var parse_results = bucketize(directory, test_results, keep);
    var print_str = getConsoleStr(directory, parse_results, test_results);
    console.log(print_str);
    fs.writeFileSync(directory + '/regr.log',print_str,'utf8');
    console.log('Results output to ' + directory);
    var html_str = getHtmlStr(directory, parse_results, test_results);
    fs.writeFileSync(directory + '/report.html', html_str, 'utf8');
    console.log('\nHTML file output to ' + directory + '/report.html');

    if(mail !== "") {
	execSync('cat ' + directory + '/regr.log | mail -a ' + directory + '/report.html -s \"Regression ' + label + env + '\" ' + mail)
    }

}
