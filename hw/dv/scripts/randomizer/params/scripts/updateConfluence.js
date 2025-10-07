const { ReadableStream } = require('web-streams-polyfill');
global.ReadableStream = ReadableStream;
require('dotenv').config();

const axios = require('axios');
const cheerio = require('cheerio');
const fs = require('fs').promises;

const CONFLUENCE_URL = 'https://arterisip.atlassian.net';
const API_TOKEN = process.env.API_TOKEN;
const SPACE_KEY = 'ENGR';
let rawParams = null;

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

const axiosInstance = axios.create({
  baseURL: `${CONFLUENCE_URL}/wiki/rest/api`,
  auth: {
    username: process.env.USER_ID,
    password: API_TOKEN
  }
});

const makeRequest = async(method, url, data = null, params = null, retries = 3) => {
  try {
    const response = await axiosInstance({
      method,
      url,
      data,
      params
    });
    console.log(`Request to ${url} successful`);
    return response.data;
  } catch (error) {
    console.error(`Error in ${method.toUpperCase()} request to ${url}:`);
    console.error(`Status: ${error.response ? error.response.status : 'Unknown'}`);
    console.error(`Message: ${error.message}`);
    if (error.response && error.response.data) {
      console.error('Response data:', JSON.stringify(error.response.data, null, 2));
    }
    if (error.response && error.response.status === 500 && retries > 0) {
      console.log(`Retrying request to ${url} (${retries} retries left)`);
      await new Promise(resolve => setTimeout(resolve, 5000)); // Wait 5 seconds before retrying
      return makeRequest(method, url, data, params, retries - 1);
    }
    throw error;
  }
}

const getPageContent = async(pageId) => {
  const data = await makeRequest('get', `/content/${pageId}`, null, { expand: 'body.storage,version,title' });
  return {
    content: data.body.storage.value,
    version: data.version.number,
    title: data.title
  };
}

const updatePageContent = async(pageId, content, version, title) => {
    return await makeRequest('put', `/content/${pageId}`, {
      version: { number: version + 1 },
      type: 'page',
      title: title,
      body: {
        storage: {
          value: content,
          representation: 'storage'
        }
      }
    });
}

const DRY_RUN = false; // Set this to false when you're ready to actually update Confluence

const updateTable = ($, params) => {
    let changed = false;
  
    $('table').each((index, table) => {
      const $table = $(table);
      $table.find('tr').each((rowIndex, row) => {
        const cells = $(row).find('td');
        if (cells.length == 2) {
          const key = $(cells[0]).text().trim();
          const value = $(cells[1]).find('p').text().trim();
          if (params[key] !== value) {
            $(cells[1]).find('p').text(params[key]);
            changed = true;
            console.log(`Updated ${key}: ${value} -> ${params[key]}`);
          }
        } else if (cells.length == 4) {
          const key1 = $(cells[0]).text().trim();
          const value1 = $(cells[1]).find('p').text().trim();
          if (params[key1] !== value1) {
            $(cells[1]).find('p').text(params[key1]);
            changed = true;
            console.log(`Updated ${key1}: ${value1} -> ${params[key1]}`);
          }

          const key2 = $(cells[2]).text().trim();
          const value2 = $(cells[3]).find('p').text().trim();

          if (params[key2] !== value2) {
            $(cells[3]).find('p').text(params[key2]);
            changed = true;
            console.log(`Updated ${key2}: ${value2} -> ${params[key2]}`);
          }
        } else if (cells.length == 3) {
          if ($(cells[0]).text().trim() === 'Valid Values') {
            const archValue = $(cells[1]).find('p').text().trim();
            const releaseValue = $(cells[2]).find('p').text().trim();
            if (params['architectureValidValues'] !== archValue) {
              $(cells[1]).find('p').text(params['architectureValidValues']);
              changed = true;
              console.log(`Updated Architecture Valid Values: ${archValue} -> ${params['architectureValidValues']}`);
            }
            if (params['releaseValidValues'] !== releaseValue) {
              $(cells[2]).find('p').text(params['releaseValidValues']);
              changed = true;
              console.log(`Updated Release Valid Values: ${releaseValue} -> ${params['releaseValidValues']}`);
            }
          }
        }
      });
    });
  
    console.log(`Table update complete. Changed: ${changed}`);
    return { content: $.html(), changed };
}

const getChildPages = async (parentPageId) => {
    console.log(`Getting child pages for: ${parentPageId}`);
    let allResults = [];
    let start = 0;
    const limit = 500;

    while (true) {
        const response = await axiosInstance.get(`/content/${parentPageId}/child/page`, {
            params: {
                start: start,
                limit: limit
            }
        });

        const { results, size, _links } = response.data;
        allResults = allResults.concat(results);

        if (!_links.next) {
            break;
        }
        start += size;
    }
    return allResults;
}
  
const updateConfluencePage = async (pageId, params) => {
console.log(`Processing page: ${pageId}`);
const { content, version, title } = await getPageContent(pageId);
console.log(`Page title: "${title}"`);

if (content.includes('ac:structured-macro ac:name="children"')) {
    console.log('This is a parent page with child pages. Skipping content update.');
    return;
}

const $ = cheerio.load(content, { xmlMode: true });
const { content: updatedContent, changed } = updateTable($, params);

if (changed) {
    console.log(`Changes detected for page: ${title}`);
    if (!DRY_RUN) {
    await updatePageContent(pageId, updatedContent, version, title);
    console.log(`Updated page: ${title}`);
    } else {
    console.log(`DRY RUN: Would update page: ${title}`);
    }
} else {
    console.log(`No changes for page: ${pageId}`);
}
}

const findPageByTitle = async(title) => {
  const data = await makeRequest('get', '/content', null, {
    spaceKey: SPACE_KEY,
    title: title,
    type: 'page',
    expand: 'version'
  });
  return data.results[0];
}

const traverseAndUpdate = async(structure, parentPageId) => {
    console.log(`Traversing structure for parent page: ${parentPageId}`);
    const childPages = await getChildPages(parentPageId);
    
    for (const [key, value] of Object.entries(structure)) {
      console.log(`Processing key: ${key}`);
      if (typeof value === 'object' && value !== null) {
        const matchingChildPage = childPages.find(page => page.title === key);
        if (matchingChildPage) {
          if ('Type' in value) {
            await updateConfluencePage(matchingChildPage.id, value);
          } else {
            await traverseAndUpdate(value, matchingChildPage.id);
          }
        } else {
          console.log(`Child page not found: ${key}`);
        }
      }
    }
}

const main = async() => {
  try {
    console.log('Starting Confluence update process');
    rawParams = JSON.parse(await fs.readFile('./raw_params.json', 'utf-8'));
    
    const rootPageTitle = 'Ncore Parameters';
    console.log(`Finding root page: ${rootPageTitle}`);
    const rootPage = await findPageByTitle(rootPageTitle);
    
    if (!rootPage) {
      throw new Error(`Root page "${rootPageTitle}" not found in space ${SPACE_KEY}`);
    }
    console.log(`Root page found. ID: ${rootPage.id}`);
    await traverseAndUpdate(rawParams.ncoreParams, rootPage.id);
    console.log('Confluence pages have been updated successfully.');
  } catch (error) {
    console.error('Error in main function:', error.message);
    if (error.stack) {
      console.error('Stack trace:', error.stack);
    }
  }
}

main();