var fs = require('fs');
var str = '';
var configs = ['dce_config2', 'dce_config3', 'dce_config4', 'dce_config5', 'dce_config6'];

configs.forEach(function(config) {
    var cur_params = require('/home/dclarino/line_coverage/codegen/' + config + '_achlParams.json');
    var tot_addrs = 0;
    cur_params.SnoopFilterInfo.forEach( function(snoop) {
	if(snoop.fnFilterType == "TAGFILTER")
	    tot_addrs += snoop.StorageInfo.nWays * snoop.StorageInfo.nSets;
    });
    tot_addrs = 8 + tot_addrs; //num_addrs should be twice the total number of entries to guarantee recalls
    str+= '\n\n#############################################'
    str+= '\n#              ' + config
    str+= '\n#############################################'
    str += '\n\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -a -c -r -m -d MAINTENANCE_OP,BLK_SNPS_OCP_VIP,STRICT_ON,EXCLUSIVE_MON,ADDR_OFFSET_COLLISION,DUMP_ON -n ' + config + ' -C $WORK_TOP/../test_projects/achlProjects/new_' + config + '.apf'
    str += '\n\n# Directed Maintenance Test - Init All (Maintenance Op takes place when DCE is quiscent, no traffic)'
    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t dce_csr_maint_test -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=100,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=20,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=0,+wt_cmd_dvm_msg=10,+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=init_all,+k_timeout_usec=500,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_LOW'
    str += '\n\n# Directed Maintenance Test - Recall All (Maintenance Op takes place when DCE is quiscent, no traffic)'
    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t dce_csr_maint_test -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=100,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=20,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=0,+wt_cmd_dvm_msg=10,+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=recall_all,+k_timeout_usec=500,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_LOW'
    str += '\n\n# Directed Maintenance Test - Recall by Index/Way (Maintenance Op takes place when DCE is quiscent, no traffic)'
    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t dce_csr_maint_test -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=100,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=20,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=0,+wt_cmd_dvm_msg=10,+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=recall_locs,+k_timeout_usec=500,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_LOW'
    str += '\n\n# Directed Maintenance Test - Recall by Address (Maintenance Op takes place when DCE is quiscent, no traffic)'
    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t dce_csr_maint_test -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=100,+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=20,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=0,+wt_cmd_dvm_msg=10,+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=recall_addrs,+k_timeout_usec=500,+force_reset_values=0,+k_init_rand_state=0,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_LOW'
    //TODO loop DVM =50
    var traffic_strings = [
	'+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=0,+wt_cmd_cln_inv=0,+wt_cmd_wr_unq_ptl=0,+wt_cmd_wr_unq_full=0,,+wt_cmd_upd_inv=0,+wt_cmd_upd_vld=0,+wt_cmd_rd_cpy=0,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,',
	'+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=0,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=0,+wt_cmd_upd_vld=10,',
	'+wt_cmd_rd_cpy=0,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=0,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=0,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=10,+wt_cmd_upd_vld=0,',
	'+wt_cmd_rd_cpy=10,+wt_cmd_rd_vld=10,+wt_cmd_rd_unq=10,+wt_cmd_rd_cln=10,+wt_cmd_cln_unq=10,+wt_cmd_cln_vld=10,+wt_cmd_cln_inv=10,+wt_cmd_wr_unq_ptl=10,+wt_cmd_wr_unq_full=10,+wt_cmd_upd_inv=10,+wt_cmd_upd_vld=10,'];
    var traffic_comments = ['Allocate Only', 'Allocate + No Change', 'Allocate + Evict', 'Allocate + No Change + Evict'];
    var maint_weights = ['+wt_maint_recall_all=100,+wt_maint_recall_addrs=0,+wt_maint_recall_loc=0 ','+wt_maint_recall_all=0,+wt_maint_recall_addrs=100,+wt_maint_recall_loc=0','+wt_maint_recall_all=0,+wt_maint_recall_addrs=0,+wt_maint_recall_loc=100','+wt_maint_recall_all=100,+wt_maint_recall_addrs=100,+wt_maint_recall_loc=100']
    var maint_comments = ['Recall All Only','Recall Addrs only','Recall Index Only','All Maintenance operations']
    maint_weights.forEach( function(maint_weight, maint_weight_no) {
	for(var dvm = 0; dvm < 51; dvm += 50) {
	    for(var i = 0; i < 1; i++) {
		traffic_strings.forEach( function(traffic_string, traffic_string_no) {
		    str += '\n\n#Maint Random test -- Traffic : ' + traffic_comments[traffic_string_no] + ' | Maint Ops : ' + maint_comments[maint_weight_no];
		    str += '\nnode $WORK_TOP/dv/scripts/rsim.js -e dce -t dce_csr_maint_test -r -n ' + config + ' -p +k_num_addr=' + tot_addrs + ',+k_num_cmd=10000,' + traffic_string + '+wt_cmd_dvm_msg=' + dvm + ',+ntb_random_seed=' + getRandomInt(0, 67108864).toString() + ',+maint_test_type=random_test,+k_timeout_usec=5000,+force_reset_values=0,+k_init_rand_state=0,+k_hnt_rsp_delay=1,+k_snp_rsp_delay=1,+k_str_rsp_delay=1,+UVM_MAX_QUIT_COUNT=1,+UVM_VERBOSITY=UVM_MEDIUM,' + maint_weight;
		});
	    }
	}
    });
});

fs.writeFileSync('testlist_maint', str, 'utf8');


function getRandomInt(min, max) {
  return Math.floor(Math.random() * (max - min)) + min;
}
