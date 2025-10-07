const fs = require('fs');
const path = require('path');

if (process.argv.length < 4 || process.argv.length > 5) {
    console.error('Usage: node script.js <name> <source_file> [sim_tool]');
    process.exit(1);
}

const name = process.argv[2];
const sourceFile = process.argv[3];
const simTool = process.argv[4] || 'snps';

const targetBaseDir = process.env.MAESTRO_EXAMPLES;
const workTop = process.env.WORK_TOP;

if (!targetBaseDir || !workTop) {
    console.error('MAESTRO_EXAMPLES and/or WORK_TOP environment variables are not set');
    process.exit(1);
}

const targetDir = path.join(targetBaseDir, `hw_config_${name}`);
fs.mkdirSync(targetDir, { recursive: true });

const tclContent = `
puts "##########################################"
puts "#### Read in BASE config post map MPF file"
puts "##########################################"

set curDir [ file dirname [ file normalize [ info script ] ] ]

open_project -file $curDir/hw_config_${name}.mpf

proc rename_object_by_network {network objname } {
  set netw      [abbrev $network]
  set shortname [abbrev $objname]
  set oldname   $network/$objname
  set newname   \${netw}_$shortname
  puts "Renaming $oldname to $newname"
  rename_object -name $oldname -new_name $newname
}

proc resolve_object_names { } {
  set chip [get_objects -parent project -type chip]
  set topology [get_objects -parent $chip -type topology]
  set networks [get_objects -parent $topology -type network]

  # rename any switch that begins with "insertedSwitch"
  foreach netw $networks {
    set typ [query_object -object $netw -type network_type]
    if {$typ == "nondata" || $typ == "data"} {
      set shortname [abbrev $netw]
      set switches [get_objects -parent $netw -type switch]
      foreach obj $switches {
        set pos [string first "insertedSwitch" $obj]
        if {$pos > 0} {
          rename_object_by_network $netw [abbrev $obj]
        }
      }

      # rename any pipe adapters that have the name "cd?_pp*"
      set pipes [get_objects -parent $netw -type pipe_adapter]
      foreach obj $pipes {
        set shortname [abbrev $obj]
        set pos [string match "cd?_pp*" $shortname]
        if {$pos == 1} {
          rename_object_by_network $netw [abbrev $obj]
        }
      }
    }
  }
}

proc move_forw_to_state {desired_state} {
 set current_state [get_current_state]

  while {$current_state != $desired_state} {
    set now_state [get_current_state]
    run_task -name move_to_next_state
    set current_state [get_current_state]
    if {$now_state == $current_state} {
      break; # unable to advance
    }
    puts "Moving forward  to state $current_state"
  }
}

# This proc is designed for DV flows and to be used only when maestro client 
# is launched from run_maestro
proc run_dv_gen_collateral {} {
  global env
  if { [info exists env(USE_MAESTRO_SERVER)] != 1 || $env(USE_MAESTRO_SERVER) == "false" } {
    puts "run_dv_gen_collateral: USE_MAESTRO_SERVER is not defined, will not run maestro-server"
    return
  }


  if {$env(USE_MAESTRO_SERVER)=="true"} {
    gen_collateral -file server_output.tgz
  } else {
    gen_collateral -file server_output.tgz -server_exec $env(USE_MAESTRO_SERVER)
  }
  exec tar xvfz server_output.tgz
}

# avoid object name conflicts in networks
# resolve_object_names

set desired_state "Export/Export"
move_forw_to_state $desired_state

# Continue to generate DV collaterals
run_dv_gen_collateral

puts "#######################################"
puts "#### Completion BASE config script and exit: [info script]"
puts "#######################################"
exit

`;
const tclFile = path.join(targetDir, `hw_config_${name}.tcl`);
fs.writeFileSync(tclFile, tclContent);

// Copy the .mpf file
const targetMpf = path.join(targetDir, `hw_config_${name}.mpf`);
fs.copyFileSync(sourceFile, targetMpf);

// Update JSON file
const jsonPath = path.join(workTop, `dv/cust_tb/${simTool}/tb/runsim_testlist.json`);
console.log(jsonPath);
const jsonData = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

if (jsonData.configlist) {
    jsonData.configlist[`hw_config_${name}`] = {
        "purpose": `hw_config_${name} default description`,
        "tcl_lib": `hw_config_${name}`,
        "tcl_dir": `$MAESTRO_EXAMPLES/../fsys_config/hw_config_${name}`,
        "sim_tool": `${simTool}`,
        "compile_args": ""
    };

    fs.writeFileSync(jsonPath, JSON.stringify(jsonData, null, 2));
}

console.log(`Config Added successfully`);