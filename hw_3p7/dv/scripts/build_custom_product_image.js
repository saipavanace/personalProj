#!/usr/bin/env node

// Script for creating custom Maestro product images

'use strict';
const fs = require('fs');
const path = require('path');
const cp = require('child_process');
const { promisify } = require('util');
const exec = promisify(cp.exec);
const readline = require('readline');
const cli  = require('commander');
//var readlineSync = require('readline-sync');
const { format } = require('path');



function formatDate(d) {
  let month   = d.getMonth() + 1,
    day     = d.getDate(),
    year    = d.getFullYear(),
    seconds = d.getSeconds(),
    minutes = d.getMinutes(),
    hours   = d.getHours();

  month   = (month < 10) ? "0" + month : month;
  day     = (day < 10) ? "0" + day : day;
  hours   = (hours < 10) ? "0" + hours : hours;
  minutes = (minutes < 10) ? "0" + minutes : minutes;
  seconds = (seconds < 10) ? "0" + seconds : seconds;

  return [year, month, day, hours, minutes, seconds].join('_');
}

function runInBackground(command) {
  console.log(`Info: running '${command}' in background`);
  let job = cp.exec(command);
  job.on('exit', (code) => {
    if (job.signalCode !== null) {
      console.log(`Error: '${command}' killed! Aborting the whole process`);
      process.exit(1);
    } else if (job.exitCode !== 0 ) {
      // Only print the message, but don't abort MAES-3221
      console.log(`Warning: '${command}' completed with non-zero exit status`);
    } 
  });
  return job;
}

cli
  .version(0.1)
  .name(`
This script 
  1. builds custom maestro-server
  2. install it along with specified maestro-client to create a full product image
  3. sets up an environment so when maestro/run_maestro launched in the same unix shell
     it will use the custom image 

Examples:

Create product image equivalent to Ncore3 stable:
  build_custom_product_image.js --branch_name Ncore3

Create image equivalent to Ncore3 build 157 (See list of available Ncore3 images under /engr/dev/releases/maestro/build/Ncore3/maestro-product)  
  build_custom_product_image.js --branch_name Ncore3 --image_id 157

Same, but take hw-ncr from private directory
  build_custom_product_image.js --branch_name Ncore3 --image_id 157 --hw_ncr ~/source_code/hw-ncr

  `
  )
  .option('-br|--branch_name <name>', 
    'First half of base line. Server repos and client binary are taken from this branch by default',
    'master')
  .option('-img|--image_id <name>',
    'Second half of base line. Client binary and server source code are taken from this particular product image',
    'stable')
  .option('-mcl|--maestro_client_home <path>', 
    'Copy custom Maestro client from this build directory')
  .option('-hwn|--hw_ncr <path>',
    'Path to directory with hw-ncr source code')
  .option('-hws|--hw_sym <path>',
    'Path to directory with hw-sym source code')
  .option('-hwl|--hw_lib <path>',
    'Path to directory with hw-lib source code')
  .option('-hwc|--hw_ccp <path>',
    'Path to directory with hw-ccp source code')
  .option('-swu|--utils <path>',
    'Path to directory with utils source code')
  .option('-mnc|--m_ncore <path>',
    'Path to full maestro-server (m-ncore) sandbox. It assumes that you have already run npm install for m-ncore and will copy it as is. Also all -hw* and -sw* are ignored')
  .option('-bd|--build_dir <path>',
    `New directory where custom image will be created, (default: ${process.env.PWD}/<timestamp>)`)
  .option('-drn|--dry_run',
    'Only print what will be taken from where and exit',
    false)
  .parse(process.argv);
  let options = cli.opts();

// Main function
(async function() {
  // This is the central area where Maestro images are deployed 
  const centralImageDeploymentRoot = '/engr/build/maestro';
  
  // This is a list of repos which can be overridden
  const repoList = ['hw-ncr', 'hw-sym','hw-lib','hw-ccp','utils'];

  // The base image is found here
  const imageDir = `${centralImageDeploymentRoot}/${options.branch_name}/maestro-product/${options.image_id}`;

  // Read product image manifest
  const manifest = require(`${imageDir}/manifest.json`);
  const serverGitSha = manifest.maestroServer.git_sha;
  const clientGitSha = manifest.maestroClient.git_sha;

  // Get current time and date
  const startTime =  new Date();

  // Automatically complete setting of options which were not defined
  // and report all settings
  
  // a. build dir 
  if (options.build_dir === undefined) {
    options.build_dir = `${process.env.PWD}/${formatDate(startTime)}`;
  } else {
    // If build_dir is defined -convert to absolute
    options.build_dir = path.resolve(options.build_dir);
  }
  

  // b. client binary
  if (options.maestro_client_home === undefined) {
    options.maestro_client_home = `${imageDir}/maestro-client`;
  } 
  if (! fs.existsSync(`${options.maestro_client_home}/bin/maestro`)) {
    console.error(`Error: Maestro client exec '${options.maestro_client_home}/bin/maestro' doesn't exist or not readable`);
    return;
  }
  if (! fs.existsSync(`${options.maestro_client_home}/maestro_tcl`)) {
    console.error(`Error: invalid maestro client directory - ${options.maestro_client_home}/maestro_tcl doesn't exist or not readable`);
    return;
  }
 
  console.log(`
*********************************************************************************************
Custom image will be built here:
  ${options.build_dir}
Maestro client will be taken from:
  ${options.maestro_client_home}/bin/maestro
Server baseline:`);

  if (options.m_ncore) {
    console.log(`  ${options.m_ncore}`);
  } else {
    console.log(`  branch ${options.branch_name}, commit ${serverGitSha}`);
  

    // d. List of all repo overrides
    for (let repo of repoList) {
      if (options[repo.replace('-','_')] !== undefined) {
        // Copy options.hw_ncr as options.hw-ncr 
        options[repo] = options[repo.replace('-','_')];

        // Check if repo directory exists
        if (!fs.existsSync(options[repo])) {
          console.error(`Error: Directory ${options[repo]} doesn't exist or not readable`);
          return;
        }
        console.log(`${repo} override:`);
        console.log(`  ${options[repo]} `);
      }
    }
  }
  console.log('********************************************************************************************\n');

  // If dry run - exit now
  if (options.dry_run) {
    console.log('dry run, exiting');
    return;
  }

  // Now we can actually start to create the custom product image
  
  // 1. Create build dir and go there 
  try {
    fs.mkdirSync(options.build_dir);
  } catch (e) {
    console.error(`Error: can't create ${options.build_dir}! Either directory already exists or location is not writeable`);
  }
  process.chdir(options.build_dir);

  // 2. Copy client in the background
  const job1=runInBackground(`cp -r ${options.maestro_client_home} ${options.build_dir}/maestro-client`);
  
  // When we copy maestro client from the sandbox, tests dir with tcl is found one dir
  // level above the build dir - copy it too after the main copying of the client is complete 
  job1.on('exit', async (code) => {
    if (fs.existsSync(`${options.maestro_client_home}/../tests/cases`)) {
      await exec(`rm -rf ${options.build_dir}/maestro-client/tests`);
      runInBackground(`cp -r ${options.maestro_client_home}/../tests ${options.build_dir}/maestro-client`);
    }
  });

  // 2.1 Copy wrapper dir
  exec(`cp -RL ${imageDir}/bin ${options.build_dir}`);

  // 3. Copy hw-repos - this is necessary for running Ncore DV tests
  runInBackground(`cp -r ${imageDir}/hw_repos ${options.build_dir}`); 
  
  // 4. Build maestro-server
  if (options.m_ncore) {
    // 4A. If --m_ncore was specified, simply create a package out of it
    fs.mkdirSync(`${options.build_dir}/maestro-server`);
    process.chdir(options.m_ncore);
    console.log(`Info: creating packaged ${options.build_dir}/maestro-server/maestro-server`);
    await exec(`node_modules/.bin/pkg --options max_old_space_size=4096 index.js -c scripts/build.json -o ${options.build_dir}/maestro-server/maestro-server`);
    await exec(`cp ${imageDir}/maestro-server/grpc_node.node ${options.build_dir}/maestro-server`);

    
  } else {
    // 4B. Otherwise build maestro-server from the source

    // 4.1 Clone  m-ncore - no need to specify branch because we will checkout specific git sha from the manifest
    console.log('Info: cloning server top level repo (m-ncore)');
    await exec(`git clone http://jenkins:glpat-F-Y1_Jp5UrZk-EGYT8P5@gitlab.arteris.com/maestro-dev/services/m-ncore.git`);

    // 4.2 Rename m-ncore to maestro-server and move there 
    await exec(`mv m-ncore maestro-server`);
    process.chdir('maestro-server');

    // 4.3 Checkout specific commit of m-ncore extracted from the baseline image manifest
    await exec(`git checkout ${serverGitSha}`);

    // 4.4 Remove package-lock.json
    fs.unlinkSync('package-lock.json');

    // 4.5 Load and modify package.json of m-ncore
    console.log('Info: updating package.json');
    let mncorePkg = require(`${options.build_dir}/maestro-server/package.json`);

    // 4.6 Loop through all server dependencies from m-ncore package.json, which start with '@arteris' 
    //  and update them as follows
    //  a. If this repo was specified by the user - take the value from there 
    //  b. if not - take the value from manifest.maestroServer 
    // Ex depName: "@arteris/utils", depValue: "git+ssh://git@gitlab.arteris.com:maestro-dev/packages/utils.git#d28ec...
    for (let depName of Object.keys(mncorePkg.dependencies).filter(name=>/^@arteris\//.test(name))) {
      let depValue = mncorePkg.dependencies[depName];

      // Strip '@arteris/' from depName to get bare repo name, such as 'utils'
      const repo = depName.replace('@arteris/','');

      // If repo override is defined in options - use it 
      if (options[repo] !== undefined) {
        // TBD: only unix dir is supported right now
        mncorePkg.dependencies[depName] = path.resolve(options[repo]);
        console.log(` ${repo} - ${mncorePkg.dependencies[depName]} (user override)`);
      } else if(manifest.maestroServer.components[repo] !== undefined) {
        mncorePkg.dependencies[depName] = manifest.maestroServer.components[repo].version;
        console.log(` ${repo} - ${mncorePkg.dependencies[depName]} (from manifest.json)`);
      }
    }

    // 4.7 Write modified package.json of m-ncore back
    fs.writeFileSync('package.json',JSON.stringify(mncorePkg,null,2),{encoding: 'utf8'});

    // 4.8 Install all m-ncore packages
    // Unset WORK_TOP first - MAES-2739
    console.log('installing all packages for maestro-server');
    delete process.env.WORK_TOP;
    await exec('npm install');

    // 4.9. Rename index.js to maestro-server so we won't need to create binary
    await exec('mv index.js maestro-server');

    // 4.10. Clean up all .git dirs to save space
    exec(`find ${options.build_dir} -name .git | xargs rm -rf`);

  }

  // 5. Create SOURCEME 
  let sourceme = `
# Source this file to set all necessary pointers to this custom Maestro product image
source /engr/dev/releases/maestro/build/tools/setup_maestro --build_dir ${options.build_dir}
`;

  fs.writeFileSync(`${options.build_dir}/SOURCEME`, sourceme, {encoding: 'utf8'});

  console.log(`
-----------------------------------------------------------------------
How to use this custom build
-----------------------------------------------------------------------

To setup environment so maestro/run_maestro will pick your custom build:
 setup_maestro --build_dir ${options.build_dir}

To test one Ncore config:
  maestro -c -s $MAESTRO_EXAMPLES/hw_config_02/hw_config_02.tcl

To test one Symphony config
  maestro -c -s $MAESTRO_HOME/tests/cases/test_tcl/hw_config_sym/hw_config_sym_05/samsung_1x1_downsizer.tcl

To run checkin_test:
  export WORK_TOP=$REPO_PATH/hw-ncr
  $WORK_TOP/dv/scripts/checkin_test -n -l -o -p

Waiting for all background processes to complete...
`);
  
})();
