const fs = require('fs');
const path = require('path');
const {
    indentIncreaseKeywords,
    indentDecreaseKeywords,
    indentBothKeywords,
    specialKeywords
} = require('./svIndentKeywords');

function formatSystemVerilog(filePath) {
    const fullPath = path.resolve(filePath);

    if (!fs.existsSync(fullPath)) {
        console.error(`File not found: ${fullPath}`);
        process.exit(1);
    }

    const content = fs.readFileSync(fullPath, 'utf8');
    let lines = content.split('\n');
    
    lines = lines.filter((line, index, array) => {
        if (line.trim() === '' && array[index - 1]?.trim() === '') {
            return false;
        }
        return true;
    });
    
    let indentLevel = 0;
    const indentChar = '  '; // 2 spaces for indentation
    
    lines = lines.map((line, index, array) => {
        const trimmedLine = line.trim();
        const words = trimmedLine.split(/\s+/);
        const firstWord = words[0];
        const rawLastWord = words[words.length - 1];
        const lastWord = rawLastWord.split(':')[0];

        
        // Check for indent decrease at the start of the line
        if (indentDecreaseKeywords.some((keyword) => {
            const regex = new RegExp(`\\b${keyword}\\b`);
            return regex.test(trimmedLine);
        }) || firstWord === 'end') {
            indentLevel = Math.max(0, indentLevel - 1);
        }
        
        // Apply current indentation
        let formattedLine = indentChar.repeat(indentLevel) + trimmedLine;
        
        // Check for indent increase at the end of the line
        if ((indentIncreaseKeywords.some((keyword) => {
            const regex = new RegExp(`\\b${keyword}\\b`);
            return regex.test(trimmedLine);
        }) || lastWord === 'begin') ||
            (specialKeywords.some((keyword) => {
                const regex = new RegExp(`\\b${keyword}\\b`);
                return regex.test(trimmedLine);
            }) && lastWord !== 'begin')) {
            indentLevel++;
        }
        
        // Handle 'both' keywords
        if (indentBothKeywords.some((keyword) => {
            const regex = new RegExp(`\\b${keyword}\\b`);
            return regex.test(trimmedLine);
        })) {
            indentLevel++;
        }
        
        // Special handling for `else and `elsif
        if (firstWord === '`else' || firstWord === '`elsif') {
            indentLevel++;
        }

        // Handle 'repeat' keyword
        if (firstWord === 'repeat' && lastWord === 'begin') {
            indentLevel++;
        }

        return formattedLine;
    });
    
    const formattedContent = lines.join('\n');
    fs.writeFileSync(fullPath, formattedContent);
    console.log(`File formatted successfully: ${fullPath}`);
}

// Check if a file path is provided as a command-line argument
if (process.argv.length < 3) {
    console.error('Please provide a file path as an argument.');
    process.exit(1);
}

// Get the file path from command-line arguments
const filePath = process.argv[2];

// Run the formatter
formatSystemVerilog(filePath);