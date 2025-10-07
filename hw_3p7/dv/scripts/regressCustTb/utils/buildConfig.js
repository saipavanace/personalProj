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

function buildConfig( config, tclLib, tclDir ) {

    // form the build command
    let myCmd = `run_maestro utd -ums true -ndj -sdj -g -cfg ${ tclLib } -mut ${ tclDir } |& tee ./runMaestro.log`

    // form the job command
    const jName = `cfg_${ config.split( '_' ).slice( 2 ).join( '_' ) }`

    const qsubCmd = `qsub -V -q long.q -cwd -terse -l h_rt=06:00:00 -S /bin/bash -N ${ jName } -b y `

    try {
        execSync( `${ qsubCmd } ${ myCmd }`, { encoding: 'utf-8' } )
    }
    catch ( error ) {
        console.error( `something went wrong creating from ${ config }:`, error )
        return -1
    }

    console.log( `building config ${ config }` )
    return 0
}

exports.buildConfig = buildConfig
