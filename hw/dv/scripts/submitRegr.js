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
// import functions
//////////////////////////////////////////////
var runRegr = require(process.env.WORK_TOP + '/dv/scripts/runRegr.js').runRegr;

//////////////////////////////////////////////
// cli options
//////////////////////////////////////////////
var mail = ""
var tags = ""
var environment;
var directory;
var keep;
var label;
var branch="master"
var workdir = '/scratch2/' + process.env.USER
cli
    .version('1.0')
    .option('-b, --branch <string>', '<OPTIONAL> branch of hw that will be checked out, default is master',branch)
    .option('-t, --tags <string>', '<OPTIONAL> tags that will go in regression', tags)
    .option('-l, --label <string>', '<OPTIONAL> label for this regression',label)
    .option('-d, --directory <string>', 'directory location of your regression results', directory)
    .option('-e, --environment <string>', 'name of environment regression you want to run aiu|dce|dmi|sys',environment)
    .option('-m, --mail <string>', 'If this option is set, the regression will mail the address specified when finished', mail)
    .option('-k, --keep', '<OPTIONAL> flag to keep passing directories. Default is to delete them')
    .option('-w, --workdir <string>', '<OPTIONAL> If this option is set, setup will checkout work directory under this area. Otherwise, it goes to /scratch2/$USER', workdir)
    .usage("node submitRegr.js -b <branch> [-l <label>] -d <directory> -e <environment> [-t <tags>] [-m <mail_address>] [-w <workdir location>] [-k]\n\nEXAMPLE:\n\t node submitRegr.js -b release/v1.5 -l regr -e aiu")
    .parse(process.argv);

if( cli.directory === undefined ) {
    var err_str = "ERROR! must specify -d <directory> option!"
    throw err_str;
}
if( cli.environment === undefined ) {
    var err_str = "ERROR! must specify -e <environment> option!"
    throw err_str;
}
if( cli.label === undefined ) {
    var label = execSync('date +"%Y%m%d_%H%M%S"')
    console.log('WARNING! -l option not specified, label set to ' + label);
} else {
    var label = cli.label
}

if( cli.keep === undefined) {
    var keep = 0;
} else {
    var keep = 1
}
if( cli.mail === undefined) {
    var mail = "";
} else {
    var mail = cli.mail
}
if( cli.tags === undefined) {
    var tags = [];
} else {
    var tags = cli.tags
}

/*
  RUN REGRESSION
*/

runRegr(branch,tags,cli.environment,label,cli.directory,mail,cli.workdir,keep);
