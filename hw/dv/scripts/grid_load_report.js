#!/usr/bin/env node

//Packages needed for this script
'use strict';
var fs   = require('fs');
var cli  = require('commander');
var path = require('path');
var proc = require('child_process');
var dt   = new Date();




//var fileRead = fs.readFileSync("").toString();
Object.size = function(obj) {
    var size = 0, key;
    for (key in obj) {
        if (obj.hasOwnProperty(key)) size++;
        }
    return size;
};

//Source Tools & environment variables
exec_cmd('qacct -d 1 -j > /home/'+ process.env.USER +'/cron_scripts/grid_log.txt');

var lineReader = require('readline').createInterface({
  input: require('fs').createReadStream('/home/'+ process.env.USER +'/cron_scripts/grid_log.txt')
  });

  var one_entry = [];
  var array_entry = [];
  lineReader.on('line', function (line) {
        if( line !== "=============================================================="){ 
            if(line.match(/arid/)){
                var rw = line.split(/\s+/);
                var key   = rw[0];
                var value = rw[1];
                one_entry[key] = value;

                if(Object.keys(one_entry).length > 0){
                    array_entry.push(one_entry);
                    one_entry = [];
                }

            }else{
                var rw = line.split(/\s+/);
                var key   = rw[0];
                var value = rw[1];
                one_entry[key] = value;
            }
       }
    }).on('close',function(){

       var writef   = '/home/'+ process.env.USER +'/cron_scripts/grid_script_output.txt';

       var wdata   = '\n\n';
       wdata = countTotalJobs(array_entry,wdata);
       wdata = findTotalFailedJobs(array_entry,wdata);
       wdata = findJobsByProject(array_entry,wdata);
       wdata = findJobsByUser(array_entry,wdata);
       wdata = findLongJobs(array_entry, wdata);
       wdata = findJobTimePerBlock(array_entry, wdata);

       fs.writeFileSync(writef, wdata);
       fs.chmodSync(writef, 511);
    });
 
function countTotalJobs(array_entry, wdata){
    wdata += "Total Jobs " + array_entry.length + "\n";
    return(wdata);
}


function findJobsByProject(array_entry, wdata){
    var num_proj = [];
    var proj_job_count = [];
    var count=0;
    var pad_str;
    var max_str_length = -1;

    for(var i=0;i<array_entry.length;i++) {
        if(num_proj.indexOf(array_entry[i].project) !== -1 ){
            var indx = num_proj.indexOf(array_entry[i].project);
            proj_job_count[indx] = proj_job_count[indx]+1;
        } else{
            num_proj.push(array_entry[i].project);
            proj_job_count.push(1);
        }

    }

    wdata += "Jobs Per Project " + "\n";

    for(var i=0;i<num_proj.length;i++) {
        if(max_str_length < num_proj[i].length){
            max_str_length = num_proj[i].length;
        }
    }
    for(var i=0;i<num_proj.length;i++) {
        pad_str = padright(num_proj[i], max_str_length+10);
        wdata += "Project: " + pad_str + " Job Count: " + proj_job_count[i] + "\n";
    }
    wdata += "\n";
    return(wdata);
}


function findJobsByUser(array_entry, wdata){
    var num_user = [];
    var user_job_count = [];
    var user_job_proj_count = {};
    var count=0;
    var pad_str;
    var max_str_length = -1;
    var wdataStr = "";

    for(var i=0;i<array_entry.length;i++) {
        if(num_user.indexOf(array_entry[i].owner) !== -1 ){
            var indx = num_user.indexOf(array_entry[i].owner);
            user_job_count[indx] = user_job_count[indx]+1;
        } else{
            num_user.push(array_entry[i].owner);
            user_job_count.push(1);
        }
        if(user_job_proj_count[array_entry[i].owner] !== undefined ){
            if (user_job_proj_count[array_entry[i].owner][array_entry[i].project] !== undefined) {
                user_job_proj_count[array_entry[i].owner][array_entry[i].project] += 1;
            } else {
                if (typeof(user_job_proj_count[array_entry[i].owner]) === "object") {
                    user_job_proj_count[array_entry[i].owner][array_entry[i].project] = 1;
                } else {
                    user_job_proj_count[array_entry[i].owner] = {[array_entry[i].project] : 1};
                }
            }
        } else {
            user_job_proj_count[array_entry[i].owner] = {[array_entry[i].project] : 1};
        }
    }

    wdata += "Jobs Per User " + "\n";

    for(var i=0;i<num_user.length;i++) {
        if(max_str_length < num_user[i].length){
            max_str_length = num_user[i].length;
        }
    }
    //for(var i=0;i<num_user.length;i++) {
    //    pad_str = padright(num_user[i], max_str_length+10);
    //    wdata += "User: " + pad_str + " Job Count: " + user_job_count[i] + "\n";
    //}
    Object.keys(user_job_proj_count).forEach(function (user){
        pad_str = padright(user, max_str_length+10);
        wdataStr += "User: " + pad_str;
        Object.keys(user_job_proj_count[user]).forEach(function (proj){
            wdataStr += padright(proj + " job count: ", max_str_length+15);
            wdataStr += padright(user_job_proj_count[user][proj].toString(), max_str_length);
        });
        wdataStr += "\n";
    });
    return(wdata + wdataStr);
}


function findTotalFailedJobs(array_entry, wdata){
    var count = 0;

    var signature = [];
    var signature_count = [];

    var machine_name = [];
    var machine_fail_count = [];

    for(var i=0;i<array_entry.length;i++) {
        if(array_entry[i].failed > 0){
            count = count + 1 ; 

            if(signature.indexOf(array_entry[i].failed) !== -1 ){
                var indx = signature.indexOf(array_entry[i].failed);
                signature_count[indx] = signature_count[indx]+1;
            } else{
                signature.push(array_entry[i].failed);
                signature_count.push(1);
            }

            if(machine_name.indexOf(array_entry[i].hostname) !== -1 ){
                var machine_indx = machine_name.indexOf(array_entry[i].hostname);
                machine_fail_count[machine_indx] = machine_fail_count[machine_indx]+1;
            }else{
                machine_name.push(array_entry[i].hostname);
                machine_fail_count.push(1);
            }

        }
    }
    wdata += "Total Jobs Failed " + count + "\n";

    for(var i=0;i< signature.length;i++) {
        wdata += signature_count[i]+ " Jobs failed with Message "+ signature[i] + "\n\n";
    }


    wdata += "Jobs Failed Per Machine" + "\n";
    for(var i=0;i< machine_name.length;i++) {
        wdata += machine_fail_count[i] + " Jobs failed on machine  " + machine_name[i] + "\n";
    }

    wdata += "\n";
    return(wdata);
}


function findLongJobs(array_entry, wdata){
    var runtime1=10800;
    var runtime2=21600;
    var count1=0;
    var count2=0;
    var job_name1 = [];
    var job_name2 = [];

    for(var i=0;i<array_entry.length;i++) {
        if(array_entry[i].ru_wallclock > runtime1){
            count1 = count1 + 1 ; 
            
            if(job_name1.length < 5){
                job_name1.push(array_entry[i].jobname);
            }

        }

        if(array_entry[i].ru_wallclock > runtime2){
            count2 = count2 + 1 ; 
            
            if(job_name2.length < 5){
                job_name2.push(array_entry[i].jobname);
            }

        }
    }

    wdata += "\n";
    wdata += "Total Jobs that ran more than 3 hours " + count1 + "\n";
    wdata += "Top 5 Jobs that ran more than 3 hours " + "\n";
    for(var i=0;i<job_name1.length;i++) {
        wdata +=  job_name1[i] + "\n";
    }

    wdata += "\n";
    wdata += "Total Jobs that ran more than 6 hours " + count2 + "\n";
    wdata += "Top 5 Jobs that ran more than 6 hours " + "\n";
    for(var i=0;i<job_name2.length;i++) {
        wdata +=  job_name2[i] + "\n";
    }
  return(wdata);
}


function findJobTimePerBlock(array_entry, wdata){
    var block_name = ["dmi", "cbi", "aiu", "dce", "psys"];
    var block_time = [0,0,0,0,0];
    var block_jobs = [0,0,0,0,0];
    var round_time;
    var pad_str;
    var pad_str1;
    var max_str_length = -1;

    for(var i=0;i<array_entry.length;i++) {
        var indx = searchStringInArray(array_entry[i].jobname, block_name);
        if(indx !== -1 ){
            block_time[indx] = Number(array_entry[i].ru_wallclock) + Number(block_time[indx]);
            block_jobs[indx] = block_jobs[indx]+1;
        } 
    }

    wdata += "\n";
    wdata += "Total Jobs per block and total time " + "\n";
    for(var i=0;i<block_name.length;i++) {
        pad_str = padright(block_name[i], max_str_length+10);
        pad_str1 = padright(block_jobs[i].toString(), max_str_length+5);
        round_time = Math.round(block_time[i]/(60*60));
        wdata += "Block: " + pad_str + " Job Count: " + pad_str1 + " Total Grid Time: " + round_time + " hours" +  "\n";
    }

  return(wdata);
}



//Executes shell commands
function exec_cmd(str) {
    var pwd = proc.execSync(str, function(error, stdout, stderr) {
        if(error != null) {
            console.log(str);
            throw(error);
        }
    });
}

function padright(str, num) {
    var return_str = str;
    if(num > str.length) {
    for(var i = str.length; i < num; i++)
        return_str += ' '
    } else {
    return_str = str.substring(0,num);
    }
    return return_str;
}

function searchStringInArray (str, strArray) {
    var rvalue = -1;
    for (var j=0; j<strArray.length; j++) {
        if (str.indexOf(strArray[j]) !== -1) {
            rvalue = j;    
            return rvalue;
        }
    }
}
