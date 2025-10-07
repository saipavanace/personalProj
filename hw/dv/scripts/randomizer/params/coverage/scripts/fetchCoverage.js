const fs = require('fs').promises;
const { exec } = require('child_process');
const util = require('util');
const path = require('path');
const execPromise = util.promisify(exec);
const generateReport = require(`${process.env.RANDOMIZER_HOME}/params/coverage/scripts/generateReport.js`);


async function splitFileIntoSections(filePath) {
  let fileContent = await fs.readFile(filePath, 'utf-8');

  const firstOccurrence = fileContent.indexOf('Group Instance : param.params');
  
  if (firstOccurrence !== -1) {
    fileContent = fileContent.slice(firstOccurrence);
  } else {
    console.log("Warning: 'Group Instance : param.params' not found in the file.");
    return [];
  }

  const sections = fileContent.split(/(?=Group Instance : param\.params)/);

  const trimmedSections = sections.map(section => {
    section = section.trim();
    if (!section.startsWith('Group Instance : param.params')) {
      section = 'Group Instance : param.params' + section;
    }
    return section;
  });

  return trimmedSections;
}

function formatBinValue(value) {
    value = value.replace(/^valid_values_/, '');
    
    const singleValueMatch = value.match(/^valid_values\[(\d+)\]$/);
    if (singleValueMatch) {
      return singleValueMatch[1];
    }
    
    const rangeMatch = value.match(/^valid_values\[(\d+:\d+)\]$/);
    if (rangeMatch) {
      return `[${rangeMatch[1]}]`;
    }
    
    return value;
}

function parseSection(section) {
    const lines = section.split('\n');
    const result = {
        name: '',
        coveredBins: [],
        uncoveredBins: []
    };
  
    // Extract name from the first line
    const nameMatch = lines[0].match(/Group Instance : (.+)/);
    if (nameMatch) {
        if(nameMatch[1].includes("param.params.nMIGS")) return;
        const paths = nameMatch[1].split('.');
        if (!(/\[\d+\]/.test(paths[2]))) {
            paths[2] = `${paths[2]}[0]`;
            nameMatch[1] = paths.join('.');
        }
        result.name = nameMatch[1];
    }
  
    let processingUncovered = false;
    let processingCovered = false;
    let processingAllCovered = false;
    let doneUncoveredBins = false;
    let startUncoveredBins = false;
    let startCoveredBins = false;
    let startAllCoveredBins = false;
    let debug = false;

    // if(nameMatch[1] === 'param.params.structural[0].nDces.cg_values') {
    //     console.log('sai_debug: '+ JSON.stringify(lines, null, 2));
    //     debug = true;
    // }
  
    for (let i = 1; i < lines.length; i++) {
        const line = lines[i].trim().replace(/\r$/, '');
    
        // Check for the "all covered" case first
        if (line === 'Bins' && !doneUncoveredBins) {
            processingAllCovered = true;
            processingUncovered = false;
            continue;
        } else if(line === 'Bins' && doneUncoveredBins) {
            break;
        }

        if (processingAllCovered && line.startsWith('valid_values')) {
            const [name, count] = line.split(/\s+/);
            result.coveredBins.push({ [formatBinValue(name)]: parseInt(count) });
            startAllCoveredBins = true;
            continue;
        }

        if (startAllCoveredBins && !line.startsWith('valid_values')) {
            break;
        }

        // Check for uncovered Bins

        if (line.includes('Uncovered bins') && !doneUncoveredBins) {
            processingUncovered = true;
            processingCovered = false;
            continue;
        }else if (line.includes('Uncovered bins') && doneUncoveredBins) {
            break;
        }

        if (processingUncovered && line.startsWith('valid_values')) {
            const [name, count] = line.split(/\s+/);
            result.uncoveredBins.push({ [formatBinValue(name)]: parseInt(count) });
            startUncoveredBins = true;
            continue;
        }

        if (startUncoveredBins && !line.startsWith('valid_values')) {
            doneUncoveredBins = true;
            // continue;
        }

        // Check for Covered Bins
        if (line.includes('Covered bins') && !processingCovered) {
            processingCovered = true;
            processingUncovered = false;
            continue;
        }

        if (processingCovered && line.startsWith('valid_values')) {
            const [name, count] = line.split(/\s+/);
            result.coveredBins.push({ [formatBinValue(name)]: parseInt(count) });
            startCoveredBins = true;
            continue;
        }

        if (startCoveredBins && !line.startsWith('valid_values')) {
            break;
        }
    }
    // if (debug) {
    //     console.log('sai_debug result: '+ JSON.stringify(result));
    // }
    return result;
}

function applyWaivers(parsedSections, waivers = {}) {
    // Ensure we're working with objects, not strings
    const parsedJson = typeof parsedSections === 'string' ? JSON.parse(parsedSections) : parsedSections;
    const parsedWaivers = typeof waivers === 'string' ? JSON.parse(waivers) : waivers;
  
    function processNode(parsedNode, waiversNode) {
        if (typeof parsedNode !== 'object' || parsedNode === null) {
            return;
        }
  
        if (Array.isArray(parsedNode)) {
            parsedNode.forEach((item, index) => {
                if (!waiversNode[index]) {
                    waiversNode[index] = Array.isArray(item) ? [] : {};
                }
                processNode(item, waiversNode[index]);
            });
        } else {
            for (const key in parsedNode) {
                if (key === 'uncoveredBins') {
                    // console.log('Before waiver processing:', JSON.stringify(parsedNode, null, 2));
                    // console.log('Waiver data:', JSON.stringify(waiversNode, null, 2));
                    
                    if (!waiversNode[key]) {
                        waiversNode[key] = [];
                    }
                    if (!parsedNode['coveredBins']) {
                        parsedNode['coveredBins'] = [];
                    }
                    
                    for (let i = parsedNode[key].length - 1; i >= 0; i--) {
                        const bin = parsedNode[key][i];
                        if (!waiversNode[key][i]) {
                            waiversNode[key][i] = {};
                        }
                        for (const binKey in bin) {
                            // console.log(`Processing bin ${binKey}, waiver value:`, waiversNode[key][i][binKey]);
                            if (binKey in waiversNode[key][i]) {
                                if (waiversNode[key][i][binKey] === '1') {
                                    // console.log(`Moving bin ${binKey} to covered with value '0'`);
                                    parsedNode['coveredBins'].push({ [binKey]: '0' });
                                    parsedNode[key].splice(i, 1);
                                } else {
                                    parsedNode[key][i][binKey] = waiversNode[key][i][binKey];
                                }
                            } else {
                                waiversNode[key][i][binKey] = '0';
                            }
                        }
                    }
                    // console.log('After waiver processing:', JSON.stringify(parsedNode, null, 2));
                } else {
                    if (!(key in waiversNode)) {
                        waiversNode[key] = Array.isArray(parsedNode[key]) ? [] : {};
                    }
                    processNode(parsedNode[key], waiversNode[key]);
                }
            }
        }
    }
  
    const updatedJson = JSON.parse(JSON.stringify(parsedJson));
    const updatedWaivers = JSON.parse(JSON.stringify(parsedWaivers));
    processNode(updatedJson, updatedWaivers);
    return { updatedJson, updatedWaivers };
 }

function buildDatabase(parsedSections) {
    const database = {};
    parsedSections.forEach(section => {
        if(section) {
            const { name, coveredBins, uncoveredBins } = section;
            const parts = name.split('.')
                .filter(part => part !== 'param' && part !== 'cg_values');
            let current = database;
            parts.forEach((part, index) => {
                const match = part.match(/^(\w+)\[(\d+)\]$/);
                if (match) {
                    // Handle array case
                    const [, arrayName, arrayIndex] = match;
                    if (!current[arrayName]) {
                        current[arrayName] = [];
                    }
                    if (!current[arrayName][arrayIndex]) {
                        current[arrayName][arrayIndex] = {};
                    }
                    if (index === parts.length - 1) {
                        current[arrayName][arrayIndex] = {
                            coveredBins,
                            uncoveredBins
                        };
                    } else {
                        current = current[arrayName][arrayIndex];
                    }
                } else {
                    // Handle normal object case
                    if (!current[part]) {
                        current[part] = {};
                    }
                    if (index === parts.length - 1) {
                        current[part] = {
                            coveredBins,
                            uncoveredBins
                        };
                    } else {
                        current = current[part];
                    }
                }
            });
        }
    });
    return database;
}

async function writeFile(filePath, data) {
    try {
      await fs.writeFile(filePath, data, 'utf8');
      console.log(`File written successfully: ${filePath}`);
    } catch (error) {
      if (error.code === 'ENOENT') {
        throw new Error(`Directory not found: ${filePath}`);
      } else {
        throw error; // Re-throw other errors
      }
    }
  }

async function readFile(filePath, disableError=false) {
    try {
        const data = await fs.readFile(filePath, 'utf-8');
        return data;
    } catch (error) {
        if (!disableError) {
            if (error.code === 'ENOENT') {
                throw new Error(`File not found: ${filePath}`);
            } else {
                throw error;
            }
        } else {
            console.warn(`File not found: ${filePath}`);
        }
    }
}

function addUniqueParams(data) {
      // Create a map to store unique parameters and their coverage data
      const uniqueParamsMap = new Map();
      
      // Get all category keys in the record (structural, dce, dii, etc.)
      const categoryKeys = Object.keys(data.params).filter(key => key !== 'uniqueParams');
      
      // First pass: collect all unique parameters and their bins
      categoryKeys.forEach(categoryKey => {
        const category = data.params[categoryKey];
        // We only look at the first element (index 0) of each category array
        if (!category || !category[0]) return;
        
        const categoryData = category[0];
        
        // Get all parameter keys in this category (excluding metadata keys)
        const paramKeys = Object.keys(categoryData).filter(key => 
          key !== 'totalParams' && 
          key !== 'totalUniqueParams' && 
          key !== 'totalCoverage' &&
          key !== 'totalUniqueCoverage'
        );
        
        // Process each parameter
        paramKeys.forEach(paramKey => {
          const param = categoryData[paramKey];
          
          // If this parameter is not yet in our uniqueParams map, add it
          if (!uniqueParamsMap.has(paramKey)) {
            uniqueParamsMap.set(paramKey, {
              coveredBins: new Map(),
              uncoveredBins: new Map(),
              totalParams: param.totalParams,
              totalUniqueParams: param.totalUniqueParams,
              totalCoverage: param.totalCoverage
            });
          }
          
          const uniqueParam = uniqueParamsMap.get(paramKey);
          
          // Process covered bins
          if (param.coveredBins) {
            param.coveredBins.forEach(bin => {
              const binKey = Object.keys(bin)[0];
              const binValue = bin[binKey];
              uniqueParam.coveredBins.set(binKey, binValue);
              
              // If this bin was previously marked as uncovered, remove it
              uniqueParam.uncoveredBins.delete(binKey);
            });
          }
          
          // Process uncovered bins - only add if not already in covered
          if (param.uncoveredBins) {
            param.uncoveredBins.forEach(bin => {
              const binKey = Object.keys(bin)[0];
              // Only add to uncovered if not already in covered
              if (!uniqueParam.coveredBins.has(binKey)) {
                uniqueParam.uncoveredBins.set(binKey, bin[binKey]);
              }
            });
          }
        });
      });
      
      // Second pass: look through all categories for each parameter's uncovered bins
      // and see if those bins are covered in any other category
      categoryKeys.forEach(categoryKey => {
        const category = data.params[categoryKey];
        if (!category || !category[0]) return;
        
        const categoryData = category[0];
        
        const paramKeys = Object.keys(categoryData).filter(key => 
          key !== 'totalParams' && 
          key !== 'totalUniqueParams' && 
          key !== 'totalCoverage' &&
          key !== 'totalUniqueCoverage'
        );
        
        paramKeys.forEach(paramKey => {
          if (!uniqueParamsMap.has(paramKey)) return;
          
          const param = categoryData[paramKey];
          const uniqueParam = uniqueParamsMap.get(paramKey);
          
          // For each uncovered bin in the unique parameter
          const uncoveredBinKeys = Array.from(uniqueParam.uncoveredBins.keys());
          
          uncoveredBinKeys.forEach(binKey => {
            // Check if this bin is covered in the current category instance
            const isCovered = param.coveredBins && 
                             param.coveredBins.some(bin => Object.keys(bin)[0] === binKey);
            
            if (isCovered) {
              // Move this bin from uncovered to covered in the unique parameter
              const binValue = param.coveredBins.find(bin => Object.keys(bin)[0] === binKey)[binKey];
              uniqueParam.coveredBins.set(binKey, binValue);
              uniqueParam.uncoveredBins.delete(binKey);
            }
          });
        });
      });
      
      // Convert the uniqueParams map back to the required JSON format
      const uniqueParamsObject = {};
      let totalUniqueParams = 0;
      let totalParams = 0;
      let totalCoveredBins = 0;
      let totalBinCount = 0;
      
      uniqueParamsMap.forEach((paramData, paramKey) => {
        // Convert Maps back to arrays of objects
        const coveredBins = Array.from(paramData.coveredBins).map(([key, value]) => ({ [key]: value }));
        const uncoveredBins = Array.from(paramData.uncoveredBins).map(([key, value]) => ({ [key]: value }));
        
        // Calculate new coverage percentage based on merged bins
        const totalBins = coveredBins.length + uncoveredBins.length;
        const newCoverage = totalBins > 0 ? (coveredBins.length / totalBins * 100).toFixed(2) : "0.00";

        totalBinCount  += totalBins;
        totalCoveredBins += coveredBins.length;
        
        uniqueParamsObject[paramKey] = {
          coveredBins,
          uncoveredBins,
          totalParams: paramData.totalParams,
          totalUniqueParams: paramData.totalUniqueParams,
          totalCoverage: newCoverage
        };
        
        totalUniqueParams++;
        totalParams += paramData.totalParams;
        // totalCoverageSum += parseFloat(newCoverage);
      });
      
      // Add metadata for the uniqueParams category
    //   const avgCoverage = totalUniqueParams > 0 ? (totalCoverageSum / totalUniqueParams).toFixed(2) : "0.00";
      const avgCoverage = totalBinCount > 0 ? (totalCoveredBins / totalBinCount * 100).toFixed(2) : "0.00";
      
      uniqueParamsObject.totalParams = totalParams;
      uniqueParamsObject.totalUniqueParams = totalUniqueParams;
      uniqueParamsObject.totalCoverage = avgCoverage;
      uniqueParamsObject.totalUniqueCoverage = avgCoverage;
      
      // Add the uniqueParams category to the record
      data.params.uniqueParams = [uniqueParamsObject];
    
    return data;
  }

function addStatistics(data) {
    function processLeaf(node, name) {
      // Count all bins in coveredBins as covered, regardless of value ('1' for natural coverage, '0' for waiver coverage)
      const covered = (node.coveredBins || []).length;
      const uncovered = (node.uncoveredBins || []).length;
      const total = covered + uncovered;
      const coverage = total > 0 ? (covered / total * 100) : 0;
 
      const updatedNode = {
        ...node,
        totalParams: 1,
        totalUniqueParams: 1,
        totalCoverage: coverage.toFixed(2)
      };
 
      return { 
        node: updatedNode, 
        covered, 
        uncovered, 
        totalParams: 1, 
        uniqueParams: new Set([name]) 
      };
    }
 
    function processElement(element) {
      let totalCovered = 0;
      let totalUncovered = 0;
      let totalParams = 0;
      const uniqueParams = new Set();
      const updatedElement = {};
 
      for (const [param, value] of Object.entries(element)) {
        if (typeof value === 'object' && (value.coveredBins || value.uncoveredBins)) {
          const { node, covered, uncovered, totalParams: params, uniqueParams: unique } = processLeaf(value, param);
          updatedElement[param] = node;
          totalCovered += covered;
          totalUncovered += uncovered;
          totalParams += params;
          unique.forEach(p => uniqueParams.add(p));
        } else {
          updatedElement[param] = value;
        }
      }
 
      const total = totalCovered + totalUncovered;
      const coverage = total > 0 ? (totalCovered / total * 100) : 0;
 
      updatedElement.totalParams = totalParams;
      updatedElement.totalUniqueParams = uniqueParams.size;
      updatedElement.totalCoverage = coverage.toFixed(2);
 
      return { element: updatedElement, totalCovered, totalUncovered, totalParams, uniqueParams };
    }
 
    function mergeParams(elements) {
      // Get the first element as a template since all elements have the same params
      const firstElement = elements[0];
      const mergedParams = {};
      let totalUniqueCovered = 0;
      let totalUniqueBins = 0;
 
      // For each parameter in the first element
      for (const [param, value] of Object.entries(firstElement)) {
        if (typeof value === 'object' && (value.coveredBins || value.uncoveredBins)) {
          // Initialize merged bins tracking
          const coveredBinsMap = new Map();
          const allBins = new Set();
 
          // Process each element's coverage for this parameter
          elements.forEach(element => {
            const paramData = element[param];
            
            // Track all possible bins and their values
            paramData.coveredBins?.forEach(bin => {
                const binRange = Object.keys(bin)[0];
                const value = Object.values(bin)[0];
                allBins.add(binRange);
                coveredBinsMap.set(binRange, value);  // Store the actual value
            });
            
            paramData.uncoveredBins?.forEach(bin => {
              const binRange = Object.keys(bin)[0];
              allBins.add(binRange);
            });
          });
 
          // Create merged parameter data
          const coveredBins = [];
          const uncoveredBins = [];
 
          // Sort bins for consistent ordering
          const sortedBins = Array.from(allBins).sort();
          
          sortedBins.forEach(binRange => {
            if (coveredBinsMap.has(binRange)) {
                coveredBins.push({ [binRange]: coveredBinsMap.get(binRange) });  // Use stored value
            } else {
              uncoveredBins.push({ [binRange]: "0" });
            }
          });
 
          // Update unique coverage totals
          totalUniqueCovered += coveredBins.length;
          totalUniqueBins += sortedBins.length;
 
          // Calculate statistics for this merged parameter
          const totalBins = coveredBins.length + uncoveredBins.length;
          const coverage = totalBins > 0 ? (coveredBins.length / totalBins * 100) : 0;
 
          mergedParams[param] = {
            coveredBins,
            uncoveredBins,
            totalParams: 1,
            totalUniqueParams: 1,
            totalCoverage: coverage.toFixed(2)
          };
        }
      }
 
      // Calculate unique coverage percentage
      const uniqueCoverage = totalUniqueBins > 0 ? (totalUniqueCovered / totalUniqueBins * 100) : 0;
      return { 
        mergedParams, 
        totalUniqueCoverage: uniqueCoverage.toFixed(2) 
      };
    }
 
    function processCategory(category) {
      let totalCovered = 0;
      let totalUncovered = 0;
      let totalParams = 0;
      const uniqueParams = new Set();
      const updatedCategory = [];
 
      // Process each element in the category
      for (const element of category) {
        const { element: updatedElement, totalCovered: covered, totalUncovered: uncovered, totalParams: params, uniqueParams: unique } = processElement(element);
        updatedCategory.push(updatedElement);
        totalCovered += covered;
        totalUncovered += uncovered;
        totalParams += params;
        unique.forEach(p => uniqueParams.add(p));
      }
 
      const total = totalCovered + totalUncovered;
      const coverage = total > 0 ? (totalCovered / total * 100) : 0;
 
      // Get merged parameters and unique coverage
      const { mergedParams, totalUniqueCoverage } = mergeParams(category);
 
      // Create category stats with merged parameters
      const categoryStats = {
        ...mergedParams,
        totalParams,
        totalUniqueParams: uniqueParams.size,
        totalCoverage: coverage.toFixed(2),
        totalUniqueCoverage
      };
 
      updatedCategory.unshift(categoryStats);
 
      return { 
        category: updatedCategory, 
        totalCovered, 
        totalUncovered, 
        totalParams, 
        uniqueParams,
        totalUniqueCoverage 
      };
    }
 
    function processParams(params) {
      const updatedParams = {};
      let totalCovered = 0;
      let totalUncovered = 0;
      let totalParams = 0;
      let totalUniqueCoverageSum = 0;
      let totalCategories = 0;
      const uniqueParams = new Set();
 
      for (const [category, elements] of Object.entries(params)) {
        const { 
          category: updatedCategory, 
          totalCovered: covered, 
          totalUncovered: uncovered, 
          totalParams: params, 
          uniqueParams: unique,
          totalUniqueCoverage 
        } = processCategory(elements);
        
        updatedParams[category] = updatedCategory;
        totalCovered += covered;
        totalUncovered += uncovered;
        totalParams += params;
        totalUniqueCoverageSum += Number(totalUniqueCoverage);
        totalCategories++;
        unique.forEach(p => uniqueParams.add(p));
      }
 
      const total = totalCovered + totalUncovered;
      const coverage = total > 0 ? (totalCovered / total * 100) : 0;
      const averageUniqueCoverage = totalCategories > 0 ? (totalUniqueCoverageSum / totalCategories) : 0;
 
      updatedParams.statistics = {
        totalParams,
        totalUniqueParams: uniqueParams.size,
        totalCoverage: coverage.toFixed(2),
        totalUniqueCoverage: averageUniqueCoverage.toFixed(2)
      };
 
      return updatedParams;
    }
 
    const result = JSON.parse(JSON.stringify(data));
 
    if (result.params) {
      result.params = processParams(result.params);
    }
 
    return result;
}

const decodeFnNativeInterface = (intf, owo) => {
    //     string validValues[11] = '{"CHI-E", "CHI-B", "ACE", "ACE5", "AXI4", "AXI5", "ACE-Lite", "ACE5-Lite", "PCIe_ACE-Lite", "PCIe_AXI4", "PCIe_AXI5"};
    // return intf.replace(/_/g, '-');
    if (intf == 'CHI-E') return 'CHI_E';
    if (intf == 'CHI-B') return 'CHI_B';
    if (intf == 'ACE') return 'ACE';
    if (intf == 'ACE5') return 'ACE5';
    if (intf == 'AXI4' && owo == 'false') return 'AXI4';
    if (intf == 'AXI5' && owo == 'false') return 'AXI5';
    if (intf == 'ACE-LITE' && owo == 'false') return 'ACE_Lite';
    if (intf == 'ACELITE-E' && owo == 'false') return 'ACE5_Lite';
    if (intf == 'ACE-LITE' && owo == 'true') return 'PCIe_ACE_Lite';
    if (intf == 'AXI4' && owo == 'true') return 'PCIe_AXI4';
    if (intf == 'AXI5' && owo == 'true') return 'PCIe_AXI5';
}

const assignSvParams = (obj) => {
    let nChis = 0;
    let nCioaius = 0;
    let nNcioaius = 0;
    let nAius = obj.AiuInfo.length;
    let nDces = obj.DceInfo.length;
    let nSnoopFilters = obj.SnoopFilterInfo.length;
    let nDmis = obj.DmiInfo.length;
    let nDiis = obj.DiiInfo.length;
    let nDves = obj.DveInfo.length;
    let nCaius = 0;
    for (let i=0; i< obj.AiuInfo.length; i+=1) {
        if (obj.AiuInfo[i].fnNativeInterface.includes('CHI')) {
            nChis+=1;
            nCaius += 1;
        }else if (obj.AiuInfo[i].fnNativeInterface == 'ACE' || obj.AiuInfo[i].fnNativeInterface == 'ACE5') {
            nCioaius += 1;
            nCaius += 1;
        }else{
            nNcioaius += 1;
        }
    }
    let assignment =`
    // Structural Params
    params.structural.nCaius.values = ${nCaius};
    params.structural.nNcaius.values = ${nNcioaius};
    params.structural.nDces.values = ${nDces};
    params.structural.nSnoopFilters.values = ${nSnoopFilters};
    params.structural.nDves.values = ${nDves};
    params.structural.nDmis.values = ${nDmis};
    params.structural.nDiis.values = ${nDiis};
    // System Params
    // params.system.coherentTemplate.values 
    // params.system.nAiuPorts.values 
    // params.system.aPrimaryAiuPortBits.values
    // params.system.aSecondaryAiuPortBits.values
    params.system.nGPRA.values = ${obj.AiuInfo[0].nGPRA};
    // params.system.dceInterleavingPrimaryBits.values
    // params.system.dceInterleavingSecondaryBits.values
    params.system.resiliencyEnabled.values = ${obj.AiuInfo[0].useResiliency};
    params.system.duplicationEnabled.values = ${obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication};
    //params.system.nativeIntfProtEnabled.values = ${obj.AiuInfo[0].ResilienceInfo.enableNativeIntfProtection};
    // params.system.interUnitDelay.values 
    // params.system.resiliencyProtectionType.values = ${obj.AiuInfo[0].ResilienceInfo.fnResiliencyProtectionType};
    // params.system.fnDisableResiliencyBistDebugPin.values 
    params.system.timeoutThreshold.values = ${obj.AiuInfo[0].timeOutThreshold};
    // params.system.memoryProtectionType.values = 
    //params.system.qosEnabled.values = ${obj.AiuInfo[0].fnQosEnable};
    // params.system.qosMap.values
    // params.system.qosEventThreshold.values 
    // params.system.nMainTraceBufSize.values 
    // params.system.nTraceRegisters.values 
    // params.system.nUnitTraceBufSize.values 
    // params.system.fnDebugAPBEnable.values 
    // params.system.syncDepth.values 
    // params.system.assertionEnable.values 
    // params.system.engVerId.values
    // params.system.implVerId.values
    // params.system.frequency.values 
    // params.system.unitClockGating.values 
    // params.system.gating.values 
    // params.system.noDVM.values

    // Memory Params
    // params.memory.csrMemoryBase.values
    // params.memory.bootMemoryBase.values
    // params.memory.bootMemorySize.values
    // params.memory.mg_ref.values
    // params.memory.channel_ref.values
    // params.memory.primaryInterleavingBitOne.values 
    // params.memory.primaryInterleavingBitTwo.values 
    // params.memory.primaryInterleavingBitThree.values 
    // params.memory.primaryInterleavingBitFour.values
    `
    for (let i=0; i< nChis; i+=1) {
        
        assignment += `
        // CHI Params
        params.chi[${i}].fnNativeInterface.values = ${decodeFnNativeInterface(String(obj.AiuInfo[i].fnNativeInterface), "false")};
        params.chi[${i}].checkType.values = ${obj.AiuInfo[i].interfaces.chiInt.params.checkType};
        params.chi[${i}].wData.values = ${obj.AiuInfo[i].wData};
        `
    }

    for (let i=0; i< nCioaius; i+=1) {
        assignment += `
        // Coherent IOAIU Params
        params.cioaiu[${i}].fnNativeInterface.values = ${decodeFnNativeInterface(String(obj.AiuInfo[i+nChis].fnNativeInterface), String(obj.AiuInfo[i+nChis].orderedWriteObservation))};
        params.cioaiu[${i}].wData.values = ${obj.AiuInfo[i+nChis].wData};
        `
    }

    for (let i=0; i< nNcioaius; i+=1) {
        assignment += `
        // Non-Coherent IOAIU Params
        params.ncioaiu[${i}].fnNativeInterface.values = ${decodeFnNativeInterface(String(obj.AiuInfo[i+nChis+nCioaius].fnNativeInterface), String(obj.AiuInfo[i+nChis+nCioaius].orderedWriteObservation))};
        params.ncioaiu[${i}].multicycleODSram.choice = ${obj.AiuInfo[i+nChis+nCioaius].multicycleODSRAM ? 0 : 1}; 
        params.ncioaiu[${i}].wData.values = ${obj.AiuInfo[i+nChis+nCioaius].wData};
        `
    }

    for (let i=0; i< nDces; i+=1) {
        assignment += `
        params.dce[${i}].nCMDSkidBufArb.values = ${obj.DceInfo[i].nCMDSkidBufArb};
        params.dce[${i}].nCMDSkidBufSize.values = ${obj.DceInfo[i].nCMDSkidBufSize};
        `
    }

    for (let i=0; i< nDmis; i+=1) {
        assignment += `
        params.dmi[${i}].nCMDSkidBufArb.values = ${obj.DmiInfo[i].nCMDSkidBufArb};
        params.dmi[${i}].nCMDSkidBufSize.values = ${obj.DmiInfo[i].nCMDSkidBufSize};
        params.dmi[${i}].wData.values = ${obj.DmiInfo[i].wData};
        `
    }

    for (let i=0; i< nDiis; i+=1) {
        assignment += `
        params.dii[${i}].nCMDSkidBufArb.values = ${obj.DiiInfo[i].nCMDSkidBufArb};
        params.dii[${i}].nCMDSkidBufSize.values = ${obj.DiiInfo[i].nCMDSkidBufSize};
        params.dii[${i}].wData.values = ${obj.DiiInfo[i].wData};
        `
    }

    return assignment;

}

const executeCommandAndSaveOutput = async (command, outputPath) => {
    const originalDir = process.cwd();
    try {
        process.chdir(outputPath);
        const { stdout, stderr } = await execPromise(command);
        const output = stdout + stderr;
        await fs.writeFile(`${outputPath}/vcs.log`, output);
        if (output.includes("Error-") || output.includes("Compilation failed")) {
            throw new Error("VCS compilation failed");
        }
        return { success: true, output};
    } catch (error) {
        console.error(`Error executing command or writing to file: ${error.message}`);
        throw error;
    } finally {
        process.chdir(originalDir);
    }
}

const fetchCoverage = async (configData, isGrid, debug_path) => {
    const paramCovPath = `${debug_path}/parameter_coverage`;
    const waiversContent = await readFile(`${process.env.WORK_TOP}/dv/scripts/randomizer/params/coverage/waivers.json`, true);
    const waivers = waiversContent && JSON.parse(waiversContent);
    const covReportPath = `${paramCovPath}/urgReport/grpinfo.txt`;
    let simStatus = null;
    let compileStatus = null;
    let coverageStatus = null;
    let source = [];
    let t_env = '';
    console.log('Collecting parameter Coverage');

    let paramCovModule = `
        module param();
            import params_pkg::*;
            params_class params;

            initial begin
                params = new();
                params.make_new();

    `;
    for (const env of Object.keys(configData)) {
        const configs = configData[env].configlist;
        let isRandomizerRegression = false;
        
        for (const config of Object.keys(configs)) {
            const dvJsonPath = `${debug_path}/${env}/${config}/exe/output/debug/top.level.dv.json`;
            try {
                const dvJson = JSON.parse(await fs.readFile(dvJsonPath, 'utf8'));
                paramCovModule += assignSvParams(dvJson);
                paramCovModule += '            params.sample();\n';
                source.push(dvJsonPath);
            } catch (error) {
                process.stdout.write(`=== Warning for ${config}: ${error.code} - ${error.message}\n`);
                console.log(`Could not find dv.json file for ${env}:${config} most likely because Maestro compile failed. Skipping this config`);
            }
            if (config.includes('hw_randomizer_config')) {
                isRandomizerRegression = true;
            }
        }
        if (isRandomizerRegression) {
            t_env = 'randomizer'
        } else {
            t_env = env;
        }
    }
    paramCovModule += '        end\n';
    paramCovModule += '     endmodule: param';

    await fs.writeFile(`${paramCovPath}/param.sv`, paramCovModule);

    try {
        const compileCmd = `vcs -sverilog -full64 -cm line -cm_name simv.vdb -q +vcs+lic+wait -debug_access+r ${paramCovPath}/params_pkg.sv ${paramCovPath}/param.sv`;
        // process.env.VCS_HOME = '/engr/eda/tools/synopsys/vcs_vV-2023.12-SP2-1/vcs/V-2023.12-SP2-1';
        compileStatus = await executeCommandAndSaveOutput(compileCmd, paramCovPath);
        const simCmd = `./simv +ntb_random_seed=1`;
        if(compileStatus.success) simStatus = await executeCommandAndSaveOutput(simCmd, paramCovPath);
        const covCmd = `urg -format text -dir ${paramCovPath}/simv.vdb/`;
        if(simStatus.success) coverageStatus = await executeCommandAndSaveOutput(covCmd, paramCovPath);
    } catch (error) {
        console.error('An error occurred:', error);
    } finally {
        try {
            if(compileStatus.success && simStatus.success && coverageStatus.success) {
                const sectionArray = await splitFileIntoSections(covReportPath);
                const rawJson = sectionArray.map(parseSection);
                const parsedSections = buildDatabase(rawJson);
                const updatedJsonAndWaivers = applyWaivers(parsedSections, waivers);
                const updatedJson = updatedJsonAndWaivers.updatedJson;
                const updatedWaivers = updatedJsonAndWaivers.updatedWaivers;
                
                await writeFile(`${process.env.WORK_TOP}/dv/scripts/randomizer/params/coverage/waivers.json`, JSON.stringify(updatedWaivers, null, 2));
                const withStats = addStatistics(updatedJson);
                const data = addUniqueParams(withStats);

                if (!data.params.metadata || !Array.isArray(data.params.metadata)) {
                    data.params.metadata = [];
                }
                const now = new Date();
                const metadataObject = {
                    source: source,
                    configs: source.length,
                    date: now.toLocaleString(),
                    environment: t_env,
                    envCoverage: data.params.uniqueParams[0].totalUniqueCoverage
                };
                // console.log('sai_debug: '+ data.params.uniqueParams[0].totalUniqueCoverage);
                data.params.metadata.push(metadataObject);
                await writeFile(`${paramCovPath}/data.json`, JSON.stringify(data, null, 2));


                // console.log("sai_debug: ", JSON.stringify(data, null, 2));
                await generateReport(data, paramCovPath);
            }
            // return JSON.parse(await fs.readFile(`${process.env.MAESTRO_EXAMPLES}/hw_randomizer_config_${seedList[0]}/random_params.json`, 'utf8'));
        } catch (error) {
            console.error(`Error deleting directory: ${error.message}`);
        }
    }

}

module.exports = fetchCoverage;