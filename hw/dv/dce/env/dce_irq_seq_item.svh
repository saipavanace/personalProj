////////////////////////////////////////////
//
//DCE irq interface for correctible/uncorrectible errors
//IRQ interface
////////////////////////////////////////////

class <%=obj.BlockId%>_irq_seq_item extends uvm_sequence_item;

   `uvm_object_utils(<%=obj.BlockId%>_irq_seq_item)

   typedef enum int {
       COR_ERR, UNCOR_ERR, MULTI_ERR} err_type_t;

   //correctible errors
   //uncorrectible errors
<% if(obj.AiuInfo.length > 1) { %>
   bit [<%=obj.AiuInfo.length -1 %>:0]  aiu_cor_irq_vld;
   bit [<%=obj.AiuInfo.length -1 %>:0]  aiu_uncor_irq_vld;
<% } else { %>
   bit aiu_cor_irq_vld;
   bit aiu_uncor_irq_vld;
<% } %>

<% if(obj.BridgeAiuInfo.length > 1) { %>
   bit [<%=obj.BridgeAiuInfo.length - 1%>:0] cbi_cor_irq_vld;
   bit [<%=obj.BridgeAiuInfo.length - 1%>:0] cbi_uncor_irq_vld;
<% } else { %>
   bit cbi_cor_irq_vld;
   bit cbi_uncor_irq_vld;
<% } %>

<% if(obj.DceInfo.nDces > 1) { %>
   bit [<%=obj.DceInfo.nDces -1%>:0]         dce_cor_irq_vld;
   bit [<%=obj.DceInfo.nDces -1%>:0]         dce_uncor_irq_vld;
<% } else { %>
   bit dce_cor_irq_vld;
   bit dce_uncor_irq_vld;
<% } %>

<% if(obj.DmiInfo.length > 1) { %>
   bit [<%=obj.DmiInfo.length - 1%>:0]       dmi_cor_irq_vld;
   bit [<%=obj.DmiInfo.length - 1%>:0]       dmi_uncor_irq_vld;
<% } else { %>
   bit dmi_cor_irq_vld;
   bit dmi_uncor_irq_vld;
<% } %>

   //Config bits indicating error interrupts is enabled of not
   //default enabled
   bit cor_err_intr_en, uncor_err_intr_en;

   //response correctible/uncorrectible error irq, output of DCE0
   //set by the driver
   bit correctible_error_irq, uncorrectible_error_irq;
   
   //Static ID's foreach agent 
   int aiu_ids[$], dce_ids[$], dmi_ids[$];
   //All ID's included expect DCE0
   int ids_list[$];

   //Errors injected on agents
   int cor_errors_inj[$];
   int uncor_errors_inj[$];

   //Random values
   rand int num_errors;
   rand err_type_t err_type;

   constraint num_errors_c { 
       num_errors inside {1,2};
   }

   //API metohds
   extern function new(string name = "<%=obj.BlockId%>_irq_seq_item");
   extern function void post_randomize();
   extern function void deassert_irqs();
   extern function string convert2string();

   //internal methods
   extern function void collect_config_info();
   extern function void assign_error(int id, err_type_t tmp_err);
   extern function void assign_aiu_irq(int idx, err_type_t tmp_err);
   extern function void assign_cbi_irq(int idx, err_type_t tmp_err);
   extern function void assign_dce_irq(int idx, err_type_t tmp_err);
   extern function void assign_dmi_irq(int idx, err_type_t tmp_err);

endclass: <%=obj.BlockId%>_irq_seq_item

function <%=obj.BlockId%>_irq_seq_item::new(string name = "<%=obj.BlockId%>_irq_seq_item");
    super.new(name);

    collect_config_info();
endfunction: new

//Fill up all static queues
function void <%=obj.BlockId%>_irq_seq_item::collect_config_info();

    for(int i = 0; i < ncoreConfigInfo::NUM_AIUS; i++) begin
        aiu_ids.push_back(i);
        ids_list.push_back(i);
    end

    //Excluding DCE0
    for(int i = 0; i < ncoreConfigInfo::NUM_DCES; i++) begin
        if(i != 0) begin
            dce_ids.push_back((ncoreConfigInfo::NUM_AIUS + i));
            ids_list.push_back((ncoreConfigInfo::NUM_AIUS + i));
        end
    end

    for(int i = 0; i < ncoreConfigInfo::NUM_DMIS; i++) begin
        dmi_ids.push_back((ncoreConfigInfo::NUM_AIUS + ncoreConfigInfo::NUM_DCES + i));
        ids_list.push_back((ncoreConfigInfo::NUM_AIUS + ncoreConfigInfo::NUM_DCES + i));
    end
endfunction: collect_config_info

//assign correctible/uncorrectible errors
function void <%=obj.BlockId%>_irq_seq_item::post_randomize();
    ids_list.shuffle();
    if(err_type == MULTI_ERR) begin
        for(int i = 0; i < (num_errors * 2); i++) begin
            if(i < num_errors)
                assign_error(ids_list[i], COR_ERR);
            else
                assign_error(ids_list[i], UNCOR_ERR);
        end
    end else begin
        for(int i = 0; i < num_errors; i++) begin
            assign_error(ids_list[i], err_type);
        end
    end
endfunction: post_randomize

function void <%=obj.BlockId%>_irq_seq_item::assign_error(int id, err_type_t tmp_err);
    int exists[$];
    string s;
    int act_id;

    exists = aiu_ids.find(val) with (val == id);
    if(exists.size()) begin
        if(exists[0] < <%=obj.AiuInfo.length%>)
            assign_aiu_irq(exists[0], tmp_err);
        else begin
           act_id = exists[0] - <%=obj.AiuInfo.length%>;
            assign_cbi_irq(act_id, tmp_err);
        end
    end else begin
        exists = dce_ids.find(val) with (val == id);
        if(exists.size()) begin
            act_id = exists[0] - <%=obj.AiuInfo.length + obj.BridgeAiuInfo.length%>;
            assign_dce_irq(act_id, tmp_err);
        end else begin
            exists = dmi_ids.find(val) with (val == id);
            if(exists.size()) begin
                act_id = exists[0] - <%=obj.AiuInfo.length + obj.BridgeAiuInfo.length +
                                        obj.DceInfo.nDces%>;
                exists = dmi_ids.find(val) with (val == id);
                assign_dmi_irq(act_id, tmp_err);
            end else 
                `uvm_fatal("irq_seq_item", $psprintf("TbError Unexpected agent:%0d requested error", id))
        end
   end

   //Sanity-Check
   if((exists.size() > 1) || (exists.size() == 0)) begin
       `uvm_fatal("irq_seq_item", $psprintf("TbError: exists.size():%0d", exists.size()))
   end else begin
       if(tmp_err == COR_ERR)
           cor_errors_inj.push_back(id);
       else
           uncor_errors_inj.push_back(id);
   end

endfunction: assign_error

function void <%=obj.BlockId%>_irq_seq_item::assign_aiu_irq(int idx, err_type_t tmp_err);
<% if(obj.AiuInfo.length > 1) { %>
    if(tmp_err == COR_ERR)
        aiu_cor_irq_vld[idx]   = 1'b1;
    else begin
        aiu_uncor_irq_vld[idx] = 1'b1;
    end
<% } else { %>
    if(tmp_err == COR_ERR)
        aiu_cor_irq_vld   = 1'b1;
    else begin
        aiu_uncor_irq_vld = 1'b1;
    end
<% } %>
endfunction: assign_aiu_irq

function void <%=obj.BlockId%>_irq_seq_item::assign_cbi_irq(int idx, err_type_t tmp_err);
<% if(obj.BridgeAiuInfo.length > 1) { %>
    if(tmp_err == COR_ERR)
        cbi_cor_irq_vld[idx]   = 1'b1;
    else
        cbi_uncor_irq_vld[idx] = 1'b1;
<% } else { %>
    if(tmp_err == COR_ERR)
        cbi_cor_irq_vld  = 1'b1;
    else
        cbi_uncor_irq_vld = 1'b1;
<% } %>

endfunction: assign_cbi_irq

function void <%=obj.BlockId%>_irq_seq_item::assign_dce_irq(int idx, err_type_t tmp_err);
<% if(obj.DceInfo.nDces > 1) { %>
    if(tmp_err == COR_ERR)
        dce_cor_irq_vld[idx]   = 1'b1;
    else
        dce_uncor_irq_vld[idx] = 1'b1;
<% } else { %>
    if(tmp_err == COR_ERR)
        dce_cor_irq_vld   = 1'b1;
    else
        dce_uncor_irq_vld = 1'b1;
<% } %>

endfunction: assign_dce_irq

function void <%=obj.BlockId%>_irq_seq_item::assign_dmi_irq(int idx, err_type_t tmp_err);
<% if(obj.DmiInfo.length > 1) { %>
    if(tmp_err == COR_ERR)
        dmi_cor_irq_vld[idx]   = 1'b1;
    else
        dmi_uncor_irq_vld[idx] = 1'b1;
<% } else { %>
    if(tmp_err == COR_ERR)
        dmi_cor_irq_vld   = 1'b1;
    else
        dmi_uncor_irq_vld = 1'b1;
<% } %>
endfunction: assign_dmi_irq

function void <%=obj.BlockId%>_irq_seq_item::deassert_irqs();
    //Correctible errors
    aiu_cor_irq_vld = 0;
    cbi_cor_irq_vld = 0;
    dce_cor_irq_vld = 0;
    dmi_cor_irq_vld = 0;

    //Correctible errors
    aiu_uncor_irq_vld = 0;
    cbi_uncor_irq_vld = 0;
    dce_uncor_irq_vld = 0;
    dmi_uncor_irq_vld = 0;
    
    cor_errors_inj.delete();
    uncor_errors_inj.delete();

endfunction: deassert_irqs

function string <%=obj.BlockId%>_irq_seq_item::convert2string();
    string s;

    $sformat(s, "%s aiu_cor_irq:0x%0h cbi_cor_irq:0x%0h dce_cor_irq:0x%0h dmi_cor_irq:0x%0h",
        s, aiu_cor_irq_vld, cbi_cor_irq_vld, dce_cor_irq_vld, dmi_cor_irq_vld);
    $sformat(s, "%s aiu_uncor_irq:0x%0h cbi_uncor_irq:0x%0h dce_uncor_irq:0x%0h dmi_uncor_irq:0x%0h",
        s, aiu_uncor_irq_vld, cbi_uncor_irq_vld, dce_uncor_irq_vld, dmi_uncor_irq_vld);
    $sformat(s, "%s correctible_error_irq:%b uncorrectible_error_irq:%b", 
             s, correctible_error_irq, uncorrectible_error_irq);

   $sformat(s, "%s correctible error agent-ids:", s);
   foreach(cor_errors_inj[idx]) begin
       $sformat(s, "%s %0d", s, cor_errors_inj[idx]);
   end
   $sformat(s, "%s uncorrectible error agent-ids:", s);
   foreach(uncor_errors_inj[idx]) begin
       $sformat(s, "%s %0d", s, uncor_errors_inj[idx]);
   end
   
   return(s);
endfunction: convert2string

