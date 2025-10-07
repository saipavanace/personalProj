module tb;


wire	loop_out_cxs_in_valid;
reg	loop_out_cxs_in_ready;
wire	[511:0]	loop_out_cxs_in_data;
reg	cxs_out_loop_in_valid;
wire	cxs_out_loop_in_ready;
reg	[511:0]	cxs_out_loop_in_data;
reg	GIULCSTR_LoopBackEn_out;
reg	GIULCSTR_NearLoopEn_out;
reg	GIULCSTR_FarLoopEn_out;
reg	GIULCSTR_RepeatMode_out;
reg	[1:0]	GIULCSTR_ShiftStart_out;
reg	[1:0]	GIULCSTR_DelayCounter_out;
reg	[1:0]	GIULCSTR_NumberOfTest_out;
reg	GIULCSTR_MatchStatus_out;
reg	[3:0]	GIULCSTR_MismatchPosition_out;
reg	[16:0]	GIULCSTR_LoopCycleCounter_out;
wire	GIULCSTR_MatchStatus_in;
wire	GIULCSTR_MatchStatus_wr;
wire	[3:0]	GIULCSTR_MismatchPosition_in;
wire	GIULCSTR_MismatchPosition_wr;
wire	[16:0]	GIULCSTR_LoopCycleCounter_in;
wire	GIULCSTR_LoopCycleCounter_wr;
reg	[31:0]	GIULDSR_LoopStartDataValue_out;
reg	clk_clk;
reg	clk_reset_n;



reg [31:0] GIULDMSR0_FirstMismatchValue_out ;
reg [31:0] GIULDMSR1_FirstMismatchValue_out ;
reg [31:0] GIULDMSR2_FirstMismatchValue_out ;
reg [31:0] GIULDMSR3_FirstMismatchValue_out ;
reg [31:0] GIULDMSR4_FirstMismatchValue_out ;
reg [31:0] GIULDMSR5_FirstMismatchValue_out ;
reg [31:0] GIULDMSR6_FirstMismatchValue_out ;
reg [31:0] GIULDMSR7_FirstMismatchValue_out ;
reg [31:0] GIULDMSR8_FirstMismatchValue_out ;
reg [31:0] GIULDMSR9_FirstMismatchValue_out ;
reg [31:0] GIULDMSR10_FirstMismatchValue_out;
reg [31:0] GIULDMSR11_FirstMismatchValue_out;
reg [31:0] GIULDMSR12_FirstMismatchValue_out;
reg [31:0] GIULDMSR13_FirstMismatchValue_out;
reg [31:0] GIULDMSR14_FirstMismatchValue_out;
reg [31:0] GIULDMSR15_FirstMismatchValue_out;
wire [31:0] GIULDMSR0_FirstMismatchValue_in;
wire [31:0] GIULDMSR1_FirstMismatchValue_in;
wire [31:0] GIULDMSR2_FirstMismatchValue_in;
wire [31:0] GIULDMSR3_FirstMismatchValue_in;
wire [31:0] GIULDMSR4_FirstMismatchValue_in;
wire [31:0] GIULDMSR5_FirstMismatchValue_in;
wire [31:0] GIULDMSR6_FirstMismatchValue_in;
wire [31:0] GIULDMSR7_FirstMismatchValue_in;
wire [31:0] GIULDMSR8_FirstMismatchValue_in;
wire [31:0] GIULDMSR9_FirstMismatchValue_in;
wire [31:0] GIULDMSR10_FirstMismatchValue_in;
wire [31:0] GIULDMSR11_FirstMismatchValue_in;
wire [31:0] GIULDMSR12_FirstMismatchValue_in;
wire [31:0] GIULDMSR13_FirstMismatchValue_in;
wire [31:0] GIULDMSR14_FirstMismatchValue_in;
wire [31:0] GIULDMSR15_FirstMismatchValue_in;
wire GIULDMSR0_FirstMismatchValue_wr;
wire GIULDMSR1_FirstMismatchValue_wr;
wire GIULDMSR2_FirstMismatchValue_wr;
wire GIULDMSR3_FirstMismatchValue_wr;
wire GIULDMSR4_FirstMismatchValue_wr;
wire GIULDMSR5_FirstMismatchValue_wr;
wire GIULDMSR6_FirstMismatchValue_wr;
wire GIULDMSR7_FirstMismatchValue_wr;
wire GIULDMSR8_FirstMismatchValue_wr;
wire GIULDMSR9_FirstMismatchValue_wr;
wire GIULDMSR10_FirstMismatchValue_wr;
wire GIULDMSR11_FirstMismatchValue_wr;
wire GIULDMSR12_FirstMismatchValue_wr;
wire GIULDMSR13_FirstMismatchValue_wr;
wire GIULDMSR14_FirstMismatchValue_wr;
wire GIULDMSR15_FirstMismatchValue_wr;


chiplet1_giu_cxs_loopback_controller_a dut (
                                                .loop_out_cxs_in_valid(loop_out_cxs_in_valid),
                                                .loop_out_cxs_in_ready(loop_out_cxs_in_ready),
                                                .loop_out_cxs_in_data(loop_out_cxs_in_data),
                                                .cxs_out_loop_in_valid(cxs_out_loop_in_valid),
                                                .cxs_out_loop_in_ready(cxs_out_loop_in_ready),
                                                .cxs_out_loop_in_data(cxs_out_loop_in_data),
                                                .GIULCSTR_LoopBackEn_out(GIULCSTR_LoopBackEn_out),
                                                .GIULCSTR_NearLoopEn_out(GIULCSTR_NearLoopEn_out),
                                                .GIULCSTR_FarLoopEn_out(GIULCSTR_FarLoopEn_out),
                                                .GIULCSTR_RepeatMode_out(GIULCSTR_RepeatMode_out),
                                                .GIULCSTR_ShiftStart_out(GIULCSTR_ShiftStart_out),
                                                .GIULCSTR_DelayCounter_out(GIULCSTR_DelayCounter_out),
                                                .GIULCSTR_NumberOfTest_out(GIULCSTR_NumberOfTest_out),
                                                .GIULCSTR_MatchStatus_out(GIULCSTR_MatchStatus_out),
                                                .GIULCSTR_MismatchPosition_out(GIULCSTR_MismatchPosition_out),
                                                .GIULCSTR_LoopCycleCounter_out(GIULCSTR_LoopCycleCounter_out),
                                                .GIULCSTR_MatchStatus_in(GIULCSTR_MatchStatus_in),
                                                .GIULCSTR_MatchStatus_wr(GIULCSTR_MatchStatus_wr),
                                                .GIULCSTR_MismatchPosition_in(GIULCSTR_MismatchPosition_in),
                                                .GIULCSTR_MismatchPosition_wr(GIULCSTR_MismatchPosition_wr),
                                                .GIULCSTR_LoopCycleCounter_in(GIULCSTR_LoopCycleCounter_in),
                                                .GIULCSTR_LoopCycleCounter_wr(GIULCSTR_LoopCycleCounter_wr),
                                                .GIULDSR_LoopStartDataValue_out(GIULDSR_LoopStartDataValue_out),
                                                .GIULDMSR0_FirstMismatchValue_out(GIULDMSR0_FirstMismatchValue_out ),
                                                .GIULDMSR1_FirstMismatchValue_out(GIULDMSR1_FirstMismatchValue_out ),
                                                .GIULDMSR2_FirstMismatchValue_out(GIULDMSR2_FirstMismatchValue_out ),
                                                .GIULDMSR3_FirstMismatchValue_out(GIULDMSR3_FirstMismatchValue_out ),
                                                .GIULDMSR4_FirstMismatchValue_out(GIULDMSR4_FirstMismatchValue_out ),
                                                .GIULDMSR5_FirstMismatchValue_out(GIULDMSR5_FirstMismatchValue_out ),
                                                .GIULDMSR6_FirstMismatchValue_out(GIULDMSR6_FirstMismatchValue_out ),
                                                .GIULDMSR7_FirstMismatchValue_out(GIULDMSR7_FirstMismatchValue_out ),
                                                .GIULDMSR8_FirstMismatchValue_out(GIULDMSR8_FirstMismatchValue_out ),
                                                .GIULDMSR9_FirstMismatchValue_out(GIULDMSR9_FirstMismatchValue_out ),
                                                .GIULDMSR10_FirstMismatchValue_out(GIULDMSR10_FirstMismatchValue_out),
                                                .GIULDMSR11_FirstMismatchValue_out(GIULDMSR11_FirstMismatchValue_out),
                                                .GIULDMSR12_FirstMismatchValue_out(GIULDMSR12_FirstMismatchValue_out),
                                                .GIULDMSR13_FirstMismatchValue_out(GIULDMSR13_FirstMismatchValue_out),
                                                .GIULDMSR14_FirstMismatchValue_out(GIULDMSR14_FirstMismatchValue_out),
                                                .GIULDMSR15_FirstMismatchValue_out(GIULDMSR15_FirstMismatchValue_out),
                                                .GIULDMSR0_FirstMismatchValue_in(GIULDMSR0_FirstMismatchValue_in ),
                                                .GIULDMSR1_FirstMismatchValue_in(GIULDMSR1_FirstMismatchValue_in ),
                                                .GIULDMSR2_FirstMismatchValue_in(GIULDMSR2_FirstMismatchValue_in ),
                                                .GIULDMSR3_FirstMismatchValue_in(GIULDMSR3_FirstMismatchValue_in ),
                                                .GIULDMSR4_FirstMismatchValue_in(GIULDMSR4_FirstMismatchValue_in ),
                                                .GIULDMSR5_FirstMismatchValue_in(GIULDMSR5_FirstMismatchValue_in ),
                                                .GIULDMSR6_FirstMismatchValue_in(GIULDMSR6_FirstMismatchValue_in ),
                                                .GIULDMSR7_FirstMismatchValue_in(GIULDMSR7_FirstMismatchValue_in ),
                                                .GIULDMSR8_FirstMismatchValue_in(GIULDMSR8_FirstMismatchValue_in ),
                                                .GIULDMSR9_FirstMismatchValue_in(GIULDMSR9_FirstMismatchValue_in ),
                                                .GIULDMSR10_FirstMismatchValue_in(GIULDMSR10_FirstMismatchValue_in),
                                                .GIULDMSR11_FirstMismatchValue_in(GIULDMSR11_FirstMismatchValue_in),
                                                .GIULDMSR12_FirstMismatchValue_in(GIULDMSR12_FirstMismatchValue_in),
                                                .GIULDMSR13_FirstMismatchValue_in(GIULDMSR13_FirstMismatchValue_in),
                                                .GIULDMSR14_FirstMismatchValue_in(GIULDMSR14_FirstMismatchValue_in),
                                                .GIULDMSR15_FirstMismatchValue_in(GIULDMSR15_FirstMismatchValue_in),
                                                .GIULDMSR0_FirstMismatchValue_wr(GIULDMSR0_FirstMismatchValue_wr ),
                                                .GIULDMSR1_FirstMismatchValue_wr(GIULDMSR1_FirstMismatchValue_wr ),
                                                .GIULDMSR2_FirstMismatchValue_wr(GIULDMSR2_FirstMismatchValue_wr ),
                                                .GIULDMSR3_FirstMismatchValue_wr(GIULDMSR3_FirstMismatchValue_wr ),
                                                .GIULDMSR4_FirstMismatchValue_wr(GIULDMSR4_FirstMismatchValue_wr ),
                                                .GIULDMSR5_FirstMismatchValue_wr(GIULDMSR5_FirstMismatchValue_wr ),
                                                .GIULDMSR6_FirstMismatchValue_wr(GIULDMSR6_FirstMismatchValue_wr ),
                                                .GIULDMSR7_FirstMismatchValue_wr(GIULDMSR7_FirstMismatchValue_wr ),
                                                .GIULDMSR8_FirstMismatchValue_wr(GIULDMSR8_FirstMismatchValue_wr ),
                                                .GIULDMSR9_FirstMismatchValue_wr(GIULDMSR9_FirstMismatchValue_wr ),
                                                .GIULDMSR10_FirstMismatchValue_wr(GIULDMSR10_FirstMismatchValue_wr),
                                                .GIULDMSR11_FirstMismatchValue_wr(GIULDMSR11_FirstMismatchValue_wr),
                                                .GIULDMSR12_FirstMismatchValue_wr(GIULDMSR12_FirstMismatchValue_wr),
                                                .GIULDMSR13_FirstMismatchValue_wr(GIULDMSR13_FirstMismatchValue_wr),
                                                .GIULDMSR14_FirstMismatchValue_wr(GIULDMSR14_FirstMismatchValue_wr),
                                                .GIULDMSR15_FirstMismatchValue_wr(GIULDMSR15_FirstMismatchValue_wr),
                                                .clk_clk(clk_clk),
                                                .clk_reset_n(clk_reset_n));

  initial begin
    clk_clk = 0; // Initialize clock
    forever #5 clk_clk = ~clk_clk; // Toggle clock every 5 time units
  end


always@ (posedge clk_clk) begin

cxs_out_loop_in_data  <= loop_out_cxs_in_data;
cxs_out_loop_in_valid <= loop_out_cxs_in_valid;
loop_out_cxs_in_ready <= cxs_out_loop_in_ready;

end


always@(*) begin

if (GIULCSTR_MatchStatus_wr & ~GIULCSTR_MatchStatus_in) begin
$display("FAILURE THERE WAS A MISMATCH BUT THERE SHOULDN'T BE ONE!!!!");
$finish;
end

end

initial begin
$vcdpluson;

clk_reset_n =1'b0;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NearLoopEn_out = 1'b0;
GIULCSTR_FarLoopEn_out=1'b0;
GIULCSTR_ShiftStart_out=2'b01;
GIULCSTR_RepeatMode_out = 1'd0;
GIULCSTR_DelayCounter_out =2'd0;
GIULCSTR_NumberOfTest_out =2'd1;
GIULCSTR_MatchStatus_out =1'b0;
GIULCSTR_MismatchPosition_out = 4'd0;
GIULCSTR_LoopCycleCounter_out = 17'd0;
GIULDSR_LoopStartDataValue_out = 32'h12345678;


GIULDMSR0_FirstMismatchValue_out  = 32'd0;
GIULDMSR1_FirstMismatchValue_out  = 32'd0;
GIULDMSR2_FirstMismatchValue_out  = 32'd0;
GIULDMSR3_FirstMismatchValue_out  = 32'd0;
GIULDMSR4_FirstMismatchValue_out  = 32'd0;
GIULDMSR5_FirstMismatchValue_out  = 32'd0;
GIULDMSR6_FirstMismatchValue_out  = 32'd0;
GIULDMSR7_FirstMismatchValue_out  = 32'd0;
GIULDMSR8_FirstMismatchValue_out  = 32'd0;
GIULDMSR9_FirstMismatchValue_out  = 32'd0;
GIULDMSR10_FirstMismatchValue_out = 32'd0;
GIULDMSR11_FirstMismatchValue_out = 32'd0;
GIULDMSR12_FirstMismatchValue_out = 32'd0;
GIULDMSR13_FirstMismatchValue_out = 32'd0;
GIULDMSR14_FirstMismatchValue_out = 32'd0;
GIULDMSR15_FirstMismatchValue_out = 32'd0;

#50;
clk_reset_n =1'b1;
#20;
GIULCSTR_LoopBackEn_out=1'b1;
#2000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_RepeatMode_out = 1'd1;
GIULCSTR_NumberOfTest_out = 2'd1;
GIULCSTR_DelayCounter_out =2'd0;

#200;
GIULCSTR_LoopBackEn_out=1'b1;
#2000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd2;
GIULCSTR_DelayCounter_out =2'd0;

#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#4000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd3;
GIULCSTR_DelayCounter_out =2'd0;
#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#10000;




#2000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_RepeatMode_out = 1'd1;
GIULCSTR_NumberOfTest_out = 2'd1;
GIULCSTR_DelayCounter_out =2'd1;

#200;
GIULCSTR_LoopBackEn_out=1'b1;
#2000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd2;

#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#4000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd3;
#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#10000;

#2000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_RepeatMode_out = 1'd1;
GIULCSTR_NumberOfTest_out = 2'd1;
GIULCSTR_DelayCounter_out =2'd2;

#200;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;

GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd2;

#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd3;
#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;

#100000;

GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_RepeatMode_out = 1'd1;
GIULCSTR_NumberOfTest_out = 2'd1;
GIULCSTR_DelayCounter_out =2'd3;

#100000;

GIULCSTR_LoopBackEn_out=1'b1;
#100000;

GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd2;

#100000;

GIULCSTR_LoopBackEn_out=1'b1;
#100000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd3;
#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;
#100000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd0;
#1000;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;
GIULCSTR_LoopBackEn_out=1'b0;
GIULCSTR_NumberOfTest_out = 2'd2;
#100000;
GIULCSTR_LoopBackEn_out=1'b1;
#100000;


$finish;
end
endmodule