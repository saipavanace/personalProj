#!/usr/bin/env node
const { ReadableStream } = require('web-streams-polyfill');
global.ReadableStream = ReadableStream;
require('dotenv').config();

const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs').promises;


const CONFLUENCE_URL = 'https://arterisip.atlassian.net';
const API_TOKEN = 'ATATT3xFfGF0AS2cp68cBQ_wUw7wsiZ4Okv3-xu8CUe8v7l4ya1PkcmacghxrY-Gec2tprsUJrdy7iExtA1OlDp05THKh1vSvIrB3bd6ccjLb35o6wim5tWoiX5dyZMaKdvNDkEO0ZjOY0MhTupnaY6HnqoKW3iqtxUqeAW5ePxhas2SHx_sayg=9E8FEF5A';
const SPACE_KEY = 'ENGR';
const ROOT_PAGE_ID = '757792866';
const RANDOMIZER_HOME = `${process.env.WORK_TOP}/dv/scripts/randomizer`;

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const axiosInstance = axios.create({
  baseURL: `${CONFLUENCE_URL}/wiki/rest/api`,
  auth: {
    username: 'saipavan.yaraguti@arteris.com',
    password: API_TOKEN
  }
});

const preserveCamelCase = (str) => {
    // Function to check if a word is an acronym
    const isAcronym = (word) => /^[A-Z0-9]+$/.test(word);
  
    // Remove any characters that aren't alphanumeric or spaces
    str = str.replace(/[^\w\s]/g, '');
    
    // Split the string into words, preserving existing camelCase
    let words = str.split(/(?=[A-Z])|\s+/);
    
    // If it's a single word and an acronym, convert to lowercase
    if (words.length === 1 && isAcronym(words[0])) {
      return words[0].toLowerCase();
    }
  
    return words.map((word, index) => {
      if (index === 0) {
        // First word should be all lowercase unless it's an acronym in a multi-word key
        return (words.length > 1 && isAcronym(word)) ? word : word.toLowerCase();
      } else if (isAcronym(word)) {
        // Keep acronyms in uppercase
        return word;
      } else {
        // Preserve existing capitalization
        return word;
      }
    }).join('');
}

const transformKeys = (obj) => {
    if (Array.isArray(obj)) {
        return obj.map(transformKeys);
    } else if (typeof obj === 'object' && obj !== null) {
        return Object.keys(obj).reduce((acc, key) => {
            // Remove everything before and including "::"
            let newKey = key.includes('::') ? key.split('::').pop() : key;
            
            // Remove "Parameters" from the key
            newKey = newKey.replace(/ Parameters/g, '').replace(/Parameters/g, '');
            
            // Preserve camelCase while applying our transformations
            newKey = preserveCamelCase(newKey);

            // Concert All UpperCase string to LowerCase
            if (newKey === newKey.toUpperCase()) newKey = newKey.toLowerCase();
            
            acc[newKey] = transformKeys(obj[key]);
            return acc;
        }, {});
    }
    return obj;
}

const getAllPagesInSpace = async(spaceKey) => {
    let allPages = [];
    let start = 0;
    const limit = 100;
    let hasMore = true;
    
    console.log(`Starting to fetch all pages from space ${spaceKey}...`);
  
    while (hasMore) {
      try {
        console.log(`Fetching pages ${start}-${start+limit-1}...`);
        const response = await axiosInstance.get(`/space/${spaceKey}/content`, {
          params: {
            type: 'page',
            status: 'any',       // Include all statuses, not just current
            expand: 'version',   // Get version info to help with debugging
            limit: limit,
            start: start
          }
        });
  
        const results = response.data.page.results;
        console.log(`Retrieved ${results.length} pages in this batch`);
        
        // Check if our target page is in this batch
        const targetPageInBatch = results.find(page => page.id === ROOT_PAGE_ID);
        if (targetPageInBatch) {
          console.log(`TARGET PAGE FOUND in this batch: ${targetPageInBatch.title} (ID: ${targetPageInBatch.id})`);
        }
  
        allPages = allPages.concat(results);
        
        if (response.data.page.size === limit) {
          // There might be more pages to fetch
          start += limit;
          console.log(`Total pages collected so far: ${allPages.length}, continuing...`);
        } else {
          console.log(`Retrieved all pages: ${allPages.length} total`);
          hasMore = false;
        }
      } catch (error) {
        console.error('Error fetching pages:', error);
        if (error.response) {
          console.error('Response status:', error.response.status);
          console.error('Response data:', error.response.data);
        }
        hasMore = false;
      }
    }
  
    return allPages;
  }

const getPageContent = async(pageId) => {
  const response = await axiosInstance.get(`/content/${pageId}?expand=body.storage`);
  return response.data.body.storage.value;
}

const getChildPages = async(pageId) =>{
    console.log("Getting child pages of page with pageId: " + pageId);
    let allResults = [];
    let start = 0;
    const limit = 500; // You can adjust this value, but 50 is a common limit

    while (true) {
        const response = await axiosInstance.get(`/content/${pageId}/child/page`, {
        params: {
            start: start,
            limit: limit
        }
        });

        const results = response.data.results;
        allResults = allResults.concat(results);

        if (results.length < limit) {
            break;
        }
        start += limit;
    }

    return allResults;
}

const parseTable = (html) => {
    const $ = cheerio.load(html);
    const result = {};
    const orderedKeys = [
      'Type', 'Visibility', 'Access', 'Default', 
      'architectureValidValues', 'releaseValidValues',
      'Source', 'Conditions', 'Customer Description',
      'Architecture Description', 'Constraints', 'General Comments'
    ];
  
    $('tr').each((i, row) => {
      const cells = $(row).find('td');
      let key = '';
      let value = '';
      if (cells.length == 2) {
        key = $(cells[0]).text().trim();
        value = $(cells[1]).text().trim();
        result[key] = value;
      }else if (cells.length == 4) {
        key = $(cells[0]).text().trim();
        value = $(cells[1]).text().trim();
        result[key] = value;
        key = $(cells[2]).text().trim();
        value = $(cells[3]).text().trim();
        result[key] = value;
      }else{
        if ($(cells[1]).text().trim() == 'Architecture') {
            result['architectureValidValues'] = '';
            result['releaseValidValues'] = '';
        }else {
            result['architectureValidValues'] = $(cells[1]).text().trim();
            result['releaseValidValues'] = $(cells[2]).text().trim();
        }
      }
    });
  
    const orderedResult = {};
    orderedKeys.forEach(key => {
      orderedResult[key] = key in result ? result[key] : null;
    });
  
    return orderedResult;
}

function processJSON(jsonData) {
  function processValue(value) {
    if (typeof value !== 'string') return value;
    
    // Handle empty string or whitespace-only string
    if (value.trim() === '' || value === '""') return "";
    
    // If it's not an empty string and doesn't start and end with brackets, return as is
    if (!value.startsWith('[') || !value.endsWith(']')) {
      return value;
    }
    
    // Remove brackets
    value = value.slice(1, -1);
    
    if (value === '') return []; // Handle empty array
    
    if (value.includes(':')) {
      // Handle range format
      return [`${value}`];
    } else {
      // Handle comma-separated list
      return value.split(',').map(item => {
        item = item.trim();
        if (item.startsWith('"') && item.endsWith('"')) {
          // Keep strings as they are
          return item;
        } else if (!isNaN(item)) {
          // Convert numbers
          return Number(item);
        } else {
          // Everything else
          return item;
        }
      });
    }
  }

  function traverse(obj) {
    for (let key in obj) {
      if (typeof obj[key] === 'object' && obj[key] !== null) {
        traverse(obj[key]);
      } else if (key === 'architectureValidValues' || key === 'releaseValidValues') {
        obj[key] = processValue(obj[key]);
      }
    }
  }

  traverse(jsonData);
  return jsonData;
}

const buildJsonStructure = async (pageId, structure = {}) => {
  console.log(`Processing page ID: ${pageId}`);
  const content = await getPageContent(pageId);
  const $ = cheerio.load(content);
  
  if ($('table').length > 0) {
    console.log(`Page ${pageId} contains a table. Parsing...`);
    return parseTable(content);
  } else {
    console.log(`Page ${pageId} is a parent node. Fetching child pages...`);
    const childPages = await getChildPages(pageId);
    for (const childPage of childPages) {
      console.log(`Processing child page: ${childPage.title} (ID: ${childPage.id})`);
      structure[childPage.title] = await buildJsonStructure(childPage.id);
    }
    return structure;
  }
}

const mergeWeightsStructure = async (newStructure, existingWeightsPath) => {
  let existingWeights = {};
  try {
    const data = await fs.readFile(existingWeightsPath, 'utf8');
    existingWeights = JSON.parse(data);
  } catch (error) {
    console.log('No existing weights file found or error reading it. Creating a new one.');
  }

  const mergeObjects = (newObj, existingObj) => {
    for (let key in newObj) {
      if (typeof newObj[key] === 'object' && newObj[key] !== null) {
        if (!(key in existingObj)) {
          existingObj[key] = {};
        }
        mergeObjects(newObj[key], existingObj[key]);
      } else if (!(key in existingObj)) {
        existingObj[key] = newObj[key];
      }
    }
    return existingObj;
  };

  return mergeObjects(newStructure, existingWeights);
};

const createWeightsStructure = (obj) => {
  if (Array.isArray(obj)) {
    return obj.map(createWeightsStructure);
  } else if (typeof obj === 'object' && obj !== null) {
    return Object.keys(obj).reduce((acc, key) => {
      if (key === 'architectureValidValues' || key === 'releaseValidValues') {
        acc[key] = obj[key];
        acc[key === 'architectureValidValues' ? 'archWeights' : 'releaseWeights'] = {};
      } else if (typeof obj[key] === 'object' && obj[key] !== null) {
        const nestedResult = createWeightsStructure(obj[key]);
        if (Object.keys(nestedResult).length > 0) {
          acc[key] = nestedResult;
        }
      }
      return acc;
    }, {});
  }
  return {};
};

// Replace the parseConfluence function with this more direct approach
const parseConfluence = async() => {
    try {
      console.log(`Directly accessing page with ID ${ROOT_PAGE_ID}...`);
      
      // Get the page content directly
      const content = await getPageContent(ROOT_PAGE_ID);
      console.log(`Successfully retrieved content for page ID ${ROOT_PAGE_ID}`);
      
      // Build the JSON structure starting from this page
      let result = {
        ncoreParams: await buildJsonStructure(ROOT_PAGE_ID)
      };
  
      await fs.writeFile(`${RANDOMIZER_HOME}/params/scripts/raw_params.json`, JSON.stringify(result, null, 2));
  
      result = transformKeys(result);
      result = processJSON(result);
      
      await fs.writeFile(`${RANDOMIZER_HOME}/params/params.json`, JSON.stringify(result, null, 2));
      console.log(`JSON structure has been saved to ${RANDOMIZER_HOME}/params/params.json`);
  
      // Create weights structure
      let newWeightsStructure = createWeightsStructure(result);
      
      const weightsPath = `${RANDOMIZER_HOME}/params/config/weights.json`;
  
      // Merge new structure with existing weights (if any)
      let finalWeightsStructure = await mergeWeightsStructure(newWeightsStructure, weightsPath);
  
      await fs.writeFile(weightsPath, JSON.stringify(finalWeightsStructure, null, 2));
      console.log(`Updated weights structure has been saved to ${weightsPath}`);
    } catch (error) {
      if (error.response && error.response.status === 404) {
        console.error(`Error: Page with ID ${ROOT_PAGE_ID} not found. Please verify the page exists and is accessible.`);
        
        // Optionally, try to find the page by title as a fallback
        console.log("Attempting to find page by title 'Ncore Parameters'...");
        try {
          const response = await axiosInstance.get('/content/search', {
            params: {
              cql: `space=${SPACE_KEY} AND title="Ncore Parameters" AND type=page`,
              expand: 'space'
            }
          });
          
          if (response.data.results.length > 0) {
            const page = response.data.results[0];
            console.log(`Found page with title "Ncore Parameters" (ID: ${page.id})`);
            console.log(`Please update your ROOT_PAGE_ID to: ${page.id}`);
          } else {
            console.log("No page with title 'Ncore Parameters' found in space ENGR");
          }
        } catch (searchError) {
          console.error("Error searching for page by title:", searchError.message);
        }
      } else {
        console.error('Error in main function:', error.message);
        if (error.response) {
          console.error('Response status:', error.response.status);
          console.error('Response data:', JSON.stringify(error.response.data, null, 2));
        }
      }
    }
}

if (require.main === module) {
    parseConfluence();
}

module.exports = parseConfluence;