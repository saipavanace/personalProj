#!/engr/dev/tools/node/versions/node/v10.15.3/bin/node
//--------------------------------------------------------------------------------------
// Copyright(C) 2014-2024 Arteris, Inc. and its applicable subsidiaries.
// All rights reserved.
//
// Disclaimer: This release is not provided nor intended for any chip implementations, tapeouts, or other features of production releases. 
//
// These files and associated documentation is proprietary and confidential to
// Arteris, Inc. and its applicable subsidiaries. The files and documentation
// may only be used pursuant to the terms and conditions of a signed written
// license agreement with Arteris, Inc. or one of its subsidiaries.
// All other use, reproduction, modification, or distribution of the information
// contained in the files or the associated documentation is strictly prohibited.
// This product and its technology is protected by patents and other forms of 
// intellectual property protection.
//--------------------------------------------------------------------------------------

if ( !process.env.I_AM_IN_REGRESS ) {
    console.error( 'Do not run regressCustTb.js directly, run regressCustTb.sh instead' )
    process.exit()
}

const { buildConfig } = require( './utils/buildConfig' )
const { execSync } = require( 'child_process' )
const { execTb } = require( './utils/execTb' )
const fs = require( 'fs' )

// call with noCadence to avoid running xsim
let runXsim = true
if ( process.argv.slice( 2 ).includes( 'noCadence' ) ) { runXsim = false }
// call with noConfigBuild to avoid rebuilding configs
let configBuild = true
if ( process.argv.slice( 2 ).includes( 'noConfigBuild' ) ) { configBuild = false }
// call with noVcsBuild to avoid rebuilding simulation model
let simBuild = true
if ( process.argv.slice( 2 ).includes( 'noSimBuild' ) ) { simBuild = false }
// call with configOnly to do only config builds
let configOnly = false
if ( process.argv.slice( 2 ).includes( 'configOnly' ) ) { configOnly = true }

const workTop = process.env.WORK_TOP

// get the configs, build values, and build the configs
const vcsConfigs = [
    'hw_cfg_meye_q7_latest',
    'hw_config_sanity',
    'hw_config_nxpauto',
    'hw_config_tencent',
    'hw_config_transchip',
    'hw_config_scalinx_mpf',
    'hw_cfg_ncore37',
    'hw_config_resiltech_onlyCHI_B',
    'hw_cfg_tenstorrent_mpf',
    'hw_cfg_tenstorrent_apb',
    'hw_cfg_ultrarisc_mpf',
    'hw_config_intel',
    'hw_config_41'
]
const xsimConfigs = [
    'hw_config_scalinx_mpf',
    // 'hw_cfg_meye_q7_dii',
    'hw_config_meye_q7_dii',
    'hw_config_andes_mpf'
]
const vcsJson = JSON.parse( fs.readFileSync( `${ workTop }/dv/cust_tb/snps/tb/runsim_testlist.json`, 'utf-8' ) )
const xsimJson = JSON.parse( fs.readFileSync( `${ workTop }/dv/cust_tb/cdns/tb/runsim_testlist.json`, 'utf-8' ) )
let buildConfigs = vcsConfigs
if ( runXsim ) {
    buildConfigs = [ ...new Set( [ ...vcsConfigs, ...xsimConfigs ] ) ]
}
for ( let config in buildConfigs ) {
    let thisConfig = `${ buildConfigs[ config ] }`
    let thisTclLib = ''
    let thisTclDir = ''
    if ( vcsConfigs.includes( thisConfig ) ) {
        thisTclLib = vcsJson[ 'configlist' ][ `${ thisConfig }` ][ 'tcl_lib' ]
        thisTclDir = vcsJson[ 'configlist' ][ `${ thisConfig }` ][ 'tcl_dir' ]
    } else if ( xsimConfigs.includes( thisConfig ) && runXsim ) {
        thisTclLib = xsimJson[ 'configlist' ][ `${ thisConfig }` ][ 'tcl_lib' ]
        thisTclDir = xsimJson[ 'configlist' ][ `${ thisConfig }` ][ 'tcl_dir' ]
    } else {
        console.log( `skipping config ${ thisConfig }: not in snps or cdns testlists` )
        continue
    }
    if ( configBuild ) {
        const workingDir = `${ workTop }/debug/custTbReg/${ thisConfig }`
        if ( !fs.existsSync( workingDir ) ) {
            fs.mkdirSync( workingDir, { recursive: true } )
        }
        process.chdir( `${ workingDir }` )
        buildConfig( thisConfig, thisTclLib, thisTclDir )
    }
}

// build configuration
if ( configBuild ) {
    console.log( `config build jobs submitted, waiting for all to finish\n` )
    waitQ( 'cfg_' )
} else {
    console.log( 'config build jobs skipped\n' )
}

if ( configOnly ) {
    console.log( `config builds done in ${ workTop }/debug/custTbReg/` )
    process.exit()
}

// simulation build
if ( simBuild ) {
    for ( let config in buildConfigs ) {
        const thisConfig = buildConfigs[ config ]
        const workingDir = `${ workTop }/debug/custTbReg/${ thisConfig }`
        process.chdir( `${ workingDir }` )
        execTb( `${ workTop }`, `${ workingDir }`, 'build', `${ runXsim }` )
    }

    console.log( '\nsimulation build jobs submitted, waiting for all to finish\n' )
    waitQ( 'b_' )
}

// simulation run
for ( let config in buildConfigs ) {
    const thisConfig = buildConfigs[ config ]
    const workingDir = `${ workTop }/debug/custTbReg/${ thisConfig }`
    process.chdir( `${ workingDir }` )
    execTb( `${ workTop }`, `${ workingDir }`, 'run', `${ runXsim }` )
}

console.log( `\nsimulation run jobs submitted, waiting for all to finish or ^C to exit now` )
waitQ( 'r_' )

function waitQ( qName = "cfg_" ) {
    while ( execSync( `qstat | grep -v QRLOGIN | grep ${ qName } | wc -l` ).toString().trim() != '0' ) {
        execSync( 'sleep 10s' )
    }
}
