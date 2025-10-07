//=====================================================================================================================================
// uvm_sequence <-- svt_axi_master_base_sequence <-- svt_dvm_seq 
//This sequnce use to generate atomic txn 
//====================================================================================================================================
class svt_dvm_seq extends svt_axi_ace_master_dvm_base_sequence;

    rand int unsigned sequence_length = 10;
    rand svt_axi_transaction::dvm_message_enum dvm_msg_type;
    int dvmsync;
    int dvmnonsync;
    int tlbi_wt = 0;
    int bpi_wt = 0;
    int pici_wt = 0;
    int vici_wt = 0;
    int hint_wt = 0;
    int singlepart_dvmnonsync,multipart_dvmnonsync;
    int OnePart_dvm,TwoPart_dvm;
    svt_axi_ace_master_dvm_base_sequence dvm_txn[];
    svt_axi_ace_master_multipart_dvm_sequence dvm_multipart;
   
     `svt_xvm_object_utils(svt_dvm_seq)
     `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
     function new(string name = "svt_dvm_seq");
       super.new(name);
     endfunction: new
   
     virtual task body();
        if(!$value$plusargs("singlepart_dvmnonsync=%d",singlepart_dvmnonsync)) begin
            singlepart_dvmnonsync=dvmnonsync;
        end
        if(!$value$plusargs("multipart_dvmnonsync=%d",multipart_dvmnonsync)) begin
            multipart_dvmnonsync=0;
        end

        OnePart_dvm = sequence_length * (dvmsync+singlepart_dvmnonsync) / (dvmsync+singlepart_dvmnonsync+multipart_dvmnonsync);    
        if (multipart_dvmnonsync==0) begin 
            TwoPart_dvm = sequence_length * (multipart_dvmnonsync) / (dvmsync+singlepart_dvmnonsync+multipart_dvmnonsync);    
        end else begin
            TwoPart_dvm = 10 * (multipart_dvmnonsync) ;    
        end
        `uvm_info(get_full_name(), $psprintf("Entered body ... dvmsync=%0d dvmnonsync=%0d sequence_length=%0d OnePart_dvm=%0d TwoPart_dvm=%0d singlepart_dvmnonsync:%0d,multipart_dvmnonsync:%0d", dvmsync, dvmnonsync, sequence_length,OnePart_dvm,TwoPart_dvm,singlepart_dvmnonsync,multipart_dvmnonsync), UVM_LOW)
        dvm_txn = new[OnePart_dvm];
        
        if(!$value$plusargs("tlbi_wt=%d", tlbi_wt)) tlbi_wt = 1;
        if(!$value$plusargs("bpi_wt=%d", bpi_wt))   bpi_wt = 1;
        if(!$value$plusargs("pici_wt=%d", pici_wt)) pici_wt = 1;
        if(!$value$plusargs("vici_wt=%d", vici_wt)) vici_wt = 1;
        if(!$value$plusargs("hint_wt=%d", hint_wt)) hint_wt = 1;

        `uvm_info(get_full_name(), $psprintf("Entered body ... dvmsync=%0d dvmnonsync=%0d tlbi_wt=%0d bpi_wt=%0d pici_wt=%0d vici_wt=%0d hint_wt=%0d", dvmsync, dvmnonsync, tlbi_wt, bpi_wt, pici_wt, vici_wt, hint_wt), UVM_LOW)
    
        fork
           for(int j=0; j<dvm_txn.size(); j++) begin
             automatic int i = j;
               dvm_txn[i] = svt_axi_ace_master_dvm_base_sequence::type_id::create($psprintf("dvm_txn_%0d", i));
               dvm_txn[i].seq_xact_type=svt_axi_transaction::DVMMESSAGE;
               randcase
                   tlbi_wt : dvm_txn[i].dvm_message_type = 3'b000;  //NON-SYNC
                   bpi_wt  : dvm_txn[i].dvm_message_type = 3'b001;  //NON-SYNC
                   pici_wt : dvm_txn[i].dvm_message_type = 3'b010;  //NON-SYNC
                   vici_wt : dvm_txn[i].dvm_message_type = 3'b011;  //NON-SYNC
                   dvmsync : dvm_txn[i].dvm_message_type = 3'b100;  //SYNC
                   //hint_wt : dvm_txn[i].dvm_message_type = 3'b110;  //NON-SYNC
               endcase
               `uvm_info(get_full_name(), $psprintf("Starting svt_axi_ace_master_dvm_base_sequence dvm_txn[i].dvm_message_type :%0b",dvm_txn[i].dvm_message_type), UVM_LOW)
               dvm_txn[i].start(p_sequencer);
           end
        join_none
        wait fork;
        fork
           for(int i=0; i<TwoPart_dvm; i++) begin
               dvm_multipart = svt_axi_ace_master_multipart_dvm_sequence::type_id::create($psprintf("dvm_multipart"));
               dvm_multipart.seq_xact_type=svt_axi_transaction::DVMMESSAGE;
               randcase
                   tlbi_wt : dvm_multipart.dvm_message_type = 3'b000;  //NON-SYNC
                   bpi_wt  : dvm_multipart.dvm_message_type = 3'b001;  //NON-SYNC
                   pici_wt : dvm_multipart.dvm_message_type = 3'b010;  //NON-SYNC
                   vici_wt : dvm_multipart.dvm_message_type = 3'b011;  //NON-SYNC
                   //dvmsync : dvm_multipart.dvm_message_type = 3'b100;    //SYNC is single-part only
                   //hint_wt : dvm_multipart.dvm_message_type = 3'b110;  //NON-SYNC
               endcase
           `uvm_info("DEBUG_4", $psprintf("Starting svt_axi_ace_master_dvm_base_sequence dvm_multipart.dvm_message_type :%0b",dvm_multipart.dvm_message_type), UVM_LOW)

               dvm_multipart.start(p_sequencer);
             end
        join
    
        `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
    
     endtask:body
   
   endclass:svt_dvm_seq
   
