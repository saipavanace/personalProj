var exec = require('child_process').exec;
var execSync = require('child_process').execSync;
var fs = require('fs');
var path = require('path');
var cli = require('commander');
var report_json;
var report_str;

var check_only = 1;
var concerto_top   = path.resolve(process.env.WORK_TOP);

var genReports     = require(process.env.WORK_TOP + '/dv/scripts/genReports.js');
var bucketize      = require(process.env.WORK_TOP + '/dv/scripts/bucketize.js').bucketize;
var run_grid       = require(process.env.WORK_TOP + '/dv/scripts/run_config_grid.js');

cli 
    .option('-d, --dest <string>', 'source file')
    .option('-b, --bucketize', 'only run bucketize')
    .parse(process.argv)
if(cli.dest)
    var directory = path.resolve(cli.dest);
else
    throw new Error("Must define -d <directory> option!!!")


var run_lint = 1;
var run_param = 0;
var run_veri = 1;
var run_test = 1;
var run_local = 0;

if(cli.bucketize)
    var test_results = require(directory + '/test_results.json');
else
    var test_results   = run_grid.run_grid(directory + '/run_config_list',directory,1);

fs.writeFileSync(directory + '/test_results.json', JSON.stringify(test_results,null,' '), 'utf8');


/************************************************
           PREPOPULATE RESULTS JSON
************************************************/
var module_name = 'psys'

var output_dir = directory + '/debug/' + module_name

var configs = populate_check_array(output_dir);
//console.log('configs ' + JSON.stringify(configs,null,' '));
/************************************************
           SORT THROUGH TEST RESULTS
************************************************/
var num_tests = 0
var test_string = ''
test_results.forEach( function(result) {
    var exe_dir = directory + '/debug/' + result.env_name + '/' + result.config_name
    var cur_config = configs[result.config_name];
//    console.log('config = ' + cur_config + ' test_type = ' + result.run_type + ' config_name = ' + result.config_name);
//    console.log(configs);
    if(result.run_type == 'test') {
	configs[result.config_name] = check_tests(cur_config, result);
	test_string += result.dest_dir + '\n'
	num_tests++;
    }
    
    if(result.run_type == 'lint') {
	configs[result.config_name] = check_lint(cur_config, result);
	
    }
    
    if(result.run_type == 'compile') {
	configs[result.config_name] = check_compiles(cur_config, result);
    }
    
});
fs.writeFileSync(directory + '/lslist', test_string,'utf8');
//console.log(execSync('python $WORK_TOP/dv/scripts/bucketize.py +run_dir=' + directory + ' +latest_only +num_tests=' + num_tests).toString());

//var config_obj = {configs};
//console.log(JSON.stringify(config_obj, null, '\t'));
fs.writeFileSync(directory + '/test_results.log', JSON.stringify(configs, null, ' '));
var bucketize_results = bucketize(directory, test_results, 1);
var bucketize_html = genReports.getHtmlStr(directory, bucketize_results.parse_results['UNLABELED'], test_results); //ASSUMES testlist is unlabeled!
var table_str = generate_html(configs, bucketize_html);
fs.writeFileSync(directory + '/test.html', table_str, 'utf8');


/************************************************
          UTILITY FUNCTIONS
************************************************/

function populate_check_array(output_dir) {
    var configFiles = fs.readdirSync(directory);
    var dirs = fs.readdirSync(output_dir);
    var configs = {};

    dirs.forEach( function(config_dir) {
	var config_dir_loc = directory + '/debug/' + module_name + '/' + config_dir;
	var config_dir_files = fs.readdirSync(config_dir_loc + '/json');
//	var config_dir_files = fs.readdirSync(directory);

	config_dir_files.forEach(function(filename) {
	    var cur_config = {};
	    if(filename.match(/config.*\.json$/)) {
		cur_config['filename'] = filename;
		cur_config['params'] = require(directory + '/' + filename);
		cur_config['config_dir'] = directory + '/debug/' + module_name + '/' + config_dir;
		cur_config['config_dir_name'] = config_dir;
		// **************************
		//       RUN PARAM CHECK
		// **************************

		if(run_param) {
		    var apf_path = directory + '/' + filename.replace('.json', '') + '.apf';
		    var cur_dir = process.env.PWD;
		    process.chdir(process.env.WORK_TOP + '/rtl/top/parameter_validation');
		    var create_from_json_cmd = 'node $WORK_TOP/dv/scripts/createApfFromJson.js -j ' + directory + '/' + filename + ' -a ' + apf_path;
		    console.log(create_from_json_cmd)
		    execSync(create_from_json_cmd);
		    var make_cmd = 'make parameter_validation NAME=' + config_dir + ' APF=' + apf_path + ' JSON=' + directory + '/' + filename;
		    console.log(make_cmd);
		    execSync(make_cmd);
		    execSync('mv parameter_validation.' + config_dir + ' ' + directory);
		    var param_valid_result = fs.readFileSync(directory + '/parameter_validation.' + config_dir + '/difference_count.log').toString().replace(/\s+/,'');
		    process.chdir(cur_dir);
		} 
		// ***************************
		//   Populate check object
		// ***************************
		
		var temp_obj = {};
		temp_obj.pass_fail = 0;
		temp_obj.errors = 0;
		temp_obj.warnings = 0;	    
		cur_config['Prep'] = temp_obj;
		var temp_obj = {};
		temp_obj.pass_fail = 0;
		temp_obj.errors = 0;
		temp_obj.aiu_errors = 0;
		temp_obj.ncb_errors = 0;
		temp_obj.dce_errors = 0;
		temp_obj.dmi_errors = 0;	    
		temp_obj.warnings = 0;	    
		temp_obj.wild_guess = 0;
		temp_obj.aiu_wild_guess = 0;
		temp_obj.ncb_wild_guess = 0;
		temp_obj.dmi_wild_guess = 0;
		temp_obj.dce_wild_guess = 0;	    
		cur_config['ACHL'] = temp_obj;
		var temp_obj = {};
		temp_obj.pass_fail = 0;
		temp_obj.errors = 0;
		temp_obj.warnings = 0;
		cur_config.VCS_compile = temp_obj;
		var temp_obj = {};
		temp_obj.failing_tests = [];
		temp_obj.passing_tests = [];
		temp_obj.checker_errors = [];
		cur_config.VCS_tests = temp_obj;
		var temp_obj = {};
		temp_obj.pass_fail = 0;
		temp_obj.errors = 0;
		temp_obj.aiu_errors = 0;
		temp_obj.ncb_errors = 0;
		temp_obj.dmi_errors = 0;
		temp_obj.dce_errors = 0;
		temp_obj.warnings = 0;	    
		cur_config.Lint = temp_obj;
		var temp_obj = {};
		if(run_param) {
		    temp_obj.pass_fail = (parseInt(param_valid_result) > 0) ? 0 : 1;
		    temp_obj.errors = parseInt(param_valid_result);
		} else {
		    temp_obj.pass_fail = 0;
		    temp_obj.errors = 0;
		}
		cur_config.Param_Validation = temp_obj;
		configs[config_dir] = cur_config;
	    }
	});
    });
    return configs;
}


function check_lint(cur_config, result) {
    console.log('lint for ' + result.config_name);
    var lintContents = ""
    try {
	lintContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/lint.log').toString();
    } catch(err) {
	if(err) {
	    return cur_config;
	}
    }
    var cur_config_params = cur_config['params'];
    var aiu_names = [];
    cur_config_params.AiuInfo.forEach( function(agent) {
	aiu_names.push(agent.strRtlNamePrefix);
    });
    var ncb_names = [];
    cur_config_params.BridgeAiuInfo.forEach( function(bridge) {
//	aiu_names.push(bridge.strRtlNamePrefix);
	ncb_names.push(bridge.strRtlNamePrefix);
    });
    var dmi_names = [];
    cur_config_params.DmiInfo.forEach( function(dmi) {
	var mem_region = dmi.MemRegionInfo;
	dmi_names.push(dmi.strRtlNamePrefix);
    });

    var lintContents_lines = lintContents.split(/\n/);
    var cur_line = 0;
    lintContents_lines.forEach( function(line) {
	if(line.match(/(\s+)?Error\s+/)) {
	    var line_list = line.split(/\s+/);
	    aiu_names.forEach(function(aiu_name) {
		if(line.match(aiu_name))
		    cur_config.Lint.aiu_errors++;
	    });
	    ncb_names.forEach(function(ncb_name) {
		if(line.match(ncb_name))
		    cur_config.Lint.ncb_errors++;
	    });
	    dmi_names.forEach(function(dmi_name) {
		if(line.match(dmi_name))
		    cur_config.Lint.dmi_errors++;
	    });
	    if(line.match(/dce/))
		cur_config.Lint.dce_errors++;

	    cur_config.Lint.errors++;
	}
	cur_line++;
    });
    if(cur_config.Lint.errors == 0)
	cur_config.Lint.pass_fail = cur_config.ACHL.pass_fail;
    if(lintContents.match(/SynthesisWarning\ /g)) {
	cur_config.Lint.warnings += lintContents.match(/SynthesisWarning\ /g).length;
    }
    if(lintContents.match(/Warning\ /g)) {
	cur_config.Lint.warnings += lintContents.match(/Warning\ /g).length;
    }
    return cur_config;
}



function check_tests(cur_config,result) {
    var test_dir = result.dest_dir;
    var node_run = '';
    try {
	var fileContents = fs.readFileSync(test_dir + '/vcs.log').toString();
    } catch(err) {
	if(err)
	    var fileContents = ""
    }
    var lines = fileContents.split('\n');
    var cur_config = configs[result.config_name];
    if(cur_config.VCS_compile.pass_fail) {
	if(fileContents.match(/UVM\ PASSED/)) {
	    cur_config.VCS_tests.passing_tests.push(test_dir);
	} else {
	    var last_uvm_error = ""
	    /* FIXME IMPLEMENT JS 
	       lines.forEach(function(line) {
	       if(line.match(/UVM_ERROR/)) {
	       var error_line = line.replace(/UVM_ERROR\s+/)
	       error_line=
	       last_uvm_error=error_line; 

	       }
	       }); */
	    cur_config.VCS_tests.failing_tests.push(test_dir);
	}
    }
    return cur_config;
}



function check_compiles(cur_config,result) {

    /*****************************************
        CHECK STDERR
    *****************************************/
    var fileContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/compile.err', 'utf8').toString();
    var file_lines = fileContents.split('\n');

    //GET NAMES SO WE CAN SORT ERRORS

    var cur_config_params = cur_config['params'];
    var aiu_names = [];
    cur_config_params.AiuInfo.forEach( function(agent) {
	aiu_names.push(agent.strRtlNamePrefix);
    });
    var ncb_names = [];
    cur_config_params.BridgeAiuInfo.forEach( function(bridge) {
//	aiu_names.push(bridge.strRtlNamePrefix);
	ncb_names.push(bridge.strRtlNamePrefix);
    });
    var dmi_names = [];
    cur_config_params.DmiInfo.forEach( function(dmi) {
	dmi_names.push(dmi.strRtlNamePrefix);
    });

    file_lines.forEach(function(line) {
	if(line.match(/error\:/)) {
	    aiu_names.forEach(function(aiu_name) {
		if(line.match(aiu_name) && (line.match('E015') || line.match('E012') || line.match('E009') || line.match('E006')))
		    cur_config.ACHL.aiu_errors++;
	    });
	    ncb_names.forEach(function(ncb_name) {
		if(line.match(ncb_name) && (line.match('E015') || line.match('E012') || line.match('E009') || line.match('E006')))
		    cur_config.ACHL.ncb_errors++;
	    });
	    dmi_names.forEach(function(dmi_name) {
		if(line.match(dmi_name) && (line.match('E015') || line.match('E012') || line.match('E009') || line.match('E006')))
		    cur_config.ACHL.dmi_errors++;
	    });
	    if(line.match(/dce/) && (line.match('E015') || line.match('E012') || line.match('E009') || line.match('E006')))
		cur_config.ACHL.dce_errors++;
	}
    });
    
    cur_config.ACHL.errors     = fileContents.match(/error\:/g) ? fileContents.match(/error\:/g).length : 0;
    cur_config.ACHL.warnings   = fileContents.match(/warning\:/g) ? fileContents.match(/warning\:/g).length : 0;
    /*****************************************
        CHECK WILD GUESSES
    *****************************************/
    var rtl_files = fs.readdirSync(cur_config.config_dir + '/rtl');

    rtl_files.forEach( function(v_file) {
	var verilog_contents = fs.readFileSync(cur_config.config_dir + '/rtl/' + v_file).toString();
	if(verilog_contents.match(/wild\ guess/)) {
	    var num_wild_guesses =  verilog_contents.match(/wild\ guess/g).length ;
	    cur_config.ACHL.wild_guess += num_wild_guesses;
	    aiu_names.forEach(function(aiu_name) {
		if(v_file.match(aiu_name))
		    cur_config.ACHL.aiu_wild_guess += num_wild_guesses;
	    });

	    ncb_names.forEach(function(ncb_name) {
		if(v_file.match(ncb_name))
		    cur_config.ACHL.ncb_wild_guess += num_wild_guesses;
	    });

	    dmi_names.forEach(function(dmi_name) {
		if(v_file.match(dmi_name))
		    cur_config.ACHL.dmi_wild_guess += num_wild_guesses;
	    });
	    if(v_file.match(/dce/))
		cur_config.ACHL.dce_wild_guess += num_wild_guesses;
	}
    });
    
    /*****************************************
        CHECK VCS
    *****************************************/

    var fileContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/compile.out', 'utf8').toString();
    if(fileContents.match(/VCS\ compile\ successful/)) {
	cur_config.VCS_compile.pass_fail = 1;
    }
    // ==== CHECK ACHL ====
    if(fileContents.match(/ACHL compile successful/)) {
	cur_config.ACHL.pass_fail = 1;
    }
    // ==== CHECK PREP ====
    if(fileContents.match(/Successfully\ generated\ dv\ files/)) {
	cur_config.Prep.pass_fail=1;
    }
    var errfileContents = fs.readFileSync(directory + '/debug/' + result.env_name + '/' + result.config_name + '/compile.err', 'utf8').toString();
    if(errfileContents.match(/FATAL\ ERROR/)) {
	cur_config.ACHL.pass_fail = 0;
	cur_config.VCS_compile.pass_fail = 0;
	cur_config.Prep.pass_fail=0;
	cur_config.fatal_error=1;
    }
    cur_config.VCS_compile.errors   = fileContents.match(/Error/g) ? fileContents.match(/Error/g).length : 0;
    cur_config.VCS_compile.errors   = fileContents.match(/Warning/g) ? fileContents.match(/Warning/g).length : 0;

    return cur_config;
}
function generate_html(this_configs) {
    var table_str = '<html><head>';
    var faillist = '';
    table_str += "<style type=\"text/css\">";
    //    table_str += "th.vertical > div {  transform: translate(5px, 100px) rotate(-90); width: 30px; height: 15px ; background-color: #5F9F9F bottom:1px}"
    table_str += "th.vertical { height: 200px; white-space: nowrap; border: 1px solid #eeeeee; background-color: #5F9F9F; color:white ;}" ;        
    table_str += "th.vertical_left { height: 200px; white-space: nowrap; border: 1px solid #eeeeee; background-color: #5F9F9F; color:white ;}" ;
    table_str += "th.vertical_right { height: 200px; white-space: nowrap; border: 1px solid #eeeeee; background-color: #5F9F9F; color:white ;}" ;
    table_str += ".vertical-text { transform: rotate(90deg); } "
    //    table_str += ".vertical_th {background-color: #5F9F9F; transform: rotate(-90deg); color: white; position:absolute; text-align: left;}"
    table_str += ".vertical_th {background-color: #5F9F9F; transform-origin: 0px 0px; transform: translate(0px, 80px) rotate(-90deg); color: white; position:absolute;}"    
    table_str += "th.horizontal_th { background-color: #5F9F9F; color: white; vertical-align: text-bottom; border: 1px solid #eeeeee; border-left: thick double;}"
    table_str += ".horizontal_th { background-color: #5F9F9F; color: white; vertical-align: text-bottom}"
    
    table_str += "table { border-collapse: collapse; }"
    table_str += "td { border: 1px solid #333333 ;padding: 10px;}"
    table_str += "td.empty { border: 0px solid white }"
//    table_str += "th { padding: 5px }";

    table_str += ".pass_class { background-color: #9AFF9A }"
    table_str += ".fail_class { background-color: #F2473F }"
    table_str += ".warn_class { background-color: #fbe275 }"


    table_str += "th.rotate { height: 250px; white-space: nowrap; border: 0px solid white; color:white }"
    table_str += "th.rotate > div {  transform: translate(5px, 100px) rotate(300deg); width: 30px; height: 15px ; background-color: #5F9F9F bottom:1px}"
    table_str += "th.rotate > div > span {  border-bottom: 1px solid #ccc;  padding: 5px 10px; background-color: #5F9F9F }"

    table_str += ".filler_div { background-color: #5F9F9F; height:15px; bottom: 0px }"
//    table_str += "th { background-color: #5F9F9F }"
    table_str += ".config_name { background-color: #5F9F9F; color: white; }"
    table_str += "</style></head><table cellpadding=5px>";

    //process.stdout.write(configs.toString());
    //this_configs.forEach(function(config) {}
    var table_row = 0
    //    var header_string = "'<tr><td class=\"horizontal_th\"><div class=\"horizontal_th\">Config</div></td>"
    var d=new Date();
    var header_class_string = '<tr><th class=\"horizontal_th\">' + d.getMonth() + '/' + d.getDate() + '/' + d.getFullYear();
    var header_string ='<tr><td class=\"empty\"></td>'
//    var header_classes = [["Compile", ["ACHL Compile", "aiu errors", "ncb errors", "dmi errors", "dce errors", "Total ACHL Errors", "ACHL warnings", "AIU wild guesses", "NCB wild guesses", "DMI wild guesses", "DCE wild guesses", "total wild guesses", "VCS compile"]], ["Tests", ["Pass/Fail", "Checker Errors"]], ["Lint", ["Lint", "aiu errors", "ncb errors", "dmi errors", "dce errors", "total errors", "warnings"]], ["Verilator", ["Verilator"]], ["Param Validation", ["Param Validation"]]]
//    var header_classes = [["Compile", ["ACHL Compile", "aiu errors", "ncb errors", "dmi errors", "dce errors", "Total ACHL Errors", "ACHL warnings", "AIU wild guesses", "NCB wild guesses", "DMI wild guesses", "DCE wild guesses", "total wild guesses", "VCS compile"]], ["Tests", ["Pass/Fail", "Checker Errors"]], ["Lint", ["Lint", "aiu errors", "ncb errors", "dmi errors", "dce errors", "total errors", "warnings"]]]    
    var header_classes = [["Compile", ["ACHL Compile", "aiu errors", "ncb errors", "dmi errors", "dce errors", "AIU wild guesses", "NCB wild guesses", "DMI wild guesses", "DCE wild guesses", "total wild guesses", "VCS compile"]], ["Tests", ["Pass/Fail", "Checker Errors"]], ["Lint", ["Lint", "aiu errors", "ncb errors", "dmi errors", "dce errors", "total errors", "warnings"]]]    
    header_classes.forEach(function(header) {
	header_class_string += '<th class=\"horizontal_th\" colspan=' + header[1].length + '>' + header[0];
	header[1].forEach(function(class_header,cur_header) {
	    if((cur_header == (header[1].length) - 1)) {
		header_string += '<th class=\"vertical_right\">';
	    } else if(cur_header == 0) {
		header_string += '<th class=\"vertical_left\">';
	    } else {
		header_string += '<th class=\"vertical\">';
	    }
//	    header_string += '' + class_header + '</th>'	    
//	    header_string += '<div>' + class_header + '</div></th>'	    
	    header_string += '<div class=\"vertical_th\">' + class_header + '</div></th>'
	});
    });
    '<tr><td class=\"horizontal_th\"><div class=\"horizontal_th\">'
    header_string += '</tr>'
    for (var config_name in this_configs) {
	if(table_row % 25 == 0) {
	    table_str += header_class_string + header_string
	}
	table_row++;
	var config = this_configs[config_name];
	table_str += '<tr>';
	//filename cell
	table_str += '<td class=\"horizontal_th\"><div class=\"horizontal_th\">';
	table_str += config.filename;
	table_str += '</div>'
//	table_str += '</td>';
	//Compile cell
	//	table_str += '<td>';
	// <td class=\"
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail((config.ACHL.pass_fail ? 'P' : 'F'), config.ACHL.pass_fail) + '\n';
	//	table_str += write_pass_fail((config.ACHL.pass_fail ? '&#x2714' : '&#x2716'), config.ACHL.pass_fail) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.aiu_errors, ((config.ACHL.pass_fail) && (config.ACHL.aiu_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.ncb_errors, ((config.ACHL.pass_fail) && (config.ACHL.ncb_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.dmi_errors, ((config.ACHL.pass_fail) && (config.ACHL.dmi_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.dce_errors, ((config.ACHL.pass_fail) && (config.ACHL.dce_errors == 0))) + '\n';
//	table_str += (((config.ACHL.pass_fail == 1) && (config.ACHL.errors > 0)) ? '<td class=\"warn_class\">' : '<td class=\"pass_class\">') + config.ACHL.errors;
//	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.warnings, ((config.ACHL.pass_fail) && (config.ACHL.warnings == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.aiu_wild_guess, ((config.ACHL.pass_fail) && (config.ACHL.aiu_wild_guess == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.ncb_wild_guess, ((config.ACHL.pass_fail) && (config.ACHL.ncb_wild_guess == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.dmi_wild_guess, ((config.ACHL.pass_fail) && (config.ACHL.dmi_wild_guess == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.dce_wild_guess, ((config.ACHL.pass_fail) && (config.ACHL.dce_wild_guess == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.ACHL.wild_guess, ((config.ACHL.pass_fail) && (config.ACHL.wild_guess == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail((config.VCS_compile.pass_fail ? 'P' : 'F'), config.VCS_compile.pass_fail) + '\n';	//	table_str += write_pass_fail((config.VCS_compile.pass_fail ? '&#x2714' : '&#x2716'), config.VCS_compile.pass_fail) + '\n';	
//	table_str += '</td>';

	//Tests Cells
	//	table_str += '<td>';
	var test_total_tests = (config.VCS_tests.passing_tests.length + config.VCS_tests.failing_tests.length);
	var pass_fail_str = config.VCS_tests.passing_tests.length + '/' + test_total_tests;
	table_str += (config.fatal_error) ? "<td>" : (config.fatal_error) ? "<td>" : write_pass_fail(pass_fail_str, (config.VCS_compile.pass_fail && (config.VCS_tests.failing_tests.length == 0))) + '\n';	
//	table_str += write_pass_fail(config.VCS_tests.passing_tests.length, (config.VCS_compile.pass_fail && (config.VCS_tests.failing_tests.length == 0))) + '\n';
//	table_str += write_pass_fail(config.VCS_tests.failing_tests.length, (config.VCS_compile.pass_fail && (config.VCS_tests.failing_tests.length == 0))) + '\n';		
	var total_errors = 0
	config.VCS_tests.checker_errors.forEach( function(cur_test, cur_test_no) {
	    total_errors += cur_test;
//	    table_str += '<br> test' + cur_test_no + ': ' + cur_test + ' errors';
	});
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(total_errors, (config.VCS_compile.pass_fail && (total_errors == 0))) + '\n';
	faillist += config.VCS_tests.failing_tests.join('\n<br>');
//	table_str += '</td>';


	//Lint Cells

//	table_str += '<td>';
//	table_str += write_pass_fail((config.Lint.pass_fail ? '&#x2714' : '&#x2716'), ((config.ACHL.pass_fail) && config.Lint.pass_fail)) + '\n';	
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail((config.Lint.pass_fail ? 'P' : 'F'), ((config.ACHL.pass_fail) && config.Lint.pass_fail)) + '\n';	
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.Lint.aiu_errors, ((config.ACHL.pass_fail) && (config.Lint.aiu_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.Lint.ncb_errors, ((config.ACHL.pass_fail) && (config.Lint.ncb_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.Lint.dmi_errors, ((config.ACHL.pass_fail) && (config.Lint.dmi_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.Lint.dce_errors, ((config.ACHL.pass_fail) && (config.Lint.dce_errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : write_pass_fail(config.Lint.errors, ((config.ACHL.pass_fail) && (config.Lint.errors == 0))) + '\n';
	table_str += (config.fatal_error) ? "<td>" : (((config.ACHL.pass_fail) && (config.Lint.warnings > 0)) ? '<td class=\"warn_class\">' : '<td class=\"pass_class\">') + config.Lint.warnings;    
//	table_str += '</td>';

	//Verilator Cells
//	table_str += '<td class=\"fail_class\">' + 0;
/*	table_str += 'Verilator ' + (config.Verilator.pass_fail ? 'PASSED' : 'FAILED');
	table_str += '<br>errors: ' + config.Verilator.errors;
	table_str += '<br>warnings: ' + config.Verilator.warnings;    
	table_str += '</td>'; */

	//Parameter Validation Cells
//	table_str += '<td>';
//	table_str += write_pass_fail((config.Param_Validation.pass_fail ? '&#x2714' : '&#x2716'), config.Param_Validation.pass_fail) + '\n';	
//	table_str += write_pass_fail(config.Param_Validation.errors, (config.Param_Validation.pass_fail && (config.Param_Validation.errors == 0))) + '\n';
//	table_str += '</td>';

	table_str += '</tr>';    
    };
    table_str += '</table>';
//    table_str += fs.readFileSync(directory + '/regr.log', 'utf8').toString().split('\n').join('\n<br>');
//    console.log('num new_lines ' + fs.readFileSync(directory + '/regr.log','utf8').toString().match(/\n/).length);
    table_str += bucketize_html;
//    table_str += '<h2> TEST FAILURES </h2> ' + faillist;    
    table_str += '</html>';
    return table_str;

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
