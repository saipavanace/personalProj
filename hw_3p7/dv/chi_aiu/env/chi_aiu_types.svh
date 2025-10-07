/////////////////////////////////////////////////////////////
// File Name    :   chi_aiu_types.svh
// Author       :   NF
// Description  :   Typedefs used by CHI AIU Scoreboard
/////////////////////////////////////////////////////////////
`undef LABEL
`undef LABEL_ERROR
`define LABEL $sformatf("CHI-AIU%0d SCB",m_req_aiu_id)
`define LABEL_ERROR $sformatf("CHI-AIU%0d SCB ERROR",m_req_aiu_id)

`define SMI_EXP_FLD_WIDTH   16
`define SMI_RCVD_FLD_WIDTH   16
`define CHI_EXP_FLD_WIDTH   16
`define CHI_RCVD_FLD_WIDTH   16

// These variables will hold information on what type of packet is
// expected at AIU SMI/CHI ports. Each bit indicates a type of packet
typedef bit [`SMI_EXP_FLD_WIDTH-1:0] smi_exp_t;
typedef bit [`SMI_RCVD_FLD_WIDTH-1:0] smi_rcvd_t;
typedef bit [`CHI_EXP_FLD_WIDTH-1:0] chi_exp_t;
typedef bit [`CHI_RCVD_FLD_WIDTH-1:0] chi_rcvd_t;

//example usage
//if (smi_exp[`CMD_REQ_OUT] == 1'b1) begin
//  print "received exp command request";
//end else error; end

// IN/OUT directions are with respect to AIU SMI boundary
//TODO: look at smi_types which has defines for packet types and see if its possible to reuse that  enum
`define CMD_REQ_OUT     0
`define CMD_RSP_IN      1
`define STR_REQ_IN      2
`define STR_RSP_OUT     3
`define DTR_REQ_IN      4
`define DTR_RSP_OUT     5
`define DTW_REQ_OUT     6
`define DTW_RSP_IN      7
`define SNP_DTW_REQ_OUT 8
`define SNP_DTW_RSP_IN  9
`define SNP_RSP_OUT     10
`define SNP_DTR_REQ     11
`define SNP_DTR_RSP     12
`define CMP_RSP_IN      13
`define SNP_REQ_IN      10
`define DVM_PART2_IN     11
`define SYS_REQ_OUT     14
`define SYS_RSP_IN      15

// IN/OUT directions are with respect to AIU

`define WRITE_DATA_IN   0
//`define COMP_OUT        1
`define CHI_CRESP       1   //Completer response
`define CHI_SRESP       2   //Snoop response
//`define READ_RECPT_OUT  3
`define COMP_DATA_OUT   3   //read data out
`define CHI_SNP_REQ     4
//`define COMP_ACK_IN     5
`define CHI_REQ        5
`define READ_DATA_IN   6
`define DVM_PART2_OUT   7
`define CHI_SYSCO_REQ   14
`define CHI_SYSCO_ACK   15
