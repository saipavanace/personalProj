var fs   = require('fs');
var path = require('path');
var proc = require('child_process');

var regr_dir = process.argv[2];
var test_results = require(regr_dir + '/test_results.json');
console.log(test_results);
var configs = {};

test_results.forEach(function(item) {
    if(item.run_type == 'compile') {
	configs[item.env_name + '_' + item.config_name] = {
	    'merge_ucdb' : regr_dir + '/debug/' + item.env_name + '/' + item.config_name + '/coverage/merged_' + item.config_name + '.ucdb',
	    'dirs'       : []
	};

    } else if(item.run_type == 'test') {
	var cmd = item.cmd.split(' ');
	var seed_index = cmd.indexOf('-R');
	if(seed_index != -1)
	    configs[item.env_name + '_' + item.config_name].dirs.push(item.dest_dir + '/test' + cmd[seed_index + 1] + '.ucdb');

    }
});

for(var config in configs) {
    if(configs[config].dirs.length > 0) {
	var cmd = 'vcover merge ' + configs[config].dirs[0] + ' -out ' + configs[config].merge_ucdb;
	console.log(cmd);
	proc.execSync(cmd);
    }
    for(var i = 1; i < configs[config].dirs.length; i++) {
	var cmd = 'vcover merge ' + configs[config].dirs[i] + ' ' + configs[config].merge_ucdb + ' -out ' + configs[config].merge_ucdb;
	console.log(cmd);
	proc.execSync(cmd);
    }
}
