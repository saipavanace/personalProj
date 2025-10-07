var fs = require('fs');
var str = '';
var configs = ['new_dce_config1', 'new_dce_config2', 'new_dce_config3', 'new_dce_config4', 'new_dce_config5', 'new_dce_config6'];

configs.forEach(function(config) {
    var cur_params = require('/home/dclarino/line_coverage/codegen/' + config + '_achlParams.json');
    var tot_addrs = 0;
    cur_params.SnoopFilterInfo.forEach( function(snoop) {
	if(snoop.fnFilterType == "TAGFILTER")
	    tot_addrs += snoop.StorageInfo.nWays * snoop.StorageInfo.nSets;
    });
    tot_addrs = 8 + 2 * tot_addrs; //num_addrs should be twice the total number of entries to guarantee recalls
    str+= '\n\n#############################################'
    str+= '\n#              ' + config
    str+= '\n#############################################'
    str += '\n\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -a -c -r -m -d MAINTENANCE_OP,BLK_SNPS_OCP_VIP,STRICT_ON,EXCLUSIVE_MON,ADDR_OFFSET_COLLISION,DUMP_ON -n ' + config + ' -C $WORK_TOP/../test_projects/achlProjects/new_' + config + '.apf'
    var tests = ['dce_csr_dirucecr_errovf_reg_test', 'dce_csr_dirucecr_errthd_reg_test', 'dce_csr_dirucecr_errcnt_reg_test', 'dce_csr_dirucecr_errDetEn_reg_test', 'dce_csr_diruuecr_errIntEn_reg_test', 'dce_csr_diruuecr_errDetEn_reg_test','dce_csr_diruuecr_errDetEn_reg_test']
    //TODO loop DVM =50
    for(var dvm = 0; dvm < 50; dvm += 50) {
	tests.forEach(function(test,test_no) {
	    str += '\n\n#' + test + ' : Allocate + No Change + Evict\n'
	    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t ' + test + ' -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+en_dump,+wt_cmd_upd_inv=10,+wt_cmd_upd_vld=10,+wt_cmd_dvm_msg=' + dvm + ',+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=5000,+force_reset_values=0,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM'
	    str += '\n\n# Allocate Only\n'
	    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t ' + test + ' -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,+wt_cmd_rd_cpy=0,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=0,+wt_cmd_cln_inv=0,+wt_cmd_wr_unq_ptl=0,+wt_cmd_wr_unq_full=0,,+en_dump,+wt_cmd_upd_inv=0,+wt_cmd_upd_vld=0,+wt_cmd_dvm_msg=' + dvm + ',+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=5000,+force_reset_values=0,+k_init_rand_state=0,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM'
	    str += '\n\n#Allocate + No Change\n'
	    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t ' + test + ' -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=0,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+en_dump,+wt_cmd_upd_inv=0,+wt_cmd_upd_vld=10,+wt_cmd_dvm_msg=' + dvm + ',+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=5000,+force_reset_values=0,+k_init_rand_state=0,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM'
	    str += '\n\n#Allocate + Evict\n'
	    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t ' + test + ' -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,+wt_cmd_rd_cpy=0,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=0,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=0,+wt_cmd_wr_unq_full=10,+en_dump,+wt_cmd_upd_inv=10,+wt_cmd_upd_vld=0,+wt_cmd_dvm_msg=' + dvm + ',+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=5000,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM'
	});
    }
});

fs.writeFileSync('testlist_error', str, 'utf8');


function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}
