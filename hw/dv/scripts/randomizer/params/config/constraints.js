const constraints = [
    {
        "name": "c_ace_lite_e_warid_equals_wawid",
        "constraint": `
            foreach(ncioaiu[i]){
                (ncioaiu[i].fnNativeInterface.values == ACE5_Lite) -> (ncioaiu[i].wArId.values == ncioaiu[i].wAwId.values);
            }
        `,
        "comment1": "ACE-Lite-E has atomics and hence wAwId and wArId should be same",
        "comment2": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_fnNativeInterface_constraints",
        "constraint": `
            foreach(chi[i]){
                (chi[i].fnNativeInterface.values inside {CHI_B, CHI_E});
            }
            foreach(cioaiu[i]){
                (cioaiu[i].fnNativeInterface.values inside {ACE, ACE5});
            }
            foreach(ncioaiu[i]){
                (ncioaiu[i].fnNativeInterface.values inside {AXI4, AXI5, ACE_Lite, ACE5_Lite, PCIe_ACE_Lite, PCIe_AXI4, PCIe_AXI5});
            }
        `,
        "comment": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_temp_constraint_FIXME",
        "constraint": `
            foreach(cioaiu[i]){
                (cioaiu[i].nNativeInterfacePorts.values == 1);
            }
            foreach(ncioaiu[i]) {
                (ncioaiu[i].fnNativeInterface.values inside {AXI5, ACE_Lite, ACE5_Lite, PCIe_ACE_Lite, PCIe_AXI4, PCIe_AXI5}) -> (ncioaiu[i].nNativeInterfacePorts.values == 1);
            }
        `,
        "comment": "Currently only AXI4 and AXI5 multiported IOAIU is supported. There is an open JIRA which exists to resolve this",
        "comment2": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_pcie_socket_wData",
        "constraint": `
            foreach(cioaiu[i]) {
                cioaiu[i].wData.values != 512;
            }
            foreach(ncioaiu[i]) {
                if (ncioaiu[i].fnNativeInterface.values inside {PCIe_ACE_Lite, PCIe_AXI4, PCIe_AXI5}) {
                    ncioaiu[i].wData.values inside {256, 512};
                } else {
                    ncioaiu[i].wData.values != 512;
                }
            }
        `,
        "comment": "Currently only AXI4 and AXI5 multiported IOAIU is supported. There is an open JIRA which exists to resolve this",
        "comment2": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_wAxUser_bits",
        "constraint": "",
        "post_randomize":`
            int max_awuser=0;
            int max_aruser=0;
            int max_arid=0;
            int max_awid=0;

            foreach(cioaiu[i]) begin
                if (cioaiu[i].wAwUser.values  > max_awuser) begin
                    max_awuser = cioaiu[i].wAwUser.values;
                end
                if (cioaiu[i].wArUser.values  > max_aruser) begin
                    max_aruser = cioaiu[i].wArUser.values;
                end
                if (cioaiu[i].wArId.values  > max_arid) begin
                    max_arid = cioaiu[i].wArId.values;
                end
                if (cioaiu[i].wAwId.values  > max_awid) begin
                    max_awid = cioaiu[i].wAwId.values;
                end
            end

            foreach(ncioaiu[i]) begin
                if (ncioaiu[i].wAwUser.values  > max_awuser) begin
                    max_awuser = ncioaiu[i].wAwUser.values;
                end
                if (ncioaiu[i].wArUser.values  > max_aruser) begin
                    max_aruser = ncioaiu[i].wArUser.values;
                end
                if (ncioaiu[i].wArId.values  > max_arid) begin
                    max_arid = ncioaiu[i].wArId.values;
                end
                if (ncioaiu[i].wAwId.values  > max_awid) begin
                    max_awid = ncioaiu[i].wAwId.values;
                end
            end

            foreach(chi[i]) begin
                if (chi[i].req_rsvdc.values > max_awuser) begin
                    max_awuser = chi[i].req_rsvdc.values;
                end
                if (chi[i].req_rsvdc.values > max_aruser) begin
                    max_aruser = chi[i].req_rsvdc.values;
                end
            end

            foreach(dmi[i]) begin
                dmi[i].wAwUser.values = (max_awuser > max_aruser) ? max_awuser : max_aruser;
                dmi[i].wArUser.values = (max_awuser > max_aruser) ? max_awuser : max_aruser;
            end
            foreach(dii[i]) begin
                dii[i].wAwUser.values = (max_awuser > max_aruser) ? max_awuser : max_aruser;
                dii[i].wArUser.values = (max_awuser > max_aruser) ? max_awuser : max_aruser;
            end
        `,
        "comment": "FIXME: above constraint need to be understood and fixed. Remove max id, why aruser be atleast as wide as awuser?"
    },
    {
        "name": "c_all_address_widths_must_be_same",
        "constraint": `
            foreach(dii[i]){
                if (i>0){
                    dii[i].wAddr.values == dii[i-1].wAddr.values;
                }
            }
            foreach(chi[i]){
                chi[i].wAddr.values == dii[0].wAddr.values;
            }
            foreach(cioaiu[i]){
                cioaiu[i].wAddr.values == dii[0].wAddr.values;
            }
            foreach(ncioaiu[i]){
                ncioaiu[i].wAddr.values == dii[0].wAddr.values;
            }
            foreach(dmi[i]){
                dmi[i].wAddr.values == dii[0].wAddr.values;
            }
        `,
        "comment": "all addresses should have the same width"
    },
    {
        "name": "c_no_eventin_for_ace5lite",
        "constraint": `
            foreach(ncioaiu[i]){
                ((ncioaiu[i].fnNativeInterface.values inside {AXI4, AXI5, ACE_Lite, ACE5_Lite})) -> ncioaiu[i].useEventInInt.choice == 0;
            }
        `,
        "comment": "eventinint should be false for ACE5-Lite and AXI4, AXI5",
        "comment2": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_no_eventout_for_acelite_and_axi4",
        "constraint": `
            foreach(ncioaiu[i]){
                (ncioaiu[i].fnNativeInterface.values inside {AXI4, AXI5, ACE_Lite, ACE5_Lite, PCIe_ACE_Lite, PCIe_AXI4, PCIe_AXI5}) -> ncioaiu[i].useEventOutInt.choice == 0;
            }
        `,
        "comment": "eventoutint should be false for ACE-Lite and AXI4",
        "comment2": "CHI-E=0, CHI-B=1, ACE=2, ACE5=3, AXI4=4, AXI5=5, ACE-Lite=6, ACE5-Lite=7, PCIe_ACE-Lite=8, PCIe_AXI4=9, PCIe_AXI5=10"
    },
    {
        "name": "c_nways_should_be_power_of_2",
        "constraint": `
            foreach(snoopFilter[i]){
                $countones(snoopFilter[i].nWays.values) == 1;
            }
        `,
        "comment": "n ways should be power of 2"
    },
    {
        "name": "c_nsets_should_be_power_of_2",
        "constraint": `
            $countones(helper_nsets) == 1;
        `,
        "comment": "nsets should be power of 2"
    },
    {
        "name": "FIXME_c_max_snoopfilter_sets_combined",
        "constraint": `
            helper_nsets <= 65536 * structural.nDces.values;
        `,
        "comment": "FIXME: max snoop filters is 65536 * nDCEs This is not documented"
    },
    {
        "name": "c_sf_sets_divisible_by_dce",
        "constraint": `
            (helper_nsets % (structural.nDces.values)) == 0;
            (helper_nsets / (structural.nDces.values)) >= 16;
        `,
        "comment": "nsets must be divisible by number of DCEs"
    },{
        "name": "c_sf_and_dce_relation",
        "constraint": `
            structural.nSnoopFilters.values >= structural.nDces.values;
        `,
        "comment": "nsets must be divisible by number of DCEs"
    },
    {
        "name": "c_max_sf_filters",
        "constraint": `
            foreach(snoopFilter[i]) {
                if(i>0) {
                    snoopFilter[i].nSets.values == snoopFilter[i-1].nSets.values;
                }
            }
        `,
        "comment": "FIXME: This is a limitation of randomizer where all snoop filters will have the same nSets"
    },
    {
        "name": "c_max_sf_filters_size",
        "constraint": `
            snoopFilter[0].nSets.values == helper_nsets;
            structural.nSnoopFilters.values * $clog2(helper_nsets) <= 20;
        `,
        "comment": "FIXME: This is a limitation of randomizer where all snoop filters will have the same nSets"
    },
    {
        "name": "c_sfs_cache_repl_policy",
        "constraint": `
            foreach(snoopFilter[i]){
                if (i>0) {
                    snoopFilter[i].cacheReplPolicy.values == snoopFilter[i-1].cacheReplPolicy.values;
                }
            }
        `,
        "comment": "All snoop filters should have the same cache replacement policy"
    },
    {
        "name": "c_valid_skidbuf_size",
        "constraint": `
            foreach(dii[i]){
                dii[i].nCMDSkidBufSize.values >= (structural.nChis + ((cioaiu.sum() with (item.nNativeInterfacePorts.values) + ncioaiu.sum() with (item.nNativeInterfacePorts.values)) * 2));
            }
            foreach(dmi[i]){
                dmi[i].nCMDSkidBufSize.values >= (structural.nChis + ((cioaiu.sum() with (item.nNativeInterfacePorts.values) + ncioaiu.sum() with (item.nNativeInterfacePorts.values)) * 2));
            }
            foreach(dce[i]){
                dce[i].nCMDSkidBufSize.values >= (structural.nChis + ((cioaiu.sum() with (item.nNativeInterfacePorts.values) + ncioaiu.sum() with (item.nNativeInterfacePorts.values)) * 2));
            }
        `,
        "comment": "minimum skid buffer size should be atleast one entry for each CHI and 2 entries for every IOAIU - FIXME: check if this is documented"
    },
    {
        "name": "c_dce_power_of_2",
        "constraint": `
            $countones(structural.nDces.values) == 1;
        `,
        "comment": "Number of DCEs must be in power of 2"
    },
    {
        "name": "c_latency_counters_perf_counters",
        "constraint": `
            // foreach(chi[i]) {
            //     chi[i].nLatencyCounters.values inside {0,16};
            //     (chi[i].nLatencyCounters.values == 16) -> (chi[i].nPerfCounters.values >=4);
            // }
            // foreach(cioaiu[i]) {
            //     cioaiu[i].nLatencyCounters.values inside {0,16};
            //     (cioaiu[i].nLatencyCounters.values == 16) -> (cioaiu[i].nPerfCounters.values >=4);
            // }
            // foreach(ncioaiu[i]) {
            //     ncioaiu[i].nLatencyCounters.values inside {0,16};
            //     (ncioaiu[i].nLatencyCounters.values == 16) -> (ncioaiu[i].nPerfCounters.values >=4);
            // }
            // foreach(dmi[i]) {
            //     dmi[i].nLatencyCounters.values inside {0,16};
            //     (dmi[i].nLatencyCounters.values == 16) -> (dmi[i].nPerfCounters.values >=4);
            // }
            // foreach(dii[i]) {
            //     dii[i].nLatencyCounters.values inside {0,16};
            //     (dii[i].nLatencyCounters.values == 16) -> (dii[i].nPerfCounters.values >=4);
            // }
        `,
        "comment": "Relation between latency counters and perf counters"
    },
    {
        "name": "c_skid_buf_size_and_arb",
        "constraint": `
            // foreach(chi[i]) {
            //     chi[i].nLatencyCounters.values inside {0,16};
            //     (chi[i].nLatencyCounters.values == 16) -> (chi[i].nPerfCounters.values >=4);
            // }
            // foreach(cioaiu[i]) {
            //     cioaiu[i].nLatencyCounters.values inside {0,16};
            //     (cioaiu[i].nLatencyCounters.values == 16) -> (cioaiu[i].nPerfCounters.values >=4);
            // }
            // foreach(ncioaiu[i]) {
            //     ncioaiu[i].nLatencyCounters.values inside {0,16};
            //     (ncioaiu[i].nLatencyCounters.values == 16) -> (ncioaiu[i].nPerfCounters.values >=4);
            // }
            foreach(dmi[i]) {
                dmi[i].nCMDSkidBufArb.values inside {4, 8, 16, 32, 48, 64, 128, 192, 256};
                dmi[i].nCMDSkidBufSize.values inside {(dmi[i].nCMDSkidBufArb.values+0), (dmi[i].nCMDSkidBufArb.values+4), (dmi[i].nCMDSkidBufArb.values+8), (dmi[i].nCMDSkidBufArb.values+16), (dmi[i].nCMDSkidBufArb.values+32), (dmi[i].nCMDSkidBufArb.values+64), (dmi[i].nCMDSkidBufArb.values+96), (dmi[i].nCMDSkidBufArb.values+128), (dmi[i].nCMDSkidBufArb.values+160), (dmi[i].nCMDSkidBufArb.values+192), (dmi[i].nCMDSkidBufArb.values+224), (dmi[i].nCMDSkidBufArb.values+256)};
            }
            foreach(dmi[i]) {
                dmi[i].nMrdSkidBufArb.values inside {4, 8, 16, 32, 64, 128, 192, 256};
                dmi[i].nMrdSkidBufSize.values inside {(dmi[i].nMrdSkidBufArb.values+0), (dmi[i].nMrdSkidBufArb.values+4), (dmi[i].nMrdSkidBufArb.values+8), (dmi[i].nMrdSkidBufArb.values+16), (dmi[i].nMrdSkidBufArb.values+32), (dmi[i].nMrdSkidBufArb.values+64), (dmi[i].nMrdSkidBufArb.values+96), (dmi[i].nMrdSkidBufArb.values+128), (dmi[i].nMrdSkidBufArb.values+160), (dmi[i].nMrdSkidBufArb.values+192), (dmi[i].nMrdSkidBufArb.values+224), (dmi[i].nMrdSkidBufArb.values+256)};
            }
            foreach(dii[i]) {
                dii[i].nCMDSkidBufArb.values inside {4, 8, 16, 32, 48, 64, 128, 192, 256};
                dii[i].nCMDSkidBufSize.values inside {(dii[i].nCMDSkidBufArb.values+0), (dii[i].nCMDSkidBufArb.values+4), (dii[i].nCMDSkidBufArb.values+8), (dii[i].nCMDSkidBufArb.values+16), (dii[i].nCMDSkidBufArb.values+32), (dii[i].nCMDSkidBufArb.values+64), (dii[i].nCMDSkidBufArb.values+96), (dii[i].nCMDSkidBufArb.values+128), (dii[i].nCMDSkidBufArb.values+160), (dii[i].nCMDSkidBufArb.values+192), (dii[i].nCMDSkidBufArb.values+224), (dii[i].nCMDSkidBufArb.values+256)};
            }
            foreach(dce[i]) {
                dce[i].nCMDSkidBufArb.values inside {4, 8, 16, 32, 48, 64, 128, 192, 256};
                dce[i].nCMDSkidBufSize.values inside {(dce[i].nCMDSkidBufArb.values+0), (dce[i].nCMDSkidBufArb.values+4), (dce[i].nCMDSkidBufArb.values+8), (dce[i].nCMDSkidBufArb.values+16), (dce[i].nCMDSkidBufArb.values+32), (dce[i].nCMDSkidBufArb.values+64), (dce[i].nCMDSkidBufArb.values+96), (dce[i].nCMDSkidBufArb.values+128), (dce[i].nCMDSkidBufArb.values+160), (dce[i].nCMDSkidBufArb.values+192), (dce[i].nCMDSkidBufArb.values+224), (dce[i].nCMDSkidBufArb.values+256)};
            }
            // foreach(dce[i]) {
            //     dce[i].nMrdSkidBufArb.values inside {4, 8, 16, 32, 48, 64, 128, 192, 256};
            //     dce[i].nMrdSkidBufSize.values inside {(dce[i].nMrdSkidBufArb.values+0), (dce[i].nMrdSkidBufArb.values+4), (dce[i].nMrdSkidBufArb.values+8), (dce[i].nMrdSkidBufArb.values+16), (dce[i].nMrdSkidBufArb.values+32), (dce[i].nMrdSkidBufArb.values+64), (dce[i].nMrdSkidBufArb.values+96), (dce[i].nMrdSkidBufArb.values+128), (dce[i].nMrdSkidBufArb.values+160), (dce[i].nMrdSkidBufArb.values+192), (dce[i].nMrdSkidBufArb.values+224), (dce[i].nMrdSkidBufArb.values+256)};
            // }
        `,
        "comment": "Relation between latency counters and perf counters"
    },
    {
        "name": "c_ott_should_be_divisible_by_ports",
        "constraint": `
            foreach(ncioaiu[i]) {
                ncioaiu[i].nOttCtrlEntries.values % ncioaiu[i].nNativeInterfacePorts.values == 0;
                (ncioaiu[i].nOttCtrlEntries.values / ncioaiu[i].nNativeInterfacePorts.values) >=8;
            }
        `,
        "comment": "Relation between latency counters and perf counters"
    },
    {
        "name": "FIXME_c_min_nOtt_cntrl_entries",
        "constraint": `
            foreach(cioaiu[i]) {
                cioaiu[i].nOttCtrlEntries.values >= 8;
            }
            foreach(ncioaiu[i]) {
                ncioaiu[i].nOttCtrlEntries.values >= 8;
            }
            foreach(chi[i]) {
                chi[i].nOttCtrlEntries.values >= 8;
            }
        `,
        "comment": "Relation between latency counters and perf counters"
    },
    {
        "name": "FIXME_c_even_otts_for_ioaiu",
        "constraint": `
            foreach(cioaiu[i]) {
                cioaiu[i].nOttCtrlEntries.values % 2 == 0;
            }
            foreach(ncioaiu[i]) {
                ncioaiu[i].nOttCtrlEntries.values % 2 == 0;
            }
        `,
        "comment": "Not sure why this exists. Need to investigate FIXME"
    },
    {
        "name": "c_temp_FIXME_not_sure_why_this_error_is_happening",
        "constraint": `
            foreach(dmi[i]){
                foreach(cioaiu[j]) {
                    dmi[i].wArId.values >= cioaiu[j].wArId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                    dmi[i].wAwId.values >= cioaiu[j].wAwId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                }
                foreach(ncioaiu[j]) {
                    dmi[i].wArId.values >= ncioaiu[j].wArId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                    dmi[i].wAwId.values >= ncioaiu[j].wAwId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                }
                dmi[i].wArId.values >= 5 + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                dmi[i].wAwId.values >= 5 + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                dmi[i].wAwId.values == dmi[i].wArId.values;
            }
            foreach(dii[i]){
                foreach(cioaiu[j]) {
                    dii[i].wArId.values >= cioaiu[j].wArId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                    dii[i].wAwId.values >= cioaiu[j].wAwId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                }
                foreach(ncioaiu[j]) {
                    dii[i].wArId.values >= ncioaiu[j].wArId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                    dii[i].wAwId.values >= ncioaiu[j].wAwId.values + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                }
                dii[i].wArId.values >= 5 + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                dii[i].wAwId.values >= 5 + $clog2(structural.nCaius.values+structural.nNcaius.values+structural.nDces.values+structural.nDves.values+structural.nDmis.values+structural.nDiis.values);
                dii[i].wAwId.values == dii[i].wArId.values;
            }
        `,
        "comment": "See if the last part of the constraint is documented where wAwId should be same as wArId FIXME"
    },
    {
        "name": "c_max_number_of_migs",
        "constraint": `
            nMIGS.size() inside {1,2};
            if (nMIGS.size() == 1) {
                nMIGS[0].nGroups.size() >= 1;
                nMIGS[0].nGroups.size() <= structural.nDmis.values;
                nMIGS[1].nGroups.size() == 0;
            }else{
                nMIGS[0].nGroups.size() >= 1;
                nMIGS[0].nGroups.size() <= structural.nDmis.values;
                nMIGS[1].nGroups.size() >= 1;
                nMIGS[1].nGroups.size() <= structural.nDmis.values;
            }
            foreach(nMIGS[i]){
                //nMIGS[i].nGroups.size() inside {[1:structural.nDmis.values]};
                foreach(nMIGS[i].nGroups[j]) {
                    nMIGS[i].nGroups[j].values <= structural.nDmis.values;
                    $countones(nMIGS[i].nGroups[j].values) == 1;
                }
                nMIGS[i].nGroups.sum() with (item.values) == structural.nDmis.values;
            }
            if (nMIGS.size == 2) {
                if (nMIGS[0].nGroups.size() > nMIGS[1].nGroups.size()) {
                    system.nGPRA.values >= structural.nDiis.values + nMIGS[0].nGroups.size();
                }else{
                    system.nGPRA.values >= structural.nDiis.values + nMIGS[1].nGroups.size();
                }
            }else {
                system.nGPRA.values >= structural.nDiis.values + nMIGS[0].nGroups.size();
            }
        `,
        "comment": "constraints on the number of sets and groups in migs"
    },
    {
        "name": "c_max_number_of_migs_delete",
        "constraint": `
            // nMIGS.size() inside {1,2};
            // if (nMIGS.size() == 1) {
            //     nMIGS[0].nGroups.size() >= 1;
            //     nMIGS[0].nGroups.size() <= structural.nDmis.values;
            //     nMIGS[1].nGroups.size() == 0;
            // }else{
            //     nMIGS[0].nGroups.size() >= 1;
            //     nMIGS[0].nGroups.size() <= structural.nDmis.values;
            //     nMIGS[1].nGroups.size() >= 1;
            //     nMIGS[1].nGroups.size() <= structural.nDmis.values;
            // }
            // foreach(nMIGS[i]){
            //     foreach(nMIGS[i].nGroups[j]) {
            //         nMIGS[i].nGroups[j].values <= structural.nDmis.values;
            //         $countones(nMIGS[i].nGroups[j].values) == 1;
            //     }
            //     nMIGS[i].nGroups.sum() with (item.values) == structural.nDmis.values;
            // }
            
            // if (nMIGS.size == 2) {
            //     foreach (nMIGS[0].nGroups[i]) {
            //         if (i == 0) {
            //           max_groups1 == nMIGS[0].nGroups[i].values;
            //         } else {
            //           max_groups1 >= nMIGS[0].nGroups[i].values;
            //         }
            //     }
            //     foreach (nMIGS[0].nGroups[i]) {
            //         max_groups1 == nMIGS[0].nGroups[i].values || max_groups1 > nMIGS[0].nGroups[i].values;
            //     }
            //     foreach (nMIGS[1].nGroups[i]) {
            //         if (i == 0) {
            //           max_groups2 == nMIGS[1].nGroups[i].values;
            //         } else {
            //           max_groups2 >= nMIGS[1].nGroups[i].values;
            //         }
            //     }
            //     foreach (nMIGS[1].nGroups[i]) {
            //         max_groups2 == nMIGS[1].nGroups[i].values || max_groups2 > nMIGS[1].nGroups[i].values;
            //     }
            //     if(max_groups1 > max_groups2) {
            //         system.nGPRA.values >= structural.nDiis.values + max_groups1 -1;
            //     }else{
            //         system.nGPRA.values >= structural.nDiis.values + max_groups2 -1;
            //     }
            // }else {
            //     foreach (nMIGS[0].nGroups[i]) {
            //         if (i == 0) {
            //           max_groups1 == nMIGS[0].nGroups[i].values;
            //         } else {
            //           max_groups1 >= nMIGS[0].nGroups[i].values;
            //         }
            //     }
            //     foreach (nMIGS[0].nGroups[i]) {
            //         max_groups1 == nMIGS[0].nGroups[i].values || max_groups1 > nMIGS[0].nGroups[i].values;
            //     }
            //     system.nGPRA.values >= structural.nDiis.values + max_groups1 -1;
            // }
            
        `,
        "comment": "FIXME: This is an example constraint. We need require it for later"
    },
    {
        "name": "c_consistent_dce_parameters",
        "constraint": `
            foreach(dce[i]) {
                if(i>0){
                    dce[i].nDceRbCredits.values == dce[i-1].nDceRbCredits.values;
                    dce[i].nAiuSnpCredits.values == dce[i-1].nAiuSnpCredits.values;
                    dce[i].nAttCtrlEntries.values == dce[i-1].nAttCtrlEntries.values;
                }
            }
        `,
        "comment": "all dces must have same rb credits, aiu snp credits and nattctrlEntries"
    },
    {
        "name": "c_chi_native_credits_ott_relation",
        "constraint": `
            foreach(chi[i]) {
                chi[i].nOttCtrlEntries.values > chi[i].nNativeCredits.values;
            }
        `,
        "comment": "why should this be greater. why not equal?"
    },{
        "name": "c_warid_n_procs",
        "constraint": `
            foreach(cioaiu[i]) {
                cioaiu[i].wArId.values > $clog2(cioaiu[i].nProcessors.values);
                cioaiu[i].wAwId.values > $clog2(cioaiu[i].nProcessors.values);
            }
            foreach(ncioaiu[i]) {
                ncioaiu[i].nProcessors.values == 1;
            }
        `,
        "comment": "FIXME. This need to be documented? Need to check"
    },
    {
        "name": "temp_constraint",
        "constraint": `
            structural.nIoaius <= 32;
        `,
        "comment": "FIXME. This need to be documented? Need to check"
    }
]

module.exports = constraints;