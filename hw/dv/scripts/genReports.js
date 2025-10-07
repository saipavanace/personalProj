/*
  Author: David Clarino
  Date:   6/2/16

  Usage:
  report_config_grid.js <testlist> <directory>
*/

var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var spawnSync = require('child_process').spawnSync;
var proc = require('child_process');
var fs =require('fs');
var path= require('path');
var cli = require('commander');

/*
  EXPORT FUNCTIONS
*/
module.exports = {
    getConsoleStr : get_console_str,
    getHtmlStr    : get_html_str
}
/*
  IMPORT FUNCTIONS
*/


//Get Numfails
function get_console_str(directory, parse_results, test_results) {
    var num_passes = 0;
    var didnotrun = 0;
    var total_wall_time = 0;
    var total_sim_cycles = 0;
    var sim_period = 10;
    for(var config in parse_results.configs) {
	if(parse_results.configs[config].compile_passfail)
	    num_passes += parse_results.configs[config].test_passes.length;
	else
	    didnotrun += parse_results.configs[config].test_fails.length;
	total_wall_time += Math.ceil(parse_results.configs[config].wall_time);
	total_sim_cycles += (parse_results.configs[config].sim_time) / 10;
    }
    var print_str = '';
    var num_failed = parse_results.num_tests - num_passes - didnotrun;
    print_str += '\n********************************************************\n'
    print_str += 'Total tests    : ' + parse_results.num_tests + '\n'
    print_str += 'Passed         : ' + num_passes + '\n'
    print_str += 'Pass Rate      : ' + (100 * (num_passes / parse_results.num_tests)).toFixed(2) + '%\n'
    print_str += 'Failed         : ' + num_failed + '\n'
    print_str += 'Did Not Run    : ' + didnotrun + '\n'
    print_str += 'Failed compile : ' + parse_results.fail_configs.length + '\n'
    print_str += 'Wall time      : ' + secondsToTime(total_wall_time) + '\n'
    print_str += 'Total Cycles   : ' + scientificFormat(total_sim_cycles) + '\n'    
    var bucket_str = '\n\nSignature List'
    bucket_str += '\n==========================\n'
    bucket_str += '\#    Fails\t' + 'Signature' + Array(42).join(' ') + '\tSuggested test\n'

    var config_str = '\n\n\nBucket#  Configs'
    config_str += '\n==========================\n'




    var i = 0
    for(var bucket in parse_results.buckets) {

	bucket_str += padright(i.toString(), 5)
	bucket_str += padright((parse_results.buckets[bucket].num_fails).toString(), 9)
	bucket_str += padright(parse_results.buckets[bucket].display_val, 50) + '\t'
	bucket_str += parse_results.buckets[bucket].suggested;
	bucket_str += '\n'    

	config_str += padright(i.toString(), 9);
	config_str += Object.keys(parse_results.buckets[bucket].configs).join(' ');
	config_str += '\n'
	i++;
    }
    var table_str = '\n\nFailures By Config'
    table_str += '\n==========================\n'

    if((Object.keys(parse_results.buckets).length > 0) || (parse_results.fail_configs.length > 0)) {
	//get max width
	var max_width = -1
	for(var config in parse_results.configs) {
	    if(config.length > max_width)
		max_width = config.length
	}

	table_str += '\n' + padright('Configs',max_width)
	var i = 0;
	for(var bucket in parse_results.buckets) {
	    table_str += ' ' + padright(i.toString(),4);
	    i++;
	}

    
	for(var config in parse_results.configs) {
	    table_str += '\n' + padright(config, max_width);
	    for(var bucket in parse_results.buckets) {
		table_str += '|'
		if(parse_results.configs[config].compile_passfail == 1) {
		    if(parse_results.buckets[bucket].configs[config] === undefined) 
			table_str += padright(' ', 4);//write_pass_fail('&#x2714', 1)
		    else
			table_str += padright(parse_results.buckets[bucket].configs[config].toString(), 4);
		} else {
		    table_str += 'XXXX';
		}
	    }
	    if(parse_results.configs[config].lint_pass == 0) {
		exit_code = 1;
		failing_configs.push(config);
	    }
	}
    } else {
	if(parse_results.fail_configs == 0)
	    table_str += '\n NO FAILURES'
    }
    print_str += bucket_str
    print_str += table_str
    //    print_str += bucket_str

    var pass_rate_str = '\n\n\n' + padright('P/Tot', 10) + 'Failing Configs';
    pass_rate_str += '\n==========================\n'
    for(var config in parse_results.configs) {
	var tot_tests = parse_results.configs[config].test_passes.length + parse_results.configs[config].test_fails.length
	var pass_fail_str = parse_results.configs[config].test_passes.length + '/' + tot_tests
	if(tot_tests > parse_results.configs[config].test_passes.length) {
	    pass_rate_str += padright(pass_fail_str, 10)
	    pass_rate_str += config;
	    pass_rate_str += '\n'
	}
    }
//    print_str += pass_rate_str;
//    print_str += '\n********************************************************\n'
    print_str += '\n\n'
    return print_str;
}

function get_html_str(directory, parse_results, test_results, no_header) {
    var num_passes = 0;
    var didnotrun = 0;
    for(var config in parse_results.configs) {
	if(parse_results.configs[config].compile_passfail)
	    num_passes += parse_results.configs[config].test_passes.length;
	else
	    didnotrun += parse_results.configs[config].test_fails.length;
    }

    var print_str = '';
    if(no_header === undefined) {
    print_str += '<html><head>';
    var css_str = "<style type=\"text/css\">";
	//*****CSS*****
	css_str += "table { border-collapse: collapse; }"
	css_str += "td { border: 1px solid #333333 ;padding: 10px;}"
	css_str += "td.empty { border: 0px solid white }"
	css_str += ".pass_class { background-color: #9AFF9A }"
	css_str += ".fail_class { background-color: #F2473F }"
	css_str += ".warn_class { background-color: #fbe275 }"
	css_str += ".horizontal_th { background-color: #5F9F9F; color: white; vertical-align: text-bottom}"
	css_str += "</style>";

	
	//*****OVERALL STATISTTICS******
	print_str += css_str + "</head>";
    }
    var num_failed = parse_results.num_tests - num_passes - didnotrun;
    print_str += '<br>********************************************************\n'
    print_str += '<br>Total tests    : ' + parse_results.num_tests + '\n'
    print_str += '<br>Passed         : ' + num_passes + '\n'
    print_str += '<br>Pass Rate      : ' + (100 * (num_passes / parse_results.num_tests)).toFixed(2) + '%\n'
    print_str += '<br>Failed         : ' + num_failed + '\n'
    print_str += '<br>Did Not Run    : ' + didnotrun + '\n'
    print_str += '<br>Failed compile : ' + parse_results.fail_configs.length + '\n'
//    print_str += '<br>Wall time      : ' + secondsToTime(total_wall_time) + '\n'
//    print_str += '<br>Total Cycles   : ' + scientificFormat(total_sim_cycles) + '\n'    

    
    //*****SHOW LEGEND******
/*    var bucket_str = '<br>\n\nSignature List'
    bucket_str += '<br>==========================\n'
    bucket_str += '<br>\#  Signature' + Array(42).join(' ')
    //    bucket_str += '<br>\#    Fails\t' + 'Signature' + Array(42).join(' ')
    var i = 0
    for(var bucket in parse_results.buckets) {
	bucket_str += '<br>'
	bucket_str += padright(i.toString(), 5)
	bucket_str += padright((parse_results.buckets[bucket].num_fails).toString(), 9)
	bucket_str += padright(parse_results.buckets[bucket].display_val, 50) + '\t'
	bucket_str += parse_results.buckets[bucket].suggested;
	bucket_str += '\n'
	i++;
    }
*/
    var bucket_str = '\n\n<h2>Signature List</h2>\n\n<table border="0">'
    bucket_str += '<tr><th>#  <th>Signature' + Array(42).join(' ')
    //    bucket_str += '<br>\#    Fails\t' + 'Signature' + Array(42).join(' ')
    var i = 0
    for(var bucket in parse_results.buckets) {
	bucket_str += '<tr>'
	bucket_str += '<td>' + padright(i.toString(), 5)
	bucket_str += '<td>' + padright((parse_results.buckets[bucket].num_fails).toString(), 9)
	bucket_str += '<td>' + padright(parse_results.buckets[bucket].display_val, 50) + '\t'
	bucket_str += '<td>' + parse_results.buckets[bucket].suggested;
	bucket_str += '\n'
	i++;
    }
    bucket_str += '</table>'
//    print_str += bucket_str

    //*****GEN TABLE******
    var table_str = '<table cellpadding=5px>'
    var head_class_string = '<tr><th><th class=\"horizontal_th\" colspan=\"'+ i + '\">Buckets'
    head_class_string += '<tr><th class=\"horizontal_th\">Configs'
    var i = 0;
    for(var bucket in parse_results.buckets) {
	head_class_string += '<th class=\"horizontal_th\">' + i++
    }
    table_str += head_class_string;
    for(var config in parse_results.configs) {
	table_str += '<tr><td class=\"horizontal_th\">' + config
	for(var bucket in parse_results.buckets) {
	    if(parse_results.configs[config].compile_passfail == 1) {
		if(parse_results.buckets[bucket].configs[config] === undefined) 
		    table_str += '<td>';//write_pass_fail('&#x2714', 1)
		else
		    table_str += write_pass_fail(parse_results.buckets[bucket].configs[config], 0)
	    } else {
		table_str += write_pass_fail('&#x2716', 0)
	    }
	}
	table_str += '\n'
    }
    table_str += '</table>'
    table_str += bucket_str;
    if(no_header === undefined)
	table_str += '</html>'
    
    print_str += table_str;
    return print_str;
}

function padright(str, num) {
    var return_str = str;
    if(num > str.length) {
	for(var i = str.length; i < num; i++)
	    return_str += ' '
    } else {
	return_str = str.substring(0,num);
    }
    return return_str;
}

function write_pass_fail(write_str, write_cond) {
    var cell_str = ''
    if(write_cond) {
	cell_str = '<td class=\"pass_class\">' + write_str;
    } else {
	cell_str = '<td class=\"fail_class\">' + write_str;
    }
    return cell_str;
}


function secondsToTime(my_time) {
    var hr  = Math.floor(my_time / 3600);
    var min = pad(Math.floor((my_time % 3600) / 60), 2);
    var sec = pad((my_time % 3600) % 60, 2);
    return hr + ':' + min + ':' + sec
}
function scientificFormat(cycles) {
    var pow = Math.floor(Math.log10(cycles));
    var val = (cycles / (Math.pow(10,pow)));
    val = val.toFixed(5);
    return val + '*10^' + pow;
}
function pad(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
}
