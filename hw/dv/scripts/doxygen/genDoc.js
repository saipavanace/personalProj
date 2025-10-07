const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Variables
const srcObj = {};
let classStarted = 0;
let lineNumber = 0;

// Create cppClass directory
try {
    fs.mkdirSync('cppClass');
} catch (err) {
    if (err.code !== 'EEXIST') throw err;
}

// Recursive function to process files
function processDirectory(directory) {
    fs.readdirSync(directory).forEach(filename => {
        const filePath = path.join(directory, filename);
        
        if (fs.statSync(filePath).isDirectory()) {
            // If it's a directory, recursively process it
            processDirectory(filePath);
        } else {
            // If it's a file, process it
            const originalFileName = path.basename(filePath);
            const fileName = path.parse(originalFileName).name;
            const relativePath = path.relative(process.cwd(), directory);
            const outputDir = path.join('cppClass', relativePath);
            
            // Create output directory if it doesn't exist
            try {
                fs.mkdirSync(outputDir, { recursive: true });
            } catch (err) {
                if (err.code !== 'EEXIST') throw err;
            }
            
            try {
                execSync(`perl doxygen_filter "${filePath}" > "${path.join(outputDir, fileName + '.cpp')}"`);
                console.log(`Processed: ${filePath}`);
            } catch (error) {
                console.error(`Error processing file ${filePath}: ${error.message}`);
            }
        }
    });
}

// Start processing from the current working directory
processDirectory(process.cwd());

console.log('Processing complete.');