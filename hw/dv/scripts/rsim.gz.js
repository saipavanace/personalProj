#!/usr/bin/env node
/////////////////////////////////////////////////////////
//                                                     //
//                                                     //
/////////////////////////////////////////////////////////
//File:   rsim.js
//Author: Abhinav Nippuleti

'use strict';
var fs = require('fs');
var cli = require('commander');
var genTB = require('./build_tb_env.js');
var path = require('path');
var proc = require('child_process');
var dt = new Date();
var local_dir_grid = '/local/' + process.env.USER
var prev_test_dir = ''

var path_str = [];
var disp_info = [];
var rsim_ds = {};

function list(val) {
    return (val.split(','));
}

function parseEnv(str) {
    if (str.match(/^(dce|dmi|aiu|cbi|psys|sys)$/i)) {
        return (str.toLowerCase());
    } else {
        throw ('Unexpected arguement. exec rsim -h');
    }
}

/*
 * Synchronous version of fs.stat is required because
 * callback returns undefined before
 * asynchronous version of fs.stat() is returned.
 *
 */
function validPath(str) {
    var stats = fs.statSync(str);

    if (stats.isDirectory() || stats.isFile()) {
        return (str);
    } else {
        var err = 'Unexpected type of object returned from fs.stat()';
        console.log(stats);
        throw (err);
    }
}

cli
    .version('0.0.1')
    .option('-e, --environment <string>', 'Switch to specify TestBench you want to execute(dec|dmi|aiu|psys|sys)', parseEnv)
    .option('-a, --achl', 'Switch to generate RTL from achl compiler for specific block. All previous files in rtl directory are deleted before re-generating. Default points to current stable version')
    .option('-c, --compile', 'Switch to compile specified environment using specificed simulator, default is VCS')
    .option('-t, --testname <string>', 'Switch to provide test to run, Note that this switch only runs test expacting that compile has already completed & successful')
    .option('-d, --defines <items>', 'Swtich to provide all Verlog/System-Verilog defines. All defines must be separated by comma(,) without any spaces Ex: -d DEFINE_1,DEFINE_2', list)
    .option('-p, --plusargs <items>', 'Switch to provide all Verilog/System-Verilog plusrags. All plusargs must be separated by comma(,) without any spaces Ex: -d arg_1,arg_2 ', list)
    .option('-r, --regression', 'Swtich to specify if running regressions. Adding this switch will append directory count. Must be specified at both run & compile time.')
    .option('-E, --notEnvGen', 'Switch to force program to NOT GENERATE Test-Bench Environment files')
    .option('-D, --dumpPath <string>', 'Switch to generate *debug* directory hierarchy at specified location instead of default WORK_TOP/hw/*debug* location', validPath)
    .option('-s, --configParams <string>', 'Switch to specify configuration file to generate DV/RTL. Default is concerto_system_params_hier.js. If -n switch is not specified then config file name will be the configuratioin directory name', validPath)
    .option('-n, --userConfigDir <string>', 'Switch to give control to user to decide Configuration directory name. This takes higher precedence if both -s & -n switches are specified.')
    .option('-l, --latestAchlVer', 'Switch to run with generate RTL with latest ACHL compiler.')
    .option('-i, --ncsimSimulator', 'Switch to select Cadence NCSim simulator')
    .option('-o, --codeCoverage', 'Switch to generate Code Coverage. Right Code Coverage options are specified on command line depending on simulation tool. Must be specified both compile & run time')
    .option('-m, --includeExternalMemory', 'Switch to include verilog behavioral Memory Model in compilation')
    .option('-u, --uniqueID <string>', 'Switch to pass processID in for uniqueness')
    .option('-g, --grid_run <string>', 'Switch to enable rsim to run simv in /local')
    .option('-C, --codegen <string>', 'run rsim using codegen')
    .parse(process.argv);

if (!cli.environment) {
    var error = '-e Switch Required. Specify TestBench you want to execute(dce|dmi|aiu|psys|sys)';
    throw (error);
}

/*
 * Push and pops current working dir
 * Expects full Absolute path
 */
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

function genMilliSec() {
    return (dt.getMilliseconds());
}

function getRegrDir(testName) {
    return (testName + '_' + dt.getHours() + '_' + dt.getMinutes() + '_' + dt.getSeconds() + '_' + dt.getMilliseconds());
}

var cliDefineExists = function(arg1) {
    var exists = false;
    cli.defines.forEach(function(elem, index, array) {
        if(arg1 === elem) {
            exists = true;
        }
    });
    return exists;
};

/*
 Method writes git revision, WORK_TOP
 info to debug dir for user analysis 
*/

function regrStatus() {
    var data = 'WORK_TOP set to ' + process.env.WORK_TOP;
    var gitRev  = ''
    var fName   = rsim_ds.cfg_dir + '/regr_info.txt';
    disp_info.push(data);
    push_dir(process.env.WORK_TOP);
    proc.exec('git log --stat -1', 'utf8', function(err, stdout, stderr) {
        if(err) {
            throw err;
        } else {
            data += '\n\n' + 'RTL/DV code generated from git version ' + '\n\n' + stdout;
            
            fs.writeFile(fName, data, 'utf8', function(err) {
                if(err) throw err;
            });
       }
    });
    pop_dir();
}

/*
 *Generate Bundle
 */

function gen_bundle() {
    var acc = '',
        ipRtlDir = rsim_ds.ws_top + '/rtl/top/src',
        cmd = '';

    if(cli.achl) {

        if(fs.existsSync(rsim_ds.achlBundle)) {
            fs.unlinkSync(rsim_ds.achlBundle);
            console.log("Deleted older: %s", rsim_ds.achlBundle);
        }
        push_dir(ipRtlDir);
        
        cmd = rsim_ds.achl_exec1 + ' < ' + rsim_ds.rtl_top + ' > ' + rsim_ds.achlBundle;

        console.log("Generating new %s", rsim_ds.achlBundle);
        console.log("Cmd: "+cmd);

        proc.exec(cmd, function(err, stdout, stderr) {
            if(err) throw 'unable to generate bundle';
            pop_dir();
            exec_rsim_cmd(0);
        });
    } else {
        exec_rsim_cmd(0);
    }
}

function gen_rtl() {
/*    if(cli.codegen) {
        var apf_file;
        var cmd_args = [];
        var wdata = '#! /bin/sh -f \n\n';
        var writef = rsim_ds.exe_dir + '/build_rtl';
        if (fs.existsSync(rsim_ds.rtl_dir)) {
            var files = fs.readdirSync(rsim_ds.rtl_dir);

            files.forEach(function(file, index, array) {
                fs.unlinkSync(rsim_ds.rtl_dir + '/' + file);
                if(index === 0)
                    console.log('Existing ' + cli.environment + ' RTL files are deleted');
            });
        }
	wdata += process.env.WORK_TOP + 'node_modules/.bin/generatecli -t';
    } */
    if (cli.achl) {
        var params = [];
        var cmd_args = [];
        var wdata = '#! /bin/sh -f \n\n';
        var writef = rsim_ds.exe_dir + '/build_rtl';

        params = [rsim_ds.concerto_cfg]; //, rsim_ds.concerto_encodings];

        //Delete RTL file if exists
        if (fs.existsSync(rsim_ds.rtl_dir)) {
            var files = fs.readdirSync(rsim_ds.rtl_dir);

            files.forEach(function(file, index, array) {
                fs.unlinkSync(rsim_ds.rtl_dir + '/' + file);
                if(index === 0)
                    console.log('Existing ' + cli.environment + ' RTL files are deleted');
            });
        }

        wdata += rsim_ds.achl_exec2 + ' -vvv ' + rsim_ds.achlBundle + ' -p ' + params + ' -d ' + rsim_ds.rtl_dir;
        fs.writeFile(writef, wdata, function(err) {
            if (err) {throw err;}
            fs.chmod(writef, 511, function(err) {
                if (err) {throw err;}
            });
        });

        cmd_args.push(rsim_ds.achl_exec2, '-vvv', rsim_ds.achlBundle, '-p', params, '-d', rsim_ds.rtl_dir);
        return (cmd_args);
    } else {
        return (undefined);
    }
}

function usr_defines() {
    var usr_def = '';

    if (cli.defines) {
        cli.defines.forEach(function(elem, index, array) {
            //console.log(elem);
            if (elem.match(/^\+define\+/)) usr_def += elem;
            else if (elem.match(/^\+/)) usr_def += '+define' + elem;
            else usr_def += '+define+' + elem;
            usr_def += ' ';
        });
    }
    //console.log(usr_def);
    return (usr_def);
}

function compile_sim() {
    if (cli.compile) {
        var comp_cmd = '';
        var cmd_args = [];
        var node_cmd = '';

        process.argv.forEach(function(val, index, array) {
            node_cmd += val + ' ';
        });

        var wdata = '#! /bin/sh -f \n\n';
        var writef = rsim_ds.exe_dir + '/compile_env';
        var nodef = rsim_ds.exe_dir + '/node_exe';

        //Save regression info
        regrStatus();
        //comp_cmd += "vcs -sverilog -debug_pp -timescale=1ns/1ps +acc +vpi ";
        //UVM src dir
        //comp_cmd += "+incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv ";

        //Synopsys Designware defines
        //comp_cmd += "+lint=TFIPC-L +define+SYNOPSYS_SV +define+SVT_UVM_TECHNOLOGY ";
        push_dir(rsim_ds.exe_dir);

        if (cli.ncsimSimulator) {
            comp_cmd += 'irun -64 -elaborate -mess -sv -uvm -access +rw -timescale 1ns/1ps ';
            comp_cmd += '+define+DENALI_SV_NC +define+CDN_ACE +define+DENALI_UVM +define+CDN_AUTO_TEST -access +rw -loadvpi ${DENALI}/verilog/libcdnsv.so:cdnsvVIP:export ';
            comp_cmd += '-ncsimargs \"-loadrun ${WORK_TOP}/dv/common/cdns_acevip/vip_lib/64bit/libcdnvipcuvm.so\" ';

            //Synopsys Designware defines
            //comp_cmd += "+lint=TFIPC-L +define+SYNOPSYS_SV +define+SVT_UVM_TECHNOLOGY ";
        } else {
//            comp_cmd += 'vcs -sverilog -parallel+sva -debug_pp -timescale=1ns/1ps +acc +vpi +define+VCS_SIM +vcs+lic+wait ';
            comp_cmd += 'vcs -sverilog -debug_pp -timescale=1ns/1ps +acc +vpi +define+VCS_SIM +vcs+lic+wait ';
            //UVM src dir
            comp_cmd += '+incdir+$UVM_HOME/src $UVM_HOME/src/uvm.sv ';

            //Synopsys Designware defines
            comp_cmd += '+lint=TFIPC-L +define+SYNOPSYS_SV +define+SVT_UVM_TECHNOLOGY ';
            comp_cmd += '$UVM_HOME/src/dpi/uvm_dpi.cc -CFLAGS -DVCS ';
            comp_cmd += '-CFLAGS -DGZSTREAM ';
            comp_cmd += '-CFLAGS -I/engr/dev/tools/gzstream/lib64 ';
            comp_cmd += '-L/engr/dev/tools/gzstream/lib64 -lgzstream -L/lib64 -lz ';
       
            if(cliDefineExists('BLK_SNPS_OCP_VIP')) {
                comp_cmd += '-ntb -ntb_opts rvm -ntb_opts vera_compat -ntb_opts use_sigprop +define+NO_VMM_UVM_INTEROP -ntb_define NTB -ntb_vipext +define+SVT_OCP_FORCE_SV_DEFINES -ntb_opts config=/home/sprakash/subsys_new/hw/dv/dmi/tb/tb_ocp_vrt_uvm_basic_sys.config'
               comp_cmd += ' +define+NTB -ntb_incdir /home/sprakash/subsys_new/hw/dv/dmi/tb/snps_ocp_vip/include/vera+/home/sprakash/subsys_new/hw/dv/dmi/tb/snps_ocp_vip/src/vera  ';
            }
        }
        //Get UVM defines
        comp_cmd += '+define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING ';
        comp_cmd += '+define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE ';
        comp_cmd += rsim_ds.cmpCodeCov;
        comp_cmd += usr_defines();

        // compiles and includes memory model
        // specified by -m switch
        if (cli.includeExternalMemory) {
            var mem_vend = "internal";

            // currently broken for mem_vend != internal
            if (mem_vend != "internal") {
                rsim_ds.mem_dir = rsim_ds.cfg_dir + '/' + 'memory';

                // delete memory directory if previously exists
                if (fs.existsSync(rsim_ds.mem_dir)) {
                    proc.execSync('rm -Rf ' + rsim_ds.mem_dir);
                }

                // make memory directory
                fs.mkdirSync(rsim_ds.mem_dir);

                comp_cmd += '+define+VIRAGE_FAST_VERILOG';
                comp_cmd += '+define+ARM_UD_MODEL';

                //var internal_compiler_script = '../../scripts/internal_mem.v';
                var synop_compiler_script = '../../scripts/synop_mem.scr';
                var arm_compiler_script = '../../scripts/arm_mem.sh';
                //var prep = '../../scripts/node_modules/prep/bin/prep.js';

                var mem_vend = params.mem_vend;
                var mem_ports = params.mem_ports;
                var mem_bit_en = params.mem_bit_en;
                var mem_type = params.mem_type;
                var w_data_error;
                if (params.fnErrDetectCorrect == "NONE") {
                    var w_err_bits = 0;
                    w_data_error = params.mem_width + w_err_bits;
                } else if (params.fnErrDetectCorrect == "PARITYENTRY") {
                    var w_err_bits = 1;
                    w_data_error = params.mem_width + w_err_bits;
                } else if (params.fnErrDetectCorrect == "PARITY16B") {
                    var w_err_bits = Math.ceil(params.mem_width/16);
                    w_data_error = params.mem_width + w_err_bits;
                } else if (params.fnErrDetectCorrect == "PARITY8B") {
                    var w_err_bits = Math.ceil(params.mem_width/8);
                    w_data_error = params.mem_width + w_err_bits;
                } else if (params.fnErrDetectCorrect == "SEDDED") {
                    var w_err_bits = Math.ceil(Math.log(params.mem_width)/Math.log(2));
                    if (Math.ceil(Math.log(params.mem_width + w_err_bits + 1)/Math.log(2)) > w_err_bits) {
                        w_err_bits += 1;
                    }
                    w_data_error = params.mem_width + w_err_bits;
                } else if (params.fnErrDetectCorrect == "SECDED") {
                    var w_err_bits = Math.ceil(Math.log(params.mem_width)/Math.log(2));
                    if (Math.ceil(Math.log(params.mem_width + w_err_bits + 1)/Math.log(2)) > w_err_bits) {
                        w_err_bits += 1;
                    }
                    w_data_error = params.mem_width + w_err_bits + 1;
                }
                var mem_depth = params.mem_depth;
                var mem_cm = params.mem_cm;
                var mem_bk = params.mem_bk;
            }

            // compile memory to mem_dir
            if (mem_vend === 'internal') {
                //fs.mkdirSync(mem_dir);
                //var args = [prep, '-p', params_file, '-t', internal_compiler_script, '-o', mem_dir + '/internal_mem.v', '-i', '{"mem_width" : ' + w_data_error + '}'];
                //proc.spawnSync('node', args, {
                //    stdio: 'inherit'
                //});
                //fs.appendFile(file_list, mem_dir + '/internal_mem.v\n', function(err) {
                //    if (err) throw err;
                //});

                // add memory templates to compile list
                fs.appendFile("../dv/vcs.flist", rsim_ds.ws_top + '/rtl/lib/src/internal_mem_sp.v\n', function(err) {
                    if (err) throw err;
                });
                fs.appendFile("../dv/vcs.flist", rsim_ds.ws_top + '/rtl/lib/src/internal_mem_sp_be.v\n', function(err) {
                    if (err) throw err;
                });
                fs.appendFile("../dv/vcs.flist", rsim_ds.ws_top + '/rtl/lib/src/internal_mem_tp.v\n', function(err) {
                    if (err) throw err;
                });
                fs.appendFile("../dv/vcs.flist", rsim_ds.ws_top + '/rtl/lib/src/internal_mem_tp_be.v\n', function(err) {
                    if (err) throw err;
                });
            } else if (mem_vend === 'synop') {
                var args = [rsim_ds.mem_dir, mem_ports, mem_type, mem_bit_en, w_data_error, mem_depth, mem_cm, mem_bk];
                proc.spawnSync(synop_compiler_script, args, {
                    stdio: 'inherit'
                });
                fs.appendFile(rsim_ds.rtl_dir + '/parse_top.f', rsim_ds.mem_dir + '/compout/views/synop_mem/tt0p8v25c/synop_mem.v\n', function(err) {//DCDEBUG
                    if (err) throw err;
                });
            } else if (mem_vend === 'arm') {
                var args = [rsim_ds.mem_dir, mem_ports, mem_type, mem_bit_en, w_data_error, mem_depth, mem_cm, mem_bk];
                proc.spawnSync(arm_compiler_script, args, {
                    stdio: 'inherit'
                });
                fs.appendFile(rsim_ds.rtl_dir + '/parse_top.f', rsim_ds.mem_dir + '/arm_mem.v\n', function(err) {
                    if (err) throw err;
                });
            }
        }

        //UVM DPI call
        //specify vcs flist
        comp_cmd += ' -f ../dv/vcs.flist -l compile.log';
        cmd_args = comp_cmd.split(' ');

        wdata += comp_cmd;
        fs.writeFile(writef, wdata, function(err) {
            if (err) throw err;
            fs.chmod(writef, 511, function(err) {
                if (err) throw err;
            });
        });

        fs.writeFile(nodef, node_cmd, function(err) {
            if (err) throw err;
            fs.chmod(nodef, 511, function(err) {
                if (err) throw err;
            });
        });

        return (cmd_args);

    } else {
        return (undefined);
    }
}

function plus_args() {
    var args = '';
    if (cli.plusargs) {
        cli.plusargs.forEach(function(elem, index, array) {
            if (elem.match(/^\+/)) args += elem;
            else args += '+' + elem;
            args += ' ';
        });
    }
    return (args);
}

function run_sim() {
    if (cli.testname) {
        var run_cmd = '';
        var cmd_args = [];
        var wdata = '#! /bin/sh -f \n\n';
        var writef = '';

        var node_cmd = '';

        process.argv.forEach(function(val, index, array) {
            node_cmd += val + ' ';
        });
	//*******DC GRID STUFF*******
	//run simv in /local

	if (cli.grid_run) {
            if (!fs.existsSync(local_dir_grid + '/' + cli.grid_run)) {
		fs.mkdirSync(local_dir_grid + '/' + cli.grid_run);
            }
	    push_dir(local_dir_grid + '/' + cli.grid_run);
	    prev_test_dir = rsim_ds.test_dir
	    rsim_ds.test_dir = local_dir_grid + '/' + cli.grid_run;
	} else {
            //Create Directory
            if (!fs.existsSync(rsim_ds.test_dir)) {
		fs.mkdirSync(rsim_ds.test_dir);
            }
            push_dir(rsim_ds.test_dir);
	}

        //Run command
        //run_cmd = '../../exe/simv \+UVM_TESTNAME=' + cli.testname + ' ' + plus_args() + ' -l vcs.log';
        if (cli.ncsimSimulator) {
            run_cmd += 'irun -R -64 -nclibdirname ' + rsim_ds.cfg_dir + '/exe/INCA_libs ';
            //ACE VIP shared librariesCDN_VIP_LIB_PATH
            run_cmd += '-loadvpi ${DENALI}/verilog/libcdnsv.so:cdnsvVIP:export -ncsimargs \"-loadrun ${WORK_TOP}/dv/common/cdns_acevip/vip_lib/64bit/libcdnvipcuvm.so\" ';
            run_cmd += ' +UVM_TESTNAME=' + cli.testname + ' ' + plus_args() + ' -l vcs.log ';
        } else {
            run_cmd += rsim_ds.cfg_dir + '/exe/simv ' + rsim_ds.runCodeCov + '+UVM_TESTNAME=' + cli.testname + ' ' + plus_args() + ' +vcs+lic+wait -assert nopostproc -l vcs.log -cm_dir simv.vdb';
        }

        wdata += run_cmd;

        writef = rsim_ds.test_dir + '/run_sim';
        fs.writeFile(writef, wdata, function(err) {
            if (err) throw err;
            fs.chmod(writef, 511, function(err) {
                if (err) throw err;
            });
        });

        var nodef = rsim_ds.test_dir + '/node_run';
        fs.writeFile(nodef, node_cmd, function(err) {
            if (err) throw err;
            fs.chmod(nodef, 511, function(err) {
                if (err) throw err;
            });
        });
        cmd_args = run_cmd.split(' ');
        return (cmd_args);

    } else {
        //End of Program; Exit from recursion
        return (null);
    }
}

function get_cmd(cnt) {
    if (cnt === 0) {
        return (gen_rtl());
    } else if (cnt === 1) {
        return (compile_sim());
    } else if (cnt === 2) {
        return (run_sim());
    } else {
        return (null);
    }
}

function post_process(cnt, info) {

    if (cnt === 0) {
        disp_info.push(cli.environment + ' rtl files: ' + rsim_ds.rtl_dir);

        if (info === 'command_executed')
            console.log('ACHL compile successful; Generated rtl files ' + rsim_ds.rtl_dir);
        else if (info === 'command_skipped')
            console.log('ACHL compile skipped; Pre-existing rtl files are either used for compilation or/and running test');
    } else if (cnt === 1) {
        if (info === 'command_executed')
            console.log('VCS compile successful; Generated log ' + rsim_ds.exe_dir + '/compile.log');
        else if (info === 'command_skipped')
            console.log('VCS compile skipped; Pre-existing ./simv will be used to run test');
    } else if (cnt === 2) {
        if (info === 'command_executed')
            disp_info.push('Logs & wavedump: ' + rsim_ds.test_dir);
    }

    if (info === 'report_status') {
        disp_info.forEach(function(elem, index, array) {
            console.log(elem);
        });
    }
}


/*
 Start executing user specified commands
 Recursive function, Program sequence
 maintained by this method
 */
function exec_rsim_cmd(cnt) {
    var cmd_args = [];

    cmd_args = get_cmd(cnt);

    //console.log(typeof(cmd_args));
    if ((typeof cmd_args === 'object') && cmd_args) {
        var str = cmd_args.shift();

        var pwd = proc.spawn(str, cmd_args, {
            stdio: 'inherit'
        });

        //close method
        pwd.on('close', function(code) {
            if (code) {
                var err = 'Execution Failed';
                throw err;
            }
	    if(cli.grid_run && (cnt == 2))
		rsim_ds.test_dir = prev_test_dir;
            post_process(cnt, 'command_executed');
	    var rtl_patt = /$^/;
	    if(cnt == 0) {
		var w_filename = rsim_ds.rtl_dir + '/parse_top.f';
		var params = [];
		params = [rsim_ds.concerto_cfg];
		fs.writeFile(w_filename, "");
		switch(cli.environment) {
		    case 'dce' : rtl_patt = /(top\.v|root\.v)/; break;
		    case 'aiu' : rtl_patt = /(top\.v|root\.v)/; break;
		    case 'dmi' : rtl_patt = /(top\.v|root\.v)/; break;
		    case 'cbi' : rtl_patt = /(top\.v|root\.v)/; break;
		    case 'psys' : rtl_patt = /$^/; break;
		}
		var rtl_dir_f_list = rsim_ds.rtl_dir + '/top.f';
		fs.readFile(rtl_dir_f_list, 'utf8', function(err,data) {
		    var lines = data.split('\n');
		    for(var line = 0; line < lines.length; line++){
			var filename = lines[line].replace(/^.*[\\\/]/, '');
			if(!filename.match(rtl_patt)) {
			    fs.appendFileSync(w_filename, lines[line] + '\n');
			    console.log('including this file ' + filename);
			}
		    }

		});
	    }
            cnt += 1;
            pop_dir();
	    
            exec_rsim_cmd(cnt);
        });

        pwd.on('exit', function(code, signal) {
            if(code) {
                var err = 'Execution Failed';
                throw err;
            }
        });

    } else if (typeof cmd_args === 'undefined') {
        post_process(cnt, 'command_skipped');
        cnt += 1;
        exec_rsim_cmd(cnt);
    } else {
        console.log('Program Execution done');
        post_process(cnt, 'report_status');
    }


}

/*
 Copy Configuration file to debug/<block>/<config>/json directory
 */
function copyConfigFile() {
    var concertoCfg = rsim_ds.concerto_cfg;
    var destination = rsim_ds.json_dir + '/' + path.basename(concertoCfg);
    fs.readFile(concertoCfg, function(error, data) {
        if (error) {
            console.log('Unable to read file: ' + concertoCfg);
            throw (error);
        } else {
            fs.writeFile(destination, data, function(error) {
                if (error) {
                    console.log('Unable to copy file to: ' + destination);
                    throw (error);
                }
            });
        }
    });
}

function build_tb_status(code) {
    if(code) {
        var err = 'Failed generating dv files ' + rsim_ds.dv_dir;
        console.log(err);
        throw err;
    } else {
        console.log('Successfully generated dv files ' + rsim_ds.dv_dir);
        gen_bundle();
        //exec_rsim_cmd(0);
    }
}

//Builds Testbench environment files
function build_tb_env() {
    if ((!cli.notEnvGen) && (cli.compile)) {
        var params = [];
        var cmd_args = [];
	console.log('concerto_cfg = ' + rsim_ds.concerto_cfg);
        params = [rsim_ds.concerto_cfg, rsim_ds.tb_hierarchy];

        //Copy config file to test debug directory
	if(cli.codegen) {
	} else {
            copyConfigFile();
	}

        console.log('Building dv files for ' + cli.environment);
        genTB.build_tb(cli.environment, params, rsim_ds.cfg_dir, cli.defines, rsim_ds.ws_top, cli.regression, function(code) {
            build_tb_status(code);

        });
    } else {
        console.log('Skipped generation of dv files; Pre-existing dv files are either used for compilation or/and running test');
        gen_bundle();
        //exec_rsim_cmd(0);
    }
    disp_info.push(cli.environment + ' dv files: ' + rsim_ds.dv_dir);
}

/*
 Method constructs directory hierarchy
 */
function mkDirectories(dirList) {
    if (dirList.length) {
        var dir = dirList.shift();
        fs.mkdir(dir, function(error) {
            //if(error) console.log(dir + ' already exists');
            mkDirectories(dirList);
        });
    } else {
        build_tb_env();
    }
}


/*
 Ignore creating directories if
 user executes script from debug
 directory
 */
function gen_dir() {
    var cwd = process.cwd();
    var myArr = [rsim_ds.debug_dir, rsim_ds.env_dir, rsim_ds.cfg_dir,
                 rsim_ds.dv_dir, rsim_ds.exe_dir, rsim_ds.json_dir,
                 rsim_ds.rtl_dir, rsim_ds.run_dir
                ];
    mkDirectories(myArr);
}

/*
 Delete all files in directories specified in
 the array passed and then executes the callback function
 */
function rmDirectories(dirList) {
    var rmdirList = dirList;
    if (rmdirList.length !== 0) {
        var dir = dirList.pop();

        proc.exec('rm -Rf ' + dir, function(code, stdout, stderr) {
            if (code) {
                console.log('Unable to delete ' + dir + ' directory. Make sure all files are closed');
                throw ('error');
            } else {
                rmDirectories(dirList);
            }
        });
    } else {
        gen_dir();
    }
}

function rmdirs() {
    var cwd = process.cwd();
    if (!(cwd.match(rsim_ds.debug_dir) || cli.notEnvGen) && (cli.compile)) {
        if (fs.existsSync(rsim_ds.cfg_dir)) {
            var arr = [rsim_ds.dv_dir, rsim_ds.exe_dir, rsim_ds.json_dir];
            console.log('Deleting dv/, exe/, & json/ directories within ' + rsim_ds.cfg_dir + ' directory');
            rmDirectories(arr);
        } else {
            gen_dir();
        }
    } else {
        gen_dir();
    }
}

function exec_rsim_cmds() {
    //    for(var prop in rsim_ds)
    //        console.log(prop + ': ' + rsim_ds[prop])
    rmdirs();

}

function getConcertoCfg() {
    if (cli.codegen) {
	var codegen_loc = rsim_ds.env_dir  + '/' + cli.userConfigDir + '/' + (cli.codegen.replace(/^.*[\\\/]/, '')).slice(0,-4) + 'AchlParams.json'; //-4 because always apf for this case
	console.log('code_gen loc = ' + codegen_loc);
	var codegen_cmd = process.env.WORK_TOP + '/node_modules/.bin/generatecli -a ' + codegen_loc + ' ' + cli.codegen;
	try {
	    proc.execSync(codegen_cmd, function(code, stdout, stderr) {
		if (code != null) {
		    //		console.log('codegen failed ACHL Params generation. Please run the following command to reproduce : ' + codegen_cmd);
		    //		throw('error');
		} else {
		} 
	    });
	}
	catch (err) {};
	return (path.resolve(codegen_loc));
    } else if (cli.configParams) {
        return (path.resolve(cli.configParams));
    } else {
        return (path.resolve(rsim_ds.ws_top + '/rtl/lib/src/concerto_system_params_hier.js'));
    }
}

function setupDirLinks() {
    var fname, arr;
    var cfg_dir = 'concerto_system_params_hier';

    if (typeof cli.uniqueID == 'undefined') {
	cli.uniqueID == '';
    };
	
    if (cli.userConfigDir) {
        rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cli.userConfigDir;

        rsim_ds.json_dir = rsim_ds.cfg_dir + '/' + 'json';
        rsim_ds.dv_dir = rsim_ds.cfg_dir + '/' + 'dv';
        rsim_ds.rtl_dir = rsim_ds.cfg_dir + '/' + 'rtl';
        rsim_ds.exe_dir = rsim_ds.cfg_dir + '/' + 'exe';
        rsim_ds.run_dir = rsim_ds.cfg_dir + '/' + 'run';
        rsim_ds.achlBundle = rsim_ds.cfg_dir + '/bundle.js';

        if (cli.regression && cli.testname) {
            rsim_ds.test_dir = rsim_ds.run_dir + '/' + cli.testname;
            fs.readdir(rsim_ds.run_dir, function(err, files) {
                if (!err)
                    rsim_ds.test_dir = rsim_ds.test_dir + '_' + files.length + '_' + genMilliSec() + '_' + cli.uniqueID;
                else
                    rsim_ds.test_dir = rsim_ds.test_dir + '_0' + '_' + genMilliSec() + '_' + cli.uniqueID;

                exec_rsim_cmds();
            });
        } else if (cli.testname) {
            rsim_ds.test_dir = rsim_ds.run_dir + '/' + cli.testname;
            exec_rsim_cmds();
        }
        //Only compile option
        else {
            exec_rsim_cmds();
        }
    } //end of cli.userConfigDir loop
    else {
        if(cli.codegen) {
            rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cfg_dir + '_' + files.length;
	} else if (cli.configParams) {
            arr = cli.configParams.split('/');
            cfg_dir = arr.pop();
            cfg_dir = cfg_dir.substring(0, cfg_dir.indexOf('.'));
        } //End of cli.configParams loop

        //If regression append directory count, append 0 for first directory to differentiate from normal debug
        //Write results into a file for later use
        if (cli.regression) {
            if (cli.compile) {
                fs.readdir(rsim_ds.env_dir, function(err, files) {
                    if (!err)
                        rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cfg_dir + '_' + files.length;
                    else
                        rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cfg_dir + '_0';

                    rsim_ds.json_dir = rsim_ds.cfg_dir + '/' + 'json';
                    rsim_ds.dv_dir = rsim_ds.cfg_dir + '/' + 'dv';
                    rsim_ds.rtl_dir = rsim_ds.cfg_dir + '/' + 'rtl';
                    rsim_ds.exe_dir = rsim_ds.cfg_dir + '/' + 'exe';
                    rsim_ds.run_dir = rsim_ds.cfg_dir + '/' + 'run';
                    rsim_ds.achlBundle = rsim_ds.cfg_dir + '/bundle.js';

                    fs.writeFile('config_dir.txt', rsim_ds.cfg_dir, function(err) {
                        if (err) {
                            console.log('Unable to write to file.');
                            throw (err);
                        }
                    });

                    if (cli.testname) {
                        rsim_ds.test_dir = rsim_ds.run_dir + '/' + cli.testname;
                        fs.readdir(rsim_ds.run_dir, function(err, files) {
                            if (!err)
                                rsim_ds.test_dir = rsim_ds.test_dir + '_' + files.length + '_' + cli.uniqueID;
                            else
                                rsim_ds.test_dir = rsim_ds.test_dir + '_0' + '_' + cli.uniqueID;

                            exec_rsim_cmds();
                        });
                    } else {
                        rsim_ds.test_dir = undefined;
                        exec_rsim_cmds();
                    }
                });
            } else if (cli.testname) {
                fname = 'config_dir.txt';
                rsim_ds.cfg_dir = fs.readFileSync(fname, 'utf8');
                rsim_ds.json_dir = rsim_ds.cfg_dir + '/' + 'json';
                rsim_ds.dv_dir = rsim_ds.cfg_dir + '/' + 'dv';
                rsim_ds.rtl_dir = rsim_ds.cfg_dir + '/' + 'rtl';
                rsim_ds.exe_dir = rsim_ds.cfg_dir + '/' + 'exe';
                rsim_ds.run_dir = rsim_ds.cfg_dir + '/' + 'run';
                rsim_ds.achlBundle = rsim_ds.cfg_dir + '/bundle.js';
                rsim_ds.test_dir = rsim_ds.run_dir + '/' + cli.testname;

                fs.readdirSync(rsim_ds.run_dir, function(err, files) {
                    if (!err)
                        rsim_ds.test_dir = rsim_ds.test_dir + '_' + files.length + '_' + genMilliSec() + '_' + cli.uniqueID;
                    else 
                        rsim_ds.test_dir = rsim_ds.test_dir + '_0' + '_' + genMilliSec() + '_' + cli.uniqueID;
                    exec_rsim_cmds();
                });
            } //End of cli.testname loop
        }
        //End of cli.regression loop
        else {
            //If running test and compile both at a time then name config directory command line config string passed
            //else if only running test the name config directory by reading file.
            if (cli.compile && cli.testname) {
                rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cfg_dir;
            } else if (cli.testname) {
                fname = 'config_dir.txt';
                rsim_ds.cfg_dir = fs.readFileSync(fname, 'utf8');
            } else {
                rsim_ds.cfg_dir = rsim_ds.env_dir + '/' + cfg_dir;
            }

            rsim_ds.json_dir = rsim_ds.cfg_dir + '/' + 'json';
            rsim_ds.dv_dir = rsim_ds.cfg_dir + '/' + 'dv';
            rsim_ds.rtl_dir = rsim_ds.cfg_dir + '/' + 'rtl';
            rsim_ds.exe_dir = rsim_ds.cfg_dir + '/' + 'exe';
            rsim_ds.achlBundle = rsim_ds.cfg_dir + '/bundle.js';

	    if (cli.grid_run) {
		rsim_ds.run_dir = ''
	    } else {
		rsim_ds.run_dir = rsim_ds.cfg_dir + '/' + 'run';
	    }
            if (cli.testname) {
                rsim_ds.test_dir = rsim_ds.run_dir + '/' + cli.testname;
            }

            //Write config directory into a file
            if (cli.compile) {
                fs.writeFile('config_dir.txt', rsim_ds.cfg_dir, function(err) {
                    if (err) {
                        console.log('Unable to write to file.');
                        throw (err);
                    }
                });
            } //End of cli.compile loop

            exec_rsim_cmds();
        } //End of else loop of cli.regression
    } //end of cli.userConfigDir loop
}

function setupRsimStruct(dbgPath, wsTop) {
    //Sets rsim_ds objects
    rsim_ds.ws_top = wsTop;
    rsim_ds.debug_dir = dbgPath + '/debug';
    rsim_ds.env_dir = rsim_ds.debug_dir + '/' + cli.environment;

    // rsim_ds.build_tb = rsim_ds.ws_top + '/' + 'dv/scripts/build_tb_env.js';
    rsim_ds.concerto_cfg = getConcertoCfg();
    console.log('concerto_cfg setupRsimStruct = ' + rsim_ds.concerto_cfg);
    rsim_ds.concerto_encodings = rsim_ds.ws_top + '/rtl/lib/src/concerto_encodings.js';
    rsim_ds.tb_hierarchy = rsim_ds.ws_top + '/dv/scripts/concerto_tb_hier.js';
    rsim_ds.rtl_top = 'v1_tb_top.achl.js';

    //ACHL execution option
    if (cli.latestAchlVer) {
        rsim_ds.achl_exec1 = '/engr/dev/tools/achl/achl-latest/.bin/acc';
        rsim_ds.achl_exec2 = '/engr/dev/tools/achl/achl-latest/.bin/ac';
    } else {
        rsim_ds.achl_exec1 = '/engr/dev/tools/achl/achl-current/.bin/acc';
        rsim_ds.achl_exec2 = '/engr/dev/tools/achl/achl-current/.bin/ac';
    }

    //Code Coverage switch
    if (cli.codeCoverage) {
        rsim_ds.cmpCodeCov = '-lca -cm line+cond+fsm+tgl+path+assert -cm_line contassign -cm_cond allops+anywidth+event -cm_noconst ';
        rsim_ds.runCodeCov = '-lca -cm line+cond+fsm+tgl+assert+path -cm_dir simv ';
    } else {
        rsim_ds.cmpCodeCov = '';
        rsim_ds.runCodeCov = '';
    }

    //Group Coverage switch
    if (cli.groupCoverage) {
        rsim_ds.groupCoverage = '-cg_coverage_control=1';
    } else {
        rsim_ds.groupCoverage = '';
    }

    //Setup config directory & related parameters
    setupDirLinks();
    //this assignment goes after so that rsim_ds is already defined: DAVIDC

}

function exec_wstop() {
    var dbgPath, WsTop;
    if (typeof process.env.WORK_TOP === 'undefined') {
        var err = '\nFATAL: Environment variable WORK_TOP is not set';
        console.error(err);
        return;
    } else {
        WsTop = path.resolve(process.env.WORK_TOP);
        if (!(cli.dumpPath)) {
            dbgPath = WsTop;
        } else {
            dbgPath = path.resolve(cli.dumpPath);
        }
        //Setup the script data structure
        setupRsimStruct(dbgPath, WsTop);
    }
}

/*
 * Called when script executed on command line
 * Initiates all tasks
 */
exec_wstop();

//                       + '_' + dt.getFullYear() +
//                       '_' + dt.getMonth() + '_' + dt.getDate() +
//                       '_' + dt.getHours() + '_' + dt.getMinutes() +
//                       '_' + dt.getSeconds();
//
