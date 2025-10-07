#!/usr/bin/env node

'use strict';

var fs   = require('fs');
var path = require('path');
var proc = require('child_process');
var path = require('path');
var dt   = new Date();

//Returns a random integer between min (included) and max (excluded)
//Using Math.round() will give you a non-uniform distribution!
var getRandomInt = function(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
};

var getRandoms = function() {
    var wdata = '';
    
    //wdata += ",+k_reoder_rsp_max=0";
    //wdata += ",+k_reoder_rsp_tmr=0";
    //wdata += ",+k_req_vld_delay_min=0";
    //wdata += ",+k_req_vld_delay_max="; wdata += getRandomInt(0,1).toString();
    //wdata += ",+k_req_rdy_delay_min=0";
    //wdata += ",+k_req_rdy_delay_max="; wdata += getRandomInt(0,1).toString();
    //wdata += ",+k_rsp_vld_delay_min=0";
    //wdata += ",+k_rsp_vld_delay_max="; wdata += getRandomInt(0,1).toString();
    //wdata += ",+k_rsp_rdy_delay_min=0";
    //wdata += ",+k_rsp_rdy_delay_max="; wdata += getRandomInt(0,1).toString();
    //wdata += ",+k_req_vld_burst_pct=100";
    //wdata += ",+k_req_rdy_burst_pct=100";
    //wdata += ",+k_rsp_vld_burst_pct=100";
    //wdata += ",+k_rsp_rdy_burst_pct=100";
    //wdata += ",+k_req_vld_grp_dly_min=0";
    //wdata += ",+k_req_vld_grp_dly_max="; wdata += getRandomInt(0,32).toString();
    //wdata += ",+k_req_vld_grp_pkt_min=0";
    //wdata += ",+k_req_vld_grp_pkt_max="; wdata += getRandomInt(0,8).toString();
    //wdata += ",+k_req_inj_pkt_num=";     wdata += getRandomInt(0,500).toString();
    //wdata += ",+k_req_inj_pkt_dly=";     wdata += getRandomInt(64,128).toString();
    //wdata += ",+k_rsp_vld_grp_dly_min=0";
    //wdata += ",+k_rsp_vld_grp_dly_max="; wdata += getRandomInt(0,32).toString();
    //wdata += ",+k_rsp_vld_grp_pkt_min=0";
    //wdata += ",+k_rsp_vld_grp_pkt_max="; wdata += getRandomInt(0,8).toString();
    //wdata += ",+k_rsp_inj_pkt_num=";     wdata += getRandomInt(0,500).toString();
    //wdata += ",+k_rsp_inj_pkt_dly=";     wdata += getRandomInt(64,128).toString();
    wdata += ",+ntb_random_seed="; wdata += getRandomInt(1, 967108864).toString();
    wdata += ",+UVM_MAX_QUIT_COUNT=1";
    wdata += ",+disable_strict_sv_check";
    wdata += ",+UVM_VERBOSITY=UVM_NONE";

    return(wdata);
};

var compileCmd = function(configFile) {
    var dir = path.basename(configFile);
    var wdata = '';
  
    dir = dir.substr(0, (dir.length - 4)); //console.log('dir: ' + dir);
    wdata  = "\n##\n## DCE regression set\n##Config File: " + configFile + "\n##\n";
    wdata += "node $WORK_TOP/dv/scripts/rsim.js -e dce -a -m -c -q -d DUMP_ON,DISABLE_STRRSP_TR_CHECK,STRICT_ON,EXCLUSIVE_MON,ASSERT_ON,HNT_CHECKER_ON,INHOUSE_OCP_VIP -C " + configFile + " -n " + dir + "\n\n";

    return(wdata);
};

var commonTest = function(configFile, iter, testName, cb0) {
    var dir = path.basename(configFile);
    var wdata = '';
    
    dir = dir.substr(0, (dir.length - 4)); //console.log('dir: ' + dir);
    
    for(var i = 0; i <iter; i++) {
        var temp_data = '';
       
        temp_data = "node $WORK_TOP/dv/scripts/rsim.js -e dce -q -t " + testName + " -r -n " + dir + " -p " + getRandoms();

        //Call-BackAdditions
        temp_data = cb0(temp_data);
        
        wdata += temp_data;
    }

    return(wdata);
};

var dirm_alloc_test = function(configFile, iter) {
    
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        return(data + ",+dirm_scb_en=1,+dirm_alloc_test\n");
    });

    return(wdata);
};

var addr_sharing_test = function(configFile, iter) {
    
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+correctible_error=";
        data += getRandomInt(10,30).toString();
        data += ",+dirm_scb_en=1,+addr_sharing_test\n";
        return(data);
    });

    return(wdata);
};

var mem_test = function(configFile, iter) {
    
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+correctible_error=";
        data += getRandomInt(20,40).toString();
        data += ",+dirm_scb_en=1,+mem_test\n";
        return(data);
    });

    return(wdata);
};

var dvm_test = function(configFile, iter) {
    
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        return(data + ",+dirm_scb_en=1,+dvm_test\n");
    });

    return(wdata);
};

var random_test = function(configFile, iter) {
    
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        return(data + ",+dirm_scb_en=1\n");
    });

    return(wdata);
};

//Single bit error tests
var cor_err1 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+correctible_error=";
        data += getRandomInt(60,100).toString();
        data += ",+dirm_alloc_test,+dirm_scb_en=1\n";
        return(data);
    });

    return(wdata);
};

var cor_err2 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+correctible_error=";
        data += getRandomInt(60,100).toString();
        data += ",+dirm_scb_en=1\n";
        return(data);
    });

    return(wdata);
};

var test3 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_dirucecr_errovf_reg_test', function(data) {
        data += ",+correctible_error=100";////       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test4 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_dirucecr_errthd_reg_test', function(data) {
        data += ",+correctible_error=100";////       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test5 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_dirucecr_errcnt_reg_test', function(data) {
        data += ",+correctible_error=100";////       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test6 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_dirucecr_errDetEn_reg_test', function(data) {
        data += ",+correctible_error=100";////       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test8 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_diruuecr_errIntEn_reg_test', function(data) {
        data += ",+uncorrectible_error=100";//       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test9 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_diruuecr_errovf_reg_test', function(data) {
        data += ",+uncorrectible_error=100";//       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test10 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_diruuecr_errDetEn_reg_test', function(data) {
        data += ",+uncorrectible_error=100";//       data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Reset-InMiddle Testing
var test12 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+reset_testing";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//DCE Recall address/data error tests
//Address Error (SFI SLV) on SNPrsp for Recall  +wt_err_snp_sfi_slv_recall=50
var test13 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+wt_err_snp_sfi_slv_recall=";  data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Data Error (SFI DERR) on SNPrsp for Recall +wt_err_snp_sfi_derr_recall=50
var test14 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+wt_err_snp_sfi_derr_recall=";  data += getRandomInt(40,80).toString();
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Transport Error has higher precedence over Address Error/Data Error
var test15 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+wt_err_snp_sfi_slv_recall=30,+wt_err_snp_sfi_derr_recall=30,+wt_err_snp_sfi_tmo=30";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//DCE propagated address/data error tests
var test16 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+wt_err_snp_sfi_slv=25,+wt_err_snp_sfi_derr=25,wt_err_snp_sfi_disc=30,+wt_err_snp_sfi_tmo=25";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//DCE All Snoop/Correctable Errors
var test17 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+wt_err_snp_sfi_slv_recall=15,+wt_err_snp_sfi_derr_recall=15,+wt_err_snp_sfi_slv=15";
        data += ",+wt_err_snp_sfi_derr=15,+wt_err_snp_sfi_disc=15,+wt_err_snp_sfi_tmo=15,+correctible_error=10";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//DCE Power Management tests
var pow_mgmt_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+power_mgmt_test,+force_reset_values=0";
        data += ",+dce_scb_en=0";
        data += ",+correctible_error=";
        data += getRandomInt(10,20).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE DIRUCASER bit-bash test
var dirucaser_bitbash_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dirucaser_bitbash_test,+force_reset_values=0";
        data += ",+dce_scb_en=0";
        data += ",+correctible_error=";
        data += getRandomInt(10,30).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

var reg_bit_bash_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_bitbash_reg_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=0,+force_reset_values=0";
        data += ",+dce_scb_en=1";
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE rand test all fetures are enabled expect uncorrectible error
var dce_rand_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dce_rand_test,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(20,80).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE coherent traffic test
var dce_coherent_traffic_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dce_coherent_traffic_test,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(60,80).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

var dce_min_addr_test1 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dce_rand_cmdreq_addr_test,+force_reset_values=0";
        data += ",+m_num_addr=min";
        data += ",+correctible_error=";
        data += getRandomInt(20,40).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

var dce_min_addr_test2 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dce_rand_cmdreq_addr_test,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(20,40).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE dirm alloc stress test
var dce_dirm_aloc_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+dirm_alloc_stress_test,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(20,40).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE error logging test
var error_logging_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+m_timeout_ns=5000000,+dirm_scb_en=1,+error_csr_log_test,+force_reset_values=0";
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE SFI Transport error test snoop recall errors also included
var dce_sfi_errors_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce_sfi_errors_test,+m_timeout_ns=5000000,+dirm_scb_en=1,+force_reset_values=0";
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE all errors in test
var dce_all_errors_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce_sfi_errors_test,+m_timeout_ns=5000000,+dirm_scb_en=1,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(60,80).toString();
        data += ",+uncorrectible_error=";
        data += getRandomInt(20,40).toString();
        data += "\n";
        return(data);
    });
    return(wdata);
};

//DCE No errors test. 
var dce_no_errors_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce_rand_test,+dce_no_errors,+m_timeout_ns=5000000,+dirm_scb_en=1,+force_reset_values=0";
        data += "\n";
        return(data);
    });
    return(wdata);

};

//DCE0 irq test
var dce_irq_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce0_oring_interrupts,+m_timeout_ns=1000000,+dirm_scb_en=1,+force_reset_values=0";
        data += "\n";
        return(data);
    });
    return(wdata);

};

//DCE interrrupt disable test
var dce_intr_disable_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce_intr_disable_test,+m_timeout_ns=5000000,+dirm_scb_en=1,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(60,80).toString();
        data += ",+uncorrectible_error=";
        data += getRandomInt(10,20).toString();
        data += "\n";
        return(data);
    });
    return(wdata);

};

//DCE error interrupt enable/disable test
var dce_err_detect_disable_test = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_unit_test', function(data) {
        data += ",+dce_err_detect_disable_test,+m_timeout_ns=5000000,+force_reset_values=0";
        data += ",+correctible_error=";
        data += getRandomInt(60,80).toString();
        data += ",+uncorrectible_error=";
        data += getRandomInt(10,20).toString();
        data += ",+dirm_scb_en=0,+dce_scb_en=0";
        data += "\n";
        return(data);
    });
    return(wdata);
};

var test19 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_power_management_test', function(data) {
        data +=",+pm_test_type=ca_snp_en,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test20 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_power_management_test', function(data) {
        data +=",+pm_test_type=ca_snp_en_rand,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test21 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_power_management_test', function(data) {
        data +=",+pm_test_type=mr_hnt_en_rand,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
    
};

var test22 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_power_management_test', function(data) {
        data +=",+pm_test_type=dvm_snp_en,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
    
};

var test23 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_power_management_test', function(data) {
        data +=",+pm_test_type=dvm_snp_en_rand,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
    
};

//OCP REG rd/wr tests
var test24 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'ocp_directed_reg_wr_rd_test', function(data) {
        data += "\n";
        return(data);
    });

    return(wdata);
};

var test25 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'ocp_directed_reg_reset_test', function(data) {
        data += "\n";
        return(data);
    });

    return(wdata);
};

//maint rd/wr test
var maint_rd_wr = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+maint_test_type=wr_test,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Maintanence Reall all tests
var recall_all = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+maint_test_type=recall_all,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

var recall_vctb = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+maint_test_type=recall_vctb,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Maintanence Recall Index/Way tests
var recall_locs = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+maint_test_type=recall_locs,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Maintanence Recall Address tests
var recall_addrs = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+maint_test_type=recall_addrs,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//Random recall operations on live traffic
var recall_randoms = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_strict_so_check,+disable_strict_sv_check";
        data += ",+correctible_error=";
        data += getRandomInt(20,40).toString();
        data += ",+maint_test_type=random_test,+dirm_scb_en=1";
        data += "\n";
        return(data);
    });

    return(wdata);
};

//*************************************************************************************************//
//Tests crossed with all
//Random recalls, single bit errors, functional tests included
var all_features1 = function(configFile, iter) {
    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+correctible_error=";
        data += getRandomInt(70,90).toString();
        data += ",+maint_test_type=random_test,+dirm_scb_en=1";
        data += ",+disable_strict_so_check,+disable_strict_sv_check\n";
        return(data);
    });

    return(wdata);
};
//*************************************************************************************************//

//Maintance Init All
var test29 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+maint_test_type=init_all";
        data += "\n";
        return(data);
    });
    return(wdata);
};

//Uncorrectable Error tests
var uncorrectable_err = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_test', function(data) {
        data += ",+dir_commit_check,+disable_end_state_check";
        data += ",+uncorrectible_error=";
        data += getRandomInt(10,20).toString();
        data += ",+correctible_error=";
        data += getRandomInt(10,20).toString();
        data += ",+disable_strict_so_check,+disable_strict_sv_check\n";
        return(data);
    });
    return(wdata);
};

var uncor_err_maint = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_maint_test', function(data) {
        data += ",+dir_commit_check,+disable_end_state_check";
        data += ",+uncorrectible_error=";
        data += getRandomInt(10,20).toString();
        data += ",+correctible_error=";
        data += getRandomInt(10,20).toString();
        data += ",+maint_test_type=random_test,+dirm_scb_en=1";
        data += ",+disable_strict_so_check,+disable_strict_sv_check\n";
        return(data);
    });
    return(wdata);
};

//ttdebug tests with comparisions
var ttdebug_test0 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_dbgops_test', function(data) {
        return(data + ",+dirm_scb_en=1,+mem_test,+correctible_error=10,+inject_dbg_ops\n");
    });

    return(wdata);
};

//ttdebug tests without comparisions
var ttdebug_test1 = function(configFile, iter) {

    var wdata = commonTest(configFile, iter, 'dce_csr_dbgops_test', function(data) {
        return(data + ",+dirm_scb_en=1,+mem_test,+correctible_error=10,+no_quiesce\n");
    });

    return(wdata);
};

var genRegress = function() {
    var writef   = 'dce_testlist.sh';
    var wdata    = '#! /bin/sh -f \n\n';

    var configFile = [
        //"$WORK_TOP/../test_projects/fsys_v1.5_configs/mini-EyeQ5.v1.apf"
        "$WORK_TOP/../test_projects/fsys_v1.5_configs/skyrunner_cc_sfNoPcache_v13.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config1.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config2.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config3.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config4.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config5.apf",
        "$WORK_TOP/../test_projects/achlProjects/new_dce_config6.apf"
    ];

    //Compile Commands
    configFile.forEach(function(f, idx, array) {
        wdata += compileCmd(f);
    });

    //Run commands
    configFile.forEach(function(f, idx, array) {

        //Functional tests
        //wdata += dirm_alloc_test(f, 5);
        //wdata += addr_sharing_test(f, 5);
        //wdata += mem_test(f, 5);
        //wdata += dvm_test(f, 5);
        //wdata += random_test(f, 5);
        //wdata += cor_err1(f, 5);
        //wdata += cor_err2(f, 5);

        //Maint tests
        //wdata += maint_rd_wr(f, 5);
        //wdata += recall_all(f, 5);
        //wdata += recall_vctb(f, 5);
        //wdata += recall_randoms(f, 5);

        //Tests crossed with all
        //Tests with single bit errors, recalls normal
        //wdata += all_features1(f, 5);

        //Uncorrectable error
        //wdata += uncorrectable_err(f, 5);
        //wdata += uncor_err_maint(f, 5);

        //De-classified test
        //wdata += dirucaser_bitbash_test(f, 5);

        /////////////////////////////////////
        //New Tests
        /////////////////////////////////////
        //dce rand tests
        wdata += dce_rand_test(f, 20);
        wdata += dce_coherent_traffic_test(f, 20);
        wdata += dce_min_addr_test1(f, 20);
        wdata += dce_min_addr_test2(f, 20);
        wdata += dce_dirm_aloc_test(f, 10);
        wdata += pow_mgmt_test(f, 10);
        wdata += dce_no_errors_test(f, 5);

        //////errors test
        wdata += error_logging_test(f, 5);
        wdata += dce_sfi_errors_test(f, 20);
        wdata += dce_all_errors_test(f, 10);

        //////DCE0 oring irq test
        wdata += dce_irq_test(f, 2);
        wdata += dce_intr_disable_test(f, 1);
        wdata += dce_err_detect_disable_test(f, 1);
        //////reg bit-bash test
        wdata += reg_bit_bash_test(f, 1);

        //ttdebug tests
        wdata += ttdebug_test0(f, 4);
        wdata += ttdebug_test1(f, 1);

        //Sanitty check
        //wdata += dce_rand_test(f, 1);
        //wdata += dce_coherent_traffic_test(f, 0);
        //wdata += dce_min_addr_test1(f, 1);
        //wdata += dce_min_addr_test2(f, 0);
        //wdata += dce_dirm_aloc_test(f, 0);
        //wdata += pow_mgmt_test(f, 0);
        //wdata += dce_no_errors_test(f, 0);
        ////errors test
        //wdata += error_logging_test(f, 1);
        //wdata += dce_sfi_errors_test(f, 1);
        //wdata += dce_all_errors_test(f, 1);
        //wdata += force_recall_rsp_error(f, 0);
        ////DCE0 oring irq test
        //wdata += dce_irq_test(f, 0);
        ////reg bit-bash test
        //wdata += reg_bit_bash_test(f, 0);
       
        ////CSR tests
        //wdata += test3(f,  1);
        //wdata += test4(f,  1);
        //wdata += test5(f,  1);
        //wdata += test6(f,  1);
        //wdata += test8(f,  1);
        //wdata += test9(f,  1);
        //wdata += test10(f, 1);
        //wdata += test12(f, 1);
        //wdata += test13(f, 1);
        //wdata += test14(f, 1);
        //wdata += test15(f, 1);
        //wdata += test16(f, 1);
        //wdata += test17(f, 1);
        //wdata += test19(f, 1);
        //wdata += test20(f, 1);
        //wdata += test21(f, 1);
        //wdata += test22(f, 1);
        //wdata += test23(f, 1);
        //wdata += test24(f, 1);
        //wdata += test25(f, 1);
    });

    // Output to file
    fs.writeFileSync(writef, wdata);
    fs.chmodSync(writef, 511);
};

genRegress();

