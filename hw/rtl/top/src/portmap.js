'use strict';

var lodashForEach = require('lodash.foreach');
var _ = require('lodash');
var lodashSet = require('lodash.set');
var fs = require('fs');

var allPinLists = {};
var topLevelPinLists = {};
var connectivityInfo = {};

var structures = [];

//For performance reasons custoom merge versus lodash merge is much faster
var pinlistMerge = function pinlistMerge(object, source) {
   if (!object.result) {
       object.result = {};
   }
   if (!object.coh) {
       object.coh = {};
   }
   if (!object.result.fn) {
       object.result.fn = {};
   }
   if (source.result && source.result.fn){
       object.result.fn = _.assign(object.result.fn, source.result.fn);
   } 
   if (source.coh){
       object.coh = _.assign(object.coh, source.coh);
   } 
};

// Info needed from outside - hardcoded for now
//var pinListFiles = ['output_achl.pinlist', 'Structure/out/Structure.pinlist', 'Structure1/out/Structure1.pinlist', 'Structure2/out/Structure2.pinlist'];
//var structures = ['Structure', 'Structure1', 'Structure2'];
//var coh_modules = ['aiu0', 'aiu1', 'aiu2', 'aiu3', 'dce', 'dmi'];

//regex vars
var csrInit = 'init_csr';
var cohMarker = 'coh_';
var sfiMarker = 'sfi_';
var axiMarker = 'axi_';
var aceMarker = 'ace_';
var ocpMarker = 'ocp_';
var sfiRegex = new RegExp('ctim|ctis');
var axiRegex = new RegExp('coh_[A-Za-z0-9_]+_bypass');
var csrRegex = new RegExp('csr');
var bridgeRegex = new RegExp('bridge');

var nocCoherencyMap = {};

// Combine all pinlist files
var readPinlists = function (f) {
    pinlistMerge(allPinLists, JSON.parse(fs.readFileSync(f)));
};

// Throw out everything except the toplevel
var extractTopLevelPins = function (p, s, c) {
    var obj;
    for (var i=0; i<p.length; i++) {
        pinlistMerge(allPinLists, p[i]);
    }

    //console.log('apl:' + JSON.stringify(allPinLists)); 

    s.forEach(function (e) {
        obj = {};
        obj[e] = allPinLists.result.fn[e];
        _.assign(topLevelPinLists, obj);
    });

    c.forEach(function (e1) {
        obj = {};
        if (typeof allPinLists.coh[e1] === "string") {
            obj[e1] = allPinLists.coh[allPinLists.coh[e1]];
            _.assign(topLevelPinLists, obj);
        } else {
            obj[e1] = allPinLists.coh[e1];
            _.assign(topLevelPinLists, obj);
            //console.log('apl: ' + JSON.stringify(allPinLists.coh)); 
        }
    });
    
    //var topLevelMarker = new RegExp('^((?!_).)*$');
    //for (var struct in allPinLists.result.fn) {
    //    var match = struct.match(topLevelMarker);
    //    if (match) {
    //        structures.push(struct);
            //console.log("match: "+struct);
    //    } else {
            //console.log("no match: "+struct);
    //    }
    //}

    //console.log('apl:' + JSON.stringify(topLevelPinLists));
};

// Separate pinlists into usable groups
var separatePinGroups = function (e, pinRegex, markerRegex) {
    var match;
    var tgt;

    connectivityInfo[e] = {};
    connectivityInfo[e].inputs = {};
    connectivityInfo[e].outputs = {};
    connectivityInfo[e].local = {};
    connectivityInfo[e].internal = {};

    lodashForEach(topLevelPinLists[e], function(v, k) {
        tgt = '';
        // match = [];
        //console.log('k:' + k);
        if (!k.match(markerRegex)) {
            if (v > 0) {
                connectivityInfo[e].inputs[k] = v;
            } else if (v < 0) {
                connectivityInfo[e].outputs[k] = v;
            }
        } else {
            // Find coherent signals
            if ((match = pinRegex.exec(k)) !== null) {
                //console.log('k:' + k);
                //console.log('ma:' + JSON.stringify(match));

                // match[3] is valid only for FlexNoC structures
                if (match[3]) {
                    //console.log('match[3]: ' + JSON.stringify(match[3]));

                    tgt = match[3];
                    // sfiRegex matches SFI interface signals
                    // FIXME: do it just once
                    if (k.match(sfiRegex)) {
                        lodashSet(nocCoherencyMap, '.' + sfiMarker + '.' + tgt, e);
                        //console.log('sfi match on struct: ' + k + ', tgt: '+tgt);
                    }

                    // axiRegex matches AXI interface signals
                    // FIXME: do it just once
                    if (k.match(axiRegex)) {
                        lodashSet(nocCoherencyMap, '.' + axiMarker + '.' + tgt, e);
                        //console.log('axi match on struct: ' + k + ', tgt: '+tgt);
                    }

                    // bridgeRegex matches ACE interface signals
                    // FIXME: do it just once
                    if (k.match(bridgeRegex)) {
                        lodashSet(nocCoherencyMap, '.' + aceMarker + '.' + tgt, e);
                        //console.log('ace match on struct: ' + k + ', tgt: '+tgt);
                    }

                    if (k.match(csrRegex)) {
                        lodashSet(nocCoherencyMap, '.' + ocpMarker + '.' + tgt, e);
                        //console.log('csr match on struct: ' + k + ', tgt: '+tgt);
                    }
                }

                // match[4] is valid only for coherent blocks w/ sfi_* or axi_*, or ocp_* or ace_*
                // signals. This is used to set the target name (FlexNoC structure) in the coherent
                // modules obj
                if (match[4] && nocCoherencyMap[match[4]]) {
                    //console.log('match[4]: ' + JSON.stringify(match[4]));
                    //console.log('nocCoherencyMap[match[4]]: ' + nocCoherencyMap[match[4]]);
                    tgt = nocCoherencyMap[match[4]][e];
                    //console.log('matching: ' + k + ' tgt: ' + tgt + ' m[4]: ' + match[4] + ' struct: ' + e);
                }
                //if (!(match[3] || match[4])) console.log("no match 3 or 4: "+k);

                if (tgt) {
                    // Save internal outputs to local
                    if (v < 0) {
                        lodashSet(connectivityInfo, '.' + e + '.local.' + tgt + '.' +  k, ['??', v]);
                    }

                    // Save internal inputs to internal
                    if (v > 0) {
                        lodashSet(connectivityInfo, '.' + e + '.internal.' + tgt + '.' +  k, ['??', v]);
                    }
                } else {
                    if (v > 0) {
                        connectivityInfo[e].inputs[k] = v;
                    } else if (v < 0) {
                        connectivityInfo[e].outputs[k] = v;
                    }
                }
            } else {
                //console.error("no match on struct "+e+" with key: "+k);
                if (v > 0) {
                    connectivityInfo[e].inputs[k] = v;
                } else if (v < 0) {
                    connectivityInfo[e].outputs[k] = v;
                }
            }
        }
    });
};

// Process pinlist wrapper
var processPinList = function (s, c) {

    var sortByLength = function (a, b) { return b.length - a.length };
    var cSorted = c.sort(sortByLength)

    // cr:/^((coh_)(aiu0|aiu1|aiu2|aiu3|dce|dmi|init_csr))|((sfi_)|(axi_)|(ocp_)|(ace_))/i
    var pinString = '^(('+ cohMarker + ')' + '(' + cSorted.join('|') + '|' + csrInit + '))' + '|((' + sfiMarker + ')|(' + axiMarker + ')|(' + ocpMarker + ')|(' + aceMarker + '))';
    var pinRegex = new RegExp(pinString, 'i');
    var markerRegex = new RegExp('^' + cohMarker + '|' + sfiMarker + '|' + axiMarker + '|' + ocpMarker + '|' + aceMarker, 'i');

    s.forEach(function (e) {separatePinGroups(e, pinRegex, markerRegex);});
    c.forEach(function (e1) {separatePinGroups(e1, pinRegex, markerRegex);});
    //console.log(JSON.stringify(connectivityInfo, null, 4));
};

// Check and delete matched pins
var checkAndUpdateOutputs = function (i0, i1, sig, k0, v0)  {
    if (Math.abs(connectivityInfo[i0].local[i1][sig][1]) === Math.abs(v0[1])) {
        connectivityInfo[i0].local[i1][sig][0] = k0;
        delete connectivityInfo[i1].internal[i0][k0];
        return true;
    } else if (Math.abs(connectivityInfo[i0].local[i1][sig][1]) < Math.abs(v0[1])) {
        throw 'Top level signal width mismatch between ' + i0 + ' and ' + i1 +
            '. Signals: ' + k0 + '(' + Math.abs(v0[1]) + ') and ' +
            sig + '(' + Math.abs(connectivityInfo[i0].local[i1][sig][1]) + ').';
        connectivityInfo[i0].local[i1][sig][0] = k0;
        //console.log('Warning: width mismatch:' + 'signals: ' + k0 + ' & ' + sig);
        //console.log('Using smallest width');
        delete connectivityInfo[i1].internal[i0][k0];
        return true;
    } else if (Math.abs(connectivityInfo[i0].local[i1][sig][1]) > Math.abs(v0[1])) {
        throw 'Top level signal width mismatch between ' + i0 + ' and ' + i1 +
            '. Signals: ' + k0 + '(' + Math.abs(v0[1]) + ') and ' +
            sig + '(' + Math.abs(connectivityInfo[i0].local[i1][sig][1]) + ').';
        connectivityInfo[i0].local[i1][sig][0] = k0;
        connectivityInfo[i0].local[i1][sig][1] = 0 - v0[1];
        //console.log('Warning: width mismatch:' + 'signals: ' + k0 + ' & ' + sig);
        //console.log('Using smallest width');
        delete connectivityInfo[i1].internal[i0][k0];
        return true;
    }
    return false;
};

var checkAndUpdateInputs = function (i0, i1, sig, k0, v0)  {
    if (Math.abs(connectivityInfo[i0].internal[i1][sig][1]) === Math.abs(v0[1])) {
        connectivityInfo[i0].internal[i1][sig][0] = k0;
        delete connectivityInfo[i1].local[i0][k0];
        return true;
    } else if (Math.abs(connectivityInfo[i0].internal[i1][sig][1]) < Math.abs(v0[1])) {
        throw 'Top level signal width mismatch between ' + i0 + ' and ' + i1 +
            '. Signals: ' + k0 + '(' + Math.abs(v0[1]) + ') and ' +
            sig + '(' + Math.abs(connectivityInfo[i0].internal[i1][sig][1]) + ').';
        connectivityInfo[i0].internal[i1][sig][0] = k0;
        //console.log('Warning: width mismatch:' + 'signals: ' + k0 + ' & ' + sig);
        //console.log('Using smallest width');
        delete connectivityInfo[i1].local[i0][k0];
        return true;
    } else if (Math.abs(connectivityInfo[i0].internal[i1][sig][1]) > Math.abs(v0[1])) {
        throw 'Top level signal width mismatch between ' + i0 + ' and ' + i1 +
            '. Signals: ' + k0 + '(' + Math.abs(v0[1]) + ') and ' +
            sig + '(' + Math.abs(connectivityInfo[i0].internal[i1][sig][1]) + ').';
        connectivityInfo[i0].internal[i1][sig][0] = k0;
        connectivityInfo[i0].internal[i1][sig][1] = 0 - v0[1];
        //console.log('Warning: width mismatch:' + 'signals: ' + k0 + ' & ' + sig);
        //console.log('Using smallest width');
        delete connectivityInfo[i1].local[i0][k0];
        return true;
    } else {
        //console.error('Error: width mismatch:' + 'signals: ' + k0 + ' & ' + sig);
        return false;
    }
};


var matchCsrStructs = function (s) {
    var m, target;
    s.forEach(function (l0) {
        s.forEach(function (l1) {
            lodashForEach(connectivityInfo[l1].inputs, function (v, k) {
                //console.log("input signal: " + k);
                if ((m = k.match(/coh_(.*)_targ_csr_(.*$)/)) !== null) {
                    //console.log("targ match: " + m);
                    target = 'coh_' + m[1] + '_init_csr_' + m[2]
                    if (connectivityInfo[l0].outputs[target]) {
                        //console.log("match!");
                        if (!connectivityInfo[l0].local[l1]) connectivityInfo[l0].local[l1] = {};
                        if (!connectivityInfo[l0].local[l1][target]) connectivityInfo[l0].local[l1][target] = {};
                        connectivityInfo[l0].local[l1][target][0] = k;
                        connectivityInfo[l0].local[l1][target][1] = v;
                        delete connectivityInfo[l1].inputs[k];
                        delete connectivityInfo[l0].outputs[target];
                    }
                }
                if ((m = k.match(/coh_(.*)_init_csr_(.*$)/)) !== null) {
                    //console.log("init match: " + m);
                    target = 'coh_' + m[1] + '_targ_csr_' + m[2]
                    if (connectivityInfo[l0].outputs[target]) {
                        //console.log("match!");
                        if (!connectivityInfo[l0].local[l1]) connectivityInfo[l0].local[l1] = {};
                        if (!connectivityInfo[l0].local[l1][target]) connectivityInfo[l0].local[l1][target] = {};
                        connectivityInfo[l0].local[l1][target][0] = k;
                        connectivityInfo[l0].local[l1][target][1] = v;
                        delete connectivityInfo[l1].inputs[k];
                        delete connectivityInfo[l0].outputs[target];
                    }
                }
            });
            lodashForEach(connectivityInfo[l1].outputs, function (v, k) {
                //console.log("output signal: " + k);
                if ((m = k.match(/coh_(.*)_targ_csr_(.*$)/)) !== null) {
                    //console.log("targ match: " + m);
                    target = 'coh_' + m[1] + '_init_csr_' + m[2]
                    if (connectivityInfo[l0].inputs[target]) {
                        //console.log("match!");
                        if (!connectivityInfo[l0].internal[l1]) connectivityInfo[l0].internal[l1] = {};
                        if (!connectivityInfo[l0].internal[l1][target]) connectivityInfo[l0].internal[l1][target] = {};
                        connectivityInfo[l0].internal[l1][target][0] = k;
                        connectivityInfo[l0].internal[l1][target][1] = v;
                        delete connectivityInfo[l1].outputs[k];
                        delete connectivityInfo[l0].inputs[target];
                    }
                }
                if ((m = k.match(/coh_(.*)_init_csr_(.*$)/)) !== null) {
                    //console.log("init match: " + m);
                    target = 'coh_' + m[1] + '_targ_csr_' + m[2]
                    if (connectivityInfo[l0].inputs[target]) {
                        //console.log("match!");
                        if (!connectivityInfo[l0].internal[l1]) connectivityInfo[l0].internal[l1] = {};
                        if (!connectivityInfo[l0].internal[l1][target]) connectivityInfo[l0].internal[l1][target] = {};
                        connectivityInfo[l0].internal[l1][target][0] = k;
                        connectivityInfo[l0].internal[l1][target][1] = v;
                        delete connectivityInfo[l1].outputs[k];
                        delete connectivityInfo[l0].inputs[target];
                    }
                }
            });
        });
    });
}

// Find connections between the various submodules
var findConnections = function (s, c) {
    var m, status, axiSignal, sfiSignal, bridgeSignal, csrSignal;
    s.forEach(function (l0) {
        c.forEach(function (l1) {
            lodashForEach(connectivityInfo[l1].internal[l0], function (v, k) {
                m = '';
                // connect axi_mst <-> bypass signals
                if ((m = k.match(/axi_mst_(.*$)/)) !== null) {
                    axiSignal = 'coh_' + l1 + '_bypass_' + m[1];
                    if (connectivityInfo[l0].local[l1][axiSignal]) {
                        checkAndUpdateOutputs(l0, l1, axiSignal, k, v);
                    }
                }
                // connect sfi_mst|slv <-> ctim/ctis signals
                if ((m = k.match(/sfi_(mst|slv)(_.*$)/)) !== null) {
                    sfiSignal = 'coh_' + l1 + (m[1] === 'mst' ? '_ctim' : '_ctis') + m[2];
                    if (connectivityInfo[l0].local[l1][sfiSignal]) {
                        checkAndUpdateOutputs(l0, l1, sfiSignal, k, v);
                    }
                }
                // connect ace <-> bridge signals
                if ((m = k.match(/ace_(.*$)/)) !== null) {
                    bridgeSignal = 'coh_' + l1 + '_bridge_'  + m[1];
                    if (connectivityInfo[l0].local[l1][bridgeSignal]) {
                        checkAndUpdateOutputs(l0, l1, bridgeSignal, k, v);
                    }
                }
                // connect ocp  <-> csr signals
                if ((m = k.match(/ocp_(.*$)/)) !== null) {
                    csrSignal = 'coh_' + l1 + 'csr_' + m[1].toLowerCase();
                    if (connectivityInfo[l0].local[l1][csrSignal]) {
                        checkAndUpdateOutputs(l0, l1, csrSignal, k, v);
                    }
                }
            });
            lodashForEach(connectivityInfo[l1].local[l0], function (v1, k1) {
                m = '';
                // connect axi_mst <-> bypass signals
                if ((m = k1.match(/axi_mst_(.*$)/)) !== null) {
                    axiSignal = 'coh_' + l1 + '_bypass_' + m[1];
                    if (connectivityInfo[l0].internal[l1][axiSignal]) {
                        checkAndUpdateInputs(l0, l1, axiSignal, k1, v1);
                    }
                }
                // connect sfi_mst|slv <-> ctim/ctis signals
                if ((m = k1.match(/sfi_(mst|slv)(_.*$)/)) !== null) {
                    sfiSignal = 'coh_' + l1 + (m[1] === 'mst' ? '_ctim' : '_ctis') + m[2];
                    if (connectivityInfo[l0].internal[l1][sfiSignal]) {
                        checkAndUpdateInputs(l0, l1, sfiSignal, k1, v1);
                    }
                }
                // connect ace <-> bridge signals
                if ((m = k1.match(/ace_(.*$)/)) !== null) {
                    bridgeSignal = 'coh_' + l1 + '_bridge_'  + m[1];
                    if (connectivityInfo[l0].internal[l1][bridgeSignal]) {
                        checkAndUpdateInputs(l0, l1, bridgeSignal, k1, v1);
                    }
                }
                // connect ocp <-> csr signals
                if ((m = k1.match(/ocp_(.*$)/)) !== null) {
                    csrSignal = 'coh_' + l1 + 'csr_' + m[1].toLowerCase();
                    if (connectivityInfo[l0].internal[l1][csrSignal]) {
                        checkAndUpdateInputs(l0, l1, csrSignal, k1, v1);
                    }
                }
            });

        });
    });
};

// Print all '??' pins
var reportUnconnected = function (s, c) {
    s.concat(c).forEach(function (e) {
        ['local', 'internal'].forEach(function (e0) {
            lodashForEach(connectivityInfo[e][e0], function (v, k) {
                lodashForEach(connectivityInfo[e][e0][k], function (v0, k0) {
                    if (v0[0] === '??') {
                        //console.error('Unmatched internal signal: ' + k0 + ' in module: ' + e);
                    }
                });
            });
        });
    });
};

// Delete unnecessary signals from coh modules
var deleteCohInfo = function(c) {
    c.forEach(function (e) {
        delete connectivityInfo[e];
    });
}

module.exports = {
    getPortMap: function(p, s, c) {
        extractTopLevelPins(p, s, c);
        processPinList(s, c);
        findConnections(s, c);
        matchCsrStructs(s);
        //deleteCohInfo(c);
        return connectivityInfo;
    },
    getAllPins: function(p, s, c) {
        extractTopLevelPins(p, s, c);
        return allPinLists;
    },
    getUnconnectedPorts: function() {
        reportUnconnected(s, c);
    }
}
