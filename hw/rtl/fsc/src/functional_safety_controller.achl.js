//=============================================================================
// Copyright(C) 2016 Arteris, Inc.
// All rights reserved
//=============================================================================
// Safety Controller
// Author: Mohammed Khaleeluddin 
//
// Safety controller with AMBA3 APB Spec v1.0 interface
//
//=============================================================================
'use strict';

//=============================================================================
// Included Modules
//=============================================================================

//=============================================================================
// Library Files
//=============================================================================

var utils = require('../../lib/src/utils.js');

//=============================================================================
// fault_checker() Function Declaration
//=============================================================================

function functional_safety_controller() {
    this.defineName('functional_safety_controller');
    this.useParamDefaults = true ;
    var u = utils.init(this);

//=========================================================================
// Parameter Declarations
//=========================================================================

u.paramDefault('nUnits', 'int', 2, 2, 128);
u.paramDefault('wAddr', 'int', 6);
u.paramDefault('wData', 'int', 32);
u.paramDefault('wThresWidth', 'int', 8 ) ;

//=========================================================================
// Interfaces
//=========================================================================


// per unit inputs 

for (var i = 0; i < u.getParam('nUnits'); i++)
    {
	u.input('mission_fault_'+i, 1);
	u.input('latent_fault_'+i, 1);
	u.input('cerr_over_thres_fault_'+i, 1);
	u.output('bist_next_'+i, 1);
	u.input('bist_ack_'+i, 1);
    u.output('cerr_threshold_vld_'+i,1);
    u.input('cerr_threshold_ack_'+i,1);
    }
u.output ('cerr_threshold', u.getParam('wThresWidth'));

u.output('mission_fault_int', 1);
u.output('latent_fault_int', 1);
u.output('cerr_over_thres_int', 1);
		
// APB interface 
 
u.input('paddr', u.getParam('wAddr'));
u.input('psel', 1);
u.input('penable', 1);
u.input('pwrite', 1);
u.input('pwdata', u.getParam('wData'));
u.output('pready', 1);
u.output('prdata', u.getParam('wData'));
u.output('pslverr', 1);

var maxUnits = 128;
var numUnits = u.getParam('nUnits');
var regWidth = u.getParam('wData');
var nStatusRegs = maxUnits/regWidth;
var nBistStates = 5;
//var wThresWidth = u.getParam('wThresWidth');    


//=========================================================================
// fault capture logic
//=========================================================================

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
//Fault CDC logic
//

for(var i = 0; i < u.getParam('nUnits'); i++)
    {
	u.synchronize('mission_fault_'+i, 1);
	u.synchronize('latent_fault_'+i, 1);
	u.synchronize('cerr_over_thres_fault_'+i, 1);
	u.synchronize('bist_ack_'+i, 1);
    u.synchronize('cerr_threshold_ack_'+i,1);
    }

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// fault capture tree
//

u.signal('mission_fault', u.getParam('nUnits'));
u.signal('latent_fault', u.getParam('nUnits'));
u.signal('cerr_over_thres_fault', u.getParam('nUnits'));
u.signal('mission_fault_all', 1);
u.signal('latent_fault_all', 1);
u.signal('cerr_over_thres_all', 1);

this.always(function(){
    //!! for (var i=0; i<u.getParam('nUnits'); i++) {
    mission_fault[$i$] = fault_inv ^ mission_fault_$i$_sync;
    latent_fault[$i$] = fault_inv ^ latent_fault_$i$_sync;
    cerr_over_thres_fault[$i$] =  cerr_over_thres_fault_$i$_sync ;   
    //!! }
    mission_fault_all = [mission_fault].reduceOr;
    latent_fault_all = [latent_fault].reduceOr;
    cerr_over_thres_all = [cerr_over_thres_fault].reduceOr;
    mission_fault_and_all = [mission_fault].reduceAnd;
    latent_fault_and_all = [latent_fault].reduceAnd;
});

    
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// BIST FSM
//

var wBistState = 3;
u.signal('nxt_state', wBistState);
u.signal('ST_IDLE', wBistState);
u.signal('ST_RESET_FULL', wBistState);
u.signal('ST_FORCE_MISSION', wBistState);
u.signal('ST_FORCE_LATENT', wBistState);
u.signal('ST_FORCE_FULL', wBistState); 
u.signal('ST_RESET_FINAL', wBistState); 

this.always(function(){
    ST_IDLE = '0'.d("wBistState");
    ST_RESET_FULL = '1'.d("wBistState");
    ST_FORCE_FULL = '2'.d("wBistState");
    ST_FORCE_LATENT = '3'.d("wBistState");
    ST_FORCE_MISSION = '4'.d("wBistState");
    ST_RESET_FINAL = '5'.d("wBistState");
    });

u.dffre('bist_state', 'nxt_state', "'1'.b(1)", wBistState, 0);

this.always(function(){
    switch (bist_state) 
    {
	case ST_IDLE: 
	nxt_state = bist_start_en ? ST_RESET_FULL : ST_IDLE; break;
	case ST_RESET_FULL: 
	nxt_state = bist_fsm_update ? ST_FORCE_MISSION : ST_RESET_FULL; break;
	case ST_FORCE_MISSION:
	nxt_state = bist_fsm_update ? ST_FORCE_LATENT : ST_FORCE_MISSION; break;
	case ST_FORCE_LATENT:
	nxt_state = bist_fsm_update ? ST_FORCE_FULL : ST_FORCE_LATENT; break;
	case ST_FORCE_FULL:
	nxt_state = bist_fsm_update ? ST_RESET_FINAL : ST_FORCE_FULL; break;
	case ST_RESET_FINAL: 
	nxt_state = bist_ack_done ? ST_IDLE : ST_RESET_FINAL; break;
	default:
	nxt_state = ST_IDLE;
    }
    });

this.always(function(){
    bist_fsm_en = ~((bist_state == ST_IDLE) | (bist_state == ST_RESET_FINAL));
    bist_ack_and_all = [
	//!!for (var i = 0; i < u.getParam('nUnits'); i++) {
	bist_ack_$i$_sync ,
	//!! }
	'1'.b(1)].reduceAnd;
    bist_ack_or_all = [
	//!!for (var i = 0; i < u.getParam('nUnits'); i++) {
	bist_ack_$i$_sync ,
	//!! }
	'0'.b(1)].reduceOr;
    bist_ack_done_early =  bist_ack_or_all_reg & ~bist_ack_or_all;
    bist_ack_set_early = ~bist_ack_and_all_reg & bist_ack_and_all;
    bist_fsm_update = (((bist_ack_done & bist_auto_run) |
			(bist_man_step & ~bist_auto_run)) & bist_fsm_en);
    // start signal 
    bist_nxt_set = ((bist_start_en_reg) | 
		    ((bist_ack_done & bist_auto_run) |
		     (bist_man_step & ~bist_auto_run)) & bist_fsm_en);
    bist_nxt_en = bist_nxt_set | bist_ack_set;
    bist_nxt_in = (bist_nxt_set) ? '1'.b(1) : '0'.b(1); 
    // FSM invert ctrl 
    fault_inv = (((bist_state == ST_FORCE_FULL) | 
		  (bist_state == ST_FORCE_MISSION) |
                  (bist_state == ST_FORCE_LATENT)) & bist_ack_done_early);

    // done signalling
    bist_reset_full_done_en = ((bist_state == ST_RESET_FULL) & bist_ack_done) | bist_start_en;
    bist_force_full_done_en = ((bist_state == ST_FORCE_FULL) & bist_ack_done) | bist_start_en;
    bist_force_latent_done_en = ((bist_state == ST_FORCE_LATENT) & bist_ack_done) | bist_start_en;
    bist_force_mission_done_en = ((bist_state == ST_FORCE_MISSION) & bist_ack_done) | bist_start_en;
    bist_reset_final_done_en = ((bist_state == ST_RESET_FINAL) & bist_ack_done) | bist_start_en;
    });

u.dffre('bist_ack_or_all_reg', 'bist_ack_or_all', "'1'.b(1)", 1, 0);
u.dffre('bist_ack_and_all_reg', 'bist_ack_and_all', "'1'.b(1)", 1, 0);
u.dffre('bist_ack_done', 'bist_ack_done_early', "'1'.b(1)", 1, 0);
u.dffre('bist_ack_set', 'bist_ack_set_early', "'1'.b(1)", 1, 0);
    

for (var i=0; i<numUnits; i++) 
    {
	u.dffre('bist_nxt_reg_'+i, 'bist_nxt_in','bist_nxt_en', 1, 0);
    }

this.always(function(){
    //!! for (var i=0; i<numUnits; i++) {
    bist_next_$i$ = bist_nxt_reg_$i$;
    //!! }
    });
    
//=========================================================================
// APB interface logic
//=========================================================================

u.dffre('addr_reg', 'paddr', 'psel', u.getParam('wAddr'), 0);
u.dffre('write_reg', 'pwrite_in', "'1'.b(1)", 1, 0);
u.dffre('enable_reg', 'penable_in', "'1'.b(1)", 1, 0);
u.dffre('wdata_reg', 'pwdata', 'pwdata_en', u.getParam('wData'), 0);

this.always(function(){
    pwdata_en = psel & penable;
    pwrite_in = psel & pwrite;
    penable_in = psel & penable;
    });
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Address Decode
//

this.always(function(){
    bist_ctrl_sel = (addr_reg == '00'.h("u.getParam('wAddr')"));
    bist_status_sel = (addr_reg == '04'.h("u.getParam('wAddr')"));
    cerr_thres_sel = (addr_reg == '08'.h("u.getParam('wAddr')"));
    //!! for (var i=0; i<nStatusRegs; i++) {
    latent_fault_sel$i$ = (addr_reg == '"i*4+16"'.d("u.getParam('wAddr')"));
    mission_fault_sel$i$ = (addr_reg == '"i*4+32"'.d("u.getParam('wAddr')"));
    cerr_over_thres_fault_sel$i$ = (addr_reg == '"i*4+48"'.d("u.getParam('wAddr')"));
    //!! }
    });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// BIST CTRL reg
//

this.always(function(){
    bist_auto_run_en   = ((bist_ctrl_sel & enable_reg & write_reg & wdata_reg[0]) |
			  (bist_reset_final_done_en & ~bist_start_en));
    bist_step_en       = ((bist_ctrl_sel & enable_reg & write_reg & wdata_reg[1]));
    });

this.always(function(){
    bist_start_en = (~bist_auto_run_reg & bist_auto_run) | (bist_man_step & (bist_state == ST_IDLE));
    bist_auto_run_in = (bist_reset_final_done_en & ~bist_start_en) ? '0'.b(1) : '1'.b(1);
    });

this.always(function(){
    
//!!for (var i = 0; i < u.getParam('nUnits'); i++) {
    cerr_threshold_vld_$i$ = cerr_thres_vld ;
//!! } 
    cerr_thres_reg_en =  cerr_thres_sel & enable_reg & write_reg ;
    cerr_thres_reg_in = wdata_reg["u.getParam('wThresWidth')-1",0];
    cerr_threshold    = cerr_thres_reg;
    cerr_thres_vld_set = cerr_thres_reg_en  ;
    cerr_thres_vld_reset = [
	//!!for (var i = 0; i < u.getParam('nUnits'); i++) {
cerr_threshold_ack_$i$_sync,
    
	//!! }
	'1'.b(1)].reduceAnd ;
    
    cerr_thres_vld_reg_en = cerr_thres_vld_set | cerr_thres_vld_reset ;
    cerr_thres_vld_in = cerr_thres_vld_set ? '1'.b(1) : '0'.b(1) ;


});

u.dffre('bist_auto_run', 'bist_auto_run_in', 'bist_auto_run_en', 1, 0);
u.dffre('bist_auto_run_reg', 'bist_auto_run', "'1'.b(1)", 1, 0);
u.dffre('bist_man_step', 'bist_step_en', "'1'.b(1)", 1, 0);
u.dffre('bist_start_en_reg', 'bist_start_en', "'1'.b(1)", 1, 0);    
    
u.dffre('cerr_thres_reg', 'cerr_thres_reg_in', "cerr_thres_reg_en", u.getParam('wThresWidth'), 1);
u.dffre('cerr_thres_vld', 'cerr_thres_vld_in', "cerr_thres_vld_reg_en ", 1 , 0);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// BIST status reg
//

u.signal('bist_done', nBistStates);
u.signal('bist_err', nBistStates);
u.signal('bist_status', u.getParam('wData'));

this.always(function(){
    bist_reset_full_done_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_force_full_done_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_force_latent_done_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_force_mission_done_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_reset_final_done_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    });

u.dffre('bist_reset_full_done', 'bist_reset_full_done_in', 'bist_reset_full_done_en', 1, 0);
u.dffre('bist_force_full_done', 'bist_force_full_done_in', 'bist_force_full_done_en', 1, 0);
u.dffre('bist_force_latent_done', 'bist_force_latent_done_in', 'bist_force_latent_done_en', 1, 0);
u.dffre('bist_force_mission_done', 'bist_force_mission_done_in', 'bist_force_mission_done_en', 1, 0);
u.dffre('bist_reset_final_done', 'bist_reset_final_done_in', 'bist_reset_final_done_en', 1, 0);

this.always(function(){
    bist_done = [bist_reset_final_done, bist_force_full_done, bist_force_latent_done,
		 bist_force_mission_done, bist_reset_full_done].concat;
    });


this.always(function(){
    // in 
    bist_reset_full_err_in = (bist_start_en) ? '0'.b(1) : '1'.b(1); 
    bist_force_full_err_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_force_latent_err_in = (bist_start_en) ? '0'.b(1) : '1'.b(1);
    bist_force_mission_err_in = (bist_start_en) ? '0'.b(1) : '1'.b(1); 
    bist_reset_final_err_in = (bist_start_en) ? '0'.b(1) : (mission_fault_all | latent_fault_all | cerr_over_thres_all );
    // en 
    bist_reset_full_err_en = ((((bist_state == ST_RESET_FULL) & bist_ack_done) & (mission_fault_all | latent_fault_all | cerr_over_thres_all))
                              | bist_start_en);
    bist_force_full_err_en = ((((bist_state == ST_FORCE_FULL) & bist_ack_done_early) & (mission_fault_all | ~latent_fault_and_all)) |
                              (((bist_state == ST_FORCE_FULL) & bist_ack_done) & (~mission_fault_and_all | latent_fault_all)) |
                              bist_start_en);
    bist_force_latent_err_en = ((((bist_state == ST_FORCE_LATENT) & bist_ack_done_early) & (~mission_fault_and_all | latent_fault_all)) |
                                (((bist_state == ST_FORCE_LATENT) & bist_ack_done) & (mission_fault_all | ~latent_fault_and_all))|
                                 bist_start_en);
    bist_force_mission_err_en = ((((bist_state == ST_FORCE_MISSION) & bist_ack_done_early) & (mission_fault_all | latent_fault_all)) |
                                 (((bist_state == ST_FORCE_MISSION) & bist_ack_done) & (~mission_fault_and_all | ~latent_fault_and_all)) |
                                 bist_start_en);
    bist_reset_final_err_en = ((((bist_state == ST_RESET_FINAL) & bist_ack_done) & (mission_fault_all | latent_fault_all)) |
                               bist_start_en);
    });
    
u.dffre('bist_reset_full_err', 'bist_reset_full_err_in', 'bist_reset_full_err_en', 1, 0);
u.dffre('bist_force_full_err', 'bist_force_full_err_in', 'bist_force_full_err_en', 1, 0);
u.dffre('bist_force_latent_err', 'bist_force_latent_err_in', 'bist_force_latent_err_en', 1, 0);
u.dffre('bist_force_mission_err', 'bist_force_mission_err_in', 'bist_force_mission_err_en', 1, 0);
u.dffre('bist_reset_final_err', 'bist_reset_final_err_in', 'bist_reset_final_err_en', 1, 0);

this.always(function(){
    bist_err = [bist_reset_final_err,  bist_force_full_err, bist_force_latent_err,
		bist_force_mission_err,  bist_reset_full_err].concat;
    });

this.always(function(){
    bist_status_reg = ['0'.b("regWidth-2*nBistStates"), bist_err, bist_done].concat;
    });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Latent Fault regs
//

u.signal('latent_fault_reg', maxUnits);

this.always(function(){
    latent_fault_reg = ['0'.b("maxUnits-numUnits"), latent_fault].concat;
    });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Mission Fault regs
//

u.signal('mission_fault_reg', maxUnits);

this.always(function(){
    mission_fault_reg = ['0'.b("maxUnits-numUnits"), mission_fault].concat;
    });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Cerr Err Fault regs
//

u.signal('cerr_over_thres_fault_reg', maxUnits);

this.always(function(){
    cerr_over_thres_fault_reg = ['0'.b("maxUnits-numUnits"), cerr_over_thres_fault ].concat;
    });


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Read Decode
//

this.always(function(){
    prdata = (([bist_status_sel].repeat("regWidth") & bist_status_reg) |
              ([cerr_thres_sel].repeat("regWidth") & ['0'.b("regWidth-u.getParam('wThresWidth')"), cerr_thres_reg].concat ) |
	     //!! for (var i = 0; i<nStatusRegs; i++) {
	     ([latent_fault_sel$i$].repeat("regWidth") & latent_fault_reg["regWidth+(regWidth*i)-1", "regWidth*i"]) |
	     ([mission_fault_sel$i$].repeat("regWidth") & mission_fault_reg["regWidth+(regWidth*i)-1", "regWidth*i"]) |
	     ([cerr_over_thres_fault_sel$i$].repeat("regWidth") & cerr_over_thres_fault_reg["regWidth+(regWidth*i)-1", "regWidth*i"]) |
	     //!! }
	     '0'.b("regWidth"));
    pready = penable;
    pslverr = '0'.b(1);
    });

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Interrupts
//

u.dffre('mission_fault_int_q', 'mission_fault_all', "'1'.b(1)", 1, 0);
u.dffre('latent_fault_int_q', 'latent_fault_all', "'1'.b(1)", 1, 0);
u.dffre('cerr_over_thres_int_q', 'cerr_over_thres_all', "'1'.b(1)", 1, 0);

this.always(function(){
    mission_fault_int = mission_fault_int_q;
    latent_fault_int = latent_fault_int_q;
    cerr_over_thres_int = cerr_over_thres_int_q   ; 
});
}
module.exports = functional_safety_controller;	    
	
