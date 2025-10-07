const fs = require('fs').promises;
const path = require('path');
const util = require('util');
const execAsync = util.promisify(require('child_process').exec);

async function getAssetFiles(buildDir) {
  try {
    const jsFiles = await fs.readdir(path.join(buildDir, 'static/js'));
    const cssFiles = await fs.readdir(path.join(buildDir, 'static/css'));
    
    const mainJsFile = jsFiles.find(file => file.startsWith('main.') && file.endsWith('.js') && !file.endsWith('.map') && !file.endsWith('.LICENSE.txt'));
    const mainCssFile = cssFiles.find(file => file.startsWith('main.') && file.endsWith('.css') && !file.endsWith('.map'));
    
    if (!mainJsFile) throw new Error('Main JavaScript file not found');
    if (!mainCssFile) throw new Error('Main CSS file not found');

    return {
      js: mainJsFile,
      css: mainCssFile
    };
  } catch (error) {
    console.error('Error reading asset files:', error);
    throw error;
  }
}

function generateHtml(data, assets, outPath) {
  return `
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Parameter Coverage</title>
        <link rel="stylesheet" href="static/css/${assets.css}">
    </head>
    <body>
        <div id="root">
            <p>This text should be replaced by React content if hydration is working.</p>
        </div>
        <script>
            window.__INITIAL_DATA__ = [${JSON.stringify(data.params)}];
        </script>
        <script src="static/js/${assets.js}"></script>
    </body>
    </html>
  `;
}

async function generateReport(data, outputPath) {
  try {
    const buildDir = `${process.env.RANDOMIZER_HOME}/params/coverage/build/`;
    const command = `cp -rf "${buildDir}" "${outputPath}"`;

    // exec(command, (error, stdout, stderr) => {
    //     if (error) {
    //         console.error(`Error: ${error.message}`);
    //         return;
    //     }
    //     if (stderr) {
    //         console.error(`stderr: ${stderr}`);
    //         return;
    //     }
    // });
    try {
        await execAsync(command);
        console.log(`Successfully copied ${buildDir} to ${outputPath}`);
    } catch (error) {
        console.error(`Error during copy operation: ${error.message}`);
        throw error;
    }
    
    const outputDir = `${outputPath}/build`;

    const assets = await getAssetFiles(outputDir);
    
    const html = generateHtml(data, assets, outputDir);
    
    await fs.writeFile(path.join(outputDir, 'param_cov_report.html'), html);
    
    console.log(`Parameter Coverage report has been created at ${outputDir}/param_cov_report.html`);
  } catch (error) {
    console.error('Error generating report:', error);
    throw error;
  }
}

module.exports = generateReport;