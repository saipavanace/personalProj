`ifndef DMI_CCP_RAL_GEN_SEQ_SV
`define DMI_CCP_RAL_GEN_SEQ_SV
import apb_agent_pkg::*;
class cmiu_ccp_ral_gen_base_seq extends uvm_reg_sequence;
    `uvm_object_utils(cmiu_ccp_ral_gen_base_seq)

    uvm_reg_data_t         rd_data,wr_data;
    uvm_reg_data_t         data;
    concerto_register_map  m_regs;
    uvm_status_e           status;
    uvm_reg_data_t         field_rd_data;

    string fnerrdetectcorrect = "<%=obj.fnErrDetectCorrect%>";

    rand bit [19:0] cpy_nSets;
    rand bit [5:0]  cpy_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0]  rand_wr_data;

    function new(string name="cmiu_ccp_ral_gen_base_seq");
        super.new(name);
    endfunction
    
    task pre_body();
        $cast(m_regs,model);
    endtask
endclass : cmiu_ccp_ral_gen_base_seq 

//-----------------------------------------------------------------------
/**
 * Abstract:
 * 
 * In the build phase of the test we will set the necessary test related
 * steps as below
 *  -PMSW performs the following steps to complete the transition to offline state:
 *  1. Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
 *  2. Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
 *     until clear
 *  3. Initiate and complete a Proxy Cache Flush operation (Proxy Cache Maintenance Control 
 *     Register and Proxy Cache Maintenance Activity Register).
 *  4. Poll the Proxy Cache Evict Active bit (Proxy Cache Transaction Activity Register) until clear
 *  5. Clear the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
 *     the main phase of the Master agent's dataflow Sequencer
 *  .
 */
//----------------------------------------------------------------------------

class cmiu_ccp_offline_seq extends cmiu_ccp_ral_gen_base_seq;
  `uvm_object_utils(cmiu_ccp_offline_seq)

    function new(string name="cmiu_ccp_offline_seq");
        super.new(name);
    endfunction
  
    virtual task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        // ************************************************************************************
        //  1. Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
        // ************************************************************************************
        wr_data = 0;
        m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
        m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));
        // ************************************************************************************
        //  2. Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
        //    until clear
        // ************************************************************************************
        do
        begin
            data = 0;
            m_regs.cmiu.CMIUCMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        // ************************************************************************************
        //  3. Initiate and complete a Proxy Cache Flush operation (Proxy Cache Maintenance Control 
        //    Register and Proxy Cache Maintenance Activity Register).
        //    a. write the "CMIUCMCMCR_CmcMntOp" field with 0. This will flush the entire tag array
        // ************************************************************************************
         wr_data = 4;
         m_regs.cmiu.CMIUCMCMCR.CmcMntOp.set(wr_data);
         m_regs.cmiu.CMIUCMCMCR.update(status,.path(UVM_FRONTDOOR), .parent(this));


        // ************************************************************************************
        //  c.Poll the "CMIUCMCMAR" register till the field "MntOpActv" becomes 0. 
        // ************************************************************************************
        do
        begin
            data = 0;
            m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);


        // ************************************************************************************
        //  4. Poll the Proxy Cache Evict Active bit (Proxy Cache Transaction Activity Register) 
        //    until clear
        // ************************************************************************************
        do
        begin
            data = 0;
            m_regs.cmiu.CMIUCMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        // ************************************************************************************
        // 5. Clear the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
        //    the main phase of the Master agent's dataflow Sequencer
        // ************************************************************************************
         wr_data = 0;
         m_regs.cmiu.CMIUCMCTCR.LookupEn.set(wr_data);
         m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));


    `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask: body
endclass : cmiu_ccp_offline_seq 

//-----------------------------------------------------------------------
/**
*  * Abstract:
*  * 
*  For block level IO cache. The steps to bring IO cache online are as follows. 
* 
* 1.	If a proxy cache reset has been performed, initiate and complete a Proxy 
*       Cache Initialization operation (Proxy Cache Maintenance Control Register 
*       and Proxy Cache Maintenance Activity Register)
*       a.write the "CMIUCMCMCR" register field "CmcMntOp" field with 0. 
*         This will flush the entire tag array. 
*       b.write the "CMIUCMCMCR" register field "CmcMntOp" field with 0 
*         and PcArrId field as "1". This will flush the data memory. 
*       c.Poll the "CMIUCMCTAR" register till the field "MntOpActv" becomes 0. 
* 2.	Set the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
* 3.	Set the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
* 
 */
//----------------------------------------------------------------------------

class cmiu_ccp_online_seq extends cmiu_ccp_ral_gen_base_seq;
    `uvm_object_utils(cmiu_ccp_online_seq)

   // int dont_enable_correctible_interrupt = 0;
   // int dont_enable_correctible_error_detection = 0;
   // int dont_enable_uncorrectible_interrupt = 0;
   // int dont_enable_uncorrectible_error_detection = 0;
    
    function new(string name="cmiu_ccp_online_seq");
        super.new(name);
    endfunction
    
    virtual task body();

        `uvm_info("body", "Entered...", UVM_MEDIUM)
// ************************************************************************************
//  1. Initiate and complete a Proxy Cache Flush operation (Proxy Cache Maintenance Control 
//    Register and Proxy Cache Maintenance Activity Register).
//    a. write the "CMIUCMCMCR_CmcMntOp" field with 0. This will flush the entire tag array
// ************************************************************************************
     wr_data = 0;

     m_regs.cmiu.CMIUCMCMCR.write(status, wr_data, .parent(this));


// ************************************************************************************
//  c.Poll the "CMIUCMCMAR" register till the field "MntOpActv" becomes 0. 
// ************************************************************************************
    do
    begin
        data = 0;
        m_regs.cmiu.CMIUCMCMAR.read( status, field_rd_data,.parent(this));
    end while(field_rd_data != data);
// ************************************************************************************
//  2.	Set the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
// ************************************************************************************
     wr_data = 1;
     m_regs.cmiu.CMIUCMCTCR.LookupEn.set(wr_data);
     m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));
// ************************************************************************************
//  3.	Set the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
// ************************************************************************************


     wr_data = 1;
     m_regs.cmiu.CMIUCMCTCR.FillEn.set( wr_data);
     m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));


    //Enable the Interrupts

    //if (dont_enable_correctible_interrupt == 0)
    //  m_regs.cmiu.CMIUCECR.ErrIntEn.set(1'b1);
     
    //if (dont_enable_correctible_error_detection == 0)
    //  m_regs.cmiu.CMIUCECR.ErrDetEn.set(1'b1);

    //if (dont_enable_uncorrectible_interrupt == 0)
    //  m_regs.cmiu.CMIUUECR.ErrIntEn.set(1'b1);

    //if (dont_enable_uncorrectible_error_detection == 0)
    //  m_regs.cmiu.CMIUUECR.ErrDetEn.set(1'b1);

    m_regs.cmiu.CMIUCECR.update(status, .path(UVM_FRONTDOOR), .parent(this));
    m_regs.cmiu.CMIUUECR.update(status, .path(UVM_FRONTDOOR), .parent(this));

  `uvm_info("body", "Exiting...", UVM_MEDIUM)
endtask: body

endclass : cmiu_ccp_online_seq 


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_flush_per_index_way_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_flush_per_index_way_seq)

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0]  rand_wr_data;

    int k_num_flush_cmd=500;
   <% if(obj.isBridgeInterface && obj.useIoCache) { %>  

<% if (obj.useCmc) { %>
    <% if (obj.DmiInfo[0].ccpParams.nSets>1){ %>
    constraint c_nSets  { m_nSets  < <%=obj.DmiInfo[0].ccpParams.nSets%>;}
    <%}%>
<%}%>
    
<% if (obj.useCmc) { %>
    <% if (obj.DmiInfo[0].ccpParams.nWays>1){ %>
    constraint c_nWays  { m_nWays  < <%=obj.DmiInfo[0].ccpParams.nWays%>;}  
    <%}%> 
    <%}%>
<%}%>

    function new(string name="");
        super.new(name);
    endfunction
  
    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)

        repeat(k_num_flush_cmd) begin
            #(1us);
<% if (obj.useCmc) { %>
                <% if (obj.DmiInfo[0].ccpParams.nSets>1){ %>
                    assert(randomize(m_nSets))
                <%}else{%>
                    m_nSets = 0;
                <%}%>
<%}%>


<% if (obj.useCmc) { %>
                <% if (obj.DmiInfo[0].ccpParams.nWays>1){ %>
                    assert(randomize(m_nWays))
                <%}else{%>
                    m_nWays = 0;
                <%}%>
<%}%>

                `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_MEDIUM)

                //**********************************************************************************
                //  	Program the CMIUCMCMLR0 to read a random index/way. 
                //  
                //**********************************************************************************

                 wr_data = {6'h0,m_nWays,m_nSets};
                 m_regs.cmiu.CMIUCMCMLR0.write(status, wr_data, .parent(this));

                //**********************************************************************************
                // If the state is not IX flush that particular index/way   
                // Perform a MntOp operation CMIUCMCMCR register with flush index/way 
                //**********************************************************************************

                 wr_data = 5;
                 m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));

                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);
        end

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask
endclass : cmiu_ccp_flush_per_index_way_seq


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------

class cmiu_ccp_flush_by_addr_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_flush_by_addr_seq)

  //  dmi_scoreboard cpy_ioCacheModel;
    bit security;
    bit [WAXADDR - SYS_wSysCacheline] m_addr_size; 
    axi_axaddr_t  m_addr; 
    Addr_t    cache_addr_list [$];
    bit flag;
    int offset = SYS_wSysCacheline;

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0] rand_wr_data;
    int             addrcnt;
<% if (obj.useCmc) { %>
    int k_num_flush_cmd = <%=obj.DmiInfo[0].ccpParams.nSets%>*<%=obj.DmiInfo[0].ccpParams.nWays%>-2;
<% } else { %>
    int k_num_flush_cmd = 500;
<%} %>

    int m_tmp_q[$];

<% if (obj.useCmc) { %>
    <% if (obj.DmiInfo[0].ccpParams.nSets>1){ %>
    constraint c_nSets  { m_nSets  < <%=obj.DmiInfo[0].ccpParams.nSets%>;}
    <%}%>
<%}%>
    
<% if (obj.useCmc) { %>
    <% if (obj.DmiInfo[0].ccpParams.nWays>1){ %>
    constraint c_nWays  { m_nWays  < <%=obj.DmiInfo[0].ccpParams.nWays%>;}  
    <%}%> 
 <%}%>

    function new(string name="");
        super.new(name);
        addrcnt =0;
    endfunction

    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)
             k_num_flush_cmd = cache_addr_list.size();
            repeat(k_num_flush_cmd) begin
                #(1us);
<% if (obj.useCmc) { %>
                <% if (obj.DmiInfo[0].ccpParams.nSets>1){ %>
                    assert(randomize(m_nSets))
                <%}else{%>
                    m_nSets = 0;
                <%}%>
<%}%>

<% if (obj.useCmc) { %>
                <% if (obj.DmiInfo[0].ccpParams.nWays>1){ %>
                    assert(randomize(m_nWays))
                <%}else{%>
                    m_nWays = 0;
                <%}%>
<%}%>
                `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  mway :%x ",m_nSets,m_nWays), UVM_MEDIUM)
                m_addr = 0;


                if(cache_addr_list.size()==0) begin
                    `uvm_error("CMC-$-SEQ",$sformatf("Addr queue for Cmc is empty"))
                end

                if(cache_addr_list.size()>0) begin
                    m_addr = cache_addr_list[addrcnt].addr; 
                    <% if (obj.wSecurityAttribute > 0) { %>
                    security = cache_addr_list[addrcnt].req_security; 
                    <%}%>
                    `uvm_info("CMC-$-SEQ",$sformatf("Hurray Got Addr :%x from IO cache model",m_addr), UVM_MEDIUM)
                end
                if($size(m_addr_size) > 32) begin
                    //Program the ML0 Entry for Addr
                    wr_data   = m_addr >> offset;
                    m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data,.parent(this));
                    `uvm_info("CMC-$-SEQ",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)


                    //Program the ML1 Entry for Addr
                    wr_data   = m_addr >> offset;
                    wr_data   = wr_data >> 'h20;
                    m_regs.cmiu.CMIUCMCMLR1.write(status,wr_data,.parent(this));
                    `uvm_info("CMC-$-SEQ",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

                    //Program the MntOp Register with Opcode-6
                     wr_data   = {10'h0,security,21'h6};
                     m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));
                    
                    `uvm_info("CMC-$-SEQ",$sformatf("Found the Addr size to be greater than 32 Size:%0d",m_addr_size), UVM_MEDIUM)

                end else begin
                    //Program the ML0 Entry for Addr
                    wr_data   = m_addr >> offset;
                    m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data,.parent(this));
                    `uvm_info("CMC-$-SEQ",$sformatf("Sending Addr :%x from IO cache model",wr_data), UVM_MEDIUM)

                    //Program the MntOp Register with Opcode-6
                     wr_data   = {10'h0,security,21'h6};
                     m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));
                end

                //Poll the MntOp Active Bit
                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);
              addrcnt++;
            end
      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask      
endclass : cmiu_ccp_flush_by_addr_seq



//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------

class cmiu_ccp_dis_lookup_en_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_dis_lookup_en_seq)

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)

        // ************************************************************************************
        //  1. Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
        // ************************************************************************************
        wr_data = 0;
        m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
        m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));
        // ************************************************************************************
        //  2. Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
        //    until clear
        // ************************************************************************************
        do
        begin
            data = 0;
            m_regs.cmiu.CMIUCMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

        //Clear the Lookup Enable Bit.
         wr_data = 0;
         m_regs.cmiu.CMIUCMCTCR.LookupEn.set(wr_data);
         m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));

        //Set the Fill bit 
        wr_data = 1;
        m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
        m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));

        `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask        
endclass : cmiu_ccp_dis_lookup_en_seq 


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------

class cmiu_ccp_dis_fill_en_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_dis_fill_en_seq)

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)

        repeat(5) begin

            #(20us);
            //Set the Fill Enable Bit.
            wr_data = 1;
            m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
            m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));

            #(20us);
            //Clear the Fill Enable Bit.
            wr_data = 0;
            m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
            m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));


        end

        `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask
endclass : cmiu_ccp_dis_fill_en_seq 

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_mntop_write_data_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_mntop_write_data_seq)

    string spkt;
    int local_nSets;
    int local_nWays;
    rand bit [31:0] rand_wr_data;

//Calculate the Width of IO cache tag.
<% if(obj.useCmc) { %> 
<%
 var memWidth     = obj.DmiInfo[0].wData;

%>
bit [31:0] cacheData;
//bit [34-1:0] cacheTag;

    function new(string name="cmiu_ccp_mntop_write_data_seq");
        super.new(name);
    endfunction

    task body();
   
       <% if(obj.useCmc) { %>  
        local_nSets = <%=obj.nSets%>;
        local_nWays = <%=obj.nWays%>;
        <%}%> 

        spkt = {"Perform MntOp Write with Index Size:%0h and Way:%0h"};
        `uvm_info("CMC-$-SEQ", $psprintf(spkt,local_nSets,local_nWays), UVM_MEDIUM)
        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(100ns);
                for(bit[5:0] m_nWord=0; m_nWord<16; m_nWord++) begin
                    cpy_nSets = i;
                    cpy_nWays   = m;

                    `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",cpy_nSets,cpy_nWays), UVM_MEDIUM)

                    //**********************************************************************************
                    //  	Program the CMIUCMCMLR0 to read a random index/way. 
                    //  
                    //**********************************************************************************

                     m_regs.cmiu.CMIUCMCMLR0.MntSet.set(cpy_nSets);
                     m_regs.cmiu.CMIUCMCMLR0.MntWay.set(cpy_nWays);
                     m_regs.cmiu.CMIUCMCMLR0.MntWord.set(m_nWord);
                     m_regs.cmiu.CMIUCMCMLR0.update(status,.path(UVM_FRONTDOOR), .parent(this));

                    //**********************************************************************************
                    // Read the CMIUCMCMDR. This register will return the tag it has stored.  
                    // check it is valid , if not valid then configure again with new Indx and way 
                    //**********************************************************************************
                        randomize(rand_wr_data);
                        cacheData = rand_wr_data;
                        wr_data = cacheData;
                        m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));

                    //**********************************************************************************
                    //  There is a PCMNTOP field which determines what operation you can do. 
                    //  In these field program the opcode to write particular index/way.  
                    //  
                    //**********************************************************************************
                    wr_data = 'he;
                    m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));

                    do
                    begin
                        data = 0;
                        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                    end while(field_rd_data != data);
                   
                end


                //**********************************************************************************
                //  There is a PCMNTOP field which determines what operation you can do. 
                //  In these field program the opcode to write particular index/way.  
                //  
                //**********************************************************************************
                 //Clear the Data register so we know that the Data is written to tag
                 wr_data = 'h0;
                 m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));

                 wr_data = {6'h0,cpy_nWays,cpy_nSets};
                 m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data, .parent(this));
                
                
                 wr_data = 'hc;
                 m_regs.cmiu.CMIUCMCMCR.write(status, wr_data,.parent(this));

                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);

                m_regs.cmiu.CMIUCMCMDR.read(status,field_rd_data,.parent(this));
             
                if(field_rd_data != cacheData) begin
                    `uvm_error("CMC-$-SEQ",$sformatf("Data Mismatch Exp Data :%0h but got Data:%0h ",cacheData,field_rd_data))
                end

            end
        end

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask

    <%}%>
endclass : cmiu_ccp_mntop_write_data_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_mntop_write_index_way_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_mntop_write_index_way_seq)

    string spkt;
    int local_nSets;
    int local_nWays;
    rand bit [31:0] rand_wr_data;
    bit [31:0] wr_data_q[$];
    bit [5:0] total_word;
    bit [5:0] word_bndry;

//Calculate the Width of IO cache tag.
<% if(obj.useCmc) { %> 
<% 
    var wSecurity; 
    var errorInfo =  obj.DmiInfo[0].ccpParams.TagErrInfo;
    var nSetSelectBits = obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;
    if(obj.wSecurityAttribute>0){
       wSecurity = 1;
    }else{
       wSecurity = 0;
    }
    var wAxAddr = obj.DmiInfo[0].wAddr;
    var nWays = obj.DmiInfo[0].ccpParams.nWays;
    var nSets = obj.DmiInfo[0].ccpParams.nSets;
    var nTagBanks = obj.DmiInfo[0].ccpParams.nTagBanks;
    var nPrimaryDiagonalPortSelectBits = obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;
    var nDmis = obj.DmiInfo[0].nDmis;
    var removedPortBits = nPrimaryDiagonalPortSelectBits - Math.ceil(Math.log2(Math.pow(2, nPrimaryDiagonalPortSelectBits) / nDmis));
    var repPolicy = obj.DmiInfo[0].ccpParams.fnReplPolType;
    var nRPPorts = obj.DmiInfo[0].ccpParams.nReplPolMemPorts;
    var nStateBits = 2;
    var wCacheLineOffset = obj.wCacheLineOffset;

    var dataWidth = wAxAddr
        - nSetSelectBits
        - wCacheLineOffset
        + wSecurity
        //- nPortSelectBits
        - removedPortBits
        + nStateBits
        // Only add when replacement policy is NRU
        + (((nWays > 1) && (repPolicy !== 'RANDOM') && (nRPPorts === 1)) ? 1 : 0);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ECC Calculations
    //
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var blockWidths;
    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS')) {
        blockWidths = getEvenBlockWidths(errorInfo, dataWidth, 0);
    } else {
        blockWidths = [dataWidth];
    }
/************************************************************
 * Returns a vector of block widths that are as close as possible
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @arg {Number} extraBits - extra number of bits to be added to the first element
 * @return [{Number1},{Number2}...] - The vector of block widths.
 */
function getEvenBlockWidths(fnErrDetectCorrect, width, extraBits) {
    var idealNumBlock;
    if (fnErrDetectCorrect === 'SECDED64BITS') {
        idealNumBlock = Math.ceil(width / 64);
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        idealNumBlock = Math.ceil(width / 128);
    } else {
        idealNumBlock = 1;
    }

    var evenBlockWidths = [];
    var tempWidth = width;

    for (var i = 0; i < idealNumBlock; i++) {

        if (fnErrDetectCorrect === 'SECDED64BITS') {
            if (i === 0) {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 64 + extraBits;
                }
            } else {
                if (tempWidth < 64) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 64;
                }
            }
            tempWidth = tempWidth - 64;
        } else if (fnErrDetectCorrect === 'SECDED128BITS') {
            if (i === 0) {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth + extraBits;
                } else {
                    evenBlockWidths[i] = 128 + extraBits;
                }
            } else {
                if (tempWidth < 128) {
                    evenBlockWidths[i] = tempWidth;
                } else {
                    evenBlockWidths[i] = 128;
                }
            }
            tempWidth = tempWidth - 128;
        } else {
            if (i === 0) {
                evenBlockWidths[i] = tempWidth + extraBits;
            } else {
                evenBlockWidths[i] = tempWidth;
            }
            tempWidth = 0;
        }

    }

    return evenBlockWidths;
}

//------------------------------------------------------------
// getEccIndexes()
// takes an array of block widths and returns an array of
// arrays that contain the data bits for each ecc logical
// block as it would appear in memory.
//------------------------------------------------------------
function getEccIndexes(blockWidths, startIndex, errorInfo) {
    var index;
    if (startIndex) {
        index = startIndex;
    } else {
        index = 0;
    }
    var blockIndex = [];
    var memEccBlocks = [];
    var eccOnlyBlocks = [];
    var block;
    var bit;

    // create array
    for (block = 0; block < blockWidths.length; block++) {
        memEccBlocks[block] = [];
        eccOnlyBlocks[block] = [];
        blockIndex[block] = 0;
    }

    if ((errorInfo === 'SECDED64BITS') || (errorInfo === 'SECDED128BITS') || (errorInfo === 'SECDED')) {
        // parity bit
        for (block = 0; block < blockWidths.length; block++) {
            eccOnlyBlocks[block][blockIndex[block]] = index;
            memEccBlocks[block][blockIndex[block]++] = index++;
        }

        // error bits
        for (block = 0; block < blockWidths.length; block++) {
            for (bit = 0; bit < getErrorEncodingWidth('SECDED', blockWidths[block]) - 1; bit++) {
                eccOnlyBlocks[block][blockIndex[block]] = index;
                memEccBlocks[block][blockIndex[block]++] = index++;
            }
        }
    } else {
        // parity bits
        for (block = 0; block < blockWidths.length; block++) {
            for (bit = 0; bit < getErrorEncodingWidth(errorInfo, blockWidths[block]) - 1; bit++) {
                eccOnlyBlocks[block][blockIndex[block]] = index;
                memEccBlocks[block][blockIndex[block]++] = index++;
            }
        }
    }

    // data bits
    for (block = 0; block < blockWidths.length; block++) {
        for (bit = 0; bit < blockWidths[block]; bit++) {
            memEccBlocks[block][blockIndex[block]++] = index++;
        }
    }
    return {
        memEccBlocks: memEccBlocks,
        eccOnlyBlocks: eccOnlyBlocks
    }
}
/************************************************************
 * Returns the number of bits required for error encoding.
 *
 * @arg {string} fnErrDetectCorrect - error encoding type.
 * @arg {Number} width - data width before encoding.
 * @return {Number} - The number of bits required for the error code.
 */
function getErrorEncodingWidth(fnErrDetectCorrect, width, blockWidths) {
    //u.log("EncodingWidth ... "+fnErrDetectCorrect+", "+width);
    var errWidth = 0;
    var resolution;

    if (fnErrDetectCorrect === 'PARITYENTRY') {
        errWidth = 1;
    } else if (fnErrDetectCorrect === 'PARITY16BITS') {
        errWidth = Math.ceil(width / 16);
    } else if (fnErrDetectCorrect === 'PARITY8BITS') {
        errWidth = Math.ceil(width / 8);
    } else if (fnErrDetectCorrect === 'SECDED') {
        if (width === 1) {
            errWidth = 3;
        } else if (width === 2) {
            errWidth = 4;
        } else {
            errWidth = Math.ceil(Math.log2(width + Math.ceil(Math.log2(width)) + 1)) + 1;
        }
        if (width <= 2) {
            throw new Error('SECDED Entry is not supported if data width <= 2.: ');
        }
    } else if (fnErrDetectCorrect === 'SECDED64BITS') {
        resolution = 64;
    } else if (fnErrDetectCorrect === 'SECDED128BITS') {
        resolution = 128;
    }

    var numInst;
    var wInstData;
    var inst;
    if (fnErrDetectCorrect === 'SECDED64BITS' ||
        fnErrDetectCorrect === 'SECDED128BITS') {
        if (blockWidths) {
            numInst = blockWidths.length;
            for (inst = 0; inst < numInst; inst++) {
                wInstData = blockWidths[inst];
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        } else {
            numInst = Math.ceil(width / resolution);
            for (inst = 0; inst < numInst; inst++) {
                if ((resolution * (inst + 1)) > width) {
                    wInstData = width % resolution;
                } else {
                    wInstData = resolution;
                }
                if (wInstData === 1) {
                    errWidth += 3;
                } else if (wInstData === 2) {
                    errWidth += 4;
                } else {
                    errWidth += Math.ceil(Math.log2(wInstData + Math.ceil(Math.log2(wInstData)) + 1)) + 1;
                }
            }
        }
    }

    return errWidth;
}
    var wayStart = 0;
    for (var way = 0; way < nWays; way++) {
        var eccIndexes = getEccIndexes(blockWidths, wayStart, errorInfo);
        memEccBlocks = memEccBlocks.concat(eccIndexes.memEccBlocks);
        eccOnlyBlocks = eccOnlyBlocks.concat(eccIndexes.eccOnlyBlocks);
        wayStart += dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Width with Error Bits
    //
    var memWidth = (dataWidth + getErrorEncodingWidth(errorInfo, dataWidth, blockWidths)) * nWays;

    var TagWidth = memWidth/obj.nWays;
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Depth
    //
    var memDepth = nSets / nTagBanks;

   var  numCacheWord = Math.ceil((memWidth)/32);
%>
bit [<%=TagWidth%>-1:0] cacheTag;
bit [32-1:0] cacheData;

    function new(string name="cmiu_ccp_mntop_write_index_way_seq");
        super.new(name);
    endfunction

    task body();
   
       <% if(obj.useCmc) { %>  
        local_nSets = <%=obj.nSets%>;
        local_nWays = <%=obj.nWays%>;
        <%}%> 

        spkt = {"Perform MntOp Write with Index Size:%0h and Way:%0h"};
        `uvm_info("CMC-$-SEQ", $psprintf(spkt,local_nSets,local_nWays), UVM_MEDIUM)
        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(100ns);
              // for(bit[5:0] m_nWord=0; m_nWord<<%=numCacheWord%>; m_nWord++) begin
                    cpy_nSets = i;
                    cpy_nWays = m;
                    m_nWord   = 0;
                    `uvm_info("RUN_MAIN",$sformatf("configuring Tag Array m_nSets :%x,  m_nWays :%x ",cpy_nSets,cpy_nWays), UVM_MEDIUM)

                    //**********************************************************************************
                    //  	Program the CMIUCMCMLR0 to read a random index/way. 
                    //  
                    //**********************************************************************************

                     m_regs.cmiu.CMIUCMCMLR0.MntSet.set(cpy_nSets);
                     m_regs.cmiu.CMIUCMCMLR0.MntWay.set(cpy_nWays);
                     m_regs.cmiu.CMIUCMCMLR0.MntWord.set(m_nWord);
                     m_regs.cmiu.CMIUCMCMLR0.update(status,.path(UVM_FRONTDOOR), .parent(this));

                    //**********************************************************************************
                    // Read the CMIUCMCMDR. This register will return the tag it has stored.  
                    // check it is valid , if not valid then configure again with new Indx and way 
                    //**********************************************************************************
                    if(m_nWord==0) begin
                        randomize(rand_wr_data);
                        cacheTag = rand_wr_data;
                        wr_data = cacheTag;
                        m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));
                        wr_data_q.push_back(wr_data);
                    end else begin
                         wr_data = 'h0;
                        m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));
                    end
                    `uvm_info("TAG MAINTDEBUG",$sformatf("wr_data pushed data:%0x",wr_data),UVM_MEDIUM);

                    //**********************************************************************************
                    //  There is a PCMNTOP field which determines what operation you can do. 
                    //  In these field program the opcode to write particular index/way.  
                    //  
                    //**********************************************************************************
                    wr_data = 'he;
                    m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));

                    do
                    begin
                        data = 0;
                        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                    end while(field_rd_data != data);
                   
               // end
            end
        end

        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(100ns);
                    cpy_nSets = i;
                    cpy_nWays = m;
                    m_nWord   = 0;

                //**********************************************************************************
                //  There is a PCMNTOP field which determines what operation you can do. 
                //  In these field program the opcode to write particular index/way.  
                //  
                //**********************************************************************************
                 //Clear the Data register so we know that the Data is written to tag
                 wr_data = 'h0;
                 m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));

                 wr_data = {6'h0,cpy_nWays,cpy_nSets};
                 m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data, .parent(this));
                
                
                 wr_data = 'hc;
                 m_regs.cmiu.CMIUCMCMCR.write(status, wr_data,.parent(this));

                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);

                m_regs.cmiu.CMIUCMCMDR.read(status,field_rd_data,.parent(this));
            
                cacheTag = wr_data_q.pop_front(); 
                `uvm_info("TAG MAINTDEBUG",$sformatf("wr_data pop :%0x",cacheTag),UVM_MEDIUM);

                if(field_rd_data != cacheTag) begin
                    `uvm_error("CMC-$-SEQ",$sformatf("Data Mismatch Exp Data :%0h but got Data:%0h ",cacheTag,field_rd_data))
                end

            end
        end
        //********************************************************************************************
        // Write to Cmc data Array  and read it back 
        //
        //********************************************************************************************
        total_word = (((SYS_nSysCacheline*8)/
                                        <%=obj.DmiInfo[0].wData%>)) ;

        word_bndry = (<%=obj.DmiInfo[0].wData%>)/32;

       for(int i=0; i<local_nSets; i++) begin
          for(int m=0; m<local_nWays; m++) begin
                #(100ns);
             cpy_nSets = i;
             cpy_nWays   = m;
             for(bit[5:0] mw=0; mw<total_word*2; mw=mw+2) begin
                for(bit[5:0] m_nWord=(0+(mw*word_bndry)); m_nWord<(word_bndry+(mw*word_bndry)); m_nWord++) begin

                    `uvm_info("RUN_MAIN",$sformatf("configuring Data Array m_nSets :%x,  m_nWays :%x ",cpy_nSets,cpy_nWays), UVM_MEDIUM)

                    //**********************************************************************************
                    //  	Program the CMIUCMCMLR0 to read a random index/way. 
                    //  
                    //**********************************************************************************

                //     m_regs.cmiu.CMIUCMCMLR0.MntSet.set(cpy_nSets);
                //     m_regs.cmiu.CMIUCMCMLR0.MntWay.set(cpy_nWays);
                //     m_regs.cmiu.CMIUCMCMLR0.MntWord.set(m_nWord);
                //     m_regs.cmiu.CMIUCMCMLR0.update(status,.path(UVM_FRONTDOOR), .parent(this));
                     wr_data = {m_nWord,cpy_nWays,cpy_nSets};
                     m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data, .parent(this));
                //     m_regs.cmiu.CMIUCMCMLR0.read(status,field_rd_data,.parent(this));
                  
                    //**********************************************************************************
                    // Read the CMIUCMCMDR. This register will return the tag it has stored.  
                    // check it is valid , if not valid then configure again with new Indx and way 
                    //**********************************************************************************
                    randomize(rand_wr_data);
                    cacheData = rand_wr_data;
                    wr_data = cacheData;
                    m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));
                    wr_data_q.push_back(wr_data);
                    `uvm_info("DATA MAINTDEBUG",$sformatf("wr_data push :%0x",wr_data),UVM_MEDIUM);

                    //**********************************************************************************
                    //  There is a PCMNTOP field which determines what operation you can do. 
                    //  In these field program the opcode to write particular index/way.  
                    //  
                    //**********************************************************************************
                    wr_data = 'h1000e;
                    m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));

                    do
                    begin
                        data = 0;
                        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                    end while(field_rd_data != data);
               
               end       
              end
            end
        end

        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(100ns);

                 cpy_nSets = i;
                 cpy_nWays = m;
                //**********************************************************************************
                //  There is a PCMNTOP field which determines what operation you can do. 
                //  In these field program the opcode to write particular index/way.  
                //  
                //**********************************************************************************
             for(bit[5:0] mw=0; mw<total_word*2; mw=mw+2) begin
               for(bit[5:0] m_nWord=(0+(mw*word_bndry)); m_nWord<(word_bndry+(mw*word_bndry)); m_nWord++) begin
                 //Clear the Data register so we know that the Data is written to tag
                 wr_data = 'h0;
                 m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));

                 wr_data = {m_nWord,cpy_nWays,cpy_nSets};
                 m_regs.cmiu.CMIUCMCMLR0.write(status,wr_data, .parent(this));
                
                
                 wr_data = 'h1000c;
                 m_regs.cmiu.CMIUCMCMCR.write(status, wr_data,.parent(this));

                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);

                m_regs.cmiu.CMIUCMCMDR.read(status,field_rd_data,.parent(this));
                cacheData = wr_data_q.pop_front(); 
               `uvm_info("DATA MAINTDEBUG",$sformatf("wr_data pop :%0x",cacheData),UVM_MEDIUM);
             
                if(field_rd_data != cacheData) begin
                    `uvm_error("CMC-$-SEQ",$sformatf("Data Mismatch Exp Data :%0h but got Data:%0h ",cacheData,field_rd_data))
                end
              end
             end
          end
        end


      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask

    <%}%>
endclass : cmiu_ccp_mntop_write_index_way_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------

class cmiu_ccp_mntop_rand_write_index_way_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_mntop_rand_write_index_way_seq)

    typedef bit [31:0] cmiu_ccp_word[2];
    typedef cmiu_ccp_word cmiu_ccp_nway_a[<%=obj.nWays%>];
    cmiu_ccp_nway_a       cmiu_ccp_nset_a[<%=obj.nSets%>];

    string spkt;
    int local_nSets;
    int local_nWays;


    function new(string name="cmiu_ccp_mntop_rand_write_index_way_seq");
        super.new(name);
    endfunction

    task body();

     //************************************************************************************
     //  1. Clear the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
     // ************************************************************************************
        wr_data = 0;
        m_regs.cmiu.CMIUCMCTCR.FillEn.set(wr_data);
        m_regs.cmiu.CMIUCMCTCR.update(status, .path(UVM_FRONTDOOR), .parent(this));
     // ************************************************************************************
     //  2. Poll the Proxy Cache Fill Active bit (Proxy Cache Transaction Activity Register) 
     //    until clear
     // ************************************************************************************
        do
        begin
            data = 0;
            m_regs.cmiu.CMIUCMCTAR.read(status,field_rd_data,.parent(this));
        end while(field_rd_data != data);

    // ************************************************************************************
    // 3. Clear the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
     //    the main phase of the Master agent's dataflow Sequencer
     // ************************************************************************************
         wr_data = 0;
         m_regs.cmiu.CMIUCMCTCR.LookupEn.set(wr_data);
         m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));

       <% if(obj.useCmc) { %>  
        local_nSets = <%=obj.nSets%>;
        local_nWays = <%=obj.nWays%>;
        <%}%> 


        spkt = {"Perform MntOp Write with Index Size:%0h and Way:%0h"};
        `uvm_info("CMC-$-SEQ", $psprintf(spkt,local_nSets,local_nWays), UVM_MEDIUM)
        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(1us);
                for(bit[5:0] m_nWord=0; m_nWord<2; m_nWord++) begin
                    cpy_nSets = i;
                    cpy_nWays = m;

                    `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",cpy_nSets,cpy_nWays), UVM_MEDIUM)

                    
                    //**********************************************************************************
                    //  There is a PCMNTOP field which determines what operation you can do. 
                    //  In these field program the opcode to write particular index/way.  
                    //  
                    //**********************************************************************************
                    m_regs.cmiu.CMIUCMCMLR0.MntSet.set(cpy_nSets);
                    m_regs.cmiu.CMIUCMCMLR0.MntWay.set(cpy_nWays);
                     m_regs.cmiu.CMIUCMCMLR0.MntWord.set(m_nWord);
                     m_regs.cmiu.CMIUCMCMLR0.update(status,.path(UVM_FRONTDOOR), .parent(this));



                   wr_data = 'hc;
                   m_regs.cmiu.CMIUCMCMCR.write(status, wr_data,.parent(this));
                                
                    
                    do
                    begin
                        data = 0;
                        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                    end while(field_rd_data != data);
                    
                    m_regs.cmiu.CMIUCMCMDR.read(status,field_rd_data,.parent(this));
                    cmiu_ccp_nset_a[cpy_nSets][cpy_nWays][m_nWord] = field_rd_data;
        
                    spkt = {"Read Word:%0d for Index:%0d and Way:%0d Data:%0h"}; 
                    `uvm_info("CMC-$-SEQ",$psprintf(spkt,m_nWord, cpy_nSets,cpy_nWays, field_rd_data),UVM_MEDIUM)

                end
            end
        end
// ************************************************************************************
//  1. Initiate and complete a Proxy Cache Flush operation (Proxy Cache Maintenance Control 
//    Register and Proxy Cache Maintenance Activity Register).
//    a. write the "CMIUCMCMCR_CmcMntOp" field with 0. This will flush the entire tag array
// ************************************************************************************
     wr_data = 0;
     m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));


// ************************************************************************************
//  c.Poll the "CMIUCMCMAR" register till the field "MntOpActv" becomes 0. 
// ************************************************************************************
    do
    begin
        data = 0;
        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
    end while(field_rd_data != data);
// ************************************************************************************
//  2.	Set the Proxy Cache Lookup Enable bit (Proxy Cache Transaction Control Register)
// ************************************************************************************
     wr_data = 1;
     m_regs.cmiu.CMIUCMCTCR.LookupEn.set(wr_data);
     m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));
// ************************************************************************************
//  3.	Set the Proxy Cache Fill Enable bit (Proxy Cache Transaction Control Register)
// ************************************************************************************


     wr_data = 1;
     m_regs.cmiu.CMIUCMCTCR.FillEn.set( wr_data);
     m_regs.cmiu.CMIUCMCTCR.update( status, .path(UVM_FRONTDOOR), .parent(this));

        for(int i=0; i<local_nSets; i++) begin
            for(int m=0; m<local_nWays; m++) begin
                #(1us);
                for(bit[5:0] m_nWord=0; m_nWord<2; m_nWord++) begin
                    cpy_nSets = i;
                    cpy_nWays   = m;

                    `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",cpy_nSets,cpy_nWays), UVM_MEDIUM)

                    //**********************************************************************************
                    //  	Program the CMIUCMCMLR0 to read a random index/way. 
                    //  
                    //**********************************************************************************

                     m_regs.cmiu.CMIUCMCMLR0.MntSet.set(cpy_nSets);
                     m_regs.cmiu.CMIUCMCMLR0.MntWay.set(cpy_nWays);
                     m_regs.cmiu.CMIUCMCMLR0.MntWord.set(m_nWord);
                     m_regs.cmiu.CMIUCMCMLR0.update(status,.path(UVM_FRONTDOOR), .parent(this));
                    
                    //**********************************************************************************
                    // Read the CMIUCMCMDR. This register will return the tag it has stored.  
                    // check it is valid , if not valid then configure again with new Indx and way 
                    //**********************************************************************************
                    wr_data =  cmiu_ccp_nset_a[cpy_nSets][cpy_nWays][m_nWord];
                    m_regs.cmiu.CMIUCMCMDR.write( status, wr_data,.parent(this));

                    spkt = {"Write Word:%0d for Index:%0d and Way:%0d Data:%0h"}; 
                    `uvm_info("CMC-$-SEQ",$psprintf(spkt,m_nWord, cpy_nSets,cpy_nWays, wr_data),UVM_MEDIUM)

                    //**********************************************************************************
                    //  There is a PCMNTOP field which determines what operation you can do. 
                    //  In these field program the opcode to write particular index/way.  
                    //  
                    //**********************************************************************************
                    wr_data = 'he;
                    m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));


                    do
                    begin
                        data = 0;
                        m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                    end while(field_rd_data != data);

                end
            end
        end
        `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask      
endclass : cmiu_ccp_mntop_rand_write_index_way_seq



//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_rand_all_flush_op_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_rand_all_flush_op_seq)

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0] rand_wr_data;
    rand bit [3:0]  mntop_cmd;
    Addr_t    cache_addr_list [$];

    <% if(obj.INHOUSE_APB_VIP) { %>
    apb_sequencer    m_apb_sequencer;
    <%}%>

    //io_cache_model cpy_ioCacheModel;
    bit security;
    bit [WAXADDR - SYS_wSysCacheline] m_addr_size; 

    constraint c_mntop_cmd {
        mntop_cmd inside {4,5};
    }

   <% if(obj.isBridgeInterface && obj.useIoCache) { %>  

    <% if (obj.nSets>1){ %>
    constraint c_nSets  { m_nSets  < <%=obj.nSets%>;}
    <%}%>
    
    <% if (obj.nWays>1){ %>
    constraint c_nWays  { m_nWays  < <%=obj.nWays%>;}  
    <%}%> 
    <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        
        `uvm_info("body", "Entered...", UVM_MEDIUM)
        repeat(10) begin
             assert(randomize(mntop_cmd)); 
             wr_data = mntop_cmd;

            <% if(obj.INHOUSE_APB_VIP) { %>
            //If Flush By Index 
            if(mntop_cmd == 'h5) begin
                cmiu_ccp_flush_per_index_way_seq csr_seq = cmiu_ccp_flush_per_index_way_seq::type_id::create("csr_seq");
                `uvm_info("body","FLUSH_PER_INDEX chosen", UVM_MEDIUM);
                csr_seq.model = this.model; 
                csr_seq.k_num_flush_cmd = 1; 
                csr_seq.start(m_apb_sequencer);
            
            //Else if Flush by Addr
            end else if(mntop_cmd == 'h6) begin
              // `uvm_info("body","FLUSH_BY_ADDRESS chosen, Ignored", UVM_MEDIUM);
              //  cmiu_ccp_flush_by_addr_seq csr_seq_addr = cmiu_ccp_flush_by_addr_seq::type_id::create("csr_seq_addr");
              //  csr_seq_addr.model = this.model; 
              //  csr_seq_addr.cache_addr_list = this.cache_addr_list; 
              //  csr_seq_addr.k_num_flush_cmd = 1; 
              //  csr_seq_addr.start(m_apb_sequencer);
            
            //Else flush all
            end else begin
                `uvm_info("body","FLUSH_ALL chosen", UVM_MEDIUM);
                m_regs.cmiu.CMIUCMCMCR.write(status, wr_data, .parent(this));

                //Poll the MntOp Active Bit
                do
                begin
                   data = 0;
                   m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);
            end
            <%}%>

            //Else Intialize all

        end

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask
endclass : cmiu_ccp_rand_all_flush_op_seq
//-----------------------------------------------------------------------
//  Task    :  Flush all
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_flush_all_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_flush_all_seq)

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0] rand_wr_data;
    rand bit [3:0]  mntop_cmd;
    ccp_ctrlop_addr_t   cache_addr_list [$];

    <% if(obj.INHOUSE_APB_VIP) { %>
    apb_sequencer    m_apb_sequencer;
    <%}%>

    //io_cache_model cpy_ioCacheModel;
    bit security;
    bit [WAXADDR - SYS_wSysCacheline] m_addr_size; 

    constraint c_mntop_cmd {
        mntop_cmd ==  4;
    }

   <% if(obj.isBridgeInterface && obj.useIoCache) { %>  

    <% if (obj.nSets>1){ %>
    constraint c_nSets  { m_nSets  < <%=obj.nSets%>;}
    <%}%>
    
    <% if (obj.nWays>1){ %>
    constraint c_nWays  { m_nWays  < <%=obj.nWays%>;}  
    <%}%> 
    <%}%>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        
        `uvm_info("body", "Entered...", UVM_MEDIUM)
             wr_data = 4;

            <% if(obj.INHOUSE_APB_VIP) { %>
                `uvm_info("body","FLUSH_ALL chosen", UVM_MEDIUM);
                m_regs.cmiu.CMIUCMCMCR.write(status, wr_data, .parent(this));

                //Poll the MntOp Active Bit
                do
                begin
                   data = 0;
                   m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);
            <%}%>

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask
endclass : cmiu_ccp_flush_all_seq


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class cmiu_ccp_mntop_init_all_seq extends cmiu_ccp_ral_gen_base_seq; 
  `uvm_object_utils(cmiu_ccp_mntop_init_all_seq)

    rand bit [19:0] m_nSets;
    rand bit [5:0]  m_nWays;
    rand bit [5:0]  m_nWord;
    rand bit [31:0]  rand_wr_data;

    int k_num_flush_cmd=1;

    function new(string name="");
        super.new(name);
    endfunction
  
    task body();
        `uvm_info("body", "Entered...", UVM_MEDIUM)

        repeat(k_num_flush_cmd) begin
                `uvm_info("RUN_MAIN",$sformatf("configuring m_nSets :%x,  m_nWays :%x ",m_nSets,m_nWays), UVM_MEDIUM)

                //**********************************************************************************
                // If the state is not IX flush that particular index/way   
                // Perform a MntOp operation CMIUCMCMCR register with flush index/way 
                //**********************************************************************************

                 wr_data = 0;
                 m_regs.cmiu.CMIUCMCMCR.write(status,wr_data, .parent(this));

                do
                begin
                    data = 0;
                    m_regs.cmiu.CMIUCMCMAR.read(status,field_rd_data,.parent(this));
                end while(field_rd_data != data);
        end

      `uvm_info("body", "Exiting...", UVM_MEDIUM)
    endtask
endclass : cmiu_ccp_mntop_init_all_seq


`endif

