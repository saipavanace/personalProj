
class compressible_fifo #(int D = 64, int W = 6);

    //Fully assoc victim buffer
    bit [W-1:0] victim_buffer[$];
    //Switch to control victim_buffer going from empty to full = 0
    //and full to empty = 1
    bit emptying_vbuf;

    //set if victim buffer is full
    bit vbuf_full;

    extern function new(string name = "victim_buffer");

    //Class interface methods
    extern function get_push_pop_info(input bit [W-1:0] push_ptr,
                                      output bit m_comp, output bit m_push,
                                      output bit[($ceil($ln(W))-1):0] m_comp_id);
    extern function check_output(bit m_comp, bit m_push, bit [($ceil($ln(W))-1):0] m_comp_id,
                                 bit [W-1:0] pop_ptr, bit [W-1:0] push_ptr, bit full); 

    //Helper methods
    extern function bit[($ceil($ln(W))-1):0] get_comp_id(bit head = 1'b0,
                                                         output bit [W-1:0] pop_ptr);
 
endclass: compressible_fifo

function compressible_fifo::new(string name = "victim_buffer");
    $display("%0t new(): %s class constructed", $time, name);
endfunction: new

function compressible_fifo::get_push_pop_info(input bit [W-1:0] push_ptr,
                                              output bit m_comp, output bit m_push,
                                              output bit[($ceil($ln(W))-1):0] m_comp_id);
    bit [W-1:0] pop_ptr;
    $timeformat(-9, 2, " ns", 10);

    if(victim_buffer.size() == 0) begin
        emptying_vbuf = 1'b0;
        m_push = 1'b1;
        m_comp = 1'b0;
        $display("%0t get_push_pop_info(): setting push signal one first entry", $time);

    end else if((victim_buffer.size() < D) && (!emptying_vbuf)) begin
       //70% push 25% random compress pop 5% head removed
       randcase
           60: begin
                   m_push = 1'b1;
                   m_comp = 1'b0;
                   $display("%0t get_push_pop_info(): setting push signal, switch:%b",
                   $time, emptying_vbuf);
               end
           30: begin
                   m_push = 1'b0;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b0, pop_ptr);
                   $display("%0t get_push_pop_info(): setting pop signal, comp_id:%0d, switch:%b",
                   $time, m_comp_id, emptying_vbuf);
               end
            5: begin
                   m_push = 1'b1;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b1, pop_ptr);
                   $display("%0t get_push_pop_info(): push & head poped out, comp_id: %0d, switch: %b",
                   $time, m_comp_id, emptying_vbuf);
               end
            5: begin
                   m_push = 1'b1;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b0, pop_ptr);
                   $display("%0t get_push_pop_info(): push/pop, comp_id: %0d, switch:%b",
                   $time, m_comp_id, emptying_vbuf);
               end
       endcase
    end else if(victim_buffer.size() == D)begin 

        if(!emptying_vbuf) begin
            m_push = 1'b1;
            m_comp = 1'b1;
            m_comp_id = get_comp_id(1'b1, pop_ptr);
            vbuf_full = 1'b1;
            $display("%0t get_push_pop_info(): setting push/pop signal on full case, comp_id: %0d", $time, m_comp_id);
        end else begin
            m_push = 1'b0;
            m_comp = 1'b1;
            m_comp_id = get_comp_id(1'b1, pop_ptr);
            vbuf_full = 1'b0;
            $display("%0t get_push_pop_info(): setting pop signal on full case, comp_id: %0d", $time, m_comp_id);
        end

        emptying_vbuf = 1'b1;
    end else if((victim_buffer.size() < D) && (emptying_vbuf)) begin
        randcase
           30: begin
                   m_push = 1'b1;
                   m_comp = 1'b0;
                   $display("%0t get_push_pop_info(): setting push signal, switch:%b",
                   $time, emptying_vbuf);
               end
           60: begin
                   m_push = 1'b0;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b0, pop_ptr);
                   $display("%0t get_push_pop_info(): setting pop signal, comp_id:%0d, switch:%b",
                   $time, m_comp_id, emptying_vbuf);
               end
            5: begin
                   m_push = 1'b1;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b0, pop_ptr);
                   $display("%0t get_push_pop_info(): push/pop, comp_id: %0d, switch:%b",
                   $time, m_comp_id, emptying_vbuf);
               end
            5: begin
                   m_push = 1'b1;
                   m_comp = 1'b1;
                   m_comp_id = get_comp_id(1'b1, pop_ptr);
                   $display("%0t get_push_pop_info(): push & head poped out, comp_id: %0d, switch: %b",
                   $time, m_comp_id, emptying_vbuf);
               end
        endcase
    end

    //Push entry to victim buffer if entry is sucessfull
    if(m_push) begin
        if((victim_buffer.size() == D -1) && (vbuf_full)) begin
            victim_buffer.push_front(pop_ptr);
            $display("%0t get_push_pop_info(): on full case, pushing 0x%h current pop_ptr to front of queue",
            $time, pop_ptr);
        end else begin
            victim_buffer.push_front(push_ptr);
            $display("%0t get_push_pop_info(): pushing 0x%h ptr to front of queue", $time, push_ptr);
        end
    end
endfunction: get_push_pop_info

//Returns Id of deleted entry, 
//set head = 1 to remove head pointer
function bit [($ceil($ln(compressible_fifo::W)-1)):0] compressible_fifo::get_comp_id(bit head = 1'b0,
                                                                                     output bit [W-1:0] pop_ptr);
   int q_idx;
   bit [W-1:0] one_hot_val;
   int count;
   bit [($ceil($ln(W))-1):0] m_comp_id;

   $timeformat(-9, 2, " ns", 10);

   count = 0;
   if(!head) 
       q_idx = $urandom_range(0, victim_buffer.size()-1);
   else 
       q_idx = victim_buffer.size() - 1;

   one_hot_val = victim_buffer[q_idx];

   if(one_hot_val == 0) begin
       $display("%0t get_comp_id(): Tb_error pop_ptr in victim_buffer (%h) is invalid q_idx, head:%b", 
       one_hot_val, victim_buffer[q_idx], head);
       $error("one_hot_val cannot be 0");
       $finish();
   end

   while(one_hot_val != 1) begin
       count++;
       one_hot_val = one_hot_val >> 1;
   end

   if(!($cast(m_comp_id, count))) begin
       $error("Unable to cast");
       $finish();
   end

   //Assigning the pop pointer
   pop_ptr = victim_buffer[q_idx];

   //Deleting entry from the victim_buffer
   $display("%0t get_comp_id(): Deleting entry from victim buffer id:%0d index:%0d val:%h",
   $time, m_comp_id, q_idx, victim_buffer[q_idx]);
   victim_buffer.delete(q_idx);

   return(m_comp_id);
endfunction: get_comp_id

function compressible_fifo::check_output(bit m_comp, bit m_push, bit [($ceil($ln(W))-1):0] m_comp_id, 
                                         bit [W-1:0] pop_ptr, bit [W-1:0] push_ptr, bit full);
    $timeformat(-9, 2, " ns", 10);

    //Check{}: Full asserted correctly
    if(full) begin
        if(victim_buffer.size() == D) begin
            $display("%0t check_output(): Victim buffer full asserted correctly, victim_buffer depth: %0d",
            $time, victim_buffer.size());
        end else begin
            $error("check_output(): Victim buffer full assertion unexpected, victim_buffer depth: %0d",
            victim_buffer.size());
            $finish();
        end
    end

    if(victim_buffer.size() > D) begin
        $error("check_output(): Victim buffer is overflowing, this isunexpected, victim_buffer depth: %0d",
        victim_buffer.size());
        $finish();
    end

    //Check{}: push pointer is always unique
    //Making sure value pushed in previous clock cycle was unique
    if(m_push) begin
        int tmpq[$];

        tmpq = victim_buffer.find_index(item) with (item == victim_buffer[0]);
        if(tmpq.size() > 1) begin
            foreach(tmpq[ridx]) begin
                $display("%0t check_output(): duplicate on index %0d val: %b",$time,  ridx, tmpq[ridx]);
            end
            $error("check_output(): Multiple entries with same push_ptr() val: %b", push_ptr);
            $finish();
        end
    end

    //Check{}: pop pointer always points to head
    if(m_comp && (victim_buffer.size() != 0)) begin
        int tmpq[$];

        if(pop_ptr == victim_buffer[(victim_buffer.size()-1)]) begin
            $display("%0t check_output(): Victim buffer pointing to correct entry %b size: %0d",
            $time, victim_buffer[(victim_buffer.size()-1)], (victim_buffer.size()-1));

        end else begin
            tmpq = victim_buffer.find_index(item) with (item == pop_ptr);

            if(tmpq.size() == 0) begin
                $display("%0t check_output(): {ACT}:%b does not exist in victim buffer {EXP}:%b",
                $time, pop_ptr, victim_buffer[victim_buffer.size()-1]);

            end else if(tmpq.size() == 1)begin
                $display("%0t check_output(): {ACT}:%b pop ptr is not the head entry in victim buffer; {ACT}:%0d {EXP}:%0d",
                $time, pop_ptr, tmpq[0], (victim_buffer.size()-1));
                
            end else begin
                $error("check_output(): TB_error, Multiple entries with same ptr detected");
                $finish();
            end

            $error("check_output() Victim buffer pointing to wrong entry {ACT}:%b {EXP}:%b", 
            pop_ptr, victim_buffer[(victim_buffer.size()-1)]);
            $finish();
        end 
    end

endfunction: check_output

interface compressible_fifo_if #(parameter int D = 64,
                                 parameter int W = 6)
                                (input bit clk,
                                 input bit reset);
    wire compress;
    wire [(($ceil($ln(W)))-1):0] compress_id;
    wire push;
    wire full;
    wire [W-1:0] pop_ptr;
    wire [W-1:0] push_ptr;
/*
    clocking cp @(posedge clk);
        output compress;
        output push;
        output compress_id;
    endclocking

    clocking cn @(negedge clk);
        input compress;
        input push;
        input compress_id;
        input full;
        input pop_ptr, push_ptr;
    endclocking

    modport tb (clocking cp);

    modport mon (clocking cn);
*/    
endinterface: compressible_fifo_if

module tb_top();
    localparam int DEPTH  = 8;
    localparam int WIDTH  = DEPTH;
    localparam int NUM_OP = 3000; 

    logic clk, rst;

    //units unit 
    logic compress, push;
    logic [($ceil($ln(WIDTH))-1):0] compress_id;
    wire full;
    wire [WIDTH-1:0] pop_ptr, push_ptr;
    wire [WIDTH-1:0] validvec;


    compressible_fifo_if #(DEPTH, WIDTH) if0 (clk, rst);

    no_project_name__dce0__dirm__SnoopOwnerSharer1_victim_buff_ptr u_dut(
        .clk(clk),
        .reset_n(rst),
        .compress(compress),
        .compress_id(compress_id),
        .push(push),
        .full(full),
        .pop_pointer(pop_ptr),
        .push_pointer(push_ptr),
        .validvec(validvec)
    );

    initial begin
      clk <= 1'b0;
      forever 
          #5 clk <= ~clk;
    end

    initial begin
        rst <= 1'b1;
        @(posedge clk);
        rst <= 1'b0;

        repeat(2) @(posedge clk);

        rst <= 1'b1;
    end

    initial begin
        $vcdpluson;
    end

    //TB & RTL interface logic
    initial begin
        compressible_fifo #(DEPTH, WIDTH) m_obj;
        m_obj = new();
       
        //init values
        push <= 1'b0;
        compress_id <= 0;
        compress <= 1'b0;
 
        repeat(2) @(posedge clk);
        @(posedge rst);

        fork: b0
            begin
                for(int i = 0; i < NUM_OP; i++) begin
                    @(negedge clk);
                    #1ns;
                    m_obj.get_push_pop_info(push_ptr, compress, push, compress_id);
                end
            end
            begin
                forever begin
                    @(negedge clk);
                    m_obj.check_output(compress, push, compress_id, pop_ptr, push_ptr, full);
                end
            end
        join_any
        disable b0;

        $display("************");
        $display("TEST PASSED");
        $display("************");
        $finish();
    end

endmodule: tb_top;
