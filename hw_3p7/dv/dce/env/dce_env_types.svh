//
//DCE env Package Typedefs
//

<% 

var attvec_width = 0;

obj.DceInfo.forEach(function(bundle) {
    if (bundle.nAttCtrlEntries > attvec_width) {
        attvec_width = bundle.nAttCtrlEntries;
    }
});
%> 
parameter WATTVEC  = <%=attvec_width%>;

typedef bit [WATTVEC - 1 : 0] attvec_width_t;

typedef enum int {

	EXLD_NOMATCH_TMADDR_OTHER_TM_NOT_AVAILABLE,
	EXLD_NOMATCH_TMADDR_OTHER_TM_AVAILABLE,
	EXLD_MATCH_TMADDR,
 	
 	EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_NOT_AVAILABLE,
 	EXST_NOMATCH_TMADDR_NO_BMVLD_OTHER_TM_AVAILABLE,
 	EXST_NOMATCH_TMADDR_BMVLD,
 	EXST_MATCH_TMADDR_NO_TMVLD,
 	EXST_MATCH_TMADDR_TMVLD,

    NONEX_SNP_INV_CLEAR,
    NONEX_SNP_INV_FAIL
} exmon_state_e;

typedef enum int {
	RB_RSV,
	RB_RLS,
	RB_USE
} req_type_e;
