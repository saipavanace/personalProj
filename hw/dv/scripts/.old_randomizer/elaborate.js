const utils = require('./utils.js');

function elaborate(obj, seed) {
    for (const key in obj) {
        if (key === "count") {
            const countValue = parseInt(utils.getRandomValue(obj[key], seed++), 10);
            const newObj = {};
            newObj[key] = countValue;
            const objArray = [];
            for (let i = 0; i < countValue; i++) {
                const innerObj = {};
                for (const innerKey in obj) {
                    if (innerKey !== "count") {
                        innerObj[innerKey] = utils.getRandomValue(obj[innerKey],seed++);
                    }
                }
                objArray.push(innerObj);
            }
            newObj["items"] = objArray;
            return newObj;
        } else if (typeof obj[key] === "object" && obj[key] !== null) {
            if (key === 'clock' || key === 'system' || key === 'safety') {
                const innerObj = {};
                for (innerKey in obj[key]) {
                    innerObj[innerKey] = utils.getRandomValue(obj[key][innerKey], seed++);
                }
                obj[key] = innerObj;
            }else{
                obj[key] = elaborate(obj[key], seed);
            }
        }
    }
    return obj;
};

module.exports = elaborate;