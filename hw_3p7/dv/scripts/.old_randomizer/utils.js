const seededRandom = (min, max, seed)  => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
}

const getRandomValue = (inputString, seed) => {
    const cleanedString = inputString.replace(/[\[\]']/g, '');

    if (cleanedString.includes(':')) {
        const [min, max] = cleanedString.split(':').map(Number);
        return `${seededRandom(min,max, seed)}`;
    } else {
        const values = cleanedString.split(',');
        return values[seededRandom(0, values.length - 1, seed)].trim();
    }
}

const closestLowerPowerOf2 = (k) => {
    let powerOf2 = 1;
    while (powerOf2 * 2 <= k) {
        powerOf2 *= 2;
    }
    return powerOf2;
}

const closestHigherPowerOf2 = (k) => {
    let powerOf2 = 1;
    while (powerOf2 <= k) {
        powerOf2 *= 2;
    }
    return powerOf2;
}

const getInterleavingBits = (addr, units, seed, uniqueBits='') => {
    const nBits = Math.log2(units);
    const bitsArray = [];
    const uniqueArray = uniqueBits.trim() !== "" ? uniqueBits.split(" ").map(Number) : [];
    for (let i=0; i<nBits; i++){
        let randomValue = '';
        let temp = 0;
        do {
            randomValue = getRandomValue(`[6:${addr-1}]`, seed++);
            temp = parseInt(randomValue);
        }while(bitsArray.includes(randomValue) || uniqueArray.includes(temp));
        bitsArray.push(randomValue);
    }
    bitsArray.sort((a, b) => {
        return a - b;
    });
    return bitsArray.join(' ');
}

const getLog2Zeros = (units) => {
    const nBits = Math.log2(units);
    const bitsArray = [];
    for (let i=0; i<nBits; i++){
        bitsArray.push('0');
    }
    return bitsArray.join(' ');
}

const getClosestFactors = (number) => {
    let factors = [];
    let sqrt = Math.sqrt(number);
    for (let i = Math.floor(sqrt); i > 0; i--) {
        if (number % i === 0) {
            factors.push([i, number / i]);
            break;
        }
    }
    if (factors.length === 0) {
        factors.push([1, number]);
    }
    factors[0].sort((a, b) => b - a);
    factors[0] = factors[0].map(element => element - 1);
    return factors[0];
}

const stripIndent = (str) => {
    // Find the minimum common indentation
    const match = str.match(/^\s*(?=\S)/gm);
    const indent = match && Math.min(...match.map((line) => line.length));

    // Remove the minimum common indentation from each non-blank line
    if (indent) {
        return str
            .split('\n')
            .map((line) => {
                return line.match(/^\s*$/) ? line : line.slice(indent);
            })
            .join('\n');
    }
    return str;
};

module.exports = {
    getRandomValue: getRandomValue,
    closestLowerPowerOf2: closestLowerPowerOf2,
    closestHigherPowerOf2: closestHigherPowerOf2,
    getClosestFactors: getClosestFactors,
    getInterleavingBits: getInterleavingBits,
    stripIndent: stripIndent,
    getLog2Zeros: getLog2Zeros
};