/*
  Author : David Clarino
  Date   : 9/21/17
changes

*/

//**********IMPORT LIBRARY FILES**********
var fs 		= require('fs');
var path 	= require('path');
var proc 	= require('child_process');
var cli 	= require('commander');
var genBlockFList = require(process.env.WORK_TOP + '/dv/scripts/flist_gen.js').genBlockFlist;

var path_str = [];
//if(process.env.SCRIPTS_TOP === undefined)
//    throw new Error("ERROR! SCRIPTS_TOP must be defined in this environment!");

//make this point to central json later?
//var defaultRsim = require(process.env.SCRIPTS_TOP + '/defaultRsim.js');
var defaultRsim = require(process.env.WORK_TOP + '/../scripts').defaultRsim;

//var tbNamingMap = require(process.env.WORK_TOP + 'dv/full_sys/tb').tbMap;

//var genBuildTb = require(process.env.WORK_TOP + "dv/scripts/buildTb.js").genTb;
module.exports = {
    stateFunc          : stateFunc,
    execFunc           : execFunc,
}

function stateFunc(args,callback,testObj) {
//    console.log(args.state);
    switch(args.state) {
/* DCDELETE
    case "gen_dir" : {
	if((args.cli.achl !== undefined) && ((args.cli.tcl_input !== undefined) || (args.cli.tcl_cfg !== undefined)))
	    return "run_maestro";
	else
	    return defaultRsim.stateFunc(args,callback,testObj);
    }
    case "run_maestro" : {
	args.state = "gen_dir";
	return defaultRsim.stateFunc(args,callback,testObj);
    }
*/
    case "gen_params" : {
	return  "check_params" ;
    }
    case "check_params" : {
	args.state = "gen_params";
	if(((args.cli.achl !== undefined) && (args.rtlPkg !== undefined)) || (args.cli.tcl_input !== undefined) || (args.cli.tcl_cfg !== undefined))
	    return defaultRsim.stateFunc(args,callback,testObj);
	else if(args.cli.compile)
	    return "gen_tb";
	else
	    return "stop";
	break;
    }

    case "run_test" : {
	if(args.cli.run_tempo)
	    return "run_tempo";
	else
	    return defaultRsim.stateFunc(args, callback, testObj);
    }
    case "gen_rtl" : {
	if (args.cli.Lint)
	    return "run_lint";
	else if (args.cli.compile)
	    return "gen_tb";
	else
	    return "compile";
	break;
    }
    case "run_tempo" : {
	args.state = "run_test";
	return defaultRsim.stateFunc(args, callback, testObj);
    }
    case "gen_tb" : {
	if(args.cli.achl && (args.rtl_json || args.cli.tcl_input || args.cli.tcl_cfg) && (args.cli.skip_maestro == null) && (args.cli.environment !== 'cust_tb' && args.cli.environment !== 'snps_test_suite'))
//	if(args.cli.achl && (args.rtl_json || args.cli.tcl_input || args.cli.tcl_cfg))
	{
	    return "gen_ralgen";
	}
	else
	    return defaultRsim.stateFunc(args,callback,testObj);
    }	
    case "gen_ralgen" : {
		args.state = "gen_tb";
		return defaultRsim.stateFunc(args,callback,testObj);
		break;
    }

    default : {
	return defaultRsim.stateFunc(args,callback,testObj);
	break;
    }
    };
}
function execFunc(args,callback,testObj) {
//    console.log('DCDEBUG state ' + args.state);
//    console.log('DCDEBUG cli ' + JSON.stringify(args.cli,null,' '));
    switch(args.state) {
/* DCDELETE
    case "run_maestro" : {
	return runMaestro;
    }
*/
    case "gen_dir" : {
	return genDirs;
	break;
    }
    case "get_args" : {
	return getArgs;
	break;
    }
    case "check_params" : {
	return checkParams;
	break;
    }
    case "run_lint" : {
	return runLint;
	break;
    }
    case "gen_ralgen" : {
	return genRalgen;
	break;
    }
    case "run_test" : {
	//DCDEBUG
	if (args.cli.environment === 'cust_tb' || args.cli.environment === 'snps_test_suite') {
	    return runCustTbTest;
	   }
	else if(args.cli.skip_test === undefined) {
	    // console.log("I am in args.cli.skip_test === undefined");
	    return defaultRsim.execFunc(args,callback,testObj);
	   }
	else if (args.cli.questaSimulator)
	    return runMentorTest;
	else
	    return function(args,callback,testObj) { callback(args,testObj); };
    }
    case "gen_rtl_dirs": {
	return genRtlDirs;
	break;
    }
    case "run_tempo" : {
	return runTempo;
    }
    case "gen_rtl" : {
	if(args.rtlType == "TACHL" || (args.rtlType === undefined)) {
	    return genTachlWithCopy(args,callback,testObj);
	} else {
	    return defaultRsim.execFunc(args,callback,testObj);
	}
	break;
    }
    case "compile" : {
	if (args.cli.environment === 'cust_tb' || args.cli.environment === 'snps_test_suite')
	    return runCustTbCompile;
	else if(args.cli.questaSimulator)
        if(args.cli.environment === "emu") {
    	    return runVeloceCompile;
		}
	    else {
	        return runMentorCompile;
		}
	else if (args.cli.environment === "emu_t") {
        process.exit(0);
	}
	else
	    return defaultRsim.execFunc(args,callback,testObj);
	break;
    }
    case "gen_params" : {
	return getParams;
	break;
    }
    default : {
	return defaultRsim.execFunc(args,callback,testObj);
	break;
    }
    }
}

function runTempo(args,callback,testObj) {
    var Tempo = "/engr/dev/tools/script/tempo/latest/maincheck"

    if(args.cli.grid_run)
	var test_dir = '/local/' + process.env.USER + '/' + args.cli.grid_run
    else
	var test_dir = args.test_dir;
    if (cli.run_time_options) {
	if(cli.run_time_options.match("veloce")) {
        var args_str = "-json " + args.exe_dir + "/output/debug/top.level.dv_sorted.json -trace " + test_dir + "/../../exe/concerto_trace.txt";
        }
        }
        else { 
        var args_str = "-json " + args.exe_dir + "/output/debug/top.level.dv_sorted.json -trace "  +  test_dir + "/concerto_trace.txt" ;
         }
    var args_str = "-json " + args.exe_dir + "/output/debug/top.level.dv_sorted.json -trace " + test_dir + "/concerto_trace.txt";

    console.log(Tempo + " " + args_str);

    var out = fs.openSync(test_dir + '/tempo.log','a');
    var pwd = proc.spawn(Tempo,args_str.split(' '), {stdio:["inherit",out]});
    pwd.on('close', function(err) {
	if(err) {
	    // throw err;
	}
    });
/*
    try {
	var str = proc.execSync(Tempo + " " + args_str).toString();
	fs.writeFileSync(test_dir + '/tempo.log',str,'utf8');
    } catch(err) {
	if(err) {
	    console.log(str);
	    fs.writeFileSync(test_dir + '/tempo.log',str,'utf8');
	    throw new Error();
	}
    }
    console.log(str);
  */  
    /*    var pwd = proc.spawn("/engr/dev/tools/script/tempo/latest/maincheck",args_str.split(' '),{stdio:"inherit"} );
    pwd.on('close', function() {
	callback(args,testObj);
    });
*/
    callback(args,testObj);
}
function genRalgen(args,callback,testObj) {
    //var cli = args.cli
    var rsim_ds = args;
    var stitcher_args = ['ipxact -j ' +  args.cli.unitRtlParams + ' -v library=ncore,rtlPrefixName='+args.cli.environment + ' -o ' + args.exe_dir + '/xml_output'];
    var ralgen_args;
console.log("genRalgen");

    if(args.cli.tcl_input == undefined && args.cli.tcl_cfg == undefined){
	proc.execSync('stitcher ' + stitcher_args);
    	ralgen_args = ["-uvm", "-l", "sv", "-t ncore", "-o ", args.exe_dir + '/concerto_register_map', "-ipxact ", args.exe_dir + '/xml_output/*2009.xml'];
	execRalgen(ralgen_args,args,testObj);
    }else{
	if((args.cli.environment == "fsys") || (args.cli.environment == "fsys_snps")  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "ioaiu_subsys") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "emu")) {
    	    ralgen_args = ["-uvm", "-l", "sv", "-t ncore", "-o ", args.dv_dir + '/concerto_register_map', "-ipxact ", args.exe_dir + '/output/IPXACT/' + args.params.strProjectName + '_2009.xml'];
	    execRalgen(ralgen_args,args,testObj);

            const file_content = fs.readFileSync(args.exe_dir + '/output/IPXACT/' + args.params.strProjectName + '_2009.xml');
            const regex =  new RegExp ('fsc');
            if(regex.test(file_content)){
 	    	ralgen_args = ["-uvm", "-l", "sv", "-t resiliency", "-o ", args.dv_dir + '/fsc_concerto_register_map', "-ipxact ", args.exe_dir + '/output/IPXACT/' + args.params.strProjectName + '_2009.xml'];
	    	execRalgen(ralgen_args,args,testObj);
           }
	} else if((args.cli.environment == "cust_tb") || args.cli.environment === 'snps_test_suite') {
    	    ralgen_args = ["-uvm", "-l", "sv", "-t ncore", "-o ", args.dv_dir + '/ncore_system_register_map', "-ipxact ", args.exe_dir + '/output/IPXACT/' + args.params.strProjectName + '_2009.xml'];
	    execRalgen(ralgen_args,args,testObj);
	} else {
	    var ralgenUnits = getRalgenUnits(args);
	    ralgenUnits.forEach(function(unitObj) {
		if((args.cli.instanceName) ? (unitObj.name == args.cli.instanceName) : 1) {
    		    ralgen_args = ["-uvm", "-l", "sv", "-t ncore", "-o ", args.exe_dir + '/' + unitObj.name + '_concerto_register_map', "-ipxact ", args.exe_dir + '/output/debug/IPXACT/' + unitObj.name + '_*2009.xml'];
		    execRalgen(ralgen_args,args,testObj);
		}
	    });
	}

    }

    callback(args,testObj);
}

function execRalgen(ralgen_args,args,testObj) {

    fs.writeFileSync(args.exe_dir + '/run_ralgen',
		     '#!/bin/bash\n' +
		     'source /usr/share/Modules/init/bash\n' + 
		     'source /opt/sge/default/common/settings.sh\n' + 
		     'export PATH=/usr/bin/:$PATH\n' +
		     'lic_string=\`lmstat -c 5285@lic-node0 -a \| grep VCSTools_Net \| grep -o \"Total\\ of\\ [0-9]\\ licenses\\ in\\ use\"| grep -o "[0-9]"\`\n' + 
		     'while [ "$lic_string" -gt 1 ] ; do\n' + 
		     'echo \"WAITING FOR VCSTools_Net LICENSE\"\n' + 
		     'sleep 100s\n' +
		     'lic_string=\`lmstat -c 5285@lic-node0 -a \| grep VCSTools_Net \| grep -o \"Total\\ of\\ [2-9]\\ licenses\\ in\\ use\"| grep -o "[0-9]"\`\n' + 
		     'done\n' + 
		     "$VCS_HOME/bin/ralgen "+ ralgen_args.join(' '),'utf8');
    console.log ("ralgen :" + ralgen_args);
    fs.chmodSync(args.exe_dir + '/run_ralgen',511);
    var realErr = 0;
    var os_type = proc.execSync('uname -a').toString();


    if(os_type.match('el7|el8')) {
	var cmdStr = 'qsub -V -P ncore3 -q checkin.q -sync y -l VCSTools_Net=1 -o ' + args.exe_dir + '/ralgen.out' + ' -e ' + args.exe_dir + '/ralgen.err ' + ' -b y \"' + args.exe_dir + '/run_ralgen\"';
    } else {
	var cmdStr = 'qsub -V -P oc -sync y -l VCSTools_Net=1 -o ' + args.exe_dir + '/ralgen.out' + ' -e ' + args.exe_dir + '/ralgen.err ' + ' -b y \"' + args.exe_dir + '/run_ralgen\"';
    }
    var str = proc.execSync(cmdStr,[]).toString();
    console.log(str);
    //console.log(fs.readFileSync(args.exe_dir + '/ralgen.out'));
    
    //if(fs.readFileSync(args.exe_dir + '/ralgen.err').toString() != "")
	//console.log(fs.readFileSync(args.exe_dir + '/ralgen.err'));

/*
} else {
	try {
	    var str = proc.execSync(args.exe_dir + '/run_ralgen');
	    console.log(str.toString());
	} catch(err) {
	    if(err) {
		if(err.toString().match('Licensed number'))
		    genRalgen(args,callback,testObj);
		else {
		    console.log(err.toString());
		    throw err;
		}
	    }
    }
*/
//    callback(args,testObj);
/*
    var pwd = proc.spawn(args.exe_dir + '/run_ralgen', []);
    var err_flag = 0;
    pwd.stderr.on('data', function(data) {
	console.log('stderr: \n' + data);
        err_flag = 1;
	if(!data.includes('Licensed number')){
		return;
	}else{
		genRalgen(args,callback,testObj);
	}
    });
    pwd.on('close', function(code) {
		if((err_flag==0) && !fs.existsSync( args.dv_dir + '/concerto_register_map.sv')){
			genRalgen(args,callback,testObj);
		}
		console.log('Done ralgen:{code} ' +code);
		callback(args,testObj);
    });
*/
    
}

function runCustTbCompile(args,callback,testObj) {
  var rsim_ds = args;
  var comp_cmd = 'build TB_SRC=../dv';
  var cmd_args = comp_cmd.split(' ');
  
  process.env.PROJ_HOME = rsim_ds.exe_dir + '/output';
  if (cli.sim_tool === "snps") {
/*    if (!fs.existsSync(rsim_ds.env_dir + '/snps_amba_vip')) {
      console.log('generating the snps_amba_vip at ' + rsim_ds.env_dir + '/snps_amba_vip');
      push_dir(rsim_ds.env_dir);
      var str = proc.execSync('$DESIGNWARE_HOME/bin/dw_vip_setup -path snps_amba_vip -e amba_svt/tb_chi_svt_uvm_basic_sys'); 
      console.log(str);
    }
    process.env.SNPS_AMBA_VIP = rsim_ds.env_dir + '/snps_amba_vip';
*/ 
    if (!fs.existsSync('/scratch/dv_reg/common_vip_lib/snps_amba_vip')) {
      console.log('generating the snps_amba_vip at ' + '/scratch/dv_reg/common_vip_lib/snps_amba_vip');
      if (!fs.existsSync('/scratch/dv_reg/common_vip_lib')) { fs.mkdirSync('/scratch/dv_reg/common_vip_lib');}
      push_dir('/scratch/dv_reg/common_vip_lib');
      var str = proc.execSync('$DESIGNWARE_HOME/bin/dw_vip_setup -path snps_amba_vip -e amba_svt/tb_chi_svt_uvm_basic_sys'); 
      console.log(str);
    } 

    process.env.SNPS_AMBA_VIP = '/scratch/dv_reg/common_vip_lib/snps_amba_vip';
    
  } else if (cli.sim_tool === "cdns"){
    process.env.CDN_VIP_ROOT = '/engr/eda/tools/cadence/vipcat_11.30.096-03_Apr_2024_08_15_04';  
    process.env.CDS_INST_DIR = '/engr/eda/tools/cadence/XCELIUM_24.03.002';  
    process.env.CDS_ARCH     = 'lnx86';  
    process.env.DENALI       = process.env.CDN_VIP_ROOT + '/tools.' + process.env.CDS_ARCH + '/denali_64bit';  
    process.env.CDN_VIP_LIB_PATH = 'engr/eda/tools/cadence/cdns_vip_lib/11.30.096';
    if (!fs.existsSync('/scratch/dv_reg/common_vip_lib')) { fs.mkdirSync('/scratch/dv_reg/common_vip_lib');}
    process.env.SPECMAN_PATH = process.env.CDN_VIP_ROOT + '/packages:'+ process.env.CDN_VIP_LIB_PATH + '/64bit';
    process.env.PATH = `${process.env.CDS_INST_DIR}/tools.${process.env.CDS_ARCH}/bin/64bit:${process.env.CDN_VIP_ROOT}/tools.${process.env.CDS_ARCH}/bin/64bit:${process.env.PATH}`;
    process.env.LD_LIBRARY_PATH = `${process.env.CDN_VIP_LIB_PATH}/64bit:${process.env.DENALI}/verilog:${process.env.CDS_INST_DIR}/tools.${process.env.CDS_ARCH}/specman/lib/64bit:${process.env.CDS_INST_DIR}/tools.${process.env.CDS_ARCH}/lib/64bit:${process.env.LD_LIBRARY_PATH}`;
    process.env.CDS_LIC_FILE = '5282@lic-node0.arteris.com:5282@yquem.arteris.com:5282@lic01.arteris.com';
    process.env.LM_LICENSE_FILE = '5285@lic-node0.arteris.com'+':'+process.env.CDS_LIC_FILE+':'+process.env.LM_LICENSE_FILE;
    //Disable automatic nc to xm remapping
    process.env.CDN_VIP_DISABLE_REMAP_NC_XM = '';
    // wait for license
    process.env.CADENCE_VIP_LIC_Q_ONLY_WHEN_ALL_IN_USE = 0;
    process.env.CADENCE_VIP_LIC_Q_TIMEOUT = -1;
    process.env.CADENCE_VIP_LIC_DEBUG = 1;
  } else {
      throw new Error("ERROR! sim tool is not defined in -k option for compilation");
  
  }
    
  push_dir(rsim_ds.cfg_dir + "/dv");
  testFunc('runCustTbCompile', { "comp_cmd": comp_cmd }, testObj, function () {

	var pwd = proc.spawn('make', cmd_args, { stdio: "inherit" });
	
	pwd.on('close', function (err) {
	    if (err) {
	        throw err;
		throw new Error("ERROR! Something went wrong with VCS Compile! Please run make build in " + rsim_ds.cfg_dir + "/dv to reproduce this error");
	    } else {

		console.log('===============COMPILE SUCCESSFUL===============');
		//if (args.rtlPkg === undefined)
		//    console.log('===============RTLGEN SUCCESSFUL===============');
		proc.execSync('sleep 1s');
		callback(args, testObj);
	    }
	});
    });
}

function runVeloceCompile(args,callback,testObj) {
if(args.cli.environment === "emu") {
proc.exec('echo $XL_VIP_LIBS_QUESTA_PATH', {env: {'XL_VIP_LIBS_QUESTA_PATH' : '/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/'}}, function (error, stdout, stderr) {
  console.log(stdout, stderr, error);
});

console.log(process.env.XL_VIP_LIBS_QUESTA_PATH);
  process.env["XL_VIP_LIBS_QUESTA_PATH"] = '/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/' ;
  process.env["TRANSACTOR_LIBS"]  = '/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/lib/linux64_el30_gnu53/libcommontbx.a' ;
  process.env["TRANSACTOR_LIBS"] += '/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/lib/linux64_el30_gnu53/libchi_v2tbx.a' ;
  process.env["TRANSACTOR_LIBS"] += '/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/lib/linux64_el30_gnu53/libaxi_v2tbx.a' ;
  process.env["VTL_AXI_V2_VERSION"] = 'axi_v2' ;
  process.env["VTL_CHI_V2_VERSION"] = 'chi_v2' ;
  
var QUESTA_MVC_DIR = '$(shell ls $(VELOCE_XACTOR_HOME) | grep \'QUESTA_x.*UVM\' )' ;

var QUESTA_MVC_HOME_PATH = path.join('process.env.VELOCE_XACTOR_HOME' + 'QUESTA_MVC_DIR ') ;

proc.exec('echo $QUESTA_MVC_HOME', {env: {'QUESTA_MVC_HOME' : QUESTA_MVC_HOME_PATH}}, function (error, stdout, stderr) {
  console.log(stdout, stderr, error);
});
//export QUESTA_MVC_HOME;

var C_INCL  = '-I ' + process.env.QUESTA_MVC_HOME + '/include/systemc '    + '-I ' + process.env.QUESTA_MVC_HOME + '/include ' ;
    C_INCL += '-I ' + process.env.VELOCE_XACTOR_HOME + '/common/include '  + '-I ' + process.env.QUESTA_MVC_HOME + '/include ' ;

var C_FILES = process.env.VELOCE_XACTOR_HOME + '/common/include/vtl_c_defs.cxx ' ;
}

    var cli = args.cli;
    var rsim_ds = args;
    var assertFiles = fs.readdirSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
    var assertFlist = ""
    var xprop_options = {};
    /*
    for(var i = 0; i < assertFiles.length; i++) {
	if(fs.lstatSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/' + assertFiles[i]).isFile()) {
	    proc.execSync('cp ' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/' + assertFiles[i] + ' ' + args.cfg_dir + '/dv');
	}
    }  */
    var filesVc = fs.readFileSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/files.vc','utf8').split('\n');
    filesVc.forEach(function(line) {
//	var newLine = line.replace(/^\.\//,args.cfg_dir + '/dv/');
	var newLine = line.replace(/^\.\//,process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
	newLine = newLine.replace(/^\+incdir\+./,'+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
	assertFlist += newLine + '\n';
    });
    if(args.cli.environment == "fsys" || args.cli.environment == "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || args.cli.environment == "ioaiu_subsys" || (args.cli.environment == "chi_subsys") || args.cli.environment == "emu") {
	//proc.execSync('cp ' + args.exe_dir + '/concerto_register_map.sv ' + args.dv_dir);
    } else {
	var ralgenUnits = getRalgenUnits(args);
	ralgenUnits.forEach(function(unitObj) {
	    if((args.cli.instanceName) ? (unitObj.name == args.cli.instanceName) : 1) {
		proc.execSync('cp ' + args.exe_dir + '/' + unitObj.name + '_concerto_register_map.sv ' + args.dv_dir);
	    }
	});
    }

//	    proc.execSync('cp ' + args.exe_dir + '/concerto_register_map.sv ' + args.dv_dir);
    var verFiles = fs.readdirSync(process.env.WORK_TOP + '/node_modules/@arteris/hw-lib/verilog/');
    var verFlist = "";
    for(var i = 0; i < verFiles.length; i++) {
	verFlist += args.rtl_dir + '/' + verFiles[i] + '\n'
	proc.execSync('cp ' + process.env.WORK_TOP + '/node_modules/@arteris/hw-lib/verilog/' + verFiles[i] + ' ' + args.cfg_dir + '/rtl');	
    }
    if(args.rtl_json)
	fs.writeFileSync(args.cfg_dir + '/rtl/verFiles.flist', verFlist,'utf-8'); 

//    var newFlist = '-f ../rtl/verFiles.flist\n-f ../dv/files.vc\n' + fs.readFileSync(args.cfg_dir + '/dv/vcs.flist');
    newFlist += '+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva\n';
//    newFlist += '-f ' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/files.vc\n';

    var lines = fs.readFileSync(args.cfg_dir + '/dv/vcs.flist','utf-8').split('\n');
    var emu_lines = fs.readFileSync(args.cfg_dir + '/dv/vcs.flist','utf-8').split('\n');
    var insertedFlist = 0;
    if(args.rtl_json)
	var newFlist = '-f ../rtl/verFiles.flist\n';

    else
	var newFlist = '';
	var newHvlFlist = '';
        var newFlist2 = ""; 
        var emuHvlFlist = '';
        var content = "";
            console.log("vcs.flist Extraction started");
         for (var i = 0; i < emu_lines.length; i++) {
            if(emu_lines[i].match(args.cfg_dir) && !emu_lines[i].match[/axi_if.sv/g]) {
             fs.writeFileSync(process.env.WORK_TOP + '/dv/full_sys/temp.flist',content, err => {
                if(err) throw err ;
             }); 
            console.log("vcs.flist Extracted");}
        }


    for(var i = 0;i < lines.length;i++) {
        if (lines[i].match(/axi_if/g) || lines[i].match(/axi_agent_pkg/g) || lines[i].match(/axi_if/g) || lines[i].match(/axi_agent_pkg/g) || lines[i].match(/ncore_probe_module/g) || lines[i].match(/mem_wrapper_connectivity_checker/g) || lines[i].match(/ioaiu_smi_bfm/g)) {
             newFlist2 += lines[i] + '\n' ;
             fs.writeFileSync(process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',newFlist2 ); 
            console.log("vcs.flist 2 Extracted"); 
            } 
      

        if( !lines[i].match(/^\-f/) && !lines[i].match(/ncore_hdl_top/g) && !lines[i].match(/ncore_probe_module/g) && !lines[i].match(/mem_wrapper_connectivity_checker/g) && !lines[i].match(/AXI_slave_memory/g) && !lines[i].match(/ioaiu_smi_bfm/g)) {
             newHvlFlist += lines[i] + '\n' ;
            
        } else  {
  
             newHvlFlist +=  '\n' ;
        }
	if(lines[i].match(args.cfg_dir) && !lines[i].match(/^\-f/) && !lines[i].match(/\+incdir\+/) && !insertedFlist && cliDefineExists(args,"CHI_ARM_ASSERT_ON")) {
	    fs.writeFileSync(args.cfg_dir + '/dv/files.vc', assertFlist,'utf-8');
	    newFlist += '+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva\n';
	    newFlis += '-f ../dv/files.vc\n';
	    insertedFlist = 1;
	}
if(args.cli.environment === "emu") {

//	if(!(lines[i].match(/flist.f/) && args.rtlPkg == undefined)) {
	    newFlist += lines[i] + '\n';
//	}
}
 if(args.cli.environment === "fsys") {
	if(!(lines[i].match(/flist.f/) && args.rtlPkg == undefined)) {
	    newFlist += lines[i] + '\n';
	}
    }
    }
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/dii_pkg.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/dmi_pkg.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/concerto_xrtl_pkg.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/mgc_resp_pkg.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/classDefpkg.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/AXI_slave_memory.sv\n', 'utf-8');  
          fs.appendFileSync( process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist',args.cfg_dir + '/dv/ncore_hdl_top.sv\n', 'utf-8');  
                      //   += args.cfg_dir + '/dv/AXI_slave_memory.sv\n' ;
                      //   += args.cfg_dir + '/dv/ncore_hdl_top.sv' ;
             var file_lines = "" ;
    fs.writeFileSync(args.cfg_dir + '/dv/vcs.flist',newFlist,'utf-8');
    fs.writeFileSync(process.env.WORK_TOP + '/dv/full_sys/myhvl_emu.flist',newHvlFlist,'utf-8');
//    defaultRsim.runMentorCompile(args,callback,testObj);
    //    setEnv('/engr/dev/tools/script/mentor-eng.sh');
    console.log('setEnvMentor reached');
    args.setEnvMentor();

    genExeDirs(args, callback, testObj);
    push_dir(rsim_ds.exe_dir);
    if (fs.existsSync(rsim_ds.exe_dir + '/build_rtl')) {
	    proc.execSync('rm -rf ' + rsim_ds.exe_dir + '/build_rtl');
    }

    var vel_cfg = '';
    vel_cfg += ' comp -num_boards 4\n ';  
    vel_cfg += ' comp -hvl questa\n ' ; 
    vel_cfg += ' comp -platform Stratoplus\n ';
   // vel_cfg += ' hvl -enable_profile_report\n ';   //Added from emu data base

	// to submit jobs on grid
    //vel_cfg += ' comp -distrib_flow grid\n '; 
    //vel_cfg += ' comp -grid_queue veloce\n '; 
	vel_cfg += ' comp -distrib_flow machlist\n ';
    vel_cfg += ' comp -mf ' + process.env.WORK_TOP + '/emulation/tb/mach.list\n ';


    //vel_cfg += ' rtlc -partition_module_xrtl tb_top\n  ';
    vel_cfg += ' rtlc -allow_ERWC\n '; 
    vel_cfg += ' rtlc -allow_4ST\n '; 
    vel_cfg += ' rtlc -one_way_callee_opt\n '; 
    vel_cfg += ' rtlc -enable_flexmem\n ';
    vel_cfg += ' rtlc -flexmem_use_wr_clk_for_async_rd \n ';
    //vel_cfg += ' rtlc -disable_auto_inactive_negedge \n ';
    vel_cfg += ' velsyn -Mm 10.9\n ';
    vel_cfg += ' comp -rtlc_opt_flow capOnly\n ';
    fs.writeFileSync(rsim_ds.exe_dir + '/veloce.config', vel_cfg,'utf-8');

    if (cli.compile_time_args) {
	if(cli.compile_time_args.match("veloce")) {
             console.log("=============================VELHVL_FOR_VELOCE_1==================================") ;
           //  proc.execSync ('velhvl -g -sim veloce -ldflags "-Wl,--whole-archive /engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/axi_v2/lib/linux64_el30_gnu53/libaxi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/chi_v2/lib/linux64_el30_gnu53/libchi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/common/lib/linux64_el30_gnu53/libcommontbx.a -Wl,--no-whole-archive" -cppinstall 5.3.0 -ldflags "/engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit_extras.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit_stubs.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip.so" ' || true);
             if (fs.existsSync(rsim_ds.exe_dir + '/veloce.med/.compileLock')) {
                 push_dir(rsim_ds.exe_dir);
                 console.log('===============Unlocking compile===============');
                 proc.execSync ('velcomp -unlock_project')
                 pop_dir();
             }
         }
    }else{
         console.log("=============================VELHVL_FOR_VSIM_1==================================") ;
         proc.execSync ('velhvl -g -sim puresim -ldflags "-Wl,--whole-archive /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/lib/linux64_el30_gnu53/libaxi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/lib/linux64_el30_gnu53/libchi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/lib/linux64_el30_gnu53/libcommontbx.a -Wl,--no-whole-archive" -cppinstall 7.4.0 -ldflags "/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit_extras.so /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit.so /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit_stubs.so" ' || true);

   } 
   
       console.log('UVM_HOME ' + process.env['UVM_HOME']);
    proc.execSync('vlib -compress work');
       if (cli.compile_time_args)  {
	if(cli.compile_time_args.match("veloce")) {
            var veloce_hvl_comp_cmd = 'vlog -sv -mfcu -64 -timescale=1ps/1ps -suppress 2620';
            console.log(veloce_hvl_comp_cmd) ;
            console.log("=============================Getting compile_time_args for VELOCE ==================================") ; 
        }else {
               var comp_cmd = 'vlog -sv -mfcu -64 -timescale=1ps/1ps -suppress 2620';
            console.log(comp_cmd) ;
            console.log("=============================Getting compile_time_args for VSIM ==================================") ; 
        }

    } else {
        var comp_cmd = 'vlog -sv -mfcu -64 -timescale=1ps/1ps -suppress 2620';
        console.log(comp_cmd) ;
        console.log(" ***************************************Getting default compile_time_args for VSIM********************") ;
    }

    var HDL_FILES = process.env.VELOCE_XACTOR_HOME + '/common/hdl/common_hdl.f' ;
    var HDL_INCL  =   process.env.VELOCE_XACTOR_HOME + '/common/hdl' ;
    var HVL_FILES = process.env.VELOCE_XACTOR_HOME + '/common/sysvlog/TBXSemaphores.sv ' ;


    var RTL_DIR = args.rtl_dir ;
console.log("RTL DIR is", RTL_DIR) ;

if (cli.compile_time_args) {
 var HW_CFG = args.rtl_dir ;
console.log("RTL DIR is",HW_CFG) ;
 if(cli.compile_time_args.match("hvl_veloce_compile")) {
  proc.execSync( ' velanalyze -extract_hvl_info +incdir+/engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/uvm_pkg.sv ') ;
console.log("UVM PKG compiled Successful_hvl_compile_only")  ;     

       console.log (" *************************** VELCOMP_STARTS_HVL_COMPILE_ONLY *********************** ") ;
    }
   
else if(cli.compile_time_args.match("veloce")) {
  proc.execSync('vlib work');     
  proc.execSync(' vlog -sv -mfcu -64 -timescale=1ps/1ps -work work -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/hdl/vtl_chi_rn.f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/shared/axi_enum_pkg.sv -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/ace_master.f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/install/axi_v2/axi_v2/hdl/vtl_axi_clk_advancer.sv -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_slave.f +define+VELOCE_HDL_COMPILE  -f ' + args.rtl_dir + '/flist.f ' + args.cfg_dir + '/dv/sv_assert_pkg.sv ' + args.cfg_dir + '/dv/addr_trans_mgr_pkg.sv ' + args.cfg_dir + '/dv/common_knob_pkg.sv ' + args.cfg_dir + '/dv/ioaiu0_smi_agent_pkg.sv ' + args.cfg_dir + '/dv/ioaiu_smi_pkg.sv ' + ' -f ' + process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/shared/axi_enum_pkg.sv -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/acelite_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_slave.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/hdl/common_hdl.f +define+STUB_OUT +define+XL_AXI_MONITOR_VERBOSE +define+CARBON +define+VELOCE_RUN /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/AxiMonitor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/axislave_sm_indicator_if.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/vsms5505.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/vsmu5505.sv +incdir+' + process.env.UVM_HOME + '/src +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/hdl +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/hdl +incdir+/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/ /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/XlAxiSlaveTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlFlexMemTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlRngTransactor.sv +define+XL_AXI_MONITOR_VERBOSE +define+XL_FLEX_SLAVE_XACTOR +define+ARTERIS_TBX +define+MIN_READ_RESPONSE_LATENCY=2 -l vlog_hdl.log' || true );
  proc.execSync('vmap work work');     
  proc.execSync('vellib dutwork');     
  proc.execSync('velmap work dutwork');
  proc.execSync(' velanalyze -sv -hdl verilog -work dutwork -f ' + args.cfg_dir + '/rtl/flist.f ');
  proc.execSync( ' velanalyze -extract_hvl_info +incdir+/engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/uvm_pkg.sv ') ;
console.log("UVM PKG compiled Successful")  ;     
proc.execSync(' velanalyze -sv -work work   -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/hdl/vtl_chi_rn.f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/shared/axi_enum_pkg.sv -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/ace_master.f  /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/install/axi_v2/axi_v2/hdl/vtl_axi_clk_advancer.sv  -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_slave.f +define+VELOCE_HDL_COMPILE -f' + args.rtl_dir + '/flist.f -extract_hvl_info' + args.cfg_dir + '/dv/ioaiu0_smi_agent_pkg.sv +incdir+' + process.env.UVM_HOME + '/src ' + args.cfg_dir + '/dv/ioaiu0_smi_agent_pkg.sv ' + args.cfg_dir + '/dv/ioaiu_smi_pkg.sv  -f ' + process.env.WORK_TOP + '/dv/full_sys/myhdl_emu.flist /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/shared/axi_enum_pkg.sv -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/acelite_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_master.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl/axi4_slave.f -f /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/hdl/common_hdl.f +define+STUB_OUT +define+XL_AXI_MONITOR_VERBOSE +define+CARBON +define+VELOCE_RUN /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/AxiMonitor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/axislave_sm_indicator_if.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/vsms5505.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/vsmu5505.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0/hdl/XlAxiSlaveTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlMemoryTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlSparseMemoryTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlFlexMemTransactor.sv /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/XlRngTransactor.sv +incdir+' + process.env.UVM_HOME + '/src +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/hdl +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/hdl +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/hdl +define+XL_AXI_MONITOR_VERBOSE +define+XL_FLEX_SLAVE_XACTOR +define+ARTERIS_TBX +define+MIN_READ_RESPONSE_LATENCY=2' || true ) ;

       console.log (" *************************** VELCOMP_STARTS *********************** ") ;
       proc.execSync ('velcomp  -top ncore_hdl_top' || true) ;
       console.log (" *************************** VELCOMP_DONE *********************** ") ;
    }
  
} 



   if(args.cli.environment == "emu"){
   //  var Hvl_comp_cmd = 'velhvl -g -sim puresim -ldflags  -Wl,--whole-archive \"/engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/common/lib/linux64_el30_gnu53/libcommontbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/chi_v2/lib/linux64_el30_gnu53/libchi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v20.2/common/lib/linux64_el30_gnu53/libcommontbx.a\" -Wl,--no-whole-archive -cppinstall 5.3.0 -ldflags \"/engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit_extras.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip_open_kit_stubs.so /engr/dev/tools/mentor/VeloceVirtuaLAB_v20.2/VirtuaLAB_v20.2/common/virtualab-open_kit_v20.0.2a/xl_vip-questa2019.4/lib/linux64_el30_gnu53/xl_vip.so\" ' ;

    comp_cmd += ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/common/sysvlog ' + process.env.VELOCE_XACTOR_HOME + '/common/sysvlog/TBXSemaphores.sv ';
    //comp_cmd += '/scratch/dhalani/work_copy_of_09march21/hw-ncr/debug/emu/hw_cfg_42/dv/concerto_tb_top.sv +define+VTL_DEBUG +define+CHI_CACHE +define+VELOCE_RUN ' ;
    //comp_cmd +=  ' +define+XL_FLEX_SLAVE_XACTOR +define+XL_AXI_MONITOR_VERBOSE +define+MIN_READ_RESPONSE_LATENCY=2' ;
    comp_cmd += '+incdir+' + process.env.VELOCE_XACTOR_HOME + '/common/hdl ';
    comp_cmd += '-f ' + process.env.VELOCE_XACTOR_HOME + '/common/hdl/common_hdl.f ';
    comp_cmd +=  ' +define+XL_FLEX_SLAVE_XACTOR +define+XL_AXI_MONITOR_VERBOSE +define+MIN_READ_RESPONSE_LATENCY=2' ;
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/common/hdl/syn_fifo.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/common/hdl/ClockAdvancer.sv ';
   //Added for emulation veloce_hvl_comp_cmd::

    veloce_hvl_comp_cmd += ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog ' ;
    veloce_hvl_comp_cmd += ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/axi_v2/sysvlog ' ;
    veloce_hvl_comp_cmd +=  process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog/mgc_chi_txn_id_update_callback.sv ' ;
    //veloce_hvl_comp_cmd +=  process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog/mgc_chi_link_pkg.sv ' ;
    //veloce_hvl_comp_cmd +=  process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog/mgc_chi_rn_if.sv ' ;
    veloce_hvl_comp_cmd +=  process.env.VELOCE_XACTOR_HOME + '/axi_v2/sysvlog/mgc_axi_pkg.sv ' ;
    veloce_hvl_comp_cmd += ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/common/sysvlog ' + process.env.VELOCE_XACTOR_HOME + '/common/sysvlog/TBXSemaphores.sv ';
    veloce_hvl_comp_cmd += ' +define+VTL_DEBUG +define+CHI_CACHE  ' ;
    //veloce_hvl_comp_cmd += ' +define+STUB_OUT	+define+XL_AXI_MONITOR_VERBOSE ' ;

   

    comp_cmd +=   ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog ' ;
    comp_cmd +=   '+incdir+' + process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_counter.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_flit_txfr.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_link_layer_tx.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_flit_rcv.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_link_layer_rx.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_link_layer_top.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/ComodelFifoBase_CHI.sv  ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_ConcurrentFifoBase.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_prefetch_sync_fifo.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_protocol_layer.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_layered_top.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_interface_parity.sv ';
    comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/hdl/vtl_chi_rn.sv ';

comp_cmd +=   '+incdir+' + process.env.VELOCE_XACTOR_HOME + '/axi_v2/sysvlog ';
    comp_cmd +=    process.env.VELOCE_XACTOR_HOME + '/axi_v2/sysvlog/shared/axi_enum_pkg.sv ';
    comp_cmd +=    process.env.VELOCE_XACTOR_HOME + '/install/axi_v2/axi_v2/hdl/vtl_axi_clk_advancer.sv ';

 
    comp_cmd +=   '+incdir+' + process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl '               ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_master_module.sv ' ;     
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_acelite_master_module.sv ';
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_master_module.sv ';
    //comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/axi_v2_exportdefs.sv '    ; 
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/ComodelFifoBase_AMBA.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/axi_v2_ConcurrentFifoBase.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_glob_timer.sv '       ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_ack_schedular.sv '     ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi_valid_to_ready_timeout.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_snoop_data_schedular.sv '   ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_snoop_master.sv '    ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_snoop_resp_schedular.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_ace_snoop_timeout_controller.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_wr_addr_scheduler.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_wr_data_scheduler.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_rd_addr_scheduler.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_rd_rsp_handler.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi_wr_rsp_handler.sv '  ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_rd_timeout_controller.sv ' ;
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi4_wr_order_and_timeout_controller.sv '  ;   
    comp_cmd +=       process.env.VELOCE_XACTOR_HOME + '/axi_v2/hdl/vtl_axi_xrtl_master.sv ' ;

   //also Added for veloce 


    comp_cmd +=  '+incdir+' + process.env.XL_VIP_HOME + '/lib ';
    comp_cmd += process.env.AXI_SLAVE_RELS  + '/hdl/AxiMonitor.sv ' ;
    comp_cmd += process.env.AXI_SLAVE_RELS  + '/hdl/axislave_sm_indicator_if.sv ' ;
    comp_cmd += process.env.AXI_SLAVE_RELS  + '/hdl/vsms5505.sv ' ;
    comp_cmd += process.env.AXI_SLAVE_RELS  + '/hdl/vsmu5505.sv ' ;
    comp_cmd += process.env.AXI_SLAVE_RELS  + '/hdl/XlAxiSlaveTransactor.sv ' ;
    comp_cmd +=   process.env.XL_VIP_HOME + '/lib/XlFlexMemTransactor.sv ';
    comp_cmd += process.env.XL_VIP_HOME  + '/lib/XlRngTransactor.sv ' ;

    comp_cmd += ' +incdir+' + process.env.VELOCE_XACTOR_HOME + '/common/sysvlog ';
    comp_cmd += process.env.VELOCE_XACTOR_HOME + '/common/sysvlog/TBXSemaphores.sv ';
    comp_cmd += '+define+VTL_DEBUG +define+CHI_CACHE ';
    //comp_cmd +=   process.env.VELOCE_XACTOR_HOME + '/chi_v2/sysvlog/mgc_chi_txn_id_update_callback.sv ';
   
     //var comp_cmd = 'vlog -sv -mfcu -64 -timescale=1ps/1ps';  
     }

    comp_cmd += ' +incdir+' + process.env.UVM_HOME + '/src ' + process.env.UVM_HOME + '/src/uvm.sv';
    comp_cmd += ' +define+QUESTA +define+SVT_UVM_TECHNOLOGY ';
    comp_cmd += process.env.UVM_HOME + '/src/dpi/uvm_dpi.cc';
//    comp_cmd += ' -printinfilenames -writetoplevels toplevels.f -stats=perf,verbose -warning 2367 -suppress 13185 -svext=ias,idcl,iddp '
    comp_cmd += ' -printinfilenames -writetoplevels toplevels.f -suppress 2620'
    var default_compile_args = ' -stats=perf,verbose -warning 2367 -suppress 13185,2620 -svext=ias,idcl,iddp';
   veloce_hvl_comp_cmd += ' +incdir+' + process.env.UVM_HOME + '/src ' + process.env.UVM_HOME + '/src/uvm.sv';
   veloce_hvl_comp_cmd += ' +define+QUESTA +define+SVT_UVM_TECHNOLOGY ';
   veloce_hvl_comp_cmd += process.env.UVM_HOME + '/src/dpi/uvm_dpi.cc';
 //veloce_hvl_comp_cmd += ' -printinfilenames -writetoplevels toplevels.f -stats=perf,verbose -warning 2367 -suppress 13185 -svext=ias,idcl,iddp '
 //veloce_hvl_comp_cmd += ' -printinfilenames -writetoplevels toplevels.f'
   var default_compile_args = ' -stats=perf,verbose -warning 2367 -suppress 13185,2620 -svext=ias,idcl,iddp ';
    if (cli.compile_time_args) {
	var option_args = cli.compile_time_args.replace(/^!/,"");
	if(!cli.compile_time_args.match(/^!/))
	    comp_cmd += default_compile_args;
	    veloce_hvl_comp_cmd += default_compile_args;
	comp_cmd += ' ' + option_args;
    } else {
	comp_cmd += default_compile_args;
	veloce_hvl_comp_cmd += default_compile_args;
        console.log(veloce_hvl_comp_cmd);
    }
    comp_cmd += ' ';
    comp_cmd += '+define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING ';
    comp_cmd += '+define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE ';
    comp_cmd += '+libext+.v+.vlib -y /engr/dev/tools/ovl/std_ovl +incdir+/engr/dev/tools/ovl/std_ovl ';
    veloce_hvl_comp_cmd += ' ';
    veloce_hvl_comp_cmd += '+define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING ';
    veloce_hvl_comp_cmd += '+define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE ';
    veloce_hvl_comp_cmd += '+libext+.v+.vlib -y /engr/dev/tools/ovl/std_ovl +incdir+/engr/dev/tools/ovl/std_ovl ';
    if (args.cli.includeSnpsMemory) { //need to remove the internal mem dir
//	comp_cmd += ' -y ' + cli.tcl_cfg + '/../memories ';
	veloce_hvl_comp_cmd += ' -y ' + cli.tcl_cfg + '/../memories ';
    }
    //   if(!cli.noPermissive) comp_cmd += ' -permissive ';
    if (!cliDefineExists(args, 'OVL_ASSERT_OFF'))
	comp_cmd += '+define+ARTERIS_TBX ';
	//comp_cmd += '+define+OVL_ASSERT_ON ';
    comp_cmd += usr_defines(args);
    comp_cmd += '-f ../dv/vcs.flist -l compile.log -suppress 2620';
	veloce_hvl_comp_cmd += '+define+ARTERIS_TBX ';
	//veloce_hvl_comp_cmd += '+define+OVL_ASSERT_ON ';
        veloce_hvl_comp_cmd += usr_defines(args);
        veloce_hvl_comp_cmd += ' -f ' + process.env.WORK_TOP + '/dv/full_sys/vc1.flist -l compile.log ';
        console.log(veloce_hvl_comp_cmd) ;
    var coverage_code = (cli.codeCoverage) ? '+cover ' : '';
    var cmd_args = comp_cmd.split(' ');
    var veloce_hvl_comp_cmd_args = veloce_hvl_comp_cmd.split(' ');
    var xprop_glitch_free_assert = '';
    testFunc('runVeloceCompile', { "comp_cmd": comp_cmd }, testObj, function () {

	if (cli.xprop) {
                xprop_options = xprop_args(args);
                xprop_glitch_free_assert = ' -xprop_enable=glitchfreeassert ';
                if(xprop_options.xprop_glitch_free_assert == 0) {
                       xprop_glitch_free_assert = '';
                }
	}

	if (cli.xprop) {
	    //var vopt_cmd = coverage_code + '-xprop,mode=' + xprop_options.xprop_mode + ',object=' + args.xprop_unitPath + ' -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp -l mti_vopt.log +designfile';
	    var vopt_cmd = coverage_code + '-xprop,mode=' + xprop_options.xprop_mode + ',report=error,object=/tb_top/dut.' + xprop_glitch_free_assert + ' -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185,8688,2620,13412 -svext=ias,idcl,iddp -l mti_vopt.log +designfile';
	    //anippuleti 06/2/2017
	    //Adding switch to disable optimization due to bug in Questa10.6, swtich provided by Suman
	    //Please remove below logic once the issue in the tool is fixed.
	    //vopt_cmd = vopt_cmd + ' +acc=r +noacc+tb_top.';
	    //    var vopt_cmd = 'vopt -inlineFactor=1024 -64 -f toplevels.f -o top_opt -stats=perf,verbose -svext=ias,idcl,iddp -permissive -l mti_vopt.log +designfile';
	} else {
//	    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp -l mti_vopt.log +designfile +acc=r +noacc+tb_top.'
        console.log("=============================VOPT_COMMAND==================================") ;
if (cli.compile_time_args) {
    if(cli.compile_time_args.match("veloce")) {
    //for emulation
    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -access=r+/. -fprofile -allowwriteaccess -j 4 -debug -f toplevels.f -o top_opt -l mti_vopt.log -stats=perf,verbose,all +designfile'
    //    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 0 -stats=+elab,perf+child+verbose -noincr  -wprof=harsha.pdb -debug -f toplevels.f -o top_opt -opt=tphases -svext=ias,idcl,iddp -l mti_vopt.log +designfile +acc=r +noacc+tb_top.'
}
}
//opt_cmd for simulation and fsys 
             var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4  TbxSvManager -debug -f toplevels.f  -o top_opt -l mti_vopt.log +designfile'   //    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 0 -stats=+elab,perf+child+verbose -noincr  -wprof=harsha.pdb -debug -f toplevels.f -o top_opt -opt=tphases -svext=ias,idcl,iddp -l mti_vopt.log +designfile +acc=r +noacc+tb_top.'
	}

	//    	if(!cli.noPermissive) vopt_cmd += ' -permissive ';

	var default_vopt_options = ' -stats=perf,verbose -suppress 13185,8688,2620,13412 -svext=ias,idcl,iddp'

	if (cli.optimize_time_options) {
	    var options_args = cli.optimize_time_options.replace(/^!/,"");
	    console.log("DCDEBUG optimize_time_options " + !cli.optimize_time_options.match(/^!/));
	    if(!cli.optimize_time_options.match(/^!/)) {
		vopt_cmd += default_vopt_options
	    }
	    vopt_cmd += ' ' + options_args;
	} else {
	    vopt_cmd += default_vopt_options
            if (cli.vcd) {
		vopt_cmd += ' +acc=npr+' + cli.vcd + '.';
            } else {
		//vopt_cmd += ' +acc=r +noacc+tb_top.'
		        if(args.cli.environment == "dce" || args.cli.environment == "dve") {
                    vopt_cmd += ' +acc=p+/tb_top/dut';
	               }
	    }
	}
	var node_cmd = '';
	process.argv.forEach(function (val, index, array) {
	    node_cmd += val + ' ';
	});


	if (args.cli.maestro_build_num == undefined) {
/*	    try {
		// Try new method first. This will work under new Maestro-Test pipeline
		var maestro_build_num = require(`${process.env.REPO_PATH}/../manifest.json`).maestroClient.build_id;
	    } catch (e) {
		// If try failed, we must be running under the old maestro_test pipeline. Fall back to the old method
		var maestro_build_num = proc.execSync('cat $REPO_PATH/manifest.json | grep \\"build_tag | egrep -o "[[:digit:]]*" ');
	    } 
	    node_cmd += ' -B ' + maestro_build_num; */
	}
	fs.writeFileSync(rsim_ds.exe_dir + '/node_compile', node_cmd, 'utf8');
        if (cli.compile_time_args) {
	    if(cli.compile_time_args.match("veloce")) {
	          //fs.writeFileSync(rsim_ds.exe_dir + '/vel_hvl_compile_env', veloce_hvl_comp_cmd + ' && vopt ' + vopt_cmd);
	          fs.writeFileSync(rsim_ds.exe_dir + '/vel_hvl_compile_env', veloce_hvl_comp_cmd + ' && vopt ' + vopt_veloce_cmd);
                  fs.writeFileSync(rsim_ds.exe_dir + '/compile_env', comp_cmd + ' && vopt ' + vopt_cmd);
             } else {
                  fs.writeFileSync(rsim_ds.exe_dir + '/compile_env', comp_cmd + ' && vopt ' + vopt_cmd);
             }
         } else {
                  fs.writeFileSync(rsim_ds.exe_dir + '/compile_env', comp_cmd + ' && vopt ' + vopt_cmd);
         }
if (cli.compile_time_args) {
    if(cli.compile_time_args.match("veloce")) {
    fs.chmodSync(rsim_ds.exe_dir + '/vel_hvl_compile_env', "0777");
}
}
	fs.chmodSync(rsim_ds.exe_dir + '/node_compile', "0777");
	fs.chmodSync(rsim_ds.exe_dir + '/compile_env', "0777");
	cmd_args.shift();
	//DCTODO Take this out when TACHL is fixed
	//	if(((args.cli.environment == 'llc') || (args.cli.environment == 'llc_tachl'))&& (args.rtlPkg !== undefined)) {
//	if (args.rtlPkg !== undefined || args.cli.tcl_input !== undefined || (args.cli.tcl_cfg !== undefined))
//	    editFlist(args, testObj);

 if (cli.compile_time_args) {
	if(cli.compile_time_args.match("veloce")) {
	   //var pwd = proc.spawn('vlog', veloce_hvl_comp_cmd_args, { stdio: "inherit" });
	} else {
			console.log (" *************************** VOPT_1 *********************** ") ;
            var pwd = proc.spawn('vlog', cmd_args, { stdio: "inherit" });
        }
} else {
	   console.log (" *************************** VOPT_2 *********************** ") ;
	   var pwd = proc.spawn('vlog', cmd_args, { stdio: "inherit" });
}



if (cli.compile_time_args) {
	if(cli.compile_time_args.match("veloce")) {
console.log (" *************************** VLOG_START Emulation *********************** ") ;
     proc.execSync ('vlog -sv -mfcu -64 -timescale=1ps/1ps -work work +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog  +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/mgc_chi_txn_id_update_callback.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/master/axi_master_if.sv +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/sysvlog /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/sysvlog/TBXSemaphores.sv  +define+VTL_DEBUG +define+CHI_CACHE   +incdir+/engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/uvm.sv +define+QUESTA +define+SVT_UVM_TECHNOLOGY /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/dpi/uvm_dpi.cc -stats=perf,verbose -warning 2367 -suppress 13185,2620 -svext=ias,idcl,iddp  +define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE +libext+.v+.vlib -y /engr/dev/tools/ovl/std_ovl +incdir+/engr/dev/tools/ovl/std_ovl +define+STUB_OUT +define+XL_AXI_MONITOR_VERBOSE +define+OVL_ASSERT_ON +define+DUMP_ON +define+ASSERT_OFF +define+TT_DEBUG +define+INHOUSE_APB_VIP +define+DATA_ADEPT +define+COVER_ON +define+ARTERIS_TBX -tbxhvllint  -f ' + process.env.WORK_TOP + '/dv/full_sys/myhvl_emu.flist -l compile.log ' || true);
console.log (" *************************** VLOG_DONE Emulation *********************** ") ;
        }
    }else{
console.log (" *************************** VLOG_START Simulation *********************** ") ;
   proc.execSync ('vlog -sv -mfcu -64 -timescale=1ps/1ps -work work +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog  +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/mgc_chi_txn_id_update_callback.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/mgc_axi_pkg.sv /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/sysvlog/master/axi_master_if.sv +incdir+/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/sysvlog /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/sysvlog/TBXSemaphores.sv  +define+VTL_DEBUG +define+CHI_CACHE   +incdir+/engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/uvm.sv +define+QUESTA +define+SVT_UVM_TECHNOLOGY /engr/dev/tools/mentor/questa-2019.4/questasim/verilog_src/uvm-1.1d/src/dpi/uvm_dpi.cc -stats=perf,verbose -warning 2367 -suppress 13185,2620 -svext=ias,idcl,iddp  +define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING +define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE +libext+.v+.vlib -y /engr/dev/tools/ovl/std_ovl +incdir+/engr/dev/tools/ovl/std_ovl +define+STUB_OUT +define+XL_AXI_MONITOR_VERBOSE +define+DUMP_ON +define+ASSERT_OFF +define+TT_DEBUG +define+INHOUSE_APB_VIP +define+DATA_ADEPT +define+COVER_ON -tbxhvllint  -f ' + process.env.WORK_TOP + '/dv/full_sys/myhvl_emu.flist -l compile.log ' || true);
console.log (" *************************** VLOG_DONE Simulation *********************** ") ;
        }
   
 if (cli.compile_time_args) {
	if(cli.compile_time_args.match("veloce")) {
	              proc.execSync ('velhvl -g -sim veloce -ldflags "-Wl,--whole-archive /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/axi_v2/lib/linux64_el30_gnu53/libaxi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/lib/linux64_el30_gnu53/libchi_v2tbx.a /engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/common/lib/linux64_el30_gnu53/libcommontbx.a -Wl,--no-whole-archive" -cppinstall 7.4.0 -ldflags "/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit_extras.so /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit.so /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip_open_kit_stubs.so /engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1/lib/linux64_el30_gnu74/xl_vip.so" ' || true);
   

console.log (" *************************** VELHVL_DONE_veloce *********************** ") ;
        }
 }


 if (cli.compile_time_args) {
	if(cli.compile_time_args.match("veloce")) {
console.log('===============VELHVL SUCCESSFUL before===============');
	    var vopt_veloce_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4  TbxSvManager -debug ncore_hdl_top tb_top  -o top_opt -l mti_vopt.log +designfile' ;
	    vopt_veloce_cmd += ' +acc=r +noacc+tb_top.' ;
	    default_vopt_options = ' -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp' ;
console.log('===============VELHVL SUCCESSFUL===============');
}
}
else{
var vopt_veloce_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4  TbxSvManager -debug ncore_hdl_top tb_top  -o top_opt -l mti_vopt.log +designfile' ;
	    vopt_veloce_cmd += ' +acc=r +noacc+tb_top.' ;
	    default_vopt_options = ' -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp' ;

}
   if (cli.compile_time_args){
         if(cli.compile_time_args.match("veloce")) {

                              console.log('===============VELHVL SUCCESSFUL===============');
                              if (cli.compile_time_args) {
	                          if(cli.compile_time_args.match("veloce")) {
                                      var vopt_veloce_args = vopt_veloce_cmd.split(' ');
		                      var vlogPwd = proc.spawn('vopt', vopt_veloce_args, { stdio: "inherit" });
                                  } else {
				      var vopt_args = vopt_cmd.split(' ');
		                      var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });
	                          }
                              } else {
				      var vopt_args = vopt_cmd.split(' ');
		                      var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });

                              }
		                vlogPwd.on('close', function (err) {
	                           if (err) {
		                       throw new Error("ERROR! Something went wrong with Questa Elaboration_12! Please run " + rsim_ds.exe_dir + "/compile_env to reproduce this error");
	                           } else {
			                   console.log('===============COMPILE SUCCESSFUL===============');
			                   if (args.rtlPkg === undefined)
			                       console.log('===============RTLGEN SUCCESSFUL===============');
			                   proc.execSync('sleep 1s');
			                   callback(args, testObj);
	                   }
	                 });
						 console.log('===============Locking Veloce Compile===============');
						 push_dir(rsim_ds.exe_dir);
                         proc.execSync ('velcomp -lock_project')


 				      
                              }else {
	                          pwd.on('close', function (err) {
	    if (err) {
		throw new Error("ERROR! Something went wrong with Questa Compile! Please run " + rsim_ds.exe_dir + "/compile_env to reproduce this error");
	    } else {
            console.log('===============VELHVL SUCCESSFUL===============');
                              if (cli.compile_time_args) {
	                          if(cli.compile_time_args.match("veloce")) {
                                      var vopt_veloce_args = vopt_veloce_cmd.split(' ');
		                      var vlogPwd = proc.spawn('vopt', vopt_veloce_args, { stdio: "inherit" });
                                  } else {
		var vopt_args = vopt_cmd.split(' ');
		var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });
	                          }
                              } else {
				      var vopt_args = vopt_cmd.split(' ');
                                    var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });

                              }
		                vlogPwd.on('close', function (err) {
	                           if (err) { 
                                      throw new Error("ERROR! Something went wrong with Questa Elaboration! Please run " + rsim_ds.exe_dir + "/compile_env to reproduce this error");
                		  } else {
                			console.log('===============COMPILE SUCCESSFUL===============');
                			if (args.rtlPkg === undefined)
                			    console.log('===============RTLGEN SUCCESSFUL===============');
                			proc.execSync('sleep 1s');
                			callback(args, testObj);
                	    }
                	});
                    }
          });

}    // veloce else part

}
 else {
                              console.log('===============VELHVL SUCCESSFUL DEFAULT===============');
                               var vopt_args = vopt_cmd.split(' ');
 		                      console.log('=============compile_args else part=================');
                                      var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });
                                      console.log(vlogPwd);
 		                      console.log('=============compile_args part after else=================');
		                vlogPwd.on('close', function (err) {
	                           if (err) {
		                       throw new Error("ERROR! Something went wrong with Questa Elaboration! Please run_11" + rsim_ds.exe_dir + "/compile_env to reproduce this error");
	                           } else {
			                   console.log('===============COMPILE SUCCESSFUL===============');
			                   if (args.rtlPkg === undefined)
			                       console.log('===============RTLGEN SUCCESSFUL===============');
			                   proc.execSync('sleep 1s');
			                   callback(args, testObj);
	                   }
	                 });
	       }       // compile_args else part
   
    });
}



function runMentorCompile(args,callback,testObj) {
    var cli = args.cli;
    var rsim_ds = args;
    var assertFiles = fs.readdirSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
    var assertFlist = ""
    var xprop_options = {};
    /*
    for(var i = 0; i < assertFiles.length; i++) {
	if(fs.lstatSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/' + assertFiles[i]).isFile()) {
	    proc.execSync('cp ' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/' + assertFiles[i] + ' ' + args.cfg_dir + '/dv');
	}
    }  */
    var filesVc = fs.readFileSync(process.env.WORK_TOP + '/dv/common/chi_arm_sva/files.vc','utf8').split('\n');
    filesVc.forEach(function(line) {
//	var newLine = line.replace(/^\.\//,args.cfg_dir + '/dv/');
	var newLine = line.replace(/^\.\//,process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
	newLine = newLine.replace(/^\+incdir\+./,'+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/');
	assertFlist += newLine + '\n';
    });
    if(args.cli.environment == "fsys" || args.cli.environment == "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || args.cli.environment == "ioaiu_subsys" || args.cli.environment == "emu") {
	//proc.execSync('cp ' + args.exe_dir + '/concerto_register_map.sv ' + args.dv_dir);
    } else {
	var ralgenUnits = getRalgenUnits(args);
	ralgenUnits.forEach(function(unitObj) {
	    if((args.cli.instanceName) ? (unitObj.name == args.cli.instanceName) : 1) {
		proc.execSync('cp ' + args.exe_dir + '/' + unitObj.name + '_concerto_register_map.sv ' + args.dv_dir);
	    }
	});
    }

//	    proc.execSync('cp ' + args.exe_dir + '/concerto_register_map.sv ' + args.dv_dir);

    var verFiles = fs.readdirSync(process.env.WORK_TOP + '/node_modules/@arteris/hw-lib/verilog/');
    var verFlist = "";
/*
    for(var i = 0; i < verFiles.length; i++) {
	verFlist += args.rtl_dir + '/' + verFiles[i] + '\n'
	proc.execSync('cp ' + process.env.WORK_TOP + '/../hw-lib/verilog/' + verFiles[i] + ' ' + args.cfg_dir + '/rtl');	
    }
*/
    if(args.rtl_json)
	fs.writeFileSync(args.cfg_dir + '/rtl/verFiles.flist', verFlist,'utf-8'); 

//    var newFlist = '-f ../rtl/verFiles.flist\n-f ../dv/files.vc\n' + fs.readFileSync(args.cfg_dir + '/dv/vcs.flist');
    newFlist += '+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva\n';
//    newFlist += '-f ' + process.env.WORK_TOP + '/dv/common/chi_arm_sva/files.vc\n';

    var lines = fs.readFileSync(args.cfg_dir + '/dv/vcs.flist','utf-8').split('\n');
    var insertedFlist = 0;
    if(args.rtl_json)
	var newFlist = '-f ../rtl/verFiles.flist\n';
    else
	var newFlist = '';
    for(var i = 0;i < lines.length;i++) {
	if(lines[i].match(args.cfg_dir) && !lines[i].match(/^\-f/) && !lines[i].match(/\+incdir\+/) && !insertedFlist && cliDefineExists(args,"CHI_ARM_ASSERT_ON")) {
	    fs.writeFileSync(args.cfg_dir + '/dv/files.vc', assertFlist,'utf-8');
	    newFlist += '+incdir+' + process.env.WORK_TOP + '/dv/common/chi_arm_sva\n';
	    newFlis += '-f ../dv/files.vc\n';
	    insertedFlist = 1;
	}
	if(!(lines[i].match(/flist.f/) && args.rtlPkg == undefined)) {
	    newFlist += lines[i] + '\n';
	}
    }

    fs.writeFileSync(args.cfg_dir + '/dv/vcs.flist',newFlist,'utf-8');
//    defaultRsim.runMentorCompile(args,callback,testObj);
    //    setEnv('/engr/dev/tools/script/mentor-eng.sh');
    console.log('setEnvMentor reached');
    args.setEnvMentor();

    genExeDirs(args, callback, testObj);
    push_dir(rsim_ds.exe_dir);
    if (fs.existsSync(rsim_ds.exe_dir + '/build_rtl')) {
	proc.execSync('rm -rf ' + rsim_ds.exe_dir + '/build_rtl');
    }
    console.log('UVM_HOME ' + process.env['UVM_HOME']);
    proc.execSync('vlib -compress work');
    var comp_cmd = 'vlog -sv -mfcu -64 -timescale=1ps/1ps -suppress 2620';
    comp_cmd += ' +incdir+' + process.env.UVM_HOME + '/src ' + process.env.UVM_HOME + '/src/uvm.sv';
    comp_cmd += ' +define+QUESTA +define+SVT_UVM_TECHNOLOGY ';
    comp_cmd += process.env.UVM_HOME + '/src/dpi/uvm_dpi.cc';
//    comp_cmd += ' -printinfilenames -writetoplevels toplevels.f -stats=perf,verbose -warning 2367 -suppress 13185 -svext=ias,idcl,iddp '
    comp_cmd += ' -printinfilenames -writetoplevels toplevels.f'
    var default_compile_args = ' -stats=perf,verbose -warning 2367 -suppress 13185,2620 -svext=ias,idcl,iddp ';
    if (cli.compile_time_args) {
	var option_args = cli.compile_time_args.replace(/^!/,"");
	if(!cli.compile_time_args.match(/^!/))
	    comp_cmd += default_compile_args;
	comp_cmd += ' ' + option_args;
    } else {
	comp_cmd += default_compile_args;
    }
    comp_cmd += ' ';
    comp_cmd += '+define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING ';
    comp_cmd += '+define+UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE ';
    comp_cmd += '+libext+.v+.vlib -y /engr/dev/tools/ovl/std_ovl +incdir+/engr/dev/tools/ovl/std_ovl ';
    if (args.cli.includeSnpsMemory) { //need to remove the internal mem dir
	comp_cmd += ' -y ' + cli.tcl_cfg + '/../memories ';
    }
    //   if(!cli.noPermissive) comp_cmd += ' -permissive ';
    if (!cliDefineExists(args, 'OVL_ASSERT_OFF'))
	comp_cmd += '+define+OVL_ASSERT_ON ';
    comp_cmd += usr_defines(args);
    comp_cmd += '-f ../dv/vcs.flist -l compile.log';
    var coverage_code = (cli.codeCoverage) ? '+cover ' : '';
    var cmd_args = comp_cmd.split(' ');
    var xprop_glitch_free_assert = '';
    testFunc('runMentorCompile', { "comp_cmd": comp_cmd }, testObj, function () {

	if (cli.xprop) {
                xprop_options = xprop_args(args);
                xprop_glitch_free_assert = ' -xprop_enable=glitchfreeassert ';
                if(xprop_options.xprop_glitch_free_assert == 0) {
                       xprop_glitch_free_assert = '';
                }
	}

	if (cli.xprop) {
	    //var vopt_cmd = coverage_code + '-xprop,mode=' + xprop_options.xprop_mode + ',object=' + args.xprop_unitPath + ' -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp -l mti_vopt.log +designfile';
	    var vopt_cmd = coverage_code + '-xprop,mode=' + xprop_options.xprop_mode + ',report=error,object=/tb_top/dut.' + xprop_glitch_free_assert + ' -inlineFactor=1024 -64 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185,8688,2620,13412 -svext=ias,idcl,iddp -l mti_vopt.log +designfile';
	    //anippuleti 06/2/2017
	    //Adding switch to disable optimization due to bug in Questa10.6, swtich provided by Suman
	    //Please remove below logic once the issue in the tool is fixed.
	    //vopt_cmd = vopt_cmd + ' +acc=r +noacc+tb_top.';
	    //    var vopt_cmd = 'vopt -inlineFactor=1024 -64 -f toplevels.f -o top_opt -stats=perf,verbose -svext=ias,idcl,iddp -permissive -l mti_vopt.log +designfile';
	} else {
//	    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4 -debug -f toplevels.f -o top_opt -stats=perf,verbose -suppress 13185 -svext=ias,idcl,iddp -l mti_vopt.log +designfile +acc=r +noacc+tb_top.'
	    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 4 -debug -f toplevels.f -o top_opt -l mti_vopt.log +designfile'
	    //    var vopt_cmd = coverage_code + '-inlineFactor=1024 -64 -j 0 -stats=+elab,perf+child+verbose -noincr  -wprof=harsha.pdb -debug -f toplevels.f -o top_opt -opt=tphases -svext=ias,idcl,iddp -l mti_vopt.log +designfile +acc=r +noacc+tb_top.'
	}

	//    	if(!cli.noPermissive) vopt_cmd += ' -permissive ';

	var default_vopt_options = ' -stats=perf,verbose -suppress 13185,8688,2620,13412 -svext=ias,idcl,iddp'

	if (cli.optimize_time_options) {
	    var options_args = cli.optimize_time_options.replace(/^!/,"").replace(/\\-coveropt/,"-coveropt");
	    console.log("DCDEBUG optimize_time_options " + !cli.optimize_time_options.match(/^!/));
	    if(!cli.optimize_time_options.match(/^!/)) {
		vopt_cmd += default_vopt_options
	    }
	    vopt_cmd += ' ' + options_args;
	} else {
	    vopt_cmd += default_vopt_options
            if (cli.vcd) {
		vopt_cmd += ' +acc=npr+' + cli.vcd + '.';
            } else {
		//vopt_cmd += ' +acc=r +noacc+tb_top.'
		         if(args.cli.environment == "dce" || args.cli.environment == "dve") {
                    vopt_cmd += ' +acc=p+/tb_top/dut';
	               }
	    }
	}
	var node_cmd = '';
	process.argv.forEach(function (val, index, array) {
	    node_cmd += val + ' ';
	});


	if (args.cli.maestro_build_num == undefined) {
/*	    try {
		// Try new method first. This will work under new Maestro-Test pipeline
		var maestro_build_num = require(`${process.env.REPO_PATH}/../manifest.json`).maestroClient.build_id;
	    } catch (e) {
		// If try failed, we must be running under the old maestro_test pipeline. Fall back to the old method
		var maestro_build_num = proc.execSync('cat $REPO_PATH/manifest.json | grep \\"build_tag | egrep -o "[[:digit:]]*" ');
	    } 
	    node_cmd += ' -B ' + maestro_build_num; */
	}
	fs.writeFileSync(rsim_ds.exe_dir + '/node_compile', node_cmd, 'utf8');
	fs.writeFileSync(rsim_ds.exe_dir + '/compile_env', comp_cmd + ' && vopt ' + vopt_cmd);
	fs.chmodSync(rsim_ds.exe_dir + '/node_compile', "0777");
	fs.chmodSync(rsim_ds.exe_dir + '/compile_env', "0777");
	cmd_args.shift();
	//DCTODO Take this out when TACHL is fixed
	//	if(((args.cli.environment == 'llc') || (args.cli.environment == 'llc_tachl'))&& (args.rtlPkg !== undefined)) {
//	if (args.rtlPkg !== undefined || args.cli.tcl_input !== undefined || (args.cli.tcl_cfg !== undefined))
//	    editFlist(args, testObj);

	var pwd = proc.spawn('vlog', cmd_args, { stdio: "inherit" });
	pwd.on('close', function (err) {
	    if (err) {
		throw new Error("ERROR! Something went wrong with Questa Compile! Please run " + rsim_ds.exe_dir + "/compile_env to reproduce this error");
	    } else {

		var vopt_args = vopt_cmd.split(' ');
		//		vopt_args.shift();
		var vlogPwd = proc.spawn('vopt', vopt_args, { stdio: "inherit" });
		vlogPwd.on('close', function (err) {
		    if (err)
			throw new Error("ERROR! Something went wrong with Questa Elaboration! Please run " + rsim_ds.exe_dir + "/compile_env to reproduce this error");
		    else {
			console.log('===============COMPILE SUCCESSFUL===============');
			if (args.rtlPkg === undefined)
			    console.log('===============RTLGEN SUCCESSFUL===============');
			proc.execSync('sleep 1s');
			callback(args, testObj);
		    }
		});
	    }
	});
    });
}
function genRtlDirs(args, callback, testObj) {
	var cli = args.cli;
	var rsim_ds = args;
	var isTest = 1;
	testFunc('genRtlDirs', args, testObj, function () {
	    isTest = 0;

	    if (fs.existsSync(rsim_ds.rtl_dir) && (cli.skip_maestro == null))
		proc.execSync('rm -Rf ' + rsim_ds.rtl_dir);

	    if ( (cli.tcl_input || cli.tcl_cfg) && (cli.skip_maestro == null)){
		proc.execSync('ln -s ' + rsim_ds.exe_dir + '/output/rtl/design ' + rsim_ds.rtl_dir);
		proc.execSync('ln -s ' + rsim_ds.exe_dir + '/output/rtl/placeholders/*.* ' + rsim_ds.rtl_dir);

		if (args.cli.includeSnpsMemory) {
		    proc.execSync('ln -s ' + rsim_ds.exe_dir + '/output/rtl/models/memories/memories.flist ' + rsim_ds.rtl_dir);
		    proc.execSync('ln -s ' + cli.tcl_cfg + '/../memories/*.* ' + rsim_ds.rtl_dir);
		} else {
		    proc.execSync('ln -s ' + rsim_ds.exe_dir + '/output/rtl/models/memories/*.* ' + rsim_ds.rtl_dir);
		}
	    } else {
		if(cli.skip_maestro == null)
		    fs.mkdirSync(rsim_ds.rtl_dir);
	    }
	    callback(args, testObj);
	});
    if (isTest)
	callback(args, testObj);
}

function genDirs(args,callback,testObj) {
    defaultRsim.genDirs(args,function(){},testObj);
    //args.tachlCmd = '/engr/dev/releases/tachl/versions/tachl-v1.6.12/bin/tachl.js'
    args.newMentor = 1;
    if(args.pkgMap.env_name) {
	args.tbName          = args.cli.environment;
	args.cli.environment = args.pkgMap.env_name;
	args.env_name = args.pkgMap.env_name;
    } else {
	args.env_name = args.cli.environment;
    }

    var path = process.env["PATH"];
    if(!path.includes("tachl")){ args.tachlCmd = '/engr/dev/releases/tachl/versions/tachl-v1.6.18/bin/tachl.js';}
    if(!path.includes("questa")){
      args.setEnvMentor = function() {
	process.env["UVM_HOME"]         = "/engr/dev/tools/mentor/questa_10.7c_2/questasim/verilog_src/uvm-1.1d";
	process.env["PATH"]             = "/engr/dev/tools/mentor/questa_10.7c_2/questasim/linux_x86_64:/engr/dev/tools/mentor/visualizer_10.7c_1/visualizer/linux_x86_64:" + path;
	process.env["LM_LICENSE_FILE"]  = "1717@lic-node0"; 
      
       process.env["AXI_SLAVE_RELS"] = '/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/devices/SoftModelMemories/AMBA_AXI_SlaveSoftmodelMemory_5.0.0';
       process.env["XL_VIP_HOME"] =     '/engr/eda/tools/mentor/VeloceVirtuaLAB_v22.3/VirtuaLAB_v22.3/common/virtualab-open_kit_v22.0.3a/xl_vip-questa2022.1_1'; 
       process.env["VELOCE_XACTOR_HOME"] = '/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2';
    }
    }
    args.rtl_json = 0;
    if(args.cli.environment == "fsc")
	args.rtlType = "TACHL"
    if(args.cli.unitRtlParams)
	args.rtl_json = 1;
    if(args.cli.tcl_input) {
    }
    callback(args,testObj);
}

function runMaestro(args, callback, testObj) {
  var maestro_env;
  var maestro_build_tag; // = args.cli.maestro_build_tag; //proc.execSync('cat $REPO_PATH/manifest.json | grep maestro_build_tag | egrep -o "maestro_build_tag|[[:digit:]]*" | paste -sd: -');

  var tcl_library = (args.cli.tcl_lib === undefined) ? 'hw_config_02' : args.cli.tcl_lib;
//  console.log('DCDEBUG tcl_lib option ' + args.cli.tcl_lib + ' tcl_library ' + tcl_library);
  const WORK_TOP = process.env.WORK_TOP;

  // Start forming arguments for run_maestro. If env var, such as SW_UTL_PATH is 
  // defined, then repo is loaded from location pointed by this variable. 
  // Otherwise we take it from WORK_TOP/../<repo>
  // BW. Why is the default path to ncr is 'concerto' and not 'hw-ncr'? 
  let maestro_args;
  if (args.cli.int_json) {
     maestro_args = `-mco -i ` + args.cli.int_json;
  } else {
     maestro_args = `utd -ums true`;
  }

  if(args.cli.maestro_build || process.env.DONT_USE_HW_OVERRIDES) {
    maestro_args += ` -ndj -sdj -g `;  
  }else{
    maestro_args += ` -ndj -sdj -g \\
        -hws ${process.env.HW_SYM_PATH ? process.env.HW_SYM_PATH : process.env.MAESTRO_HW_PATH ? process.env.MAESTRO_HW_PATH + '/hw-sym' : WORK_TOP + '/../hw-sym'} \\
        -hwl ${process.env.HW_LIB_PATH ? process.env.HW_LIB_PATH : process.env.MAESTRO_HW_PATH ? process.env.MAESTRO_HW_PATH + '/hw-lib' : WORK_TOP + '/../hw-lib'} \\
        -hwc ${process.env.HW_CCP_PATH ? process.env.HW_CCP_PATH : process.env.MAESTRO_HW_PATH ? process.env.MAESTRO_HW_PATH + '/hw-ccp' : WORK_TOP + '/../hw-ccp'} \\
        -hwn ${process.env.HW_NCR_PATH ? process.env.HW_NCR_PATH : process.env.MAESTRO_HW_PATH ? process.env.MAESTRO_HW_PATH + '/hw-ncr' : WORK_TOP + '/../hw-ncr'} \\
    `;  
}

  // Custom utils pointer
  if (process.env.SW_UTL_PATH) {
    maestro_args += `-swu ${process.env.SW_UTL_PATH} \\
    `;
  }

  if (args.cli.maestro_example_bleed) {
    //maestro_env += (args.cli.ums ? ' ' : '#!/bin/bash\n') + 'export MAESTRO_EXAMPLES=/engr/dev/releases/utils/dep/m.ncore.bleeding_edge/mClient/samples\n';
    maestro_env += 'export MAESTRO_EXAMPLES=/engr/dev/releases/utils/dep/m.ncore.bleeding_edge/mClient/samples\n';

  }

  // Custom maestro client binary
  if (process.env.MAESTRO_EXEC_PATH) {
    // A. Path to maestro-client binary is defined in  MAESTRO_EXEC_PATH env var
    maestro_build_tag = 'custom maestro-client build';
    maestro_args += `-mc ${process.env.MAESTRO_EXEC_PATH} \\
    `
  } else if (args.cli.maestro_build_num !== undefined) {
    // B. maestro build number defined
    //	maestro_args += ' -mbn ' + args.cli.maestro_build_num;
    maestro_build_tag = maestro_env + ' ' + args.cli.maestro_build_num;
    //maestro_args += '-mc /engr/dev/releases/maestro/client/ci_debug/maestro-0.5.0-Maestro_CI_Debug-' + args.cli.maestro_build_num + '-debug/bin/maestro'
    maestro_args += ' -mc  /engr/dev/tools/Ncore3/stable_' +  args.cli.maestro_build_num  + '/maestro/bin/maestro ';
  } else {
    // C. Default maestro client, will be taken from $PATH by run_maestro
    maestro_build_tag = maestro_env + ' No Maestro build number provided';
  }

  // Run with custom tcl script and user tcl directory
  if (process.env.SW_MAESTRO_EXAMPLES_PATH) {
    const maestroExamples = path.resolve(process.env.SW_MAESTRO_EXAMPLES_PATH);
    maestro_args += `-cfg ${tcl_library} \\
    -t ${maestroExamples}/${tcl_library}/${tcl_library}.tcl \\
    -mut ${maestroExamples}/${tcl_library}/default_design` 
  }else if (args.cli.tcl_lib !== undefined || args.cli.tcl_cfg !== undefined){
        maestro_args += '-cfg ' + tcl_library;
	if(args.cli.tcl_input!==undefined){
	  maestro_args += ' -t ' + args.cli.tcl_input;
        }
        if(args.cli.tcl_cfg !== undefined) {
    	  maestro_args += ' -mut ' + args.cli.tcl_cfg;
	}
  } else {
    maestro_args += args.cli.tcl_input;
  }
  //if (args.cli.ums) {
  //  maestro_args += ' -ums true ';
  //}
  //if (args.cli.int_json){
  //  maestro_args += ' -i ' + args.cli.int_json;
  //}

  
  try {
    //	var str = proc.execSync('run_maestro ' + maestro_args, {cwd: args.exe_dir}, {stdio:"inherit",stderr:"ignore"});
    push_dir(args.exe_dir);
    if ((fs.existsSync(args.exe_dir + '/output')) && (cli.skip_maestro === undefined))
      proc.execSync('rm -rf ' + args.exe_dir + '/output');
    console.log('writing Maestro Cmd');

    //fs.writeFileSync(args.exe_dir + '/maestro_cmd', maestro_build_tag + '\n$WORK_TOP/../mClient/scripts/run_maestro ' + maestro_args + ' | tee run_maestro.log', 'utf-8');
    fs.writeFileSync(`${args.exe_dir}/maestro_cmd`, 
`# ${maestro_build_tag}
run_maestro ${maestro_args} | tee run_maestro.log
`, 'utf-8');

    fs.chmodSync(args.exe_dir + '/maestro_cmd', 511);
    console.log('Finish writing Maestro Cmd');
    console.time('Running_Maestro');
    //var str = proc.execSync('run_maestro ' + maestro_args);
    if(cli.skip_maestro === undefined)
      var str = proc.execSync(' ./maestro_cmd');
    pop_dir();
  }
  catch (err) {
    if (err) {
      console.log("run_maestro has errors: please see maestro.log");
    }
  }

  console.timeEnd('Running_Maestro');

  let TB = require(args.exe_dir + '/output/debug/top.level.dv.json', 'utf8');
  for (let section of ['AiuInfo', 'DceInfo', 'DmiInfo', 'DveInfo', 'DiiInfo']) {   // Extend the list if needed
    TB[section] = TB[section].sort(function (a, b) { return a.nUnitId - b.nUnitId });
  }
  TB.ConfDirectory = args.cfg_dir;
  fs.writeFileSync(args.exe_dir + '/output/debug/top.level.dv_sorted.json', JSON.stringify(TB, null, 2), { encoding: 'utf8' });
}



function checkParams(args,callback,testObj) {    var cli = args.cli;

    /*

      PARAM CHECKING CODE HERE


     */

    
    callback(args,testObj);
}
function getParams(args,callback,testObj) {
    var cli = args.cli;
//    console.log('DCDEBUG configParams ' + JSON.stringify(cli,null,' '));
    
    if(cli.tcl_input || cli.tcl_cfg){
	var dv_json =  args.exe_dir + '/output/debug/top.level.dv_sorted.json';
//	if(cli.skip_maestro === undefined)
            runMaestro(args, callback, testObj);
	console.log('===============RTLGEN SUCCESSFUL===============');
	args.params = getParamObj(args, dv_json,testObj);
	args.params.instanceMap = getInstanceData(args);
	if(cli.instanceName)
	    args.params.instanceName = cli.instanceName;
	else 
	    args.params.dontUseInstanceName = 1;	

        //runAria(args, callback, testObj);
        //var ariaObj = require(args.exe_dir + '/output/debug/' + 'fsys_dut_instantiation.json');
        //args.params.ariaObj = ariaObj;
//	if(fs.existsSync(args.rtl_dir + '/placeholders.flist')) 
//	   proc.execSync('rm ' + args.rtl_dir + '/placeholders.flist');
//	if(fs.existsSync(args.rtl_dir + '/memories.flist')) 
//	   proc.execSync('rm ' + args.rtl_dir + '/memories.flist');
	if (cli.sim_tool === "snps")
	  args.params.SNPS = 1;
	else if (cli.sim_tool === "cdns")
	  args.params.CDN = 1;
    if(cli.csr_off !== true && cli.csr_off !== 'true' ) runCsrCompile(args); // to run Csr Compile
	callback(args,testObj);
    } else {
	defaultRsim.getParams(args,callback,testObj);
    }
}

function runCsrCompile(args) {
    var directoryPath = args.exe_dir + '/output/IPXACT/';
    var files;
   
    try { //trying to read from the IPXACT folder
         files = fs.readdirSync(directoryPath);
    } catch (err) {
        console.log('Unable to scan the IPXACT directory: ' + err);
    }

    files.forEach(file=>{  
        var csr_cmd =  'csrCompile '+ directoryPath + file + ' ';
        var parts = csr_cmd.split(' ');
        var cmd = parts[0];
        var cmd_args = parts.slice(1);
        var result = proc.spawnSync(cmd, cmd_args, { encoding: 'utf8' });

        fs.writeFileSync(args.exe_dir + '/csr_' + file.split('.')[0] + '.log', result.stderr)
        

        if (result.error) { // to check if there was any error in executing the csrcommand
            console.error('------ERROR executing the CSR compile command:', result.error, "------");
            return;
        }
        
        if (result.status !== 0) { // has errors
            console.error(`------ERRORS have been detected in the CSR logs of ${file.split('.')[0]}.xml, Please check the log file ------`);
           // process.exit(result.status);
            
        } else { // may have warnings
            console.log('------CSR command executed successfully and has no errors but could have warnings in the logs.------');
        }

    });
    
}



function generateParams(args,callback,testObj) {
    args.concerto_cfg = getConcertCfg(args,callback,testObj);
    var codegen_cmd = 'node ' + args.wsTop + '/../codegen/bin/generatecli.js -s -a' + args.concerto_cfg + ' ' + cli.codegen;
    if(testObj.callbacks['generateParams'] !== undefined)
	testObj.callbacks['generateParams'](args,codegen_cmd);
    else
	proc.execSync(codegen_cmd);
}
function runLint(args,callback,testObj) {
    var lint_cmd = '$WORK_TOP/dv/scripts/lint_script ' + args.cli.userConfigDir + ' ' + args.cli.environment + ' ' + path.resolve(args.dbgPath);
    var pwd = proc.spawn(process.env.WORK_TOP + '/dv/scripts/lint_script', [args.cli.userConfigDir, args.cli.environment, path.resolve(args.dbgPath)], {stdio:"inherit"});
    pwd.on('close', function() {
	callback(args,testObj);
    });
}

function getParamObj(args, obj_path,callback,testObj) {
    var cli = args.cli;
    var testArgs = {
	"obj_path" : obj_path
    }
    var returnObj;
    testFunc('getParamObj',testArgs,testObj, function() {
	returnObj = require(path.resolve(obj_path));
    });
    if(cli.defines) {
	cli.defines.forEach(function(def) {
	    returnObj[def] = 1;
	});
    }
    returnObj.cli = {};
    returnObj.cli.environment = cli.environment;

    if(cli.unitRtlParams)
	returnObj.unitRtlParams = require(args.rtl_cfg);
    // console.log(JSON.stringify(returnObj.unitRtlParams));
    return returnObj;
}
//
//           RUN TESTS
//
function runCustTbTest(args,callback,testObj) {
  var rsim_ds = args;
  var run_cmd = cli.testname;
  if (cli.run_time_options) {
    var option_args = cli.run_time_options.replace(/^!/,"");
    run_cmd += ' ' + option_args;
}

if (cli.plusargs && Array.isArray(cli.plusargs)) {
  // Check if the array is either empty or contains only an empty string
  if (cli.plusargs.length === 0 || (cli.plusargs.length === 1 && cli.plusargs[0] === '')) {

  } else {
     if (cli.plusargs && cli.plusargs.length > 0) {
      var option_args = cli.plusargs
          .filter(arg => !arg.includes('UVM_VERBOSITY')) // Remove the original UVM_VERBOSITY
          .join(" ");

      let uvmVerbosityArg = cli.plusargs.find(arg => arg.includes('UVM_VERBOSITY'));
      if (uvmVerbosityArg) {
          uvmVerbosityArg = uvmVerbosityArg.replace(/^\+/, '');
          option_args += ` ${uvmVerbosityArg}`; // Append the modified UVM_VERBOSITY
      }

      run_cmd += ` RUN_ARG=${option_args}`;
  }
     
  }
}

if(cli.seed){ //seed
    var seedNum = Number(cli.seed[0])
    run_cmd += ` SEED=${seedNum}`;
  } 
  var run_args = run_cmd.split(' ');
  process.env.PROJ_HOME = rsim_ds.exe_dir + '/output';
  if (cli.sim_tool === "snps") {
    //process.env.SNPS_AMBA_VIP = rsim_ds.env_dir + '/snps_amba_vip';
    process.env.SNPS_AMBA_VIP = '/scratch/dv_reg/common_vip_lib/snps_amba_vip';
    //push_dir(rsim_ds.exe_dir + "/output/tb/VCS");
  } else if (cli.sim_tool === "cdns"){
    process.env.CDN_VIP_ROOT = '/engr/dev/tools/cadence/vipcat_11.30.066-13_Nov_2019_17_45_18';  
    process.env.CDS_INST_DIR = '/engr/dev/tools/cadence/XCELIUM_21.03.009';  
    process.env.CDS_ARCH     = 'lnx86';  
    process.env.DENALI       = process.env.CDN_VIP_ROOT + '/tools.' + process.env.CDS_ARCH + '/denali_64bit';  
    //process.env.CDN_VIP_LIB_PATH = rsim_ds.env_dir + '/cdn_vip_lib'; 
    process.env.CDN_VIP_LIB_PATH = '/scratch/dv_reg/common_vip_lib/cdn_vip_lib';
    process.env.SPECMAN_PATH = process.env.CDN_VIP_ROOT + '/packages:'+ process.env.CDN_VIP_LIB_PATH + '/64bit';
    process.env.PATH = process.env.CDS_INST_DIR + '/tools.' + process.env.CDS_ARCH + '/bin:' + process.env.PATH;  
    process.env.LD_LIBRARY_PATH = process.env.CDN_VIP_LIB_PATH + '/64bit:' + process.env.DENALI + '/verilog:' + process.env.CDS_INST_DIR + '/tools.' + process.env.CDS_ARCH + '/specman/lib/64bit:' + process.env.CDS_INST_DIR + '/tools.' + process.env.CDS_ARCH + '/lib/64bit:' + process.env.LD_LIBRARY_PATH;
    //process.env.CDS_LIC_FILE = '5282@lic-node1.arteris.com';  
    process.env.CDS_LIC_FILE = '5282@lic-node0.arteris.com:5282@yquem.arteris.com:5282@lic01.arteris.com';
    process.env.CADENCE_VIP_LIC_Q_TIMEOUT = '-1';
    process.env.CADENCE_VIP_LIC_Q_ONLY_WHEN_ALL_IN_USE = '0';
    process.env.CADENCE_VIP_LIC_DEBUG = '1';
    process.env.CADENCE_VIP_LIC_OPT = '1';
    process.env.LM_LICENSE_FILE = process.env.CDS_LIC_FILE+process.env.LM_LICENSE_FILE;
  } else {
      throw new Error("ERROR! sim tool is not defined in -k option for simulation");  
  }
  
  push_dir(rsim_ds.cfg_dir + "/dv");
  testFunc('runCustTbTest', { "run_cmd": run_cmd }, testObj, function () {

	var pwd = proc.spawn('make', run_args, { stdio: "inherit" });	
	pwd.on('close', function (err) {
	    if (err) {
	        //throw err;
		throw new Error("ERROR! Something went wrong with "+ cli.sim_tool +" simulation! Please run make " + run_cmd + "in " + rsim_ds.cfg_dir + "/dv to reproduce this error");
	    } else {

		console.log('===============SIMULATION RUN SUCCESSFUL===============');
		proc.execSync('sleep 1s');
		callback(args, testObj);
	    }
	});
    });
}

function runMentorTest(args, callback, testObj) {
	var cli = args.cli;
	var rsim_ds = args;
        var xprop_options = {};

	args.setEnvMentor();
	//    setEnv('/engr/dev/tools/script/mentor-eng.sh');
	if (!cli.grid_run)
		genTestDir(args, callback, testObj);
	var coverage_string = ''
	if (cli.codeCoverage)
		coverage_string = '-coverage ';
	if (cli.seed)
		var sv_seed_string = '-sv_seed ' + cli.seed;
	else
		var sv_seed_string = '-sv_seed ' + getRandomInt(0, 67108864);

	if (cli.grid_run)
		var test_dir = '/local/' + process.env.USER + '/' + cli.grid_run
	else
		var test_dir = rsim_ds.test_dir

	if (cli.xprop) {
		xprop_options = xprop_args(args);
	}

    if (xprop_options.xprop_error_limit) {
	var run_cmd = 'vsim ' + coverage_string + '-batch -64 +UVM_TESTNAME=' + cli.testname + ' ' + sv_seed_string + ' ' + plus_args(args) + '-lib ' + rsim_ds.exe_dir + '/work top_opt -L ' + rsim_ds.exe_dir + '/work -do dofile -stats=perf,verbose -solvefaildebug -l vcs.log -permit_unmatched_virtual_intf -warning 3829,3839,8604,12003,12023,3008,3009,7077,8630,8209 +nowarn3829 +nowarn8233 -suppress 8554,8560,8858 -uvmcontrol=none -msglimit error' + ' -msglimitcount ' + xprop_options.xprop_error_limit + ' -modelsimini /engr/dev/tools/script/modelsim.ini' + ((args.newMentor) ? "" : " -novopt"); //sv_seed random
	if (cli.run_time_options)
	    run_cmd += ' ' + default_run_time_options;
	
    } else {
	var run_cmd = 'vsim ' + coverage_string + '-batch -64 +UVM_TESTNAME=' + cli.testname + ' ' + sv_seed_string + ' ' + plus_args(args) + '-lib ' + rsim_ds.exe_dir + '/work top_opt -L ' + rsim_ds.exe_dir + '/work -do dofile -stats=perf,verbose -solvefaildebug -l vcs.log -modelsimini /engr/dev/tools/script/modelsim.ini' + ((args.newMentor) ? "" : " -novopt"); //sv_seed random
	var default_run_time_options = '-permit_unmatched_virtual_intf -warning 3829,3839,8604,12003,12023,3008,3009,7077,8630,8209 +nowarn3829 +nowarn8233 -suppress 8554,8560,8858 -uvmcontrol=none -msglimit error'
	if (cli.run_time_options) {
	    var option_args = cli.run_time_options.replace(/^!/,"");
	    if(!cli.run_time_options.match(/^!/))
		run_cmd += ' ' + default_run_time_options;
	    run_cmd += ' ' + option_args;
	} else {
	    run_cmd += ' ' + default_run_time_options;
	}

    }
	//if(!cli.noPermissive) run_cmd += ' -permissive ';

    if (plusArgExists(args, 'en_dump')) {
	run_cmd += ' -qwavedb=+signal -qwavedb=+memory=1000,3'
    }

	var seed_value = (cli.seed) ? cli.seed : '';


	/*
	if(plusArgExists(args,'ntb_random_seed')) {
	
  cli.plusargs.forEach(function(elem, index, array) {
	  if(elem.match(/\+?ntb_random_seed=/)) {
	sv_seed_string = '-sv_seed ' + elem.replace(/\+?ntb_random_seed=/, '');
  //		seed_value = elem.replace(/\+?ntb_random_seed=/, '');
	  }
  });
	}
  */
	var testArgs = {
		"run_cmd": run_cmd
	}
	var dofile_str = 'set PrefMain(LinePrefix) {};\n'
	if (cli.codeCoverage || cli.functionalCoverage) {
		dofile_str += 'coverage exclude -du internal_mem_*;\n'
		dofile_str += 'coverage save -onexit test' + seed_value + '.ucdb;\n'
	}
	if (args.dofile_args) {
		dofile_str += args.dofile_args;
	}
	if (cli.xprop) {
		dofile_str += 'do xpropdofile;\n';
	}
        if (cli.vcd) {
            dofile_str += 'vcd add -file vsim.vcd ' + cli.vcd + '/\*\n';
	}
	dofile_str += 'run -a;\nquit -f\n';

	var xpropdofile_str = ''
	if (xprop_options.xprop_assert_limit) {
		xpropdofile_str += 'xprop assertlimit ' + xprop_options.xprop_assert_limit + ';\n';
	}

	if (xprop_options.xprop_exclude_file) {
		xpropdofile_str += fs.readFileSync(xprop_options.xprop_exclude_file);
        }

	if (xprop_options.xprop_init_disable_time) {
		xpropdofile_str += 'xprop disable;\nrun ' + xprop_options.xprop_init_disable_time + ';\nxprop enable;\n';
	}

	testFunc('runMentorTest', testArgs, testObj, function () {
		var node_cmd = '';
		process.argv.forEach(function (val, index, array) {
			node_cmd += val + ' ';
		});
		fs.writeFileSync(test_dir + '/node_run', node_cmd, 'utf8');
		fs.writeFileSync(test_dir + '/dofile', dofile_str, 'utf8');
		if (cli.xprop) {
			fs.writeFileSync(test_dir + '/xpropdofile', xpropdofile_str, 'utf8');
		}
		fs.writeFileSync(test_dir + '/run_sim', run_cmd + ' -qwavedb=+signal -qwavedb=+memory=1000,3', 'utf8');
		fs.chmodSync(test_dir + '/run_sim', "0777");

		if (cli.grid_run) {
			if (process.env.JOB_ID !== undefined) {
				var grid_dir = '/local/' + process.env.USER + '/' + process.env.JOB_ID;
				if (!fs.existsSync(grid_dir))
					fs.mkdirSync(grid_dir);
				push_dir(grid_dir);
			}
		} else {
			push_dir(rsim_ds.test_dir);
		}

		var cmd_args = run_cmd.split(' ');
		cmd_args.shift();
		var pwd = proc.spawn('vsim', cmd_args, { stdio: "inherit" })
		pwd.on('close', function () {
			if (cli.grid_run) {
				//		proc.execSync('cp ' + grid_dir + '/* ' + rsim_ds.test_dir);
			}
			pop_dir();
			callback(args, testObj);
		});
	});
}

function genTachlWithCopy(args,callback,testObj) {
    if(args.cli.tcl_input || args.cli.tcl_cfg) {

	//if Tcl input for fsys, don't actually generate RTL
	return function(args,callback,testObj) {
	    console.log('Skipping TACHL generation for Full System because it is already generated from maestro');
	    var fileName = args.rtlPkg;
	    //DCHACK how to get this more dynamically from testlist?
	    if(fs.existsSync(args.exe_dir + '/output/rtl/models/memories/*'))
		proc.execSync('cp ' + args.exe_dir + '/output/rtl/models/memories/* ' + args.rtl_dir);
	    if(fs.existsSync(args.exe_dir + '/output/rtl/placeholders/*'))
		proc.execSync('cp ' + args.exe_dir + '/output/rtl/placeholders/* ' + args.rtl_dir);
	    genBlockFList(args);
	    if(args.cli.instanceName) {
		var moduleName  = args.params.instanceMap[args.cli.instanceName];
		console.log('sourcing ' + moduleName + '.flist');
		if(moduleName === undefined)
		    throw new Error('ERROR! ' + moduleName + ' not found in design!');
		editFlist(moduleName + '.flist',args,testObj);
	    } else {
		if(args.cli.environment == "ioaiu")
		    editFlist('ioaiu_top_0.flist',args,testObj);		
		else if(args.cli.environment == "dmi")
		    editFlist('dmi_0.flist',args,testObj);		
		else if(args.cli.environment == "dii")
		    editFlist('dii_top_0.flist',args,testObj);
		else if(args.cli.environment == "aceaiu")
		    editFlist('aiu_top_0.flist',args,testObj);
		else if(args.cli.environment == "chi_aiu")
		    editFlist('aiu_top_0.flist',args,testObj);
		else if(args.cli.environment == "chi_aiu_snps")
		    editFlist('aiu_top_0.flist',args,testObj);
		else if(args.cli.environment == "dve")
		    editFlist('dve_0.flist',args,testObj);
		else if(args.cli.environment == "fsc")
		    editFlist('fsc_0.flist',args,testObj);
		else
		    editFlist('top.flist',args,testObj);
	    }
            args.memflist=1;
//	    if(!args.cli.skip_maestro || (args.cli.environment == "fsys")) 
	    if(args.cli.environment == "fsys" || args.cli.environment == "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || args.cli.environment == "ioaiu_subsys") {
		if(!args.cli.skip_maestro) {
//		    if(fs.existsSync(args.rtl_dir + '/memories.flist'))
//			editFlist('memories.flist', args,testObj);
//		    if(fs.existsSync(args.rtl_dir + '/placeholders.flist'))
//			editFlist('placeholders.flist', args,testObj);
		}
	    }

	    callback(args,testObj);
	};
    } else {
	console.log('Starting TACHL generation');
	var verFiles = fs.readdirSync(process.env.WORK_TOP + '/node_modules/@arteris/hw-lib/verilog/');
	for(var i = 0; i < verFiles.length; i++) {
	    if(!fs.existsSync(args.cfg_dir + '/rtl'))
		fs.mkdirSync(args.cfg_dir + '/rtl');
	    proc.execSync('cp ' + process.env.WORK_TOP + '/node_modules/@arteris/hw-lib/verilog/' + verFiles[i] + ' ' + args.cfg_dir + '/rtl');	
	}
	process.env["ATP_TOP"] = process.env.WORK_TOP + "/node_modules/@arteris/hw-sym/dv/tb/top/dryrun_legato";
	return defaultRsim.execFunc(args,callback,testObj);
    }
}
function genParseTop(args, callback, testObj) {
	var rsim_ds = args;
	var cli = args.cli;

	var rtl_patt = /(top\.v|root\.v)/;
	switch (cli.environment) {
		case 'dce': rtl_patt = /(top\.v|root\.v)/; break;
		case 'aiu': rtl_patt = /(top\.v|root\.v)/; break;
		case 'dmi': rtl_patt = /(top\.v|root\.v)/; break;
		case 'cbi': rtl_patt = /(top\.v|root\.v)/; break;
		case 'ccp_dmi': rtl_patt = /(top\.v|root\.v)/; break;
		case 'ccp_ncb': rtl_patt = /(top\.v|root\.v)/; break;
		case 'psys': rtl_patt = /$^/; break;
	}
	var testArgs = {
		"rtl_patt": rtl_patt
	}
	testFunc('genParseTop', testArgs, testObj, function () {
		var w_filename = rsim_ds.rtl_dir + '/parse_top.f';
		var params = [];
		params = [rsim_ds.concerto_cfg];
		fs.writeFileSync(w_filename, "");
		if (args.rtlType == 'TACHL')
			var rtl_dir_f_list = rsim_ds.rtl_dir + '/flist.f';
		else
			var rtl_dir_f_list = rsim_ds.rtl_dir + '/top.f';
		var lines = fs.readFileSync(rtl_dir_f_list, 'utf8').split('\n');
		for (var line = 0; line < lines.length; line++) {
			var filename = lines[line].replace(/^.*[\\\/]/, '');
			if (!filename.match(rtl_patt)) {
				fs.appendFileSync(w_filename, lines[line] + '\n');
				console.log('including this file ' + filename);
			}
		}
		callback(args, testObj);
	});
}
function cliDefineExists(args, arg1) {
    var cli = args.cli;
    var exists = false;
    if (cli.defines) {
        cli.defines.forEach(function(elem, index, array) {
            if(arg1 === elem) {
                exists = true;
            }
        });
    }
    return exists;
};
function editFlist(flist_name,args,testObj) {
    var fileName = args.rtlPkg;
    if(testObj === undefined) {
	var fn = fs.readFileSync(args.rtl_dir + '/' + flist_name).toString().split('\n');
	var buf = "";
	if(fileName) {
	    var modName = path.basename(fileName).replace('tmp_','').replace('\.js','\.v');
	    var origFileName = path.basename(fileName);
	} else if(args.dvPkg) {
	    var modName = path.basename(flist_name).replace('.flist','.v');
	    var origFileName = path.basename(flist_name);
	}

	fn.forEach(function(line) {
	    if(line.length > 1) {
		console.log('origFileName ' + origFileName);
		if(!path.isAbsolute(line))
		    buf += args.rtl_dir +'/'
		if(line.match(origFileName))
		    buf += line + '\n';
		else if(line.match(/\$PROJ_HOME/)) {
		    console.log('line ' + line + ' fileName ' + path.basename(line));
		    buf += path.basename(line) + '\n';
		}else
		    buf += line + '\n';
	    }
	});
        if(args.memflist!=undefined){
		fs.appendFileSync(args.rtl_dir + '/flist.f', buf, 'utf-8');
	}else{	
		fs.writeFileSync(args.rtl_dir + '/flist.f', buf, 'utf-8');
	}
    }
}

function testFunc(fname,testArgs,testObj, funcOp) {
    var returnVal;
    if(testObj === undefined) {
	returnVal = funcOp();
    } else {
	if(testObj.callbacks === undefined) {
	    returnVal = funcOp();
	} else {
	    if(testObj.callbacks[fname] !== undefined) {
		testObj.callbacks[fname](testArgs);
	    } else {
		returnVal = funcOp();
	    }
	}
    }
    if(returnVal !== undefined)
	return returnVal;
}
function genExeDirs(args, callback, testObj) {
	var cli = args.cli;
	var rsim_ds = args;
	testFunc('genExeDirs', {}, testObj, function () {
		if (!fs.existsSync(rsim_ds.cfg_dir + '/exe'))
			fs.mkdirSync(rsim_ds.cfg_dir + '/exe');
	});
}

function getRalgenUnits(args) {
    var unitNames = [];

    if(args.cli.environment === "chi_aiu" || args.cli.environment === "chi_aiu_snps" || args.cli.environment === "ioaiu" || args.cli.environment === "ioaiu_snps" || args.cli.environment === "fsys"  || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || args.cli.environment === "ioaiu_subsys" || args.cli.environment == "emu"){
	args.params.AiuInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : (unit.fnNativeInterface === "CHI-B" || unit.fnNativeInterface === "CHI-A" || unit.fnNativeInterface === "CHI-E") ? "chi_aiu" : "ioaiu"
	    };
	    unitNames.push(unitObj);
	});
    }
    if(args.cli.environment === "aceaiu"|| args.cli.environment === "fsys"  || (args.cli.environment == "ioaiu_subsys_snps") || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || args.cli.environment === "ioaiu_subsys"){
	args.params.DceInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : "aceaiu"
	    };
	    unitNames.push(unitObj);
	});
    }
    if(args.cli.environment === "dce"|| args.cli.environment === "fsys" || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "ioaiu_subsys")){
	args.params.DceInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : "dce"
	    };
	    unitNames.push(unitObj);
	});
    }
    if(args.cli.environment === "dii"|| args.cli.environment === "dii_snps"|| args.cli.environment === "fsys" || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "ioaiu_subsys")){
	args.params.DiiInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : "dii"
	    };
	    unitNames.push(unitObj);	
	});
    }
    if(args.cli.environment === "dmi"|| args.cli.environment === "fsys" || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "ioaiu_subsys")){
	args.params.DmiInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : "dmi"
	    };
	    unitNames.push(unitObj);
	});
    }
    if(args.cli.environment === "dve"|| args.cli.environment === "fsys" || args.cli.environment === "fsys_snps"  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "ioaiu_subsys")){
	args.params.DveInfo.forEach(function(unit) {
	    var unitObj = {
		"name" : unit.strRtlNamePrefix,
		"type" : "dve"
	    };
	    unitNames.push(unitObj);
	});
    }
    if(((args.cli.environment === "fsys") || (args.cli.environment === "fsys_snps")  || (args.cli.environment == "ioaiu_subsys_snps") || (args.cli.environment == "chi_subsys") || (args.cli.environment == "ioaiu_subsys")) && (Object.keys(args.params.FscInfo) > 0)){
	    var unitObj = {
		"name" : "fsc",
		"type" : "fsc"
	    };
	    unitNames.push(unitObj);
    }

    
    return unitNames;
}
function getArgs(args,callback,testObj) {
    cli
	.version('0.0.1')
	.option('-a, --achl', 'Switch to generate RTL from achl compiler for specific block. All previous files in rtl directory are deleted before re-generating. Default points to current stable version')
	.option('-A, --assertOff', 'turn off random assertOn picking')
	.option('-b, --label <string>', 'Switch to specify a label for this run')
        .option('-B, --maestro_build_num <string>', 'Maestro Build number')
	.option('-c, --compile', 'Switch to compile specified environment using specificed simulator, default is VCS')
	.option('-C, --noPermissive', 'Remove permissive switch from verilog compilaton')
	.option('-d, --defines <items>', 'Swtich to provide all Verlog/System-Verilog defines. All defines must be separated by comma(,) without any spaces Ex: -d DEFINE_1,DEFINE_2', list)
	.option('-D, --dumpPath <string>', 'Switch to generate *debug* directory hierarchy at specified location instead of default CONCERTO_TOP/hw/*debug* location', validPath(args, testObj))
	.option('-e, --environment <string>', 'Switch to specify TestBench you want to execute(dec|dmi|aiu|psys|sys)')
	.option('-E, --notEnvGen', 'Switch to force program to NOT GENERATE Test-Bench Environment files')
	.option('-f, --functionalCoverage', 'functional coverage run')
	.option('-F, --maestro_build', 'Using git hw repo hash specified in manifest.json')
	.option('-g, --grid_run <string>', 'Switch to enable rsim to run simv in /local')
	.option('-h, --skip_maestro', 'skip_maestro and RAL')
	.option('-H, --skip_test', 'skip test')
	.option('-i, --instanceName <string>', 'select instanceName of unit for unitLevel')
	.option('-I, --ncsimSimulator', 'Switch to select Cadence NCSim simulator')
	.option('-j, --int_json <string>', 'user supplied intermediate json')
	.option('-l, --compile_time_args <string>', 'This string will be passed as compile time flags to the SystemVerilog compiler')
	.option('-L, --Lint', 'Switch to run lint')
	.option('-m, --includeExternalMemory', 'Switch to include verilog behavioral Memory Model in compilation')
	.option('-M, --includeSnpsMemory', 'Switch to include Synopsys Memory Model in compilation')
	.option('-n, --userConfigDir <string>', 'Switch to give control to user to decide Configuration directory name.')
	.option('-o, --codeCoverage', 'Switch to generate Code Coverage. Right Code Coverage options are specified on command line depending on simulation tool. Must be specified both compile & run time')
	.option('-O, --optimize_time_options <string>', 'pass this string to run it as optimize time options to Mentor Graphics VOPT')
	.option('-p, --plusargs <items>', 'Switch to provide all Verilog/System-Verilog plusrags. All plusargs must be separated by comma(,) without any spaces Ex: -d arg_1,arg_2 ', list)
	.option('-P, --run_tempo', 'run Tempo')
	.option('-q, --questaSimulator', 'Switch to select Cadence NCSim simulator')
	.option('-Q, --maestro_example_bleed', 'Use Maestro_example bleeding edge')
	.option('-r, --run_time_options <string>', 'pass this string to run it as run time options to simulator')
	.option('-R, --seed <string>', 'Swtich to provide all Verlog/System-Verilog defines. All defines must be separated by comma(,) without any spaces Ex: -d DEFINE_1,DEFINE_2', list)
	.option('-s, --configParams <string>', 'Switch to specify configuration file to generate DV/RTL. Default is concerto_system_params_hier.js. If -n switch is not specified then config file name will be the configuratioin directory name', validPath(args, testObj))
        .option('-S, --ums', 'Maestro server mode')
	.option('-t, --testname <string>', 'Switch to provide test to run, Note that this switch only runs test expacting that compile has already completed & successful')
	.option('-T, --tachlfordv', 'use tachl for dv')
	.option('-u, --uniqueID <string>', 'Switch to pass processID in for uniqueness')
	.option('-U, --unitRtlParams <string>', 'Switch to pass in JSON for unit params')
	.option('-x, --xml_path <string>','xml file for ipxact')
	.option('-v, --vcd <string>','Enable VCD dumping for specified hiearchy')
	.option('-X, --xprop <items>', 'run with xprop enabled. Swtich to provide all xprop options. All plusargs must be separated by comma(,) without any spaces Ex: -X xprop_mode=<mode>,xprop_init_disable_time=<time>,xprop_error_limit=<num_errors>,xprop_assert_limit=<n> ', list)
        .option('-y, --tcl_lib <string>', 'Maestro library')
   	.option('-z, --tcl_input <string>', 'Maestro input tcl')
	.option('-Z, --tcl_cfg <string>', 'TCL configuration directory')
	.option('-k, --sim_tool <string>', 'simulation tool for cust_tb, supporting snps and cdns')
    .option('--csr, --csr_off', 'Disable CSR compile;')
    .option('--verible, --verible_on', 'Enable Verible Formatter;')
    
	.parse(args.cmdArgs);
    
    var rsim_ds = args;
    //Sets rsim_ds objects

    args.cli = cli;
    callback(args,testObj);
}
function list(val) {
    return (val.split(','));
}

function validPath(args, testObj) {
    if(testObj !== undefined) {
	return function(str) { return str };
    } else {
	return function(str) {
	    if(!path.isAbsolute(str))
	       str = args.PWD + '/' + str

	    var stats = fs.statSync(str);

	    if (stats.isDirectory() || stats.isFile()) {
		return (str);
	    } else {
		var err = 'Unexpected type of object returned from fs.stat()';
		console.log(stats);
		throw (err);
	    }
	};
    }
}
function usr_defines(args) {
	var usr_def = '';
	var cli = args.cli;
	if (cli.defines) {
		cli.defines.forEach(function (elem, index, array) {
			//console.log(elem);
			if (elem.match(/^\+define\+/)) usr_def += elem;
			else if (elem.match(/^\+/)) usr_def += '+define' + elem;
			else usr_def += '+define+' + elem;
			usr_def += ' ';
		});
	}

	if (cli.environment === 'psys') {
		usr_def += '+define+V1' + ' ';
	}
	//console.log(usr_def);
	return (usr_def);
}

function getInstanceData(args) {
//    var instanceData = require(args.rtl_dir + '/instanceMap.json');
    var retData      = require(args.exe_dir + '/output/rtl/design/instanceMap.json');
    /*    for(var moduleName in instanceData) {
	instanceData.forEach(function(instanceName) {
	    retData[instanceName] = moduleName;
	});
    } */
    return retData;
}
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
function xprop_args(myArgs) {
	var cli = myArgs.cli;
	var args = {};
	if (cli.xprop) {
		cli.xprop.forEach(function (elem, index, array) {
                        var parts = [];
                        parts = elem.split("=");
                        args[parts[0]] = parts[1];
		});
	}
	return (args);
}
