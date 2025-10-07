const fs = require('fs');
const path = require('path');

const MAX_RANGE_SIZE = 1000;

const resolvePath = (_path) => {
    return path.resolve(_path);
}

const logger = (message, seed) => {
    const logPath = resolvePath(`${process.env.MAESTRO_EXAMPLES}/../base_configs/hw_randomizer_config_${seed}/randomizer.log`);
    fs.appendFile(logPath, `${message}\n`, err => {
        if (err) console.error('Error writing to the log file:', err);
    });
}

const makeDir = (dirPath) => {
    const dirName = resolvePath(dirPath);
    if (!fs.existsSync(dirName)) {
        fs.mkdirSync(dirName, { recursive: true });
    }
}

const cleanLogs = (seed) => {
    const logPath = resolvePath(`${process.env.MAESTRO_EXAMPLES}/../base_configs/hw_randomizer_config_${seed}/randomizer.log`);
    fs.access(logPath, fs.constants.F_OK, (err) => {
        if (err) {
            console.log(`Log file for seed ${seed} doesn't exist. No cleanup needed.`);
            logger(`Log file for seed ${seed} doesn't exist. No cleanup needed.`, seed);
            return;
        }
        
        fs.unlink(logPath, (unlinkErr) => {
            if (unlinkErr) {
                console.error(`Error: Unable to remove existing log file for seed ${seed}:`, unlinkErr);
            } else {
                console.log(`Successfully removed log file for seed ${seed}.`);
                logger(`Successfully removed log file for seed ${seed}.`, seed);
            }
        });
    });
}

// FIXME: after the typo is resolved by Ahmed, remove the min_max condition and make min, max const instead of let
const parseRangeString = (rangeString) => {
    let [min, max] = rangeString.split(':').map(Number);
    if (min > max) {
        const t = min;
        min = max;
        max = t;
    }
    return { min, max };
};


module.exports = {
    logger,
    makeDir,
    cleanLogs,
    resolvePath
};