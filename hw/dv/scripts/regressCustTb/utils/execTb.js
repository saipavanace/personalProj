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

const { execSync } = require( 'child_process' )
const fs = require( 'fs' )

function execTb( basePath, configPath, action = null, runXsim = true ) {

    if ( !( action === 'build' || action === 'run' ) ) {
        console.error( `execTb( ${ basePath }, ${ configPath }, ${ action }, ${ runXsim })` )
        console.error( `illegal call, action was ${ action }... exiting function` )
        return -1
    }

    process.env.PROJ_HOME = `${ configPath }/output`
    const config = configPath.split( '/' )[ configPath.split( '/' ).length - 1 ]

    let simulators = [ 'vcs', 'xsim' ]
    if ( `${ runXsim }` === 'false' ) { simulators.pop() } // skip xsim if desired

    for ( sim in simulators ) {
        const thisSim = simulators[ sim ]

        // build the amba_vip lib if vcs AND it doesn't already exist
        if ( thisSim == 'vcs' && !fs.existsSync( `${ basePath }/debug/custTbReg/amba_vip` ) ) {
            console.log( "cant't find synopsys amba vip, building" )
            execSync( `$DESIGNWARE_HOME/bin/dw_vip_setup -path ${ basePath }/debug/custTbReg/amba_vip -e amba_svt/tb_chi_svt_uvm_basic_sys` )
        }

        // form the job command
        const jName = `${ action[ 0 ] }_${ thisSim[ 0 ] }_${ config.split( '_' ).slice( 2 ).join( '_' ) }`
        const oPath = ` ${ process.env.PROJ_HOME }/tb/${ thisSim }/${ action }/`
        const qsubCmd = `qsub -V -q long.q -cwd -terse -l h_rt=06:00:00 -S /bin/bash -N ${ jName } -e ${ oPath } -o ${ oPath } -b y `

        if ( !fs.existsSync( `${ process.env.PROJ_HOME }/tb/` ) ) {
            console.log( `couldn't   ${ action } ${ thisSim } for ${ config }, skipping` )
            continue
        } else {
            // make sure the output directories exist
            if ( !fs.existsSync( `${ oPath }` ) ) {
                execSync( `mkdir -p ${ oPath }` )
            }
            process.chdir( `${ process.env.PROJ_HOME }/tb/${ thisSim }` )
            console.log( `submitting ${ action } ${ thisSim } for ${ config }` )
            execSync( `${ qsubCmd } make ${ action }` )
        }
    }

}

exports.execTb = execTb
