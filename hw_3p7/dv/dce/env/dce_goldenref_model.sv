////////////////////////////////////////////////////////////////
// DCE Golden Reference Model
// DCE Architecture Spec that Verification Engineer Interprets.
// Author: Hema Sajja
///////////////////////////////////////////////////////////////
typedef enum {UNQ, SHD, DEF} state_e;


class dce_goldenref_model;

    static eMsgSNP cmdreq2owner_snp[eMsgCMD];
    static eMsgSNP cmdreq2sharer_snp[eMsgCMD];
    static eMsgSNP cmdreq2stsh_snp[eMsgCMD];
    static eMsgMRD cmdreq2mrdreq[eMsgCMD][state_e];
    static bit [WSMICMSTATUS - 1:0] snptyp2legl_cmsts[addrMgrConst::interface_t][eMsgSNP][$];
    static bit [WSMICMSTATUS - 1:0] snptyp2legl_cmsts_stshtgt[eMsgSNP][$];
    static bit [WSMICMSTATUS - 1:0] snptyp2legl_cmsts_peer[addrMgrConst::interface_t][eMsgSNP][$];
<%
   var qidx              = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       } else {
         if(obj.AiuInfo[pidx].orderedWriteObservation == 1) {
           qidx++;
         }
       }
   }

%>

<%
   if(qidx > 0)
   {
%>
     static bit orderedWriteObservation = 1;
<%
   }
   else
   {
%>
     static bit orderedWriteObservation = 0;
<%
   }
%>


    static function void build();
        //ConcertoCProtocolArch.pdf: Table 4-20 Mapping of CMDreqs to SNPreqs
        //SNP_CLN_DTW in spec is called SNP_VLD_DTW in verif

        //snps to target AIUs
        cmdreq2stsh_snp[CMD_WR_STSH_FULL]        = eMsgSNP'(SNP_INV_STSH);
        cmdreq2stsh_snp[CMD_WR_STSH_PTL]         = eMsgSNP'(SNP_UNQ_STSH);
        cmdreq2stsh_snp[CMD_LD_CCH_SH]           = eMsgSNP'(SNP_STSH_SH); 
        cmdreq2stsh_snp[CMD_LD_CCH_UNQ]          = eMsgSNP'(SNP_STSH_UNQ); 

        //snps to owners
        cmdreq2owner_snp[CMD_RD_CLN]            = eMsgSNP'(SNP_CLN_DTR);
        cmdreq2owner_snp[CMD_RD_VLD]            = eMsgSNP'(SNP_VLD_DTR); 
        cmdreq2owner_snp[CMD_RD_UNQ]            = eMsgSNP'(SNP_INV_DTR);
        cmdreq2owner_snp[CMD_RD_NOT_SHD]        = eMsgSNP'(SNP_NOSDINT);
        cmdreq2owner_snp[CMD_RD_NITC]           = eMsgSNP'(SNP_NITC);
        cmdreq2owner_snp[CMD_RD_NITC_CLN_INV]   = eMsgSNP'(SNP_NITCCI);
        cmdreq2owner_snp[CMD_RD_NITC_MK_INV]    = eMsgSNP'(SNP_NITCMI);

        cmdreq2owner_snp[CMD_WR_UNQ_FULL]       = eMsgSNP'(SNP_INV);
        cmdreq2owner_snp[CMD_MK_UNQ]            = eMsgSNP'(SNP_INV);
        cmdreq2owner_snp[CMD_MK_INV]            = eMsgSNP'(SNP_INV);

        cmdreq2owner_snp[CMD_CLN_VLD]           = eMsgSNP'(SNP_CLN_DTW);
        cmdreq2owner_snp[CMD_CLN_SH_PER]        = eMsgSNP'(SNP_CLN_DTW);

        cmdreq2owner_snp[CMD_WR_UNQ_PTL]        = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_CLN_INV]           = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_CLN_UNQ]           = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_RD_ATM]            = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_WR_ATM]            = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_SW_ATM]            = eMsgSNP'(SNP_INV_DTW);
        cmdreq2owner_snp[CMD_CMP_ATM]           = eMsgSNP'(SNP_INV_DTW);

        //snps to sharers
        cmdreq2sharer_snp[CMD_RD_UNQ]           = eMsgSNP'(SNP_INV_DTR);
        cmdreq2sharer_snp[CMD_RD_NITC_CLN_INV]  = eMsgSNP'(SNP_NITCCI);
        cmdreq2sharer_snp[CMD_RD_NITC_MK_INV]   = eMsgSNP'(SNP_NITCMI);

        cmdreq2sharer_snp[CMD_WR_UNQ_FULL]      = eMsgSNP'(SNP_INV);
        cmdreq2sharer_snp[CMD_MK_UNQ]           = eMsgSNP'(SNP_INV);
        cmdreq2sharer_snp[CMD_MK_INV]           = eMsgSNP'(SNP_INV);
        
        cmdreq2sharer_snp[CMD_WR_UNQ_PTL]       = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_CLN_INV]          = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_CLN_UNQ]          = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_RD_ATM]           = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_WR_ATM]           = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_SW_ATM]           = eMsgSNP'(SNP_INV_DTW);
        cmdreq2sharer_snp[CMD_CMP_ATM]          = eMsgSNP'(SNP_INV_DTW);

        //Refer to Jira Bug-4434
        $cast(cmdreq2mrdreq[CMD_RD_CLN][UNQ]          , eMsgMRD'(MRD_RD_WITH_UNQ_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_CLN][SHD]          , eMsgMRD'(MRD_RD_WITH_SHR_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_VLD][UNQ]          , eMsgMRD'(MRD_RD_WITH_UNQ_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_VLD][SHD]          , eMsgMRD'(MRD_RD_WITH_SHR_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_UNQ][DEF]          , eMsgMRD'(MRD_RD_WITH_UNQ));
        $cast(cmdreq2mrdreq[CMD_RD_NOT_SHD][UNQ]      , eMsgMRD'(MRD_RD_WITH_UNQ_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_NOT_SHD][SHD]      , eMsgMRD'(MRD_RD_WITH_SHR_CLN));
        $cast(cmdreq2mrdreq[CMD_RD_NITC][DEF]         , eMsgMRD'(MRD_RD_WITH_INV));
        $cast(cmdreq2mrdreq[CMD_RD_NITC_CLN_INV][DEF] , eMsgMRD'(MRD_RD_WITH_INV));
        $cast(cmdreq2mrdreq[CMD_RD_NITC_MK_INV][DEF]  , eMsgMRD'(MRD_RD_WITH_INV));

        //cleaning cmds
        $cast(cmdreq2mrdreq[CMD_CLN_SH_PER][DEF]      , eMsgMRD'(MRD_CLN));
        $cast(cmdreq2mrdreq[CMD_CLN_VLD][DEF]         , eMsgMRD'(MRD_CLN));

        //invalidate cmds 
        $cast(cmdreq2mrdreq[CMD_CLN_INV][DEF]         , eMsgMRD'(MRD_FLUSH));
       
        $cast(cmdreq2mrdreq[CMD_MK_INV][DEF]          , eMsgMRD'(MRD_INV));

        //stash reads 
        $cast(cmdreq2mrdreq[CMD_LD_CCH_SH][UNQ]       , eMsgMRD'(MRD_RD_WITH_UNQ_CLN)); 
        $cast(cmdreq2mrdreq[CMD_LD_CCH_SH][SHD]       , eMsgMRD'(MRD_RD_WITH_SHR_CLN)); 
        $cast(cmdreq2mrdreq[CMD_LD_CCH_SH][DEF]       , eMsgMRD'(MRD_PREF)); 

        $cast(cmdreq2mrdreq[CMD_LD_CCH_UNQ][UNQ]      , eMsgMRD'(MRD_RD_WITH_UNQ_CLN)); 
        $cast(cmdreq2mrdreq[CMD_LD_CCH_UNQ][DEF]      , eMsgMRD'(MRD_PREF)); 

        // Snooptype in snpreq to all legal cmstatus in snpres mapping
		
		//=================== ReadClean =====================================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b001110); //SnpRespData_I_PD(UP=1) (UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b001110); //SnpRespData_I_PD(UP=1) (UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b001110); //SnpRespData_I_PD(UP=1) (UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX) Dtr-SCln
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b001110); //SnpRespData_I_PD(UP=1) (UD->IX) Dtr-UCln
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTR ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTR ].push_back(6'b110000); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTR ].push_back(6'b100100); //SD,UD->SD
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTR ].push_back(6'b110100); //UC->SC
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_CLN_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_CLN_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_CLN_DTR ].push_back(6'b000000);
	end

        //====================================================================================

		//=================== ReadValid =====================================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=0,1) (SD,UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b111100); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_VLD_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=0,1) (SD,UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b111100); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_VLD_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=0,1) (SD,UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b111100); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_VLD_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=0,1) (SD,UD->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b111100); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_VLD_DTR ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_VLD_DTR ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_VLD_DTR ].push_back(6'b110000); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_VLD_DTR ].push_back(6'b100100); //SD,UD->SD Need to remove this
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_VLD_DTR ].push_back(6'b110100); //UC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_VLD_DTR ].push_back(6'b111100); //UC,UD,SD->SC
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_VLD_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_VLD_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_VLD_DTR ].push_back(6'b000000);
	end
        //====================================================================================

		//=================== ReadNotSharedDirty =============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=1) (UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NOSDINT ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
	    snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=1) (UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NOSDINT ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)
        
	    snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b000110); //SnpRespData_I_PD(UP=0) (SD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b001100); //SnpRespData_I(UC->IX), SnpRespData_I_PD(UP=1) (UD->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b001110); //SnpRespDataPtl_I_PD (UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NOSDINT ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)

        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b000000); //SnpResp_I (SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b000100); //SnpRespData_I(UP=1) (UC,UD->IX) Dtr-SCln
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b001100); //SnpRespData_I Dtr-UCln
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b000110); //SnpRespData_I_PD Dtr-SCln+Dtw-FDty
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NOSDINT ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NOSDINT ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NOSDINT ].push_back(6'b110000); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NOSDINT ].push_back(6'b100100); //SD,UD->SD
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NOSDINT ].push_back(6'b110100); //UC->SC
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_NOSDINT ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_NOSDINT ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_NOSDINT ].push_back(6'b000000);
	end
        //====================================================================================

		//=================== ReadNITC =============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b000000); //SnpResp_I(SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b000100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b000110); //SnpRespData_I_PD(UD,SD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b100000); //SnpResp_UC(UC->UC, UCE->UCE)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD), SnpRespData_UD(UD->UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITC    ].push_back(6'b100110); //SnpRespDataPtl_UD(UDP->UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b000000); //SnpResp_I(SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b000100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b000110); //SnpRespData_I_PD(UD,SD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b100000); //SnpResp_UC(UC->UC, UCE->UCE)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD), SnpRespData_UD(UD->UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITC    ].push_back(6'b100110); //SnpRespDataPtl_UD(UDP->UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b000000); //SnpResp_I(SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b000100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b000110); //SnpRespData_I_PD(UD,SD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b110100); //SnpRespData_SC(UC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b100000); //SnpResp_UC(UC->UC, UCE->UCE)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD), SnpRespData_UD(UD->UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITC    ].push_back(6'b100110); //SnpRespDataPtl_UD(UDP->UDP)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b000000); //SnpResp_I(SC,UCE,UC,IX->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b000100); //SnpRespData_I(UC->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b000110); //SnpRespData_I_PD(UD,SD->IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b110110); //SnpRespData_SC_PD(UD,SD->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b100000); //SnpResp_UC(UC->UC, UCE->UCE)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITC    ].push_back(6'b100100); //SnpRespData_SD(UD,SD->SD), SnpRespData_UD(UD->UD)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITC    ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITC    ].push_back(6'b110000); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITC    ].push_back(6'b110100); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITC    ].push_back(6'b100100); //UC->UC,UD->UD,SD->SD
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_NITC ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_NITC ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_NITC ].push_back(6'b000000);
	end
        
        //========================================================================================

		//=================== ReadUnique =============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTR ].push_back(6'b000000); //SnpResp_I (UC,UCE,SC,IX -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTR ].push_back(6'b001100); //SnpRspData_I, SnpRspData_I_PD (SD,UC,UD -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTR ].push_back(6'b001110); //SnpRspDataPtl_I_PD (UDP -> IX)
	    snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTR ].push_back(6'b000010);

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTR ].push_back(6'b000000); //SnpResp_I (UC,UCE,SC,IX -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTR ].push_back(6'b001100); //SnpRspData_I, SnpRspData_I_PD (SD,UC,UD -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTR ].push_back(6'b001110); //SnpRspDataPtl_I_PD (UDP -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTR ].push_back(6'b000010);

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTR ].push_back(6'b000000); //SnpResp_I (UC,UCE,SC,IX -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTR ].push_back(6'b001100); //SnpRspData_I, SnpRspData_I_PD (SD,UC,UD -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTR ].push_back(6'b001110); //SnpRspDataPtl_I_PD (UDP -> IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTR ].push_back(6'b000010);

        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV_DTR ].push_back(6'b000000); //SnpResp_I (UC,SC,IX -> IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV_DTR ].push_back(6'b001100); //SnpRspData_I, SnpRspData_I_PD (SD,UC,UD -> IX)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV_DTR ].push_back(6'b000010);

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV_DTR ].push_back(6'b000000); //SC,IX -> IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV_DTR ].push_back(6'b001100); //SD,UC,UD -> IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV_DTR ].push_back(6'b000010);
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_INV_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_INV_DTR ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_INV_DTR ].push_back(6'b000000);
	end
		//***************Not possible from proxyCache and ACE snooper******************************//
        //========================================================================================

		//=================== CleanValid, CleanShPer =============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b000000); //SnpResp_I (IX,UC,UCE,SC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b000010); //SnpRespData_I_PD(SD,UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b100000); //SnpResp_UC(UC->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b100010); //SnpRespData_UC_PD(UD->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_CLN_DTW ].push_back(6'b110010); //SnpRespData_SC_PD(UD,SD->SC)

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b000000); //SnpResp_I (IX,UC,UCE,SC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b000010); //SnpRespData_I_PD(SD,UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b100000); //SnpResp_UC(UC->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b100010); //SnpRespData_UC_PD(UD->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_CLN_DTW ].push_back(6'b110010); //SnpRespData_SC_PD(UD,SD->SC)

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b000000); //SnpResp_I (IX,UC,UCE,SC->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b000010); //SnpRespData_I_PD(SD,UD->IX), SnpRespDataPtl_I_PD(UDP->IX)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b100000); //SnpResp_UC(UC->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b100010); //SnpRespData_UC_PD(UD->UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b110000); //SnpResp_SC(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_CLN_DTW ].push_back(6'b110010); //SnpRespData_SC_PD(UD,SD->SC)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTW ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTW ].push_back(6'b000010); //SD,UD->IX
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTW ].push_back(6'b100000); //(UC,UD->UC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTW ].push_back(6'b110000); //(UC,SC->SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_CLN_DTW ].push_back(6'b110010); //(UD,SD->SC)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTW ].push_back(6'b000000); //IX->IX
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTW ].push_back(6'b100000); //UC->UC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTW ].push_back(6'b100010); //UD->UC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTW ].push_back(6'b110000); //SC->SC
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_CLN_DTW ].push_back(6'b110010); //SD->SC
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_CLN_DTW ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_CLN_DTW ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_CLN_DTW ].push_back(6'b000000);
	end
        //========================================================================================

		//=================== Atomics, ClnUnique, ClnInvalid, WrUnqPtl ==================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTW ].push_back(6'b000010);
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV_DTW ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTW ].push_back(6'b000010);
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV_DTW ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTW ].push_back(6'b000010);
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV_DTW ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV_DTW ].push_back(6'b000010);
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV_DTW ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV_DTW ].push_back(6'b000010);
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV_DTW ].push_back(6'b000000);

        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_INV_DTW ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_INV_DTW ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_INV_DTW ].push_back(6'b000000);
	end
        //===============================================================================

		//=================== MkUnique, MkInvalid, WrUnqFull ============================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_INV     ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_INV     ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_INV     ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_INV     ].push_back(6'b000000);

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_INV     ].push_back(6'b000000);
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_INV ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_INV ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_INV ].push_back(6'b000000);
	end
        //===============================================================================

		//=================== RdNITCClnInv ===============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCCI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCCI  ].push_back(6'b000100); //SnpRespData_I (UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCCI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD), SnpRespDataPtl_I_PD(UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCCI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCCI  ].push_back(6'b000100); //SnpRespData_I (UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCCI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD), SnpRespDataPtl_I_PD(UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCCI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCCI  ].push_back(6'b000100); //SnpRespData_I (UC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCCI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD), SnpRespDataPtl_I_PD(UDP)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITCCI  ].push_back(6'b000000); //SnpResp_I(IX, UC, SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITCCI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITCCI  ].push_back(6'b000000); //SnpResp_I(IX, SC)
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITCCI  ].push_back(6'b000100); //SnpRespData_I (UC)
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITCCI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD)
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_NITCCI ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_NITCCI ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_NITCCI ].push_back(6'b000000);
	end
        //===============================================================================

		//=================== RdNITCMkInv ===============================================
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCMI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCMI  ].push_back(6'b000100); //SnpRespData_I (UC), SnpRespData_I_PD(SD, UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_A_AIU   ][SNP_NITCMI  ].push_back(6'b000110); //SnpRespDataPtl_I_PD(UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCMI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCMI  ].push_back(6'b000100); //SnpRespData_I (UC), SnpRespData_I_PD(SD, UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_B_AIU   ][SNP_NITCMI  ].push_back(6'b000110); //SnpRespDataPtl_I_PD(UDP)

        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCMI  ].push_back(6'b000000); //SnpResp_I(IX, UC, UCE, SC)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCMI  ].push_back(6'b000100); //SnpRespData_I (UC), SnpRespData_I_PD(SD, UD)
        snptyp2legl_cmsts[addrMgrConst::CHI_E_AIU   ][SNP_NITCMI  ].push_back(6'b000110); //SnpRespDataPtl_I_PD(UDP)
        
	    snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITCMI  ].push_back(6'b000000); //SnpResp_I(IX, UC, SC)
        snptyp2legl_cmsts[addrMgrConst::ACE_AIU     ][SNP_NITCMI  ].push_back(6'b000110); //SnpRespData_I_PD(SD, UD)

        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITCMI  ].push_back(6'b000000); //SnpResp_I(IX, SC)
        snptyp2legl_cmsts[addrMgrConst::IO_CACHE_AIU][SNP_NITCMI  ].push_back(6'b000100); //SnpRespData_I (UC)
	//SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts[addrMgrConst::AXI_AIU     ][SNP_NITCMI ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_AIU][SNP_NITCMI ].push_back(6'b000000);
          snptyp2legl_cmsts[addrMgrConst::ACE_LITE_E_AIU][SNP_NITCMI ].push_back(6'b000000);
	end
        //===============================================================================

		//============================ StashOnceShared ===============================
		//snp_rsp from stash target
        snptyp2legl_cmsts_stshtgt[SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_stshtgt[SNP_STSH_SH ].push_back(6'b000001); //SnpResp_I_Read
        snptyp2legl_cmsts_stshtgt[SNP_STSH_SH ].push_back(6'b110000); //SnpResp_SC
        snptyp2legl_cmsts_stshtgt[SNP_STSH_SH ].push_back(6'b100000); //SnpResp_UD, SnpResp_SD
        snptyp2legl_cmsts_stshtgt[SNP_STSH_SH ].push_back(6'b100001); //SnpResp_UC_Read

		//snp_rsp from peer
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_SH ].push_back(6'b000010); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_SH ].push_back(6'b110000); //SnpResp_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_SH ].push_back(6'b110010); //SnpRespData_SC_PD, SnpRespData_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_SH ].push_back(6'b100010); //SnpRespData_SD

        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_SH ].push_back(6'b000010); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_SH ].push_back(6'b110000); //SnpResp_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_SH ].push_back(6'b110010); //SnpRespData_SC_PD, SnpRespData_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_SH ].push_back(6'b100010); //SnpRespData_SD

        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_SH ].push_back(6'b000010); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_SH ].push_back(6'b110000); //SnpResp_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_SH ].push_back(6'b110010); //SnpRespData_SC_PD, SnpRespData_SC
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_SH ].push_back(6'b100010); //SnpRespData_SD
        
	    snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_STSH_SH ].push_back(6'b000010); //SnpRespData_I, SnpRespData_I_PD, SnpRespDataPtl_I_PD
        
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_STSH_SH ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_STSH_SH ].push_back(6'b110000); //SnpResp_SC
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_STSH_SH ].push_back(6'b100010); //SnpRespData_SD

        if(orderedWriteObservation == 1'b1) begin
          snptyp2legl_cmsts_peer[addrMgrConst::AXI_AIU     ][SNP_STSH_SH].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_AIU][SNP_STSH_SH].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_E_AIU][SNP_STSH_SH].push_back(6'b000000);
        end
        //==========================================================================

		//============================ StashOnceUnique ===============================
		//snp_rsp from stash target
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b000000);
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b000001);
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b100000);
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b100001);
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b110000);
        snptyp2legl_cmsts_stshtgt[SNP_STSH_UNQ].push_back(6'b110001);

        //snp_rsp from peer
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_UNQ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_STSH_UNQ].push_back(6'b000010); //SnpRespData_I_PD
        
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_UNQ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_STSH_UNQ].push_back(6'b000010); //SnpRespData_I_PD
        
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_UNQ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_STSH_UNQ].push_back(6'b000010); //SnpRespData_I_PD
        
	    snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_STSH_UNQ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_STSH_UNQ].push_back(6'b000010); //SnpRespData_I_PD
        
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_STSH_UNQ].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_STSH_UNQ].push_back(6'b000010); //SnpRespData_I

        if(orderedWriteObservation == 1'b1) begin
          snptyp2legl_cmsts_peer[addrMgrConst::AXI_AIU     ][SNP_STSH_UNQ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_AIU][SNP_STSH_UNQ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_E_AIU][SNP_STSH_UNQ].push_back(6'b000000);
        end
        //==========================================================================


		//============================ WriteStashFull ================================
		//snp_rsp from stash target
        snptyp2legl_cmsts_stshtgt[SNP_INV_STSH].push_back(6'b000001);
        snptyp2legl_cmsts_stshtgt[SNP_INV_STSH].push_back(6'b000000);
        
        //snp_rsp from peer
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_INV_STSH].push_back(6'b000000); 
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_INV_STSH].push_back(6'b000000); 
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_INV_STSH].push_back(6'b000000); 
        snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_INV_STSH].push_back(6'b000000); 
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_INV_STSH].push_back(6'b000000); 
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts_peer[addrMgrConst::AXI_AIU     ][SNP_INV_STSH ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_AIU][SNP_INV_STSH ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_E_AIU][SNP_INV_STSH ].push_back(6'b000000);
	end
        //===========================================================================

		//============================ WriteStashPtl ================================
		//snp_rsp from stash target
        snptyp2legl_cmsts_stshtgt[SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_stshtgt[SNP_UNQ_STSH].push_back(6'b000001); //SnpResp_I_Read
        snptyp2legl_cmsts_stshtgt[SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        snptyp2legl_cmsts_stshtgt[SNP_UNQ_STSH].push_back(6'b000011); //SnpRespData_I_Read

        //snp_rsp from peer
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_A_AIU   ][SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_B_AIU   ][SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::CHI_E_AIU   ][SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        
	    snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::ACE_AIU     ][SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_UNQ_STSH].push_back(6'b000000); //SnpResp_I
        snptyp2legl_cmsts_peer[addrMgrConst::IO_CACHE_AIU][SNP_UNQ_STSH].push_back(6'b000010); //SnpRespData_I
        //SANJEEV: OWO Support For Ncore 3.7
	if(orderedWriteObservation == 1'b1)
	begin
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_AIU][SNP_UNQ_STSH ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::ACE_LITE_E_AIU][SNP_UNQ_STSH ].push_back(6'b000000);
          snptyp2legl_cmsts_peer[addrMgrConst::AXI_AIU     ][SNP_UNQ_STSH ].push_back(6'b000000);
	end
        //===========================================================================

    endfunction: build

    static function bit is_nonstash_write(eMsgCMD cmd);
        if (cmd inside { CMD_WR_UNQ_PTL,
                         CMD_WR_UNQ_FULL,
                         CMD_WR_CLN_PTL,
                         CMD_WR_CLN_FULL,
                         CMD_WR_BK_PTL,
                         CMD_WR_BK_FULL,
                         CMD_WR_EVICT}) return 1;
        else return 0;
    endfunction
    
    static function bit is_stash_request(eMsgCMD cmd);
        if (cmd inside { CMD_WR_STSH_PTL,
                         CMD_WR_STSH_FULL,
                         CMD_LD_CCH_SH,
                         CMD_LD_CCH_UNQ}) return 1;
        else return 0;
    endfunction
    
    static function bit is_stash_write(eMsgCMD cmd);
        if (cmd inside { CMD_WR_STSH_PTL,
                         CMD_WR_STSH_FULL}) return 1;
        else return 0;
    endfunction
    
    static function bit is_stash_read(eMsgCMD cmd);
        if (cmd inside { CMD_LD_CCH_SH,
                         CMD_LD_CCH_UNQ}) return 1;
        else return 0;
    endfunction
    
    static function bit is_read(eMsgCMD cmd);
        if (cmd inside {CMD_RD_VLD,
                        CMD_RD_CLN,
                        CMD_RD_UNQ,
                        CMD_RD_NOT_SHD,
                        CMD_RD_NITC,
                        CMD_RD_NITC_CLN_INV,
                        CMD_RD_NITC_MK_INV}) return 1;
        else return 0;
    endfunction
    
    static function bit is_clean(eMsgCMD cmd);
        if (cmd inside {CMD_CLN_VLD,
                        CMD_CLN_SH_PER,
                        CMD_CLN_UNQ,
                        CMD_CLN_INV}) return 1;
        else return 0;
    endfunction
    
    static function bit is_atomic(eMsgCMD cmd);
        if (cmd inside {CMD_RD_ATM,
                        CMD_WR_ATM,
                        CMD_SW_ATM,
                        CMD_CMP_ATM}) return 1;
        else return 0;
    endfunction
    
    static function bit is_master_allocating_req(eMsgCMD cmd);
        if (cmd inside {CMD_RD_VLD,
                        CMD_RD_CLN,
                        CMD_RD_UNQ,
                        CMD_RD_NOT_SHD,
                        CMD_CLN_UNQ,
                        CMD_MK_UNQ}) return 1;
        else return 0;
    endfunction

endclass: dce_goldenref_model
