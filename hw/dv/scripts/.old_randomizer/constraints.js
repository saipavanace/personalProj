const constraints = [
    {
        description: "If IOAIU Protocol is ACE-Lite or ACE5-Lite, wAwId = wArId, since atomics are enabled",
        action: function(params) {
            params.sockets.ioaiu.items.forEach(item => {
                if (item.protocol == 'ACE-Lite' || item.protocol == 'ACE5-Lite') {
                    item.wAwId = item.wArId;
                }
            });
        },
        comment: ""
    },
    {
        description: "There has to be at least one Initiator with fnCsrAccess=1",
        action: function(params) {
            let found = 0;
            params.sockets.ioaiu.items.forEach(item => {
                if (item.hasCsrAccess == 1) {
                    found = 1;
                }
            });
            params.sockets.chi.items.forEach(item => {
                if (item.hasCsrAccess == 1) {
                    found = 1;
                }
            });
            if (found == 0) {
                if (params.sockets.chi.items.length == 0) {
                    params.sockets.ioaiu.items[0].hasCsrAccess = 1;
                }else {
                    params.sockets.chi.items[0].hasCsrAccess = 1;
                }
            }
        },
        comment: ""
    },
    {
        description: "wAxUser on DMI and DII should be equal to the max wAxUser among all initiators. which means aruser and awuser cannot be different? because as I understand, the axuser bits of DMI/DII should be greater than any user bits. Not necessarily associated with Aw or ar. Look at the single variable used in the below logic",
        action: function(params) {
            let maxUserBits = 0;
            for (let i=0; i<params.sockets.ioaiu.items.length; i++) {
                if (parseInt(params.sockets.ioaiu.items[i].wArUser) > maxUserBits) {
                    maxUserBits = parseInt(params.sockets.ioaiu.items[i].wArUser);
                }
                if (parseInt(params.sockets.ioaiu.items[i].wAwUser) > maxUserBits) {
                    maxUserBits = parseInt(params.sockets.ioaiu.items[i].wAwUser);
                }
            }
            for (let i=0; i<params.sockets.chi.items.length; i++) {
                if (parseInt(params.sockets.chi.items[i].wReqRsvdc) > maxUserBits) {
                    maxUserBits = parseInt(params.sockets.chi.items[i].wReqRsvdc);
                }
            }
            for (let i=0; i<params.sockets.dmi.items.length; i++) {
                params.sockets.dmi.items[i].wArUser = `${maxUserBits}`;
                params.sockets.dmi.items[i].wAwUser = `${maxUserBits}`;
            }
            for (let i=0; i<params.sockets.dii.items.length; i++) {
                params.sockets.dii.items[i].wArUser = `${maxUserBits}`;
                params.sockets.dii.items[i].wAwUser = `${maxUserBits}`;
            }
        }
    },
    {
        description: "There are no event interfaces on AXI4 or ACE-Lite",
        action: function(params) {
            params.sockets.ioaiu.items.forEach((ioaiu) => {
                if(ioaiu.protocol == 'AXI4' || ioaiu.protocol == 'ACE-Lite') {
                    ioaiu.hasEventInInt = 'false';
                    ioaiu.hasEventOutInt = 'false';
                }
            })
        }
    },
    {
        description: "For ACE-Lite-DVM with DVM disabled, there are no event interfaces",
        action: function(params) {
            params.sockets.ioaiu.items.forEach((ioaiu) => {
                if(ioaiu.protocol == 'ACE5-Lite' && ioaiu.enableDvm == 'false') {
                    ioaiu.hasEventInInt = 'false';
                    ioaiu.hasEventOutInt = 'false';
                }else if(ioaiu.protocol == 'ACE5-Lite' && ioaiu.enableDvm == 'true') {
                    ioaiu.hasEventInInt = 'false';
                }
            })
        }
    },
    {
        description: "DVM v8.4 can only be supported if all units can support that version",
        action: function(params) {
            let canSupportDvmV8p4 = 1;
            params.sockets.chi.items.forEach((chi) => {
                if(chi.protocol == 'CHI-B') {
                    canSupportDvmV8p4 = 0;
                }
            })
            params.sockets.ioaiu.items.forEach((ioaiu) => {
                if(ioaiu.protocol == 'ACE') {
                    canSupportDvmV8p4 = 0;
                }
            })
            if (canSupportDvmV8p4 == 0) {
                params.system.dvmVersion = ((Math.random() < 0.5) ? "DVM_v8" : "DVM_v8.1");
            }
        }
    },
    {
        description: "nLatencyCounters can be 16 only if nPerfCounters is non-zero",
        action: function(params) {
            let i=0;
            params.sockets.chi.items.forEach((chi) => {
                if(chi.nPerfCounters == '0') {
                    params.sockets.chi.items[i].nLatencyCounters = '0';
                }
                i+=1;
            })
            i=0;
            params.sockets.ioaiu.items.forEach((ioaiu) => {
                if(ioaiu.nPerfCounters == '0') {
                    params.sockets.ioaiu.items[i].nLatencyCounters = '0';
                }
                i+=1;
            })
        }
    },
    {
        description: "All DCEs should have the same number of AttCtrlEntries",
        action: function(params) {
            let i=0;
            let nAttCtrlEntries = params.sockets.dce.items[0].nAttCtrlEntries;
            for (let i=1; i<params.sockets.dce.count; i++) {
                params.sockets.dce.items[i].nAttCtrlEntries = nAttCtrlEntries;
            }
        }
    },
    {
        description: "nGPRAs should be atleast nDIIs+ 1 (all DMIs share the GPRA region)",
        action: function(params) {
            if (params.system.nGpra < (params.sockets.dii.count + 1)) {
                params.system.nGpra = params.sockets.dii.count + 1;
            }
        },
        comment1: "FIXME: This places a constraint on how many DIIs we can have since the max nGPRA maestro let's us set it 24",
        comment2: "FIXME: Currently all DMIs are in the same interleaving group. Once this is fixed, we need to update gpra calculation according to this formula: min_nGPRA_value = getMaxNumberOfDynamicMemoryGroupsPerMemorySet(*this) + numDIIs() -numConfigurationDIIs() : Check with neha",
    }
];

module.exports = constraints;