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
// 0.2.4 - ChiAiu reference value updates, empty values allowed in some cases

//
// This file contains helper functions for parameter coverage
//

const XLSX = require( "xlsx" )
const noop = () => { }

// global so all functions have access
let maxRange = 256 // maximum range before splitting it
let splitRange = 16 // number of values to have after splitting a large range

// start top.level.dv.json restructuring
// don't process these keys in any structures, this list may need scrubbing
let ignoreKeys = [ "project_name", "ncore_version", "randomizer_version", "comment" ]
ignoreKeys.push( "description", "name", "InterleaveInfo", "MemoryGeneration" )
ignoreKeys.push( "postmap", "kind", "type", "title", "readOnly", "description", "_comments_" )
ignoreKeys.push( "default", "min", "max", "minItems", "maxItems", "unit" )
ignoreKeys.push( "TagMem", "RpMem", "synonyms", "CachingAgentsLpIds", "engVerId" )
ignoreKeys.push( "memoryInt", "chiCmd", "concMuxMsgParams", "cmType", "strRtlNamePrefix" )
ignoreKeys.push( "concParams" )
// look at these lines once top.level.dv.json format is finalized
// ignoreKeys.push("AiuInfo"); // comment for 3.6, uncomment for 3.7
// ignoreKeys.push("ChiaiuInfo", "IoaiuInfo") // uncomment for 3.6, comment for 3.7
// end of top.level.dv.json restructuring
exports.ignoreKeys = ignoreKeys

// some values can be empty, list the keys here
let emptyKeyAllowed = [ "qosMap" ]

let summaries = {} // needed by traverseAndCompare and compareParameters

//
// Exported Functions
//
function compareParameters( referenceJson, foundJson ) {

    summaries = {}

    if ( Array.isArray( foundJson ) ) {
        foundJson.forEach( found => { traverseAndCompare( referenceJson, found ) } )
    } else {
        traverseAndCompare( referenceJson, foundJson )
    }

    // Make foundValues and illegalValues unique and sorted, then calculate notFoundValues, counts, and percentages
    for ( let key in summaries ) {
        let summary = summaries[ key ]
        let isHex = false
        if ( key.toUpperCase().includes( "HEX" ) ) { isHex = true }

        if ( summary.foundValues.toString().includes( "'h" ) |
            summary.notFoundValues.toString().includes( "'h" ) |
            summary.illegalValues.toString().includes( ":" ) ) { isHex = true }

        if ( summary.foundValues.toString().includes( ":" ) ) {
            summary.foundValues = convertFromRange( summary.foundValues )
        }
        summary.foundValues = [ ...new Set( summary.foundValues ) ].sort( ( a, b ) => a - b )
        let foundCount = summary.foundValues.length

        if ( emptyKeyAllowed.includes( key.split( "." )[ 2 ] ) && foundCount === 0 ) {
            console.log
            summary.foundValues = [ "empty" ]
            foundCount += 1
        }

        if ( isHex ) {
            for ( item in summary.foundValues ) {
                summary.foundValues[ item ] = convertFromHex( summary.foundValues[ item ] )
            }
        }
        summary.foundValues = convertToRange( summary.foundValues )
        if ( isHex ) {
            for ( item in summary.foundValues ) {
                summary.foundValues[ item ] = convertToHex( summary.foundValues[ item ] )
            }
        }

        if ( summary.notFoundValues.toString().includes( ":" ) ) {
            summary.notFoundValues = convertFromRange( summary.notFoundValues )
        }
        summary.notFoundValues = [ ...new Set( summary.notFoundValues ) ].sort( ( a, b ) => a - b )
        let notFoundCount = summary.notFoundValues.length
        if ( isHex ) {
            for ( item in summary.notFoundValues ) {
                summary.notFoundValues[ item ] = convertFromHex( summary.notFoundValues[ item ] )
            }
        }
        summary.notFoundValues = convertToRange( summary.notFoundValues )
        if ( isHex ) {
            for ( item in summary.notFoundValues ) {
                summary.notFoundValues[ item ] = convertToHex( summary.notFoundValues[ item ] )
            }
        }

        summary.illegalValues = [ ...new Set( summary.illegalValues ) ].sort( ( a, b ) => a - b )
        if ( isHex ) {
            for ( item in summary.illegalValues ) {
                summary.illegalValues[ item ] = convertFromHex( summary.illegalValues[ item ] )
            }
        }
        summary.illegalValues = convertToRange( summary.illegalValues )
        if ( isHex ) {
            for ( item in summary.illegalValues ) {
                summary.illegalValues[ item ] = convertToHex( summary.illegalValues[ item ] )
            }
        }

        summary.percentage = foundCount === 0 && notFoundCount === 0 ? '0.00' : Number( foundCount / ( foundCount + notFoundCount ) * 100 ).toFixed( 2 )

        if ( foundCount === 0 ) { // && !emptyKeyAllowed.includes( key.split( "." )[ 2 ] ) ) {
            summary.foundValues = {
                count: foundCount,
                values: [ 'ref param not in actual' ]
            }
        } else {
            summary.foundValues = {
                count: foundCount,
                values: summary.foundValues.length > 0 ? convertToRange( summary.foundValues ) : []
            }
        }
        summary.notFoundValues = {
            count: notFoundCount,
            values: summary.notFoundValues != "undefined" ? convertToRange( summary.notFoundValues ) : []
        }
        summary.foundIllegal = {
            count: summary.illegalValues.length,
            values: summary.illegalValues != "undefined" ? convertToRange( summary.illegalValues ) : []
        }

        delete summary.refValues
        delete summary.illegalValues
    }

    // Convert the flat structure to nested structure for the top level
    let nestedSummaries = {}
    for ( let key in summaries ) {
        let [ topLevelKey, ...restOfKeys ] = key.split( '.' )
        if ( topLevelKey == "premap" ) { // account for using Maestro user parameter JSON, may remove later
            topLevelKey = restOfKeys.shift()
        } else {
            topLevelKey = topLevelKey.replace( "Info", "" )
        }
        if ( !nestedSummaries[ topLevelKey ] ) {
            nestedSummaries[ topLevelKey ] = {}
        }
        nestedSummaries[ topLevelKey ][ restOfKeys.join( '.' ).replace( "items.", "" ).replace( ".allowableValues", "" ) ] = summaries[ key ]
    }

    for ( key in nestedSummaries ) {
        nestedSummaries[ key ] = sortByKey( nestedSummaries[ key ] )
    }

    nestedSummaries = sortByKey( nestedSummaries )

    return nestedSummaries
}
exports.compareParameters = compareParameters

function jsonToCsv( json ) {
    let csv = 'Parameter,Coverage,Found,Not Found,Illegal\n'
    function traverse( obj, path ) {
        if ( typeof obj === 'object' && !Array.isArray( obj ) ) {
            let keys = Object.keys( obj )
            if ( keys.includes( 'foundValues' ) && keys.includes( 'notFoundValues' ) && keys.includes( 'percentage' ) && keys.includes( 'foundIllegal' ) ) {
                csv += `\n${ path },"${ obj.percentage }","${ obj.foundValues.values }","${ obj.notFoundValues.values }","${ obj.foundIllegal.values }"`
                csv += ``
            } else {
                for ( let key in obj ) {
                    traverse( obj[ key ], path ? `${ path }.${ key }` : key )
                }
            }
        }
    }
    traverse( json, '' )
    return csv
}
exports.jsonToCsv = jsonToCsv

function jsonToXlsx( json, filename ) {
    const workbook = XLSX.utils.book_new()
    for ( let sheetName in json ) {
        let data = []
        data.push( [ "Parameter", "Coverage", "Found", "Not Found", "Illegal" ] )
        function traverse( obj, path ) {
            if ( typeof obj === 'object' && !Array.isArray( obj ) ) {
                let keys = Object.keys( obj )
                if ( keys.includes( 'foundValues' ) &&
                    keys.includes( 'notFoundValues' ) &&
                    keys.includes( 'percentage' ) &&
                    keys.includes( 'foundIllegal' ) ) {
                    let row = Array( 5 ).fill( '' )
                    row[ 0 ] = path
                    row[ 1 ] = obj.percentage
                    row[ 2 ] = obj.foundValues.values.join( ', ' )
                    row[ 3 ] = obj.notFoundValues.values.join( ', ' )
                    row[ 4 ] = obj.foundIllegal.values.join( ', ' )
                    data.push( row )
                } else {
                    for ( let key in obj ) {
                        traverse( obj[ key ], path ? `${ path }.${ key }` : key )
                    }
                }
            }
        }
        traverse( json[ sheetName ], '' )
        const worksheet = XLSX.utils.aoa_to_sheet( data )
        XLSX.utils.book_append_sheet( workbook, worksheet, sheetName )
    }
    XLSX.writeFile( workbook, filename )
}
exports.jsonToXlsx = jsonToXlsx

function list( val ) {
    // needed by commander list option
    return ( val.split( ',' ) )
}
exports.list = list

function mergeResults( newJson, baseJson ) {
    baseJson = JSON.parse( baseJson )

    for ( key in baseJson ) {

        if ( key == "ignoredKeys" ) {
            continue
        }
        if ( typeof newJson[ key ] == "undefined" ) {
            console.log( `${ key } not in new data, ignoring` )
            continue
        }
        if ( key != "numFiles" ) {
            baseJson[ key ] = mergeBlock( baseJson[ key ], newJson[ key ] )
        } else {
            baseJson[ key ] += newJson[ key ]
        }
    }
    return baseJson
}
exports.mergeResults = mergeResults


//
// Local functions
//

function mergeBlock( referenceBlock, newBlock ) {

    let isHex = false
    regexp = /^[a-fA-F]+$/ // try to figure out hex values without 'h or 0x

    function convertBlockValues( thisBlockValue ) {
        // let isHex = false;
        if ( thisBlockValue.toString().includes( "'h" ) ) { isHex = true };
        if ( thisBlockValue.toString().includes( ':' ) ) {
            let tVals = []
            for ( element in thisBlockValue ) {
                if ( thisBlockValue[ element ].includes( ":" ) ) {
                    tVals = [ ...tVals, ...convertFromRange( convertFromHex( thisBlockValue[ element ] ) ) ]
                } else if ( regexp.test( thisBlockValue[ element ] ) & thisBlockValue[ element ] != "ecc"
                    | isHex ) {
                    tVals = [ ...tVals, convertFromHex( `'h${ thisBlockValue[ element ] }` ) ]
                } else {
                    tVals = [ ...tVals, ...thisBlockValue[ element ] ]
                }
            }
            tVals = tVals.map( Number )
            thisBlockValue = [ ...new Set( tVals ) ].sort( ( a, b ) => a - b )
        } else if ( isHex ) {
            for ( element in thisBlockValue ) {
                thisBlockValue[ element ] = convertFromHex( thisBlockValue[ element ] )
            }
        }
        return [ ...new Set( thisBlockValue.map( String ) ) ]
    }

    // Iterate over each key in the new data
    for ( let key in newBlock ) {
        // If the key is also in the reference data'
        isHex = false
        if ( key in referenceBlock ) {
            // Get the values from the new data
            let newFoundValues = convertBlockValues( newBlock[ key ][ 'foundValues' ][ 'values' ].map( String ) )
            let newNotFoundValues = convertBlockValues( newBlock[ key ][ 'notFoundValues' ][ 'values' ].map( String ) )
            let newFoundIllegal = convertBlockValues( newBlock[ key ][ 'foundIllegal' ][ 'values' ].map( String ) )

            // Get the values from the reference data
            let refFoundValues = convertBlockValues( referenceBlock[ key ][ 'foundValues' ][ 'values' ].map( String ) )
            let refNotFoundValues = convertBlockValues( referenceBlock[ key ][ 'notFoundValues' ][ 'values' ].map( String ) )
            let refFoundIllegal = convertBlockValues( referenceBlock[ key ][ 'foundIllegal' ][ 'values' ].map( String ) )

            // force 0/1 to boolean if old or new has true or false.  Older versions of paramter spec had 0/1 instead of true/false
            if ( newFoundValues.includes( "true" ) || newFoundValues.includes( "false" ) ||
                refFoundValues.includes( "true" ) || refFoundValues.includes( "false" ) ) {
                // newFoundValues = newFoundValues.map(Boolean).map(String);
                // newNotFoundValues = newNotFoundValues.map(Boolean).map(String);
                refFoundValues = refFoundValues.map( Boolean ).map( String )
                refNotFoundValues = refNotFoundValues.map( Boolean ).map( String )
            }

            // Iterate over each value in the new foundValues
            for ( let value of newFoundValues ) {
                // If the value is not in the reference foundValues
                if ( !refFoundValues.includes( value ) ) {
                    // Add the value to the reference foundValues and sort the result
                    refFoundValues.push( value )
                    refFoundValues.sort()

                    // we now have an actual value so remove "ref param not in actual"
                    let index = refFoundValues.indexOf( 'ref param not in actual' )
                    if ( index !== -1 ) {
                        refFoundValues.splice( index, 1 )
                    }
                }
                // If the value is in the reference notFoundValues, remove it
                index = refNotFoundValues.indexOf( value )
                if ( index !== -1 ) {
                    refNotFoundValues.splice( index, 1 )
                }
            }

            // Iterate over each value in the new notFoundValues
            for ( let value of newNotFoundValues ) {
                // If the value is not in the reference notFoundValuea and foundValues
                if ( !refNotFoundValues.includes( value ) & !refFoundValues.includes( value ) ) {
                    // Add the value to the reference notFoundValues and sort the result
                    refNotFoundValues.push( value )
                } else if ( refNotFoundValues.includes( value ) & refFoundValues.includes( value ) ) {
                    // Make sure to take it out if it's there and in found
                    refNotFoundValues.splice( refNotFoundValues.indexOf( value ), 1 )
                }
            }

            // Iterate over each value in the new foundIllegal values
            for ( let value of newFoundIllegal ) {
                // If the value is not in the reference foundIllegal

                if ( !refFoundIllegal.includes( value ) ) {
                    // Add the value to the reference notFoundValues and sort the result
                    refFoundIllegal.push( regexp.test( value ) ? convertFromHex( `'h${ value }` ) : value )
                }
            }

            // Update Illegal Values
            refFoundIllegal = [ ...new Set( refFoundIllegal ) ].sort( ( a, b ) => a - b )
            referenceBlock[ key ][ 'foundIllegal' ][ 'count' ] = refFoundIllegal.length
            refFoundIllegal = refFoundIllegal.length != 0 ? convertToRange( refFoundIllegal ) : []
            referenceBlock[ key ][ 'foundIllegal' ][ 'values' ] = isHex ? convertToHex( refFoundIllegal ) : refFoundIllegal

            // Update Found values
            refFoundValues = [ ...new Set( refFoundValues ) ].sort( ( a, b ) => a - b )
            const fCount = !refFoundValues.includes( "ref param not in actual" ) ? refFoundValues.length : 0
            referenceBlock[ key ][ 'foundValues' ][ 'count' ] = fCount
            refFoundValues = fCount != 0 ? convertToRange( refFoundValues ) : refFoundValues
            referenceBlock[ key ][ 'foundValues' ][ 'values' ] = isHex ? convertToHex( refFoundValues ) : refFoundValues

            // Update Not Found values
            refNotFoundValues = [ ...new Set( refNotFoundValues ) ].sort( ( a, b ) => a - b )
            const nfCount = refNotFoundValues.length
            referenceBlock[ key ][ 'notFoundValues' ][ 'count' ] = nfCount
            refNotFoundValues = nfCount != 0 ? convertToRange( refNotFoundValues ) : []
            referenceBlock[ key ][ 'notFoundValues' ][ 'values' ] = isHex ? convertToHex( refNotFoundValues ) : refNotFoundValues

            // Update % coverage
            referenceBlock[ key ][ 'percentage' ] = ( fCount + nfCount ) != 0 ? ( fCount / ( fCount + nfCount ) * 100 ).toFixed( 2 ) : "0.00"
        }
    }

    // Return the merged data
    return referenceBlock
}

function convertFromBinary( binaryValue ) {
    // convertFromHex converts binary strings to decimal numbers
    // required input:  binaryValue
    // is one of the following or an object containing any number of the following:
    // - a single decimal integer containing 0's and/or 1's: this is treated as a binary number
    // - a string with a binay number preceeded by 'b or 0b 
    // - a string with 2 (binary and/or apparently decimal) numbers separated by : (a range)
    // NOTE: all input values that appear to be decimal are treated as hexidecimal!
    // e.g. 10 is treated as 0b10, 10:111 is 0b10:0b111, 10:0b111 is 0b10:0b111 etc
    // 
    // output: a decimal string equivalent of the input value

    switch ( typeof binaryValue ) {
        case "object":
            let tString = []
            for ( item in binaryValue ) {
                tString.push( convertFromHex( binaryValue[ item ] ) )
            }
            return tString

        case "number":
            return Number( BigInt( `0b${ binaryValue }` ).toString( 10 ) )

        case "string":
            binaryValue = binaryValue.replace( "_", "" )
            if ( binaryValue.includes( ":" ) ) {
                left = convertFromBinary( binaryValue.split( ":" )[ 0 ] )
                right = convertFromBinary( binaryValue.split( ":" )[ 1 ] )
                return `${ left }:${ right }`
            } else if ( binaryValue.includes( "?" ) ) {
                convertFromBinary( `${ binaryValue.replace( "?", "0" ) }:${ binaryValue.replace( "?", "1" ) }` )
            } else {
                let tString = binaryValue.split( "'b" )
                return Number( BigInt( `0b${ tString[ tString.length - 1 ] }` ).toString( 10 ) )
            }
        default:
            console.log( `Houston, we have a problem!  Unknown type ${ typeof binaryValue } passed to convertFromBinary` )
            return NaN
    }
}

function convertToBinary( decimalNumber ) {
    // function assumes that number is one of or an object containing any number of:
    // - a single base-10 integer
    // - a string representing a single base-10 integer
    // - a string of two single base-10 integers separated by : (a range)
    // any other value passed will cause an error or erroneous results
    // input: decimalNumber (required)
    // output: binary representation of the input
    switch ( typeof decimalNumber ) {
        case "object":
            let tBinary = []
            for ( item in decimalNumber ) {
                tBinary.push( convertToHex( decimalNumber[ item ] ) )
            }
            return tBinary
        case "number":
            return `'b${ BigInt( decimalNumber ).toString( 2 ).toUpperCase() }`
        case "string":
            if ( decimalNumber.includes( "'b" ) ) {
                return decimalNumber
            } else if ( decimalNumber.includes( ":" ) ) {
                let left = convertToHex( decimalNumber.split( ":" )[ 0 ] )
                let right = convertToHex( decimalNumber.split( ":" )[ 1 ] )
                return `${ left }:${ right }`
            } else {
                try {
                    return `'b${ BigInt( decimalNumber ).toString( 2 ).toUpperCase() }`
                } catch ( SyntaxError ) {
                    return ( decimalNumber )
                }
            }
        case "default":
            console.log( `Houston, we have a problem!  Unknown type ${ typeof decimalNumber } passed to convertToBinary` )
            return NaN
    }
}

function convertToDecStr( val ) {
    // converts a string input to an output string representation of a decimal
    // number.
    // Input:  val - required.  String of decimal or hex or binary.  Can not mix
    //         hex and binary. If hex or binary, that is assumed for decimal appearing
    //         strings.
    // Output: decimal representation of input. NaN of both hex and binary detected
    if ( typeof val == "number" | typeof val == "boolean" | typeof val == "object" | val == undefined ) { return val }

    let isHex = val.includes( "'h" )
    let isBinary = val.includes( "'b" )
    if ( isHex & isBinary ) { return NaN }

    if ( isHex ) {
        val = `0x${ val.split( "'h" )[ 1 ] }`
        return BigInt( val ).toString( 10 )
        // TODO: handle binary
        // } else if (isBinary) {
        //     val = `0b${val.split("'b")[1]}`;
        //     return BigInt(val).toString(10);
    } else {
        return val
    }

}

function convertFromHex( hexValue ) {
    // convertFromHex converts hexadecimal strings to decimal numbers
    // required input:  hexValue
    // is one of the following or an object containing any number of the following:
    // - a single decimal integer number: this is treated as a hexadecimal number
    // - a string with a hexidecimal number preceeded by 'h or 0x 
    // - a string with 2 (hexadecimal and/or apparently decimal) numbers separated by : (a range)
    // NOYE: all input values that appear to be decimal are treated as hexidecimal!
    // e.g. 10 is treated as 0x10, 10:21 is 0x10:0x21, 10:0x21 is 0x10:0x21 etc
    // 
    // output:
    // one of the following or an object containing the following:
    // - a single 

    // this helps capture the corner cases where a hex value is passed without
    // the 'h prefix and the value passed is a non-hex value.  Note that ecc is
    // used as a non-hex value so we may need to account for it later.  So far,
    // other code tries to make sure only expected hex values are coded.
    if ( !hexValue.toString().includes( "'h" ) & !( /^[0-9a-fA-F]+$/ ).test( hexValue ) ) {
        return hexValue
    }

    switch ( typeof hexValue ) {
        case "object":
            let tString = []
            for ( item in hexValue ) {
                tString.push( convertFromHex( hexValue[ item ] ) )
            }
            return tString

        case "number":
            return parseInt( hexValue, 10 )

        case "string":
            if ( hexValue.includes( ":" ) ) {
                left = BigInt( hexValue.split( ":" )[ 0 ].replace( /\S*'h/gi, '0x' ) ).toString( 10 )
                right = BigInt( hexValue.split( ":" )[ 1 ].replace( /\S*'h/gi, '0x' ) ).toString( 10 )
                return `${ left }:${ right }`
            } else if ( ( /(^|[^h])[0-9A-Fa-f]+/g ).test( hexValue ) ) {
                return BigInt( `0x${ hexValue.replace( /\S*'h/gi, '' ) }` ).toString( 10 )
            } else {
                return BigInt( hexValue.replace( /\S*'h/gi, '0x' ) ).toString( 10 )
            }
        default:
            console.log( `Houston, we have a problem!  Unknown type ${ typeof hexValue } passed to convertFromHex` )
            return NaN
    }
}

function convertToHex( decimalNumber ) {
    // function assumes that number is one of or an object containing any number of:
    // - a single base-10 integer
    // - a string representing a single base-10 integer
    // - a string of two single base-10 integers separated by : (a range)
    // any other value passed will cause an error or erroneous results
    // input: decimalNumber (required)
    // output: a hexadecimal equivalent of the input value
    switch ( typeof decimalNumber ) {
        case "object":
            let tHex = []
            for ( item in decimalNumber ) {
                tHex.push( convertToHex( decimalNumber[ item ] ) )
            }
            return tHex
        case "number":
            return `'h${ BigInt( decimalNumber ).toString( 16 ).toUpperCase() }`
        case "string":
            if ( decimalNumber.includes( ":" ) ) {
                let left = convertToHex( decimalNumber.split( ":" )[ 0 ] )
                let right = convertToHex( decimalNumber.split( ":" )[ 1 ] )
                return `${ left }:${ right }`
            } else if ( decimalNumber.includes( "'h" ) ) {
                return decimalNumber
            } else {
                try {
                    return `'h${ BigInt( decimalNumber ).toString( 16 ).toUpperCase() }`
                } catch ( SyntaxError ) {
                    return ( decimalNumber )
                }
            }
        case "default":
            console.log( `Houston, we have a problem!  Unknown type ${ typeof decimalNumber } passed to convertToHex` )
            return NaN
    }
}

function convertFromRange( range ) {
    // converts ranges to an array of individual values with the same type as input
    // if a radix is found in the range, that radix is assumed through the range
    // e.g. 10:'h12 will expand to 32, 33, 34 and not 10, 11, 12, ..., 33, 34
    // input:  range (required)
    // output: array with range expanded to individual values
    let isHex = false
    let isBinary = false
    // if (!range.toString().includes(':')) {return range}; // not a range, just return
    if ( range.toString().includes( "'h" ) ) {
        isHex = true
        range.replace( /\'h/gi, '0x' )
    }
    // TODO: handle binary
    // if (range.toString().includes("'b")) {
    //     isBinary = true;
    //     range.replace(/\'h/gi, '0b');
    // }
    if ( isHex & isBinary ) {
        return NaN
    }

    let [ start, end ] = []
    if ( isHex ) {
        [ start, end ] = range.split( ':' )
        start = convertFromHex( start )
        if ( end == undefined ) {
            return [ start, start ]
        }
        end = convertFromHex( end )
    } else {
        [ start, end ] = range.split( ':' ).map( Number )
        if ( end == undefined ) {
            return [ start, start ]
        }
    }

    let thisArray = []
    if ( ( end - start ) < maxRange ) {
        thisArray = Array( end - start + 1 ).fill().map( ( _, idx ) => start + idx )
    } else {
        thisArray = [ start ]
        for ( let n = 1; n <= ( splitRange - 2 ); n++ ) {
            thisArray.push( start + n * Math.trunc( ( end - start ) / ( splitRange - 2 ) ) )
        }
        thisArray.push( end )
    }

    if ( isHex ) {
        for ( element in thisArray ) {
            // thisArray[element] = thisArray[element].toString(16).replace("0x","'h");
            thisArray[ element ] = `'h${ thisArray[ element ].toString( 16 ) }`
        }
    }
    // TODO: Handle binary
    // if (isHex | isBinary) {
    //     for (element in thisArray) {
    //         thisArray[element] = isHex ? thisArray[element].toString(16).replace("0x","'h") : thisArray[element].toString(2).replace("0b","'b");
    //     }
    // }
    return thisArray
}

function convertToRange( array ) {
    // takes in an array of values in any mixed radix: decimal, binary, hex
    // returns an array string values with ranges where possible

    if ( !Array.isArray( array ) ) { return array };
    let isHex = false
    if ( array.toString().includes( "'h" ) ) { isHex = true }

    if ( array.toString().includes( ":" ) ) {
        let tArr = []
        for ( let i = 0; i < array.length; i++ ) {
            if ( array[ i ].includes( ":" ) ) {
                tArr = tArr.concat( array[ i ].toString().includes( "'h" ) ? convertFromRange( convertFromHex( array[ i ] ) ) : convertFromRange( array[ i ] ) )
            } else {
                tArr.push( array[ i ] )
            }
        }
        array = tArr
    }

    array = array.sort( ( a, b ) => a - b )

    let ranges = []
    let start = convertToDecStr( array[ 0 ] )
    let end = start

    for ( let i = 1; i < array.length; i++ ) {
        if ( typeof array[ i ] == "boolean" ) { return array }
        if ( convertToDecStr( array[ i ] ) - end === 1 ) {
            end = convertToDecStr( array[ i ] )
        } else {
            if ( isHex ) {
                start = convertToHex( start )
                end = convertToHex( end )
            }
            ranges.push( start === end ? `${ start }` : `${ start }:${ end }` )
            start = convertToDecStr( array[ i ] )
            end = start
        }
    }

    // array = tArr;

    if ( isHex ) {
        start = convertToHex( start )
        end = convertToHex( end )
    }

    ranges.push( start === end ? `${ start }` : `${ start }:${ end }` )

    // try {
    //     start.map(Number);
    // } catch {
    //     return array;
    // } finally {
    return ranges
    // }
}

function sortByKey( myObj ) {
    tObj = Object.keys( myObj ).sort( ( a, b ) => a.toLowerCase().localeCompare( b.toLowerCase() ) ).reduce(
        ( obj, key ) => {
            obj[ key ] = myObj[ key ]
            return obj
        },
        {}
    )
    return tObj
}

function traverseAndCompare( ref, found, path = [] ) {
    for ( let key in ref ) {
        if ( ignoreKeys.includes( key ) ) {
            continue
        }
        if ( ref.hasOwnProperty( key ) ) {
            let newPath = [ ...path, key ]
            if ( typeof ref[ key ] === 'object' && !Array.isArray( ref[ key ] ) ) {
                if ( Array.isArray( found ) ) {
                    found.forEach( f => traverseAndCompare( ref[ key ], f && typeof f === 'object' ? f[ key ] || {} : {}, newPath ) )
                } else {
                    traverseAndCompare( ref[ key ], found && typeof found === 'object' ? found[ key ] || {} : {}, newPath )
                }
            } else {
                let refValues = Array.isArray( ref[ key ] ) ? ref[ key ] : [ ref[ key ] ]
                let isHex = false
                // let isBinary = false; // TODO: add binary support
                if ( refValues.toString().includes( "'h" ) ) {
                    isHex = true
                    let tVal = []
                    for ( item in refValues ) {
                        // if (refValues[item].toString().includes(":")) {
                        //     let left = convertFromHex(refValues[item].split(":")[0]);
                        //     let right = convertFromHex(refValues[item].split(":")[1]);
                        //     tVal.push(`${left}:${right}`);
                        // } else {
                        tVal.push( convertFromHex( refValues[ item ] ) )
                        // }
                    }
                    refValues = tVal
                }

                refValues = refValues.reduce( ( acc, val ) => acc.concat( typeof val === 'string' && val.includes( ':' ) ? convertFromRange( val ) : isNaN( parseInt( val ) ) ? val : parseInt( val ) ), [] )
                refValues = [ ...new Set( refValues ) ].sort( ( a, b ) => a - b )
                let foundValues = []
                let notFoundValues = []
                let illegalValues = []
                let values = []
                // TODO: Scrub this if-clause, it seems to work but it's wonky and likely doesn't work in 
                // ALL cases.  For instance, some values end up as a string instead of array of (string) values?
                if ( typeof found[ key ] == "object" && found[ key ] !== null ) {
                    for ( item in found[ key ] ) {
                        if ( found[ key ][ item ] !== undefined ) {
                            values.push( isHex ? convertFromHex( found[ key ][ item ] ) : found[ key ][ item ] )
                        }
                    }
                } else {
                    for ( item in found ) {
                        if ( !Array.isArray( found[ item ] ) ) {
                            if ( found[ key ] !== undefined ) {
                                values.push( isHex ? convertFromHex( found[ key ] ) : found[ key ] )
                            } else if ( found[ item ][ key ] !== undefined ) {
                                values.push( isHex ? convertFromHex( found[ item ][ key ] ) : found[ item ][ key ] )
                            }
                        }
                    }
                }

                if ( typeof refValues == "boolean" | typeof refValues[ 0 ] == "boolean" ) { values = [].concat.apply( [], values ).map( Boolean ) }
                values = values.reduce( ( acc, val ) => acc.concat( typeof val === 'string' && val.includes( ':' ) ? convertFromRange( val ) : isNaN( parseInt( val ) ) ? val : parseInt( val ) ), [] )
                values = [ ...new Set( values ) ].sort( ( a, b ) => a - b )

                foundValues.push( ...values.filter( val => refValues.includes( val ) ).sort( ( a, b ) => a - b ) )
                foundValues = [ ...new Set( foundValues ) ].sort( ( a, b ) => a - b )

                notFoundValues.push( ...refValues.filter( val => !values.includes( val ) ).sort( ( a, b ) => a - b ) )

                illegalValues.push( ...values.filter( val => !foundValues.includes( val ) ).sort( ( a, b ) => a - b ) )
                illegalValues = [ ...new Set( illegalValues ) ].sort( ( a, b ) => a - b )

                if ( isHex ) {
                    refValues = convertToHex( refValues )
                    foundValues = convertToHex( foundValues )
                    notFoundValues = convertToHex( notFoundValues )
                    illegalValues = convertToHex( illegalValues )
                }

                if ( !summaries[ newPath.join( '.' ) ] ) {
                    summaries[ newPath.join( '.' ) ] = {
                        refValues: refValues,
                        foundValues: foundValues,
                        notFoundValues: notFoundValues,
                        illegalValues: illegalValues
                    }
                } else {
                    foundValues = [ ...new Set( [ ...foundValues, ...summaries[ newPath.join( '.' ) ].foundValues ] ) ].sort( ( a, b ) => a - b )
                    summaries[ newPath.join( '.' ) ].foundValues = foundValues
                    notFoundValues = [ ...new Set( notFoundValues, summaries[ newPath.join( '.' ) ].notFoundValues ) ].sort( ( a, b ) => a - b )
                    notFoundValues = notFoundValues.filter( ( element ) => !summaries[ newPath.join( '.' ) ].foundValues.includes( element ) )
                    summaries[ newPath.join( '.' ) ].notFoundValues = notFoundValues
                    summaries[ newPath.join( '.' ) ].illegalValues.push( ...illegalValues )
                }
            }
        }
    }
}
