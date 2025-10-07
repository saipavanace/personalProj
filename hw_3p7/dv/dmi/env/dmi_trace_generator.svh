/*`uvm_analysis_imp_decl(_master_req)
`uvm_analysis_imp_decl(_master_rsp)
`uvm_analysis_imp_decl(_slave_req)
`uvm_analysis_imp_decl(_slave_rsp)
`uvm_analysis_imp_decl(_read_addr_chnl)
`uvm_analysis_imp_decl(_read_data_chnl)
`uvm_analysis_imp_decl(_write_addr_chnl)
`uvm_analysis_imp_decl(_write_data_chnl)
`uvm_analysis_imp_decl(_write_resp_chnl)*/

////////////////////////////////////////////////////////////////////////////////
//
// DMI Trace Generator
//
////////////////////////////////////////////////////////////////////////////////
class dmi_trace_generator extends uvm_component;

   `uvm_component_utils(dmi_trace_generator)

   uvm_analysis_imp_master_req #(sfi_seq_item, dmi_trace_generator) analysis_master_req;
   uvm_analysis_imp_master_rsp #(sfi_seq_item, dmi_trace_generator) analysis_master_rsp;
   uvm_analysis_imp_slave_req  #(sfi_seq_item, dmi_trace_generator) analysis_slave_req;
   uvm_analysis_imp_slave_rsp  #(sfi_seq_item, dmi_trace_generator) analysis_slave_rsp;
   uvm_analysis_imp_read_addr_chnl #(axi4_read_addr_pkt_t, dmi_trace_generator) analysis_read_addr_port;
   uvm_analysis_imp_read_data_chnl #(axi4_read_data_pkt_t, dmi_trace_generator) analysis_read_data_port;
   uvm_analysis_imp_write_addr_chnl #(axi4_write_addr_pkt_t, dmi_trace_generator) analysis_write_addr_port;
   uvm_analysis_imp_write_data_chnl #(axi4_write_data_pkt_t, dmi_trace_generator) analysis_write_data_port;
   uvm_analysis_imp_write_resp_chnl #(axi4_write_resp_pkt_t, dmi_trace_generator) analysis_write_resp_port;
   static int mhandle;
   int  mAgtId;

   function new(string name = "dmi_trace_generator", uvm_component parent = null);
      super.new(name, parent);
      $timeformat(-9);
   endfunction : new

   function void build_phase(uvm_phase phase);

      super.build_phase(phase);
      analysis_master_req = new ("analysis_master_req", this);
      analysis_master_rsp = new ("analysis_master_rsp", this);
      analysis_slave_req  = new ("analysis_slave_req",  this);
      analysis_slave_rsp  = new ("analysis_slave_rsp",  this);
      analysis_read_addr_port = new ("analysis_read_addr_port", this);
      analysis_read_data_port = new ("analysis_read_data_port", this);
      analysis_write_addr_port = new ("analysis_write_addr_port", this);
      analysis_write_data_port = new ("analysis_write_data_port", this);
      analysis_write_resp_port = new ("analysis_write_resp_port", this);

endfunction : build_phase

   function void start_of_simulation();
      super.start_of_simulation();
      mhandle = $fopen("checker_debug.trc","w");
      if (mhandle == 0) begin
         $display("ERROR : Cannot open trace file for write");
      end
      mAgtId = <%=obj.nAIUs+obj.nCBIs+obj.nDCEs%>;
      /*else begin
         $fwrite(mhandle,"trial");
      end*/
   endfunction // start_of_simulation_phase

   function void report_phase(uvm_phase phase);
      //run_report(phase);
      $fclose(mhandle);
   endfunction // report_phase

    extern function void pack_data_lendn(ref <%=obj.BlockId + '_con'%>::sfi_data_t data[], bit[7:0] data_lendn[]);
    extern function void pack_data_lendn_axi(ref <%=obj.BlockId + '_con'%>::axi_xdata_t data[], bit[7:0] data_lendn[]);
    extern function void pack_be_lendn(ref <%=obj.BlockId + '_con'%>::sfi_be_t be[], bit be_lendn[]);
   extern function void write_master_req(sfi_seq_item  item);
   extern function void write_master_rsp(sfi_seq_item  m_pkt);
   extern function void write_slave_req(sfi_seq_item  m_pkt);
   extern function void write_slave_rsp(sfi_seq_item  item);
   extern function void write_read_addr_chnl(axi4_read_addr_pkt_t m_pkt);
   extern function void write_read_data_chnl(axi4_read_data_pkt_t m_pkt);
   extern function void write_write_addr_chnl(axi4_write_addr_pkt_t m_pkt);
   extern function void write_write_data_chnl(axi4_write_data_pkt_t m_pkt);
   extern function void write_write_resp_chnl(axi4_write_resp_pkt_t m_pkt);

endclass : dmi_trace_generator

function void dmi_trace_generator::write_master_req(sfi_seq_item  item);

   sfi_seq_item m_item;
   time recdTime;
   int  isInitiator;
   <%=obj.BlockId + '_con'%>::sfi_data_t temp_data[];
   <%=obj.BlockId + '_con'%>::sfi_be_t   temp_be[];
   bit [7:0] sfi_data_lendn[];
   bit       sfi_be_lendn[];
   m_item = new();
   m_item.copy(item);
   isInitiator = 0;

   temp_data = new[m_item.req_pkt.req_data.size()];
   temp_be   = new[m_item.req_pkt.req_be.size()];
   foreach(m_item.req_pkt.req_data[i]) begin
      temp_data[i] = m_item.req_pkt.req_data[i];
   end
   foreach(m_item.req_pkt.req_be[i]) begin
      temp_be[i] = m_item.req_pkt.req_be[i];
   end

   pack_data_lendn(temp_data, sfi_data_lendn);
   pack_be_lendn(temp_be, sfi_be_lendn);
   // case 2
   $fwrite(mhandle,$sformatf("2:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:",
                             $time,mAgtId,isInitiator,m_item.req_pkt.req_opc,
                             m_item.req_pkt.req_burst,m_item.req_pkt.req_length,
                             m_item.req_pkt.req_addr,m_item.req_pkt.req_sfiSlvId,
                             m_item.req_pkt.req_transId,m_item.req_pkt.req_sfiPriv,
                             m_item.req_pkt.req_urgency,m_item.req_pkt.req_security,
                             m_item.req_pkt.req_press,m_item.req_pkt.req_hurry,
                             1,m_item.req_pkt.req_protBits,
                             m_item.req_pkt.req_data.size(),
                             0));//m_item.pktType));
   for (int i = 0; i < sfi_data_lendn.size(); i++)
     $fwrite(mhandle, "%0d:%0d:", sfi_data_lendn[i], sfi_be_lendn[i]);
   $fwrite(mhandle,"\n");
endfunction : write_master_req

function void dmi_trace_generator::write_master_rsp(sfi_seq_item  m_pkt);

   sfi_seq_item m_item;
   time recdTime;
   int  isInitiator;
   m_item = new();
   m_item.copy(m_pkt);
   isInitiator = 1;

   // case 3
   $fwrite(mhandle,$sformatf("3:%0d:%0d:%0d:%0d:%0d:%0d:%0d\n",
                             $time,mAgtId,isInitiator,
                             m_item.rsp_pkt.rsp_status,m_item.rsp_pkt.rsp_errCode,
                             m_item.rsp_pkt.rsp_transId,m_item.rsp_pkt.rsp_sfiPriv));//m_item.pktType));
endfunction : write_master_rsp

function void dmi_trace_generator::write_slave_req(sfi_seq_item m_pkt);

   sfi_seq_item m_item;
   time recdTime;
   int  isInitiator;
   <%=obj.BlockId + '_con'%>::sfi_data_t temp_data[];
   <%=obj.BlockId + '_con'%>::sfi_be_t   temp_be[];
   bit [7:0] sfi_data_lendn[];
   bit       sfi_be_lendn[];
   m_item = new();
   m_item.copy(m_pkt);
   isInitiator = 1;

   temp_data = new[m_item.req_pkt.req_data.size()];
   temp_be   = new[m_item.req_pkt.req_be.size()];
   foreach(m_item.req_pkt.req_data[i]) begin
      temp_data[i] = m_item.req_pkt.req_data[i];
   end
   //$display($sformatf("temp:%p req_data:%p",temp_data,m_item.req_pkt.req_data));
   foreach(m_item.req_pkt.req_be[i]) begin
      temp_be[i] = m_item.req_pkt.req_be[i];
   end

   pack_data_lendn(temp_data, sfi_data_lendn);
   pack_be_lendn(temp_be, sfi_be_lendn);
   // case 2
   $fwrite(mhandle,$sformatf("2:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:",
                             $time,mAgtId,isInitiator,m_item.req_pkt.req_opc,
                             m_item.req_pkt.req_burst,m_item.req_pkt.req_length,
                             m_item.req_pkt.req_addr,m_item.req_pkt.req_sfiSlvId,
                             m_item.req_pkt.req_transId,m_item.req_pkt.req_sfiPriv,
                             m_item.req_pkt.req_urgency,m_item.req_pkt.req_security,
                             m_item.req_pkt.req_press,m_item.req_pkt.req_hurry,
                             1,m_item.req_pkt.req_protBits,
                             m_item.req_pkt.req_data.size(),
                             0));//m_item.pktType));
   for (int i = 0; i < sfi_data_lendn.size(); i++)
     $fwrite(mhandle, "%0d:%0d:", sfi_data_lendn[i], sfi_be_lendn[i]);
   $fwrite(mhandle,"\n");
endfunction : write_slave_req

function void dmi_trace_generator::write_slave_rsp(sfi_seq_item  item);

   sfi_seq_item m_item;
   time recdTime;
   int  isInitiator;
   m_item = new();
   m_item.copy(item);
   // case 3
   $fwrite(mhandle,$sformatf("3:%0d:%0d:%0d:%0d:%0d:%0d:%0d\n",
                             $time,mAgtId,isInitiator,
                             m_item.rsp_pkt.rsp_status,m_item.rsp_pkt.rsp_errCode,
                             m_item.rsp_pkt.rsp_transId,m_item.rsp_pkt.rsp_sfiPriv));//m_item.pktType));

endfunction : write_slave_rsp

function void dmi_trace_generator::write_read_addr_chnl(axi4_read_addr_pkt_t m_pkt);

   axi4_read_addr_pkt_t m_item;
   time recdTime;
   int  isInitiator;
   m_item = new();
   m_item.copy(m_pkt);
   // case 0
	$fdisplay(mhandle, "0:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d\n",
		  $time,
		  mAgtId,
		  m_item.arid,
		  m_item.araddr,
		  m_item.arlen,
		  m_item.arsize,
		  m_item.arburst,
		  m_item.arsize,
		  m_item.arburst,
		  m_item.arlock,
		  m_item.arcache,
		  m_item.arprot,
		  m_item.arqos,
		  m_item.arregion,
		  m_item.aruser,
		  0,//m_item.ardomain,
		  0,//m_item.arsnoop,
		  0,//m_item.arbar,
		  m_item.t_pkt_seen_on_intf
		  );

endfunction : write_read_addr_chnl

function void dmi_trace_generator::write_read_data_chnl(axi4_read_data_pkt_t m_pkt);

   axi4_read_data_pkt_t m_item;
   time recdTime;
   int  isInitiator;
   bit [7:0] rddata_lendn[];
   m_item = new();
   m_item.copy(m_pkt);
   pack_data_lendn_axi(m_item.rdata, rddata_lendn);

   // case 1
   $fwrite(mhandle, "1:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:", 
	   $time,
	   mAgtId,
	   m_item.rid,
	   m_item.rresp,
	   m_item.ruser,
	   1,//m_item.rack,
	   m_item.rlast,
	   m_item.t_pkt_seen_on_intf
		);
   for (int i = 0; i < rddata_lendn.size(); i++) 
     $fwrite(mhandle, "%0d:", rddata_lendn[i]);
   $fwrite(mhandle,"\n");

endfunction : write_read_data_chnl

function void dmi_trace_generator::write_write_addr_chnl(axi4_write_addr_pkt_t m_pkt);
   axi4_write_addr_pkt_t m_item;
   time recdTime;
   int  isInitiator;
   m_item = new();
   m_item.copy(m_pkt);
   // case 4
   $fdisplay(mhandle, "4:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d:%0d\n", 
	     $time,
	     mAgtId,
	     m_item.awid, 
	     m_item.awaddr, 
	     m_item.awlen,
	     m_item.awsize,
	     m_item.awburst,
	     m_item.awlock,
	     m_item.awcache,
	     m_item.awprot,
	     m_item.awqos,
	     m_item.awregion,
	     m_item.awuser,
	     0,//m_item.awdomain,
	     0,//m_item.awsnoop,
	     0,//m_item.awbar,
	     0,//m_item.awunique,
	     m_item.t_pkt_seen_on_intf
	     );
//   $fwrite(mhandle,"4:\n");

endfunction : write_write_addr_chnl

function void dmi_trace_generator::write_write_data_chnl(axi4_write_data_pkt_t m_pkt);

   axi4_write_data_pkt_t m_item;
   time recdTime;
   int  isInitiator;
   bit [7:0] wrdata_lendn[];
   m_item = new();
   m_item.copy(m_pkt);
   pack_data_lendn_axi(m_item.wdata, wrdata_lendn);

   // case 5
   $fwrite(mhandle, "5:%0d:%0d:%0d:%0d:%0d:",
	   $time,
	   mAgtId,
	   m_item.wuser,
	   m_item.wlast,
	   m_item.t_pkt_seen_on_intf
	   );
   for (int i = 0; i < wrdata_lendn.size(); i++) 
     $fwrite(mhandle, "%0d:", wrdata_lendn[i]);
   $fwrite(mhandle,"\n");

endfunction : write_write_data_chnl

function void dmi_trace_generator::write_write_resp_chnl(axi4_write_resp_pkt_t m_pkt);

   axi4_write_resp_pkt_t m_item;
   time recdTime;
   int  isInitiator;
   m_item = new();
   m_item.copy(m_pkt);

   // case 6
   $fwrite(mhandle, "6:%0d:%0d:%0d:%0d:%0d:%0d:%0d:\n",
	     $time,
	     mAgtId,
	     m_item.bid,
	     m_item.bresp,
	     m_item.buser,
	     1,//m_item.wack,
	     m_item.t_pkt_seen_on_intf
	     );

endfunction : write_write_resp_chnl

function void dmi_trace_generator::pack_data_lendn(ref <%=obj.BlockId + '_con'%>::sfi_data_t data[], bit[7:0] data_lendn[]);
    <%=obj.BlockId + '_con'%>::axi_xdata_t data_beat;
    int nbeats;
    int nbytes_beat;
    int nbytes_xfr;
    int idx, bidx;

    nbeats      = data.size();
    nbytes_beat = (<%=obj.BlockId + '_con'%>::WXDATA/8);
    nbytes_xfr  = nbeats * nbytes_beat;
    data_lendn  = new[nbytes_xfr];
    //`uvm_info("REF", $sformatf("nbeats = %0d nbytes_beat = %0d nbytes_xfr = %0d", nbeats, nbytes_beat, nbytes_xfr), UVM_HIGH);
    
    for(idx = 0; idx < nbeats; idx++) begin
        data_beat = data[idx];
        //`uvm_info("REF", $sformatf("DATA: Bus Format[%0d]  = %9h", idx, data[idx]), UVM_HIGH);
        for(bidx = 0; bidx < nbytes_beat; bidx++) begin
            int nidx = (idx * nbytes_beat) + bidx;

            data_lendn[nidx] = data_beat[8*bidx +: 8];
            //`uvm_info("REF", $sformatf("DATA: Byte Format[%2d] = %2h",nidx, data_lendn[nidx]), UVM_HIGH);
        end
    end

    //foreach(data_lendn[i])
    //    `uvm_info("REF", $sformatf("Final[%2d] = %2h", i, data_lendn[i]), UVM_HIGH);
        
endfunction: pack_data_lendn

function void dmi_trace_generator::pack_data_lendn_axi(ref <%=obj.BlockId + '_con'%>::axi_xdata_t data[], bit[7:0] data_lendn[]);
    <%=obj.BlockId + '_con'%>::axi_xdata_t data_beat;
    int nbeats;
    int nbytes_beat;
    int nbytes_xfr;
    int idx, bidx;

    nbeats      = data.size();
    nbytes_beat = (<%=obj.BlockId + '_con'%>::WXDATA/8);
    nbytes_xfr  = nbeats * nbytes_beat;
    data_lendn  = new[nbytes_xfr];
    //`uvm_info("REF", $sformatf("nbeats = %0d nbytes_beat = %0d nbytes_xfr = %0d", nbeats, nbytes_beat, nbytes_xfr), UVM_HIGH);
    
    for(idx = 0; idx < nbeats; idx++) begin
        data_beat = data[idx];
        //`uvm_info("REF", $sformatf("DATA: Bus Format[%0d]  = %9h", idx, data[idx]), UVM_HIGH);
        for(bidx = 0; bidx < nbytes_beat; bidx++) begin
            int nidx = (idx * nbytes_beat) + bidx;

            data_lendn[nidx] = data_beat[8*bidx +: 8];
            //`uvm_info("REF", $sformatf("DATA: Byte Format[%2d] = %2h",nidx, data_lendn[nidx]), UVM_HIGH);
        end
    end

    //foreach(data_lendn[i])
    //    `uvm_info("REF", $sformatf("Final[%2d] = %2h", i, data_lendn[i]), UVM_HIGH);
        
endfunction: pack_data_lendn_axi

/*function void dmi_trace_generator::pack_data_lendn_w(ref <%=obj.BlockId + '_con'%>::sfi_data_t data[], bit[7:0] data_lendn[]);
    <%=obj.BlockId + '_con'%>::axi_xdata_t data_beat;
    int nbeats;
    int nbytes_beat;
    int nbytes_xfr;
    int idx, bidx;

    nbeats      = data.size();
    nbytes_beat = (<%=obj.BlockId + '_con'%>::WXDATA/8);
    nbytes_xfr  = nbeats * nbytes_beat;
    data_lendn  = new[nbytes_xfr];
    //`uvm_info("REF", $sformatf("nbeats = %0d nbytes_beat = %0d nbytes_xfr = %0d", nbeats, nbytes_beat, nbytes_xfr), UVM_HIGH);
    
    for(idx = 0; idx < nbeats; idx++) begin
        data_beat = data[idx];
        //`uvm_info("REF", $sformatf("DATA: Bus Format[%0d]  = %9h", idx, data[idx]), UVM_HIGH);
        for(bidx = 0; bidx < nbytes_beat; bidx++) begin
            int nidx = (idx * nbytes_beat) + bidx;

            data_lendn[nidx] = data_beat[8*bidx +: 8];
            //`uvm_info("REF", $sformatf("DATA: Byte Format[%2d] = %2h",nidx, data_lendn[nidx]), UVM_HIGH);
        end
    end

    //foreach(data_lendn[i])
    //    `uvm_info("REF", $sformatf("Final[%2d] = %2h", i, data_lendn[i]), UVM_HIGH);
        
endfunction: pack_data_lendn_w*/

function void dmi_trace_generator::pack_be_lendn(ref <%=obj.BlockId + '_con'%>::sfi_be_t be[], bit be_lendn[]);
    <%=obj.BlockId + '_con'%>::axi_xstrb_t be_beat;
    int nbeats;
    int nbe_beat;
    int nbe_xfr;
    int idx, bidx;

    nbeats   = be.size();
    nbe_beat = (<%=obj.BlockId + '_con'%>::WXDATA/8);
    nbe_xfr  = nbeats * nbe_beat;

    be_lendn = new[nbe_xfr];
    //`uvm_info("REF", $sformatf("nbeats = %0d nbe_beat = %0d nbe_xfr = %0d", nbeats, nbe_beat, nbe_xfr), UVM_HIGH);
    
    for(idx = 0; idx < nbeats; idx++) begin
        be_beat = be[idx];
        //`uvm_info("REF", $sformatf("STROBE: Bus Format[%0d]  = %9h", idx, be[idx]), UVM_HIGH);
        for(bidx = 0; bidx < nbe_beat; bidx++) begin
            int nidx = (idx * nbe_beat) + bidx;

            be_lendn[nidx] = be_beat[bidx];
            //`uvm_info("REF", $sformatf("STROBE: Byte Format[%2d] = %2h",nidx, be_lendn[nidx]), UVM_HIGH);
        end
    end
    
endfunction: pack_be_lendn
