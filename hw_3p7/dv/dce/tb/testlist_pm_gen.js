var fs = require('fs');
var str = '';
var configs = ['new_dce_config2', 'new_dce_config3', 'new_dce_config4', 'new_dce_config5', 'new_dce_config6'];

configs.forEach(function(config) {
    var iter_max = 1;
    var tot_addrs = 34;
    var config_dir = 'pm_' + config;
    str+= '\n\n#############################################'
    str+= '\n#              ' + config
    str+= '\n#############################################'
    str += '\n\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -a -c -r -m -d MAINTENANCE_OP,BLK_SNPS_OCP_VIP,STRICT_ON,EXCLUSIVE_MON,ADDR_OFFSET_COLLISION,DUMP_ON -n ' + config_dir + ' -C $WORK_TOP/../test_projects/achlProjects/' + config + '.apf'
    var tests = ['dce_power_management_test']
    for(var iter = 0; iter < iter_max; iter++) {
	tests.forEach(function(test,test_no) {
	    str += '\n\n#' + test + ' : Allocate + Non-Allocate + Evict\n'
	    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t ' + test + ' -r -n ' + config_dir + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=5,+wt_cmd_wr_unq_full=5,+wt_cmd_upd_inv=0,+wt_cmd_dvm_msg=0,+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=10000,+force_reset_values=0,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM,+pm_test_type=sf_en_in_middle'
	});
    }
});

str += '\n\npython ../../scripts/bucketize.py +run_dir=../../../debug/dce\n'

fs.writeFileSync('testlist_pm', str, 'utf8');


function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}


