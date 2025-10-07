#!/usr/bin/env node

//////////////////////////////////////////////////////////////////////////////////
// Purpose: Create UVM register model                                           //
// Description: This script takes the xml file in IPXACT                        //
//              format which has the register description                       //
//              and constructs a reg model from it in UVM                       //
// Usage: node reg_gen.js -ipxact <path\to\ipxact2009|2014> -o <output_file>    //
// Author: Sai Pavan Yaraguti                                                   //
//////////////////////////////////////////////////////////////////////////////////

const fs = require('fs');
const path = require('path');
const parseXML = require('./parseXML'); // Assuming xmlParser.js is in the same directory

const getAccessType = (access, writeModifier = null, readAction = null) => {
    const validAccess = ['read-write', 'read-only', 'write-only', 'read-writeOnce', 'writeOnce'];
    const validWriteModifiers = [null, 'clear', 'set', 'modify', 'oneToClear', 'oneToSet', 'oneToToggle', 'zeroToClear', 'zeroToSet', 'zeroToToggle'];
    const validReadActions = [null, 'set', 'clear'];
  
    if (!validAccess.includes(access)) {
        throw new Error(`Invalid access type: ${access}`);
    }
    if (!validWriteModifiers.includes(writeModifier)) {
      throw new Error(`Invalid write modifier: ${writeModifier}`);
    }
    if (!validReadActions.includes(readAction)) {
      throw new Error(`Invalid read action: ${readAction}`);
    }
  
    if (access === 'read-writeOnce') {
        if (writeModifier === null && readAction === null) {
            return 'W1';
        }
        throw new Error(`Invalid combination for read-writeOnce: writeModifier=${writeModifier}, readAction=${readAction}`);
    }
    
    if (access === 'writeOnce') {
        if (writeModifier === null && readAction === null) {
            return 'W01';
        }
        throw new Error(`Invalid combination for writeonce: writeModifier=${writeModifier}, readAction=${readAction}`);
    }
  
    if (access === 'read-write') {
        if (writeModifier === null && readAction === null) return 'RW';
        if (writeModifier === null && readAction === 'set') return 'WRS';
        if (writeModifier === null && readAction === 'clear') return 'WRC';
        if (writeModifier === 'clear' && readAction === null) return 'WC';
        if (writeModifier === 'clear' && readAction === 'set') return 'WCRS';
        if (writeModifier === 'set' && readAction === null) return 'WS';
        if (writeModifier === 'set' && readAction === 'set') return 'WSRC';
        if (writeModifier === 'oneToClear' && readAction === null) return 'W1C';
        if (writeModifier === 'oneToClear' && readAction === 'set') return 'W1CRS';
        if (writeModifier === 'oneToSet' && readAction === null) return 'W1S';
        if (writeModifier === 'oneToSet' && readAction === 'clear') return 'W1SRC';
        if (writeModifier === 'oneToToggle' && readAction === null) return 'W1T';
        if (writeModifier === 'zeroToClear' && readAction === null) return 'W0C';
        if (writeModifier === 'zeroToClear' && readAction === 'set') return 'W0CRS';
        if (writeModifier === 'zeroToSet' && readAction === null) return 'W0S';
        if (writeModifier === 'zeroToSet' && readAction === 'clear') return 'W0SRC';
        if (writeModifier === 'zeroToToggle' && readAction === null) return 'W0T';
    }
  
    if (access === 'read-only') {
        if (writeModifier === null && readAction === null) return 'RO';
        if (writeModifier === null && readAction === 'set') return 'RS';
        if (writeModifier === null && readAction === 'clear') return 'RC';
    }
  
    if (access === 'write-only') {
        if (writeModifier === null && readAction === null) return 'WO';
        if (writeModifier === 'clear' && readAction === null) return 'W0C';
        if (writeModifier === 'set' && readAction === null) return 'W0S';
    }
  
    throw new Error(`Invalid combination: access=${access}, writeModifier=${writeModifier}, readAction=${readAction}`);
};

const extractBits = (resetValue, initialBit, bitWidth) => {
    let resetInt = parseInt(resetValue, 16);
    if(bitWidth == 32) return resetValue;
    let mask = ((1 << bitWidth) - 1) << initialBit;
    let extracted = (resetInt & mask) >>> initialBit;

    // Convert back to hex and ensure at least one digit
    return extracted.toString(16).padStart(1, '0');
}

const genRegisterDoc = (data, is_2009) => {
    const namespace = is_2009 ? 'spirit' : 'ipxact';
    
    let html = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/svg+xml" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'%3E%3Crect width='100' height='100' fill='%23fe5000'/%3E%3Cpath d='M35 75L55 25L75 75M43 60H67' stroke='white' stroke-width='12' fill='none' transform='skewX(-12) translate(10, 0)'/%3E%3C/svg%3E">
        <title>Register Viewer</title>
        <style>
            body, html {
                margin: 0;
                padding: 0;
                height: 100%;
                font-family: system-ui, -apple-system, sans-serif;
            }
            .search-result-item:hover {
                background-color: #f7fafc;
            }
            .tree-item:hover {
                background-color: #e9ecef !important;
            }
            .tree-item:focus {
                background-color: #fd5002 !important;
                color: white !important;
            }
            .expand-button:hover {
                background-color: #cbd5e0 !important;
            }
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
        </style>
    </head>
    <body>
        <div id="loadingOverlay" style="
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(255, 255, 255, 0.9);
            display: flex;
            visibility: visible !important;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 9999;
        ">
            <div style="
                width: 50px;
                height: 50px;
                border: 5px solid #f3f3f3;
                border-top: 5px solid #fd5002;
                border-radius: 50%;
                animation: spin 1s linear infinite;
            "></div>
            <p style="margin-top: 20px; font-family: Arial, sans-serif;">Loading. Please Wait...</p>
        </div>
        <div id="app" style="height: 100vh; margin: 0; font-family: system-ui, sans-serif;">
            <div style="padding: 10px; position: sticky; top:0;">
                <div style="display: flex; align-items: center;">
                    <!-- Logo on the left -->
                    <div style="margin-left: 0; flex-shrink: 0;">
                        <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="Group_6" data-name="Group 6" width="198.237" height="29.993" viewBox="0 0 198.237 29.993">
                            <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="Group_6" data-name="Group 6" width="198.237" height="29.993" viewBox="0 0 198.237 29.993">
                                <defs>
                                    <clipPath id="clip-path">
                                    <rect id="Rectangle_2" data-name="Rectangle 2" width="198.237" height="29.993" fill="none"></rect>
                                    </clipPath>
                                </defs>
                                <path id="Path_1" data-name="Path 1" d="M15.21,22.776h.064L17,31.2H10.6ZM12.873,17.46,0,40.323H5.572l2.69-4.9h9.606l.993,4.9h5.6L19.117,17.46Z" transform="translate(0 -13.895)"></path>
                                <g id="Group_2" data-name="Group 2">
                                    <g id="Group_1" data-name="Group 1" clip-path="url(#clip-path)">
                                    <path id="Path_2" data-name="Path 2" d="M152.931,28.155c3.33,0,4.707-1.473,4.707-3.715,0-1.761-1.089-2.722-3.682-2.722h-4.483l-1.025,6.436ZM141.083,40.323,144.7,17.46h10.663c5,0,7.717,2.434,7.717,6.5a7.976,7.976,0,0,1-5.668,7.621l3.811,8.742h-5.764L152.1,32.414h-4.323l-1.249,7.909Z" transform="translate(-112.279 -13.895)"></path>
                                    <path id="Path_3" data-name="Path 3" d="M272.979,21.719H265.07l.672-4.259H287.1l-.64,4.259h-7.941l-2.946,18.6h-5.539Z" transform="translate(-210.953 -13.896)"></path>
                                    <path id="Path_4" data-name="Path 4" d="M380.825,17.46h17.323l-.672,4.259H385.564l-.769,5h10.439l-.7,4.259H384.123l-.8,5.059h12.072l-.673,4.291H377.206Z" transform="translate(-300.195 -13.896)"></path>
                                    <path id="Path_5" data-name="Path 5" d="M501.661,28.155c3.33,0,4.707-1.473,4.707-3.715,0-1.761-1.089-2.722-3.683-2.722H498.2l-1.025,6.436ZM489.813,40.323l3.618-22.863h10.663c5,0,7.717,2.434,7.717,6.5a7.976,7.976,0,0,1-5.668,7.621l3.811,8.742h-5.764l-3.362-7.909h-4.323l-1.249,7.909Z" transform="translate(-389.812 -13.895)"></path>
                                    <path id="Path_6" data-name="Path 6" d="M623.659,17.46l-3.619,22.863H614.5l3.618-22.863Z" transform="translate(-489.044 -13.896)"></path>
                                    <path id="Path_7" data-name="Path 7" d="M677.566,31.781c.128,2.5,2.338,3.458,4.675,3.458,2.754,0,4.515-1.217,4.515-3.106,0-1.185-.9-1.729-3.074-2.209l-3.971-.865c-2.914-.64-5.283-2.4-5.283-5.6,0-4.835,4.227-7.877,9.767-7.877,5.924,0,8.934,2.85,9.03,7.013H688.1c-.1-1.857-1.633-3.042-4.195-3.042s-4.1,1.249-4.1,2.978c0,1.281.961,1.793,2.946,2.241l4.195.929c3.362.737,5.219,2.5,5.219,5.412,0,4.867-4.419,8.1-10.119,8.1-5.828,0-9.767-2.626-9.831-7.429Z" transform="translate(-534.978 -12.398)"></path>
                                    <rect id="Rectangle_1" data-name="Rectangle 1" width="29.993" height="29.993" transform="translate(168.244)" fill="#fe5000"></rect>
                                    <path id="Path_8" data-name="Path 8" d="M863.713,44.548c2.155,0,3.017-.985,3.017-2.483,0-1.149-.677-1.765-2.339-1.765h-2.729l-.677,4.248Zm-3.16,2.729-.78,4.946h-3.488L858.6,37.571h6.525c3.181,0,5.13,1.457,5.13,4.145,0,3.612-2.647,5.561-6.567,5.561Zm-4.658-9.706-2.319,14.652h-3.55l2.319-14.652Z" transform="translate(-676.484 -29.9)" fill="#fff"></path>
                                    </g>
                                </g>
                            </svg>
                        </svg>
                    </div>
                    
                    <!-- Search bar in center -->
                    <div id="searchContainer" style="flex-grow: 1; display: flex; justify-content: center; margin-left: 20px; margin-right: 20px; margin-bottom: 20px; margin-left:300px;">
                        <div style="width: 100%; max-width: 600px;">
                            <div style="display: flex; align-items: center; padding: 8px 16px; border: 2px solid #4299e1; border-radius: 24px; background-color: white;">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 8px; color: #4a5568">
                                    <circle cx="11" cy="11" r="8"></circle>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                </svg>
                                <input 
                                    type="text" 
                                    id="searchInput"
                                    placeholder="Search registers and fields..." 
                                    style="border: none; outline: none; width: 100%; font-size: 14px; background-color: transparent;"
                                >
                                <div id="clearSearch" style="display: none; cursor: pointer;" onclick="clearSearch()">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <line x1="18" y1="6" x2="6" y2="18"></line>
                                        <line x1="6" y1="6" x2="18" y2="18"></line>
                                    </svg>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Add an empty div to balance the layout -->
                    <div style="flex-shrink: 0; width: 198.237px;"></div>
                </div>
            </div>

            <!-- Main Content -->
            <div style="display: flex; width: 100%; height: calc(100vh - 70px); overflow: hidden;">
                <!-- Index Panel -->
                <div id="indexPanel" style="width: 300px; height: 100vh; background-color: #f8f9fa; border-right: 1px solid #dee2e6; overflow: auto; position:fixed;">
                    <div style="padding: 12px; border-bottom: 1px solid #dee2e6; background:white; top:0; position:sticky; z-index:1;">
                        <div style="display: flex; gap: 8px;">
                            <button onclick="expandAll()" class="expand-button" style="padding: 4px 8px; background-color: #e9ecef; border: 1px solid #dee2e6; border-radius: 4px; cursor: pointer; display: flex; align-items: center; gap: 4px; font-size: 12px; transition: background-color 0.2s;">
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <polyline points="15 3 21 3 21 9"></polyline>
                                    <polyline points="9 21 3 21 3 15"></polyline>
                                    <line x1="21" y1="3" x2="14" y2="10"></line>
                                    <line x1="3" y1="21" x2="10" y2="14"></line>
                                </svg>
                                Expand All
                            </button>
                            <button onclick="collapseAll()" class="expand-button" style="padding: 4px 8px; background-color: #e9ecef; border: 1px solid #dee2e6; border-radius: 4px; cursor: pointer; display: flex; align-items: center; gap: 4px; font-size: 12px; transition: background-color 0.2s;">
                                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <polyline points="4 14 10 14 10 20"></polyline>
                                    <polyline points="20 10 14 10 14 4"></polyline>
                                    <line x1="14" y1="10" x2="21" y2="3"></line>
                                    <line x1="3" y1="21" x2="10" y2="14"></line>
                                </svg>
                                Collapse All
                            </button>
                        </div>
                    </div>
                    <div id="treeContent" style="padding: 12px;"></div>
                </div>

                <!-- Data Panel -->
                <div id="dataPanel" style="flex: 1; height: 90vh; overflow: auto; padding: 20px; margin-right: 20px; margin-top: 20px; margin-bottom: 20px; margin-left: 300px;"></div>
            </div>

            <!-- Search Results Modal -->
            <div id="searchOverlay" style="position: fixed; top: 0; left: 0; right: 0; bottom: 0; background-color: rgba(0, 0, 0, 0.5); display: none; z-index: 998;"></div>
            <div id="searchResults" style="position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); width: 90%; max-width: 600px; background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); z-index: 999; display: none; flex-direction: column; max-height: 80vh;"></div>
        </div>
        <script>
            // This is where Maestro will inject the data
            const initialData = ${JSON.stringify(data, null, 2)};
            
            // Global state
            let activeRegister = null;
            const expandedMaps = new Set();
            const expandedBlocks = new Set();

            class TrieNode {
                constructor() {
                    this.children = new Map();
                    this.items = [];
                    this.isEndOfWord = false;
                }
            }

            class SearchTrie {
                constructor() {
                    this.root = new TrieNode();
                }

                insert(word, item) {
                    let node = this.root;
                    const chars = word.toLowerCase();
                    for (const char of chars) {
                        if (!node.children.has(char)) {
                            node.children.set(char, new TrieNode());
                        }
                        node = node.children.get(char);
                        if (node.items.length < 100) {
                            node.items.push(item);
                        }
                    }
                    node.isEndOfWord = true;
                }

                search(prefix) {
                    let node = this.root;
                    const chars = prefix.toLowerCase();
                    for (const char of chars) {
                        if (!node.children.has(char)) {
                            return [];
                        }
                        node = node.children.get(char);
                    }
                    return node.items;
                }
            }

            function indexPaths(trie, item) {
                const pathParts = item.path.split('.');
                
                for (let i = 0; i < pathParts.length; i++) {
                    const currentPart = pathParts[i].toLowerCase();
                    
                    for (let j = 0; j < currentPart.length; j++) {
                        const substring = currentPart.substring(j);
                        
                        trie.insert(substring, item);
                        
                        for (let k = i + 1; k <= pathParts.length; k++) {
                            const restOfPath = pathParts.slice(i + 1, k).join('.');
                            const combinedPath = restOfPath ? \`\${substring}.\${restOfPath}\` : substring;
                            trie.insert(combinedPath, item);
                        }
                    }
                }
                
                for (let i = 0; i < pathParts.length; i++) {
                    for (let j = i + 1; j <= pathParts.length; j++) {
                        const partialPath = pathParts.slice(i, j).join('.');
                        trie.insert(partialPath, item);
                    }
                }
            }

            function optimizeForSearch(ipxactData) {
                const trie = new SearchTrie();
                const getChildText = (node, childName) => {
                    const child = node.children.find(c => c.name === childName);
                    return child ? child.text : '';
                };

                function transformRegister(register, blockName, mapName) {
                    const getChildText = (node, childName) => {
                        if (node.name === childName) {
                            return node.text;
                        }
                        const child = node?.children?.find(c => c.name === childName);
                        return child ? child.text : '';
                    };

                    let resetValue;
                    if (${is_2009}) {
                        const resetNode = register.children.find(c => c.name === \`${namespace}:reset\`);
                        resetValue = resetNode ? getChildText(resetNode.children[0], \`${namespace}:value\`) : '0x0';
                    } else {
                        const resetNode = register.children.find(c => c.name === \`${namespace}:resets\`);
                        const firstReset = resetNode?.children?.find(c => c.name === \`${namespace}:reset\`);
                        resetValue = firstReset ? getChildText(firstReset.children[0], \`${namespace}:value\`) : "'h0";
                    }

                    return {
                        registerName: getChildText(register, \`${namespace}:name\`),
                        description: getChildText(register, \`${namespace}:description\`),
                        size: parseInt(getChildText(register, \`${namespace}:size\`)),
                        resetValue: resetValue,
                        addressOffset: getChildText(register, \`${namespace}:addressOffset\`),
                        blockName,
                        hierarchy: \`\${mapName}.\${blockName}.\${getChildText(register, \`${namespace}:name\`)}\`,
                        fields: register.children
                            .filter(child => child.name === \`${namespace}:field\`)
                            .map(field => ({
                                fieldName: getChildText(field, \`${namespace}:name\`),
                                description: getChildText(field, \`${namespace}:description\`),
                                bitOffset: parseInt(getChildText(field, \`${namespace}:bitOffset\`)),
                                bitWidth: parseInt(getChildText(field, \`${namespace}:bitWidth\`)),
                                access: getChildText(field, \`${namespace}:access\`)
                            }))
                    };
                }

                ipxactData.forEach(memoryMap => {
                    const mapName = getChildText(memoryMap, '${namespace}:name');
                    
                    memoryMap.children
                        .filter(child => child.name === '${namespace}:addressBlock')
                        .forEach(block => {
                            const blockName = getChildText(block, '${namespace}:name');
                            
                            block.children
                                .filter(child => child.name === '${namespace}:register')
                                .forEach(register => {
                                    const transformedRegister = transformRegister(register, blockName, mapName);
                                    const regItem = {
                                        type: 'Register',
                                        name: transformedRegister.registerName.toLowerCase(),
                                        displayName: transformedRegister.registerName,
                                        path: \`\${mapName}.\${blockName}.\${transformedRegister.registerName}\`.toLowerCase(),
                                        displayPath: \`\${mapName}.\${blockName}.\${transformedRegister.registerName}\`,
                                        address: transformedRegister.addressOffset,
                                        description: transformedRegister.description,
                                        register: transformedRegister
                                    };

                                    indexPaths(trie, regItem);
                                    
                                    transformedRegister.fields.forEach(field => {
                                        const fieldItem = {
                                            type: 'Field',
                                            name: field.fieldName.toLowerCase(),
                                            displayName: field.fieldName,
                                            path: \`\${mapName}.\${blockName}.\${transformedRegister.registerName}.\${field.fieldName}\`.toLowerCase(),
                                            displayPath: \`\${mapName}.\${blockName}.\${transformedRegister.registerName}.\${field.fieldName}\`,
                                            address: transformedRegister.addressOffset,
                                            description: field.description,
                                            register: transformedRegister
                                        };
                                        
                                        indexPaths(trie, fieldItem);
                                    });
                                });
                        });
                });
                
                return trie;
            }

            // Utility functions
            function getChildValue(node, childName) {
                if (node.name == \`${namespace}\:\${childName}\`) {
                    return node.text;
                }
                const child = node.children.find(c => c.name === \`${namespace}:\${childName}\`);
                
                return child ? child.text : '';
            }

            function parseNumber(value) {
                if (!value) return 0;
                if (typeof value === 'number') return value;
                value = value.trim();
                if (value.startsWith("'h")) return parseInt(value.slice(2), 16);
                if (value.startsWith("0x")) return parseInt(value.slice(2), 16);
                return parseInt(value);
            }

            function getRegisterFields(register) {
                return register.children
                    .filter(child => child.name === \`${namespace}:field\`)
                    .map(field => ({
                        fieldName: getChildValue(field, 'name'),
                        description: getChildValue(field, 'description'),
                        bitOffset: parseNumber(getChildValue(field, 'bitOffset')),
                        bitWidth: parseNumber(getChildValue(field, 'bitWidth')),
                        access: getChildValue(field, 'access')
                    }));
            }

            function buildSearchIndex() {
                const trie = new SearchTrie();
                
                initialData.forEach((map, mapIndex) => {
                    if (map.name !== '${namespace}:memoryMap') return;
                    const mapName = getChildValue(map, 'name');
                    
                    // Index map name
                    trie.insert(mapName, {
                        type: 'Map',
                        mapName,
                        displayName: mapName,
                        hierarchy: mapName
                    });

                    const addressBlocks = map.children.filter(child => 
                        child.name === '${namespace}:addressBlock'
                    );

                    addressBlocks.forEach((block, blockIndex) => {
                        const blockName = getChildValue(block, 'name');
                        const blockHierarchy = \`\${mapName}.\${blockName}\`;
                        
                        // Index block name and hierarchy
                        trie.insert(blockName, {
                            type: 'Block',
                            mapName,
                            blockName,
                            displayName: blockName,
                            hierarchy: blockHierarchy
                        });
                        trie.insert(blockHierarchy, {
                            type: 'Block',
                            mapName,
                            blockName,
                            displayName: blockName,
                            hierarchy: blockHierarchy
                        });

                        const registers = block.children.filter(child => 
                            child.name === '${namespace}:register'
                        );

                        registers.forEach((register, registerIndex) => {
                            const registerName = getChildValue(register, 'name');
                            const description = getChildValue(register, 'description');
                            const addressOffset = getChildValue(register, 'addressOffset');
                            const hierarchy = \`\${mapName}.\${blockName}.\${registerName}\`;
                            
                            const registerItem = {
                                type: 'Register',
                                mapName,
                                blockName,
                                registerName,
                                displayName: registerName,
                                description,
                                addressOffset,
                                hierarchy,
                                register,
                                block,
                                map
                            };

                            trie.insert(registerName, registerItem);
                            
                            const pathParts = hierarchy.split('.');
                            for (let i = 0; i < pathParts.length; i++) {
                                const partialPath = pathParts.slice(i).join('.');
                                trie.insert(partialPath, registerItem);
                            }

                            const fields = getRegisterFields(register);
                            fields.forEach(field => {
                                const fieldHierarchy = \`\${hierarchy}.\${field.fieldName}\`;
                                const fieldItem = {
                                    ...registerItem,
                                    type: 'Field',
                                    fieldName: field.fieldName,
                                    fieldDescription: field.description,
                                    hierarchy: fieldHierarchy
                                };
                                
                                trie.insert(field.fieldName, fieldItem);
                                trie.insert(fieldHierarchy, fieldItem);
                            });
                        });
                    });
                });
                
                return trie;
            }

            // Search functionality
            function clearSearch() {
                const searchInput = document.getElementById('searchInput');
                const clearButton = document.getElementById('clearSearch');
                searchInput.value = '';
                clearButton.style.display = 'none';
                hideSearchResults();
            }

            function hideSearchResults() {
                const searchOverlay = document.getElementById('searchOverlay');
                const searchResults = document.getElementById('searchResults');
                const searchInput = document.getElementById('searchInput');
                const clearButton = document.getElementById('clearSearch');
                
                searchOverlay.style.display = 'none';
                searchResults.style.display = 'none';
                clearButton.style.display = 'none';
            }

            function highlightMatch(text, searchTerm) {
                if (!searchTerm) return text;
                const parts = text.split(new RegExp(\`(\${searchTerm})\`, 'gi'));
                return parts.map((part, i) => 
                    part.toLowerCase() === searchTerm.toLowerCase() ? 
                        \`<span style="color: #fd5002; font-weight: 500;">\${part}</span>\` : 
                        part
                ).join('');
            }

            function showSearchResults(results) {
                const searchOverlay = document.getElementById('searchOverlay');
                const searchResults = document.getElementById('searchResults');
                const searchTerm = document.getElementById('searchInput').value.trim();
                
                searchOverlay.style.display = 'block';
                searchResults.style.display = 'flex';
                
                searchResults.innerHTML = \`
                    <div style="padding: 16px; border-bottom: 1px solid #e2e8f0; font-weight: 600; font-size: 18px;">
                        Results (\${results.length})
                    </div>
                    <div style="overflow: auto; flex: 1;">
                        \${results.map(result => \`
                            <div class="search-result-item" style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; cursor: pointer;"
                                onclick="handleSearchResultClick('\${result.register.registerName}', '\${result.register.blockName}', '\${result.register.hierarchy.split('.')[0]}')"
                            >
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
                                    <div style="font-size: 14px;">\${highlightMatch(result.displayPath, searchTerm)}</div>
                                    <div style="font-size: 14px; color: #4a5568;">\${result.type}</div>
                                </div>
                                <div style="color: #4a5568; font-size: 14px;">\${result.address}</div>
                                \${result.description ? \`
                                    <div style="font-size: 14px; color: #718096;">\${highlightMatch(result.description, searchTerm)}</div>
                                \` : ''}
                            </div>
                        \`).join('')}
                    </div>
                \`;
            }

            // Add this debug function
            function debugSearch() {
                const searchOverlay = document.getElementById('searchOverlay');
                const searchResults = document.getElementById('searchResults');
            }

            function handleSearchResultClick(registerName, blockName, mapName) {
                const map = initialData.find(m => 
                    m.name === '${namespace}:memoryMap' && 
                    getChildValue(m, 'name') === mapName
                );
                
                if (!map) return;

                const block = map.children.find(b => 
                    b.name === '${namespace}:addressBlock' && 
                    getChildValue(b, 'name') === blockName
                );
                
                if (!block) return;

                const register = block.children.find(r => 
                    r.name === '${namespace}:register' && 
                    getChildValue(r, 'name') === registerName
                );
                
                if (!register) return;

                expandedMaps.add(mapName);
                expandedBlocks.add(blockName);

                selectRegister(register, block, map);
                renderTree();

                hideSearchResults();
            }

            function initializeSearch() {
                const searchInput = document.getElementById('searchInput');
                const searchTrie = optimizeForSearch(initialData);

                searchInput.addEventListener('input', (e) => {
                    const searchTerm = e.target.value.trim();
                    const clearButton = document.getElementById('clearSearch');
                    
                    if (searchTerm.length >= 2) {
                        const results = searchTrie.search(searchTerm);
                        if (results.length > 0) {
                            showSearchResults(results);
                            clearButton.style.display = 'block';
                        } else {
                            hideSearchResults();
                        }
                    } else {
                        hideSearchResults();
                        clearButton.style.display = searchTerm.length > 0 ? 'block' : 'none';
                    }
                });
            }

            // Tree manipulation functions
            function expandAll() {
                initialData.forEach(map => {
                    if (map.name !== '${namespace}:memoryMap') return;
                    const mapName = getChildValue(map, 'name');
                    expandedMaps.add(mapName);
                    
                    map.children
                        .filter(child => child.name === '${namespace}:addressBlock')
                        .forEach(block => {
                            const blockName = getChildValue(block, 'name');
                            expandedBlocks.add(blockName);
                        });
                });
                renderTree();
            }

            function collapseAll() {
                expandedMaps.clear();
                expandedBlocks.clear();
                renderTree();
            }

            function toggleMap(mapName) {
                if (expandedMaps.has(mapName)) {
                    expandedMaps.delete(mapName);
                } else {
                    expandedMaps.add(mapName);
                }
                renderTree();
            }
            function toggleBlock(blockName) {
                if (expandedBlocks.has(blockName)) {
                    expandedBlocks.delete(blockName);
                } else {
                    expandedBlocks.add(blockName);
                }
                renderTree();
            }

            function selectRegister(register, block, map) {
                activeRegister = extractRegisterInfo(register, block, map);
                renderDataPanel();
            }

            function extractRegisterInfo(register, block, map) {
                let resetValue;
                if (${is_2009}) {
                    const resetNode = register.children.find(child => child.name === '${namespace}:reset');
                    resetValue = resetNode ? getChildValue(resetNode.children[0], 'value') : '0x0';
                } else {
                    const registerReset = register.children.find(child => child.name === 'ipxact:resets');
                    if (registerReset) {
                        resetValue = registerReset.children[0]?.children[0]?.text || "'h0";
                    }
                    
                    const fieldReset = register.children
                        .find(child => child.name === 'ipxact:field')
                        ?.children
                        .find(child => child.name === 'ipxact:resets');
                    
                    resetValue = fieldReset?.children[0]?.children[0]?.text || "'h0";
                }
                return {
                    registerName: getChildValue(register, 'name'),
                    description: getChildValue(register, 'description'),
                    size: parseInt(getChildValue(register, 'size')),
                    resetValue: resetValue,
                    addressOffset: getChildValue(register, 'addressOffset'),
                    hierarchy: \`\${getChildValue(map, 'name')}.\${getChildValue(block, 'name')}.\${getChildValue(register, 'name')}\`,
                    fields: getRegisterFields(register)
                };
            }

            function renderTree() {
                const treeContent = document.getElementById('treeContent');
                treeContent.innerHTML = '';

                initialData.forEach((memoryMap, mapIndex) => {
                    if (memoryMap.name !== '${namespace}:memoryMap') return;
                    
                    const mapName = getChildValue(memoryMap, 'name');
                    const isMapExpanded = expandedMaps.has(mapName);
                    
                    const mapDiv = document.createElement('div');
                    mapDiv.innerHTML = \`
                        <div class="tree-item" style="display: flex; align-items: center; cursor: pointer; padding: 8px; border-radius: 4px; margin-bottom: 4px; background-color: \${isMapExpanded ? '#f8f9fa' : '#ffffff'}; transition: background-color 0.2s;" onclick="toggleMap('\${mapName}')">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 8px;">
                                \${isMapExpanded ? 
                                    '<polyline points="6 9 12 15 18 9"></polyline>' : 
                                    '<polyline points="9 18 15 12 9 6"></polyline>'}
                            </svg>
                            <span>\${mapName}</span>
                        </div>
                    \`;

                    if (isMapExpanded) {
                        const addressBlocks = memoryMap.children.filter(child => 
                            child.name === '${namespace}:addressBlock'
                        );

                        addressBlocks.forEach((block, blockIndex) => {
                            const blockName = getChildValue(block, 'name');
                            const isBlockExpanded = expandedBlocks.has(blockName);

                            const blockDiv = document.createElement('div');
                            blockDiv.innerHTML = \`
                                <div class="tree-item" style="display: flex; align-items: center; cursor: pointer; padding: 8px; border-radius: 4px; margin-bottom: 4px; background-color: \${isBlockExpanded ? '#f8f9fa' : '#ffffff'}; margin-left: 20px; transition: background-color 0.2s;" onclick="toggleBlock('\${blockName}')">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 8px;">
                                        \${isBlockExpanded ? 
                                            '<polyline points="6 9 12 15 18 9"></polyline>' : 
                                            '<polyline points="9 18 15 12 9 6"></polyline>'}
                                    </svg>
                                    <span>\${blockName}</span>
                                </div>
                            \`;

                            if (isBlockExpanded) {
                                const registers = block.children.filter(child => 
                                    child.name === '${namespace}:register'
                                );

                                registers.forEach((register, registerIndex) => {
                                    const registerName = getChildValue(register, 'name');
                                    const isActive = activeRegister && activeRegister.registerName === registerName;
                                    
                                    const registerDiv = document.createElement('div');
                                    registerDiv.innerHTML = \`
                                        <div class="tree-item" tabindex="0" style="display: flex; align-items: center; cursor: pointer; padding: 8px; border-radius: 4px; margin-bottom: 4px; background-color: \${isActive ? '#e2e6ff' : '#ffffff'}; margin-left: 40px; transition: background-color 0.2s;" 
                                            onclick="selectRegister(initialData[\${mapIndex}].children.filter(c => c.name === '${namespace}:addressBlock')[\${blockIndex}].children.filter(c => c.name === '${namespace}:register')[\${registerIndex}], initialData[\${mapIndex}].children.filter(c => c.name === '${namespace}:addressBlock')[\${blockIndex}], initialData[\${mapIndex}])">
                                            <span style="margin-left: 24px;">\${registerName}</span>
                                        </div>
                                    \`;
                                    blockDiv.appendChild(registerDiv);
                                });
                            }

                            mapDiv.appendChild(blockDiv);
                        });
                    }

                    treeContent.appendChild(mapDiv);
                });
            }

            function getBits(offset, width) {
                if (offset == (offset+width-1)) {
                    return \`[\${offset}]\`;
                }else{
                    return \`[\${offset+width-1}:\${offset}]\`;
                }
            }

            function getFieldReset(offset, width, reset) {
                let hex = ${is_2009} ? reset.split('0x')[1] : reset.split("'h")[1];
                let binary = parseInt(hex, 16).toString(2).padStart(32, '0');
                let extractedBits = binary.slice(31 - (width + offset - 1), 32 - offset);

                return ${is_2009} ? '0x' + parseInt(extractedBits, 2).toString(16) : "'h" + parseInt(extractedBits, 2).toString(16);
            }

            function renderDataPanel() {
                const dataPanel = document.getElementById('dataPanel');
                if (!activeRegister) {
                    dataPanel.innerHTML = '';
                    return;
                }

                dataPanel.innerHTML = \`
                    \${activeRegister.hierarchy ? \`
                        <div style="margin-bottom: 24px;">
                            <div style="font-size: 16px; font-weight: 600; margin-bottom: 12px; color: #2d3748;">Hierarchy</div>
                            <div style="background-color: white; padding: 12px 16px; border-radius: 8px; font-size: 14px; color: #4a5568; border: 1px solid #e2e8f0;">
                                \${activeRegister.hierarchy}
                            </div>
                        </div>
                    \` : ''}

                    <div style="margin-bottom: 24px;">
                        <div style="font-size: 16px; font-weight: 600; margin-bottom: 12px; color: #2d3748;">Register Overview</div>
                        <table style="width: 100%; border-collapse: collapse; background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                            <tbody>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Register Name</th>
                                    <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${activeRegister.registerName}</td>
                                </tr>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Description</th>
                                    <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${activeRegister.description}</td>
                                </tr>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Size</th>
                                    <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${activeRegister.size} bits</td>
                                </tr>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Reset Value</th>
                                    <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${activeRegister.resetValue}</td>
                                </tr>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Address Offset</th>
                                    <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${activeRegister.addressOffset}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div style="margin-bottom: 24px;">
                        <div style="font-size: 16px; font-weight: 600; margin-bottom: 12px; color: #2d3748;">Bit Field Layout</div>
                        <div style="display: flex; border: 1px solid #e2e8f0; margin-top: 20px; margin-bottom: 20px; position: relative; height: 120px; background-color: white; border-radius: 8px; overflow: hidden;">
                            \${Array.from({ length: activeRegister.size }, (_, i) => activeRegister.size - 1 - i)
                                .map(bit => \`
                                    <div style="flex: 1; border-right: 1px solid #e2e8f0; display: flex; flex-direction: column; align-items: center; padding: 4px 0; font-size: 12px;">
                                        <span style="color: #718096; font-size: 10px;">\${bit}</span>
                                    </div>
                                \`).join('')}
                            
                            \${activeRegister.fields.map((field, index) => {
                                const left = activeRegister.size - (field.bitOffset + field.bitWidth);
                                const width = field.bitWidth;
                                const leftPosition = (left / activeRegister.size) * 100;
                                const widthPercentage = (width / activeRegister.size) * 100;
                                
                                return \`
                                    <div style="position: absolute; top: 20px; height: 80px; background-color: #ebf4ff; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 12px; color: #4a5568; border: 2px solid #4299e1; left: \${leftPosition}%; width: calc(\${widthPercentage}% - 2px); box-sizing: border-box;">
                                        <span style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 100%; padding: 0 4px;">
                                            \${field.fieldName}
                                        </span>
                                    </div>
                                \`;
                            }).join('')}
                        </div>
                    </div>
                    <div style="margin-bottom: 24px;">
                        <div style="font-size: 16px; font-weight: 600; margin-bottom: 12px; color: #2d3748;">Field Details</div>
                        <table style="width: 100%; border-collapse: collapse; background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1);">
                            <thead>
                                <tr>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Field Name</th>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Description</th>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Bits</th>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Reset</th>
                                    <th style="background-color: #f8f9fa; padding: 12px 16px; text-align: left; font-size: 14px; font-weight: 600; color: #4a5568; border-bottom: 1px solid #e2e8f0;">Access</th>
                                </tr>
                            </thead>
                            <tbody>
                                \${activeRegister.fields.map(field => \`
                                    <tr>
                                        <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${field.fieldName}</td>
                                        <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${field.description}</td>
                                        <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${getBits(field.bitOffset, field.bitWidth)}</td>
                                        <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${getFieldReset(field.bitOffset, field.bitWidth, activeRegister.resetValue)}</td>
                                        <td style="padding: 12px 16px; border-bottom: 1px solid #e2e8f0; font-size: 14px; color: #2d3748;">\${field.access}</td>
                                    </tr>
                                \`).join('')}
                            </tbody>
                        </table>
                    </div>
                \`;
            }

            // Initialize the application
            document.addEventListener('DOMContentLoaded', () => {
                renderTree();
                initializeSearch();
                expandAll();
                document.getElementById('loadingOverlay').style.display = 'none';
            });

            // Handle clicks outside search results
            document.addEventListener('click', (event) => {
                const searchContainer = document.getElementById('searchContainer');
                const searchResults = document.getElementById('searchResults');
                const searchOverlay = document.getElementById('searchOverlay');
                
                if (!searchContainer.contains(event.target) && 
                    !searchResults.contains(event.target) && 
                    !searchOverlay.contains(event.target)) {
                    hideSearchResults();
                }
            });
        </script>
    </body>
</html>     

    `;
    return html;
}

const generateUVMRegisterModel = (xmlFile, output, ncoreModelName='ral_sys_ncore', ncoreFileName='ncore_system_register_map.sv', fscModelName='ral_sys_resiliency', fscFileName='ncore_fsc_system_register_map.sv') => {
    let regModel = '';
    let ncoreRegModel = '';
    let fscRegModel = '';
    let success = false;
    let proj = 'ncore';

    let data = null;

    try {
        data = fs.readFileSync(xmlFile, 'utf8');
    } catch (error) {
        console.error('Error reading file:', error.message);
        return;
    }

    const xml = parseXML(data);
    const is_2014 = xml.attributes["xsi:schemaLocation"].includes("IPXACT");
    const is_2009 = xml.attributes["xsi:schemaLocation"].includes("SPIRIT");
    const identifier = is_2014 ? "ipxact":"spirit";

    const memoryMapsElement = xml.children.find((child) => child.name === `${identifier}:memoryMaps`);
    if (!memoryMapsElement) {
        console.error(`Could not find ${identifier}:memoryMaps element`);
        return;
    }

    const memoryMaps = memoryMapsElement.children.filter(child => child.name === `${identifier}:memoryMap`);
    console.log(genRegisterDoc(memoryMaps, is_2009));
    
    // Headers
    ncoreRegModel += `/////////////////////////////////////////////////////////////////\n`;
    ncoreRegModel += `// Generated using reg_gen. Copyright Arteris, Inc. 2024       //\n`;
    ncoreRegModel += `/////////////////////////////////////////////////////////////////\n\n`;
    ncoreRegModel += `\`ifndef RAL_${proj.toUpperCase()}\n`;
    ncoreRegModel += `\`define RAL_${proj.toUpperCase()}\n\n`;
    ncoreRegModel += `import uvm_pkg::*;\n\n`;

    if (memoryMaps.length > 1) {
        fscRegModel += `/////////////////////////////////////////////////////////////////\n`;
        fscRegModel += `// Generated using reg_gen. Copyright Arteris, Inc. 2024       //\n`;
        fscRegModel += `/////////////////////////////////////////////////////////////////\n\n`;
        fscRegModel += `\`ifndef RAL_${proj.toUpperCase()}_FSC\n`;
        fscRegModel += `\`define RAL_${proj.toUpperCase()}_FSC\n\n`;
        fscRegModel += `import uvm_pkg::*;\n\n`;
    }
    
    for (let i = 0; i < memoryMaps.length; i += 1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        
        addrBlocks.forEach((addrBlock) => {
            const registers = addrBlock.children.filter(child => child.name === `${identifier}:register`);
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const baseAddressElement = addrBlock.children.find(child => child.name === `${identifier}:baseAddress`);
            let baseAddress = null;
            if (is_2014) {
                baseAddress = baseAddressElement ? baseAddressElement.text : '';
            }else{
                baseAddress = baseAddressElement ? baseAddressElement.text.replace("0x","'h") : '';
            }
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            const addrWidth = addrWidthElement ? addrWidthElement.text : '';

            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                const regSizeElement = register.children.find(child => child.name === `${identifier}:size`);
                const regSize = regSizeElement ? regSizeElement.text : '';
                
                regModel += `class ral_${mapName}_${blockName}_${regName} extends uvm_reg;\n`;
                regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName}_${regName})\n\n`;
                
                const fields = register.children.filter(child => child.name === `${identifier}:field`);

                let resetsElement = null;
                if (is_2009) {
                    resetsElement = register.children.find(child => child.name === `${identifier}:reset`);
                }

                let regResetValue = is_2014 ? null : resetsElement.children[0].text.split("0x")[1];
                let hasReset = (regResetValue && resetsElement) ? 1 : 0;
                let bitCount = 0;

                fields.forEach((field) => {
                    const fieldNameElement = field.children.find(child => child.name === `${identifier}:name`);
                    const fieldName = fieldNameElement ? fieldNameElement.text : '';
                    regModel += `    rand uvm_reg_field ${fieldName};\n`;
                });
                regModel += `\n    function new(string name = "ral_${mapName}_${blockName}_${regName}");\n`;
                regModel += `        super.new(name, ${regSize}, build_coverage(UVM_NO_COVERAGE));\n`
                regModel += `    endfunction: new\n\n`
                
                regModel += `    virtual function void build();\n`;
                fields.forEach((field) => {
                    const fieldNameElement = field.children.find(child => child.name === `${identifier}:name`);
                    const fieldName = fieldNameElement ? fieldNameElement.text : '';
                    const bitWidthElement = field.children.find(child => child.name === `${identifier}:bitWidth`);
                    const bitOffsetElement = field.children.find(child => child.name === `${identifier}:bitOffset`);

                    let bitWidth = null;
                    let bitOffset = null;
                    if(is_2014){
                        bitWidth = bitWidthElement ? parseInt(bitWidthElement.text.replace(/'h/, ''), 16) : 0;
                        bitOffset = bitOffsetElement ? parseInt(bitOffsetElement.text.replace(/'h/, ''), 16) : 0;
                    }else{
                        bitWidth = bitWidthElement ? parseInt(bitWidthElement.text) : 0;
                        bitOffset = bitOffsetElement ? parseInt(bitOffsetElement.text) : 0;
                    }
                    const volatileElement = field.children.find(child => child.name === `${identifier}:volatile`);
                    const volatile = volatileElement && volatileElement.text === 'true' ? 1 : 0;
                    let resetValue = 0;
                    if (is_2014) {
                        resetsElement = field.children.find(child => child.name === `${identifier}:resets`);
                        let resetValue = null;
                        if (resetsElement) {
                            let resetChild = resetsElement.children.find(child => child.name === `${identifier}:reset`);
                            if (resetChild && resetChild.children) {
                                let valueChild = resetChild.children.find(child => child.name === `${identifier}:value`);
                                resetValue = valueChild ? valueChild.text : null;
                            }
                        }

                    }else{
                        resetValue = `'h${extractBits(regResetValue, parseInt(bitCount), bitWidth)}`;
                    }
                    
                    const isRand = 0;
                    const accessible = (((bitOffset % 8) == 0 ) && (((bitOffset+bitWidth) % 8) == 0)) ? 1 : 0;
                    const modifiedWriteValueElement = field.children.find(child => child.name === `${identifier}:modifiedWriteValue`);
                    const modifiedWriteValue = modifiedWriteValueElement ? modifiedWriteValueElement.text : null;
                    const accessElement = field.children.find(child => child.name === `${identifier}:access`);
                    const access = getAccessType(accessElement ? accessElement.text : '', modifiedWriteValue);
                    
                    regModel += `        this.${fieldName} = uvm_reg_field::type_id::create("${fieldName}",,get_full_name());\n`;
                    regModel += `        this.${fieldName}.configure(this, ${bitWidth}, ${bitOffset}, "${access}", ${volatile}, ${bitWidth}${resetValue || '0'}, ${hasReset}, ${isRand}, ${accessible});\n`;
                    bitCount += parseInt(bitWidth);
                });
                regModel += `    endfunction: build\n\n`;
                regModel += `endclass:ral_${mapName}_${blockName}_${regName}\n\n`;
            });

            regModel += `class ral_${mapName}_${blockName} extends uvm_reg_block;\n`;
            regModel += `    \`uvm_object_utils(ral_${mapName}_${blockName})\n\n`;
            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                regModel += `    rand ral_${mapName}_${blockName}_${regName} ${regName};\n`;
            });
            regModel += `\n    function new (string name = "ral_${mapName}_${blockName}");\n`;
            regModel += `        super.new(name, UVM_NO_COVERAGE);\n`;
            regModel += `    endfunction: new\n\n`;

            regModel += `    virtual function void build();\n`;
            regModel += `        this.default_map = create_map("ral_${mapName}_${blockName}", ${baseAddress}, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
            registers.forEach((register) => {
                const regNameElement = register.children.find(child => child.name === `${identifier}:name`);
                const regName = regNameElement ? regNameElement.text : '';
                let access = 'RO';
                const fields = register.children.filter(child => child.name === `${identifier}:field`);
                //FIXME: Need to understand the below logic more
                for (let i=0; i<fields.length; i+= 1) {
                    const fieldAccessElement = fields[i].children.find(child => child.name === `${identifier}:access`);
                    if (fieldAccessElement && fieldAccessElement.text != 'read-only') {
                        access = 'RW';
                        break;
                    }
                }
                
                const regOffsetElement = register.children.find(child => child.name === `${identifier}:addressOffset`);
                let regOffset = null;
                if(is_2014) {
                    regOffset = regOffsetElement ? regOffsetElement.text : '';
                }else{
                    regOffset = regOffsetElement ? regOffsetElement.text.replace("0x","'h") : '';
                }
        
                regModel += `        this.${regName} = ral_${mapName}_${blockName}_${regName}::type_id::create("${regName}", , get_full_name());\n`;
                regModel += `        this.${regName}.configure(this, null, "");\n`;
                regModel += `        this.${regName}.build();\n`;
                regModel += `        this.default_map.add_reg(this.${regName}, \`UVM_REG_ADDR_WIDTH${regOffset}, "${access}", 0);\n\n`;

            });
            regModel += `    endfunction: build\n\n`;
            regModel += `endclass: ral_${mapName}_${blockName}\n\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }
    ncoreRegModel += `class ${ncoreModelName} extends uvm_reg_block;\n`;
    ncoreRegModel += `    \`uvm_object_utils(${ncoreModelName})\n\n`;
    if (memoryMaps.length > 1) {
        fscRegModel += `class ${fscModelName} extends uvm_reg_block;\n`;
        fscRegModel += `    \`uvm_object_utils(${fscModelName})\n\n`;
    }
    regModel = '';
    let addrWidth = 0;
    for (let i=0; i<memoryMaps.length; i+=1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        addrBlocks.forEach((addrBlock) =>{
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            addrWidth = addrWidthElement ? addrWidthElement.text : '0';
            regModel += `    ral_${mapName}_${blockName} ${blockName};\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }

    ncoreRegModel += `    function new(string name = "${ncoreModelName}");\n`;
    ncoreRegModel += `        super.new(name);\n`;
    ncoreRegModel += `    endfunction: new\n\n`;

    ncoreRegModel += `    function void build();\n`;
    ncoreRegModel += `        this.default_map = create_map("${ncoreModelName}", 0, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;

    if (memoryMaps.length > 1) {
        fscRegModel += `    function new(string name = "${fscModelName}");\n`;
        fscRegModel += `        super.new(name);\n`;
        fscRegModel += `    endfunction: new\n\n`;

        fscRegModel += `    function void build();\n`;
        fscRegModel += `        this.default_map = create_map("${fscModelName}", 0, ${addrWidth/8}, UVM_LITTLE_ENDIAN, 0);\n`;
    }

    regModel = '';
    for (let i=0; i<memoryMaps.length; i+=1) {
        const mapNameElement = memoryMaps[i].children.find(child => child.name === `${identifier}:name`);
        const mapName = mapNameElement ? mapNameElement.text : '';
        const addrBlocks = memoryMaps[i].children.filter(child => child.name === `${identifier}:addressBlock`);
        addrBlocks.forEach((addrBlock) =>{
            const blockNameElement = addrBlock.children.find(child => child.name === `${identifier}:name`);
            const blockName = blockNameElement ? blockNameElement.text : '';
            const baseAddressElement = addrBlock.children.find(child => child.name === `${identifier}:baseAddress`);
            let baseAddress = null;
            if(is_2014) {
                baseAddress = baseAddressElement ? baseAddressElement.text : '';
            }else{
                baseAddress = baseAddressElement ? baseAddressElement.text.replace("0x","'h") : '';
            }
            const addrWidthElement = addrBlock.children.find(child => child.name === `${identifier}:width`);
            addrWidth = addrWidthElement ? addrWidthElement.text : '0';
            regModel += `        this.${blockName} = ral_${mapName}_${blockName}::type_id::create("${blockName}", , get_full_name());\n`;
            regModel += `        this.${blockName}.configure(this, "");\n`;
            regModel += `        this.${blockName}.build();\n`;
            regModel += `        this.default_map.add_submap(this.${blockName}.default_map, \`UVM_REG_ADDR_WIDTH${baseAddress});\n\n`;
        });
        if (mapName === 'resiliency') {
            fscRegModel += regModel;
        }else {
            ncoreRegModel += regModel;
        }
        regModel = '';
    }
    ncoreRegModel += `    endfunction: build\n\n`;
    ncoreRegModel += `endclass: ${ncoreModelName}\n`;

    ncoreRegModel += `\`endif`;

    if (memoryMaps.length > 1) {
        fscRegModel += `    endfunction: build\n\n`;
        fscRegModel += `endclass: ${fscModelName}\n`;

        fscRegModel += `\`endif`;
    }

    const ncoreOutput = path.join(output, ncoreFileName);
    const fscOutput = path.join(output, fscFileName);

    try {
        fs.writeFileSync(ncoreOutput, ncoreRegModel);
        console.log(`UVM register model generated at: ${ncoreOutput}`);
    }catch(error) {
        console.error(`Could not write to ${ncoreFileName} file:`, err);
        return;
    }

    if (memoryMaps.length > 1) {
        fs.writeFileSync(fscOutput, fscRegModel, (err) => {
            if (err) {
                console.error(`Could not write the ${fscFileName} file:`, err);
                return;
            }
            console.log(`UVM register model generated at: ${fscOutput}`);
        });
    }

    success = true;
    return success;
}

function printUsage() {
    console.log("Usage: node reg_gen.js -ipxact <path\\to\\ipxact2009|2014> [options]");
    console.log("Options:");
    console.log("  -ipxact <path>               Path to the IP-XACT file (2009 or 2014 version)");
    console.log("  -o <path>                    Path where output files should be dumped (default: ./)")
    console.log("  -ncoreFileName <name>        Name for the ncore output file (default: ncore_system_register_map.sv)");
    console.log("  -fscFileName <name>          Name for the fsc output file (default: ncore_fsc_system_register_map.sv)");
    console.log("  -ncoreModelName <name>       Name for the ncore model (default: ral_sys_ncore)");
    console.log("  -fscModelName <name>         Name for the fsc model (default: ral_sys_resiliency)");
    console.log("  -h, -help, --help, --h       Display this help message");
}

function parseCommandLineArgs(args) {
    let outputFilePath = process.cwd();
    let ncoreFileName = 'ncore_system_register_map.sv';
    let fscFileName = 'ncore_fsc_system_register_map.sv';
    let ncoreModelName = 'ral_sys_ncore';
    let fscModelName = 'ral_sys_resiliency';
    if (args.includes('-h') || args.includes('-help') || args.includes('--h') || args.includes('--help')) {
        printUsage();
        process.exit(0);
    }

    if (args.length === 0 || args.indexOf('-ipxact') === -1 || args[args.indexOf('-ipxact') + 1] === undefined) {
        console.error("Error: Invalid arguments");
        printUsage();
        process.exit(1);
    }

    let xmlFile = args[args.indexOf('-ipxact') + 1];
    
    if (args.indexOf('-o') !== -1 && args[args.indexOf('-o') + 1] !== undefined) {
        outputFilePath = args[args.indexOf('-o') + 1];
    }
    if (args.indexOf('-ncoreFileName') !== -1 && args[args.indexOf('-ncoreFileName') + 1] !== undefined) {
        ncoreFileName = args[args.indexOf('-ncoreFileName') + 1];
    }
    if (args.indexOf('-fscFileName') !== -1 && args[args.indexOf('-fscFileName') + 1] !== undefined) {
        fscFileName = args[args.indexOf('-fscFileName') + 1];
    }
    if (args.indexOf('-ncoreModelName') !== -1 && args[args.indexOf('-ncoreModelName') + 1] !== undefined) {
        ncoreModelName = args[args.indexOf('-ncoreModelName') + 1];
    }
    if (args.indexOf('-fscModelName') !== -1 && args[args.indexOf('-fscModelName') + 1] !== undefined) {
        fscModelName = args[args.indexOf('-fscModelName') + 1];
    }
    return { xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName };
}

if (require.main === module) {
    const { xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName } = parseCommandLineArgs(process.argv.slice(2));
    generateUVMRegisterModel(xmlFile, outputFilePath, ncoreModelName, ncoreFileName, fscModelName, fscFileName);
} else {
    module.exports = generateUVMRegisterModel;
}