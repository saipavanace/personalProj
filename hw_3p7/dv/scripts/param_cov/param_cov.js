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
// Version history:
// 0.1.0 - Initial commit against CONC-14332 3.7/develop
// 0.1.1 - formatting and typo fixes, moved file count into coverage json, html template updates
//         add todo list output, support randomizer, WIP new Json merge
// 0.1.2 - Randomizer parameter coverage supported (just point to proper reference
//         and input file types), still WIP new raw Json merge
// 0.1.3 - Account for strings as numbers (randomizer), Use new format for top.level.dv.json
//         merge new raw Json data into existing still WIP
// 0.1.4 - more error handling
// 0.1.5 - adapt to interim random json
// 0.1.6 - fix html template, fix help with no options, put functions in file, handle hex values
// 0.1.7 - fix found values in summary, preliminary merge code, updated some ref params
// 0.2.0 - first merge release, fixed results (found values, hex, ranges), added data to outputs
// 0.2.1 - hex and ranges work properly, mereg fixes for hex and boolean, 
//         data updates to reference_parameters.json, template.html improvements
// 0.2.2 - final fix for booleans in all cases
// 0.2.3 - formatting fixes, reference_parameters.json AIU and CLOCK updates
// 0.2.4 - ChiAiu reference values, empty values allowed in some cases


let cli = require( 'commander' )
const { execSync } = require( 'child_process' )
const fs = require( 'fs' )
const { list } = require( './utils/helper.js' )
const { jsonToCsv } = require( './utils/helper.js' )
const { jsonToXlsx } = require( './utils/helper.js' )
const { mergeResults } = require( './utils/helper.js' )
const { compareParameters } = require( './utils/helper.js' )
const { ignoreKeys } = require( './utils/helper.js' )

// local
const htmlTemplate = process.env.WORK_TOP + '/dv/scripts/param_cov/utils/template.html'
let jsonFile = 'top.level.dv.json'
let outFileName = 'coverage_results'
let refFileName = process.env.WORK_TOP + '/dv/scripts/param_cov/utils/reference_parameters.json'


// process the command line
cli
    .option( '-b, --jsonFile <string>', `specify a base filename with configuration data, default is: ${ jsonFile }` )
    .option( '-c, --csv', `create a csv output file, default is: ${ outFileName }.csv` )
    .option( '-d, --debug', 'specify this to print helpful debug information' )
    .option( '-f, --paramsListFile <string>', 'file containing a list of json files, paths allowed' )
    .option( '-j, --json', `create a json output file named: ${ outFileName }.json` )
    .option( '-l, --paramsList <items>', 'comma separated string of json files', list )
    .option( '-m, --merge <string>', `merge new raw results into existing results, provide the <path/>filename.ext to merge with` )
    .option( '-p, --paramsPath <string>', `path to look for ALL JSON files (be careful, use -b if needed)` )
    .option( '-o, --outFileName <string>', `override the output file name, default is: ${ outFileName }` )
    .option( '-r, --refFileName <string>', `specify a reference json file, default is: $WORK_TOP/dv/scripts/param_cov/utils/reference_parameters.json` )
    .option( '-t, --todo', 'list remaining work to do' )
    .option( '-w, --web', `create an html output file (and json), default is: ${ outFileName }.html` )
    .option( '-x, --xlsx', `create an Excel file, default is: ${ outFileName }.xlsx` )
    .version( '0.2.3' )
    .parse( process.argv )


// -t specified, list items on the todo list and exit
if ( cli.todo ) {
    console.log( "- populate proper reference values (WIP)" )
    console.log( "- add merging two existing coverage Jsons" )
    console.log( "- add cross-coverage" )
    console.log( "- discuss exclusions, implement -- esp invalid values that aren't really invalid" )
    console.log( "- consider counting number of times a value is seen" )
    console.log( "- discuss need for per-instance coverage" )
    process.exit()
}

// one and only one option of parameter files is expected, check for them
if ( !cli.paramsList && !cli.paramsListFile && !cli.paramsPath ) {
    let error = '\nERROR: parameter list required. Please pass in at least one .json file with -l or a file with paths to json files using -f or a path to json files with -p'
    console.log( error )
    cli.help()
} else if ( cli.paramsList && cli.paramsListFile || cli.paramsList && cli.paramsPath || cli.paramsListFile && cli.paramsPath ) {
    let error = 'only one of -f or -l or -p is allowed!'
    throw ( error )
}
// -b specified: override the base json file name to look for
if ( cli.jsonFile ) {
    jsonFile = cli.jsonFile
}
// -f specified: file containing a list of parameter files
if ( cli.paramsListFile ) {
    var paramsFiles = fs.readFileSync( cli.paramsListFile ).toString().split( '\n' )
}
// -l specified: comma separated list of one or more parameter files on command line 
if ( cli.paramsList ) {
    var paramsFiles = []
    for ( file in cli.paramsList ) {
        paramsFiles.push( cli.paramsList[ file ] )
    }
}
// -o specified: override the default output file name
if ( cli.outFileName ) {
    outFileName = cli.outFileName
}
// -p specified:  look for jsonFile in this path and below
if ( cli.paramsPath ) {
    if ( cli.jsonFile === undefined ) { // -b was not specified so look for any json
        if ( cli.debug ) {
            console.log( `NOTE: -j jsonFile_name not specified so ALL json files will be included.  This may` )
            console.log( `not be what you intend and may result in erroneous results.  Specify -j jsonFile_name to be safe.` )
        }
        var paramsFiles = execSync( `find ${ cli.paramsPath } -name "*.json"`, { encoding: 'utf-8' } ).toString().split( '\n' )
    } else { // -b was specified so use only that name in the search
        var paramsFiles = execSync( `find ${ cli.paramsPath } -name ${ jsonFile }`, { encoding: 'utf-8' } ).toString().split( '\n' )
    }
}
// -r specified: override the default reference json file name OR reference for merge
if ( cli.refFileName ) {
    referenceParametersJson = JSON.parse( fs.readFileSync( `${ cli.refFileName }`, 'utf-8' ) )
} else {
    referenceParametersJson = JSON.parse( fs.readFileSync( `${ refFileName }`, 'utf-8' ) )
}

// convert the list of files into an array of JSON objects even if only 1
let paramData = []
let numFiles = 0
paramsFiles.forEach( function ( elem ) {
    if ( elem != '' ) {
        numFiles += 1
        if ( cli.debug ) { console.log( "Processing: ", elem ) }
        paramData.push( JSON.parse( fs.readFileSync( elem, 'utf8' ) ) )
    }
} )

// compute the coverage and what is and isn't covered for each parameter
let result = compareParameters( referenceParametersJson, paramData )
// put some global results in the output
result[ "numFiles" ] = numFiles
result[ "ignoredKeys" ] = ignoreKeys.sort()

// -m specified, merge results
if ( cli.merge ) {
    merged = JSON.stringify( JSON.parse( fs.readFileSync( cli.merge, 'utf8' ) ), null, 3 )
    result = mergeResults( result, merged )
}

// -j specified without -w, create a Json file
if ( cli.json && !cli.web ) {
    try {
        fs.writeFileSync( `${ outFileName }.json`, JSON.stringify( result, null, 3 ) )
    } catch ( error ) {
        console.log( `Error creating ${ outFileName }.json` )
    }
}

// -d specified, create debug messages and dump Json to console
if ( cli.debug ) {
    // console.dir(result, { depth: null });
    console.log( `${ numFiles } files processed` )
}

// -w specified, create Json and html
if ( cli.web ) {
    try {
        fs.writeFileSync( `${ outFileName }.json`, JSON.stringify( result, null, 3 ) ) // write out json, we need it
        const htmlString = fs.readFileSync( htmlTemplate, 'utf8' )
        fs.writeFileSync( `${ outFileName }.html`, htmlString )
    } catch ( error ) {
        console.log( `Error creating ${ outFileName }.json or ${ outFileName }.html` )
    }
}

// -c specified, create a csv files
if ( cli.csv ) {
    try {
        fs.writeFileSync( `${ outFileName }.csv`, jsonToCsv( result ) )
    } catch ( error ) {
        console.error( `Error creating the file ${ outFileName }.csv :`, error )
    }
}


// -x specified, create an Excel workbook
if ( cli.xlsx ) {
    try {
        jsonToXlsx( result, `${ outFileName }.xlsx` )
    } catch ( error ) {
        console.error( `Error creating the file ${ outFileName }.xlsx :`, error )
    }
}
