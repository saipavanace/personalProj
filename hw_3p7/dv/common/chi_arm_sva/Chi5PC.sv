//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may 
// only be used by a person authorised under and to the extent permitted 
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2012-2014 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file 
// and copies of this file may only be made by a person if such person is 
// permitted to do so under the terms of a subsisting license agreement 
// from ARM Limited.
//
//----------------------------------------------------------------------------
//  Version and Release Control Information:
//
//  File Revision       : 179635
//
//  Date                :  2014-08-27 10:43:37 +0100 (Wed, 27 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             : This is the Chi5 protocol checker.
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  196.  Module: Chi5PC
//  208.    1) Parameters
//  212.         - Configurable (user can set)
//  293.    2) Wire and Reg Declarations
//  383.    3) Verilog Defines
//  386.         - Clock and Reset
//  414.    4) Initialize simulation
//  420.         - Format for time reporting
//  427.         - Indicate version of Chi5PC
//  434.         - Warn if any/some recommended rules are disabled
//  457.    5)  Link Credits 
//  516.    6)  Node Type Structure
// 1692.    7)  Reset Checks
// 1695.         - CHI5PC_ERR_REQ_TXFLITV_RESET
// 1707.         - CHI5PC_ERR_REQ_RXLCRDV_RESET
// 1720.         - CHI5PC_ERR_DAT_TXFLITV_RESET
// 1732.         - CHI5PC_ERR_DAT_RXLCRDV_RESET
// 1744.         - CHI5PC_ERR_RSP_TXFLITV_RESET
// 1756.         - CHI5PC_ERR_RSP_RXLCRDV_RESET
// 1768.         - CHI5PC_ERR_SNP_TXFLITV_RESET
// 1781.         - CHI5PC_ERR_SNP_RXLCRDV_RESET
// 1794.         - CHI5PC_ERR_LNK_TXLINKACTIVEREQ_RESET
// 1806.         - CHI5PC_ERR_LNK_RXLINKACTIVEACK_RESET
// 1819.    8)  Credit Checks
// 1824.         - CHI5PC_ERR_REQ_TXCRD_OVFLW
// 1837.         - CHI5PC_ERR_REQ_RXCRD_OVFLW
// 1851.         - CHI5PC_ERR_DAT_TXCRD_OVFLW
// 1864.         - CHI5PC_ERR_DAT_RXCRD_OVFLW
// 1877.         - CHI5PC_ERR_SNP_TXCRD_OVFLW
// 1891.         - CHI5PC_ERR_SNP_RXCRD_OVFLW
// 1904.         - CHI5PC_ERR_RSP_TXCRD_OVFLW
// 1918.         - CHI5PC_ERR_RSP_RXCRD_OVFLW
// 1933.         - CHI5PC_ERR_REQ_TXCRD_UNFLW
// 1946.         - CHI5PC_ERR_REQ_RXCRD_UNFLW
// 1959.         - CHI5PC_ERR_DAT_TXCRD_UNFLW
// 1971.         - CHI5PC_ERR_DAT_RXCRD_UNFLW
// 1985.         - CHI5PC_ERR_SNP_TXCRD_UNFLW
// 1998.         - CHI5PC_ERR_SNP_RXCRD_UNFLW
// 2011.         - CHI5PC_ERR_RSP_TXCRD_UNFLW
// 2024.         - CHI5PC_ERR_RSP_RXCRD_UNFLW
// 2037.         - CHI5PC_ERR_LNK_TXDEACT_CRD
// 2052.         - CHI5PC_ERR_LNK_RXDEACT_CRD
// 2068.     9)  Transaction match checks
// 2071.         - CHI5PC_ERR_RSP_TXMATCH
// 2086.         - CHI5PC_ERR_RSP_RXMATCH
// 2100.         - CHI5PC_ERR_DAT_TXMATCH
// 2114.         - CHI5PC_ERR_DAT_RXMATCH
// 2130.    10)  REQ channel Checks
// 2135.         - CHI5PC_ERR_REQ_TXSRCID
// 2149.         - CHI5PC_ERR_REQ_TXTGTID
// 2163.         - CHI5PC_ERR_REQ_RXTGTID
// 2177.         - CHI5PC_ERR_REQ_RXSRCID
// 2191.    11)  TXDAT channel Checks
// 2196.         - CHI5PC_ERR_DAT_TXSRCID
// 2210.         - CHI5PC_ERR_DAT_TXTGTID
// 2224.         - CHI5PC_ERR_DAT_CTL_LINKFLIT_TX
// 2237.         - CHI5PC_ERR_DAT_RSVD_OPCODE_TX
// 2250.    12)  RXDAT channel Checks
// 2253.         - CHI5PC_ERR_DAT_RXTGTID
// 2267.         - CHI5PC_ERR_DAT_RXSRCID
// 2281.         - CHI5PC_ERR_DAT_CTL_LINKFLIT_RX
// 2293.         - CHI5PC_ERR_DAT_RSVD_OPCODE_RX
// 2308.    13)  TXSNP channel Checks
// 2313.         - CHI5PC_ERR_SNP_TXSRCID
// 2327.    14)  RXSNP channel Checks
// 2331.         - CHI5PC_ERR_SNP_RXSRCID
// 2346.    15)  TXRSP channel Checks
// 2352.         - CHI5PC_ERR_RSP_TXSRCID
// 2366.         - CHI5PC_ERR_RSP_TXTGTID
// 2380.         - CHI5PC_ERR_RSP_CTL_LINKFLIT_TX
// 2392.         - CHI5PC_ERR_RSP_RSVD_OPCODE_TX
// 2406.    16)  RXRSP channel Checks
// 2412.         - CHI5PC_ERR_RSP_RXTGTID
// 2426.         - CHI5PC_ERR_RSP_RXSRCID
// 2439.         - CHI5PC_ERR_RSP_CTL_LINKFLIT_RX
// 2452.         - CHI5PC_ERR_RSP_RSVD_OPCODE_RX
// 2465.    17)  FLITPEND Checks
// 2493.         - CHI5PC_ERR_REQ_TXREQFLITPEND
// 2505.         - CHI5PC_ERR_REQ_RXREQFLITPEND
// 2517.         - CHI5PC_ERR_DAT_TXDATFLITPEND
// 2529.         - CHI5PC_ERR_DAT_RXDATFLITPEND
// 2541.         - CHI5PC_ERR_RSP_TXRSPFLITPEND
// 2553.         - CHI5PC_ERR_RSP_RXRSPFLITPEND
// 2565.         - CHI5PC_ERR_SNP_TXSNPFLITPEND
// 2577.         - CHI5PC_ERR_SNP_RXSNPFLITPEND
// 2589.    18)  Connection checks
// 2592.         - CHI5PC_ERR_REQ_NOVC_TXREQ
// 2604.         - CHI5PC_ERR_REQ_NOVC_RXREQ
// 2616.         - CHI5PC_ERR_SNP_NOVC_TXSNP
// 2628.         - CHI5PC_ERR_SNP_NOVC_RXSNP
// 2640.         - CHI5PC_ERR_RSP_NOVC_RXRSP
// 2651.    19)  X checks
// 2654.         - CHI5PC_ERR_REQ_TXLCRDV_X
// 2665.         - CHI5PC_ERR_REQ_RXLCRDV_X
// 2676.         - CHI5PC_ERR_DAT_TXLCRDV_X
// 2687.         - CHI5PC_ERR_DAT_RXLCRDV_X
// 2698.         - CHI5PC_ERR_RSP_TXLCRDV_X
// 2709.         - CHI5PC_ERR_RSP_RXLCRDV_X
// 2720.         - CHI5PC_ERR_SNP_TXLCRDV_X
// 2731.         - CHI5PC_ERR_SNP_RXLCRDV_X
// 2742.         - CHI5PC_ERR_REQ_TXFLITPEND_X
// 2753.         - CHI5PC_ERR_REQ_RXFLITPEND_X
// 2764.         - CHI5PC_ERR_DAT_TXFLITPEND_X
// 2775.         - CHI5PC_ERR_DAT_RXFLITPEND_X
// 2786.         - CHI5PC_ERR_RSP_TXFLITPEND_X
// 2797.         - CHI5PC_ERR_RSP_RXFLITPEND_X
// 2808.         - CHI5PC_ERR_SNP_TXFLITPEND_X
// 2819.         - CHI5PC_ERR_SNP_RXFLITPEND_X
// 2830.         - CHI5PC_ERR_REQ_TX_X
// 2842.         - CHI5PC_ERR_REQ_RX_X
// 2854.         - CHI5PC_ERR_DAT_TX_X
// 2877.         - CHI5PC_ERR_DAT_RX_X
// 2900.         - CHI5PC_ERR_DAT_DATA127TO0_TX_X
// 2927.         - CHI5PC_ERR_DAT_DATA127TO0_RX_X
// 2954.         - CHI5PC_ERR_DAT_DATA255TO128_TX_X
// 2984.         - CHI5PC_ERR_DAT_DATA255TO128_RX_X
// 3014.         - CHI5PC_ERR_DAT_DATA511TO256_TX_X
// 3060.         - CHI5PC_ERR_DAT_DATA511TO256_RX_X
// 3106.         - CHI5PC_ERR_SNP_TX_X
// 3117.         - CHI5PC_ERR_SNP_RX_X
// 3128.         - CHI5PC_ERR_RSP_TX_X
// 3139.         - CHI5PC_ERR_RSP_RX_X
// 3150.         - CHI5PC_ERR_REQ_TXFLITV_X
// 3161.         - CHI5PC_ERR_REQ_RXFLITV_X
// 3172.         - CHI5PC_ERR_SNP_TXFLITV_X
// 3183.         - CHI5PC_ERR_SNP_RXFLITV_X
// 3194.         - CHI5PC_ERR_RSP_TXFLITV_X
// 3205.         - CHI5PC_ERR_RSP_RXFLITV_X
// 3216.         - CHI5PC_ERR_DAT_TXFLITV_X
// 3227.         - CHI5PC_ERR_DAT_RXFLITV_X
// 3238.         - CHI5PC_ERR_LNK_TXLINKACTIVEREQ_X
// 3249.         - CHI5PC_ERR_LNK_RXLINKACTIVEREQ_X
// 3260.         - CHI5PC_ERR_LNK_TXLINKACTIVEACK_X
// 3271.         - CHI5PC_ERR_LNK_RXLINKACTIVEACK_X
// 3282.         - CHI5PC_ERR_LNK_TXSACTIVE_X
// 3293.         - CHI5PC_ERR_LNK_RXSACTIVE_X
// 3304.    20)  End of simulation checks
// 3311.         - CHI5PC_ERR_EOS_LCRD_TXREQ
// 3320.         - CHI5PC_ERR_EOS_LCRD_RXREQ
// 3329.         - CHI5PC_ERR_EOS_LCRD_TXRSP
// 3338.         - CHI5PC_ERR_EOS_LCRD_RXRSP
// 3347.         - CHI5PC_ERR_EOS_LCRD_TXSNP
// 3356.         - CHI5PC_ERR_EOS_LCRD_RXSNP
// 3365.         - CHI5PC_ERR_EOS_LCRD_TXDAT
// 3374.         - CHI5PC_ERR_EOS_LCRD_RXDAT
// 3385.    21) Clear Verilog Defines
// 3395.    22) End of module
// 3401. 
// 3402.  End of File
//----------------------------------------------------------------------------


`ifndef CHI5PC_OFF


//------------------------------------------------------------------------------
// CHI5 Standard Defines
//------------------------------------------------------------------------------


`ifndef CHI5PC_CHI5_MESSAGES
`endif
  `include "Chi5PC_defines.v"



//------------------------------------------------------------------------------
// INDEX: Module: Chi5PC
//------------------------------------------------------------------------------
  `include "Chi5PC_Chi5_defines.v"

`ifndef CHI5PC
  `define CHI5PC
module Chi5PC
  (Chi5PC_if Chi5_in,
  input wire SCLK);
  import Chi5PC_pkg::*;

//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
 
  // =====
  // INDEX:        - Configurable (user can set)
  // =====
  // Parameters below can be set by the user.
  
  parameter  MAX_OS_REQ = 8;
  parameter eChi5PCMode PCMODE = LOCAL;
  parameter MAX_OS_SNP = 16;
  parameter MAX_OS_EXCL = 8;
  parameter REQ_RSVDC_WIDTH = 4;
  parameter DAT_RSVDC_WIDTH = 4;
  parameter DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH;
  parameter eChi5PCDevType NODE_TYPE = RNF;
  parameter int NODE_ID = 0;


  parameter numChi5nodes = 4 ;


  parameter MAXLLCREDITS= 16;
  parameter MAXLLCREDITS_IN_RXDEACTIVATE = MAXLLCREDITS;

  parameter CRDGRANT_BEFORE_RETRY = 1'b1;
  typedef Chi5_in.Chi5PCReqFlit Chi5PCReqFlit;
  typedef Chi5_in.Chi5PCRspFlit Chi5PCRspFlit;
  typedef Chi5_in.Chi5PCDatFlit Chi5PCDatFlit;
  typedef Chi5_in.Chi5PCSnpFlit Chi5PCSnpFlit;





  // Recommended Rules Enable
  // enable/disable reporting of all  _REC_SW_* rules
  parameter ErrorOn_SW   = 1'b1;   
  // enable/disable reporting of all  _REC*_* rules
  parameter RecommendOn   = 1'b1;   
  // enable disable address hazarding 
  parameter RecommendOn_Haz = 1'b1; 
  // enable disable X checking on data
  parameter ErrorOn_Data_X = 1'b1; 
  // Assune that all transactions are required to be ordered wrt barriers
  parameter Barrier_Order = 1'b1; 
  localparam int MAXLLCREDITS_MAX_WIDTH = clogb2(MAXLLCREDITS);
  const logic NODE_TYPE_HAS_MN = ((NODE_TYPE == MN) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI_MN) );
  const logic NODE_TYPE_HAS_HNI = ((NODE_TYPE == HNI) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );
  const logic NODE_TYPE_HAS_HNF = ((NODE_TYPE == HNF) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );

  const logic HAS_RXSNP = (NODE_TYPE == RNF  ||
                       NODE_TYPE == RND );
  const logic HAS_TXSNP = (NODE_TYPE_HAS_HNF  ||
                       NODE_TYPE_HAS_MN );
  const logic HAS_RXREQ = (NODE_TYPE_HAS_HNF  ||
                       NODE_TYPE_HAS_HNI  ||
                       NODE_TYPE == SNI  ||
                       NODE_TYPE == SNF  ||
                       NODE_TYPE_HAS_MN );
  const logic HAS_TXREQ = (NODE_TYPE_HAS_HNF  ||
                       NODE_TYPE_HAS_HNI  ||
                       NODE_TYPE == RNF  ||
                       NODE_TYPE == RNI  ||
                       NODE_TYPE == RND  ||
                       NODE_TYPE_HAS_MN );
  const logic HAS_TXRSP = (NODE_TYPE == RNF  ||
                       NODE_TYPE == RNI ||
                       NODE_TYPE == RND ||
                       NODE_TYPE_HAS_HNF ||
                       NODE_TYPE_HAS_HNI ||
                       NODE_TYPE_HAS_MN ||
                       NODE_TYPE == SNF ||
                       NODE_TYPE == SNI 
                     );
  const logic HAS_RXRSP = (NODE_TYPE_HAS_HNF  ||
                       NODE_TYPE_HAS_HNI  ||
                       NODE_TYPE == RNF  ||
                       NODE_TYPE == RNI  ||
                       NODE_TYPE == RND  ||
                       NODE_TYPE_HAS_MN );

  
   
//------------------------------------------------------------------------------
// INDEX:   2) Wire and Reg Declarations
//------------------------------------------------------------------------------
  Chi5PCReqFlit STRUCT_TXREQFLIT;
  assign STRUCT_TXREQFLIT = Chi5_in.TXREQFLIT;
  Chi5PCReqFlit STRUCT_RXREQFLIT;
  assign STRUCT_RXREQFLIT = Chi5_in.RXREQFLIT;
  Chi5PCRspFlit STRUCT_TXRSPFLIT;
  assign STRUCT_TXRSPFLIT = Chi5_in.TXRSPFLIT;
  Chi5PCRspFlit STRUCT_RXRSPFLIT ;
  assign STRUCT_RXRSPFLIT = Chi5_in.RXRSPFLIT;
  Chi5PCSnpFlit STRUCT_TXSNPFLIT;
  assign STRUCT_TXSNPFLIT = Chi5_in.TXSNPFLIT;
  Chi5PCSnpFlit STRUCT_RXSNPFLIT;
  assign STRUCT_RXSNPFLIT = Chi5_in.RXSNPFLIT;
  Chi5PCDatFlit STRUCT_RXDATFLIT;
  assign STRUCT_RXDATFLIT = Chi5_in.RXDATFLIT;
  Chi5PCDatFlit STRUCT_TXDATFLIT;
  assign STRUCT_TXDATFLIT = Chi5_in.TXDATFLIT;


  wire m_RXDAT_match;
  wire m_TXDAT_match;
  wire m_RXRSP_match;
  wire m_TXRSP_match;
  wire s_RXDAT_match;
  wire s_TXDAT_match;
  wire s_RXRSP_match;
  wire s_TXRSP_match;
  wire snp_DAT_match;
  wire snp_RSP_match;
  wire [1:0] receiver_link_state;
  wire [1:0] transmitter_link_state;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_TXDAT_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_RXDAT_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_TXSNP_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_RXSNP_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_TXREQ_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_RXREQ_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_TXRSP_Credits;
  wire [MAXLLCREDITS_MAX_WIDTH -1 :0] next_RXRSP_Credits;
  wire TXREQ_TGTID_exists;
  wire TXRSP_TGTID_exists;
  wire TXDAT_TGTID_exists;
  wire RXREQ_SRCID_exists;
  wire RXRSP_SRCID_exists;
  wire RXDAT_SRCID_exists;
  wire RXSNP_SRCID_exists;
  eChi5PCDevType RXREQ_SRCID_NodeType;
  eChi5PCDevType RXRSP_SRCID_NodeType;
  eChi5PCDevType RXDAT_SRCID_NodeType;
  eChi5PCDevType RXSNP_SRCID_NodeType;
  eChi5PCDevType TXREQ_TGTID_NodeType;
  eChi5PCDevType TXSNP_TGTID_NodeType;
  eChi5PCDevType TXRSP_TGTID_NodeType;
  eChi5PCDevType TXDAT_TGTID_NodeType;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] TXDAT_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] RXDAT_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] TXSNP_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] RXSNP_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] TXREQ_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] RXREQ_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] TXRSP_Credits;
  reg [MAXLLCREDITS_MAX_WIDTH -1 :0] RXRSP_Credits;
  wire TX_Credits;
  wire RX_Credits;
  reg TXREQFLITPEND_del ;
  reg RXREQFLITPEND_del ;
  reg TXDATFLITPEND_del ;
  reg RXDATFLITPEND_del ;
  reg TXRSPFLITPEND_del ;
  reg RXRSPFLITPEND_del ;
  reg TXSNPFLITPEND_del ;
  reg RXSNPFLITPEND_del ;

  assign TXREQ_TGTID_exists = Chi5_in.NODE_exists(Chi5PC_SAM_pkg::SAM_remap(Chi5_in.TXREQFLIT));
  assign TXRSP_TGTID_exists = Chi5_in.NODE_exists(Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  assign TXDAT_TGTID_exists = Chi5_in.NODE_exists(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_TGTID_RANGE]);
  assign RXREQ_SRCID_exists = Chi5_in.NODE_exists(Chi5_in.RXREQFLIT[`CHI5PC_REQ_FLIT_SRCID_RANGE]);
  assign RXRSP_SRCID_exists = Chi5_in.NODE_exists(Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign RXDAT_SRCID_exists = Chi5_in.NODE_exists(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_SRCID_RANGE]);
  assign RXSNP_SRCID_exists = Chi5_in.NODE_exists(Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_SRCID_RANGE]);

  assign RXREQ_SRCID_NodeType = Chi5_in.get_NodeType(Chi5_in.RXREQFLIT[`CHI5PC_REQ_FLIT_SRCID_RANGE]);
  assign RXSNP_SRCID_NodeType = Chi5_in.get_NodeType(Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_SRCID_RANGE]);
  assign RXRSP_SRCID_NodeType = Chi5_in.get_NodeType(Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign RXDAT_SRCID_NodeType = Chi5_in.get_NodeType(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_SRCID_RANGE]);
  assign TXREQ_TGTID_NodeType = Chi5_in.get_NodeType(Chi5PC_SAM_pkg::SAM_remap(Chi5_in.TXREQFLIT));
  assign TXRSP_TGTID_NodeType = Chi5_in.get_NodeType(Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  assign TXDAT_TGTID_NodeType = Chi5_in.get_NodeType(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_TGTID_RANGE]);
//------------------------------------------------------------------------------
// INDEX:   3) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  //
  `ifdef CHI5_SVA_CLK
  `else
     `define CHI5_SVA_CLK SCLK
  `endif
  //
  `ifdef CHI5_SVA_RSTn
  `else
     `define CHI5_SVA_RSTn Chi5_in.SRESETn
  `endif
  // 
  // AUX: Auxiliary Logic
  `ifdef CHI5_AUX_CLK
  `else
     `define CHI5_AUX_CLK SCLK
  `endif
  //
  `ifdef CHI5_AUX_RSTn
  `else
     `define CHI5_AUX_RSTn Chi5_in.SRESETn
  `endif
  


//------------------------------------------------------------------------------
// INDEX:   4) Initialize simulation
//------------------------------------------------------------------------------
  initial
    begin

      // =====
      // INDEX:        - Format for time reporting
      // =====
      // Format for time reporting
      $timeformat(-9, 0, " ns", 0);


      // =====
      // INDEX:        - Indicate version of Chi5PC
      // =====
      $display("\nCHI5PC_INFO: Running Chi5PC version BP066-BU-01000-r0p0-00lac0 (SVA implementation)");
      $display("Node ID == %d",  Chi5_in.NODE_ID);
      $display("System Node Type vector  = %p, System Node ID vector == %p \n\n", Chi5_in.devQ, Chi5_in.nodeIdQ);

      // =====
      // INDEX:        - Warn if any/some recommended rules are disabled
      // =====
      if (ErrorOn_SW == 0)
        // All _SW rules disabled
        $display("CHI5_WARN: All CHI5 software rules have been disabled by the ErrorOn_SW parameter");
      if (RecommendOn == 0)
        // All _REC*_* rules disabled
        $display("CHI5_WARN: All recommended CHI5 rules have been disabled by the RecommendOn parameter");
      if (RecommendOn_Haz == 0)
        // All _REC*_HAZ rules disabled
        $display("CHI5_WARN: All recommended CHI5 hazard rules have been disabled by the RecommendOn_Haz parameter");
      if (ErrorOn_Data_X == 0)
        // All _REC*_* rules disabled
        $display("CHI5_WARN: All Data X-Checks have been disabled by the ErrorOn_Data_X parameter");
      if (Barrier_Order == 0)
        // All _REC*_* rules disabled
        $display("CHI5_WARN: All CHI5 checks that assume that all transactions are required to be ordered with respect to Barriers have been disabled by the Barrier_Order parameter");


    end
 

//------------------------------------------------------------------------------
// INDEX:   5)  Link Credits 
//------------------------------------------------------------------------------ 


  assign next_TXREQ_Credits = Chi5_in.SRESETn && HAS_TXREQ ? (Chi5_in.TXREQFLITV && Chi5_in.TXREQLCRDV) ? TXREQ_Credits  :
      Chi5_in.TXREQFLITV ? (TXREQ_Credits -1) :
      Chi5_in.TXREQLCRDV ?  (TXREQ_Credits +1) : TXREQ_Credits : 'b0;
  assign next_RXREQ_Credits = Chi5_in.SRESETn && HAS_RXREQ? (Chi5_in.RXREQFLITV && Chi5_in.RXREQLCRDV) ? RXREQ_Credits   :
      Chi5_in.RXREQFLITV ? (RXREQ_Credits -1) :
      Chi5_in.RXREQLCRDV ?  (RXREQ_Credits +1) : RXREQ_Credits : 'b0;
  assign next_TXDAT_Credits = Chi5_in.SRESETn ? (Chi5_in.TXDATFLITV && Chi5_in.TXDATLCRDV) ? TXDAT_Credits  :
      Chi5_in.TXDATFLITV ? (TXDAT_Credits -1) :
      Chi5_in.TXDATLCRDV ?  (TXDAT_Credits +1) : TXDAT_Credits : 'b0;
  assign next_RXDAT_Credits = Chi5_in.SRESETn ? (Chi5_in.RXDATFLITV && Chi5_in.RXDATLCRDV) ? RXDAT_Credits  :
      Chi5_in.RXDATFLITV ? (RXDAT_Credits -1) :
      Chi5_in.RXDATLCRDV ?  (RXDAT_Credits +1) : RXDAT_Credits : 'b0;
  assign next_TXSNP_Credits = Chi5_in.SRESETn && HAS_TXSNP ? (Chi5_in.TXSNPFLITV && Chi5_in.TXSNPLCRDV) ? TXSNP_Credits :
      Chi5_in.TXSNPFLITV ? (TXSNP_Credits -1) :
      Chi5_in.TXSNPLCRDV ?  (TXSNP_Credits +1) : TXSNP_Credits : 'b0;
  assign next_RXSNP_Credits = Chi5_in.SRESETn && HAS_RXSNP ? Chi5_in.RXSNPFLITV && Chi5_in.RXSNPLCRDV ? RXSNP_Credits: 
      Chi5_in.RXSNPFLITV ? RXSNP_Credits - 1 : 
      Chi5_in.RXSNPLCRDV ? RXSNP_Credits + 1 : RXSNP_Credits : 'b0;
  assign next_TXRSP_Credits = Chi5_in.SRESETn && HAS_TXRSP? (Chi5_in.TXRSPFLITV && Chi5_in.TXRSPLCRDV) ? TXRSP_Credits  :
      Chi5_in.TXRSPFLITV ? (TXRSP_Credits -1) :
      Chi5_in.TXRSPLCRDV ?  (TXRSP_Credits +1) : TXRSP_Credits : 'b0;
  assign next_RXRSP_Credits = Chi5_in.SRESETn && HAS_RXRSP? (Chi5_in.RXRSPFLITV && Chi5_in.RXRSPLCRDV) ? RXRSP_Credits  :
      Chi5_in.RXRSPFLITV ? (RXRSP_Credits -1) :
      Chi5_in.RXRSPLCRDV ?  (RXRSP_Credits +1) : RXRSP_Credits : 'b0;

  assign TX_Credits = |TXREQ_Credits || |TXRSP_Credits || |TXDAT_Credits || |TXSNP_Credits ;
  assign RX_Credits = |RXREQ_Credits || |RXRSP_Credits || |RXDAT_Credits || |RXSNP_Credits ;

  always @(negedge `CHI5_SVA_RSTn or posedge `CHI5_SVA_CLK)
  begin
    if(!`CHI5_SVA_RSTn)
    begin
      TXDAT_Credits <= 0;
      RXDAT_Credits <= 0;
      TXSNP_Credits <= 0;
      RXSNP_Credits <= 0;
      TXREQ_Credits <= 0;
      RXREQ_Credits <= 0;
      TXRSP_Credits <= 0;
      RXRSP_Credits <= 0;
    end
    else
    begin
      TXDAT_Credits <= next_TXDAT_Credits;
      RXDAT_Credits <= next_RXDAT_Credits;
      TXSNP_Credits <= next_TXSNP_Credits;
      RXSNP_Credits <= next_RXSNP_Credits;
      TXREQ_Credits <= next_TXREQ_Credits;
      RXREQ_Credits <= next_RXREQ_Credits;
      TXRSP_Credits <= next_TXRSP_Credits;
      RXRSP_Credits <= next_RXRSP_Credits;
    end
  end

//------------------------------------------------------------------------------
// INDEX:   6)  Node Type Structure
//------------------------------------------------------------------------------ 

generate
  case (NODE_TYPE)
    HNF:
    begin : hnf
      wire  m_RDDAT_Last;
      wire  s_RDDAT_Last;
      wire [44:0] m_S_RSP_Addr_NS;
      wire [44:0] s_S_RSP_Addr_NS;
      wire [3:0] m_S_RSP_Dev_Size;
      wire [3:0] s_S_RSP_Dev_Size;
      wire m_S_RSP_Comp_Wr;
      wire s_S_RSP_Comp_Wr;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.RDDAT_Last_(m_RDDAT_Last)
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (m_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (m_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (m_S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(0),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_s_FlitTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.REQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.RXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.RXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(s_RDDAT_Last)
         ,.RDDAT_match (s_RXDAT_match)
         ,.WRDAT_match (s_TXDAT_match)
         ,.RXRSP_match (s_RXRSP_match)
         ,.TXRSP_match (s_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (s_S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (s_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (s_S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_SnoopTrace #(.NODE_TYPE(NODE_TYPE),.MAX_OS_SNP (MAX_OS_SNP),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH),.numChi5nodes(numChi5nodes), .ErrorOn_SW(ErrorOn_SW), .PCMODE(PCMODE))
      u_m_SnoopTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.DATFLITV_(Chi5_in.RXDATFLITV)
         ,.DATFLIT_(Chi5_in.RXDATFLIT)
         ,.SNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.SNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.DAT_match  (snp_DAT_match)
         ,.RSP_match  (snp_RSP_match)
         ,.RDDAT_Data_FLITV (1'b0)
         ,.WRDAT_Data_FLITV (1'b0)
         ,.S_RSP_Comp_Haz_FLITV (1'b0)
         ,.RDDAT_Addr_NS (39'b0)
         ,.WRDAT_Addr_NS (39'b0)
         ,.S_RSP_Addr_NS (39'b0)
         ,.BroadcastVector(Chi5_in.BroadcastVector)
      );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_rx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDAT_Last_(s_RDDAT_Last)
         ,.S_RSP_Addr_NS(s_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size(s_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr(s_S_RSP_Comp_Wr)
     );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_tx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDAT_Last_(m_RDDAT_Last)
         ,.S_RSP_Addr_NS(m_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size(m_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr(m_S_RSP_Comp_Wr)
     );


    end
    HNI:
    begin : hni
      wire  m_RDDAT_Last;
      wire  s_RDDAT_Last;
      wire [44:0] m_S_RSP_Addr_NS;
      wire [44:0] s_S_RSP_Addr_NS;
      wire [3:0] m_S_RSP_Dev_Size;
      wire [3:0] s_S_RSP_Dev_Size;
      wire m_S_RSP_Comp_Wr;
      wire s_S_RSP_Comp_Wr;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(m_RDDAT_Last)
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (m_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (m_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (m_S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(0),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_s_FlitTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.REQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.RXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.RXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(s_RDDAT_Last)
         ,.RDDAT_match (s_RXDAT_match)
         ,.WRDAT_match (s_TXDAT_match)
         ,.RXRSP_match (s_RXRSP_match)
         ,.TXRSP_match (s_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (s_S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (s_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (s_S_RSP_Comp_Wr)
         ,.RDDAT_Comp_Haz ( )
         ,.RDDAT_Addr_NS ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_tx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDAT_Last_(m_RDDAT_Last)
         ,.S_RSP_Addr_NS(m_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size(m_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr(m_S_RSP_Comp_Wr)
     );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_rx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDAT_Last_(s_RDDAT_Last)
         ,.S_RSP_Addr_NS(s_S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size(s_S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr(s_S_RSP_Comp_Wr)
     );

      assign snp_DAT_match = 1'b0;
      assign snp_RSP_match = 1'b0;
    end
    RNF:
    begin : rnf
      wire S_RSP_Comp_Haz;
      wire [63:23] RXSNP_Addr;
      assign RXSNP_Addr = Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_ADDR_RANGE];
      wire [43:5] RXSNP_Addr_NS;
      assign RXSNP_Addr_NS = {RXSNP_Addr[63:26],Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_NS_RANGE]};
      wire [44:0] S_RSP_Addr_NS;
      wire [43:5] RDDAT_Addr_NS;
      wire [43:5] WRDAT_Addr_NS;
      wire  RDDAT_Last;
      wire [3:0] S_RSP_Dev_Size;
      wire S_RSP_Comp_Wr;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK),
         .Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SNPFLITV_(Chi5_in.RXSNPFLITV && (Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPDVMOP) && |Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_OPCODE_RANGE] )
         ,.SNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz (S_RSP_Comp_Haz)
         ,.S_RSP_Addr_NS (S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS (RDDAT_Addr_NS)
         ,.RDDAT_Comp_Haz (RDDAT_Comp_Haz)
         ,.WRDAT_Addr_NS (WRDAT_Addr_NS)
      );
      Chi5PC_Retry_Crdgrnt #(.MAX_OS_REQ (MAX_OS_REQ), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .MODE(1))
      u_m_Retry_Crdgrnt
      ( .SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
   );

      Chi5PC_SnoopTrace #(.NODE_TYPE(NODE_TYPE),.MAX_OS_SNP (MAX_OS_SNP),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .ErrorOn_SW(ErrorOn_SW), .PCMODE(PCMODE))
      u_s_SnoopTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.DATFLITV_(Chi5_in.TXDATFLITV)
         ,.DATFLIT_(Chi5_in.TXDATFLIT)
         ,.SNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.SNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.DAT_match  (snp_DAT_match)
         ,.RSP_match  (snp_RSP_match)
         ,.RDDAT_Data_FLITV (Chi5_in.RXDATFLITV && 
            (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA) && RDDAT_Comp_Haz) 
         ,.WRDAT_Data_FLITV (Chi5_in.TXDATFLITV && 
            ((Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA) || 
             (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA)))
         ,.S_RSP_Comp_Haz_FLITV (Chi5_in.RXRSPFLITV && S_RSP_Comp_Haz)
         ,.RDDAT_Addr_NS (RDDAT_Addr_NS)
         ,.WRDAT_Addr_NS (WRDAT_Addr_NS)
         ,.S_RSP_Addr_NS ({(S_RSP_Addr_NS[44:7]),(S_RSP_Addr_NS[0])})
         ,.BroadcastVector(Chi5_in.BroadcastVector)
      );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_tx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.S_RSP_Addr_NS(S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
     );

      assign s_RXDAT_match = 1'b0;
      assign s_TXDAT_match = 1'b0;
      assign s_RXRSP_match = 1'b0;
      assign s_TXRSP_match = 1'b0;
    end
    RND:
    begin : rnd
      wire  RDDAT_Last;
      wire [44:0] S_RSP_Addr_NS;
      wire [3:0] S_RSP_Dev_Size;
      wire S_RSP_Comp_Wr;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
         ,.RDDAT_Comp_Haz ( )
         ,.RDDAT_Addr_NS ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_Retry_Crdgrnt #(.MAX_OS_REQ (MAX_OS_REQ), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .MODE(1))
      u_m_Retry_Crdgrnt
      ( .SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
   );
      Chi5PC_SnoopTrace #(.NODE_TYPE(NODE_TYPE),.MAX_OS_SNP (MAX_OS_SNP),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .ErrorOn_SW(ErrorOn_SW), .PCMODE(PCMODE))
      u_s_SnoopTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.DATFLITV_(Chi5_in.TXDATFLITV)
         ,.DATFLIT_(Chi5_in.TXDATFLIT)
         ,.SNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.SNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.DAT_match  (snp_DAT_match)
         ,.RSP_match  (snp_RSP_match)
         ,.RDDAT_Data_FLITV (1'b0)
         ,.WRDAT_Data_FLITV (1'b0)
         ,.S_RSP_Comp_Haz_FLITV (1'b0)
         ,.RDDAT_Addr_NS (39'b0)
         ,.WRDAT_Addr_NS (39'b0)
         ,.S_RSP_Addr_NS (39'b0)
         ,.BroadcastVector(Chi5_in.BroadcastVector)
      );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_tx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.S_RSP_Addr_NS(S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
     );

      assign s_RXDAT_match = 1'b0;
      assign s_TXDAT_match = 1'b0;
      assign s_RXRSP_match = 1'b0;
      assign s_TXRSP_match = 1'b0;
    end
    RNI:
    begin : rni
      wire  RDDAT_Last;
      wire [44:0] S_RSP_Addr_NS;
      wire [3:0] S_RSP_Dev_Size;
      wire S_RSP_Comp_Wr;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)

         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_Retry_Crdgrnt #(.MAX_OS_REQ (MAX_OS_REQ), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .MODE(1))
      u_m_Retry_Crdgrnt
      ( .SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
   );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_tx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.S_RSP_Addr_NS(S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
     );

      assign s_RXDAT_match = 1'b0;
      assign s_TXDAT_match = 1'b0;
      assign s_RXRSP_match = 1'b0;
      assign s_TXRSP_match = 1'b0;
      assign snp_DAT_match = 1'b0;
      assign snp_RSP_match = 1'b0;
    end
    MN:
    begin : mn
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(1),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_m_FlitTrace 
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.TXREQFLITV)
         ,.REQFLIT_(Chi5_in.TXREQFLIT)
         ,.REQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.TXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.TXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)

         ,.RDDAT_Last_()
         ,.RDDAT_match (m_RXDAT_match)
         ,.WRDAT_match (m_TXDAT_match)
         ,.RXRSP_match (m_RXRSP_match)
         ,.TXRSP_match (m_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS ( )
         ,.S_RSP_Dev_Size ()
         ,.S_RSP_Comp_Wr ()
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(0),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_s_FlitTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.REQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.RXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.RXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.M_RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.M_RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_()
         ,.RDDAT_match (s_RXDAT_match)
         ,.WRDAT_match (s_TXDAT_match)
         ,.RXRSP_match (s_RXRSP_match)
         ,.TXRSP_match (s_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS ( )
         ,.S_RSP_Dev_Size ()
         ,.S_RSP_Comp_Wr ()
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      Chi5PC_SnoopTrace #(.NODE_TYPE(NODE_TYPE),.MAX_OS_SNP (MAX_OS_SNP),.MODE(1), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .ErrorOn_SW(ErrorOn_SW), .PCMODE(PCMODE))
      u_m_SnoopTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.DATFLITV_(Chi5_in.RXDATFLITV)
         ,.DATFLIT_(Chi5_in.RXDATFLIT)
         ,.SNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.SNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.RSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.SNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.DAT_match  (snp_DAT_match)
         ,.RSP_match  (snp_RSP_match)
         ,.RDDAT_Data_FLITV ()
         ,.WRDAT_Data_FLITV ()
         ,.S_RSP_Comp_Haz_FLITV ()
         ,.RDDAT_Addr_NS ()
         ,.WRDAT_Addr_NS ()
         ,.S_RSP_Addr_NS ()
         ,.BroadcastVector(Chi5_in.BroadcastVector)
      );
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
    end
    SNF:
    begin : sn
      wire  RDDAT_Last;
      wire [3:0] S_RSP_Dev_Size;
      wire [44:0] S_RSP_Addr_NS;
      wire [43:5] RDDAT_Addr_NS;
      wire [43:5] WRDAT_Addr_NS;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(0),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_s_FlitTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.REQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.RXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.RXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.M_RSPFLITV_(1'b0)
         ,.M_RSPFLIT_(`CHI5PC_RSP_FLIT_WIDTH'b0)
         ,.TXRSPLCRDV_(1'b0)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDAT_match (s_RXDAT_match)
         ,.WRDAT_match (s_TXDAT_match)
         ,.RXRSP_match (s_RXRSP_match)
         ,.TXRSP_match (s_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      if (CRDGRANT_BEFORE_RETRY)
      begin : Chi5PC_Retry_Crdgrnt
      Chi5PC_Retry_Crdgrnt #(.MAX_OS_REQ (MAX_OS_REQ), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .numChi5nodes(numChi5nodes), .MODE(0))
      u_s_Retry_Crdgrnt
      ( .SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         );
      end
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );
      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_rx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.S_RSP_Addr_NS(S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
     );
      assign m_RXDAT_match = 1'b0;
      assign m_TXDAT_match = 1'b0;
      assign m_RXRSP_match = 1'b0;
      assign m_TXRSP_match = 1'b0;
      assign snp_DAT_match = 1'b0;
      assign snp_RSP_match = 1'b0;
    end
    SNI:
    begin : sn
      wire  RDDAT_Last;
      wire [44:0] S_RSP_Addr_NS;
      wire [43:5] RDDAT_Addr_NS;
      wire [43:5] WRDAT_Addr_NS;
      wire [3:0]  S_RSP_Dev_Size;
      Chi5PC_FlitTrace #(.NODE_TYPE(NODE_TYPE), .MAX_OS_REQ (MAX_OS_REQ),.numChi5nodes(numChi5nodes),.MODE(0),.RecommendOn(RecommendOn),.RecommendOn_Haz(RecommendOn_Haz), .ErrorOn_Data_X(ErrorOn_Data_X), .Barrier_Order(Barrier_Order), .CRDGRANT_BEFORE_RETRY(CRDGRANT_BEFORE_RETRY), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .PCMODE(PCMODE), .ErrorOn_SW(ErrorOn_SW))
      u_s_FlitTrace
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.REQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.WRDATFLITV_(Chi5_in.RXDATFLITV)
         ,.WRDATFLIT_(Chi5_in.RXDATFLIT)
         ,.WRDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.RDDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.M_RSPFLITV_(1'b0)
         ,.M_RSPFLIT_(`CHI5PC_RSP_FLIT_WIDTH'b0)
         ,.TXRSPLCRDV_(1'b0)
         ,.SNPFLITV_(1'b0)
         ,.SNPFLIT_(`CHI5PC_SNP_FLIT_WIDTH'b0)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.SACTIVE_(Chi5_in.TXSACTIVE)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDAT_match (s_RXDAT_match)
         ,.WRDAT_match (s_TXDAT_match)
         ,.RXRSP_match (s_RXRSP_match)
         ,.TXRSP_match (s_TXRSP_match)
         ,.S_RSP_Comp_Haz ( )
         ,.S_RSP_Addr_NS (S_RSP_Addr_NS )
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
         ,.RDDAT_Addr_NS ( )
         ,.RDDAT_Comp_Haz ( )
         ,.WRDAT_Addr_NS ( )
      );
      if (CRDGRANT_BEFORE_RETRY)
      begin : Chi5PC_Retry_Crdgrnt
      Chi5PC_Retry_Crdgrnt #(.MAX_OS_REQ (MAX_OS_REQ), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH),.numChi5nodes(numChi5nodes), .MODE(0))
      u_s_Retry_Crdgrnt
      ( .SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         );
      end
      Chi5PC_XLA #(.MAXLLCREDITS_IN_RXDEACTIVATE(MAXLLCREDITS_IN_RXDEACTIVATE),.PCMODE (PCMODE), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH))
      u_Chi5PC_XLA
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.TXLINKACTIVEREQ_(Chi5_in.TXLINKACTIVEREQ)
         ,.TXLINKACTIVEACK_(Chi5_in.TXLINKACTIVEACK)
         ,.TXREQFLITV_(Chi5_in.TXREQFLITV)
         ,.TXREQFLIT_(Chi5_in.TXREQFLIT)
         ,.TXREQLCRDV_(Chi5_in.TXREQLCRDV)
         ,.TXRSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.TXRSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.TXRSPLCRDV_(Chi5_in.TXRSPLCRDV)
         ,.TXDATFLITV_(Chi5_in.TXDATFLITV)
         ,.TXDATFLIT_(Chi5_in.TXDATFLIT)
         ,.TXDATLCRDV_(Chi5_in.TXDATLCRDV)
         ,.TXSNPFLITV_(Chi5_in.TXSNPFLITV)
         ,.TXSNPFLIT_(Chi5_in.TXSNPFLIT)
         ,.TXSNPLCRDV_(Chi5_in.TXSNPLCRDV)
         ,.TXREQFLITPEND_(Chi5_in.TXREQFLITPEND)
         ,.TXRSPFLITPEND_(Chi5_in.TXRSPFLITPEND)
         ,.TXDATFLITPEND_(Chi5_in.TXDATFLITPEND)
         ,.TXSNPFLITPEND_(Chi5_in.TXSNPFLITPEND)
         ,.TXSACTIVE_(Chi5_in.TXSACTIVE)
         ,.RXLINKACTIVEREQ_(Chi5_in.RXLINKACTIVEREQ)
         ,.RXLINKACTIVEACK_(Chi5_in.RXLINKACTIVEACK)
         ,.RXREQFLITV_(Chi5_in.RXREQFLITV)
         ,.RXREQFLIT_(Chi5_in.RXREQFLIT)
         ,.RXREQLCRDV_(Chi5_in.RXREQLCRDV)
         ,.RXRSPFLITV_(Chi5_in.RXRSPFLITV)
         ,.RXRSPFLIT_(Chi5_in.RXRSPFLIT)
         ,.RXRSPLCRDV_(Chi5_in.RXRSPLCRDV)
         ,.RXDATFLITV_(Chi5_in.RXDATFLITV)
         ,.RXDATFLIT_(Chi5_in.RXDATFLIT)
         ,.RXDATLCRDV_(Chi5_in.RXDATLCRDV)
         ,.RXSNPFLITV_(Chi5_in.RXSNPFLITV)
         ,.RXSNPFLIT_(Chi5_in.RXSNPFLIT)
         ,.RXSNPLCRDV_(Chi5_in.RXSNPLCRDV)
         ,.RXREQFLITPEND_(Chi5_in.RXREQFLITPEND)
         ,.RXRSPFLITPEND_(Chi5_in.RXRSPFLITPEND)
         ,.RXDATFLITPEND_(Chi5_in.RXDATFLITPEND)
         ,.RXSNPFLITPEND_(Chi5_in.RXSNPFLITPEND)
         ,.RXSACTIVE_(Chi5_in.RXSACTIVE)
      );

      Chi5PC_EXCL #(.NODE_TYPE(NODE_TYPE), .MAX_OS_EXCL(MAX_OS_EXCL),.MODE(0), .DAT_FLIT_WIDTH(DAT_FLIT_WIDTH), .REQ_RSVDC_WIDTH(REQ_RSVDC_WIDTH), .DAT_RSVDC_WIDTH(DAT_RSVDC_WIDTH), .ErrorOn_SW(ErrorOn_SW))
        u_rx_EXCL
        (.SCLK  (`CHI5_SVA_CLK)
         ,.Chi5_in (Chi5_in)
         ,.SRESETn(Chi5_in.SRESETn)
         ,.REQFLITV_(Chi5_in.RXREQFLITV)
         ,.REQFLIT_(Chi5_in.RXREQFLIT)
         ,.S_RSPFLITV_(Chi5_in.TXRSPFLITV)
         ,.S_RSPFLIT_(Chi5_in.TXRSPFLIT)
         ,.RDDAT_Last_(RDDAT_Last)
         ,.RDDATFLITV_(Chi5_in.TXDATFLITV)
         ,.RDDATFLIT_(Chi5_in.TXDATFLIT)
         ,.S_RSP_Addr_NS(S_RSP_Addr_NS)
         ,.S_RSP_Dev_Size (S_RSP_Dev_Size)
         ,.S_RSP_Comp_Wr (S_RSP_Comp_Wr)
     );
      assign m_RXDAT_match = 1'b0;
      assign m_TXDAT_match = 1'b0;
      assign m_RXRSP_match = 1'b0;
      assign m_TXRSP_match = 1'b0;
      assign snp_DAT_match = 1'b0;
      assign snp_RSP_match = 1'b0;
    end
  endcase
endgenerate
//------------------------------------------------------------------------------
// INDEX:   7)  Reset Checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXFLITV_RESET
  // =====
  property CHI5PC_ERR_REQ_TXFLITV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn)) && HAS_TXREQ
      |-> ~(Chi5_in.TXREQFLITV) ;
  endproperty
  chi5pc_err_req_txflitv_reset: assert property (CHI5PC_ERR_REQ_TXFLITV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXFLITV_RESET: TXREQFLITV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving TXREQFLITV  HIGH is at a rising edge after RESETn is HIGH."));


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXLCRDV_RESET
  // =====
  // Request Flit Valid signal REQLCRDV must be de-asserted on RESET 
  property CHI5PC_ERR_REQ_RXLCRDV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn)) && HAS_RXREQ
      |-> ~(Chi5_in.RXREQLCRDV);
  endproperty
  chi5pc_err_req_rxlcrdv_reset: assert property (CHI5PC_ERR_REQ_RXLCRDV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXLCRDV_RESET: RXREQLCRDV  must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving RXREQLCRDV HIGH is at a rising edge after RESETn is HIGH."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXFLITV_RESET
  // =====
  // Request Flit Valid signal DATFLITV must be de-asserted on RESET 
  property CHI5PC_ERR_DAT_TXFLITV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn))
      |-> !Chi5_in.TXDATFLITV;
  endproperty
  chi5pc_err_dat_txflitv_reset: assert property (CHI5PC_ERR_DAT_TXFLITV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXFLITV_RESET: TXDATFLITV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving TXDATFLITV  HIGH is at a rising edge after RESETn is HIGH."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXLCRDV_RESET
  // =====
  // Request Flit Valid signal DATLCRDV must be de-asserted on RESET 
  property CHI5PC_ERR_DAT_RXLCRDV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn))
      |-> !Chi5_in.RXDATLCRDV  ;
  endproperty
  chi5pc_err_dat_rxlcrdv_reset: assert property (CHI5PC_ERR_DAT_RXLCRDV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXLCRDV_RESET: RXDATLCRDV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving RXDATLCRDV  HIGH is at a rising edge after RESETn is HIGH."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXFLITV_RESET
  // =====
  // Request Flit Valid signal RSPFLITV must be de-asserted on RESET 
  property CHI5PC_ERR_RSP_TXFLITV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn))
      |-> !(Chi5_in.TXRSPFLITV); 
  endproperty
  chi5pc_err_rsp_txflitv_reset: assert property (CHI5PC_ERR_RSP_TXFLITV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXFLITV_RESET: TXRSPFLITV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving TXRSPFLITV  HIGH is at a rising edge after RESETn is HIGH."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXLCRDV_RESET
  // =====
  // Request Flit Valid signal RSPLCRDV must be de-asserted on RESET 
  property CHI5PC_ERR_RSP_RXLCRDV_RESET;
     @(posedge `CHI5_SVA_CLK)
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn)) && HAS_RXRSP
      |-> !(Chi5_in.RXRSPLCRDV) ;
  endproperty
  chi5pc_err_rsp_rxlcrdv_reset: assert property (CHI5PC_ERR_RSP_RXLCRDV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXLCRDV_RESET: RXRSPLCRDV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving RXRSPLCRDV  HIGH is at a rising edge after RESETn is HIGH."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXFLITV_RESET
  // =====
  // Request Flit Valid signal SNPFLITV must be de-asserted on RESET 
  property CHI5PC_ERR_SNP_TXFLITV_RESET;
     @(posedge `CHI5_SVA_CLK) 
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn)) && HAS_TXSNP
      |-> ~(Chi5_in.TXSNPFLITV) ;
  endproperty
  chi5pc_err_snp_txflitv_reset: assert property (CHI5PC_ERR_SNP_TXFLITV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXFLITV_RESET: TXSNPFLITV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving TXSNPFLITV  HIGH is at a rising edge after RESETn is HIGH."));


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXLCRDV_RESET
  // =====
  // Request Flit Valid signal SNPLCRDV must be de-asserted on RESET 
  property CHI5PC_ERR_SNP_RXLCRDV_RESET;
     @(posedge `CHI5_SVA_CLK) 
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn)) && HAS_RXSNP
      |-> ~(Chi5_in.RXSNPLCRDV) ;
  endproperty
  chi5pc_err_snp_rxlcrdv_reset: assert property (CHI5PC_ERR_SNP_RXLCRDV_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXLCRDV_RESET: RXSNPLCRDV must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving RXSNPLCRDV  HIGH is at a rising edge after RESETn is HIGH."));


  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXLINKACTIVEREQ_RESET
  // =====
  property CHI5PC_ERR_LNK_TXLINKACTIVEREQ_RESET;
     @(posedge `CHI5_SVA_CLK) 
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn))
      |-> ~Chi5_in.TXLINKACTIVEREQ ;
  endproperty
  chi5pc_err_lnk_txlinkactivereq_reset: assert property (CHI5PC_ERR_LNK_TXLINKACTIVEREQ_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXLINKACTIVEREQ_RESET: TXLINKACTIVEREQ must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving TXLINKACTIVEREQ  HIGH is at a rising edge after RESETn is HIGH."));


  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXLINKACTIVEACK_RESET
  // =====
  // signal RXLINKACTIVEACK must be de-asserted on RESET 
  property CHI5PC_ERR_LNK_RXLINKACTIVEACK_RESET;
     @(posedge `CHI5_SVA_CLK) 
          (~$past(`CHI5_SVA_RSTn) && (`CHI5_SVA_RSTn)) && !($isunknown(`CHI5_SVA_RSTn))
      |-> ~Chi5_in.RXLINKACTIVEACK ;
  endproperty
  chi5pc_err_lnk_rxlinkactiveack_reset: assert property (CHI5PC_ERR_LNK_RXLINKACTIVEACK_RESET) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXLINKACTIVEACK_RESET: RXLINKACTIVEACK must be deasserted during RESET. The earliest point after reset that it is permitted to begin driving RXLINKACTIVEACK  HIGH is at a rising edge after RESETn is HIGH."));


//------------------------------------------------------------------------------
// INDEX:   8)  Credit Checks
//------------------------------------------------------------------------------ 
//

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXCRD_OVFLW
  // =====
  // Max TXREQ Link layer credits overflow
  property CHI5PC_ERR_REQ_TXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({TXREQ_Credits,Chi5_in.TXREQLCRDV}))
          && (TXREQ_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.TXREQLCRDV;
  endproperty
  chi5pc_err_req_txcrd_ovflw: assert property (CHI5PC_ERR_REQ_TXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXCRD_OVFLW: The number of link-layer credits on the TXREQ channel has exceeded MAXLLCREDITS."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXCRD_OVFLW
  // =====
  // Max RXREQ Link layer credits overflow
  property CHI5PC_ERR_REQ_RXCRD_OVFLW;  
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({RXREQ_Credits,Chi5_in.RXREQLCRDV}))
          && (RXREQ_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.RXREQLCRDV || Chi5_in.RXREQFLITV;
  endproperty
  chi5pc_err_req_rxcrd_ovflw: assert property (CHI5PC_ERR_REQ_RXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXCRD_OVFLW: The number of link-layer credits on the RXREQ channel has exceeded MAXLLCREDITS."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXCRD_OVFLW
  // =====
  // Max TXDAT Link layer credits overflow
  property CHI5PC_ERR_DAT_TXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({TXDAT_Credits,Chi5_in.TXDATLCRDV}))
          && (TXDAT_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.TXDATLCRDV;
  endproperty
  chi5pc_err_dat_txcrd_ovflw: assert property (CHI5PC_ERR_DAT_TXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXCRD_OVFLW: The number of link-layer credits on the TXDAT channel has exceeded MAXLLCREDITS."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXCRD_OVFLW
  // =====
  // Max RXDAT Link layer credits overflow
  property CHI5PC_ERR_DAT_RXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({RXDAT_Credits,Chi5_in.RXDATLCRDV}))
          && (RXDAT_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.RXDATLCRDV || Chi5_in.RXDATFLITV;
  endproperty
  chi5pc_err_dat_rxcrd_ovflw: assert property (CHI5PC_ERR_DAT_RXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXCRD_OVFLW: The number of link-layer credits on the RXDAT channel has exceeded MAXLLCREDITS."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXCRD_OVFLW
  // =====
  // Max TXSNP Link layer credits overflow
  property CHI5PC_ERR_SNP_TXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({TXSNP_Credits,Chi5_in.TXSNPLCRDV}))
          && (TXSNP_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.TXSNPLCRDV ;
  endproperty
  chi5pc_err_snp_txcrd_ovflw: assert property (CHI5PC_ERR_SNP_TXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXCRD_OVFLW: The number of link-layer credits on the TXSNP channel has exceeded MAXLLCREDITS."));


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXCRD_OVFLW
  // =====
  // Max RXSNP Link layer credits overflow
  property CHI5PC_ERR_SNP_RXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({RXSNP_Credits,Chi5_in.RXSNPLCRDV}))
          && (RXSNP_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.RXSNPLCRDV || Chi5_in.RXSNPFLITV;
  endproperty
  chi5pc_err_snp_rxcrd_ovflw: assert property (CHI5PC_ERR_SNP_RXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXCRD_OVFLW: The number of link-layer credits on the RXSNP channel has exceeded MAXLLCREDITS."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXCRD_OVFLW
  // =====
  // Max TXRSP Link layer credits overflow
  property CHI5PC_ERR_RSP_TXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({TXRSP_Credits,Chi5_in.TXRSPLCRDV}))
          && (TXRSP_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.TXRSPLCRDV ;
  endproperty
  chi5pc_err_rsp_txcrd_ovflw: assert property (CHI5PC_ERR_RSP_TXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXCRD_OVFLW: The number of link-layer credits on the TXRSP channel has exceeded MAXLLCREDITS."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXCRD_OVFLW
  // =====   

  // Max RXRSP Link layer credits overflow
  property CHI5PC_ERR_RSP_RXCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({RXRSP_Credits,Chi5_in.RXRSPLCRDV}))
          && (RXRSP_Credits == Chi5_in.MAXLLCREDITS)
      |-> ~Chi5_in.RXRSPLCRDV || Chi5_in.RXRSPFLITV;
  endproperty
  chi5pc_err_rsp_rxcrd_ovflw: assert property (CHI5PC_ERR_RSP_RXCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXCRD_OVFLW: The number of link-layer credits on the RXRSP channel has exceeded MAXLLCREDITS."));


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXCRD_UNFLW
  // =====
  // TXREQ Link layer credits underflow
  property CHI5PC_ERR_REQ_TXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({TXREQ_Credits,Chi5_in.TXREQFLITV}))
       && ~|TXREQ_Credits
      |-> !Chi5_in.TXREQFLITV;
  endproperty
  chi5pc_err_req_txcrd_unflw: assert property (CHI5PC_ERR_REQ_TXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXCRD_UNFLW: Link layer credit underflow on TXREQ channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXCRD_UNFLW
  // =====
  // RXREQ Link layer credits underflow
  property CHI5PC_ERR_REQ_RXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RXREQ_Credits,Chi5_in.RXREQFLITV}))
       && ~|RXREQ_Credits
      |-> !Chi5_in.RXREQFLITV;
  endproperty
  chi5pc_err_req_rxcrd_unflw: assert property (CHI5PC_ERR_REQ_RXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXCRD_UNFLW: Link layer credit underflow on RXREQ channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXCRD_UNFLW
  // =====
  // TXDAT Link layer credits underflow
  property CHI5PC_ERR_DAT_TXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({TXDAT_Credits,Chi5_in.TXDATLCRDV}))
       && ~|TXDAT_Credits
      |-> !Chi5_in.TXDATFLITV;
  endproperty
  chi5pc_err_dat_txcrd_unflw: assert property (CHI5PC_ERR_DAT_TXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXCRD_UNFLW: Link layer credit underflow on TXDAT channel."));

  // INDEX:        - CHI5PC_ERR_DAT_RXCRD_UNFLW
  // =====
  // RXDAT Link layer credits underflow
  property CHI5PC_ERR_DAT_RXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RXDAT_Credits,Chi5_in.RXDATLCRDV}))
       && ~|RXDAT_Credits
      |-> !Chi5_in.RXDATFLITV;
  endproperty
  chi5pc_err_dat_rxcrd_unflw: assert property (CHI5PC_ERR_DAT_RXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXCRD_UNFLW: Link layer credit underflow on RXDAT channel."));


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXCRD_UNFLW
  // =====
  // TXSNP Link layer credits underflow
  property CHI5PC_ERR_SNP_TXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({TXSNP_Credits,Chi5_in.TXSNPLCRDV}))
       && ~|TXSNP_Credits
      |-> !Chi5_in.TXSNPFLITV;
  endproperty
  chi5pc_err_snp_txcrd_unflw: assert property (CHI5PC_ERR_SNP_TXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXCRD_UNFLW: Link layer credit underflow on TXSNP channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXCRD_UNFLW
  // =====
  // RXSNP Link layer credits underflow
  property CHI5PC_ERR_SNP_RXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RXSNP_Credits,Chi5_in.RXSNPLCRDV}))
       && ~|RXSNP_Credits
      |-> !Chi5_in.RXSNPFLITV;
  endproperty
  chi5pc_err_snp_rxcrd_unflw: assert property (CHI5PC_ERR_SNP_RXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXCRD_UNFLW: Link layer credit underflow on RXSNP channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXCRD_UNFLW
  // =====
  // TXRSP Link layer credits underflow
  property CHI5PC_ERR_RSP_TXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({TXRSP_Credits,Chi5_in.TXRSPLCRDV}))
       && ~|TXRSP_Credits
      |-> !Chi5_in.TXRSPFLITV;
  endproperty
  chi5pc_err_rsp_txcrd_unflw: assert property (CHI5PC_ERR_RSP_TXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXCRD_UNFLW: Link layer credit underflow on TXRSP channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXCRD_UNFLW
  // =====
  // RXRSP Link layer credits underflow
  property CHI5PC_ERR_RSP_RXCRD_UNFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RXRSP_Credits,Chi5_in.RXRSPLCRDV}))
       && ~|RXRSP_Credits
      |-> !Chi5_in.RXRSPFLITV;
  endproperty
  chi5pc_err_rsp_rxcrd_unflw: assert property (CHI5PC_ERR_RSP_RXCRD_UNFLW) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXCRD_UNFLW: Link layer credit underflow on RXRSP channel."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXDEACT_CRD
  // =====
  // TXLINKACTIVE must not be deasserted while there are tx flit credits
  property CHI5PC_ERR_LNK_TXDEACT_CRD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({TXREQ_Credits,TXRSP_Credits,TXDAT_Credits,TXSNP_Credits,Chi5_in.TXLINKACTIVEACK}))
       && (|TXREQ_Credits || |TXRSP_Credits || |TXDAT_Credits || |TXSNP_Credits ||
           |next_TXREQ_Credits || |next_TXRSP_Credits || |next_TXDAT_Credits || |next_TXSNP_Credits) 
           &&  !Chi5_in.TXLINKACTIVEREQ
      |-> Chi5_in.TXLINKACTIVEACK;
  endproperty
  chi5pc_err_lnk_txdeact_crd: assert property (CHI5PC_ERR_LNK_TXDEACT_CRD) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXDEACT_CRD: TXLINKACTIVEACK must not be deasserted when the transmit link has active credits."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXDEACT_CRD
  // =====
  // RXLINKACTIVEACK must not be deasserted while there are RX flit credits
  property CHI5PC_ERR_LNK_RXDEACT_CRD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RXREQ_Credits,RXRSP_Credits,RXDAT_Credits,RXSNP_Credits,Chi5_in.RXLINKACTIVEACK}))
       && (|RXREQ_Credits || |RXRSP_Credits || |RXDAT_Credits || |RXSNP_Credits || 
           |next_RXREQ_Credits || |next_RXRSP_Credits || |next_RXDAT_Credits || |next_RXSNP_Credits) 
           &&  !Chi5_in.RXLINKACTIVEREQ
      |-> Chi5_in.RXLINKACTIVEACK;
  endproperty
  chi5pc_err_lnk_rxdeact_crd: assert property (CHI5PC_ERR_LNK_RXDEACT_CRD) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXDEACT_CRD: RXLINKACTIVEACK must not be deasserted when the receive link has active credits."));


//------------------------------------------------------------------------------
// INDEX:    9)  Transaction match checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXMATCH
  // =====

 property CHI5PC_ERR_RSP_TXMATCH; 
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && Chi5_in.TXRSPFLITV && 
      (Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDGRANT) && 
      (Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)
      |-> ((NODE_TYPE == RNF) || (NODE_TYPE == RND)) ? $onehot({snp_RSP_match,m_TXRSP_match}) :
          $onehot({m_TXRSP_match,s_RXRSP_match});
  endproperty
  chi5pc_err_rsp_txmatch: assert property (CHI5PC_ERR_RSP_TXMATCH) else
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXMATCH: No matching transaction found for the response flit on TXRSPFLIT."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXMATCH
  // =====
 property CHI5PC_ERR_RSP_RXMATCH; 
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && Chi5_in.RXRSPFLITV && 
      (Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDGRANT) && 
      (Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)
      |-> ((NODE_TYPE_HAS_HNF) || (NODE_TYPE_HAS_MN)) ? $onehot({snp_RSP_match,m_RXRSP_match,s_TXRSP_match}) :
          $onehot({m_RXRSP_match,s_TXRSP_match});
  endproperty
  chi5pc_err_rsp_rxmatch: assert property (CHI5PC_ERR_RSP_RXMATCH) else
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXMATCH: No matching transaction found for the response flit on RXRSPFLIT."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXMATCH
  // =====
 property CHI5PC_ERR_DAT_TXMATCH;
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && Chi5_in.TXDATFLITV && 
      (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (NODE_TYPE == RNF) || (NODE_TYPE == RND) ? $onehot({snp_DAT_match,m_TXDAT_match}) :
          (NODE_TYPE_HAS_HNF) || (NODE_TYPE_HAS_MN) ? $onehot({s_RXDAT_match,m_TXDAT_match}) :
          $onehot({m_TXDAT_match,s_RXDAT_match});
  endproperty
  chi5pc_err_dat_txmatch: assert property (CHI5PC_ERR_DAT_TXMATCH) else
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXMATCH: No matching transaction found for the data flit on TXDATFLIT."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXMATCH
  // =====
 property CHI5PC_ERR_DAT_RXMATCH; 
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && Chi5_in.RXDATFLITV && 
      (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (NODE_TYPE_HAS_HNF) || (NODE_TYPE_HAS_MN) ? $onehot({snp_DAT_match,m_RXDAT_match,s_TXDAT_match}) :
          $onehot({m_RXDAT_match,s_TXDAT_match});
  endproperty
  chi5pc_err_dat_rxmatch: assert property (CHI5PC_ERR_DAT_RXMATCH) else
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXMATCH: No matching transaction found for the data flit on RXDATFLIT."));




//------------------------------------------------------------------------------
// INDEX:   10)  REQ channel Checks
//------------------------------------------------------------------------------ 
//

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXSRCID
  // =====
  // TXREQ SrcID matches the local ID 
  property CHI5PC_ERR_REQ_TXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXREQFLITV,Chi5_in.TXREQFLIT}))
       && Chi5_in.TXREQFLITV
       && (Chi5_in.TXREQFLIT[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> Chi5_in.TXREQFLIT[`CHI5PC_REQ_FLIT_SRCID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_req_txsrcid: assert property (CHI5PC_ERR_REQ_TXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXSRCID: A message sent on the TXREQ channel must have a SrcID value that matches the local node ID."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXTGTID
  // =====
  // TXREQ TgtID must match an existing node
  property CHI5PC_ERR_REQ_TXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXREQFLITV,Chi5_in.TXREQFLIT}))
       && Chi5_in.TXREQFLITV
       && (Chi5_in.TXREQFLIT[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> TXREQ_TGTID_exists;
  endproperty
  chi5pc_err_req_txtgtid: assert property (CHI5PC_ERR_REQ_TXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXTGTID: A message sent on the TXREQ channel must have a (remapped) TgtID value that matches the ID of an existing node."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXTGTID
  // =====
  // RXREQ TgtID matches the local ID 
  property CHI5PC_ERR_REQ_RXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXREQFLITV,Chi5_in.RXREQFLIT}))
       && Chi5_in.RXREQFLITV
       && (Chi5_in.RXREQFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> Chi5_in.RXREQFLIT[`CHI5PC_REQ_FLIT_TGTID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_req_rxtgtid: assert property (CHI5PC_ERR_REQ_RXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXTGTID: A message received on the RXREQ channel must have a TgtID value that matches the local node ID."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXSRCID
  // =====
  // RXREQ SrcID must match an existing node
  property CHI5PC_ERR_REQ_RXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXREQFLITV,Chi5_in.RXREQFLIT}))
       && Chi5_in.RXREQFLITV
       && (Chi5_in.RXREQFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> RXREQ_SRCID_exists;
  endproperty
  chi5pc_err_req_rxsrcid: assert property (CHI5PC_ERR_REQ_RXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXSRCID: A message received on the RXREQ channel must have a SrcID value that matches the ID of an existing node."));

//------------------------------------------------------------------------------
// INDEX:   11)  TXDAT channel Checks
//------------------------------------------------------------------------------ 
//

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXSRCID
  // =====
  // TXDAT SrcID matches the local ID 
  property CHI5PC_ERR_DAT_TXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXDATFLITV,Chi5_in.TXDATFLIT}))
       && Chi5_in.TXDATFLITV
       && (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_SRCID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_dat_txsrcid: assert property (CHI5PC_ERR_DAT_TXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXSRCID: Data flits on the TXDAT channel must have a SrcID value that matches the local node ID."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXTGTID
  // =====
  property CHI5PC_ERR_DAT_TXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXDATFLITV,Chi5_in.TXDATFLIT}))
       && Chi5_in.TXDATFLITV
       && (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> TXDAT_TGTID_exists;
  endproperty
  chi5pc_err_dat_txtgtid: assert property (CHI5PC_ERR_DAT_TXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXTGTID: Data flits on the TXDAT channel must have a TgtID value that matches the ID of an existing node."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_LINKFLIT_TX
  // =====
  property CHI5PC_ERR_DAT_CTL_LINKFLIT_TX;
      @(posedge `CHI5_SVA_CLK)
         `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXDATFLITV,Chi5_in.TXDATFLIT}))
         && Chi5_in.TXDATFLITV && Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_DATLINKFLIT
        |-> Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_TXNID_RANGE] == 'b0;
    endproperty
    chi5pc_err_dat_ctl_linkflit_tx: assert property (CHI5PC_ERR_DAT_CTL_LINKFLIT_TX) else
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_CTL_LINKFLIT_TX: Data flits on the TXDAT channel with opcode DatLinkFlit must have TxnID = 'b0."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_OPCODE_TX
  // =====
  property CHI5PC_ERR_DAT_RSVD_OPCODE_TX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXDATFLITV,Chi5_in.TXDATFLIT}))
        && Chi5_in.TXDATFLITV
       |-> (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] < 6);

  endproperty
  chi5pc_err_dat_rsvd_opcode_tx: assert property (CHI5PC_ERR_DAT_RSVD_OPCODE_TX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RSVD_OPCODE_TX: Data flit opcode values 0x6 and 0x7 are reserved (TXDAT channel)."));

//------------------------------------------------------------------------------
// INDEX:   12)  RXDAT channel Checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXTGTID
  // =====
  // RXDAT TgtID matches the local ID 
  property CHI5PC_ERR_DAT_RXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXDATFLITV,Chi5_in.RXDATFLIT}))
       && Chi5_in.RXDATFLITV
      && (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_TGTID_RANGE] == Chi5_in.NODE_ID ;
  endproperty
  chi5pc_err_dat_rxtgtid: assert property (CHI5PC_ERR_DAT_RXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXTGTID: Data flits received on the RXDAT channel must have a TgtID value that matches the local node ID."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXSRCID
  // =====
  // RXDAT SrcID must match an existing node
  property CHI5PC_ERR_DAT_RXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXDATFLITV,Chi5_in.RXDATFLIT}))
       && Chi5_in.RXDATFLITV
       && (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> RXDAT_SRCID_exists;
  endproperty
  chi5pc_err_dat_rxsrcid: assert property (CHI5PC_ERR_DAT_RXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXSRCID: Data flits received on the RXDAT channel must have a SrcID value that matches the ID of an existing node."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_LINKFLIT_RX
  // =====
    property CHI5PC_ERR_DAT_CTL_LINKFLIT_RX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXDATFLITV,Chi5_in.RXDATFLIT}))
       && Chi5_in.RXDATFLITV && Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_DATLINKFLIT
      |-> Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_TXNID_RANGE] == 'b0;
  endproperty
  chi5pc_err_dat_ctl_linkflit_rx: assert property (CHI5PC_ERR_DAT_CTL_LINKFLIT_RX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_CTL_LINKFLIT_RX: Data flits on the RXDAT channel with opcode DatLinkFlit must have TxnID = 'b0."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_OPCODE_RX
  // =====
  property CHI5PC_ERR_DAT_RSVD_OPCODE_RX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXDATFLITV,Chi5_in.RXDATFLIT}))
        && Chi5_in.RXDATFLITV
       |-> (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] < 6);

  endproperty
  chi5pc_err_dat_rsvd_opcode_rx: assert property (CHI5PC_ERR_DAT_RSVD_OPCODE_RX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RSVD_OPCODE_RX: Data flit opcode values 0x6 and 0x7 are reserved (RXDAT channel)."));


  
//------------------------------------------------------------------------------
// INDEX:   13)  TXSNP channel Checks
//------------------------------------------------------------------------------ 
//
  // TXSNP SrcID matches the local ID 
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXSRCID
  // =====
  property CHI5PC_ERR_SNP_TXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXSNPFLITV,Chi5_in.TXSNPFLIT}))
       && Chi5_in.TXSNPFLITV
       && (Chi5_in.TXSNPFLIT[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
      |-> Chi5_in.TXSNPFLIT[`CHI5PC_SNP_FLIT_SRCID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_snp_txsrcid: assert property (CHI5PC_ERR_SNP_TXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXSRCID: A message sent on the TXSNP channel must have a SrcID value that matches the local node ID."));


//------------------------------------------------------------------------------
// INDEX:   14)  RXSNP channel Checks
//------------------------------------------------------------------------------ 
//
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXSRCID
  // =====
  property CHI5PC_ERR_SNP_RXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXSNPFLITV,Chi5_in.RXSNPFLIT}))
       && Chi5_in.RXSNPFLITV
       && (Chi5_in.RXSNPFLIT[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
      |-> RXSNP_SRCID_exists;
  endproperty
  chi5pc_err_snp_rxsrcid: assert property (CHI5PC_ERR_SNP_RXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXSRCID: A message received on the RXSNP channel must have a SrcID value that matches the ID of an existing node."));



//------------------------------------------------------------------------------
// INDEX:   15)  TXRSP channel Checks
//------------------------------------------------------------------------------ 
//

  // TXRSP SrcID matches the local ID 
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXSRCID
  // =====
  property CHI5PC_ERR_RSP_TXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXRSPFLITV,Chi5_in.TXRSPFLIT}))
       && Chi5_in.TXRSPFLITV
       && (Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)
      |-> Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_SRCID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_rsp_txsrcid: assert property (CHI5PC_ERR_RSP_TXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXSRCID: Response flits on the TXRSP channel must have a SrcID value that matches the local node ID."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXTGTID
  // =====
  property CHI5PC_ERR_RSP_TXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXRSPFLITV,Chi5_in.TXRSPFLIT}))
       && Chi5_in.TXRSPFLITV
       && (Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)
      |-> TXRSP_TGTID_exists;
  endproperty
  chi5pc_err_rsp_txtgtid: assert property (CHI5PC_ERR_RSP_TXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXTGTID: Response flits on the TXRSP channel must have a TgtID value that matches the ID of an existing node."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_LINKFLIT_TX
  // =====
  property CHI5PC_ERR_RSP_CTL_LINKFLIT_TX;
      @(posedge `CHI5_SVA_CLK)
         `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXRSPFLITV,Chi5_in.TXRSPFLIT}))
         && Chi5_in.TXRSPFLITV && Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RSPLINKFLIT
        |-> Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_TXNID_RANGE] == 'b0;
    endproperty
    chi5pc_err_rsp_ctl_linkflit_tx: assert property (CHI5PC_ERR_RSP_CTL_LINKFLIT_TX) else
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_CTL_LINKFLIT_TX: Response flits on the TXRSP channel with opcode RspLinkFlit must have TxnID = 'b0."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RSVD_OPCODE_TX
  // =====
  property CHI5PC_ERR_RSP_RSVD_OPCODE_TX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXRSPFLITV,Chi5_in.TXRSPFLIT}))
       && Chi5_in.TXRSPFLITV 
       && (Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT)
      |-> Chi5_in.TXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] <= `CHI5PC_READRECEIPT;
  endproperty
  chi5pc_err_rsp_rsvd_opcode_tx: assert property (CHI5PC_ERR_RSP_RSVD_OPCODE_TX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RSVD_OPCODE_TX: Response flit opcode values 0x9, 0xA, 0xB, 0xC, 0xD, 0xE and 0xF are reserved (TXRSP channel)."));


//------------------------------------------------------------------------------
// INDEX:   16)  RXRSP channel Checks
//------------------------------------------------------------------------------ 
//

  // RXRSP SrcID matches the local ID 
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXTGTID
  // =====
  property CHI5PC_ERR_RSP_RXTGTID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXRSPFLITV,Chi5_in.RXRSPFLIT}))
       && Chi5_in.RXRSPFLITV
       && (Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
      |-> Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_TGTID_RANGE] == Chi5_in.NODE_ID;
  endproperty
  chi5pc_err_rsp_rxtgtid: assert property (CHI5PC_ERR_RSP_RXTGTID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXTGTID: Response flits received on the RXRSP channel must have a TgtID value that matches the local node ID."));

  // RXRSP SrcID must match an existing node
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXSRCID
  // =====
  property CHI5PC_ERR_RSP_RXSRCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXRSPFLITV,Chi5_in.RXRSPFLIT}))
       && Chi5_in.RXRSPFLITV
       && (Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
      |-> RXRSP_SRCID_exists;
  endproperty
  chi5pc_err_rsp_rxsrcid: assert property (CHI5PC_ERR_RSP_RXSRCID) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXSRCID: Response flits received on the RXRSP channel must have a SrcID value that matches the ID of an existing node."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_LINKFLIT_RX
  // =====
  property CHI5PC_ERR_RSP_CTL_LINKFLIT_RX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXRSPFLITV,Chi5_in.RXRSPFLIT}))
       && Chi5_in.RXRSPFLITV && Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RSPLINKFLIT
      |-> Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_TXNID_RANGE] == 'b0;
  endproperty
  chi5pc_err_rsp_ctl_linkflit_rx: assert property (CHI5PC_ERR_RSP_CTL_LINKFLIT_RX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_CTL_LINKFLIT_RX: Response flits on the RXRSP channel with opcode RspLinkFlit must have TxnID = 'b0."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RSVD_OPCODE_RX
  // =====
  property CHI5PC_ERR_RSP_RSVD_OPCODE_RX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXRSPFLITV,Chi5_in.RXRSPFLIT}))
       && Chi5_in.RXRSPFLITV 
      |-> Chi5_in.RXRSPFLIT[`CHI5PC_RSP_FLIT_OPCODE_RANGE] <= `CHI5PC_READRECEIPT;
  endproperty
  chi5pc_err_rsp_rsvd_opcode_rx: assert property (CHI5PC_ERR_RSP_RSVD_OPCODE_RX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RSVD_OPCODE_RX: Response flit opcode values 0x9, 0xA, 0xB, 0xC, 0xD, 0xE and 0xF are reserved (RXRSP channel)."));


//------------------------------------------------------------------------------
// INDEX:   17)  FLITPEND Checks
//------------------------------------------------------------------------------ 
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      TXREQFLITPEND_del <= 1'b0;
      RXREQFLITPEND_del <= 1'b0;
      TXDATFLITPEND_del <= 1'b0;
      RXDATFLITPEND_del <= 1'b0;
      TXRSPFLITPEND_del <= 1'b0;
      RXRSPFLITPEND_del <= 1'b0;
      TXSNPFLITPEND_del <= 1'b0;
      RXSNPFLITPEND_del <= 1'b0;
    end
    else
    begin
      TXREQFLITPEND_del <= Chi5_in.TXREQFLITPEND;
      RXREQFLITPEND_del <= Chi5_in.RXREQFLITPEND;
      TXDATFLITPEND_del <= Chi5_in.TXDATFLITPEND;
      RXDATFLITPEND_del <= Chi5_in.RXDATFLITPEND;
      TXRSPFLITPEND_del <= Chi5_in.TXRSPFLITPEND;
      RXRSPFLITPEND_del <= Chi5_in.RXRSPFLITPEND;
      TXSNPFLITPEND_del <= Chi5_in.TXSNPFLITPEND;
      RXSNPFLITPEND_del <= Chi5_in.RXSNPFLITPEND;
    end
  end 
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXREQFLITPEND
  // =====
  property CHI5PC_ERR_REQ_TXREQFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.TXREQFLITV))
       && Chi5_in.TXREQFLITV && HAS_TXREQ 
      |-> TXREQFLITPEND_del;
  endproperty
  chi5pc_err_req_txreqflitpend: assert property (CHI5PC_ERR_REQ_TXREQFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXREQFLITPEND: TXREQFLITPEND must be asserted one cycle before TXREQFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXREQFLITPEND
  // =====
  property CHI5PC_ERR_REQ_RXREQFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.RXREQFLITV))
       && Chi5_in.RXREQFLITV && HAS_RXREQ 
      |-> RXREQFLITPEND_del;
  endproperty
  chi5pc_err_req_rxreqflitpend: assert property (CHI5PC_ERR_REQ_RXREQFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXREQFLITPEND: RXREQFLITPEND must be asserted one cycle before RXREQFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXDATFLITPEND
  // =====
  property CHI5PC_ERR_DAT_TXDATFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.TXDATFLITV))
       && Chi5_in.TXDATFLITV 
      |-> TXDATFLITPEND_del;
  endproperty
  chi5pc_err_dat_txdatflitpend: assert property (CHI5PC_ERR_DAT_TXDATFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXDATFLITPEND: TXDATFLITPEND must be asserted one cycle before TXDATFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXDATFLITPEND
  // =====
  property CHI5PC_ERR_DAT_RXDATFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.RXDATFLITV))
       && Chi5_in.RXDATFLITV 
      |-> RXDATFLITPEND_del;
  endproperty
  chi5pc_err_dat_rxdatflitpend: assert property (CHI5PC_ERR_DAT_RXDATFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXDATFLITPEND: RXDATFLITPEND must be asserted one cycle before RXDATFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXRSPFLITPEND
  // =====
  property CHI5PC_ERR_RSP_TXRSPFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.TXRSPFLITV))
       && Chi5_in.TXRSPFLITV && HAS_TXRSP 
      |-> TXRSPFLITPEND_del;
  endproperty
  chi5pc_err_rsp_txrspflitpend: assert property (CHI5PC_ERR_RSP_TXRSPFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXRSPFLITPEND: TXRSPFLITPEND must be asserted one cycle before TXRSPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXRSPFLITPEND
  // =====
  property CHI5PC_ERR_RSP_RXRSPFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.RXRSPFLITV))
       && Chi5_in.RXRSPFLITV && HAS_RXRSP 
      |-> RXRSPFLITPEND_del;
  endproperty
  chi5pc_err_rsp_rxrspflitpend: assert property (CHI5PC_ERR_RSP_RXRSPFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXRSPFLITPEND: RXRSPFLITPEND must be asserted one cycle before RXRSPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXSNPFLITPEND
  // =====
  property CHI5PC_ERR_SNP_TXSNPFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.TXSNPFLITV))
       && Chi5_in.TXSNPFLITV && HAS_TXSNP 
      |-> TXSNPFLITPEND_del;
  endproperty
  chi5pc_err_snp_txsnpflitpend: assert property (CHI5PC_ERR_SNP_TXSNPFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXSNPFLITPEND: TXSNPFLITPEND must be asserted one cycle before TXSNPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXSNPFLITPEND
  // =====
  property CHI5PC_ERR_SNP_RXSNPFLITPEND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown(Chi5_in.RXSNPFLITV))
       && Chi5_in.RXSNPFLITV && HAS_RXSNP 
      |-> RXSNPFLITPEND_del;
  endproperty
  chi5pc_err_snp_rxsnpflitpend: assert property (CHI5PC_ERR_SNP_RXSNPFLITPEND) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXSNPFLITPEND: RXSNPFLITPEND must be asserted one cycle before RXSNPFLITV."));

//------------------------------------------------------------------------------
// INDEX:   18)  Connection checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_NOVC_TXREQ
  // =====
  property CHI5PC_ERR_REQ_NOVC_TXREQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXREQFLITV,Chi5_in.TXREQFLITPEND,Chi5_in.TXREQLCRDV }))
       && ~HAS_TXREQ 
      |-> ~Chi5_in.TXREQFLITV && ~Chi5_in.TXREQFLITPEND && ~Chi5_in.TXREQLCRDV;
  endproperty
  chi5pc_err_req_novc_txreq: assert property (CHI5PC_ERR_REQ_NOVC_TXREQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_NOVC_TXREQ: TXREQFLITV, TXREQLCRDV and TXREQFLITPEND must not be asserted on an interface that does not send requests."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_NOVC_RXREQ
  // =====
  property CHI5PC_ERR_REQ_NOVC_RXREQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXREQFLITV,Chi5_in.RXREQFLITPEND,Chi5_in.RXREQLCRDV}))
       && ~HAS_RXREQ 
      |-> ~Chi5_in.RXREQFLITV && ~Chi5_in.RXREQFLITPEND && ~Chi5_in.RXREQLCRDV;
  endproperty
  chi5pc_err_req_novc_rxreq: assert property (CHI5PC_ERR_REQ_NOVC_RXREQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_NOVC_RXREQ: RXREQFLITV, RXREQLCRDV and RXREQFLITPEND must not be asserted on an interface that does not receive requests."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_NOVC_TXSNP
  // =====
  property CHI5PC_ERR_SNP_NOVC_TXSNP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.TXSNPFLITV,Chi5_in.TXSNPFLITPEND,Chi5_in.TXSNPLCRDV}))
       && ~HAS_TXSNP 
      |-> ~Chi5_in.TXSNPFLITV &&  ~Chi5_in.TXSNPFLITPEND && ~Chi5_in.TXSNPLCRDV;
  endproperty
  chi5pc_err_snp_novc_txsnp: assert property (CHI5PC_ERR_SNP_NOVC_TXSNP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_NOVC_TXSNP: TXSNPFLITV, TXSNPLCRDV and TXSNPFLITPEND must not be asserted on an interface that does not send snoops."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_NOVC_RXSNP
  // =====
  property CHI5PC_ERR_SNP_NOVC_RXSNP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXSNPFLITV,Chi5_in.RXSNPFLITPEND,Chi5_in.RXSNPLCRDV}))
       && ~HAS_RXSNP 
      |-> ~Chi5_in.RXSNPFLITV && ~Chi5_in.RXSNPFLITPEND && ~Chi5_in.RXSNPLCRDV;
  endproperty
  chi5pc_err_snp_novc_rxsnp: assert property (CHI5PC_ERR_SNP_NOVC_RXSNP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_NOVC_RXSNP: RXSNPFLITV, RXSNPLCRDV and RXSNPFLITPEND must not be asserted on an interface that does not receive snoops."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_NOVC_RXRSP
  // =====
  property CHI5PC_ERR_RSP_NOVC_RXRSP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({Chi5_in.RXRSPFLITV,Chi5_in.RXRSPFLITPEND,Chi5_in.RXRSPLCRDV}))
       && ~HAS_RXRSP 
      |-> ~Chi5_in.RXRSPFLITV && ~Chi5_in.RXRSPFLITPEND && ~Chi5_in.RXRSPLCRDV;
  endproperty
  chi5pc_err_rsp_novc_rxrsp: assert property (CHI5PC_ERR_RSP_NOVC_RXRSP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_NOVC_RXRSP: RXRSPFLITV, RXRSPLCRDV and RXRSPFLITPEND must not be asserted on an interface that does not receive responses."));
//------------------------------------------------------------------------------
// INDEX:   19)  X checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXLCRDV_X
  // =====
  property CHI5PC_ERR_REQ_TXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXREQ
      |-> ! $isunknown(Chi5_in.TXREQLCRDV);
  endproperty
  chi5pc_err_req_txlcrdv_x:  assert property (CHI5PC_ERR_REQ_TXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXLCRDV_X: A value of X is not allowed on TXREQLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXLCRDV_X
  // =====
  property CHI5PC_ERR_REQ_RXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXREQ
      |-> ! $isunknown(Chi5_in.RXREQLCRDV);
  endproperty
  chi5pc_err_req_rxlcrdv_x:  assert property (CHI5PC_ERR_REQ_RXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXLCRDV_X: A value of X is not allowed on RXREQLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXLCRDV_X
  // =====
  property CHI5PC_ERR_DAT_TXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> ! $isunknown(Chi5_in.TXDATLCRDV);
  endproperty
  chi5pc_err_dat_txlcrdv_x:  assert property (CHI5PC_ERR_DAT_TXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXLCRDV_X: A value of X is not allowed on TXDATLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXLCRDV_X
  // =====
  property CHI5PC_ERR_DAT_RXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> ! $isunknown(Chi5_in.RXDATLCRDV);
  endproperty
  chi5pc_err_dat_rxlcrdv_x:  assert property (CHI5PC_ERR_DAT_RXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXLCRDV_X: A value of X is not allowed on RXDATLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXLCRDV_X
  // =====
  property CHI5PC_ERR_RSP_TXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXRSP
      |-> ! $isunknown(Chi5_in.TXRSPLCRDV);
  endproperty
  chi5pc_err_rsp_txlcrdv_x:  assert property (CHI5PC_ERR_RSP_TXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXLCRDV_X: A value of X is not allowed on TXRSPLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXLCRDV_X
  // =====
  property CHI5PC_ERR_RSP_RXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXRSP
      |-> ! $isunknown(Chi5_in.RXRSPLCRDV);
  endproperty
  chi5pc_err_rsp_rxlcrdv_x:  assert property (CHI5PC_ERR_RSP_RXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXLCRDV_X: A value of X is not allowed on RXRSPLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXLCRDV_X
  // =====
  property CHI5PC_ERR_SNP_TXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXSNP
      |-> ! $isunknown(Chi5_in.TXSNPLCRDV);
  endproperty
  chi5pc_err_snp_txlcrdv_x:  assert property (CHI5PC_ERR_SNP_TXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXLCRDV_X: A value of X is not allowed on TXSNPLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXLCRDV_X
  // =====
  property CHI5PC_ERR_SNP_RXLCRDV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXSNP
      |-> ! $isunknown(Chi5_in.RXSNPLCRDV);
  endproperty
  chi5pc_err_snp_rxlcrdv_x:  assert property (CHI5PC_ERR_SNP_RXLCRDV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXLCRDV_X: A value of X is not allowed on RXSNPLCRDV."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXFLITPEND_X
  // =====
  property CHI5PC_ERR_REQ_TXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXREQ
      |-> ! $isunknown(Chi5_in.TXREQFLITPEND);
  endproperty
  chi5pc_err_req_txflitpend_x:  assert property (CHI5PC_ERR_REQ_TXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXFLITPEND_X: A value of X is not allowed on TXREQFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXFLITPEND_X
  // =====
  property CHI5PC_ERR_REQ_RXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXREQ
      |-> ! $isunknown(Chi5_in.RXREQFLITPEND);
  endproperty
  chi5pc_err_req_rxflitpend_x:  assert property (CHI5PC_ERR_REQ_RXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXFLITPEND_X: A value of X is not allowed on RXREQFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXFLITPEND_X
  // =====
  property CHI5PC_ERR_DAT_TXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> ! $isunknown(Chi5_in.TXDATFLITPEND);
  endproperty
  chi5pc_err_dat_txflitpend_x:  assert property (CHI5PC_ERR_DAT_TXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXFLITPEND_X: A value of X is not allowed on TXDATFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXFLITPEND_X
  // =====
  property CHI5PC_ERR_DAT_RXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> ! $isunknown(Chi5_in.RXDATFLITPEND);
  endproperty
  chi5pc_err_dat_rxflitpend_x:  assert property (CHI5PC_ERR_DAT_RXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXFLITPEND_X: A value of X is not allowed on RXDATFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXFLITPEND_X
  // =====
  property CHI5PC_ERR_RSP_TXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXRSP
      |-> ! $isunknown(Chi5_in.TXRSPFLITPEND);
  endproperty
  chi5pc_err_rsp_txflitpend_x:  assert property (CHI5PC_ERR_RSP_TXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXFLITPEND_X: A value of X is not allowed on TXRSPFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXFLITPEND_X
  // =====
  property CHI5PC_ERR_RSP_RXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXRSP
      |-> ! $isunknown(Chi5_in.RXRSPFLITPEND);
  endproperty
  chi5pc_err_rsp_rxflitpend_x:  assert property (CHI5PC_ERR_RSP_RXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXFLITPEND_X: A value of X is not allowed on RXRSPFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXFLITPEND_X
  // =====
  property CHI5PC_ERR_SNP_TXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_TXSNP
      |-> ! $isunknown(Chi5_in.TXSNPFLITPEND);
  endproperty
  chi5pc_err_snp_txflitpend_x:  assert property (CHI5PC_ERR_SNP_TXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXFLITPEND_X: A value of X is not allowed on TXSNPFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXFLITPEND_X
  // =====
  property CHI5PC_ERR_SNP_RXFLITPEND_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn  && HAS_RXSNP
      |-> ! $isunknown(Chi5_in.RXSNPFLITPEND);
  endproperty
  chi5pc_err_snp_rxflitpend_x:  assert property (CHI5PC_ERR_SNP_RXFLITPEND_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXFLITPEND_X: A value of X is not allowed on RXSNPFLITPEND."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TX_X
  // =====
  property CHI5PC_ERR_REQ_TX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.TXREQFLITV && HAS_TXREQ
      
      |-> ! $isunknown(Chi5_in.TXREQFLIT);
  endproperty
  chi5pc_err_req_tx_x:  assert property (CHI5PC_ERR_REQ_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TX_X: A value of X is not allowed on TXREQFLIT when TXREQFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RX_X
  // =====
  property CHI5PC_ERR_REQ_RX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.RXREQFLITV && HAS_RXREQ
      |-> ! $isunknown(Chi5_in.RXREQFLIT);
  endproperty
  chi5pc_err_req_rx_x:  assert property (CHI5PC_ERR_REQ_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RX_X: A value of X is not allowed on RXREQFLIT when RXREQFLITV is high."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TX_X
  // =====
  property CHI5PC_ERR_DAT_TX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.TXDATFLITV 
      && |Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
      |-> ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_RSVDC_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_DATAID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_CCID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_DBID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_RESP_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_RESPERR_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_TXNID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_SRCID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_TGTID_RANGE]) &&
          ! $isunknown(Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_QOS_RANGE]) &&
          (! $isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_MSB:Chi5_in.CHI5PC_DAT_FLIT_BE_LSB]) || (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA));
  endproperty
  chi5pc_err_dat_tx_x:  assert property (CHI5PC_ERR_DAT_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TX_X: A value of X is not allowed on the payload fields of DATFLIT when DATFLITV is high. BE may be X for Read Data, not for write data."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RX_X
  // =====
  property CHI5PC_ERR_DAT_RX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.RXDATFLITV
      && |Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
      |-> ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_RSVDC_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_DATAID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_CCID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_DBID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_RESP_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_RESPERR_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_TXNID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_SRCID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_TGTID_RANGE]) &&
          ! $isunknown(Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_QOS_RANGE]) && 
          (! $isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_MSB:Chi5_in.CHI5PC_DAT_FLIT_BE_LSB]) || (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA));
  endproperty
  chi5pc_err_dat_rx_x:  assert property (CHI5PC_ERR_DAT_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RX_X: A value of X is not allowed on the payload fields of DATFLIT when DATFLITV is high. BE may be X for Read Data, not for write data."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA127TO0_TX_X
  // =====
  property CHI5PC_ERR_DAT_DATA127TO0_TX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.TXDATFLITV && 
      (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+7:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+1] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+15:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+8]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+2] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+23:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+16]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+3] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+31:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+24]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+4] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+39:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+32]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+5] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+47:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+40]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+6] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+55:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+48]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+7] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+63:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+56]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+8] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+71:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+64]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+9] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+79:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+72]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+10] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+87:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+80]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+11] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+95:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+88]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+12] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+103:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+96]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+13] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+111:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+104]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+14] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+119:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+112]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+15] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+127:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+120]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data127to0_tx_x:  assert property (CHI5PC_ERR_DAT_DATA127TO0_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA127TO0_TX_X: A value of X is not allowed on the TXDATFLIT Data[127:0] field if BE is high (does not apply to read data)."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA127TO0_RX_X
  // =====
  property CHI5PC_ERR_DAT_DATA127TO0_RX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.RXDATFLITV && 
      (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+7:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+1] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+15:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+8]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+2] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+23:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+16]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+3] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+31:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+24]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+4] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+39:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+32]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+5] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+47:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+40]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+6] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+55:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+48]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+7] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+63:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+56]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+8] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+71:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+64]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+9] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+79:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+72]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+10] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+87:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+80]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+11] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+95:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+88]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+12] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+103:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+96]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+13] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+111:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+104]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+14] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+119:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+112]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+15] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+127:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+120]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data127to0_rx_x:  assert property (CHI5PC_ERR_DAT_DATA127TO0_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA127TO0_RX_X: A value of X is not allowed on the RXDATFLIT Data[127:0] field if BE is high (does not apply to read data)."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA255TO128_TX_X
  // =====
  if ((DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) || (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH)) 
  begin: txdatflit_255_to_128_x
  property CHI5PC_ERR_DAT_DATA255TO128_TX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.TXDATFLITV  &&
      (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+16] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+135:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+128]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+17] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+143:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+136]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+18] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+151:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+144]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+19] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+159:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+152]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+20] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+167:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+160]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+21] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+175:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+168]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+22] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+183:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+176]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+23] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+191:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+184]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+24] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+199:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+192]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+25] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+207:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+200]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+26] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+215:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+208]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+27] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+223:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+216]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+28] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+231:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+224]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+29] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+239:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+232]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+30] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+247:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+240]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+31] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+255:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+248]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data255to128_tx_x:  assert property (CHI5PC_ERR_DAT_DATA255TO128_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA255TO128_TX_X: A value of X is not allowed on the TXDATFLIT Data[255:128] field if BE is high (does not apply to read data)."));
  end

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA255TO128_RX_X
  // =====
  if ((DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) || (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH)) 
  begin: rxdatflit_255_to_128_x
  property CHI5PC_ERR_DAT_DATA255TO128_RX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.RXDATFLITV && 
      (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+16] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+135:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+128]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+17] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+143:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+136]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+18] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+151:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+144]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+19] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+159:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+152]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+20] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+167:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+160]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+21] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+175:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+168]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+22] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+183:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+176]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+23] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+191:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+184]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+24] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+199:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+192]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+25] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+207:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+200]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+26] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+215:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+208]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+27] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+223:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+216]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+28] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+231:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+224]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+29] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+239:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+232]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+30] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+247:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+240]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+31] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+255:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+248]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data255to128_rx_x:  assert property (CHI5PC_ERR_DAT_DATA255TO128_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA255TO128_RX_X: A value of X is not allowed on the RXDATFLIT Data[255:128] field if BE is high (does not apply to read data)."));
  end

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA511TO256_TX_X
  // =====
  if (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH) 
  begin: txdatflit_511_to_256_x
  property CHI5PC_ERR_DAT_DATA511TO256_TX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.TXDATFLITV &&  
      (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.TXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+32] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+263:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+256]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+33] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+271:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+264]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+34] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+279:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+272]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+35] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+287:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+280]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+36] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+295:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+288]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+37] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+303:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+296]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+38] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+311:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+304]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+39] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+319:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+312]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+40] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+327:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+320]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+41] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+335:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+328]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+42] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+343:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+336]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+43] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+351:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+344]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+44] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+359:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+352]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+45] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+367:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+360]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+46] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+375:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+368]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+47] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+383:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+376]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+48] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+391:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+384]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+49] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+399:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+392]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+50] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+407:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+400]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+51] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+415:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+408]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+52] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+423:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+416]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+53] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+431:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+424]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+54] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+439:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+432]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+55] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+447:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+440]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+56] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+455:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+448]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+57] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+463:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+456]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+58] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+471:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+464]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+59] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+479:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+472]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+60] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+487:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+480]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+61] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+495:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+488]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+62] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+503:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+496]) :1'b1) &&
          (Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+63] ? !$isunknown(Chi5_in.TXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+511:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+504]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data511to256_tx_x:  assert property (CHI5PC_ERR_DAT_DATA511TO256_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA511TO256_TX_X: A value of X is not allowed on the TXDATFLIT Data[511:256] field if BE is high (does not apply to read data)."));
  end

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DATA511TO256_RX_X
  // =====
  if (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH) 
  begin: rxdatflit_511_to_256_x
  property CHI5PC_ERR_DAT_DATA511TO256_RX_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  Chi5_in.RXDATFLITV && 
      (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA) && (Chi5_in.RXDATFLIT[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_DATLINKFLIT)
      |-> (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+32] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+263:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+256]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+33] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+271:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+264]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+34] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+279:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+272]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+35] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+287:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+280]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+36] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+295:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+288]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+37] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+303:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+296]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+38] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+311:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+304]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+39] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+319:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+312]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+40] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+327:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+320]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+41] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+335:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+328]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+42] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+343:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+336]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+43] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+351:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+344]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+44] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+359:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+352]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+45] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+367:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+360]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+46] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+375:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+368]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+47] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+383:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+376]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+48] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+391:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+384]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+49] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+399:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+392]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+50] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+407:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+400]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+51] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+415:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+408]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+52] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+423:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+416]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+53] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+431:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+424]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+54] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+439:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+432]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+55] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+447:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+440]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+56] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+455:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+448]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+57] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+463:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+456]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+58] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+471:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+464]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+59] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+479:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+472]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+60] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+487:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+480]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+61] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+495:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+488]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+62] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+503:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+496]) :1'b1) &&
          (Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB+63] ? !$isunknown(Chi5_in.RXDATFLIT[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+511:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+504]) :1'b1) ;
  endproperty
  chi5pc_err_dat_data511to256_rx_x:  assert property (CHI5PC_ERR_DAT_DATA511TO256_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_DATA511TO256_RX_X: A value of X is not allowed on the RXDATFLIT Data[511:256] field if BE is high (does not apply to read data)."));
  end

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TX_X
  // =====
  property CHI5PC_ERR_SNP_TX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.TXSNPFLITV && HAS_TXSNP
      |-> ! $isunknown(Chi5_in.TXSNPFLIT);
  endproperty
  chi5pc_err_snp_tx_x:  assert property (CHI5PC_ERR_SNP_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TX_X: A value of X is not allowed on TXSNPFLIT when TXSNPFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RX_X
  // =====
  property CHI5PC_ERR_SNP_RX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.RXSNPFLITV && HAS_RXSNP
      |-> ! $isunknown(Chi5_in.RXSNPFLIT);
  endproperty
  chi5pc_err_snp_rx_x:  assert property (CHI5PC_ERR_SNP_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RX_X: A value of X is not allowed on RXSNPFLIT when RXSNPFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TX_X
  // =====
  property CHI5PC_ERR_RSP_TX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.TXRSPFLITV && HAS_TXRSP
      |-> ! $isunknown(Chi5_in.TXRSPFLIT);
  endproperty
  chi5pc_err_rsp_tx_x:  assert property (CHI5PC_ERR_RSP_TX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TX_X: A value of X is not allowed on TXRSPFLIT when TXRSPFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RX_X
  // =====
  property CHI5PC_ERR_RSP_RX_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  Chi5_in.RXRSPFLITV && HAS_RXRSP
      |-> ! $isunknown(Chi5_in.RXRSPFLIT);
  endproperty
  chi5pc_err_rsp_rx_x:  assert property (CHI5PC_ERR_RSP_RX_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RX_X: A value of X is not allowed on RXRSPFLIT when RXRSPFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXFLITV_X
  // =====
  property CHI5PC_ERR_REQ_TXFLITV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn && HAS_TXREQ
      |-> !$isunknown(Chi5_in.TXREQFLITV);
  endproperty
  chi5pc_err_req_txflitv_x:  assert property (CHI5PC_ERR_REQ_TXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_TXFLITV_X: A value of X is not allowed on TXREQFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RXFLITV_X
  // =====
  property CHI5PC_ERR_REQ_RXFLITV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn && HAS_RXREQ
      |-> !$isunknown(Chi5_in.RXREQFLITV);
  endproperty
  chi5pc_err_req_rxflitv_x:  assert property (CHI5PC_ERR_REQ_RXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_RXFLITV_X: A value of X is not allowed on RXREQFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_TXFLITV_X
  // =====
  property CHI5PC_ERR_SNP_TXFLITV_X;
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn  && HAS_TXSNP
      |-> !$isunknown(Chi5_in.TXSNPFLITV);
  endproperty
  chi5pc_err_snp_txflitv_x:  assert property (CHI5PC_ERR_SNP_TXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_TXFLITV_X: A value of X is not allowed on TXSNPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_SNP_RXFLITV_X
  // =====
  property CHI5PC_ERR_SNP_RXFLITV_X;
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && HAS_RXSNP 
      |-> !$isunknown(Chi5_in.RXSNPFLITV);
  endproperty
  chi5pc_err_snp_rxflitv_x:  assert property (CHI5PC_ERR_SNP_RXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_RXFLITV_X: A value of X is not allowed on RXSNPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TXFLITV_X
  // =====
  property CHI5PC_ERR_RSP_TXFLITV_X;
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && HAS_TXRSP
      |-> !$isunknown(Chi5_in.TXRSPFLITV);
  endproperty
  chi5pc_err_rsp_txflitv_x:  assert property (CHI5PC_ERR_RSP_TXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_TXFLITV_X: A value of X is not allowed on TXRSPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RXFLITV_X
  // =====
  property CHI5PC_ERR_RSP_RXFLITV_X;
    @(posedge `CHI5_SVA_CLK)
      `CHI5_SVA_RSTn && HAS_RXRSP 
      |-> !$isunknown(Chi5_in.RXRSPFLITV);
  endproperty
  chi5pc_err_rsp_rxflitv_x:  assert property (CHI5PC_ERR_RSP_RXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_RXFLITV_X: A value of X is not allowed on RXRSPFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_TXFLITV_X
  // =====
  property CHI5PC_ERR_DAT_TXFLITV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.TXDATFLITV);
  endproperty
  chi5pc_err_dat_txflitv_x:  assert property (CHI5PC_ERR_DAT_TXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_TXFLITV_X: A value of X is not allowed on TXDATFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RXFLITV_X
  // =====
  property CHI5PC_ERR_DAT_RXFLITV_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.RXDATFLITV);
  endproperty
  chi5pc_err_dat_rxflitv_x:  assert property (CHI5PC_ERR_DAT_RXFLITV_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_RXFLITV_X: A value of X is not allowed on RXDATFLITV."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXLINKACTIVEREQ_X
  // =====
  property CHI5PC_ERR_LNK_TXLINKACTIVEREQ_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.TXLINKACTIVEREQ);
  endproperty
  chi5pc_err_lnk_txlinkactivereq_x:  assert property (CHI5PC_ERR_LNK_TXLINKACTIVEREQ_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXLINKACTIVEREQ_X: A value of X is not allowed on TXLINKACTIVEREQ."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXLINKACTIVEREQ_X
  // =====
  property CHI5PC_ERR_LNK_RXLINKACTIVEREQ_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.RXLINKACTIVEREQ);
  endproperty
  chi5pc_err_lnk_rxlinkactivereq_x:  assert property (CHI5PC_ERR_LNK_RXLINKACTIVEREQ_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXLINKACTIVEREQ_X: A value of X is not allowed on RXLINKACTIVEREQ."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXLINKACTIVEACK_X
  // =====
  property CHI5PC_ERR_LNK_TXLINKACTIVEACK_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.TXLINKACTIVEACK);
  endproperty
  chi5pc_err_lnk_txlinkactiveack_x:  assert property (CHI5PC_ERR_LNK_TXLINKACTIVEACK_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXLINKACTIVEACK_X: A value of X is not allowed on TXLINKACTIVEACK."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXLINKACTIVEACK_X
  // =====
  property CHI5PC_ERR_LNK_RXLINKACTIVEACK_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.RXLINKACTIVEACK);
  endproperty
  chi5pc_err_lnk_rxlinkactiveack_x:  assert property (CHI5PC_ERR_LNK_RXLINKACTIVEACK_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXLINKACTIVEACK_X: A value of X is not allowed on RXLINKACTIVEACK."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXSACTIVE_X
  // =====
  property CHI5PC_ERR_LNK_TXSACTIVE_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.TXSACTIVE);
  endproperty
  chi5pc_err_lnk_txsactive_x:  assert property (CHI5PC_ERR_LNK_TXSACTIVE_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSACTIVE_X: A value of X is not allowed on TXSACTIVE."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_RXSACTIVE_X
  // =====
  property CHI5PC_ERR_LNK_RXSACTIVE_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn
      |-> !$isunknown(Chi5_in.RXSACTIVE);
  endproperty
  chi5pc_err_lnk_rxsactive_x:  assert property (CHI5PC_ERR_LNK_RXSACTIVE_X) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_RXSACTIVE_X: A value of X is not allowed on RXSACTIVE."));

//------------------------------------------------------------------------------
// INDEX:   20)  End of simulation checks
//------------------------------------------------------------------------------ 
`ifndef CHI5PC_EOS_OFF
final
begin
  $display ("Executing CHI5 End Of Simulation credit checks");
  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_TXREQ
  // =====
  //property CHI5PC_ERR_EOS_LCRD_TXREQ;
  if (!($isunknown({next_TXREQ_Credits,TXREQ_Credits})))
  chi5pc_err_eos_lcrd_txreq:
    assert (~|next_TXREQ_Credits && ~|TXREQ_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_TXREQ: Outstanding TXREQ link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_RXREQ
  // =====
  //property CHI5PC_ERR_EOS_LCRD_RXREQ;
  if (!($isunknown({next_RXREQ_Credits,RXREQ_Credits})))
  chi5pc_err_eos_lcrd_rxreq:
    assert (~|next_RXREQ_Credits && ~|RXREQ_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_RXREQ: Outstanding RXREQ link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_TXRSP
  // =====
  //property CHI5PC_ERR_EOS_LCRD_TXRSP;
  if (!($isunknown({next_TXRSP_Credits,TXRSP_Credits})))
  chi5pc_err_eos_lcrd_txrsp:
    assert (~|next_TXRSP_Credits && ~|TXRSP_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_TXRSP: Outstanding TXRSP link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_RXRSP
  // =====
  //property CHI5PC_ERR_EOS_LCRD_RXRSP;
  if (!($isunknown({next_RXRSP_Credits,RXRSP_Credits})))
  chi5pc_err_eos_lcrd_rxrsp:
    assert (~|next_RXRSP_Credits && ~|RXRSP_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_RXRSP: Outstanding RXRSP link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_TXSNP
  // =====
  //property CHI5PC_ERR_EOS_LCRD_TXSNP;
  if (!($isunknown({next_TXSNP_Credits,TXSNP_Credits})))
  chi5pc_err_eos_lcrd_txsnp:
    assert (~|next_TXSNP_Credits && ~|TXSNP_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_TXSNP: Outstanding TXSNP link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_RXSNP
  // =====
  //property CHI5PC_ERR_EOS_LCRD_RXSNP;
  if (!($isunknown({next_RXSNP_Credits,RXSNP_Credits})))
  chi5pc_err_eos_lcrd_rxsnp:
    assert (~|next_RXSNP_Credits && ~|RXSNP_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_RXSNP: Outstanding RXSNP link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_TXDAT
  // =====
  //property CHI5PC_ERR_EOS_LCRD_TXDAT;
  if (!($isunknown({next_TXDAT_Credits,TXDAT_Credits})))
  chi5pc_err_eos_lcrd_txdat:
    assert (~|next_TXDAT_Credits && ~|TXDAT_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_TXDAT: Outstanding TXDAT link layer credits at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_LCRD_RXDAT
  // =====
  //property CHI5PC_ERR_EOS_LCRD_RXDAT;
  if (!($isunknown({next_RXDAT_Credits,RXDAT_Credits})))
  chi5pc_err_eos_lcrd_rxdat:
    assert (~|next_RXDAT_Credits && ~|RXDAT_Credits) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_LCRD_RXDAT: Outstanding RXDAT link layer credits at end of simulation."));

end
`endif
//------------------------------------------------------------------------------
// INDEX:   21) Clear Verilog Defines
//------------------------------------------------------------------------------

  // Clock and Reset
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   22) End of module
//------------------------------------------------------------------------------

endmodule // Chi5PC

//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------
`endif
`endif
