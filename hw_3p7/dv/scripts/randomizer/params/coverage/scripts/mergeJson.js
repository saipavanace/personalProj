const fs = require('fs');
const path = require('path');

// Enable/disable debug mode
const DEBUG = true;

/**
 * Print debug message if debug mode is enabled
 * @param {string} message - Message to print
 * @param {any} data - Optional data to display
 */
function debug(message, data = null) {
  if (DEBUG) {
    if (data) {
    //   console.log(`[DEBUG] ${message}:`, JSON.stringify(data, null, 2));
    } else {
    //   console.log(`[DEBUG] ${message}`);
    }
  }
}

/**
 * Check if correct command line arguments were provided
 * @returns {object} Object containing input file paths and output file path
 */
function validateArguments() {
  if (process.argv.length < 4) {
    console.error('Usage: node mergeJson.js <input1.html> <input2.html> ... <inputN.html> <output.html>');
    process.exit(1);
  }
  
  // Get all the input paths (all arguments except the first two and the last one)
  const inputPaths = process.argv.slice(2, process.argv.length - 1);
  // Get the output path (the last argument)
  const outputPath = process.argv[process.argv.length - 1];
  
  debug("Input and output paths", { inputPaths, outputPath });
  
  return { inputPaths, outputPath };
}

/**
 * Extract JSON data from an HTML file
 * @param {string} filePath - Path to the HTML file
 * @returns {object} Extracted JSON data
 */
function extractJsonFromHtml(filePath) {
  debug(`Extracting JSON from ${filePath}`);
  
  try {
    const htmlContent = fs.readFileSync(filePath, 'utf8');
    const jsonMatch = htmlContent.match(/window\.__INITIAL_DATA__ = (\[.+?\]);/s);
    
    if (!jsonMatch || !jsonMatch[1]) {
      throw new Error(`Could not find JSON data in ${filePath}`);
    }
    
    const extractedJson = JSON.parse(jsonMatch[1])[0];
    debug(`JSON extraction successful. Found ${Object.keys(extractedJson).length} top-level keys`);
    
    // Optional: Print categories found
    debug("Categories found", Object.keys(extractedJson).filter(key => key !== 'statistics'));
    
    return extractedJson;
  } catch (error) {
    console.error(`Error extracting JSON from ${filePath}:`, error.message);
    process.exit(1);
  }
}

/**
 * Merge bins from two parameter objects
 * @param {object} param1 - Parameter from first JSON
 * @param {object} param2 - Parameter from second JSON
 * @returns {object} Merged parameter
 */
function mergeParameterBins(param1, param2) {
  debug("Merging parameter bins");
  
  // Create maps of bin values for easier lookup
  const coveredMap1 = new Map();
  param1.coveredBins.forEach(bin => {
    const key = Object.keys(bin)[0];
    coveredMap1.set(key, bin[key]);
  });
  
  const coveredMap2 = new Map();
  param2.coveredBins.forEach(bin => {
    const key = Object.keys(bin)[0];
    coveredMap2.set(key, bin[key]);
  });
  
  debug(`Parameter has ${param1.coveredBins.length} covered bins and ${param1.uncoveredBins.length} uncovered bins in JSON1`);
  debug(`Parameter has ${param2.coveredBins.length} covered bins and ${param2.uncoveredBins.length} uncovered bins in JSON2`);
  
  // Find bins that are uncovered in param1 but covered in param2
  const mergedCoveredBins = [...param1.coveredBins];
  const newUncoveredBins = [];
  let newlyCoveredBins = 0;
  
  param1.uncoveredBins.forEach(bin => {
    const key = Object.keys(bin)[0];
    if (coveredMap2.has(key)) {
      // This bin is covered in param2, so add it to covered bins in the merged result
      mergedCoveredBins.push({ [key]: coveredMap2.get(key) });
      newlyCoveredBins++;
    } else {
      // Still uncovered, keep it in uncovered bins
      newUncoveredBins.push(bin);
    }
  });
  
  debug(`Found ${newlyCoveredBins} bins that are now covered`);
  debug(`Merged result: ${mergedCoveredBins.length} covered bins and ${newUncoveredBins.length} uncovered bins`);
  
  // Create merged parameter
  const mergedParam = {
    ...param1,
    coveredBins: mergedCoveredBins,
    uncoveredBins: newUncoveredBins
  };
  
  // Update totalCoverage percentage for this parameter
  const totalBins = mergedCoveredBins.length + newUncoveredBins.length;
  if (totalBins > 0) {
    const coveragePercentage = (mergedCoveredBins.length / totalBins * 100).toFixed(2);
    debug(`New coverage percentage: ${coveragePercentage}%`);
    mergedParam.totalCoverage = coveragePercentage;
  }
  
  return mergedParam;
}

/**
 * Merge item from two JSONs
 * @param {object} item1 - Item from first JSON
 * @param {object} item2 - Item from second JSON
 * @returns {object} Merged item
 */
function mergeItems(item1, item2) {
  debug("Merging items");
  
  const mergedItem = JSON.parse(JSON.stringify(item1)); // Deep clone item1
  
  // Iterate through each parameter in the item
  Object.keys(item1).forEach(param => {
    if (param === 'totalParams' || param === 'totalUniqueParams' || 
        param === 'totalCoverage' || param === 'totalUniqueCoverage') {
      return; // Skip these properties as they'll be recalculated
    }
    
    const param1 = item1[param];
    const param2 = item2[param];
    
    if (!param2) {
      debug(`Parameter ${param} not found in item2, skipping`);
      return; // Skip if param doesn't exist in item2
    }
    
    // Process covered and uncovered bins
    if (param1.coveredBins && param1.uncoveredBins && 
        param2.coveredBins && param2.uncoveredBins) {
      debug(`Processing parameter: ${param}`);
      mergedItem[param] = mergeParameterBins(param1, param2);
    }
  });
  
  return mergedItem;
}

/**
 * Recalculate statistics for an item
 * @param {object} item - Item to recalculate statistics for
 */
function recalculateItemStats(item) {
  debug("Recalculating item statistics");
    let totalBins = 0;
    let totalCoveredBins = 0;
    let uniqueBins = 0;
    let uniqueCoveredBins = 0;
    for(let i=1; i<item.length; i+=1) {
        let itemCoveredBins = 0;
        let itemBins = 0;
        Object.keys(item[i]).forEach((param) => {
            if (param !== 'totalParams' && param !== 'totalUniqueParams' && param !== 'totalCoverage' && param !== 'totalUniqueCoverage' && (item[i][param].coveredBins && item[i][param].uncoveredBins)) {
                totalBins += item[i][param].coveredBins.length + item[i][param].uncoveredBins.length;
                totalCoveredBins += item[i][param].coveredBins.length;
                itemBins += item[i][param].coveredBins.length + item[i][param].uncoveredBins.length;
                itemCoveredBins += item[i][param].coveredBins.length;
                item[i][param].totalCoverage = ((item[i][param].coveredBins.length)/(item[i][param].coveredBins.length + item[i][param].uncoveredBins.length)*100).toFixed(2);
            }
        });
        item[i].totalCoverage = ((itemCoveredBins)/(itemBins)*100).toFixed(2);
        item[i].totalUniqueCoverage = ((itemCoveredBins)/(itemBins)*100).toFixed(2);
    }
    Object.keys(item[0]).forEach((param) => {
        if (param !== 'totalParams' && param !== 'totalUniqueParams' && param !== 'totalCoverage' && param !== 'totalUniqueCoverage' && (item[0][param].coveredBins && item[0][param].uncoveredBins)) {
            uniqueBins += item[0][param].coveredBins.length + item[0][param].uncoveredBins.length;
            uniqueCoveredBins += item[0][param].coveredBins.length;
        }
    });
    item[0].totalUniqueCoverage = ((uniqueCoveredBins)/(uniqueBins)*100).toFixed(2);
    item[0].totalCoverage = (totalCoveredBins/totalBins*100).toFixed(2);
}

/**
 * Merge two JSONs
 * @param {object} json1 - First JSON
 * @param {object} json2 - Second JSON
 * @returns {object} Merged JSON
 */
function mergeBins(json1, json2) {
  const mergedJson = JSON.parse(JSON.stringify(json1)); // Deep clone json1
  
  // Iterate through each category (chi, cioaiu, dii, etc.)
  Object.keys(json1).forEach(category => {
    if (category === 'statistics') {
      return; // Skip statistics as mentioned
    }

    if (category === "metadata") {
        // Combine all elements from both metadata arrays
        mergedJson["metadata"] = json1.metadata.concat(json2.metadata);
    } else if (category === "uniqueParams") {
        // Handle uniqueParams specially - it's an array with one element
        if (Array.isArray(json1[category]) && json1[category].length > 0 && 
            Array.isArray(json2[category]) && json2[category].length > 0) {
            
            // Process the first (and only) element of uniqueParams array
            mergedJson[category][0] = mergeItems(json1[category][0], json2[category][0]);
            
            // Recalculate totalCoverage for uniqueParams
            let totalBins = 0;
            let coveredBins = 0;
            
            Object.keys(mergedJson[category][0]).forEach(param => {
                if (param !== 'totalParams' && param !== 'totalUniqueParams' && 
                    param !== 'totalCoverage' && param !== 'totalUniqueCoverage') {
                    
                    const paramObj = mergedJson[category][0][param];
                    if (paramObj && paramObj.coveredBins && paramObj.uncoveredBins) {
                        totalBins += paramObj.coveredBins.length + paramObj.uncoveredBins.length;
                        coveredBins += paramObj.coveredBins.length;
                    }
                }
            });
            
            if (totalBins > 0) {
                mergedJson[category][0].totalCoverage = (coveredBins / totalBins * 100).toFixed(2);
            } else {
                mergedJson[category][0].totalCoverage = "0.00";
            }
        }
    } else {
        // Process regular categories
        for (let i = 0; i < json1[category].length; i++) {
            const item1 = json1[category][i];
            const item2 = json2[category][i]; // Get the corresponding item from json2
            
            if (!item2) {
                continue; // Skip if no corresponding item in json2
            }
            
            mergedJson[category][i] = mergeItems(item1, item2);
        }
        recalculateItemStats(mergedJson[category]);
    }
  });
  
  // Recalculate overall statistics
  recalculateOverallStats(mergedJson);
  
  return mergedJson;
}

/**
 * Merge multiple JSONs
 * @param {Array<object>} jsons - Array of JSON objects to merge
 * @returns {object} Merged JSON
 */
function mergeMultipleJsons(jsons) {
  if (jsons.length === 0) {
    throw new Error("No JSON files provided for merging");
  }
  
  if (jsons.length === 1) {
    return jsons[0]; // If only one JSON, return it as is
  }
  
  // Start with the first JSON as base
  let mergedJson = jsons[0];
  
  // Merge each subsequent JSON into the result
  for (let i = 1; i < jsons.length; i++) {
    console.log(`Merging JSON ${i+1}/${jsons.length}...`);
    mergedJson = mergeBins(mergedJson, jsons[i]);
  }
  
  return mergedJson;
}

/**
 * Recalculate overall statistics
 * @param {object} json - JSON to recalculate statistics for
 * @returns {object} JSON with updated statistics
 */
function recalculateOverallStats(json) {
  // Keep track of the values we need to calculate overall statistics
  const stats = {
    totalParams: 0,
    totalUniqueParams: 0,
    totalCoveredParams: 0,
    totalCoveredUniqueParams: 0
  };
  
  // Use index 0 from each category as specified
  Object.keys(json).forEach(category => {
    if (category === 'statistics' || category === 'metadata') return;
    
    if (json[category] && json[category][0]) {
      const categoryItem = json[category][0];
      
      // Extract values from index 0
      const categoryTotalParams = parseInt(categoryItem.totalParams) || 0;
      const categoryUniqueParams = parseInt(categoryItem.totalUniqueParams) || 0;
      
      // Add to our statistics
      stats.totalParams += categoryTotalParams;
      stats.totalUniqueParams += categoryUniqueParams;
      
      // Calculate covered parameters
      if (categoryTotalParams > 0 && categoryItem.totalCoverage) {
        const coveragePercentage = parseFloat(categoryItem.totalCoverage) / 100;
        const coveredParams = Math.round(categoryTotalParams * coveragePercentage);
        stats.totalCoveredParams += coveredParams;
      }
      
      // Calculate covered unique parameters
      if (categoryUniqueParams > 0 && categoryItem.totalUniqueCoverage) {
        const uniqueCoveragePercentage = parseFloat(categoryItem.totalUniqueCoverage) / 100;
        const coveredUniqueParams = Math.round(categoryUniqueParams * uniqueCoveragePercentage);
        stats.totalCoveredUniqueParams += coveredUniqueParams;
      }
    }
  });
  
  // Calculate overall coverage percentages
  const totalCoveragePercentage = stats.totalParams > 0 
    ? (stats.totalCoveredParams / stats.totalParams * 100).toFixed(2)
    : "0.00";
    
  const totalUniqueCoveragePercentage = stats.totalUniqueParams > 0
    ? (stats.totalCoveredUniqueParams / stats.totalUniqueParams * 100).toFixed(2)
    : "0.00";
  
  // Update statistics
  json.statistics = {
    totalParams: stats.totalParams,
    totalUniqueParams: stats.totalUniqueParams,
    totalCoverage: totalCoveragePercentage,
    totalUniqueCoverage: totalUniqueCoveragePercentage
  };
  
  return json;
}

/**
 * Create output HTML with merged JSON
 * @param {string} inputHtmlPath - Path to the input HTML file
 * @param {string} outputHtmlPath - Path to the output HTML file
 * @param {object} mergedJson - Merged JSON to insert into the HTML
 */
function createOutputHtml(inputHtmlPath, outputHtmlPath, mergedJson) {
  try {
    const htmlContent = fs.readFileSync(inputHtmlPath, 'utf8');
    const jsonStr = JSON.stringify(mergedJson);
    
    // Replace the JSON data in the HTML
    const updatedHtml = htmlContent.replace(
      /window\.__INITIAL_DATA__ = (\[.+?\]);/s,
      `window.__INITIAL_DATA__ = [${jsonStr}];`
    );
    
    fs.writeFileSync(outputHtmlPath, updatedHtml);
    console.log(`Merged data successfully written to ${outputHtmlPath}`);
  } catch (error) {
    console.error(`Error creating output HTML:`, error.message);
    process.exit(1);
  }
}

/**
 * Main function to orchestrate the process
 */
function main() {
  console.log("=== JSON Merger for Coverage Data ===");
  
  try {
    // Validate and get input/output paths
    const { inputPaths, outputPath } = validateArguments();
    
    console.log(`Merging ${inputPaths.length} HTML files...`);
    
    // Extract JSON data from all input files
    const jsonObjects = [];
    for (let i = 0; i < inputPaths.length; i++) {
      const inputPath = inputPaths[i];
      console.log(`[${i+1}/${inputPaths.length}] Extracting JSON from ${inputPath}...`);
      const jsonData = extractJsonFromHtml(inputPath);
      jsonObjects.push(jsonData);
    }
    
    // Merge all JSON data
    console.log('Merging all JSON data...');
    const mergedJson = mergeMultipleJsons(jsonObjects);
    
    // Create output HTML
    console.log(`Creating output HTML at ${outputPath}...`);
    createOutputHtml(inputPaths[0], outputPath, mergedJson);
    
    console.log('Done!');
  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  }
}

// Run the main function
main();