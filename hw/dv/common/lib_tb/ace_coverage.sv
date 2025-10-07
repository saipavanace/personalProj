
////////////////////////////////////////////////////////////////////////////////
//
// ACE Coverage
//
////////////////////////////////////////////////////////////////////////////////

class ace_coverage ;

    aceState_t start_st;
    aceState_t end_st;
    bit[1:0] rresp;
    bit[1:0] cresp;
    ace_command_types_enum_t cmd_type;

    <%if(obj.fnNativeInterface == "ACE") {%>
    covergroup ace_rd_resp_chnl;
    cp_start_state : coverpoint start_st{
         bins start_st_SC = {ACE_SC};
         bins start_st_UD = {ACE_UD};
         bins start_st_UC = {ACE_UC};
         bins start_st_IX = {ACE_IX};
         bins start_st_SD = {ACE_SD};
    }
    cp_end_state : coverpoint end_st{
         bins end_st_SC = {ACE_SC};
         bins end_st_UD = {ACE_UD};
         bins end_st_UC = {ACE_UC};
         bins end_st_IX = {ACE_IX};
         bins end_st_SD = {ACE_SD};
    }
    cp_isShared_PassDirty : coverpoint rresp{
         bins rresp_00 = {'b00};
         bins rresp_01 = {'b01};
         bins rresp_10 = {'b10};
         bins rresp_11 = {'b11};
    }
    //#Cover.IOAIU.ACE.ReadNoSnoop.RResp
    CX_rdnosnp_CS_NS_rresp_00 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDNOSNP){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00});

         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UC,ACE_SC};
    }
    //#Cover.IOAIU.ACE.ReadOnce.RResp
    CX_rdonce_CS_NS_rresp_00_10 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDONCE){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10});

         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};         
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_SC_end_state = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_SC}  ;
         ignore_bins illegal_SD_end_state = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_SD}  ;
    }
    //#Cover.IOAIU.ACE.ReadClean.RResp
    CX_rdcln_CS_NS_rresp_00_10 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDCLN){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10});

         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_IX_endstate = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_SC_endstate = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_SD_endstate = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_SC};
    }
    //#Cover.IOAIU.ACE.ReadNotSharedDirty.RResp
    CX_rdnotshrddir_CS_NS_rresp_00_01_10 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDNOTSHRDDIR){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_isShared_PassDirty) intersect {'b11}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_isShared_PassDirty) intersect {'b11}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b11});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect { ACE_IX,ACE_UD,ACE_SD};
         ignore_bins illegal_st_IX_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UC,ACE_SC};
         ignore_bins illegal_st_IX_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect {ACE_UC, ACE_UD,ACE_IX,ACE_SD};
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UD,ACE_SD};
         ignore_bins illegal_st_UD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UC,ACE_SC};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_IX,ACE_SD};
         ignore_bins illegal_st_SC_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_UC,ACE_IX,ACE_SC};
         ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_UC, ACE_UD,ACE_IX,ACE_SD};
         ignore_bins illegal_st_SD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_SC,ACE_UC};
         ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_IX,ACE_SC,ACE_UC};

    }
    //#Cover.IOAIU.ACE.ReadShared.RResp
     CX_rdshrd_CS_NS_rresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDSHRD){
         ignore_bins illegal_rresp_st =  (binsof(cp_start_state) intersect {ACE_UC}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_isShared_PassDirty) intersect {'b01,'b11});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_IX_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_IX_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_IX_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect {ACE_SC, ACE_IX,ACE_UD ,ACE_UC};
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_SC_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_UD ,ACE_SD};
         ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_IX,ACE_UD ,ACE_SD,ACE_UC };
         ignore_bins illegal_st_SC_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SD };
         ignore_bins illegal_st_SD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    }
    //#Cover.IOAIU.ACE.ReadUnique.RResp
    CX_rdunq_CS_NS_rresp_00_01 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDUNQ){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b01}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b01}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00});

         ignore_bins illegal_st_IX_00 = binsof(cp_start_state) intersect {ACE_IX} && binsof(cp_isShared_PassDirty) intersect {'b00} &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_IX_01 = binsof(cp_start_state) intersect {ACE_IX} && binsof(cp_isShared_PassDirty) intersect {'b01}  &&  !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UC_00 = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD_00 = binsof(cp_start_state) intersect {ACE_UD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_SC_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};

         ignore_bins illegal_st_SD_00 = binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};

    }
    //#Cover.IOAIU.ACE.CleanUnique.RResp
    CX_clnunq_CS_NS_rresp_00 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == CLNUNQ){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00});

         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};         
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
    }
    //#Cover.IOAIU.ACE.CleanShared.RResp
    CX_clnshrd_CS_NS_rresp_00_10 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == CLNSHRD){
         ignore_bins illegal_rresp_st = (binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10}) || (binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00}) || (binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_isShared_PassDirty) intersect {'b00,'b10});

         ignore_bins illegal_start_st= binsof(cp_start_state) intersect {ACE_UD , ACE_SD};
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};         
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_SC};
    }
    //#Cover.IOAIU.ACE.CleanInvalid.RResp
    CX_clninvl_CS_NS_rresp_00 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == CLNINVL){
         ignore_bins ignore_rresp = !binsof(cp_isShared_PassDirty) intersect {'b00} ;
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_start_st= !binsof(cp_start_state) intersect {ACE_IX};
    }
   //#Cover.IOAIU.ACE.MakeUnique.RResp
    CX_mkunq_CS_NS_rresp_00 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == MKUNQ){
         ignore_bins ignore_rresp = !binsof(cp_isShared_PassDirty) intersect {'b00} ;
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};         
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  && !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
    }
    //#Cover.IOAIU.ACE.MakeInvalid.RResp
    CX_mkinvl_CS_NS_rresp_00 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == MKINVL){
         ignore_bins ignore_rresp = !binsof(cp_isShared_PassDirty) intersect {'b00} ;
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  && !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_start_st= !binsof(cp_start_state) intersect {ACE_IX};
    }
    endgroup
    <% } %>      
    <%if(obj.fnNativeInterface == "ACE") {%>
    covergroup ace_wr_resp_chnl;
    cp_start_state : coverpoint start_st{
         bins start_st_SC = {ACE_SC};
         bins start_st_UD = {ACE_UD};
         bins start_st_UC = {ACE_UC};
         bins start_st_IX = {ACE_IX};
         bins start_st_SD = {ACE_SD};
    }
    cp_end_state : coverpoint end_st{
         bins end_st_SC = {ACE_SC};
         bins end_st_UD = {ACE_UD};
         bins end_st_UC = {ACE_UC};
         bins end_st_IX = {ACE_IX};
         bins end_st_SD = {ACE_SD};
    }
    //#Cover.IOAIU.ACE.WriteNoSnoop.states
    CX_WriteNoSnoop_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WRNOSNP){
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
    }
    //#Cover.IOAIU.ACE.WriteUnique.states
    CX_WriteUnique_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WRUNQ){
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_start_st = binsof(cp_start_state) intersect {ACE_SD,ACE_UD} ;
    }
    //#Cover.IOAIU.ACE.WriteLineUnique.states
    CX_WriteLineUnique_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WRLNUNQ){
         ignore_bins illegal_st_IX = binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC = binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_SC = binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_start_st = binsof(cp_start_state) intersect {ACE_SD,ACE_UD} ;
    }
    //#Cover.IOAIU.ACE.WriteBack.states
    CX_WriteBack_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WRBK){
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_start_st = !binsof(cp_start_state) intersect {ACE_SD,ACE_UD} ;
         //HS 11/13/2023 Talked to EricT about this. If we are getting Partial
         //WriteBacks, it mostly likely implies Master has only Partial
         //Cacheline data left of the full Cacheline. So it is safe to assume
         //that Master would not downgrade to any other state except IX
         //Now if the WRBK was from domain=00(Non-Coherent), then it is possible to
         //downgrade to some other state, but this address should never be
         //reused for any other shareable (Coherent) transactions. Current
         //inhouse ace/axi bfm does not have that capability.
         ignore_bins illegal_end_state = !binsof(cp_end_state) intersect {ACE_IX} ;

    }
    //#Cover.IOAIU.ACE.WriteClean.states
    CX_WriteClean_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WRCLN){
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_SD = binsof(cp_start_state) intersect {ACE_SD}  &&  binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_start_st = !binsof(cp_start_state) intersect {ACE_SD,ACE_UD} ;
    }
    //#Cover.IOAIU.ACE.WriteEvict.states
    CX_WriteEvict_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == WREVCT){
         ignore_bins illegal_st_UD = binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_start_st = !binsof(cp_start_state) intersect {ACE_UC} ;
    }
    //#Cover.IOAIU.ACE.Evict.states
    CX_Evict_CS_NS : cross cp_start_state,cp_end_state iff (cmd_type == EVCT){
         ignore_bins illegal_start_st = !binsof(cp_start_state) intersect {ACE_UC,ACE_SC} ;
         ignore_bins illegal_end_st= !binsof(cp_end_state) intersect {ACE_IX} ;
    }
    endgroup
    <% } %>      
    <%if(obj.fnNativeInterface == "ACE") {%>

    covergroup ace_snoop_resp_chnl ;
     cp_start_state : coverpoint start_st{
         bins start_st_SC = {ACE_SC};
         bins start_st_UD = {ACE_UD};
         bins start_st_UC = {ACE_UC};
         bins start_st_IX = {ACE_IX};
         bins start_st_SD = {ACE_SD};
    }
    cp_end_state : coverpoint end_st{
         bins end_st_SC = {ACE_SC};
         bins end_st_UD = {ACE_UD};
         bins end_st_UC = {ACE_UC};
         bins end_st_IX = {ACE_IX};
         bins end_st_SD = {ACE_SD};
    }
    cp_isShared_PassDirty : coverpoint cresp{
         bins cresp_00 = {'b00};
         bins cresp_01 = {'b01};
         bins cresp_10 = {'b10};
         bins cresp_11 = {'b11};
    }
 //#Cover.IOAIU.ACE.ReadOnce.CResp
    CX_rdonce_CS_NS_cresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDONCE){

         ignore_bins illegal_crres_with_st =( binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11} && binsof(cp_start_state) intersect {ACE_IX}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_UC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_SC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
         ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_UD,ACE_SD};
         ignore_bins illegal_st_UD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
         ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
         ignore_bins illegal_st_SD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SC};

    }
  //#Cover.IOAIU.ACE.ReadClean.CResp
    CX_rdcln_CS_NS_cresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDCLN){

    ignore_bins illegal_crres_with_st =( binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11} && binsof(cp_start_state) intersect {ACE_IX}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_UC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_SC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD});

    ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_UD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_SD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    }
 //#Cover.IOAIU.ACE.ReadShared.CResp
    CX_rdshrd_CS_NS_cresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDSHRD){         

    ignore_bins illegal_crres_with_st =( binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11} && binsof(cp_start_state) intersect {ACE_IX}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_UC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_SC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD});

    ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_UD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_SD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
        
    }

 //#Cover.IOAIU.ACE.ReadNotSharedDirty.CResp
    CX_rdnotshrddir_CS_NS_cresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDNOTSHRDDIR){

    ignore_bins illegal_crres_with_st =( binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11} && binsof(cp_start_state) intersect {ACE_IX}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_UC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_SC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD});

    ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_UD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SD_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SD};
    ignore_bins illegal_st_SD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
       
    }

 //#Cover.IOAIU.ACE.ReadUnique.CResp
    CX_rdunq_CS_NS_cresp_00_01 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == RDUNQ){

    ignore_bins illegal_crres_with_st =( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};          
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX}; 
         ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    }

 //#Cover.IOAIU.ACE.CleanInvalid.CResp
    CX_clninvl_CS_NS_cresp_00_01 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == CLNINVL){

         ignore_bins illegal_crres_with_st =( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};          
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX}; 
         ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};       
    }
  //#Cover.IOAIU.ACE.MakeInvalid.CResp
    CX_mkeinvl_CS_NS_cresp_00_01 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == MKINVL){

         ignore_bins illegal_crres_with_st =( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}) || ( !binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}) || ( !binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD});

         ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};          
         ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX}; 
         ignore_bins illegal_st_UD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
         ignore_bins illegal_st_SD_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX}; 
         ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};        
    }
    //#Cover.IOAIU.ACE.CleanShared.CResp
    CX_clnshrd_CS_NS_cresp_00_01_10_11 : cross cp_start_state,cp_end_state,cp_isShared_PassDirty iff (cmd_type == CLNSHRD){

    ignore_bins illegal_crres_with_st =( binsof(cp_isShared_PassDirty) intersect {'b01,'b10,'b11} && binsof(cp_start_state) intersect {ACE_IX}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_UC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00,'b10} && binsof(cp_start_state) intersect {ACE_UD}) || ( binsof(cp_isShared_PassDirty) intersect {'b01,'b11} && binsof(cp_start_state) intersect {ACE_SC}) || ( binsof(cp_isShared_PassDirty) intersect {'b00,'b10} && binsof(cp_start_state) intersect {ACE_SD});

    ignore_bins illegal_st_IX_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_IX}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_UC}  &&  !binsof(cp_end_state) intersect {ACE_UC,ACE_SC};
    ignore_bins illegal_st_UD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_UD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_UD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    ignore_bins illegal_st_SC_00 = binsof(cp_isShared_PassDirty) intersect {'b00} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SC_10 = binsof(cp_isShared_PassDirty) intersect {'b10} && binsof(cp_start_state) intersect {ACE_SC}  &&  !binsof(cp_end_state) intersect {ACE_SC}; 
    ignore_bins illegal_st_SD_01 = binsof(cp_isShared_PassDirty) intersect {'b01} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_IX};
    ignore_bins illegal_st_SD_11 = binsof(cp_isShared_PassDirty) intersect {'b11} && binsof(cp_start_state) intersect {ACE_SD}  &&  !binsof(cp_end_state) intersect {ACE_SC};
    }

    endgroup
    <% } %>      
function new();
    <%if(obj.fnNativeInterface == "ACE") {%>
    ace_rd_resp_chnl=new();
    ace_wr_resp_chnl=new();
    ace_snoop_resp_chnl=new();
    <% } %>      
endfunction

function void ace_response(ace_command_types_enum_t cmdtype,aceState_t m_start_state,aceState_t m_end_state,bit  isShared,bit PassDirty);
    start_st=m_start_state;
    end_st=m_end_state;
    rresp={isShared,PassDirty};
    cmd_type=cmdtype;
    <%if(obj.fnNativeInterface == "ACE") {%>
    ace_rd_resp_chnl.sample();
    ace_wr_resp_chnl.sample();
    <% } %>      
endfunction
function void ace_snoop_response(ace_command_types_enum_t cmdtype,aceState_t m_start_state,aceState_t m_end_state,bit  isShared,bit PassDirty);
    start_st=m_start_state;
    end_st=m_end_state;
    cmd_type=cmdtype;
    cresp={isShared,PassDirty};
    <%if(obj.fnNativeInterface == "ACE") {%>
    ace_snoop_resp_chnl.sample();
    <% } %>      
endfunction

endclass 

