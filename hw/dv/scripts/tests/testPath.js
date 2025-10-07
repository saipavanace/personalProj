
const execSync = require('child_process').execSync;

var WORK_TOP = process.env.WORK_TOP;

describe('testPath.js', function () {
    it('testPath', testPath);
    it('testErrorinOutput', testErrorinOutput);

 });            


function testPath()
{
	var fs = require('fs');
	var config = WORK_TOP +'/dv/sub_sys/tb/fsys_testlist.json';

	config = fs.readFileSync(config, 'utf8');
	config = JSON.parse(config).config;

	function testPathJson(element, fs) {
		var fpath = element.path.replace("$WORK_TOP",WORK_TOP);
		try {
                	fs.statSync(fpath);
			console.log('info:', `Good: ${fpath} exists!`);
		} catch(e) {
			throw('error:', ` ${fpath} does not exist!`);
		}
	}
	
	config.forEach(function(element) {
		testPathJson(element, fs);
	});
}

function testErrorinOutput()
{	
	try {
                execSync("node" + " " + WORK_TOP + "/dv/scripts/gen_my_regr.js -e fsys -f" + " " + WORK_TOP + "/dv/sub_sys/tb/fsys_testlist.json -t fsys");
                console.log('info:', `Good: The Json file does not have any syntax errors!`);
        } 
	catch(e) {
                throw('error:', `There is a syntax error in the JSON file!`);
        }
}

