'use strict';

var fs = require('fs');
var process=require('child_process');

var threadsused = 0;

window.editor = "";
window.hwpath = "";


function llog(id){
//    console.log("log:"+id);

    var tree = $$("tt");

    var d = tree.getItem(id);
    var launched = 0;
    if(d.stdout) {
        var matches1 = d.stdout.match(/Successfully generated dv files (.*)/);
        var matches2 = d.stdout.match(/wavedump: (.*)/);
        if(matches1){
            var file = matches1[1]+"/"+id+".log"
            fs.writeFileSync(file, d.stdout);
            process.exec(window.editor+' '+file+' &',null);
            launched = 1;
        } else if (matches2) {
            process.exec(window.editor+' '+matches2[1]+'/vcs.log &',null);
            launched = 1;
        }
    }
    if (launched == 0) {
        webix.ui({
            view:"window",
            move:false,
            id: "logwin",
            height:100,
            width:400,
            position:"center",
            head:{view:"toolbar", cols:[
                {view:"label", label:"View Log"},
                {view:"button", label:"Close", align:"right", click:"$$('logwin').close();"}
            ]},
            body:{view:"template", template:"No path found."} 
        }).show();
    }

}

function dve(id){
//    console.log("dve:"+id);

    var tree = $$("tt");

    var d = tree.getItem(id);
    var launched = 0;
    if(d.stdout) {
        var matches2 = d.stdout.match(/wavedump: (.*)/);
        if (matches2) {
            var path = matches2[1];
            var cmd = "dve -vpd vcdplus.vpd &";
//            console.log(path+"   "+cmd);
            process.exec(cmd, {cwd:path}, null);
            launched = 1;
        }
    }
    if (launched == 0) {
        webix.ui({
            view:"window",
            move:false,
            id: "dvewin",
            height:100,
            width:400,
            position:"center",
            head:{view:"toolbar", cols:[
                {view:"label", label:"Launch DVE"},
                {view:"button", label:"Close", align:"right", click:"$$('dvewin').close();"}
            ]},
            body:{view:"template", template:"No path found."} 
        }).show();
    }

}

function term(id){
    //    var x = 5;
//    console.log("term:"+id);
    var tree = $$("tt");

    var d = tree.getItem(id);
    var launched = 0;
    if(d.stdout) {
        var matches1 = d.stdout.match(/Successfully generated dv files (.*)/);
        var matches2 = d.stdout.match(/wavedump: (.*)/);
        if(matches1){
            process.exec('terminal  --default-working-directory='+matches1[1]+' -T="'+d.value+'" &',null);
            launched = 1;
        } else if (matches2) {
            process.exec('terminal  --default-working-directory='+matches2[1]+' -T="'+d.value+'" &',null);
            launched = 1;
        }
    }
    if (launched == 0) {
        webix.ui({
            view:"window",
            move:false,
            id: "termwin",
            height:100,
            width:400,
            position:"center",
            head:{view:"toolbar", cols:[
                {view:"label", label:"Launch Terminal"},
                {view:"button", label:"Close", align:"right", click:"$$('termwin').close();"}
            ]},
            body:{view:"template", template:"No path found."} 
        }).show();
    }
}


//--------------------------------------------------------------------------------
// Construct GUI
//--------------------------------------------------------------------------------
webix.ready(function(){



    var grida = webix.ui({
	container:"testA",

        type:"line",
        rows:[
            {view:"toolbar", cols:[
              //  { view:"search" },
                { view:"toggle", id:"dump_on_id", label:"DUMP_ON", width: 80, value:1},
                //                { view:"toggle", id:"field_a", label:"Parallel Execution", width:100, value:1, align:"right"},
                //                { view:"toggle", id:"st", label:"Show Tests", width:100, value:1, align:"right", click:"showtests"},
                { view:"counter", id:"counter_id", label:"Parallel Jobs", labelPosition:"top", width:100, value:2},
                { view:"button", value:"Go!", inputWidth:80, type:"danger", click:"sel()"}

                // TODO:  Show output as it's running.


            ]},
            //            {view:"accordion",
            //		    cols:[
            {view:"treetable",
             filterMode:{showSubItems:true, openParents:true, level:0},
             id:"tt",
             //             template:"{common.icon()} {common.checkbox()} #value#", 
             threeState: true,

             columns:[
                 { id:"id",	header:"", css:{"text-align":"right"},  	width:50},
		 { id:"value",	header:["Name", {content:"textFilter"}],	width:400, template:"{common.treetable()} {common.treecheckbox()} #value#", threeState:true },
		 { id:"status",	header:["Status",{content:"textFilter"}],	width:140},
		 { id:"actions",	header:"Actions",	width:100}
	     ],
	     autoheight:true,
	     autowidth:true,
	     data: []
            }
	]
    });

//    $$("$search1").attachEvent("onTimedKeyPress",function(){
//        var val = this.getValue();
//        if (val != null) {
//            if (val.match("#")) {
//	        $$("tt").filter(function(obj){
//                    console.log(JSON.stringify(obj));
//                    if(obj.status == "") {
//                        return false;
//                    }
//                    return true;
//                });
//            }
//        }
//
//        val.replace(/#\s/,"");
////	$$("tt").filter("#status#","");
//	$$("tt").filter("#value#",val);
//    })


    //------------------------------------------------------------
    var addItems= function(data, number, name, cwd){

        var tree = $$("tt");
        //        tree.add( { "id":number, "value":name, "status":"", "actions":actions} );

        var lines = data.split("\n");

        var count = 1;
        var count2 = 1;

        var config_id;
        var compile_id;

        for(var i = 0; i<lines.length; i++) {
            var line = lines[i];
            var value = line.replace("node ../../scripts/rsim.js", "");
            if (line.match(/^node.*-a/)) { // ACHL Compile 


                var name = "Config: Default";

                var matches = line.match(/-s\s+(.*$)/);
                if (matches) { // Defines a non-default conifguration
                    name = matches[1];
                }
                
                config_id = number+"."+count;

                tree.add( { "id":config_id, "cmd":"", status:"", "value":name, "actions":"", "cwd":cwd, "dependson":"" }, i, number );
                
                count++;
                count2=1;

                var test_id = config_id +"."+count2;

                var actions = " <img src='terminal.jpg' style='width:20px; height:20px' onclick='term(\""+test_id+"\")'>";
                actions += " <img src='log.png' style='width:20px; height:20px' onclick='llog(\""+test_id+"\");'>";

                tree.add( { "id":test_id, "cmd":line, status:"", "value":value, "actions":actions, "cwd": cwd, "dependson":"" }, i, config_id );
                count2++;

                compile_id = test_id;
                
            } else if (line.match(/^node.*-t/)) { // Run Test

                //                var actions = "<img src='play.png' style='width:18px; height:18px'>";
                var test_id = config_id +"."+ count2;

                var actions = " <img src='terminal.jpg' style='width:20px; height:20px' onclick='term(\""+test_id+"\");'>";
                actions += " <img src='log.png' style='width:20px; height:20px' onclick='llog(\""+test_id+"\");'>";
                actions += " <img src='dve.png' style='width:18px; height:18px' onclick='dve(\""+test_id+"\");'>";

                tree.add( { "id":test_id, "cmd":line, status:"", "value":value, "actions":actions, "cwd": cwd, "dependson":compile_id }, i, config_id );
                count2++;
            }
        }
    }

    var tree = $$("tt");
    tree.add( { "id":1, "value":"DCE", "status":"", "actions":""} );
    tree.add( { "id":2, "value":"DMI", "status":"", "actions":""} );
    tree.add( { "id":3, "value":"AIU", "status":"", "actions":""} );
    tree.add( { "id":4, "value":"SUBSYS", "status":"", "actions":""} );

    var data = fs.readFileSync("./config.json", 'utf8');

    var j = JSON.parse(data);
    window.editor = j.editor;
    window.hwpath = j.hwpath;

    // Read DCE Testlist
    var path = window.hwpath+"/dv/dce/tb/testlist";
    data = fs.readFileSync(path, 'utf8');
    addItems(data, 1, "DCE", window.hwpath+"/dv/dce/tb");

    path = window.hwpath+"/dv/dmi/tb/testlist";
    data = fs.readFileSync(path, 'utf8');
    addItems(data, 2, "DMI", window.hwpath+"/dv/dmi/tb");

    data = fs.readFileSync(window.hwpath+"/dv/sub_sys/tb/testlist", 'utf8');
    addItems(data, 4, "SUBSYS", window.hwpath+"/sub_sys/dmi/tb");

    data = fs.readFileSync(window.hwpath+"/dv/aiu/tb/testlist", 'utf8');
    addItems(data, 3, "AIU", window.hwpath+"/dv/aiu/tb");

        var tree = $$("tt");
        tree.openAll();
        
        tree.attachEvent("onItemClick", function(id, e, node) {
            var item = this.getItem(id);
            //            console.log(JSON.stringify(id.row));
            
            var d = this.getItem(id.row);

            var c = id.column;

            if (id.column=="status"){
                var win_id = "win"+id.row;
                //            console.log(JSON.stringify(d));

                var body = "==================== Command<br>"
                body += d.cmd+"<br>";

                body += "==================== Status<br>"
                body += d.status+"<br>";

                if (d.error) {
                    body += "==================== Error<br>"
                    body += d.error;//.replace("\n","\n<br>")+"<br>";
                }

                if (d.stdout) {
                    body += "==================== stdout<br>"
                    body += "<pre>"+d.stdout+"</pre><br>";
                }

                webix.ui({
                    view:"window",
                    move:true,
                    id: win_id,
                    height:600,
                    width:700,
                    position:"center",
                    //                fullscreen:true,
                    scroll:"xy",
                    head:{view:"toolbar", cols:[
                        {view:"label", label:id.row},
                        {view:"button", label:"Close", align:"right", click:"$$('"+win_id+"').close();"}
                    ]},
                    body:{view:"template", scroll:"xy", template:body} 
                }).show();
            }

    });
});


//------------------------------------------------------------
//
//------------------------------------------------------------
function do_cmd(d, timeout){

    

    var cmd = d.cmd;
    if (cmd.match("rsim")){
        //        console.log("Running: "+cmd);
        
        var argsstring = d.value;
        if (argsstring.match("-ro")) { }
        else if (argsstring.match("-r")) { }
        else {
            // Add "-r" is it's not already there.
            argsstring = argsstring.replace("-t", "-r -t");
        }

        var dumpon = $$("dump_on_id").getValue();
        if (dumpon==1) {
            argsstring = argsstring + " -d DUMP_ON"
            argsstring = argsstring.replace(",+no_dump","");
        }

        var args = argsstring.split(/\s+/);
        
        var tree = $$("tt");
        var allowedthreads = $$("counter_id").getValue();
        if (threadsused >= allowedthreads) {
            d.status="+Waiting for thread.";
            tree.updateItem(d);
        } else {
            threadsused++;
            console.log("Start ("+threadsused+"/"+allowedthreads+"):"+d.value);

            setTimeout( function(){
                
                d.stdout = "";
                var child = process.fork ("../../scripts/rsim.js", args, {"cwd":window.hwpath+"/dv/dce/tb", "silent":"true"});
                
                tree.updateItem(d);

                
                child.stdout.on('data', function(data){
                    
                    var x = "" + data;
                    d.stdout += data;
                    
                    if (x.match("Instance: root")){
                        d.status="++ACHL Generating";
                    }
                    if (x.match("Parsing design file")){
                        d.status="++VCS Compiling";
                    }
                    tree.updateItem(d);
                });
                
                child.stderr.on('data', function(data){
                    d.stdout += data;
                });
                
                child.on('close', function(close){
                    //                    console.log("FINISHED: "+close)
                    d.error=close;
                    threadsused--;
                    console.log("End   ("+threadsused+"/"+allowedthreads+"):"+d.value);
                    d.status = "<img src='redx.png' style='width:18px; height:18px'> ++Failed";
                    
                    
                    if (d.stdout.match(/UVM\sPASSED/)){ 
                        d.status = "<img src='greencheck.png' style='width:18px; height:18px'> ++Passed";
                    }


                    if (d.stdout.match(/VCS\scompile\ssuccessful/)){ 
                        d.status = "<img src='greencheck.png' style='width:18px; height:18px'> ++Compile Finished.";
                    }
                    tree.updateItem(d);

                    wake();

                });


            }, timeout);
        }
    }
}

//------------------------------------------------------------
//
//------------------------------------------------------------
function sel(){
    var tree = $$("tt");


    
    var timeout = 100;
    
    tree.data.each(function(row){
        var id= row.id;
        var ic = tree.isChecked(id);
        
        if (tree.isChecked(id)) {
            var d = tree.getItem(id);
            if(d.cmd){
                if(d.cmd.match("rsim")){
                    
                    d.status="++Running.";
                    
                    if (d.dependson != '') {
                        var dependee = tree.getItem(d.dependson);
                        if (!dependee.status.match(/Finished/)) {
                            d.status="+Waiting for "+d.dependson;
                        }
                    }
                    
                    
                    if(d.status == "++Running.") {
                        do_cmd(d, timeout);
                        timeout+= 500;
                        //                    console.log(id);
                    }
                }}
        }
    });

}

//------------------------------------------------------------
//
//------------------------------------------------------------
function wake(){
    var tree = $$("tt");
    
    var timeout = 100;

    //    console.log("Wake.");
    
    tree.data.each(function(row){
        var id= row.id;
        var ic = tree.isChecked(id);
        if (tree.isChecked(id)) {
            var d = tree.getItem(id);
            if(d.status.match(/Waiting/)){

                //                console.log(">>> "+d.status);

                d.status="++Running.";
                
                if (d.dependson != '') {
                    var dependee = tree.getItem(d.dependson);
                    if (!dependee.status.match(/Finished/)) {
                        d.status="+Waiting for "+d.dependson;
                    }
                }
                
                if(d.status == "++Running.") {
                    console.log("Wake (T/O:"+timeout+"):  "+d.value);
                    do_cmd(d, timeout);
                    timeout+= 500;
                    //                    console.log(id);
                }
            }
        }
    });

}

//function showtests(){
//    //    var tree = grida.getChildViews()[1];
//    var tree = $$("tt");
////    console.log($$("st").getValue());
//    
//    if ($$("st").getValue()==0) {
//        tree.hideColumn("status");
//    } else {
//        tree.showColumn("status");
//    }
//
//
//    tree.updateItem("1.1", { "id":"1.1", "value":"Hi!!", "status":"alpha"});
//}
