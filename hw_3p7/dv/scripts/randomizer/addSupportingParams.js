const randomizerParams = {
    "projectName": "hw_random_config",
    "ncoreVersion": "3.7",
    "randomizerVersion": "2.0"
}

// const getMemoryInterleavingBits = (nDmis, wAddr, chance) => {
//     const result = ['0', '0', '0', '0'];
//     const log2NDmis = Math.log2(nDmis);
  
//     if (log2NDmis === 0) {
//         return result;
//     }
  
//     const numToGenerate = Math.min(Math.floor(log2NDmis), 4);
//     const usedNumbers = new Set();
  
//     for (let i = 0; i < numToGenerate; i++) {
//         let randomNum;
//         do {
//             randomNum = chance.integer({ min: 6, max: wAddr - 1 });
//         } while (usedNumbers.has(randomNum));
        
//         usedNumbers.add(randomNum);
//         result[i] = randomNum.toString();
//     }
  
//     return result.sort((a, b) => parseInt(b) - parseInt(a));
// }

// const getDceInterleavingBits = (nDCEs, wAddr, memoryBits, chance) => {
//     const log2NDCEs = Math.log2(nDCEs);
//     const result = [];
//     const usedNumbers = new Set(memoryBits.map(Number));
  
//     for (let i = 0; i < log2NDCEs; i++) {
//       let randomNum;
//       do {
//         randomNum = chance.integer({ min: 6, max: wAddr - 1 });
//       } while (usedNumbers.has(randomNum));
      
//       usedNumbers.add(randomNum);
//       result.push(randomNum.toString());
//     }
  
//     return result.sort((a, b) => parseInt(b) - parseInt(a));
// }

const addSupportingParams = (obj) => {
    obj['params']['randomizer'] = randomizerParams;

    return obj;
}

module.exports = addSupportingParams;