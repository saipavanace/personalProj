

module tb_top();

reg clk_clk;
reg clk_reset_n;

logic pass;
logic           push_0_valid;
logic           push_0_ready;
logic [79:0]	push_0_data;
logic           push_1_valid;
logic           push_1_ready;
logic [79:0]	push_1_data;
logic           push_2_valid;
logic           push_2_ready;
logic [79:0]	push_2_data;
logic           push_3_valid;
logic           push_3_ready;
logic [79:0]	push_3_data;
logic           push_4_valid;
logic           push_4_ready;
logic [79:0]	push_4_data;
logic           push_5_valid;
logic           push_5_ready;
logic [79:0]	push_5_data;
logic           push_6_valid;
logic           push_6_ready;
logic [79:0]	push_6_data;
logic           push_7_valid;
logic           push_7_ready;
logic [79:0]	push_7_data;
logic           push_8_valid;
logic           push_8_ready;
logic [79:0]	push_8_data;
logic pop_0_valid;
logic pop_0_ready;
logic [79:0]	pop_0_data;
logic pop_1_valid;
logic pop_1_ready;
logic [79:0]	pop_1_data;
logic pop_2_valid;
logic pop_2_ready;
logic [79:0]	pop_2_data;
logic pop_3_valid;
logic pop_3_ready;
logic [79:0]	pop_3_data;
logic pop_4_valid;
logic pop_4_ready;
logic [79:0]	pop_4_data;
logic pop_5_valid;
logic pop_5_ready;
logic [79:0]	pop_5_data;

bit [79:0] sent[$];

bit [79:0] send[$];
int i;
bit [79:0] received[$];





  Fifo_pack_d Fifo_pack_d (
    .push_0_valid(  push_0_valid),
    .push_0_ready(  push_0_ready),
    .push_0_data(   push_0_data),
    .push_1_valid(  push_1_valid),
    .push_1_ready(  push_1_ready),
    .push_1_data(   push_1_data),
    .push_2_valid(  push_2_valid),
    .push_2_ready(  push_2_ready),
    .push_2_data(   push_2_data),
    .push_3_valid(  push_3_valid),
    .push_3_ready(  push_3_ready),
    .push_3_data(   push_3_data),
    .push_4_valid(  push_4_valid),
    .push_4_ready(  push_4_ready),
    .push_4_data(   push_4_data),
    .push_5_valid(  push_5_valid),
    .push_5_ready(  push_5_ready),
    .push_5_data(   push_5_data),
    .push_6_valid(  push_6_valid),
    .push_6_ready(  push_6_ready),
    .push_6_data(   push_6_data),
    .push_7_valid(  push_7_valid),
    .push_7_ready(  push_7_ready),
    .push_7_data(   push_7_data),
    .push_8_valid(  push_8_valid),
    .push_8_ready(  push_8_ready),
    .push_8_data(   push_8_data),
    .pop_0_valid(pop_0_valid),
    .pop_0_ready(pop_0_ready),
    .pop_0_data(pop_0_data),
    .pop_1_valid(pop_1_valid),
    .pop_1_ready(pop_1_ready),
    .pop_1_data(pop_1_data),
    .pop_2_valid(pop_2_valid),
    .pop_2_ready(pop_2_ready),
    .pop_2_data(pop_2_data),
    .pop_3_valid(pop_3_valid),
    .pop_3_ready(pop_3_ready),
    .pop_3_data(pop_3_data),
    .pop_4_valid(pop_4_valid),
    .pop_4_ready(pop_4_ready),
    .pop_4_data(pop_4_data),
    .pop_5_valid(pop_5_valid),
    .pop_5_ready(pop_5_ready),
    .pop_5_data(pop_5_data),
    .clk(clk_clk),
    .reset_n(clk_reset_n),
    .test_en(test_en));
    

clocking ckb @ (posedge clk_clk);
	input    push_0_ready;
	output   push_0_valid;
	output   push_0_data;
  	input    push_1_ready;
	output   push_1_valid;
	output   push_1_data;
    input    push_2_ready;
	output   push_2_valid;
	output   push_2_data;
    input    push_3_ready;
	output   push_3_valid;
	output   push_3_data;
    input    push_4_ready;
	output   push_4_valid;
	output   push_4_data;
    input    push_5_ready;
	output   push_5_valid;
	output   push_5_data;
    input    push_6_ready;
	output   push_6_valid;
	output   push_6_data;
    input    push_7_ready;
	output   push_7_valid;
	output   push_7_data;
    input    push_8_ready;
	output   push_8_valid;
	output   push_8_data;
    output   pop_0_ready;
	input    pop_0_valid;
	input    pop_0_data;
    output   pop_1_ready;
	input    pop_1_valid;
	input    pop_1_data;
    output   pop_2_ready;
	input    pop_2_valid;
	input    pop_2_data;
    output   pop_3_ready;
	input    pop_3_valid;
	input    pop_3_data;
    output   pop_4_ready;
	input    pop_4_valid;
	input    pop_4_data;
    output   pop_5_ready;
	input    pop_5_valid;
	input    pop_5_data;

endclocking


clocking ckb2 @ (posedge clk_clk);
	input  push_0_ready;
	input  push_0_valid;
	input  push_0_data;
    input   pop_0_ready;
	input   pop_0_valid;
	input   pop_0_data;
    input   pop_1_ready;
	input   pop_1_valid;
	input   pop_1_data;
    input   pop_2_ready;
	input   pop_2_valid;
	input   pop_2_data;
    input   pop_3_ready;
	input   pop_3_valid;
	input   pop_3_data;
    input   pop_4_ready;
	input   pop_4_valid;
	input   pop_4_data;
    input   pop_5_ready;
	input   pop_5_valid;
	input   pop_5_data;
    input   push_1_valid;
    input   push_1_ready;
    input   push_1_data;
    input   push_2_valid;
    input   push_2_ready;
    input   push_2_data;
    input   push_3_valid;
    input   push_3_ready;
    input   push_3_data;
    input   push_4_valid;
    input   push_4_ready;
    input   push_4_data;
    input   push_5_valid;
    input   push_5_ready;
    input   push_5_data;
    input   push_6_valid;
    input   push_6_ready;
    input   push_6_data;
    input   push_7_valid;
    input   push_7_ready;
    input   push_7_data;
    input   push_8_valid;
    input   push_8_ready;
    input   push_8_data;

endclocking



initial begin
  clk_clk = 0;
  forever
  #5 clk_clk = ~clk_clk;
end


task send_stuff(input [9:0] stuff) ;
    ckb.push_0_valid <=1'b1;
    ckb.push_0_data <= stuff;
endtask

task stop_send() ;
    ckb.push_0_valid <=1'b0;
endtask
task pop_stuff() ;
    {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <= {5{1'b1}};
endtask

task stop_pop() ;
    ckb.pop_0_ready <= 1'b0;
    ckb.pop_1_ready <= 1'b0;
    ckb.pop_2_ready <= 1'b0;
    ckb.pop_3_ready <= 1'b0;
    ckb.pop_4_ready <= 1'b0;
    ckb.pop_5_ready  <= 1'b0;
endtask


always @ (posedge clk_clk) begin
    if(ckb2.pop_0_ready & ckb2.pop_0_valid) begin
        received.push_back(ckb2.pop_0_data);
    end
    if(ckb2.pop_1_ready & ckb2.pop_1_valid) begin
    received.push_back(ckb2.pop_1_data);
    end
    if(ckb2.pop_2_ready & ckb2.pop_2_valid) begin
    received.push_back(ckb2.pop_2_data);
    end
    if(ckb2.pop_3_ready & ckb2.pop_3_valid) begin
    received.push_back(ckb2.pop_3_data);
    end
    if(ckb2.pop_4_ready & ckb2.pop_4_valid) begin
    received.push_back(ckb2.pop_4_data);
    end
    if(ckb2.pop_5_ready & ckb2.pop_5_valid) begin
    received.push_back(ckb2.pop_5_data);
    end
end


task thing_to_send();
for (int i=0; i<100; i++) begin
    send.push_back($urandom_range(1000,0));
end

endtask

task set_ready();
randcase
        	1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b100000;
        	1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b110000;
        	1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b111000;
            1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b111100;
            1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b111110;
            1	: {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b111111;
            20   : {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <=	6'b000000;
endcase
endtask



task set_valids();
randcase
        	1	: {ckb.push_0_valid,ckb.push_1_valid,ckb.push_2_valid,ckb.push_3_valid,ckb.push_4_valid,ckb.push_5_valid,ckb.push_6_valid,ckb.push_7_valid,ckb.push_8_valid} <=	9'b111111111;
            1   : {ckb.push_0_valid,ckb.push_1_valid,ckb.push_2_valid,ckb.push_3_valid,ckb.push_4_valid,ckb.push_5_valid,ckb.push_6_valid,ckb.push_7_valid,ckb.push_8_valid} <=	9'b000000000;
endcase
endtask


initial begin

$vcdpluson;
thing_to_send();
$monitor();

{ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <= {6{1'b1}};
{ckb.push_0_valid,ckb.push_1_valid,ckb.push_2_valid,ckb.push_3_valid,ckb.push_4_valid,ckb.push_5_valid,ckb.push_6_valid,ckb.push_7_valid,ckb.push_8_valid} <=	9'b000000000;

pass=1;
i=0;

clk_reset_n =0;
#10;
clk_reset_n  = 1;
#20;
while (send.size() !=0) begin
@ckb begin
set_ready();

    if ($urandom_range(1000,0)) begin
    set_valids();
    ckb.push_0_data <= send[0];
    ckb.push_1_data <= send[1];
    ckb.push_2_data <= send[2];
    ckb.push_3_data <= send[3];
    ckb.push_4_data <= send[4];
    ckb.push_5_data <= send[5];
    ckb.push_6_data <= send[6];
    ckb.push_7_data <= send[7];
    ckb.push_8_data <= send[8];
    end
    if(ckb2.push_0_ready & ckb2.push_0_valid) begin
        sent.push_back(ckb2.push_0_data);
        send.pop_front();
        $display("0");
                i++;
    end
        if(ckb2.push_1_ready & ckb2.push_1_valid) begin
        sent.push_back(ckb2.push_1_data);
        send.pop_front();
                $display("1");
                i++;
    end
        if(ckb2.push_2_ready & ckb2.push_2_valid) begin
        sent.push_back(ckb2.push_2_data);
        send.pop_front();
                i++;
                        $display("2");

    end
        if(ckb2.push_3_ready & ckb2.push_3_valid) begin
        sent.push_back(ckb2.push_3_data);
        send.pop_front();
                i++;
                        $display("3");

    end
        if(ckb2.push_4_ready & ckb2.push_4_valid) begin
        sent.push_back(ckb2.push_4_data);
        send.pop_front();
                i++;
                        $display("4");

    end
        if(ckb2.push_5_ready & ckb2.push_5_valid) begin
        sent.push_back(ckb2.push_5_data);
        send.pop_front();
                i++;
                        $display("5");

    end
        if(ckb2.push_6_ready & ckb2.push_6_valid) begin
        sent.push_back(ckb2.push_6_data);
        send.pop_front();
                i++;
                        $display("6");

    end
        if(ckb2.push_7_ready & ckb2.push_7_valid) begin
        sent.push_back(ckb2.push_7_data);
        send.pop_front();
                i++;
                        $display("7");

    end
        if(ckb2.push_8_ready & ckb2.push_8_valid) begin
        sent.push_back(ckb2.push_8_data);
        send.pop_front();
        i++;
                $display("8");

    end
end
end
@ckb begin {ckb.push_0_valid,ckb.push_1_valid,ckb.push_2_valid,ckb.push_3_valid,ckb.push_4_valid,ckb.push_5_valid,ckb.push_6_valid,ckb.push_7_valid,ckb.push_8_valid} <=	9'b000000000;
    {ckb.pop_0_ready,ckb.pop_1_ready,ckb.pop_2_ready,ckb.pop_3_ready,ckb.pop_4_ready,ckb.pop_5_ready} <= {6{1'b1}};
    end
#1000;
foreach(sent[i]) begin
    if (sent[i] != received[i]) begin
        pass=0;
        $display("failure");
        $display("%0h",sent[i]);
        $display("%0h",received[i]);
        $display(i);
        $finish;
    end
end
$display ("pass?%b",pass);
#200;
$finish;
end





endmodule