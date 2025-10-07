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
//  File Revision       : 179210
//
//  Date                :  2014-08-22 15:44:12 +0100 (Fri, 22 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Tracks flits on REQ/RSP/DAT.
//                          
//----------------------------------------------------------------------------
// CONTENTS
// ========
//  340.  Module: FlitTrace
//  394.    1) Parameters
//  400.    2) Verilog Defines
//  403.         - Clock and Reset
//  430.    3)  Transaction Tracking
// 1820.    4)  Retry tracking
// 1904.    5)  REQ channel Checks
// 1908.         - CHI5PC_ERR_REQ_X
// 1920.         - CHI5PC_ERR_REQ_TXNID_UNQ
// 1935.         - CHI5PC_ERR_REQ_EXCL_OPCODE
// 1955.         - CHI5PC_ERR_REQ_RSVD_OPCODE
// 1975.         - CHI5PC_ERR_REQ_RSVD_SIZE
// 1989.         - CHI5PC_ERR_REQ_RSVD_SNPATTR
// 2002.         - CHI5PC_ERR_REQ_CTL_LINKFLIT
// 2015.         - CHI5PC_ERR_REQ_CTL_ORDER_SN
// 2028.         - CHI5PC_ERR_REQ_OPCD_RNS
// 2060.         - CHI5PC_ERR_REQ_OPCD_WNSF
// 2092.         - CHI5PC_ERR_REQ_OPCD_WNSP
// 2124.         - CHI5PC_ERR_REQ_OPCD_RC
// 2142.         - CHI5PC_ERR_REQ_OPCD_RS
// 2160.         - CHI5PC_ERR_REQ_OPCD_RU
// 2178.         - CHI5PC_ERR_REQ_OPCD_CU
// 2196.         - CHI5PC_ERR_REQ_OPCD_MU
// 2214.         - CHI5PC_ERR_REQ_OPCD_E
// 2232.         - CHI5PC_ERR_REQ_OPCD_WBF
// 2250.         - CHI5PC_ERR_REQ_OPCD_WBP
// 2268.         - CHI5PC_ERR_REQ_OPCD_WEF
// 2286.         - CHI5PC_ERR_REQ_OPCD_WCF
// 2304.         - CHI5PC_ERR_REQ_OPCD_WCP
// 2322.         - CHI5PC_ERR_REQ_OPCD_RO
// 2342.         - CHI5PC_ERR_REQ_OPCD_CS
// 2362.         - CHI5PC_ERR_REQ_OPCD_CI
// 2382.         - CHI5PC_ERR_REQ_OPCD_MI
// 2402.         - CHI5PC_ERR_REQ_OPCD_WUF
// 2422.         - CHI5PC_ERR_REQ_OPCD_WUP
// 2442.         - CHI5PC_ERR_REQ_OPCD_EOB
// 2467.         - CHI5PC_ERR_REQ_OPCD_ECB
// 2492.         - CHI5PC_ERR_REQ_OPCD_DVM
// 2510.         - CHI5PC_ERR_REQ_OPCD_PCR
// 2544.         - CHI5PC_REC_REQ_OPCD_RC
// 2561.         - CHI5PC_REC_REQ_OPCD_RS
// 2578.         - CHI5PC_REC_REQ_OPCD_RU
// 2595.         - CHI5PC_REC_REQ_OPCD_CU
// 2612.         - CHI5PC_REC_REQ_OPCD_MU
// 2629.         - CHI5PC_REC_REQ_OPCD_E
// 2646.         - CHI5PC_REC_REQ_OPCD_WBF
// 2663.         - CHI5PC_REC_REQ_OPCD_WBP
// 2680.         - CHI5PC_REC_REQ_OPCD_WEF
// 2697.         - CHI5PC_REC_REQ_OPCD_WCF
// 2714.         - CHI5PC_REC_REQ_OPCD_WCP
// 2731.         - CHI5PC_REC_REQ_OPCD_RO
// 2750.         - CHI5PC_REC_REQ_OPCD_CS
// 2769.         - CHI5PC_REC_REQ_OPCD_CI
// 2788.         - CHI5PC_REC_REQ_OPCD_MI
// 2807.         - CHI5PC_REC_REQ_OPCD_WUF
// 2826.         - CHI5PC_REC_REQ_OPCD_WUP
// 2845.         - CHI5PC_ERR_REQ_CTL_READSHARED
// 2863.         - CHI5PC_ERR_REQ_CTL_READCLEAN
// 2882.         - CHI5PC_ERR_REQ_CTL_READONCE
// 2900.         - CHI5PC_ERR_REQ_CTL_READNOSNP
// 2914.         - CHI5PC_ERR_REQ_CTL_READUNIQUE
// 2934.         - CHI5PC_ERR_REQ_CTL_CLEANSHARED
// 2952.         - CHI5PC_ERR_REQ_CTL_CLEANINVALID
// 2969.         - CHI5PC_ERR_REQ_CTL_MAKEINVALID
// 2986.         - CHI5PC_ERR_REQ_CTL_CLEANUNIQUE
// 3005.         - CHI5PC_ERR_REQ_CTL_MAKEUNIQUE
// 3027.         - CHI5PC_ERR_REQ_CTL_EOBARRIER
// 3050.         - CHI5PC_ERR_REQ_CTL_ECBARRIER
// 3072.         - CHI5PC_ERR_REQ_CTL_PCRDRETURN
// 3096.         - CHI5PC_ERR_REQ_CTL_EVICT
// 3117.         - CHI5PC_ERR_REQ_CTL_WRITEEVICTFULL
// 3136.         - CHI5PC_ERR_REQ_CTL_WRITECLEANPTL
// 3157.         - CHI5PC_ERR_REQ_CTL_WRITECLEANFULL
// 3177.         - CHI5PC_ERR_REQ_CTL_WRITEBACKPTL
// 3198.         - CHI5PC_ERR_REQ_CTL_WRITEBACKFULL
// 3218.         - CHI5PC_ERR_REQ_CTL_WRITEUNIQUEPTL
// 3234.         - CHI5PC_ERR_REQ_CTL_WRITEUNIQUEFULL
// 3251.         - CHI5PC_ERR_REQ_CTL_WRITENOSNPPTL
// 3266.         - CHI5PC_ERR_REQ_CTL_WRITENOSNPFULL
// 3282.         - CHI5PC_ERR_REQ_WRITENOSNPFULL_DEV
// 3295.         - CHI5PC_ERR_REQ_EXPCOMPACK_SN
// 3310.         - CHI5PC_ERR_REQ_EXCL_SNOOPABLE
// 3327.         - CHI5PC_ERR_REQ_ATTR_DEV
// 3350.         - CHI5PC_ERR_REQ_ATTR_NORMAL
// 3442.         - CHI5PC_ERR_REQ_MEMATTR_X11X
// 3455.         - CHI5PC_ERR_REQ_MEMATTR_X100
// 3468.         - CHI5PC_ERR_REQ_MEMATTR_100X
// 3481.         - CHI5PC_ERR_REQ_MEMATTR_0010_EO_0
// 3495.         - CHI5PC_ERR_REQ_MEMATTR_NORMAL_EO
// 3509.         - CHI5PC_ERR_REQ_TRXN_IN_CMO
// 3523.         - CHI5PC_ERR_REQ_CMO_IN_TRXN
// 3536.         - CHI5PC_ERR_REQ_IN_COPYBACK
// 3553.         - CHI5PC_REC_REQ_HAZARD_R_W
// 3566.         - CHI5PC_REC_REQ_HAZARD_W_R
// 3579.         - CHI5PC_REC_REQ_HAZARD_W_W
// 3593.         - CHI5PC_INFO_REQ_PCRDRETURN
// 3606.         - CHI5PC_ERR_REQ_RETRY
// 3621.         - CHI5PC_ERR_REQ_PCRDTYPE_GRANTED
// 3640.         - CHI5PC_ERR_REQ_PCRDTYPE_RETRIED
// 3656.         - CHI5PC_ERR_REQ_PCRDRTN_DYN
// 3668.         - CHI5PC_ERR_REQ_PCRDRTN_TYPE
// 3680.         - CHI5PC_ERR_REQ_OVFLW
// 3693.         - CHI5PC_ERR_REQ_PCRD_OVFLW
// 3706.         - CHI5PC_ERR_REQ_RSVD_DVM_MTYPE
// 3719.         - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_NS
// 3783.         - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_S
// 3827.         - CHI5PC_ERR_REQ_DVM_TLBI_HYP_NS
// 3856.         - CHI5PC_ERR_REQ_DVM_TLBI_EL3_S
// 3886.         - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_HYP_BOTH
// 3900.         - CHI5PC_ERR_REQ_DVM_TLBI_NS_S_BOTH
// 3914.         - CHI5PC_ERR_REQ_DVM_TLBI_HYP_S
// 3929.         - CHI5PC_ERR_REQ_DVM_TLBI_EL3_NS
// 3945.         - CHI5PC_ERR_REQ_DVM_BPI
// 3971.         - CHI5PC_ERR_REQ_DVM_PICI
// 4026.         - CHI5PC_ERR_REQ_DVM_VICI
// 4080.         - CHI5PC_ERR_REQ_DVM_SYNC
// 4099.         - CHI5PC_ERR_REQ_CTL_DVMOP
// 4118.         - CHI5PC_ERR_REQ_RSVD_DVM_S2S1
// 4130.         - CHI5PC_ERR_REQ_RSVD_DVM_SECURE
// 4142.         - CHI5PC_ERR_REQ_RSVD_DVM_ADDR
// 4154.         - CHI5PC_ERR_REQ_RSVD_ORDER
// 4168.         - CHI5PC_REC_REQ_ORDER
// 4181.         - CHI5PC_ERR_REQ_SYNC_UNQ
// 4195.         - CHI5PC_ERR_REQ_BAR_WR_HAZ
// 4207.         - CHI5PC_ERR_REQ_WR_BAR_HAZ
// 4219.         - CHI5PC_REC_REQ_BAR
// 4235.         - CHI5PC_REC_REQ_SYNC_HAZ
// 4247.         - CHI5PC_ERR_REQ_REQATTR
// 4262.         - CHI5PC_ERR_REQ_DEV
// 4279.         - CHI5PC_ERR_REQ_EXCL_OVLAP_NONSNOOPABLE
// 4295.         - CHI5PC_ERR_REQ_EXCL_OVLAP_SNOOPABLE
// 4313.    6)  RSP channel Checks
// 4318.         - CHI5PC_ERR_RSP_RESP_CS
// 4336.         - CHI5PC_ERR_RSP_RESP_CI
// 4352.         - CHI5PC_ERR_RSP_RESP_MI
// 4368.         - CHI5PC_ERR_RSP_RESP_CU
// 4384.         - CHI5PC_ERR_RSP_RESP_MU
// 4400.         - CHI5PC_ERR_RSP_RESP_E
// 4416.         - CHI5PC_ERR_RSP_RESP_EOB
// 4431.         - CHI5PC_ERR_RSP_RESP_ECB
// 4446.         - CHI5PC_ERR_RSP_RESP_DVM
// 4462.         - CHI5PC_ERR_RSP_RESP_WEF
// 4478.         - CHI5PC_ERR_RSP_RESP_WCP
// 4494.         - CHI5PC_ERR_RSP_RESP_WCF
// 4510.         - CHI5PC_ERR_RSP_RESP_WUP
// 4527.         - CHI5PC_ERR_RSP_RESP_WUF
// 4544.         - CHI5PC_ERR_RSP_RESP_WBP
// 4560.         - CHI5PC_ERR_RSP_RESP_WBF
// 4576.         - CHI5PC_ERR_RSP_RESP_WNSP
// 4593.         - CHI5PC_ERR_RSP_RESP_WNSF
// 4610.         - CHI5PC_ERR_RSP_RESPERR_CS
// 4623.         - CHI5PC_ERR_RSP_RESPERR_CI
// 4636.         - CHI5PC_ERR_RSP_RESPERR_MI
// 4649.         - CHI5PC_ERR_RSP_RESPERR_MU
// 4662.         - CHI5PC_ERR_RSP_RESPERR_E
// 4676.         - CHI5PC_ERR_RSP_RESPERR_BARRIER
// 4690.         - CHI5PC_ERR_RSP_RESPERR_DVM
// 4704.         - CHI5PC_ERR_RSP_RSVD_RESP_COMP
// 4717.         - CHI5PC_ERR_RSP_CTL_COMPACK
// 4732.         - CHI5PC_ERR_RSP_CTL_RETRYACK
// 4748.         - CHI5PC_ERR_RSP_CTL_COMP
// 4762.         - CHI5PC_ERR_RSP_DBID_COMP
// 4778.         - CHI5PC_ERR_RSP_CTL_COMPDBIDRESP
// 4791.         - CHI5PC_ERR_RSP_CTL_DBIDRESP
// 4805.         - CHI5PC_ERR_RSP_DBID_DBIDRESP
// 4820.         - CHI5PC_ERR_RSP_CNT_READRECEIPT
// 4832.         - CHI5PC_ERR_RSP_READRECEIPT_READ
// 4844.         - CHI5PC_ERR_RSP_COMPDBID_READ
// 4859.         - CHI5PC_ERR_RSP_COMP_DBID_COPYBACK
// 4877.         - CHI5PC_ERR_RSP_COMP_CNT
// 4891.         - CHI5PC_ERR_RSP_CNT_COMPDBIDRESP
// 4905.         - CHI5PC_ERR_RSP_CNT_DBIDRESP
// 4918.         - CHI5PC_ERR_RSP_TRXN_DBIDRESP
// 4935.         - CHI5PC_ERR_RSP_TRXN_READRECEIPT
// 4948.         - CHI5PC_ERR_RSP_TRXN_COMPDBIDRESP
// 4965.         - CHI5PC_ERR_RSP_ORDER_READRECEIPT
// 4979.         - CHI5PC_ERR_RSP_COMPACK_WU
// 4991.         - CHI5PC_ERR_RSP_COMPACK_READ
// 5004.         - CHI5PC_ERR_RSP_DVM_RX_FIRST
// 5016.         - CHI5PC_ERR_RSP_DVM_SECOND
// 5029.         - CHI5PC_ERR_RSP_DVM_ALLDAT
// 5042.         - CHI5PC_ERR_RSP_RETRYACK_FIRST
// 5057.         - CHI5PC_ERR_RSP_RETRYACK_PCRD_DYN
// 5070.         - CHI5PC_ERR_RSP_DBID_ALLOCATION
// 5082.         - CHI5PC_ERR_RSP_DAT_DBID_ALLOCATION
// 5102.         - CHI5PC_ERR_RSP_CTL_PCRDGRANT
// 5117.         - CHI5PC_ERR_RSP_CTL_READRECEIPT
// 5132.         - CHI5PC_ERR_RSP_RETRYACK_PCRD_PREALLOC
// 5145.         - CHI5PC_REC_RSP_ORDER_WRITEUNIQUE
// 5160.         - CHI5PC_ERR_RSP_HNF_INVALID_REQ
// 5176.         - CHI5PC_ERR_RSP_HNI_INVALID_REQ
// 5192.         - CHI5PC_REC_RSP_HNI_INVALID_REQ
// 5209.         - CHI5PC_ERR_RSP_MN_INVALID_REQ
// 5226.         - CHI5PC_ERR_RSP_SNF_INVALID_REQ
// 5243.         - CHI5PC_ERR_RSP_SNI_INVALID_REQ
// 5263.         - CHI5PC_ERR_RSP_EXOKAY_WR
// 5276.         - CHI5PC_ERR_RSP_OPCD_RETRYACK
// 5310.         - CHI5PC_ERR_RSP_OPCD_DBIDRESP
// 5343.         - CHI5PC_ERR_RSP_OPCD_PCRDGRANT
// 5376.         - CHI5PC_ERR_RSP_OPCD_COMP
// 5409.         - CHI5PC_ERR_RSP_OPCD_COMPDBIDRESP
// 5441.         - CHI5PC_ERR_RSP_OPCD_READRECEIPT
// 5468.         - CHI5PC_ERR_RSP_OPCD_UPSTREAM
// 5485.         - CHI5PC_ERR_RSP_OPCD_COMPACK
// 5505.         - CHI5PC_ERR_RSP_OPCD_SNPRESP
// 5531.         - CHI5PC_ERR_RSP_OPCD_DOWNSTREAM
// 5548.    7)  DAT channel Checks
// 5552.         - CHI5PC_ERR_DAT_RESP_RS
// 5569.         - CHI5PC_ERR_DAT_RESP_RC
// 5584.         - CHI5PC_ERR_DAT_RESP_RO
// 5598.         - CHI5PC_ERR_DAT_RESP_RNS
// 5612.         - CHI5PC_ERR_DAT_RESP_RU
// 5627.         - CHI5PC_ERR_DAT_RESP_DVM
// 5640.         - CHI5PC_ERR_DAT_RESP_WEF
// 5656.         - CHI5PC_ERR_DAT_RESP_WCP
// 5671.         - CHI5PC_ERR_DAT_RESP_WUP
// 5685.         - CHI5PC_ERR_DAT_RESP_WUF
// 5699.         - CHI5PC_ERR_DAT_RESP_WBP
// 5713.         - CHI5PC_ERR_DAT_RESP_WNSP
// 5727.         - CHI5PC_ERR_DAT_RESP_WNSF
// 5741.         - CHI5PC_ERR_DAT_RESPERR_RO
// 5754.         - CHI5PC_ERR_DAT_RESPERR_RU
// 5767.         - CHI5PC_ERR_DAT_RESPERR_DVM
// 5780.         - CHI5PC_ERR_DAT_RESPERR_COPYBACK
// 5794.         - CHI5PC_ERR_DAT_RESPERR_WRITE
// 5808.         - CHI5PC_ERR_DAT_RESPERR_READ_OK_EXOK
// 5821.         - CHI5PC_ERR_DAT_RESPERR_READ_EXOK_OK
// 5834.         - CHI5PC_ERR_DAT_RSVD_RESP_COMP
// 5847.         - CHI5PC_ERR_DAT_RSVD_RESP_WRDATA
// 5861.         - CHI5PC_ERR_DAT_CTL_COPYBACKWRDATA
// 5874.         - CHI5PC_ERR_DAT_CTL_NONCOPYBACKWRDATA
// 5887.         - CHI5PC_ERR_DAT_VALID_RDDATAID
// 5900.         - CHI5PC_ERR_DAT_VALID_WRDATAID
// 5913.         - CHI5PC_ERR_DAT_VALID_WRBE
// 5955.         - CHI5PC_ERR_DAT_VALID_WRBE_DVM
// 5969.         - CHI5PC_ERR_DAT_WRBE_X
// 5982.         - CHI5PC_ERR_DAT_RDDATAID
// 5995.         - CHI5PC_ERR_DAT_WRDATAID
// 6008.         - CHI5PC_ERR_DAT_CTL_DVM
// 6024.         - CHI5PC_ERR_DAT_NCBW_WNS
// 6037.         - CHI5PC_ERR_DAT_NCBW_WU
// 6050.         - CHI5PC_ERR_DAT_CBW_WB
// 6063.         - CHI5PC_ERR_DAT_CBW_WEF
// 6076.         - CHI5PC_ERR_DAT_CBW_WC
// 6089.         - CHI5PC_ERR_DAT_ORDER
// 6106.         - CHI5PC_ERR_DAT_CONST_RESP_RD
// 6120.         - CHI5PC_ERR_DAT_CONST_RESP_WR
// 6135.         - CHI5PC_ERR_DAT_EXOKAY_WR
// 6148.         - CHI5PC_ERR_DAT_EXOKAY_RD
// 6161.         - CHI5PC_ERR_DAT_WRCCID
// 6175.         - CHI5PC_ERR_DAT_RDCCID
// 6188.         - CHI5PC_ERR_DAT_RSVD_WRDATAID_256
// 6200.         - CHI5PC_ERR_DAT_RSVD_WRDATAID_512
// 6213.         - CHI5PC_ERR_DAT_RSVD_RDDATAID_256
// 6225.         - CHI5PC_ERR_DAT_RSVD_RDDATAID_512
// 6237.         - CHI5PC_ERR_DAT_RDDATA127TO0_X
// 6266.         - CHI5PC_ERR_DAT_RDDATA255TO128_X
// 6296.         - CHI5PC_ERR_DAT_RDDATA511TO256_X
// 6345.         - CHI5PC_ERR_DAT_RDRESP_UNIFORM
// 6358.         - CHI5PC_ERR_DAT_BE_FULL
// 6378.         - CHI5PC_ERR_DAT_RDRESP_DIRTY
// 6395.         - CHI5PC_ERR_DAT_WRAPORDER_WR
// 6409.         - CHI5PC_ERR_DAT_WRAPORDER_RD
// 6423.         - CHI5PC_ERR_DAT_DBID_ALLOCATION
// 6436.         - CHI5PC_ERR_DAT_CONST_DBID_READ
// 6448.         - CHI5PC_ERR_DAT_OPCD_COMPDATA
// 6480.         - CHI5PC_ERR_DAT_OPCD_UPSTREAM
// 6493.         - CHI5PC_ERR_DAT_OPCD_COPYBACKWRDATA
// 6511.         - CHI5PC_REC_DAT_OPCD_COPYBACKWRDATA
// 6528.         - CHI5PC_ERR_DAT_OPCD_NONCOPYBACKWRDATA
// 6568.         - CHI5PC_ERR_DAT_OPCD_SNPRESPDATA
// 6585.         - CHI5PC_ERR_DAT_OPCD_SNPRESPDATAPTL
// 6602.         - CHI5PC_ERR_DAT_OPCD_DOWNSTREAM
// 6618.    8)  SNP Channel checks
// 6621.         - CHI5PC_ERR_SNP_HAZARD_RXSNP
// 6634.         - CHI5PC_ERR_SNP_REQATTR
// 6649.    9)  SACTIVE checks
// 6652.         - CHI5PC_ERR_LNK_TXSACTIVE_REQ_TX
// 6664.         - CHI5PC_ERR_LNK_TXSACTIVE_REQ_RX
// 6681.    10)  End of simulation checks
// 6689.         - CHI5PC_ERR_EOS_TRXN
// 6698.         - CHI5PC_ERR_EOS_RETRY
// 6707.         - CHI5PC_ERR_EOS_PCRD
// 6717.    11) Clear Verilog Defines
// 6726.    12) End of module
// 6732. 
// 6733.  End of File
//----------------------------------------------------------------------------


`ifndef CHI5PC_OFF



//------------------------------------------------------------------------------
// CHI5 Standard Defines
//------------------------------------------------------------------------------



`ifndef CHI5PC_FLIT_DEFINES_SVH
  `include "Chi5PC_Chi5_flit_defines.svh"
`endif
`ifndef CHI5PC_CHI5_DEFINES_V
  `include "Chi5PC_Chi5_defines.v"
`endif
`include "Chi5PC_defines.v"



//------------------------------------------------------------------------------
// INDEX: Module: FlitTrace
//------------------------------------------------------------------------------
module Chi5PC_FlitTrace #(REQ_RSVDC_WIDTH = 4,
                   DAT_RSVDC_WIDTH = 4,
                   DAT_FLIT_WIDTH = `CHI5PC_128B_DAT_FLIT_WIDTH, 
                   MAX_OS_REQ = 8,
                   numChi5nodes = 7,
                   MODE = 1,
                   RecommendOn = 1'b1,
                   RecommendOn_Haz = 1'b1,
                   CRDGRANT_BEFORE_RETRY = 1,
                   NODE_TYPE = Chi5PC_pkg::RNF,
                   PCMODE = Chi5PC_pkg::LOCAL,
                  ErrorOn_SW = 1,
                  Barrier_Order = 1,
                  ErrorOn_Data_X = 1)
      (Chi5PC_if Chi5_in
     ,input wire SRESETn
     ,input wire SCLK
     ,input wire REQFLITV_
     ,input wire [`CHI5PC_REQ_FLIT_RANGE] REQFLIT_
     ,input wire REQLCRDV_
     ,input wire WRDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0] WRDATFLIT_
     ,input wire WRDATLCRDV_
     ,input wire RDDATFLITV_
     ,input wire [DAT_FLIT_WIDTH-1:0] RDDATFLIT_
     ,input wire RDDATLCRDV_
     ,input wire M_RSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE] M_RSPFLIT_
     ,input wire TXRSPLCRDV_
     ,input wire S_RSPFLITV_
     ,input wire [`CHI5PC_RSP_FLIT_RANGE] S_RSPFLIT_
     ,input wire RXRSPLCRDV_
     ,input wire SACTIVE_
     ,input wire SNPFLITV_
     ,input wire [`CHI5PC_SNP_FLIT_RANGE] SNPFLIT_
     ,output reg RDDAT_match 
     ,output reg WRDAT_match
     ,output reg RXRSP_match
     ,output reg TXRSP_match
     ,output reg S_RSP_Comp_Haz
     ,output reg [44:0] S_RSP_Addr_NS
     ,output reg [3:0] S_RSP_Dev_Size
     ,output reg S_RSP_Comp_Wr
     ,output reg [43:5] RDDAT_Addr_NS
     ,output reg RDDAT_Comp_Haz
     ,output reg [43:5] WRDAT_Addr_NS
     ,output reg RDDAT_Last_
   );
  import Chi5PC_pkg::*;
  typedef Chi5_in.Chi5PC_Info Chi5PC_Info;
  
//------------------------------------------------------------------------------
// INDEX:   1) Parameters
//------------------------------------------------------------------------------
  localparam MAX_OS_TX = MAX_OS_REQ;
  localparam LOG2MAX_OS_TX       = clogb2(MAX_OS_TX);

//---------------------------------------------------------------------------
// INDEX:   2) Verilog Defines
//------------------------------------------------------------------------------

  // INDEX:        - Clock and Reset
  // =====
  // Can be overridden by user for a clock enable.
  
  `ifdef CHI5_SVA_CLK
  `else
     `define CHI5_SVA_CLK SCLK
  `endif
  
  `ifdef CHI5_SVA_RSTn
  `else
     `define CHI5_SVA_RSTn SRESETn
  `endif
  
  // AUX: Auxiliary Logic
  `ifdef CHI5_AUX_CLK
  `else
     `define CHI5_AUX_CLK SCLK
  `endif
  
  `ifdef CHI5_AUX_RSTn
  `else
     `define CHI5_AUX_RSTn SRESETn
  `endif
  

//------------------------------------------------------------------------------
// INDEX:   3)  Transaction Tracking
//------------------------------------------------------------------------------ 

  logic [`CHI5PC_REQ_FLIT_MEMATTR_WIDTH-1:0] mem_attr;
  logic [`CHI5PC_MEMATTR_ALLOCATE_WIDTH-1:0] memattr_allocate;
  logic [`CHI5PC_MEMATTR_CACHEABLE_WIDTH-1:0] memattr_cacheable;
  logic [`CHI5PC_MEMATTR_DEVICE_WIDTH-1:0] memattr_device;
  logic [`CHI5PC_MEMATTR_EARLYWRACK_WIDTH-1:0] memattr_ewa;
  logic REQ_ORDER;
  logic EO_ORDER;
  reg        [1:MAX_OS_TX]     Info_Pop_vector;
  reg        [1:MAX_OS_TX]     Info_Alloc_vector;
  reg        [LOG2MAX_OS_TX:0] Info_Index_next;
  reg        [LOG2MAX_OS_TX:0] S_RSP_Info_Index;
  reg        [LOG2MAX_OS_TX:0] M_RSP_Info_Index;
  reg        [LOG2MAX_OS_TX:0] RDDAT_Info_Index;
  reg        [LOG2MAX_OS_TX:0] WRDAT_Info_Index;
  reg        [LOG2MAX_OS_TX:0] Payload_match_Info_Index;

  Chi5PC_Info Info_tmp;
  Chi5PC_Info Info [1:MAX_OS_TX];
  Chi5PC_Info Current_RDDAT_Info;
  Chi5PC_Info Current_WRDAT_Info;
  Chi5PC_Info Current_M_RSP_Info;
  Chi5PC_Info Current_S_RSP_Info;
  Chi5PC_Info Current_Payload_match_Info;
  reg                           M_RSP_Pop;
  reg                           S_RSP_Pop;
  reg                           WRDAT_Pop;
  reg                           RDDAT_Pop;
  reg                           WRDAT_Last;
  reg                           INFO_PUSH;
  reg                           INFO_RDDAT;
  reg                           INFO_WRDAT;
  reg                           INFO_RXRSP;
  reg                           INFO_POP;
  reg                           IN_WREQ;
  reg                           IN_COPYBACK;
  reg                           IN_RREQ;
  reg                           IN_CMAINT;
  reg                           NOT_COMPLETE;

  logic [1:MAX_OS_TX] in_Flight_vector;
  logic [1:MAX_OS_TX] in_Retry_vector;
  logic [1:MAX_OS_TX] Is_Read_vector;
  logic [1:MAX_OS_TX] Is_Clean_Make_vector;
  logic [1:MAX_OS_TX] Is_CMO_vector;
  logic [1:MAX_OS_TX] Is_Write_vector;
  logic [1:MAX_OS_TX] Is_memattrX0XX_vector;
  logic [1:MAX_OS_TX] Is_snpattrX1_vector;
  logic [1:MAX_OS_TX] Is_tgt_HNI_SNI_vector;
  logic [1:MAX_OS_TX] Is_tgt_HNF_vector;
  logic [1:MAX_OS_TX] Is_same_LPID_SRCID_vector;
  logic [1:MAX_OS_TX] Is_same_TGTID_vector;
  logic [1:MAX_OS_TX] Is_CopyBack_vector;
  logic [1:MAX_OS_TX] Is_DVMOp_vector;
  logic [1:MAX_OS_TX] Is_Evict_Barrier_vector;
  logic [1:MAX_OS_TX] Is_Barrier_vector;
  logic [1:MAX_OS_TX] Is_Cacheable_vector;
  logic [1:MAX_OS_TX] Has_no_RSP1_or_data_vector;
  logic [1:MAX_OS_TX] txactive_vector;
  logic [1:MAX_OS_TX] Current_RDData_vector;
  logic [1:MAX_OS_TX] Has_DBIDRESP_COMP_vector;
  logic [1:MAX_OS_TX] Has_DBID_vector;
  logic [1:MAX_OS_TX] Has_Comp_vector;
  logic [1:MAX_OS_TX] ID_CLASH_vector;
  logic [1:MAX_OS_TX] REQ_Attr_CLASH_vector;
  logic [1:MAX_OS_TX] SNP_Attr_CLASH_vector;
  logic [1:MAX_OS_TX] DBID_INUSE_vector;
  logic [1:MAX_OS_TX] RSP_DBID_ALLOC_ERR_vector;
  logic [1:MAX_OS_TX] DAT_DBID_ALLOC_ERR_vector;
  logic [1:MAX_OS_TX] DATORDER_ERR_vector;
  logic [1:MAX_OS_TX] REQORDER_ERR_vector;
  logic [1:MAX_OS_TX] DVM_SYNC_CLASH_vector;
  logic [1:MAX_OS_TX] GO_vector;
  logic [1:MAX_OS_TX] S_RSP_match_vector;
  logic               S_RSP_match;
  logic [1:MAX_OS_TX] M_RSP_match_vector;
  logic               M_RSP_match;
  logic [1:MAX_OS_TX] WRDAT_match_vector;
  logic [1:MAX_OS_TX] RDDAT_match_vector;
  logic [1:MAX_OS_TX] Payload_match_vector;
  logic [1:MAX_OS_TX] Has_DBIDRESP_vector;
  logic [1:MAX_OS_TX] Has_ALLDATA_vector;
  logic [1:MAX_OS_TX] RXSNP_Addr_NS_haz_vector;
  logic [1:MAX_OS_TX] waiting_for_compack_vector;
  logic [1:MAX_OS_TX] is_CleanUnique_vector;
  logic [1:MAX_OS_TX] is_ReadShared_ReadClean_vector;
  logic [1:MAX_OS_TX] excl_ovlap_snoopable_vector;
  logic [1:MAX_OS_TX] excl_ovlap_nonsnoopable_vector;
  logic [(1 << `CHI5PC_REQ_FLIT_LPID_WIDTH) -1:0] PreBarrier_writes;
  logic Retry_match;
  logic PCRDRETURN;
  localparam num_crdtypes = 1 << `CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH;                     
  localparam CHI5PC_DAT_FLIT_BE_WIDTH = 
    DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH ? `CHI5PC_128B_DAT_FLIT_BE_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH ? `CHI5PC_256B_DAT_FLIT_BE_WIDTH : 
    DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH ? `CHI5PC_512B_DAT_FLIT_BE_WIDTH : `CHI5PC_128B_DAT_FLIT_BE_WIDTH; 
  localparam NODE_TYPE_HAS_MN = ((NODE_TYPE == MN) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI_MN) );
  localparam NODE_TYPE_HAS_HNI = ((NODE_TYPE == HNI) || (NODE_TYPE == HNI_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );
  localparam NODE_TYPE_HAS_HNF = ((NODE_TYPE == HNF) || (NODE_TYPE == HNF_MN) || (NODE_TYPE == HNF_HNI) || (NODE_TYPE == HNF_HNI_MN) );
  localparam NODE_TYPE_IS_ICN = NODE_TYPE_HAS_MN || NODE_TYPE_HAS_HNI || NODE_TYPE_HAS_HNF;

  //compares retries to crdreturns (+retry - crdrtn)
  logic [9:0] Retry_CrdRtn_cnt[1:numChi5nodes][num_crdtypes-1:0]; 
  logic [9:0] next_Retry_CrdRtn_cnt[1:numChi5nodes][num_crdtypes-1:0];
  //compares retries to crdgrants (-retry + crdgnt)
  logic [8:0] Retry_CrdGnt_cnt[1:numChi5nodes][num_crdtypes-1:0]; 
  logic [8:0] next_Retry_CrdGnt_cnt[1:numChi5nodes][num_crdtypes-1:0];
  //compares crdgrants to crdrtn (+crdgnt -crdrtn)
  logic [9:0] PCrdGnt_PCrdRtn_cnt [1:numChi5nodes][num_crdtypes-1:0];
  logic [9:0] next_PCrdGnt_PCrdRtn_cnt [1:numChi5nodes][num_crdtypes-1:0];
  //indicator that there is an outstanding credit
  logic [7:0] next_PCrd_OS;
  logic [7:0] PCrd_OS;
  logic retry_response;
  logic pcrdgrant_response;
  logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0] pcrdgrant_type;
  logic [6:0] rsp_src;
  logic pcrdreturn;
  logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0] pcrdreturn_type;
  logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0] retrycrd_type;
  logic [6:0] pcrdreturn_tgt;
  logic [6:0] pcrdreturn_src;
  logic [6:0] req_tgt;
  logic [6:0] req_src;
  logic [6:0] rsp_tgt;
  logic [6:0] rddat_tgt;
  logic [6:0] rddat_src;
  
  assign Info_Alloc_vector = in_Flight_vector | in_Retry_vector;
  assign S_RSP_Pop = S_RSPFLITV_ && 
     (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RETRYACK) &&
     (
    (( !Current_S_RSP_Info.ExpCompAck) ? 
       //Read and all data or last read data - this would be a readreceipt
       ((`IS_READ_(Current_S_RSP_Info) && (`HAS_ALLDATA(Current_S_RSP_Info) || (RDDAT_Last_ && (S_RSP_Info_Index == RDDAT_Info_Index)))) || 
         // CMO  - if no compack ends on comp
       (`IS_CLEAN__MAKE_(Current_S_RSP_Info))  || 
         //DVM - all data complete
       ((Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) && `HAS_ALLDATA(Current_S_RSP_Info) ) || 
         // WNS - All data complete or last data
       ((Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPPTL || Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPFULL) && (`HAS_ALLDATA(Current_S_RSP_Info) ||  (WRDAT_Last && (S_RSP_Info_Index == WRDAT_Info_Index) ))) || 
         // WU - All data complete or last data
       (`IS_WRITE__UNIQUE(Current_S_RSP_Info)  && (`HAS_ALLDATA(Current_S_RSP_Info ) || (WRDAT_Last && (S_RSP_Info_Index == WRDAT_Info_Index) ))) || 
         //Evict/barrier response ends
       `IS_EVICT__BARRIER(Current_S_RSP_Info)) : 
         //DVMs do not use compack
       (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP &&  &Current_S_RSP_Info.DATID ) ||
         // WNS - All data complete or last data
       ((Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPPTL || Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPFULL) && (`HAS_ALLDATA(Current_S_RSP_Info) ||  (WRDAT_Last && (S_RSP_Info_Index == WRDAT_Info_Index) ))) || 
         //Evict/barrier response ends
       `IS_EVICT__BARRIER(Current_S_RSP_Info) ||
         //Reads that have had compack and pop on readreceipt
       (`IS_READ_(Current_S_RSP_Info) && (`HAS_ALLDATA(Current_S_RSP_Info) || (RDDAT_Last_ && (S_RSP_Info_Index == RDDAT_Info_Index))) && Current_S_RSP_Info.CompAck) )) ; 


  assign M_RSP_Pop = M_RSPFLITV_ && 
       (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] ==  `CHI5PC_COMPACK) &&
       //for an ordered read must have seen readreceipt
       ((`IS_READ_(Current_M_RSP_Info) ? (|Current_M_RSP_Info.Order ? ((Current_M_RSP_Info.RspOpCode1 == `CHI5PC_READRECEIPT)||  (S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT) &&  (M_RSP_Info_Index == S_RSP_Info_Index))): 1'b1) : 
         //for a Write || CMO , must have seen comp and all Data
         `HAS_COMP(Current_M_RSP_Info) && (`HAS_ALLDATA(Current_M_RSP_Info) || (WRDAT_Last && (M_RSP_Info_Index ==WRDAT_Info_Index) ))));



  assign RDDAT_Pop = RDDATFLITV_ && RDDAT_Last_ &&
                      (!Current_RDDAT_Info.ExpCompAck) &&
                      //if ordering requested, must have seen readreceipt. 
                     (~&Current_RDDAT_Info.RspOpCode1 || ~|Current_RDDAT_Info.Order );

  assign WRDAT_Pop = WRDATFLITV_ && WRDAT_Last && //Last data beat
                     (((Current_WRDAT_Info.OpCode == `CHI5PC_WRITENOSNPFULL || Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITENOSNPPTL) && 
                        ((`HAS_DBIDRESP_COMP(Current_WRDAT_Info) || 
                        //has dbidresp and is doing comp
                        (S_RSPFLITV_ && (WRDAT_Info_Index == S_RSP_Info_Index) && ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && `HAS_DBIDRESP(Current_WRDAT_Info) || 
                        //has comp and is doing dbidresp
                        (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP) && `HAS_COMP(Current_WRDAT_Info)))))) || 

                     //transactions that are affected by compack
                     ((!Current_WRDAT_Info.ExpCompAck) ?
                       `IS_WRITE__UNIQUE(Current_WRDAT_Info) && 
                         (`HAS_DBIDRESP_COMP(Current_WRDAT_Info) || 
                           (S_RSPFLITV_ && (WRDAT_Info_Index == S_RSP_Info_Index) && 
                             ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && `HAS_DBIDRESP(Current_WRDAT_Info) || 
                        //has comp and is doing dbidresp
                              ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP) && `HAS_COMP(Current_WRDAT_Info))))):
                       `IS_WRITE__UNIQUE(Current_WRDAT_Info) && 
                         (`HAS_DBIDRESP_COMP(Current_WRDAT_Info)) && 
                         ((Current_WRDAT_Info.CompAck) || ((WRDAT_Info_Index == M_RSP_Info_Index) && M_RSPFLITV_ && M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK))) ||
                       `IS_WBACK__WCLEAN__WEF(Current_WRDAT_Info)) ;

  assign mem_attr = REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE];    
  assign memattr_allocate = mem_attr[`CHI5PC_MEMATTR_ALLOCATE_RANGE]; 
  assign memattr_cacheable = mem_attr[`CHI5PC_MEMATTR_CACHEABLE_RANGE]; 
  assign memattr_device = mem_attr[`CHI5PC_MEMATTR_DEVICE_RANGE]; 
  assign memattr_ewa = mem_attr[`CHI5PC_MEMATTR_EARLYWRACK_RANGE]; 
  assign NO_ORDER = REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 2'b00;
  assign REQ_ORDER = REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 2'b10;
  assign EO_ORDER = REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 2'b11;
  // struct assignment doesn't work without intermediate assignment
  logic [43:0]  tmp_Addr;
  logic [`CHI5PC_REQ_FLIT_ADDR_WIDTH-1:0] req_addr;
  logic [63:0] tmp_BE;
  assign tmp_BE = (Info_tmp.OpCode == `CHI5PC_DVMOP) ? 64'h3F : Chi5_in.Expect_BE(req_addr[5:0],memattr_device,Info_tmp.Size);
  assign req_addr                = REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE];
  assign Info_tmp.SrcID          = REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE];
  assign Info_tmp.TgtID          = REQFLIT_[`CHI5PC_REQ_FLIT_TGTID_RANGE];
  assign Info_tmp.TgtID_rmp      = Chi5PC_SAM_pkg::SAM_remap(REQFLIT_);
  assign Info_tmp.TxnID          = REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE];
  assign Info_tmp.CCID           = req_addr[5:4];
  assign Info_tmp.Previous       = in_Flight_vector & ~Info_Pop_vector;
  assign Info_tmp.OpCode         = eChi5PCReqOp'(REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]);
  assign Info_tmp.QoS            = eChi5PCQoS'(REQFLIT_[`CHI5PC_REQ_FLIT_QOS_RANGE]);
  assign Info_tmp.Size            = eChi5PCSize'(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE]);
  //this is a struct. Do not use indexing on this
  assign tmp_Addr                 = REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE];
  assign Info_tmp.Addr            = tmp_Addr;
  assign Info_tmp.NS              = eChi5PCNS'(REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]);
  assign Info_tmp.DynPCrd         = eChi5PCDynPCrd'(REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE]);
  assign Info_tmp.Order           = eChi5PCOrder'(REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE]);
  assign Info_tmp.LikelyShared    = REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE];
  assign Info_tmp.LPID            = REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE];
  assign Info_tmp.Excl            = eChi5PCExcl'(REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE]);
  assign Info_tmp.ExpCompAck      = REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE];
  assign Info_tmp.PCrdType        = '0;
  assign Info_tmp.SnpAttr         = REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE];
  assign Info_tmp.MemAttr         = REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE];
  assign Info_tmp.RspOpCode1      = '1;
  assign Info_tmp.DBID            = '1;
  assign Info_tmp.RspOpCode2      = '1;
  assign Info_tmp.CompAck         = '0;
  assign Info_tmp.DATID           = '0;
  assign Info_tmp.Exp_DATID       = Chi5_in.Expect_DATAID(REQFLIT_);
  assign Info_tmp.Exp_BE          = tmp_BE;
  assign Info_tmp.DATResp         = '1;
  assign Info_tmp.DATRespErr      = '1;
  assign Info_tmp.in_Retry        = '0;

  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      in_Flight_vector <= 'b0;
      INFO_PUSH <= 1'b0;
      INFO_RDDAT  <= 1'b0;
      INFO_WRDAT  <= 1'b0;
      INFO_RXRSP  <= 1'b0;
      INFO_POP  <= 1'b0;
      PCRDRETURN <= 1'b0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        Info[i] <= '0;
        Info[i].Exp_BE <= '0;
        Info[i].CompAck <= '0;
        Info[i].RspOpCode1 <= '1;
        Info[i].RspOpCode2 <= '1;
      end
    end 
    else
    begin
      if(REQFLITV_ &&  (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDRETURN))
        PCRDRETURN <= 1'b1;
      in_Flight_vector <= in_Flight_vector &  ~Info_Pop_vector;
      if (|Info_Pop_vector)
        INFO_POP <= ~INFO_POP;

      //do not push a LinkFlit
      if(REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT) && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN))
      begin
        //if we using using static credit then we are retyring a transaction
          //and we need to move it from in_retry to in_Flight
        if (!REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] && Retry_match)
        begin
          Info[Payload_match_Info_Index].in_Retry  <= 1'b0;
          Info[Payload_match_Info_Index] <= Info_tmp;
          in_Flight_vector[Payload_match_Info_Index]  <= 1'b1;
        end
        else
        begin
          Info[Info_Index_next] <= Info_tmp;
          in_Flight_vector[Info_Index_next] <= 1'b1;
          INFO_PUSH <= ~INFO_PUSH;
        end
      end
      //capture responses
      if (S_RSPFLITV_ && |S_RSP_Info_Index && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RSPLINKFLIT))
      begin
        // only move into the retry queue if you have not already had the credit granted
        if ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK))
        begin
          Info[S_RSP_Info_Index].in_Retry <= 1'b1;
          in_Flight_vector[S_RSP_Info_Index]  <= 1'b0;
          Info[S_RSP_Info_Index].PCrdType <= S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE];
        end
        //if you are not about to pop Current_S_RSP_Info
        if ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) || 
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP ))
        begin
          Info[S_RSP_Info_Index].DBID <= S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE];
        end

        if (!Info_Pop_vector[S_RSP_Info_Index])
        begin
          //store the response in RSP2 if RSP1 has already been stored
          if (!(&Current_S_RSP_Info.RspOpCode1))
          begin
            Info[S_RSP_Info_Index].RspOpCode2 <= S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE];
          end
          else
          begin
            Info[S_RSP_Info_Index].RspOpCode1 <= S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE];
            if ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP) || S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)
              Info[S_RSP_Info_Index].DBID <= S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE];
          end
          INFO_RXRSP <= ~INFO_RXRSP;
        end
      end
      if (M_RSPFLITV_ && |M_RSP_Info_Index)
      begin
        if (!Info_Pop_vector[M_RSP_Info_Index])
        begin
          if (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK)
          begin
            Info[M_RSP_Info_Index].CompAck <= 1'b1;
          end
        end
      end
      //capture data event and record the bytes transferred
      if (RDDATFLITV_ && |RDDAT_Info_Index)
      begin
        if (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA) 
        begin
          Info[RDDAT_Info_Index].DBID <= RDDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE];
        end
        //if this is the first data then store the resp to compare to
        //subsequent beats
        if (~|Info[RDDAT_Info_Index].DATID) 
        begin
          Info[RDDAT_Info_Index].DATResp <= RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE];
        end
        //selectively update the DATRespErr field. Rules are only interested
        //in conflict between CHI5PC_EXCL_OK and EXCL_FAIL
        if (~RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB] && !Info_Pop_vector[RDDAT_Info_Index] ) 
        begin
          Info[RDDAT_Info_Index].DATRespErr <= RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE];
        end
        //if you are not about to pop Current_RDDAT_Info
        if (!Info_Pop_vector[RDDAT_Info_Index])
        begin
          case (DAT_FLIT_WIDTH)
            `CHI5PC_128B_DAT_FLIT_WIDTH:
            begin
              case (RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[RDDAT_Info_Index].DATID[0] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b01:
                  Info[RDDAT_Info_Index].DATID[1] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                  Info[RDDAT_Info_Index].DATID[2] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b11:
                  Info[RDDAT_Info_Index].DATID[3] <= 1'b1;
              endcase;
            end
            `CHI5PC_256B_DAT_FLIT_WIDTH:
            begin
              case (RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                begin
                  Info[RDDAT_Info_Index].DATID[0] <= 1'b1;
                  Info[RDDAT_Info_Index].DATID[1] <= 1'b1;
                end
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                begin
                  Info[RDDAT_Info_Index].DATID[2] <= 1'b1;
                  Info[RDDAT_Info_Index].DATID[3] <= 1'b1;
                end
              endcase;
            end
            `CHI5PC_512B_DAT_FLIT_WIDTH:
            begin
              case (RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[RDDAT_Info_Index].DATID <= 4'b1111;
              endcase;
            end
          endcase;

          INFO_RDDAT <= ~INFO_RDDAT;
        end
      end
      if (WRDATFLITV_ && |WRDAT_Info_Index)
      begin
        if (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA) 
        begin
          Info[WRDAT_Info_Index].DBID <= WRDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE];
        end
        //if you are not about to pop Current_WRDAT_Info
        if (!Info_Pop_vector[WRDAT_Info_Index])
        begin
          //if this is the first data then store the resp to compare to
          //subsequent beats
          if (~|Info[WRDAT_Info_Index].DATID) 
          begin
            Info[WRDAT_Info_Index].DATResp <= WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE];
            Info[WRDAT_Info_Index].DATRespErr <= WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE];
          end
          case (DAT_FLIT_WIDTH)
            `CHI5PC_128B_DAT_FLIT_WIDTH:
            begin
              case (WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[WRDAT_Info_Index].DATID[0] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b01:
                  Info[WRDAT_Info_Index].DATID[1] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                  Info[WRDAT_Info_Index].DATID[2] <= 1'b1;
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b11:
                  Info[WRDAT_Info_Index].DATID[3] <= 1'b1;
              endcase;
            end
            `CHI5PC_256B_DAT_FLIT_WIDTH:
            begin
              case (WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                begin
                  Info[WRDAT_Info_Index].DATID[0] <= 1'b1;
                  Info[WRDAT_Info_Index].DATID[1] <= 1'b1;
                end
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b10:
                begin
                  Info[WRDAT_Info_Index].DATID[2] <= 1'b1;
                  Info[WRDAT_Info_Index].DATID[3] <= 1'b1;
                end
              endcase;
              if (`IS_DVMOP_(Current_WRDAT_Info))
              begin
                  Info[WRDAT_Info_Index].DATID <= 4'b1111;
              end 
            end
            `CHI5PC_512B_DAT_FLIT_WIDTH:
            begin
              case (WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE])
                `CHI5PC_DAT_FLIT_DATAID_WIDTH'b00:
                  Info[WRDAT_Info_Index].DATID <= 4'b1111;
              endcase;
              if (`IS_DVMOP_(Current_WRDAT_Info))
              begin
                  Info[WRDAT_Info_Index].DATID <= 4'b1111;
              end 
            end
          endcase;
          INFO_WRDAT <= ~INFO_WRDAT;
        end
      end
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (in_Flight_vector[i] && !Info_Pop_vector[i])
        begin
          Info[i].Previous <= Info[i].Previous &  ~Info_Pop_vector & ~in_Retry_vector;
        end
      end
    end
  end

  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      PreBarrier_writes <= 'b0;
    end
    else if (REQFLITV_ && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER) || (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER)))
    begin
      PreBarrier_writes[Info_tmp.LPID] <= 1'b0;
    end
    else if (REQFLITV_ && `IS_WRITE_(Info_tmp) && !memattr_cacheable)
    begin
      PreBarrier_writes[Info_tmp.LPID] <= 1'b1;
    end
  end

  
  generate
  genvar k;
    for (k = 1; k <= MAX_OS_TX; k = k + 1)
    begin : in_Retry_gen
      assign in_Retry_vector[k] = Chi5_in.SRESETn && Info[k].in_Retry ;
    end : in_Retry_gen
  endgenerate
  
  generate
  genvar l;
    for (l = 1; l <= MAX_OS_TX; l = l + 1)
    begin : Has_no_RSP1_gen
      assign Has_no_RSP1_or_data_vector[l] = Chi5_in.SRESETn && &Info[l].RspOpCode1 && in_Flight_vector[l] && ~|Info[l].DATID;
    end : Has_no_RSP1_gen
  endgenerate
  
  generate
    for (l = 1; l <= MAX_OS_TX; l = l + 1)
    begin : txactive_gen
      assign txactive_vector[l] = Chi5_in.SRESETn && in_Flight_vector[l] &&
      ((`IS_READ_(Info[l]) && !Has_no_RSP1_or_data_vector[l] && ((Info[l].Order && ~&Info[l].RspOpCode1) || !Has_ALLDATA_vector[l] || Info[l].ExpCompAck)) ||
      (!Has_no_RSP1_or_data_vector[l] && (!Has_DBIDRESP_COMP_vector[l] || !Has_ALLDATA_vector[l] || Info[l].ExpCompAck)) ||
      // the transaction has moved back into in-Flight as a static request
       !Info[l].DynPCrd
       );
    end : txactive_gen
  endgenerate
  
  generate
  genvar m;
    for (m = 1; m <= MAX_OS_TX; m = m + 1)
    begin : Current_RDData_gen
      assign Current_RDData_vector[m] = Chi5_in.SRESETn && RDDAT_match && (RDDAT_Info_Index == m)  &&  RDDATFLITV_;
    end : Current_RDData_gen
  endgenerate
  
  generate
  genvar n;
    for (n = 1; n <= MAX_OS_TX; n = n + 1)
    begin : Is_Read_gen
      assign Is_Read_vector[n] = in_Flight_vector[n] && Chi5_in.SRESETn && `IS_READ_(Info[n]);
    end : Is_Read_gen
  endgenerate

  generate
  genvar p;
    for (p = 1; p <= MAX_OS_TX; p = p + 1)
    begin : Is_Clean_Make_gen
      assign Is_Clean_Make_vector[p] = in_Flight_vector[p] && Chi5_in.SRESETn && `IS_CLEAN__MAKE_(Info[p]);
    end : Is_Clean_Make_gen
  endgenerate

  generate
  genvar q;
    for (q = 1; q <= MAX_OS_TX; q = q + 1)
    begin : Is_CMO_gen
      assign Is_CMO_vector[q] = in_Flight_vector[q] && Chi5_in.SRESETn &&`IS_CMO_(Info[q]);
    end : Is_CMO_gen
  endgenerate

  generate
  genvar r;
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_Write_gen
      assign Is_Write_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn && `IS_WRITE_(Info[r]) ;
    end : Is_Write_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_memattrX0XX_gen
      assign Is_memattrX0XX_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn &&  ~Info[r].MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE] ;
    end : Is_memattrX0XX_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_snpattrX1_gen
      assign Is_snpattrX1_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn &&  Info[r].SnpAttr[`CHI5PC_SNPATTR_SNOOPABLE_RANGE] ;
    end : Is_snpattrX1_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_tgt_HNI_SNI_gen
      assign Is_tgt_HNI_SNI_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn &&  ((Chi5_in.get_NodeType(Info[r].TgtID_rmp) == eChi5PCDevType'(HNI)) || (Chi5_in.get_NodeType(Info[r].TgtID_rmp) == eChi5PCDevType'(SNI))) ;
    end : Is_tgt_HNI_SNI_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_tgt_HNF_gen
      assign Is_tgt_HNF_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn &&  (Chi5_in.get_NodeType(Info[r].TgtID_rmp) == eChi5PCDevType'(HNF)) ;
    end : Is_tgt_HNF_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_same_LPID_SRCID_gen
      assign Is_same_LPID_SRCID_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn   && (Info_tmp.SrcID == Info[r].SrcID) && (Info_tmp.LPID == Info[r].LPID);
    end : Is_same_LPID_SRCID_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_same_TGTID_gen
      assign Is_same_TGTID_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn  && (Info_tmp.TgtID_rmp == Info[r].TgtID_rmp);
    end : Is_same_TGTID_gen
  endgenerate

  generate
    for (r = 1; r <= MAX_OS_TX; r = r + 1)
    begin : Is_CopyBack_gen
      assign Is_CopyBack_vector[r] = in_Flight_vector[r] && Chi5_in.SRESETn && `IS_WBACK__WCLEAN__WEF(Info[r]) ;
    end : Is_CopyBack_gen
  endgenerate

  generate
  genvar s;
    for (s = 1; s <= MAX_OS_TX; s = s + 1)
    begin : Is_DVMOp_gen
      assign Is_DVMOp_vector[s] = in_Flight_vector[s] && Chi5_in.SRESETn && `IS_DVMOP_(Info[s]);
    end : Is_DVMOp_gen
  endgenerate

  generate
  genvar t;
    for (t = 1; t <= MAX_OS_TX; t = t + 1)
    begin : Is_Barrier_gen
      assign Is_Barrier_vector[t] = in_Flight_vector[t] && Chi5_in.SRESETn && `IS_BARRIER(Info[t]);
    end : Is_Barrier_gen
  endgenerate

  generate
    for (t = 1; t <= MAX_OS_TX; t = t + 1)
    begin : Is_Evict_Barrier_gen
      assign Is_Evict_Barrier_vector[t] = in_Flight_vector[t] && Chi5_in.SRESETn && (`IS_EVICT(Info[t]) || `IS_BARRIER(Info[t]));
    end : Is_Evict_Barrier_gen
  endgenerate

  generate
  genvar u;
    for (u = 1; u <= MAX_OS_TX; u = u + 1)
    begin : Is_Cacheable_gen
      assign Is_Cacheable_vector[u] = in_Flight_vector[u] && Chi5_in.SRESETn && Info[u].MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE];
    end : Is_Cacheable_gen
  endgenerate

  generate
  genvar w;
    for (w = 1; w <= MAX_OS_TX; w = w + 1)
    begin : Has_DBIDRESP_COMP_gen
      assign Has_DBIDRESP_COMP_vector[w] = in_Flight_vector[w] && Chi5_in.SRESETn && `HAS_DBIDRESP_COMP(Info[w]);
    end : Has_DBIDRESP_COMP_gen
  endgenerate

  generate
  genvar aa;
    for (aa = 1; aa <= MAX_OS_TX; aa = aa + 1)
    begin : Has_DBID_gen
      assign Has_DBID_vector[aa] = in_Flight_vector[aa] && Chi5_in.SRESETn && `HAS_DBID(Info[aa]);
    end : Has_DBID_gen
  endgenerate

  generate
  genvar ab;
    for (ab = 1; ab <= MAX_OS_TX; ab = ab + 1)
    begin : Has_DBIDRESP_gen
      assign Has_DBIDRESP_vector[ab] = in_Flight_vector[ab] && Chi5_in.SRESETn && `HAS_DBIDRESP(Info[ab]);
    end : Has_DBIDRESP_gen
  endgenerate

  generate
  genvar ac;
    for (ac = 1; ac <= MAX_OS_TX; ac = ac + 1)
    begin : Has_ALLDATA_gen
      assign Has_ALLDATA_vector[ac] = in_Flight_vector[ac] && Chi5_in.SRESETn && `HAS_ALLDATA(Info[ac]) ;
    end : Has_ALLDATA_gen
  endgenerate

  generate
  genvar ad;
    for (ad = 1; ad <= MAX_OS_TX; ad = ad + 1)
    begin : Has_Comp_gen
      assign Has_Comp_vector[ad] = in_Flight_vector[ad] && Chi5_in.SRESETn && `HAS_COMP(Info[ad]) || `HAS_COMPDATA(Info[ad]);
    end : Has_Comp_gen
  endgenerate

  logic [43:6] RXSNP_Addr;
  assign RXSNP_Addr = SNPFLIT_[`CHI5PC_SNP_FLIT_ADDR_MSB:`CHI5PC_SNP_FLIT_ADDR_LSB+3];
  generate
  genvar ae;
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : RXSNP_Addr_NS_haz_gen
      assign RXSNP_Addr_NS_haz_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
               ((`IS_READ_(Info[ae]) && `HAS_COMPDATA(Info[ae]) && (Info[ae].ExpCompAck && !Info[ae].CompAck)) ||
                (`IS_WRITE_(Info[ae]) && `HAS_COMP(Info[ae])) ||
                (`IS_CLEAN__MAKE_(Info[ae]) && `HAS_COMP(Info[ae]))
               ) &&
               Info[ae].MemAttr[2] &&
               (Info[ae].OpCode != `CHI5PC_DVMOP) && 
               (Info[ae].Addr[43:6] == RXSNP_Addr) &&
               (Info[ae].NS == SNPFLIT_[`CHI5PC_SNP_FLIT_NS_RANGE]);
    end : RXSNP_Addr_NS_haz_gen
  endgenerate

  generate
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : is_CleanUnique_gen
      assign is_CleanUnique_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
               (Info[ae].OpCode == `CHI5PC_CLEANUNIQUE);
    end : is_CleanUnique_gen
  endgenerate

  generate
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : is_ReadShared_ReadClean_gen
      assign is_ReadShared_ReadClean_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
          ((Info[ae].OpCode == `CHI5PC_READCLEAN) ||
          ( Info[ae].OpCode== `CHI5PC_READSHARED));
    end : is_ReadShared_ReadClean_gen
  endgenerate

  generate
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : excl_ovlap_snoopable_gen
      assign excl_ovlap_snoopable_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
               Info[ae].Excl &&
               (Info[ae].LPID == REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE]) &&
               (Info[ae].SrcID == REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]) &&
               !waiting_for_compack_vector[ae];
    end : excl_ovlap_snoopable_gen
  endgenerate

  generate
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : excl_ovlap_nonsnoopable_gen
      assign excl_ovlap_nonsnoopable_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
               Info[ae].Excl &&
               REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] &&
               (Info[ae].LPID == REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE]) &&
               (Info[ae].SrcID == REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]) &&
               !waiting_for_compack_vector[ae] &&
               ((Info[ae].OpCode == `CHI5PC_READNOSNP) || 
               (((Info[ae].OpCode == `CHI5PC_WRITENOSNPPTL) || (Info[ae].OpCode == `CHI5PC_WRITENOSNPFULL)) && !Has_DBIDRESP_COMP_vector[ae]));
    end : excl_ovlap_nonsnoopable_gen
  endgenerate

  generate
    for (ae = 1; ae <= MAX_OS_TX; ae = ae + 1)
    begin : waiting_for_compack_gen
      assign waiting_for_compack_vector[ae] = in_Flight_vector[ae] && Chi5_in.SRESETn && 
               Info[ae].ExpCompAck &&
               (~|Info[ae].Exp_DATID || Has_ALLDATA_vector[ae]) &&
               ((Is_Write_vector[ae] && Has_DBIDRESP_COMP_vector[ae]) ||
               (Is_Clean_Make_vector[ae] && Has_Comp_vector[ae]) ||
               (Is_Read_vector[ae] && (!Info[ae].Order || (Info[ae].RspOpCode1 == `CHI5PC_READRECEIPT))));
    end : waiting_for_compack_gen
  endgenerate


  generate
  genvar ag;
    for (ag = 1; ag <= MAX_OS_TX; ag = ag + 1)
    begin : ID_CLASH_gen
      assign ID_CLASH_vector[ag] = in_Flight_vector[ag] && Chi5_in.SRESETn &&
                 ((Info[ag].TxnID == REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE]) &&
                 ((MODE ==1) || (Info[ag].SrcID == REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE])) &&
                 ((Is_Read_vector[ag] && ((&Info[ag].RspOpCode1 && |Info[ag].Order) ||  !Has_ALLDATA_vector[ag]) ) ||
                  (Is_Clean_Make_vector[ag] && ~Has_Comp_vector[ag]) ||
                  (Info[ag].OpCode == `CHI5PC_DVMOP) ||
                  (Is_Write_vector[ag] && !Has_DBIDRESP_COMP_vector[ag]) ||
                  (Is_Evict_Barrier_vector[ag] )));
    end : ID_CLASH_gen
  endgenerate

  generate
    for (ag = 1; ag <= MAX_OS_TX; ag = ag + 1)
    begin : REQ_Attr_CLASH_gen
      assign REQ_Attr_CLASH_vector[ag] = in_Flight_vector[ag] && Chi5_in.SRESETn &&
                 (Info[ag].OpCode != `CHI5PC_DVMOP) &&
                 (Info[ag].Addr[43:6] == tmp_Addr[43:6]) &&
                 (Info[ag].NS == REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE]) &&
                 //don't care about allocate
                 //don't care about EWA for normal, noncacheable
                 ((Info[ag].MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE] != memattr_cacheable) ||
                  (Info[ag].MemAttr[`CHI5PC_MEMATTR_DEVICE_RANGE] != memattr_device) ||
                  ((memattr_device || memattr_cacheable) && (Info[ag].MemAttr[`CHI5PC_MEMATTR_EARLYWRACK_RANGE] != memattr_ewa)) ||
                 (Info[ag].SnpAttr != REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE])) ;
    end : REQ_Attr_CLASH_gen
  endgenerate

  generate
    for (ag = 1; ag <= MAX_OS_TX; ag = ag + 1)
    begin : SNP_Attr_CLASH_gen
      assign SNP_Attr_CLASH_vector[ag] = in_Flight_vector[ag] && Chi5_in.SRESETn &&
                 (Info[ag].OpCode != `CHI5PC_DVMOP) &&
                 (Info[ag].Addr[43:6] == RXSNP_Addr) &&
                 (Info[ag].NS == SNPFLIT_[`CHI5PC_SNP_FLIT_NS_RANGE]) &&
                 (!Info[ag].MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE] |
                 !Info[ag].SnpAttr[`CHI5PC_SNPATTR_SNOOPABLE_RANGE]) ;
    end : SNP_Attr_CLASH_gen
  endgenerate


  generate
  genvar ah;
    for (ah = 1; ah <= MAX_OS_TX; ah = ah + 1)
    begin : DBID_INUSE_vector_gen 
      assign DBID_INUSE_vector[ah] = in_Flight_vector[ah] && Chi5_in.SRESETn && 
               ((Info[ah].ExpCompAck && !Info[ah].CompAck) || ((!Is_Read_vector[ah])  && !Has_ALLDATA_vector[ah] )) &&
                 Has_DBID_vector[ah] ;
    end : DBID_INUSE_vector_gen 
  endgenerate
  generate
  genvar ai;
    for (ai = 1; ai <= MAX_OS_TX; ai = ai + 1)
    begin : RSP_DBID_ALLOC_ERR_gen 
      assign RSP_DBID_ALLOC_ERR_vector[ai] = in_Flight_vector[ai] && Chi5_in.SRESETn && 
               S_RSPFLITV_ && S_RSP_match && (S_RSP_Info_Index != ai) && 
               (Current_S_RSP_Info.ExpCompAck || (~(`IS_READ_(Current_S_RSP_Info)) && !(`HAS_ALLDATA(Current_S_RSP_Info)))) &&
                 DBID_INUSE_vector[ai] &&  
                 (Info[ai].DBID == S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE]) && 
                 (Info[ai].TgtID_rmp == S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]) &&
                 ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP ) || 
                  (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP ) || 
                  (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP ));
    end : RSP_DBID_ALLOC_ERR_gen 
  endgenerate

  generate
  genvar aj;
    for (aj = 1; aj <= MAX_OS_TX; aj = aj + 1)
    begin : DAT_DBID_ALLOC_ERR_gen 
      assign DAT_DBID_ALLOC_ERR_vector[aj] = in_Flight_vector[aj] && Chi5_in.SRESETn && 
                 RDDATFLITV_ && RDDAT_match && (RDDAT_Info_Index != aj) &&
                 DBID_INUSE_vector[aj] &&  
                 (Info[aj].TgtID_rmp == RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE]) &&
                 (Info[aj].DBID == RDDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE]) && 
                ( RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA ) && Current_RDDAT_Info.ExpCompAck;
    end : DAT_DBID_ALLOC_ERR_gen 
  endgenerate

  generate
  genvar ak;
    for (ak = 1; ak <= MAX_OS_TX; ak = ak + 1)
    begin : DATORDER_ERR_gen
      assign DATORDER_ERR_vector[ak] = in_Flight_vector[ak] && Chi5_in.SRESETn && RDDAT_match && (Current_RDDAT_Info.Previous[ak] && |Info[ak].Order && Is_Read_vector[ak] && (Info[ak].TgtID_rmp == Current_RDDAT_Info.TgtID_rmp));
    end : DATORDER_ERR_gen
  endgenerate

  generate
  genvar al;
    for (al = 1; al <= MAX_OS_TX; al = al + 1)
    begin : REQORDER_ERR_gen
      assign REQORDER_ERR_vector[al] = Info_Alloc_vector[al] && Chi5_in.SRESETn && |Info[al].Order &&  
                                      |Info_tmp.Order && (Info[al].TgtID_rmp == Info_tmp.TgtID_rmp) && 
                                       (Info[al].SrcID == Info_tmp.SrcID) && (Info[al].LPID == Info_tmp.LPID) && 
                                         ((Is_Read_vector[al] && Has_no_RSP1_or_data_vector[al] ) ||
                                        (Is_Write_vector[al] && (!Has_DBIDRESP_vector[al] && !Has_Comp_vector[al])));
    end : REQORDER_ERR_gen
  endgenerate

  generate
  genvar sy;
    for (sy = 1; sy <= MAX_OS_TX; sy = sy + 1)
    begin : DVM_SYNC_CLASH_gen
      assign DVM_SYNC_CLASH_vector[sy] = in_Flight_vector[sy] && Chi5_in.SRESETn && 
                                   (Info[sy].OpCode == `CHI5PC_DVMOP) &&
                                   (Info[sy].Addr.REQ_DVM.Type == CHI5PC_DVM_SYNC) &&
                                   (Info[sy].LPID == REQFLIT_[`CHI5PC_REQ_FLIT_LPID_RANGE]) &&
                                   (Info[sy].SrcID == REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]);
    end : DVM_SYNC_CLASH_gen
  endgenerate

  generate
  genvar am;
    for (am = 1; am <= MAX_OS_TX; am = am + 1)
    begin : GO_gen
      assign GO_vector[am] = Info_Alloc_vector[am] && Chi5_in.SRESETn  &&
                            ((Is_Read_vector[am] &&  ~&Info[am].RspOpCode1)) ||
                             Has_Comp_vector[am] ;
    end : GO_gen
  endgenerate

  //match the rsp to an outstanding request with matching Txnid 
  generate
  genvar an;
    for (an = 1; an <= MAX_OS_TX; an = an + 1)
    begin : S_RSP_match_gen
      assign S_RSP_match_vector[an] = in_Flight_vector[an] && Chi5_in.SRESETn  && S_RSPFLITV_ &&
          (((S_RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] == Info[an].TxnID) && 
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE] ==  Info[an].TgtID_rmp) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE] ==  Info[an].SrcID) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_PCRDGRANT) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_RSPLINKFLIT) &&
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] !=  `CHI5PC_SNPRESP)) &&
              // test if the TXNId for this entry has been retired
            (((Is_Clean_Make_vector[an] || Is_Evict_Barrier_vector[an]) && !Has_Comp_vector[an]) ||
              ((Is_Write_vector[an] || (Info[an].OpCode == `CHI5PC_DVMOP) ) && !Has_DBIDRESP_COMP_vector[an]) ||
              (Is_Read_vector[an] && ((&Info[an].RspOpCode1 && |Info[an].Order) ||  !Has_ALLDATA_vector[an])) )
            );
                                        
    end : S_RSP_match_gen
  endgenerate
  assign S_RSP_match = |S_RSP_match_vector;
  assign RXRSP_match = |S_RSP_match_vector;
  
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      S_RSP_Info_Index = '0;
    end
    else
    begin
      S_RSP_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (S_RSP_match_vector[i])
        begin
            S_RSP_Info_Index = i;
        end
      end
    end
  end
  assign Current_S_RSP_Info = |S_RSP_Info_Index ? Info[S_RSP_Info_Index] : 'b0;
  //temp variable required here otherwise the bit slice on the struct fails
  logic [43:0] S_RSP_Addr;
  assign S_RSP_Addr =      Current_S_RSP_Info.Addr;
  assign S_RSP_Addr_NS = |S_RSP_Info_Index ? {S_RSP_Addr,Current_S_RSP_Info.NS} : 'b0;
  assign S_RSP_Comp_Haz = |S_RSP_Info_Index && ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP)) && 
         ((Current_S_RSP_Info.OpCode == `CHI5PC_CLEANUNIQUE) || 
          (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEUNIQUE) || 
          (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANSHARED) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANINVALID) || 
          (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEINVALID) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEEVICTFULL)); 

  assign S_RSP_Dev_Size = {(Current_S_RSP_Info.MemAttr[1]),Current_S_RSP_Info.Size};      
  assign S_RSP_Comp_Wr = |S_RSP_Info_Index && ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP)) && 
         (
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEEVICTFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKFULL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPPTL) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPFULL)); 


  generate
  genvar ap;
    for (ap = 1; ap <= MAX_OS_TX; ap = ap + 1)
    begin : M_RSP_match_gen
      assign M_RSP_match_vector[ap] = in_Flight_vector[ap] && Chi5_in.SRESETn && 
                                     (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] ==  `CHI5PC_COMPACK) && 
                                      (((Is_Read_vector[ap] ? |Info[ap].DATID :  ~&Info[ap].RspOpCode1)) &&
                                      Info[ap].ExpCompAck && !Info[ap].CompAck &&
                                      (M_RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] == Info[ap].DBID)   &&
                                      (M_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE] ==  Info[ap].TgtID_rmp) && 
                                      (M_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE] ==  Info[ap].SrcID) );
    end : M_RSP_match_gen
  endgenerate
  assign M_RSP_match = |M_RSP_match_vector;
  assign TXRSP_match = |M_RSP_match_vector;
  //match the rsp to an outstanding request with matching Txnid 
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      M_RSP_Info_Index = '0;
    end
    else
    begin
      M_RSP_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (M_RSP_match_vector[i])
        begin
              M_RSP_Info_Index = i;
          end
      end
    end
  end
  assign Current_M_RSP_Info = |M_RSP_Info_Index ? Info[M_RSP_Info_Index] : 'b0;
  //match the txdata to an outstanding request with matching tgtid and Txnid 
  generate
  genvar aq;
    for (aq = 1; aq <= MAX_OS_TX; aq = aq + 1)
    begin : WRDAT_match_gen
      assign WRDAT_match_vector[aq] = in_Flight_vector[aq] && Chi5_in.SRESETn  &&
          (((WRDATFLIT_[`CHI5PC_DAT_FLIT_TXNID_RANGE] == Info[aq].DBID)  && ~&Info[aq].RspOpCode1) &&
              |WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] &&
              (WRDATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE] == Info[aq].TgtID_rmp) && 
              (WRDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE] == Info[aq].SrcID) &&
              !Has_ALLDATA_vector[aq] &&
               ((WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA) ||
               (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA)) && Has_DBIDRESP_vector[aq]);
    end : WRDAT_match_gen
  endgenerate
  assign WRDAT_match = |WRDAT_match_vector;

  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      WRDAT_Info_Index = '0;
    end
    else
    begin
      WRDAT_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (WRDAT_match_vector[i])
        begin
              WRDAT_Info_Index = i;
        end
      end
    end
  end
  assign Current_WRDAT_Info = |WRDAT_Info_Index ? Info[WRDAT_Info_Index] : 'b0;
  //match the RDDATa to an outstanding request with matching tgtid and Txnid 
  generate
  genvar ar;
    for (ar = 1; ar <= MAX_OS_TX; ar = ar + 1)
    begin : RDDAT_match_gen
      assign RDDAT_match_vector[ar] = in_Flight_vector[ar] && Chi5_in.SRESETn &&
          ((RDDATFLIT_[`CHI5PC_DAT_FLIT_TXNID_RANGE] == Info[ar].TxnID) 
               && !Has_DBIDRESP_COMP_vector[ar]
               && (RDDATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE] == Info[ar].SrcID)
               && (RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE] == Info[ar].TgtID_rmp)
               && (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA)
               && Is_Read_vector[ar] &&  !Has_ALLDATA_vector[ar]); 
    end : RDDAT_match_gen
  endgenerate
  assign RDDAT_match = |RDDAT_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      RDDAT_Info_Index = '0;
    end
    else
    begin
      RDDAT_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (RDDAT_match_vector[i])
            RDDAT_Info_Index = i;
      end
    end
  end
  assign Current_RDDAT_Info = |RDDAT_Info_Index ? Info[RDDAT_Info_Index] : 'b0;
  generate
  genvar as;
    for (as = 1; as <= MAX_OS_TX; as = as + 1)
    begin : Payload_match_gen
      assign Payload_match_vector[as] = in_Retry_vector[as] && Chi5_in.SRESETn  &&
          ( (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
               && (Info_tmp.TgtID_rmp == Info[as].TgtID_rmp)
               && (REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE] == Info[as].SrcID)
               && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == Info[as].OpCode) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == Info[as].Size) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE] == Info[as].Addr) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE] == Info[as].NS) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == Info[as].LikelyShared) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == Info[as].Order) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == Info[as].SnpAttr) 
               && (memattr_cacheable == Info[as].MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE]) 
               && (memattr_device == Info[as].MemAttr[`CHI5PC_MEMATTR_DEVICE_RANGE]) 
               && (memattr_ewa == Info[as].MemAttr[`CHI5PC_MEMATTR_EARLYWRACK_RANGE]) 
               //Do not match LPID
               && (REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == Info[as].Excl) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == Info[as].ExpCompAck) 
               && (REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE] == Info[as].PCrdType)) ;
    end : Payload_match_gen
  endgenerate
  logic Payload_match;
  assign Payload_match = |Payload_match_vector;
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      Payload_match_Info_Index = '0;
    end
    else
    begin
      Payload_match_Info_Index = '0;
      for (int i = 1; i <= MAX_OS_TX; i = i + 1)
      begin
        if (Payload_match_vector[i])
            Payload_match_Info_Index = i;
      end
    end
  end
  assign Current_Payload_match_Info = |Payload_match_Info_Index ? Info[Payload_match_Info_Index] : 'b0;
  assign Retry_match = Payload_match && (Current_Payload_match_Info.PCrdType == REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]);
  //temp variable required here otherwise the bit slice on the struct fails
  logic [43:0] RDDAT_Addr;
  assign RDDAT_Addr =      Current_RDDAT_Info.Addr;
  assign RDDAT_Addr_NS = |RDDAT_Info_Index ? {(RDDAT_Addr[43:6]),Current_RDDAT_Info.NS} : 'b0;
  assign RDDAT_Comp_Haz = |RDDAT_Info_Index && (Current_RDDAT_Info.OpCode != `CHI5PC_READNOSNP);
  logic [43:0] WRDAT_Addr;
  assign WRDAT_Addr =      Current_WRDAT_Info.Addr;
  assign WRDAT_Addr_NS = |WRDAT_Info_Index ? {(WRDAT_Addr[43:6]),Current_WRDAT_Info.NS} : 'b0;

  //determine the pop_vector
  
  generate
  genvar at;
    for (at = 1; at <= MAX_OS_TX; at = at + 1)
    begin : Info_Pop_gen
      assign Info_Pop_vector[at] = in_Flight_vector[at] && Chi5_in.SRESETn  ? 
                                  ((S_RSP_Pop && S_RSP_match_vector[at]) ||
                                   (M_RSP_Pop && M_RSP_match_vector[at]) ||
                                   (RDDAT_Pop && RDDAT_match_vector[at]) ||
                                   (WRDAT_Pop && WRDAT_match_vector[at]) )
                                      : 1'b0;
    end : Info_Pop_gen
  endgenerate
  //determine the next available location for the next request
  always_comb
  begin
    if (!Chi5_in.SRESETn)
    begin
      Info_Index_next = 1;
    end
    else
    begin
      Info_Index_next = 1;
      for (int i = MAX_OS_TX; i >= 1; i = i - 1)
      begin
        if ((!in_Flight_vector[i] && (!in_Retry_vector[i] || PCRDRETURN))|| Info_Pop_vector[i])
        begin
          Info_Index_next = i;
        end
      end
    end
  end

  //give a last signal for RDDATA
  always_comb
  begin
    if (!Chi5_in.SRESETn || !RDDATFLITV_)
    begin
      RDDAT_Last_ = 1'b0;
    end
    else
    begin
      RDDAT_Last_ = 1'b0;
      case (DAT_FLIT_WIDTH)
        `CHI5PC_128B_DAT_FLIT_WIDTH:
        begin
          case (Current_RDDAT_Info.DATID ^ Current_RDDAT_Info.Exp_DATID)
            4'b0001,4'b0010,4'b0100,4'b1000 :
            RDDAT_Last_ = 1'b1;
          default: 
            RDDAT_Last_ = 1'b0;
          endcase;
        end
        `CHI5PC_256B_DAT_FLIT_WIDTH:
        begin
          case (Current_RDDAT_Info.DATID ^ Current_RDDAT_Info.Exp_DATID)
            4'b1100,4'b0011 :
            RDDAT_Last_ = 1'b1;
          default: 
            RDDAT_Last_ = 1'b0;
          endcase;
        end
        `CHI5PC_512B_DAT_FLIT_WIDTH:
        begin
          RDDAT_Last_ = 1'b1;
        end
      endcase;
    end
  end
  //give a last signal for WRDATA
  always_comb
  begin
    if (!Chi5_in.SRESETn || !WRDATFLITV_)
    begin
      WRDAT_Last = 1'b0;
    end
    else
    begin
      WRDAT_Last = 1'b0;
      case (DAT_FLIT_WIDTH)
        `CHI5PC_128B_DAT_FLIT_WIDTH:
        begin
          case (Current_WRDAT_Info.DATID ^ Current_WRDAT_Info.Exp_DATID)
            4'b0001,4'b0010,4'b0100,4'b1000 :
            WRDAT_Last = 1'b1;
          default: 
            WRDAT_Last = 1'b0;
          endcase;
        end
        `CHI5PC_256B_DAT_FLIT_WIDTH:
        begin
          case (Current_WRDAT_Info.DATID ^ Current_WRDAT_Info.Exp_DATID)
            4'b1100,4'b0011 :
            WRDAT_Last = 1'b1;
          default: 
            WRDAT_Last = 1'b0;
          endcase;
        end
        `CHI5PC_512B_DAT_FLIT_WIDTH:
        begin
          WRDAT_Last = 1'b1;
        end
      endcase;
    end
  end

  logic [1:MAX_OS_TX] TXPREV_WU_ERR_vector;
  generate
  genvar au;
    for (au = 1; au <= MAX_OS_TX; au = au + 1)
    begin : TXPREV_WU_ERR_gen
      assign TXPREV_WU_ERR_vector[au] = in_Flight_vector[au] && Chi5_in.SRESETn &&
                                       (Current_M_RSP_Info.Previous[au] && 
              ((Info[au].OpCode == `CHI5PC_WRITEUNIQUEPTL) || (Info[au].OpCode == `CHI5PC_WRITEUNIQUEFULL)) &&
               (Current_M_RSP_Info.SrcID == Info[au].SrcID) &&
               (Current_M_RSP_Info.LPID == Info[au].LPID) &&
               (Current_M_RSP_Info.TgtID_rmp == Info[au].TgtID_rmp) &&
                |Info[au].Order && 
                Info[au].ExpCompAck && 
                !Has_Comp_vector[au] );
    end : TXPREV_WU_ERR_gen
  endgenerate

  logic [1:MAX_OS_TX] M_RSP_ORDER_ERR_vector;
  generate
  genvar av;
    for (av = 1; av <= MAX_OS_TX; av = av + 1)
    begin : M_RSP_ORDER_ERR_gen
      assign M_RSP_ORDER_ERR_vector[av] = in_Flight_vector[av] && Chi5_in.SRESETn &&
                                         (Current_M_RSP_Info.Previous[av] && ( (Info[av].Order == CHI5PC_ORDER_REQ) 
                                         && (Info[av].SrcID == Current_M_RSP_Info.SrcID) && &Info[av].RspOpCode1));
    end : M_RSP_ORDER_ERR_gen
  endgenerate

      

  logic [1:MAX_OS_TX] Addr_overlap_vector;
  generate
  genvar ax;
    if (((NODE_TYPE == RNF) || (NODE_TYPE == RNI) || (NODE_TYPE == RND) ) || ((NODE_TYPE_HAS_HNF) && (MODE ==0)) || RecommendOn_Haz)
    begin
      for (ax = 1; ax <= MAX_OS_TX; ax = ax + 1)
      begin : Addr_overlap_vector_gen
        always_comb
        begin
          if(in_Flight_vector[ax] && Chi5_in.SRESETn && REQFLITV_ && |Info_tmp.OpCode)
          begin
            if ((Info_tmp.OpCode !=  `CHI5PC_EOBARRIER) && (Info_tmp.OpCode !=  `CHI5PC_ECBARRIER) && (Info_tmp.OpCode !=  `CHI5PC_DVMOP))
            begin
              if ((Info[ax].Addr[43:6] == Info_tmp.Addr[43:6]) && |(Info[ax].Exp_BE & Info_tmp.Exp_BE) && (Info[ax].NS == Info_tmp.NS) )
              begin
                Addr_overlap_vector[ax] = 1'b1;
              end
              else
              begin
                Addr_overlap_vector[ax] = 1'b0;
              end
            end
            else
            begin
              Addr_overlap_vector[ax] = 1'b0;
            end
          end
          else
          begin
            Addr_overlap_vector[ax] = 1'b0;
          end
        end
      end : Addr_overlap_vector_gen
    end
    else
    begin
        assign Addr_overlap_vector = 'b0;
    end
  endgenerate

  logic [1:MAX_OS_TX] Same_cacheline_vector;
  generate
    if (((NODE_TYPE == RNF) || (NODE_TYPE == RNI) || (NODE_TYPE == RND) ) || ((NODE_TYPE_HAS_HNF) && (MODE ==0)) || RecommendOn_Haz)
    begin
      for (ax = 1; ax <= MAX_OS_TX; ax = ax + 1)
      begin : Same_cacheline_vector_gen
        assign Same_cacheline_vector[ax] = in_Flight_vector[ax] && Chi5_in.SRESETn && (Info_tmp.OpCode !=  `CHI5PC_EOBARRIER) && (Info_tmp.OpCode !=  `CHI5PC_ECBARRIER) && (Info_tmp.OpCode !=  `CHI5PC_DVMOP) && REQFLITV_  && (Info[ax].Addr[43:6] == Info_tmp.Addr[43:6]) && (Info[ax].NS == Info_tmp.NS) ;
      end : Same_cacheline_vector_gen
    end
    else
    begin
        assign Same_cacheline_vector = 'b0;
    end
  endgenerate
  assign IN_RREQ = |(Addr_overlap_vector & Is_Read_vector & ~Has_Comp_vector);
  assign IN_WREQ = |(Addr_overlap_vector & Is_Write_vector & ~Has_Comp_vector);
  assign IN_COPYBACK = |(Same_cacheline_vector & Is_CopyBack_vector & ~Has_Comp_vector);

  eChi5PCDevType REQ_SRCID_NodeType;
  eChi5PCDevType REQ_TGTID_NodeType;
  assign REQ_SRCID_NodeType = Chi5_in.get_NodeType(REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]);
  assign REQ_TGTID_NodeType = Chi5_in.get_NodeType( Chi5PC_SAM_pkg::SAM_remap(REQFLIT_));
  wire REQ_SRCID_NODE_TYPE_HAS_MN;
  wire REQ_SRCID_NODE_TYPE_HAS_HNF;
  wire REQ_SRCID_NODE_TYPE_HAS_HNI;
  wire REQ_TGTID_NODE_TYPE_HAS_MN;
  wire REQ_TGTID_NODE_TYPE_HAS_HNF;
  wire REQ_TGTID_NODE_TYPE_HAS_HNI;
  assign REQ_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(REQ_SRCID_NodeType);
  assign REQ_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(REQ_SRCID_NodeType);
  assign REQ_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(REQ_SRCID_NodeType);
  assign REQ_TGTID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(REQ_TGTID_NodeType);
  assign REQ_TGTID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(REQ_TGTID_NodeType);
  assign REQ_TGTID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(REQ_TGTID_NodeType);

  eChi5PCDevType S_RSP_SRCID_NodeType;
  eChi5PCDevType S_RSP_TGTID_NodeType;
  assign S_RSP_SRCID_NodeType = Chi5_in.get_NodeType(S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign S_RSP_TGTID_NodeType = Chi5_in.get_NodeType(S_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  wire S_RSP_SRCID_NODE_TYPE_HAS_MN;
  wire S_RSP_SRCID_NODE_TYPE_HAS_HNF;
  wire S_RSP_SRCID_NODE_TYPE_HAS_HNI;
  wire S_RSP_TGTID_NODE_TYPE_HAS_MN;
  wire S_RSP_TGTID_NODE_TYPE_HAS_HNF;
  wire S_RSP_TGTID_NODE_TYPE_HAS_HNI;
  assign S_RSP_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(S_RSP_SRCID_NodeType);
  assign S_RSP_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(S_RSP_SRCID_NodeType);
  assign S_RSP_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(S_RSP_SRCID_NodeType);
  assign S_RSP_TGTID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(S_RSP_TGTID_NodeType);
  assign S_RSP_TGTID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(S_RSP_TGTID_NodeType);
  assign S_RSP_TGTID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(S_RSP_TGTID_NodeType);

  eChi5PCDevType M_RSP_SRCID_NodeType;
  eChi5PCDevType M_RSP_TGTID_NodeType;
  assign M_RSP_SRCID_NodeType = Chi5_in.get_NodeType(M_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign M_RSP_TGTID_NodeType = Chi5_in.get_NodeType(M_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  wire M_RSP_SRCID_NODE_TYPE_HAS_MN;
  wire M_RSP_SRCID_NODE_TYPE_HAS_HNF;
  wire M_RSP_SRCID_NODE_TYPE_HAS_HNI;
  wire M_RSP_TGTID_NODE_TYPE_HAS_MN;
  wire M_RSP_TGTID_NODE_TYPE_HAS_HNF;
  wire M_RSP_TGTID_NODE_TYPE_HAS_HNI;
  assign M_RSP_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(M_RSP_SRCID_NodeType);
  assign M_RSP_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(M_RSP_SRCID_NodeType);
  assign M_RSP_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(M_RSP_SRCID_NodeType);
  assign M_RSP_TGTID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(M_RSP_TGTID_NodeType);
  assign M_RSP_TGTID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(M_RSP_TGTID_NodeType);
  assign M_RSP_TGTID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(M_RSP_TGTID_NodeType);

  eChi5PCDevType RDDAT_SRCID_NodeType;
  eChi5PCDevType RDDAT_TGTID_NodeType;
  assign RDDAT_SRCID_NodeType = Chi5_in.get_NodeType(RDDATFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign RDDAT_TGTID_NodeType = Chi5_in.get_NodeType(RDDATFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  wire RDDAT_SRCID_NODE_TYPE_HAS_MN;
  wire RDDAT_SRCID_NODE_TYPE_HAS_HNF;
  wire RDDAT_SRCID_NODE_TYPE_HAS_HNI;
  wire RDDAT_TGTID_NODE_TYPE_HAS_MN;
  wire RDDAT_TGTID_NODE_TYPE_HAS_HNF;
  wire RDDAT_TGTID_NODE_TYPE_HAS_HNI;
  assign RDDAT_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(RDDAT_SRCID_NodeType);
  assign RDDAT_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(RDDAT_SRCID_NodeType);
  assign RDDAT_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(RDDAT_SRCID_NodeType);
  assign RDDAT_TGTID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(RDDAT_TGTID_NodeType);
  assign RDDAT_TGTID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(RDDAT_TGTID_NodeType);
  assign RDDAT_TGTID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(RDDAT_TGTID_NodeType);

  eChi5PCDevType WRDAT_SRCID_NodeType;
  eChi5PCDevType WRDAT_TGTID_NodeType;
  assign WRDAT_SRCID_NodeType = Chi5_in.get_NodeType(WRDATFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]);
  assign WRDAT_TGTID_NodeType = Chi5_in.get_NodeType(WRDATFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]);
  wire WRDAT_SRCID_NODE_TYPE_HAS_MN;
  wire WRDAT_SRCID_NODE_TYPE_HAS_HNF;
  wire WRDAT_SRCID_NODE_TYPE_HAS_HNI;
  wire WRDAT_TGTID_NODE_TYPE_HAS_MN;
  wire WRDAT_TGTID_NODE_TYPE_HAS_HNF;
  wire WRDAT_TGTID_NODE_TYPE_HAS_HNI;
  assign WRDAT_SRCID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(WRDAT_SRCID_NodeType);
  assign WRDAT_SRCID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(WRDAT_SRCID_NodeType);
  assign WRDAT_SRCID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(WRDAT_SRCID_NodeType);
  assign WRDAT_TGTID_NODE_TYPE_HAS_MN = Chi5_in.has_MN(WRDAT_TGTID_NodeType);
  assign WRDAT_TGTID_NODE_TYPE_HAS_HNF = Chi5_in.has_HNF(WRDAT_TGTID_NodeType);
  assign WRDAT_TGTID_NODE_TYPE_HAS_HNI = Chi5_in.has_HNI(WRDAT_TGTID_NodeType);
//----------------------------------------------------------------------------
// INDEX:   4)  Retry tracking
//------------------------------------------------------------------------------ 
  assign req_tgt = Chi5_in.get_nodeIndex( Chi5PC_SAM_pkg::SAM_remap(REQFLIT_));
  assign req_src = Chi5_in.get_nodeIndex(REQFLIT_[`CHI5PC_REQ_FLIT_SRCID_RANGE]) ;
  assign retry_response = S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK;
  assign retrycrd_type = S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE];
  assign pcrdgrant_response = S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT);
  assign pcrdgrant_type = S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE];
  
  assign rddat_tgt = RDDATFLITV_ ? Chi5_in.get_nodeIndex(RDDATFLIT_[`CHI5PC_DAT_FLIT_TGTID_RANGE]) : 'b0;
  assign rddat_src = RDDATFLITV_ ? Chi5_in.get_nodeIndex(RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE]) : 'b0;
  assign rsp_src = S_RSPFLITV_ ? Chi5_in.get_nodeIndex(S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]) : 'b0;
  assign rsp_tgt = S_RSPFLITV_ ? Chi5_in.get_nodeIndex(S_RSPFLIT_[`CHI5PC_RSP_FLIT_TGTID_RANGE]) : 'b0;
  assign pcrdreturn_static = REQFLITV_ && !REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] &&  (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT);
  assign pcrdreturn_type = REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE];
  assign pcrdreturn_tgt = REQFLITV_ ? req_tgt :'b0;
  assign pcrdreturn_src = REQFLITV_ ? req_src :'b0;



  generate
  genvar ci;
  genvar cj;
    for (ci = 0; ci <= num_crdtypes -1 ; ci = ci + 1)
      for (cj = 1; cj <= numChi5nodes; cj = cj + 1)
      begin : next_PCrdGnt_PCrdRtn_cnt_gen
        assign next_PCrdGnt_PCrdRtn_cnt[cj][ci] = Chi5_in.SRESETn ?
          (MODE == 1 ? PCrdGnt_PCrdRtn_cnt[cj][ci] + (pcrdgrant_response && (pcrdgrant_type == ci) && (rsp_src == cj)) - (pcrdreturn_static && (pcrdreturn_type == ci) && (pcrdreturn_tgt == cj)):
                        PCrdGnt_PCrdRtn_cnt[cj][ci] + (pcrdgrant_response && (pcrdgrant_type == ci) && (rsp_tgt == cj)) - (pcrdreturn_static && (pcrdreturn_type == ci) && (pcrdreturn_src == cj)))
                        :'b0;
      end : next_PCrdGnt_PCrdRtn_cnt_gen
  endgenerate

  
  generate
  genvar bi;
  genvar bj;
    for (bi = 0; bi <= num_crdtypes -1 ; bi = bi + 1)
      for (bj = 1; bj <= numChi5nodes; bj = bj + 1)
      begin : next_Retry_CrdRtn_cnt_gen
        assign next_Retry_CrdRtn_cnt[bj][bi] = Chi5_in.SRESETn ? 
          (MODE == 1 ? Retry_CrdRtn_cnt[bj][bi] + (retry_response && (retrycrd_type == bi) && (rsp_src == bj)) - (pcrdreturn_static && (pcrdreturn_type == bi) && (pcrdreturn_tgt == bj)):
                       Retry_CrdRtn_cnt[bj][bi] + (retry_response && (retrycrd_type == bi) && (rsp_tgt == bj)) - (pcrdreturn_static && (pcrdreturn_type == bi) && (pcrdreturn_src == bj)))
                       : 10'b1000000000;
      end : next_Retry_CrdRtn_cnt_gen
  endgenerate


  generate
  genvar ei;
  genvar ej;
    for (ei = 0; ei <= num_crdtypes -1 ; ei = ei + 1)
      for (ej = 1; ej <= numChi5nodes; ej = ej + 1)
      begin : next_Retry_CrdGnt_cnt_gen
        assign next_Retry_CrdGnt_cnt[ej][ei] = Chi5_in.SRESETn ?
          (MODE == 1 ? Retry_CrdGnt_cnt[ej][ei] - (retry_response && (retrycrd_type == ei) && (rsp_src == ej)) + (pcrdgrant_response && (pcrdgrant_type == ei) && (rsp_src == ej)):
                       Retry_CrdGnt_cnt[ej][ei] - (retry_response && (retrycrd_type == ei) && (rsp_tgt == ej)) + (pcrdgrant_response && (pcrdgrant_type == ei) && (rsp_tgt == ej)))
                       : 9'b100000000;
      end : next_Retry_CrdGnt_cnt_gen
  endgenerate

  assign next_PCrd_OS = Chi5_in.SRESETn ? PCrd_OS - pcrdreturn_static + pcrdgrant_response : 'b0;
  always @(negedge Chi5_in.SRESETn or posedge SCLK)
  begin
    if(!Chi5_in.SRESETn)
    begin
      PCrd_OS <= 'b0;
      for (int i = 0; i < num_crdtypes; i = i + 1)
        for (int j = 1; j <= numChi5nodes ; j = j + 1)
        begin
          PCrdGnt_PCrdRtn_cnt[j][i] <= 'b0;
          Retry_CrdRtn_cnt[j][i] <= 10'b1000000000;
          Retry_CrdGnt_cnt[j][i] <= 9'b100000000;
        end
    end 
    else
    begin
      Retry_CrdRtn_cnt <= next_Retry_CrdRtn_cnt;
      Retry_CrdGnt_cnt <= next_Retry_CrdGnt_cnt;
      PCrdGnt_PCrdRtn_cnt <= next_PCrdGnt_PCrdRtn_cnt;
      PCrd_OS <= next_PCrd_OS;
    end
  end
//----------------------------------------------------------------------------
// INDEX:   5)  REQ channel Checks
//------------------------------------------------------------------------------ 
//
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_X
  // =====
  property CHI5PC_ERR_REQ_X;
    @(posedge `CHI5_SVA_CLK) 
      `CHI5_SVA_RSTn &&  REQFLITV_
      |-> ! $isunknown(REQFLIT_);
  endproperty
  chi5pc_err_req_x:  assert property (CHI5PC_ERR_REQ_X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_X::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A value of X is not allowed on REQFLIT when REQFLITV is high."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TXNID_UNQ
  // =====
  // The Src/Tgt and TxnID of the transaction is already in use
  property CHI5PC_ERR_REQ_TXNID_UNQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> ~|ID_CLASH_vector;
  endproperty
  chi5pc_err_req_txnid_unq: assert property (CHI5PC_ERR_REQ_TXNID_UNQ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_TXNID_UNQ::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A request message cannot use a TxnID value that is already in use by another transaction (the previous transaction must complete before the TxnID is available for re-use)."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXCL_OPCODE
  // =====
  // Exclusive requests must be RC, RS,RNS,CU, WNS
  property CHI5PC_ERR_REQ_EXCL_OPCODE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]
       && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] 
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN || 
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL ;
  endproperty
  chi5pc_err_req_excl_opcode: assert property (CHI5PC_ERR_REQ_EXCL_OPCODE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXCL_OPCODE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The following transactions are the only ones that support the exclusive attribute: ReadClean, ReadShared, CleanUnique, ReadNoSnp, WriteNoSnpPtl and WriteNoSnpFull."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_OPCODE
  // =====
//Reserved opcode values
  property CHI5PC_ERR_REQ_RSVD_OPCODE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
      |-> (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h06 &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h10 &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h11 &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h12 &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h13 &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h1E &&
            REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != 5'h1F ) ;
  endproperty
  chi5pc_err_req_rsvd_opcode: assert property (CHI5PC_ERR_REQ_RSVD_OPCODE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_OPCODE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flit opcode values 5'h06, 5'h10, 5'h11, 5'h12, 5'h13, 5'h1E and 5'h1F are reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_SIZE
  // =====
//Reserved size values
  property CHI5PC_ERR_REQ_RSVD_SIZE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> !(REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == 3'b111);
  endproperty
  chi5pc_err_req_rsvd_size: assert property (CHI5PC_ERR_REQ_RSVD_SIZE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_SIZE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flit Size value 3'b111 is reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_SNPATTR
  // =====
//Reserved SNPATTR values
  property CHI5PC_ERR_REQ_RSVD_SNPATTR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> !(REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == 2'b10);
  endproperty
  chi5pc_err_req_rsvd_snpattr: assert property (CHI5PC_ERR_REQ_RSVD_SNPATTR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_SNPATTR::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flit SnpAttr value 2'b10 is reserved."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_LINKFLIT
  // =====
//Required control fields
  property CHI5PC_ERR_REQ_CTL_LINKFLIT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_REQLINKFLIT
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_linkflit: assert property (CHI5PC_ERR_REQ_CTL_LINKFLIT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_LINKFLIT::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReqLinkFlit must have TxnID = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_ORDER_SN
  // =====
  property CHI5PC_ERR_REQ_CTL_ORDER_SN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT
       && (REQ_TGTID_NodeType == SNF)
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_order_sn: assert property (CHI5PC_ERR_REQ_CTL_ORDER_SN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_ORDER_SN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits to Node type SNF must not have order specified."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_RNS
  // =====
  property CHI5PC_ERR_REQ_OPCD_RNS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNF  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNF)) 
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_rns: assert property (CHI5PC_ERR_REQ_OPCD_RNS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_RNS: The permitted communicating node pairs for a ReadNoSnp request message are: RNF, RNI, RND to ICN(HNF, HNI); ICN(HNF) to SNF; ICN(HNI) to SNI." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WNSF
  // =====
  property CHI5PC_ERR_REQ_OPCD_WNSF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNF  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNF)) 
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wnsf: assert property (CHI5PC_ERR_REQ_OPCD_WNSF) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WNSF: The permitted communicating node pairs for a WriteNoSnpFull request message are: RNF, RNI, RND to ICN(HNF, HNI); ICN(HNF) to SNF; ICN(HNI) to SNI." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WNSP
  // =====
  property CHI5PC_ERR_REQ_OPCD_WNSP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNF  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNF)) 
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wnsp: assert property (CHI5PC_ERR_REQ_OPCD_WNSP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WNSP: The permitted communicating node pairs for a WriteNoSnpPtl request message are: RNF, RNI, RND to ICN(HNF, HNI); ICN(HNF) to SNF; ICN(HNI) to SNI." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_RC
  // =====
  property CHI5PC_ERR_REQ_OPCD_RC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_rc: assert property (CHI5PC_ERR_REQ_OPCD_RC) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_RC: The permitted communicating node pairs for a ReadClean request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_RS
  // =====
  property CHI5PC_ERR_REQ_OPCD_RS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_rs: assert property (CHI5PC_ERR_REQ_OPCD_RS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_RS: The permitted communicating node pairs for a ReadShared request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_RU
  // =====
  property CHI5PC_ERR_REQ_OPCD_RU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_ru: assert property (CHI5PC_ERR_REQ_OPCD_RU) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_RU: The permitted communicating node pairs for a ReadUnique request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_CU
  // =====
  property CHI5PC_ERR_REQ_OPCD_CU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_cu: assert property (CHI5PC_ERR_REQ_OPCD_CU) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_CU: The permitted communicating node pairs for a CleanUnique request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_MU
  // =====
  property CHI5PC_ERR_REQ_OPCD_MU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_mu: assert property (CHI5PC_ERR_REQ_OPCD_MU) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_MU: The permitted communicating node pairs for a MakeUnique request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_E
  // =====
  property CHI5PC_ERR_REQ_OPCD_E; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EVICT
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_e: assert property (CHI5PC_ERR_REQ_OPCD_E) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_E: The permitted communicating node pairs for a Evict request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WBF
  // =====
  property CHI5PC_ERR_REQ_OPCD_WBF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wbf: assert property (CHI5PC_ERR_REQ_OPCD_WBF) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WBF: The permitted communicating node pairs for a WriteBackFull request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WBP
  // =====
  property CHI5PC_ERR_REQ_OPCD_WBP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKPTL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wbp: assert property (CHI5PC_ERR_REQ_OPCD_WBP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WBP: The permitted communicating node pairs for a WriteBackPtl request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WEF
  // =====
  property CHI5PC_ERR_REQ_OPCD_WEF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEEVICTFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wef: assert property (CHI5PC_ERR_REQ_OPCD_WEF) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WEF: The permitted communicating node pairs for a WriteEvictFull request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WCF
  // =====
  property CHI5PC_ERR_REQ_OPCD_WCF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wcf: assert property (CHI5PC_ERR_REQ_OPCD_WCF) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WCF: The permitted communicating node pairs for a WriteCleanFull request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WCP
  // =====
  property CHI5PC_ERR_REQ_OPCD_WCP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANPTL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI )
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wcp: assert property (CHI5PC_ERR_REQ_OPCD_WCP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WCP: The permitted communicating node pairs for a WriteCleanPtl request message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_RO
  // =====
  property CHI5PC_ERR_REQ_OPCD_RO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READONCE
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_ro: assert property (CHI5PC_ERR_REQ_OPCD_RO) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_RO: The permitted communicating node pairs for a ReadOnce request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_CS
  // =====
  property CHI5PC_ERR_REQ_OPCD_CS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANSHARED
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_cs: assert property (CHI5PC_ERR_REQ_OPCD_CS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_CS: The permitted communicating node pairs for a CleanShared request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_CI
  // =====
  property CHI5PC_ERR_REQ_OPCD_CI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANINVALID
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_ci: assert property (CHI5PC_ERR_REQ_OPCD_CI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_CI: The permitted communicating node pairs for a CleanInvalid request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_MI
  // =====
  property CHI5PC_ERR_REQ_OPCD_MI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEINVALID
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_mi: assert property (CHI5PC_ERR_REQ_OPCD_MI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_MI: The permitted communicating node pairs for a MakeInvalid request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WUF
  // =====
  property CHI5PC_ERR_REQ_OPCD_WUF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wuf: assert property (CHI5PC_ERR_REQ_OPCD_WUF) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WUF: The permitted communicating node pairs for a WriteUniqueFull request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_WUP
  // =====
  property CHI5PC_ERR_REQ_OPCD_WUP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_req_opcd_wup: assert property (CHI5PC_ERR_REQ_OPCD_WUP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_WUP: The permitted communicating node pairs for a WriteUniquePtl request message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_EOB
  // =====
  property CHI5PC_ERR_REQ_OPCD_EOB; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_MN
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_eob: assert property (CHI5PC_ERR_REQ_OPCD_EOB) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_EOB: The permitted communicating node pairs for a EOBarrier request message are: RNF, RNI, RND to ICN(MN); ICN(HNI) to SNI." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_ECB
  // =====
  property CHI5PC_ERR_REQ_OPCD_ECB; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_MN
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_ecb: assert property (CHI5PC_ERR_REQ_OPCD_ECB) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_ECB: The permitted communicating node pairs for a ECBarrier request message are: RNF, RNI, RND to ICN(MN); ICN(HNI) to SNI." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_DVM
  // =====
  property CHI5PC_ERR_REQ_OPCD_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_MN
          )
            ;
  endproperty
  chi5pc_err_req_opcd_dvm: assert property (CHI5PC_ERR_REQ_OPCD_DVM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_DVM: The permitted communicating node pairs for a DVMOp request message are: RNF, RND to ICN(MN)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OPCD_PCR
  // =====
  property CHI5PC_ERR_REQ_OPCD_PCR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDRETURN
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (REQ_TGTID_NODE_TYPE_HAS_HNF ||
             REQ_TGTID_NODE_TYPE_HAS_HNI ||
             REQ_TGTID_NODE_TYPE_HAS_MN)
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNF  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNF)) 
          )
          ||
          (
            REQ_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_req_opcd_pcr: assert property (CHI5PC_ERR_REQ_OPCD_PCR) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_OPCD_PCR: The permitted communicating node pairs for a PCrdReturn request message are: RNF, RNI, RND to ICN(HNF, HNI, MN); ICN(HNF) to SNF; ICN(HNI) to SNI." ));
  

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_RC
  // =====
  property CHI5PC_REC_REQ_OPCD_RC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF 
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_rc: assert property (CHI5PC_REC_REQ_OPCD_RC) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_RC: The expected communicating node pairs for a ReadClean request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_RS
  // =====
  property CHI5PC_REC_REQ_OPCD_RS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_rs: assert property (CHI5PC_REC_REQ_OPCD_RS) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_RS: The expected communicating node pairs for a ReadShared request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_RU
  // =====
  property CHI5PC_REC_REQ_OPCD_RU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_ru: assert property (CHI5PC_REC_REQ_OPCD_RU) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_RU: The expected communicating node pairs for a ReadUnique request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_CU
  // =====
  property CHI5PC_REC_REQ_OPCD_CU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_cu: assert property (CHI5PC_REC_REQ_OPCD_CU) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_CU: The expected communicating node pairs for a CleanUnique request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_MU
  // =====
  property CHI5PC_REC_REQ_OPCD_MU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEUNIQUE
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_mu: assert property (CHI5PC_REC_REQ_OPCD_MU) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_MU: The expected communicating node pairs for a MakeUnique request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_E
  // =====
  property CHI5PC_REC_REQ_OPCD_E; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EVICT
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF 
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_e: assert property (CHI5PC_REC_REQ_OPCD_E) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_E: The expected communicating node pairs for a Evict request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WBF
  // =====
  property CHI5PC_REC_REQ_OPCD_WBF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wbf: assert property (CHI5PC_REC_REQ_OPCD_WBF) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WBF: The expected communicating node pairs for a WriteBackFull request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WBP
  // =====
  property CHI5PC_REC_REQ_OPCD_WBP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKPTL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wbp: assert property (CHI5PC_REC_REQ_OPCD_WBP) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WBP: The expected communicating node pairs for a WriteBackPtl request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WEF
  // =====
  property CHI5PC_REC_REQ_OPCD_WEF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEEVICTFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wef: assert property (CHI5PC_REC_REQ_OPCD_WEF) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WEF: The expected communicating node pairs for a WriteEvictFull request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WCF
  // =====
  property CHI5PC_REC_REQ_OPCD_WCF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANFULL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wcf: assert property (CHI5PC_REC_REQ_OPCD_WCF) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WCF: The expected communicating node pairs for a WriteCleanFull request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WCP
  // =====
  property CHI5PC_REC_REQ_OPCD_WCP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANPTL
      |-> (
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wcp: assert property (CHI5PC_REC_REQ_OPCD_WCP) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WCP: The expected communicating node pairs for a WriteCleanPtl request message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_RO
  // =====
  property CHI5PC_REC_REQ_OPCD_RO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READONCE
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_ro: assert property (CHI5PC_REC_REQ_OPCD_RO) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_RO: The expected communicating node pairs for a ReadOnce request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_CS
  // =====
  property CHI5PC_REC_REQ_OPCD_CS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANSHARED
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF 
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_cs: assert property (CHI5PC_REC_REQ_OPCD_CS) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_CS: The expected communicating node pairs for a CleanShared request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_CI
  // =====
  property CHI5PC_REC_REQ_OPCD_CI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANINVALID
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_ci: assert property (CHI5PC_REC_REQ_OPCD_CI) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_CI: The expected communicating node pairs for a CleanInvalid request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_MI
  // =====
  property CHI5PC_REC_REQ_OPCD_MI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEINVALID
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            REQ_TGTID_NODE_TYPE_HAS_HNF 
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_mi: assert property (CHI5PC_REC_REQ_OPCD_MI) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_MI: The expected communicating node pairs for a MakeInvalid request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WUF
  // =====
  property CHI5PC_REC_REQ_OPCD_WUF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
             REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wuf: assert property (CHI5PC_REC_REQ_OPCD_WUF) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WUF: The expected communicating node pairs for a WriteUniqueFull request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_REC_REQ_OPCD_WUP
  // =====
  property CHI5PC_REC_REQ_OPCD_WUP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL
      |-> (
            ((REQ_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (REQ_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
             REQ_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_req_opcd_wup: assert property (CHI5PC_REC_REQ_OPCD_WUP) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_OPCD_WUP: The expected communicating node pairs for a WriteUniquePtl request message are: RNF, RNI, RND to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_READSHARED
  // =====
  property CHI5PC_ERR_REQ_CTL_READSHARED; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b1;
  endproperty
  chi5pc_err_req_ctl_readshared: assert property (CHI5PC_ERR_REQ_CTL_READSHARED) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_READSHARED::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReadShared must have Size = 64B, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and ExpCompAck = 'b1."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_READCLEAN
  // =====
  property CHI5PC_ERR_REQ_CTL_READCLEAN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b1;
  endproperty
  chi5pc_err_req_ctl_readclean: assert property (CHI5PC_ERR_REQ_CTL_READCLEAN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_READCLEAN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReadClean must have Size = 64B, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and ExpCompAck = 'b1."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_READONCE
  // =====
  property CHI5PC_ERR_REQ_CTL_READONCE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READONCE
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_req_ctl_readonce: assert property (CHI5PC_ERR_REQ_CTL_READONCE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_READONCE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReadOnce must have Size = 64B, LikelyShared = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and Excl = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_READNOSNP
  // =====
  property CHI5PC_ERR_REQ_CTL_READNOSNP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP 
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_req_ctl_readnosnp: assert property (CHI5PC_ERR_REQ_CTL_READNOSNP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_READNOSNP::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReadNoSnp must have LikelyShared = 'b0, SnoopAttr[SnoopDomain,Snoopable] = 'b00."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_READUNIQUE
  // =====
  property CHI5PC_ERR_REQ_CTL_READUNIQUE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READUNIQUE 
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b1;
  endproperty
  chi5pc_err_req_ctl_readunique: assert property (CHI5PC_ERR_REQ_CTL_READUNIQUE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_READUNIQUE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ReadUnique must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b1."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_CLEANSHARED
  // =====
  property CHI5PC_ERR_REQ_CTL_CLEANSHARED; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANSHARED 
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_req_ctl_cleanshared: assert property (CHI5PC_ERR_REQ_CTL_CLEANSHARED) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_CLEANSHARED::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode CleanShared must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Device,EWA] = 'b01 and Excl = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_CLEANINVALID
  // =====
  property CHI5PC_ERR_REQ_CTL_CLEANINVALID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANINVALID  
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_req_ctl_cleaninvalid: assert property (CHI5PC_ERR_REQ_CTL_CLEANINVALID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_CLEANINVALID::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode CleanInvalid must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Device,EWA] = 'b01 and Excl = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_MAKEINVALID
  // =====
  property CHI5PC_ERR_REQ_CTL_MAKEINVALID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEINVALID   
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_req_ctl_makeinvalid: assert property (CHI5PC_ERR_REQ_CTL_MAKEINVALID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_MAKEINVALID::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode MakeInvalid must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Device,EWA] = 'b01 and Excl = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_CLEANUNIQUE
  // =====
  property CHI5PC_ERR_REQ_CTL_CLEANUNIQUE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE   
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          memattr_cacheable == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b1;
  endproperty
  chi5pc_err_req_ctl_cleanunique: assert property (CHI5PC_ERR_REQ_CTL_CLEANUNIQUE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_CLEANUNIQUE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode CleanUnique must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and ExpCompAck = 'b1."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_MAKEUNIQUE
  // =====
  property CHI5PC_ERR_REQ_CTL_MAKEUNIQUE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_MAKEUNIQUE   
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          memattr_cacheable == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b1;
  endproperty
  chi5pc_err_req_ctl_makeunique: assert property (CHI5PC_ERR_REQ_CTL_MAKEUNIQUE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_MAKEUNIQUE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode MakeUnique must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b1."});



  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_EOBARRIER
  // =====
  property CHI5PC_ERR_REQ_CTL_EOBARRIER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER    
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          mem_attr== 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_eobarrier: assert property (CHI5PC_ERR_REQ_CTL_EOBARRIER) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_EOBARRIER::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode EOBarrier must have Size = 'b0, Addr = 'b0, NS = 'b0, LikelyShared = 'b0, Order = 'b0, MemAttr = 'b0, SnoopAttr = 'b0, Excl = 'b0 and ExpCompAck = 'b0."});



  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_ECBARRIER
  // =====
  property CHI5PC_ERR_REQ_CTL_ECBARRIER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER    
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          mem_attr== 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_ecbarrier: assert property (CHI5PC_ERR_REQ_CTL_ECBARRIER) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_ECBARRIER::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode ECBarrier must have Size = 'b0, Addr = 'b0, NS = 'b0, LikelyShared = 'b0, Order = 'b0, MemAttr = 'b0, SnoopAttr = 'b0, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_PCRDRETURN
  // =====
  property CHI5PC_ERR_REQ_CTL_PCRDRETURN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDRETURN     
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_TXNID_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ADDR_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          mem_attr == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_pcrdreturn: assert property (CHI5PC_ERR_REQ_CTL_PCRDRETURN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_PCRDRETURN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode PCrdReturn must have TxnID = 'b0, Size = 'b0, Addr = 'b0, NS = 'b0, LikelyShared = 'b0, DynPCrd = 0, Order = 'b0, MemAttr = 'b0, SnoopAttr = 'b0, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_EVICT
  // =====
  property CHI5PC_ERR_REQ_CTL_EVICT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EVICT     
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_allocate == 1'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_evict: assert property (CHI5PC_ERR_REQ_CTL_EVICT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_EVICT::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode Evict must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr = 4'b0101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITEEVICTFULL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITEEVICTFULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEEVICTFULL     
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writeevictfull: assert property (CHI5PC_ERR_REQ_CTL_WRITEEVICTFULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITEEVICTFULL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteEvictFull must have Size = 64B, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITECLEANPTL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITECLEANPTL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANPTL      
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writecleanptl: assert property (CHI5PC_ERR_REQ_CTL_WRITECLEANPTL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITECLEANPTL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteCleanPtl must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITECLEANFULL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITECLEANFULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANFULL      
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writecleanfull: assert property (CHI5PC_ERR_REQ_CTL_WRITECLEANFULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITECLEANFULL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteCleanFull must have Size = 64B, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITEBACKPTL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITEBACKPTL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKPTL
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writebackptl: assert property (CHI5PC_ERR_REQ_CTL_WRITEBACKPTL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITEBACKPTL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteBackPtl must have Size = 64B, LikelyShared = 'b0, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITEBACKFULL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITEBACKFULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKFULL
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0 &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writebackfull: assert property (CHI5PC_ERR_REQ_CTL_WRITEBACKFULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITEBACKFULL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteBackFull must have Size = 64B, Order = 'b0, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1, Excl = 'b0 and ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITEUNIQUEPTL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITEUNIQUEPTL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && ( REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL)
      |-> memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writeuniqueptl: assert property (CHI5PC_ERR_REQ_CTL_WRITEUNIQUEPTL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITEUNIQUEPTL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteUniquePtl must have MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and Excl = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITEUNIQUEFULL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITEUNIQUEFULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B &&
          memattr_cacheable == 1'b1 &&
          memattr_device == 1'b0 &&
          memattr_ewa == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b1 &&
          REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] == 'b0;
  endproperty
  chi5pc_err_req_ctl_writeuniquefull: assert property (CHI5PC_ERR_REQ_CTL_WRITEUNIQUEFULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITEUNIQUEFULL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteUniqueFull must have Size = 64B, MemAttr[Cacheable,Device,EWA] = 'b101, SnoopAttr[Snoopable] = 'b1 and Excl = 'b0."});
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITENOSNPPTL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITENOSNPPTL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL)
      |-> (REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0);
  endproperty
  chi5pc_err_req_ctl_writenosnpptl: assert property (CHI5PC_ERR_REQ_CTL_WRITENOSNPPTL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITENOSNPPTL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteNoSnpPtl must have LikelyShared = 'b0, SnoopAttr[SnoopDomain,Snoopable] = 'b00 and ExpCompAck = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_WRITENOSNPFULL
  // =====
  property CHI5PC_ERR_REQ_CTL_WRITENOSNPFULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL)
      |-> (REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE64B) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNPDOMAIN_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 'b0);
  endproperty
  chi5pc_err_req_ctl_writenosnpfull: assert property (CHI5PC_ERR_REQ_CTL_WRITENOSNPFULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_WRITENOSNPFULL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode WriteNoSnpFull must have Size = 64B, LikelyShared = 'b0, SnoopAttr[SnoopDomain,Snoopable] = 'b00 and ExpCompAck = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_WRITENOSNPFULL_DEV
  // =====
  property CHI5PC_ERR_REQ_WRITENOSNPFULL_DEV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL) && 
          memattr_device == 1'b1 
      |-> Info_tmp.Addr[5:0] == 'b0;
  endproperty
  chi5pc_err_req_writenosnpfull_dev: assert property (CHI5PC_ERR_REQ_WRITENOSNPFULL_DEV) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_WRITENOSNPFULL_DEV::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Requests of type WriteNoSnpFull to device memory-type must have an address aligned to the cache-line size."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXPCOMPACK_SN
  // =====
  property CHI5PC_ERR_REQ_EXPCOMPACK_SN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]
       &&  ((REQ_TGTID_NodeType == eChi5PCDevType'(SNI)) || (REQ_TGTID_NodeType == eChi5PCDevType'(SNF)))
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b0; 
  endproperty
  chi5pc_err_req_expcompack_sn: assert property (CHI5PC_ERR_REQ_EXPCOMPACK_SN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXPCOMPACK_SN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits to an SNI or SNF node must have ExpCompAck = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXCL_SNOOPABLE
  // =====
  property CHI5PC_ERR_REQ_EXCL_SNOOPABLE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] 
       && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]
       && REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE]
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED ||
          REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE;
  endproperty
  chi5pc_err_req_excl_snoopable: assert property (CHI5PC_ERR_REQ_EXCL_SNOOPABLE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXCL_SNOOPABLE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Snoopable exclusive accesses must be issued as ReadClean, ReadShared or CleanUnique."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_ATTR_DEV
  // =====
  property CHI5PC_ERR_REQ_ATTR_DEV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && memattr_device 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> memattr_allocate == 1'b0 
          && ~|REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE]
          && !REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE]
          && (&REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] ||
             ((memattr_ewa && NO_ORDER) ||
              (memattr_ewa && REQ_ORDER && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READONCE) ||
                                            (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL) ||
                                            (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL) ||
                                            (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP) ||
                                            (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL) ||
                                            (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL)))));
  endproperty
  chi5pc_err_req_attr_dev: assert property (CHI5PC_ERR_REQ_ATTR_DEV) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_ATTR_DEV::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Illegal combination of MemAttr, SnpAttr, LikelyShared and Order for a Device memory type request."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_ATTR_NORMAL
  // =====
  property CHI5PC_ERR_REQ_ATTR_NORMAL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && !memattr_device 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       |->(NO_ORDER ||
            (REQ_ORDER && 
              ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READONCE) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL) ||
               (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL)))
             ) && 
             ( ( 
                 !memattr_allocate // Non-cacheable Non-bufferable
                  && !memattr_cacheable
                  && !memattr_ewa
                  && ~|REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE]
                  && !REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE]
                )
                ||
                (
                  !memattr_allocate // Non-cacheable bufferable
                  && !memattr_cacheable
                  && memattr_ewa
                  && ~|REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE]
                  && !REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE]
                )
                ||
                (
                  !memattr_allocate // Non-snoopable WriteBack No-Allocate
                  && memattr_cacheable
                  && memattr_ewa
                  && ~|REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE]
                  && !REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE]
                )
                ||
                ( memattr_allocate // Non-snoopable WriteBack Allocate
                  && memattr_cacheable
                  && memattr_ewa
                  && ~|REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE]
                  && !REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE]
                )
                ||
                ( (!REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] ||
                     ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEPTL) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEUNIQUEFULL) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEBACKFULL) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITECLEANFULL) ||
                     (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITEEVICTFULL))
                    ) &&
                    ( (
                        (!memattr_allocate) // Inner-snoopable WriteBack No-Allocate
                          && memattr_cacheable
                          && memattr_ewa
                          && (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == 2'b01)
                      )
                      ||
                      (
                        (memattr_allocate) // Inner-snoopable WriteBack Allocate
                        && memattr_cacheable
                        && memattr_ewa
                        && (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == 2'b01)
                      )
                      ||
                      (
                        (!memattr_allocate) // Outer-snoopable WriteBack No-Allocate
                        && memattr_cacheable
                        && memattr_ewa
                        && (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == 2'b11)
                      )
                      ||
                      (
                        (memattr_allocate) // Outer-snoopable WriteBack Allocate
                        && memattr_cacheable
                        && memattr_ewa
                        && (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_RANGE] == 2'b11)
                      )
                    )
                  )
                ) ;
  endproperty
  chi5pc_err_req_attr_normal: assert property (CHI5PC_ERR_REQ_ATTR_NORMAL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_ATTR_NORMAL::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Illegal combination of MemAttr, SnpAttr, LikelyShared and Order for a Non-Device memory type request."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_MEMATTR_X11X
  // =====
  property CHI5PC_ERR_REQ_MEMATTR_X11X; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && memattr_device
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> memattr_cacheable == 1'b0 ;
  endproperty
  chi5pc_err_req_memattr_x11x: assert property (CHI5PC_ERR_REQ_MEMATTR_X11X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_MEMATTR_X11X::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "MemAttr[Cacheable] must not be set for MemAttr[Device]=Device transactions."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_MEMATTR_X100
  // =====
  property CHI5PC_ERR_REQ_MEMATTR_X100; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (memattr_device == 1'b0)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> ~(memattr_cacheable == 1'b1 &&  memattr_ewa == 1'b0);
  endproperty
  chi5pc_err_req_memattr_x100: assert property (CHI5PC_ERR_REQ_MEMATTR_X100) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_MEMATTR_X100::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "MemAttr[Cacheable]=1'b1 and MemAttr[EWA]=1'b0 is not legal for for MemAttr[Device]=Normal transactions."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_MEMATTR_100X
  // =====
  property CHI5PC_ERR_REQ_MEMATTR_100X; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (memattr_device == 1'b0)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> ~(memattr_cacheable == 1'b0 &&  memattr_allocate == 1'b1);
  endproperty
  chi5pc_err_req_memattr_100x: assert property (CHI5PC_ERR_REQ_MEMATTR_100X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_MEMATTR_100X::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "MemAttr[Allocate]=1'b1 and MemAttr[Cacheable]=1'b0 is illegal when MemAttr[Device] = Normal."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_MEMATTR_0010_EO_0
  // =====
  property CHI5PC_ERR_REQ_MEMATTR_0010_EO_0; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE] == 4'b0010)
      |-> &Info_tmp.Order;
  endproperty
  chi5pc_err_req_memattr_0010_eo_0: assert property (CHI5PC_ERR_REQ_MEMATTR_0010_EO_0) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_MEMATTR_0010_EO_0::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "MemAttr='b0010 and no endpoint ordering is illegal."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_MEMATTR_NORMAL_EO
  // =====
  property CHI5PC_ERR_REQ_MEMATTR_NORMAL_EO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       &&  (memattr_device == 1'b0)
      |-> ~&Info_tmp.Order;
  endproperty
  chi5pc_err_req_memattr_normal_eo: assert property (CHI5PC_ERR_REQ_MEMATTR_NORMAL_EO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_MEMATTR_NORMAL_EO::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The combination of Normal memory type and EO asserted is not legal."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_TRXN_IN_CMO
  // =====
  property CHI5PC_ERR_REQ_TRXN_IN_CMO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_  && Info_tmp.MemAttr[`CHI5PC_MEMATTR_CACHEABLE_RANGE] && Info_tmp.SnpAttr[`CHI5PC_SNPATTR_SNOOPABLE_RANGE]
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       |-> ~|(Same_cacheline_vector & Is_CMO_vector & ~Has_Comp_vector);

  endproperty
  chi5pc_err_req_trxn_in_cmo: assert property (CHI5PC_ERR_REQ_TRXN_IN_CMO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_TRXN_IN_CMO::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A snoopable, cacheable transaction to the same address as a previously sent CMO can be sent to the interconnect only after completion of the CMO."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CMO_IN_TRXN
  // =====
  property CHI5PC_ERR_REQ_CMO_IN_TRXN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_ && `IS_CMO_(Info_tmp)
       |-> ~|(Same_cacheline_vector &  ~Has_Comp_vector & ~Is_DVMOp_vector & Is_snpattrX1_vector & Is_Cacheable_vector);

  endproperty
  chi5pc_err_req_cmo_in_trxn: assert property (CHI5PC_ERR_REQ_CMO_IN_TRXN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CMO_IN_TRXN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A CMO to a particular address can be sent to the interconnect only after completion of all previously sent snoopable, cacheable transactions to that address."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_IN_COPYBACK
  // =====
  property CHI5PC_ERR_REQ_IN_COPYBACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_ 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_EOBARRIER)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_ECBARRIER)
       && !(`IS_DVMOP_(Info_tmp))
       |-> ~(IN_COPYBACK);

  endproperty
  chi5pc_err_req_in_copyback: assert property (CHI5PC_ERR_REQ_IN_COPYBACK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_IN_COPYBACK::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "An RN-F must wait for the CompDBIDResp response to be received for an outstanding CopyBack transaction before issuing another request to the same cache line."});

  // =====
  // INDEX:        - CHI5PC_REC_REQ_HAZARD_R_W
  // =====
  property CHI5PC_REC_REQ_HAZARD_R_W; 
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn_Haz)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_ && `IS_READ_(Info_tmp)
       |-> ~(IN_WREQ);

  endproperty
  chi5pc_rec_req_hazard_r_w: assert property (CHI5PC_REC_REQ_HAZARD_R_W) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_HAZARD_R_W::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that a node should not issue a read transaction to a memory region it is writing to."});

  // =====
  // INDEX:        - CHI5PC_REC_REQ_HAZARD_W_R
  // =====
  property CHI5PC_REC_REQ_HAZARD_W_R; 
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn_Haz)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_ && `IS_WRITE_(Info_tmp)
       |-> ~(IN_RREQ);

  endproperty
  chi5pc_rec_req_hazard_w_r: assert property (CHI5PC_REC_REQ_HAZARD_W_R) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_HAZARD_W_R::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that a node should not issue a write transaction to a memory region it is reading from."});

  // =====
  // INDEX:        - CHI5PC_REC_REQ_HAZARD_W_W
  // =====
  property CHI5PC_REC_REQ_HAZARD_W_W; 
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn_Haz)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
        &&  REQFLITV_ && `IS_WRITE_(Info_tmp)
       |-> ~(IN_WREQ);

  endproperty
  chi5pc_rec_req_hazard_w_w: assert property (CHI5PC_REC_REQ_HAZARD_W_W) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_HAZARD_W_W::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that a node should not issue a write transaction to a memory region it is writing to."});


  // =====
  // INDEX:        - CHI5PC_INFO_REQ_PCRDRETURN
  // =====
  property CHI5PC_INFO_REQ_PCRDRETURN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && !PCRDRETURN
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN;
  endproperty
  chi5pc_info_req_pcrdreturn: assert property (CHI5PC_INFO_REQ_PCRDRETURN) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_INFO_REQ_PCRDRETURN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "PCrdReturn request opcode detected. The protocol checker does not support PCrdReturn and behaviour is unpredictable from this point forward."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RETRY
  // =====
  property CHI5PC_ERR_REQ_RETRY; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && !REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT) 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN) 
       && !PCRDRETURN
      |-> Retry_match;
  endproperty
  chi5pc_err_req_retry: assert property (CHI5PC_ERR_REQ_RETRY) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RETRY::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The payload of a retried request issued with pre-allocated credit must match a transaction that previously received a retry."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_PCRDTYPE_GRANTED
  // =====
  logic [9:0] PCrdGnt_PCrdRtn_cnt_tgt_type;
  logic [9:0] PCrdGnt_PCrdRtn_cnt_src_type;
  assign PCrdGnt_PCrdRtn_cnt_tgt_type = PCrdGnt_PCrdRtn_cnt[req_tgt][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]];
  assign PCrdGnt_PCrdRtn_cnt_src_type = PCrdGnt_PCrdRtn_cnt[req_src][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]];
  property CHI5PC_ERR_REQ_PCRDTYPE_GRANTED; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && !REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT) 
      |-> MODE == 1 ? |PCrdGnt_PCrdRtn_cnt_tgt_type : 
                      |PCrdGnt_PCrdRtn_cnt_src_type;
  endproperty
  chi5pc_err_req_pcrdtype_granted: assert property (CHI5PC_ERR_REQ_PCRDTYPE_GRANTED) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_PCRDTYPE_GRANTED::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A request issued with pre-allocated credit must use a credit type that has already been granted (with PCrdGrant)."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_PCRDTYPE_RETRIED
  // =====
  property CHI5PC_ERR_REQ_PCRDTYPE_RETRIED; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && !REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT) 
      |-> (MODE == 1 && Retry_CrdRtn_cnt[req_tgt][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]][9] && |Retry_CrdRtn_cnt[req_tgt][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]][8:0]) ||
          (MODE == 0 && Retry_CrdRtn_cnt[req_src][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]][9] && |Retry_CrdRtn_cnt[req_src][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]][8:0]);
  endproperty
  chi5pc_err_req_pcrdtype_retried: assert property (CHI5PC_ERR_REQ_PCRDTYPE_RETRIED) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_PCRDTYPE_RETRIED::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A request issued with pre-allocated credit must use a credit type that was indicated with a RetryAck."});



  // =====
  // INDEX:        - CHI5PC_ERR_REQ_PCRDRTN_DYN
  // =====
  property CHI5PC_ERR_REQ_PCRDRTN_DYN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDRETURN)
      |-> !REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE];
  endproperty
  chi5pc_err_req_pcrdrtn_dyn: assert property (CHI5PC_ERR_REQ_PCRDRTN_DYN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_PCRDRTN_DYN::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A credit return request must have AllowRetry deasserted."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_PCRDRTN_TYPE
  // =====
  property CHI5PC_ERR_REQ_PCRDRTN_TYPE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDRETURN)
      |-> MODE == 1 ? |PCrdGnt_PCrdRtn_cnt[pcrdreturn_tgt][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]] : |PCrdGnt_PCrdRtn_cnt[pcrdreturn_src][REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE]];
  endproperty
  chi5pc_err_req_pcrdrtn_type: assert property (CHI5PC_ERR_REQ_PCRDRTN_TYPE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_PCRDRTN_TYPE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A credit return must return a credit type that has already been granted."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_OVFLW
  // =====
  property CHI5PC_ERR_REQ_OVFLW; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,Info_Alloc_vector}))
       && &Info_Alloc_vector  
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE]) && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]
       |-> ((MODE == 1) && M_RSP_Pop || WRDAT_Pop) || ((MODE ==0) && |Info_Pop_vector);
  endproperty
  chi5pc_err_req_ovflw: assert property (CHI5PC_ERR_REQ_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_OVFLW::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The number of outstanding requests has exceeded MAX_OS_REQ."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_PCRD_OVFLW
  // =====
  property CHI5PC_ERR_REQ_PCRD_OVFLW;
     @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown(Info_Alloc_vector))
          && &Info_Alloc_vector && ~|Info_Pop_vector && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
      |-> !(REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE])) ;
  endproperty
  chi5pc_err_req_pcrd_ovflw: assert property (CHI5PC_ERR_REQ_PCRD_OVFLW) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_PCRD_OVFLW::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "The number of transactions in progress (including those waiting to be retried) must not exceed MAX_OS_REQ."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_DVM_MTYPE
  // =====
  property CHI5PC_ERR_REQ_RSVD_DVM_MTYPE;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP)
      |-> (Info_tmp.Addr.REQ_DVM.Type <= CHI5PC_DVM_SYNC); 
  endproperty
  chi5pc_err_req_rsvd_dvm_mtype : assert property (CHI5PC_ERR_REQ_RSVD_DVM_MTYPE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_DVM_MTYPE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "DVM Message Type field encodings 3'b101, 3'b110 and 3'b111 are reserved."});

   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_NS
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_GUEST_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_GUESTOS) && 
       (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) 
       |-> (((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //1 
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) && //2
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //3
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //4
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //5
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
           ||  ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //6
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b01) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //7
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //8
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //9
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b10) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
           || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) &&  //10
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b10) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1)));
  endproperty
  chi5pc_err_req_dvm_tlbi_guest_ns : assert property (CHI5PC_ERR_REQ_DVM_TLBI_GUEST_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_GUEST_NS: DVM message (TLBI, GuestOS, Non-Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_S
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_GUEST_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_GUESTOS) &&
       (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) 
        |->  (((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && //11 
               (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
               (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
               (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
               (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && //12 
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //13
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //14
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //15
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //16
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0)));
  endproperty
  chi5pc_err_req_dvm_tlbi_guest_s : assert property (CHI5PC_ERR_REQ_DVM_TLBI_GUEST_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_GUEST_S: DVM message (TLBI, GuestOS, Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_HYP_NS
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_HYP_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) && 
       (Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_HYPERVISOR) 
       |-> (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) &&
           (((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //17
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
         || (((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //18
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1)))
         || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //19
             (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
             (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
             (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0)));
  endproperty
  chi5pc_err_req_dvm_tlbi_hyp_ns : assert property (CHI5PC_ERR_REQ_DVM_TLBI_HYP_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_HYP_NS: DVM message (TLBI, Hypervisor, Non-Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_EL3_S
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_EL3_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.REQ_DVM.Hyp == 2'b01) 
       |-> (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) &&
          (((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //20
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) &&  //21
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && //22 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0)));

  endproperty
  chi5pc_err_req_dvm_tlbi_el3_s : assert property (CHI5PC_ERR_REQ_DVM_TLBI_EL3_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_EL3_S: DVM message (TLBI, EL3, Secure) detected with an unsupported combined encoding of fields ASID_Valid, VMID_Valid, LEAF, S2-S1 & VA_Valid."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_GUEST_HYP_BOTH
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_GUEST_HYP_BOTH;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) 
       |-> Info_tmp.Addr.REQ_DVM.Hyp != 2'b00;

  endproperty
  chi5pc_err_req_dvm_tlbi_guest_hyp_both : assert property (CHI5PC_ERR_REQ_DVM_TLBI_GUEST_HYP_BOTH) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_GUEST_HYP_BOTH: Unsupported DVM message (TLBI, Both GuestOS & Hypervisor) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_NS_S_BOTH
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_NS_S_BOTH;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) 
       |-> Info_tmp.Addr.REQ_DVM.NS  != CHI5PC_DVM_NS_BOTH;

  endproperty
  chi5pc_err_req_dvm_tlbi_ns_s_both : assert property (CHI5PC_ERR_REQ_DVM_TLBI_NS_S_BOTH) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_NS_S_BOTH: Unsupported DVM message (TLBI, Both Non-Secure & Secure) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_HYP_S
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_HYP_S;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.REQ_DVM.Hyp == 2'b11) 
       |-> Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE ;

  endproperty
  chi5pc_err_req_dvm_tlbi_hyp_s : assert property (CHI5PC_ERR_REQ_DVM_TLBI_HYP_S) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_HYP_S: Unsupported DVM message (TLBI, Hypervisor, Secure) detected."));
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_TLBI_EL3_NS
  // =====
  property CHI5PC_ERR_REQ_DVM_TLBI_EL3_NS;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_TLB_INV) &&  
       (Info_tmp.Addr.REQ_DVM.Hyp == 2'b01) 
       |-> Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE ;

  endproperty
  chi5pc_err_req_dvm_tlbi_el3_ns : assert property (CHI5PC_ERR_REQ_DVM_TLBI_EL3_NS) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_TLBI_EL3_NS: Unsupported DVM message (TLBI, EL3, Non-Secure) detected."));
   

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_BPI
  // =====
  property CHI5PC_ERR_REQ_DVM_BPI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_BTB_INV) 
      |-> ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1));
  endproperty
  chi5pc_err_req_dvm_bpi : assert property (CHI5PC_ERR_REQ_DVM_BPI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_BPI: DVM message (BPI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_PICI
  // =====
  property CHI5PC_ERR_REQ_DVM_PICI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_IC_PA_INV) 
      |-> ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //23
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //24
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //25
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && //26
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))  
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //27
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))  
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //28
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1));
  endproperty
  chi5pc_err_req_dvm_pici : assert property (CHI5PC_ERR_REQ_DVM_PICI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_PICI: DVM message (PICI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
    
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_VICI
  // =====
  property CHI5PC_ERR_REQ_DVM_VICI;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_IC_VA_INV) 
      |-> ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //29
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && //30
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) &&
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0))
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //31
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_SECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1))  
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //32
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0)) 
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_GUESTOS) && //33
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b1) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1)) 
       || ((Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_HYPERVISOR) && //34
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_NONSECURE) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b1));
  endproperty
  chi5pc_err_req_dvm_vici : assert property (CHI5PC_ERR_REQ_DVM_VICI) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_VICI: DVM message (VICI) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DVM_SYNC
  // =====
  property CHI5PC_ERR_REQ_DVM_SYNC;
    @(posedge `CHI5_SVA_CLK) 
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && 
       (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_SYNC) 
      |-> (Info_tmp.Addr.REQ_DVM.Hyp == CHI5PC_DVM_HYP_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.NS == CHI5PC_DVM_NS_BOTH) && 
           (Info_tmp.Addr.REQ_DVM.VMID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.ASID_Valid == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.L == 1'b0) && 
           (Info_tmp.Addr.REQ_DVM.S2S1 == 2'b00) && 
           (Info_tmp.Addr.REQ_DVM.VA_Valid == 1'b0);
  endproperty
  chi5pc_err_req_dvm_sync : assert property (CHI5PC_ERR_REQ_DVM_SYNC) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_REQ_DVM_SYNC: DVM message (SYNC) detected with an unsupported combined encoding of fields GuestOS_Hypervisor, Security, VMID_Valid, ASID_Valid, LEAF, S2-S1 & VA_Valid."));
    
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_CTL_DVMOP
  // =====
  property CHI5PC_ERR_REQ_CTL_DVMOP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP
      |-> (REQFLIT_[`CHI5PC_REQ_FLIT_SIZE_RANGE] == `CHI5PC_SIZE8B) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_NS_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_LIKELYSHARED_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_MEMATTR_RANGE] == 'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_SNPATTR_SNOOPABLE_RANGE] == 1'b0) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_DYNPCRD_RANGE] ? ~|REQFLIT_[`CHI5PC_REQ_FLIT_PCRDTYPE_RANGE] : 1'b1  ) &&
          (REQFLIT_[`CHI5PC_REQ_FLIT_EXPCOMPACK_RANGE] == 1'b0);
  endproperty
  chi5pc_err_req_ctl_dvmop: assert property (CHI5PC_ERR_REQ_CTL_DVMOP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_CTL_DVMOP::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flits with opcode DVMOp must have Size = 8B, NS = 'b0, LikelyShared = 'b0, Order = 'b0, MemAttr = 'b0, SnoopAttr[Snoopable] = 'b0, Excl = 'b0 and ExpCompAck = 'b0. If AllowRetry is high then PCrdType must be 'b0."});
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_DVM_S2S1
  // =====
  property CHI5PC_ERR_REQ_RSVD_DVM_S2S1; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP
      |-> ~&Info_tmp.Addr.REQ_DVM.S2S1;
  endproperty
  chi5pc_err_req_rsvd_dvm_s2s1: assert property (CHI5PC_ERR_REQ_RSVD_DVM_S2S1) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_DVM_S2S1::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "DVM Stage2/Stage1 field encoding 2'b11 is reserved."});
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_DVM_SECURE
  // =====
  property CHI5PC_ERR_REQ_RSVD_DVM_SECURE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP
      |-> Info_tmp.Addr.REQ_DVM.NS != 2'b01;
  endproperty
  chi5pc_err_req_rsvd_dvm_secure: assert property (CHI5PC_ERR_REQ_RSVD_DVM_SECURE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_DVM_SECURE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "DVM Secure field encoding 2'b01 is reserved."});
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_DVM_ADDR
  // =====
  property CHI5PC_ERR_REQ_RSVD_DVM_ADDR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP
      |-> ~|Info_tmp.Addr.REQ_DVM.reqDVM_ADDR2_0_RSVD0;
  endproperty
  chi5pc_err_req_rsvd_dvm_addr: assert property (CHI5PC_ERR_REQ_RSVD_DVM_ADDR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_DVM_ADDR::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "DVM address bits [2:0] are reserved and should be zero."});
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_RSVD_ORDER
  // =====
    property CHI5PC_ERR_REQ_RSVD_ORDER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]
      |-> REQFLIT_[`CHI5PC_REQ_FLIT_ORDER_RANGE] != 2'b01;
  endproperty
  chi5pc_err_req_rsvd_order: assert property (CHI5PC_ERR_REQ_RSVD_ORDER) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_RSVD_ORDER::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Request flit Order value 2'b01 is reserved."});
    
  
  // =====
  // INDEX:        - CHI5PC_REC_REQ_ORDER
  // =====
  property CHI5PC_REC_REQ_ORDER; 
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && (`IS_READ_(Info_tmp) || `IS_WRITE_(Info_tmp) )
       && REQFLITV_ && ((NODE_TYPE == RNF) || (NODE_TYPE == RNI) || (NODE_TYPE == RND)) && (MODE == 1) 
      |-> ~|REQORDER_ERR_vector;
  endproperty
  chi5pc_rec_req_order: assert property (CHI5PC_REC_REQ_ORDER) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_REQ_ORDER: It is recommended that to ensure ordering an RN should not issue a second ordered request until a ReadReceipt or DBIDResp has been received for the first ordered request." ));
  
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_SYNC_UNQ
  // =====
  property CHI5PC_ERR_REQ_SYNC_UNQ;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP)
      && (Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_SYNC) 
      |-> ~|DVM_SYNC_CLASH_vector; 
  endproperty
  chi5pc_err_req_sync_unq : assert property (CHI5PC_ERR_REQ_SYNC_UNQ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_SYNC_UNQ::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "RNF/RND must not issue more than one DVM Sync message at a time."});
   

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_BAR_WR_HAZ
  // =====
  property CHI5PC_ERR_REQ_BAR_WR_HAZ;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER) || (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER))
      |-> ~|(Is_Write_vector & Is_memattrX0XX_vector & Is_tgt_HNI_SNI_vector  & Is_same_LPID_SRCID_vector & ~Has_Comp_vector);
  endproperty
  chi5pc_err_req_bar_wr_haz : assert property (CHI5PC_ERR_REQ_BAR_WR_HAZ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_BAR_WR_HAZ::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "An RN/HNI must wait until all writes that are Normal Non-cacheable and Device type, that are targetting HNI/SNI, have received a completion response before issuing an EOBarrier or an ECBarrier request."});
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_WR_BAR_HAZ
  // =====
  property CHI5PC_ERR_REQ_WR_BAR_HAZ;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && `IS_WRITE_(Info_tmp) && !memattr_cacheable && ((Chi5_in.get_NodeType(Info_tmp.TgtID_rmp) == eChi5PCDevType'(HNI)) || (Chi5_in.get_NodeType(Info_tmp.TgtID_rmp) == eChi5PCDevType'(SNI)))
      |-> ~|(Is_Barrier_vector & Is_same_LPID_SRCID_vector);
  endproperty
  chi5pc_err_req_wr_bar_haz : assert property (CHI5PC_ERR_REQ_WR_BAR_HAZ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_WR_BAR_HAZ::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A source must wait until all barriers have completed before issuing writes that are Normal Non-cacheable or Device type."});
   
  // =====
  // INDEX:        - CHI5PC_REC_REQ_BAR
  // =====
  //logic [1:MAX_OS_TX] Is_same_LPID_SRCID_Write_memattrX0XX_vector;
  //assign Is_same_LPID_SRCID_Write_memattrX0XX_vector = Is_same_LPID_SRCID_vector &  Is_memattrX0XX_vector & Is_Write_vector;
  
  property CHI5PC_REC_REQ_BAR;
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER) || (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER))
      |-> PreBarrier_writes[Info_tmp.LPID];
  endproperty
  chi5pc_rec_req_bar : assert property (CHI5PC_REC_REQ_BAR) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_BAR::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that an RN only issues an EOBarrier or ECBarrier if it has issued a Normal Non-cacheable or Device type memory write request since previously completing an EOBarrier or ECBarrier."});
   
   
  // =====
  // INDEX:        - CHI5PC_REC_REQ_SYNC_HAZ
  // =====
  property CHI5PC_REC_REQ_SYNC_HAZ;
    @(posedge `CHI5_SVA_CLK)
    `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_})) &&
       REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP) && ( Info_tmp.Addr.REQ_DVM.Type == CHI5PC_DVM_SYNC)
      |-> ~|(Is_DVMOp_vector & ~Has_Comp_vector);
  endproperty
  chi5pc_rec_req_sync_haz : assert property (CHI5PC_REC_REQ_SYNC_HAZ) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_REQ_SYNC_HAZ::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "It is recommended that all previous DVMOp requests must have received a Comp response before the RN can send a DVM(Sync)."});
   
  // =====
  // INDEX:        - CHI5PC_ERR_REQ_REQATTR
  // =====
  property CHI5PC_ERR_REQ_REQATTR; 
    @(posedge `CHI5_SVA_CLK) disable iff (!ErrorOn_SW)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_PCRDRETURN)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_DVMOP)
      |-> ~|REQ_Attr_CLASH_vector;
  endproperty
  chi5pc_err_req_reqattr: assert property (CHI5PC_ERR_REQ_REQATTR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_REQATTR::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "All nodes must maintain a consistent view of the attributes of any region of memory. A request has been issued with memory or snoop attributes that differ from an outstanding request to the same region."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_DEV
  // =====
  property CHI5PC_ERR_REQ_DEV; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_,REQFLIT_}))
       && REQFLITV_ 
       && (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] != `CHI5PC_REQLINKFLIT)
       && memattr_device == 1'b1 
      |-> ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL) || 
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL) ||
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP));
  endproperty
  chi5pc_err_req_dev: assert property (CHI5PC_ERR_REQ_DEV) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_DEV::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "Requests to Device memory type must of type WriteNoSnpFull, WriteNoSnpPtl or ReadNoSnp."});


  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXCL_OVLAP_NONSNOOPABLE
  // =====
  property CHI5PC_ERR_REQ_EXCL_OVLAP_NONSNOOPABLE; 
    @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_} ))
       && REQFLITV_ 
       && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READNOSNP) || 
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPPTL) || 
           (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_WRITENOSNPFULL))
          |-> ~|excl_ovlap_nonsnoopable_vector;
   
  endproperty
  chi5pc_err_req_excl_ovlap_nonsnoopable: assert property (CHI5PC_ERR_REQ_EXCL_OVLAP_NONSNOOPABLE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXCL_OVLAP_NONSNOOPABLE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A nonsnoopable exclusive request must not be made while there is an ongoing non-snoopable exclusive request from the same LP."});

  // =====
  // INDEX:        - CHI5PC_ERR_REQ_EXCL_OVLAP_SNOOPABLE
  // =====
  property CHI5PC_ERR_REQ_EXCL_OVLAP_SNOOPABLE; 
    @(posedge `CHI5_SVA_CLK) 
       `CHI5_SVA_RSTn && !($isunknown({REQFLITV_} ))
       && REQFLITV_  && REQFLIT_[`CHI5PC_REQ_FLIT_EXCL_RANGE] 
       && ((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE) ||
          (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN) ||
          (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED))
          |-> !((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_CLEANUNIQUE) && |(excl_ovlap_snoopable_vector & (is_ReadShared_ReadClean_vector | is_CleanUnique_vector))) &&
               !((((REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READCLEAN) || (REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_READSHARED)) 
                 && (excl_ovlap_snoopable_vector & is_CleanUnique_vector)));

  endproperty
  chi5pc_err_req_excl_ovlap_snoopable: assert property (CHI5PC_ERR_REQ_EXCL_OVLAP_SNOOPABLE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_REQ_EXCL_OVLAP_SNOOPABLE::", string'(MODE == 1 ? " TXREQ: " : " RXREQ: "), "A snoopable exclusive STREX must not be made while there is an ongoing snoopable exclusive request from the same LP."});

//------------------------------------------------------------------------------
// INDEX:   6)  RSP channel Checks
//------------------------------------------------------------------------------ 
//

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_CS
  // =====
  property CHI5PC_ERR_RSP_RESP_CS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANSHARED) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == SC) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == UC) ;
  endproperty
  chi5pc_err_rsp_resp_cs: assert property (CHI5PC_ERR_RSP_RESP_CS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_CS::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a CleanShared transaction must be I, SC or UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_CI
  // =====
  property CHI5PC_ERR_RSP_RESP_CI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANINVALID) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_ci: assert property (CHI5PC_ERR_RSP_RESP_CI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_CI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a CleanInvalid transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_MI
  // =====
  property CHI5PC_ERR_RSP_RESP_MI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEINVALID) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_mi: assert property (CHI5PC_ERR_RSP_RESP_MI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_MI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a MakeInvalid transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_CU
  // =====
  property CHI5PC_ERR_RSP_RESP_CU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_MSB]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANUNIQUE) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == UC) ;
  endproperty
  chi5pc_err_rsp_resp_cu: assert property (CHI5PC_ERR_RSP_RESP_CU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_CU::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a CleanUnique transaction must be UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_MU
  // =====
  property CHI5PC_ERR_RSP_RESP_MU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEUNIQUE) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == UC);
  endproperty
  chi5pc_err_rsp_resp_mu: assert property (CHI5PC_ERR_RSP_RESP_MU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_MU::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a MakeUnique transaction must be UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_E
  // =====
  property CHI5PC_ERR_RSP_RESP_E; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_EVICT) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_e: assert property (CHI5PC_ERR_RSP_RESP_E) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_E::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of an Evict transaction must be I."});
  

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_EOB
  // =====
  property CHI5PC_ERR_RSP_RESP_EOB; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_EOBARRIER) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_eob: assert property (CHI5PC_ERR_RSP_RESP_EOB) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_EOB::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of an EOBarrier transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_ECB
  // =====
  property CHI5PC_ERR_RSP_RESP_ECB; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_ECBARRIER) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_ecb: assert property (CHI5PC_ERR_RSP_RESP_ECB) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_ECB::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of an ECBarrier transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_DVM
  // =====
  property CHI5PC_ERR_RSP_RESP_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
       && ~S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_MSB]
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_dvm: assert property (CHI5PC_ERR_RSP_RESP_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_DVM::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp message of a DVMOp transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WEF
  // =====
  property CHI5PC_ERR_RSP_RESP_WEF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEEVICTFULL) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wef: assert property (CHI5PC_ERR_RSP_RESP_WEF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WEF::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the CompDBIDResp message of a WriteEvictFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WCP
  // =====
  property CHI5PC_ERR_RSP_RESP_WCP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANPTL) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wcp: assert property (CHI5PC_ERR_RSP_RESP_WCP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WCP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the CompDBIDResp message of a WriteCleanPtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WCF
  // =====
  property CHI5PC_ERR_RSP_RESP_WCF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITECLEANFULL) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I);
  endproperty
  chi5pc_err_rsp_resp_wcf: assert property (CHI5PC_ERR_RSP_RESP_WCF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WCF::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the CompDBIDResp message of a WriteCleanFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WUP
  // =====
  property CHI5PC_ERR_RSP_RESP_WUP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEPTL) &&
          ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wup: assert property (CHI5PC_ERR_RSP_RESP_WUP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WUP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp/CompDBIDResp message of a WriteUniquePtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WUF
  // =====
  property CHI5PC_ERR_RSP_RESP_WUF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEFULL) &&
          ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) ||
            (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wuf: assert property (CHI5PC_ERR_RSP_RESP_WUF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WUF::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp/CompDBIDResp message of a WriteUniqueFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WBP
  // =====
  property CHI5PC_ERR_RSP_RESP_WBP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKPTL) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wbp: assert property (CHI5PC_ERR_RSP_RESP_WBP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WBP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the CompDBIDResp message of a WriteBackPtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WBF
  // =====
  property CHI5PC_ERR_RSP_RESP_WBF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEBACKFULL) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wbf: assert property (CHI5PC_ERR_RSP_RESP_WBF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WBF::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the CompDBIDResp message of a WriteBackFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WNSP
  // =====
  property CHI5PC_ERR_RSP_RESP_WNSP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_MSB]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPPTL) &&
          ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP)  || 
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wnsp: assert property (CHI5PC_ERR_RSP_RESP_WNSP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WNSP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp/CompDBIDResp message of a WriteNoSnpPtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESP_WNSF
  // =====
  property CHI5PC_ERR_RSP_RESP_WNSF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && ~S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_MSB]
       && S_RSPFLITV_ &&  
          (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPFULL) &&
          ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP)  || 
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == I;
  endproperty
  chi5pc_err_rsp_resp_wnsf: assert property (CHI5PC_ERR_RSP_RESP_WNSF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESP_WNSF::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Resp field in the Comp/CompDBIDResp message of a WriteNoSnpFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_CS
  // =====
  property CHI5PC_ERR_RSP_RESPERR_CS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANSHARED) && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK;
  endproperty
  chi5pc_err_rsp_resperr_cs: assert property (CHI5PC_ERR_RSP_RESPERR_CS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_CS::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a CleanShared transaction must not be EXOK."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_CI
  // =====
  property CHI5PC_ERR_RSP_RESPERR_CI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_CLEANINVALID) && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK;
  endproperty
  chi5pc_err_rsp_resperr_ci: assert property (CHI5PC_ERR_RSP_RESPERR_CI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_CI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a CleanInvalid transaction must not be EXOK."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_MI
  // =====
  property CHI5PC_ERR_RSP_RESPERR_MI; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEINVALID) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK;
  endproperty
  chi5pc_err_rsp_resperr_mi: assert property (CHI5PC_ERR_RSP_RESPERR_MI) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_MI::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a MakeInvalid transaction must not be EXOK."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_MU
  // =====
  property CHI5PC_ERR_RSP_RESPERR_MU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_MAKEUNIQUE) && S_RSP_match
        |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] != CHI5PC_EXCL_OK;
  endproperty
  chi5pc_err_rsp_resperr_mu: assert property (CHI5PC_ERR_RSP_RESPERR_MU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_MU::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a MakeUnique transaction must not be EXOK."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_E
  // =====
  property CHI5PC_ERR_RSP_RESPERR_E; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_EVICT) && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_RESP_OK_EXCL_FAIL) 
            || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR);
  endproperty
  chi5pc_err_rsp_resperr_e: assert property (CHI5PC_ERR_RSP_RESPERR_E) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_E::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of an Evict transaction must be OK or NDERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_BARRIER
  // =====
  property CHI5PC_ERR_RSP_RESPERR_BARRIER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && ((Current_S_RSP_Info.OpCode == `CHI5PC_EOBARRIER) || (Current_S_RSP_Info.OpCode == `CHI5PC_ECBARRIER)) && S_RSP_match && 
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP)
      |-> ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE];
  endproperty
  chi5pc_err_rsp_resperr_barrier: assert property (CHI5PC_ERR_RSP_RESPERR_BARRIER) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_BARRIER::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a barrier transaction must be OK."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RESPERR_DVM
  // =====
  property CHI5PC_ERR_RSP_RESPERR_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) &&
          (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
        |-> ~^S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE];
  endproperty
  chi5pc_err_rsp_resperr_dvm: assert property (CHI5PC_ERR_RSP_RESPERR_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RESPERR_DVM::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The RespErr field in the Comp message of a DVMOp transaction must be OK or NDERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RSVD_RESP_COMP
  // =====
  property CHI5PC_ERR_RSP_RSVD_RESP_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP)) && ~S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_MSB]
      |-> !((S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 3'b011) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 3'b100) || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 3'b101));
  endproperty
  chi5pc_err_rsp_rsvd_resp_comp: assert property (CHI5PC_ERR_RSP_RSVD_RESP_COMP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RSVD_RESP_COMP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Resp field values 3'b011, 3'b100 and 3'b101 in Comp and CompDBIDResp messages are reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_COMPACK
  // =====
  property CHI5PC_ERR_RSP_CTL_COMPACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK) && M_RSP_match
      |-> M_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == 'b0 &&
          M_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 'b0 &&
          M_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0;
  endproperty
  chi5pc_err_rsp_ctl_compack: assert property (CHI5PC_ERR_RSP_CTL_COMPACK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_COMPACK::", string'(MODE == 1 ? " TXRSP: " : " RXRSP: "), "Response flits with opcode CompAck must have RespErr = 'b0, Resp = 'b0 and PCrdType = 'b0."});


  // ====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_RETRYACK
  // =====
  property CHI5PC_ERR_RSP_CTL_RETRYACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK) && S_RSP_match 
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == 'b0 &&
          S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_rsp_ctl_retryack: assert property (CHI5PC_ERR_RSP_CTL_RETRYACK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_RETRYACK::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode RetryAck must have RespErr = 'b0 and Resp = 'b0."});




  // ====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_COMP
  // =====
  // Comp could could before dbid value so if this is the first reponse ignore
  // DBID check
  property CHI5PC_ERR_RSP_CTL_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP && S_RSP_match 
      |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0) ;
  endproperty
  chi5pc_err_rsp_ctl_comp: assert property (CHI5PC_ERR_RSP_CTL_COMP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_COMP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode Comp must have PCrdType = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DBID_COMP
  // =====
  // Comp could could before dbid value so if this is the first reponse ignore
  // DBID check
  property CHI5PC_ERR_RSP_DBID_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP && S_RSP_match 
      |-> ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE] == Current_S_RSP_Info.DBID) || &Current_S_RSP_Info.RspOpCode1);
  endproperty
  chi5pc_err_rsp_dbid_comp: assert property (CHI5PC_ERR_RSP_DBID_COMP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DBID_COMP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode Comp must have DBID equal to value in the previous DBIDResp."});



  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_COMPDBIDRESP
  // =====
  property CHI5PC_ERR_RSP_CTL_COMPDBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP && S_RSP_match 
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_rsp_ctl_compdbidresp: assert property (CHI5PC_ERR_RSP_CTL_COMPDBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_COMPDBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode CompDBIDResp must have PCrdType = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_DBIDRESP
  // =====
  property CHI5PC_ERR_RSP_CTL_DBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP && S_RSP_match 
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == 'b0 &&
          S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 'b0 &&
          S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_rsp_ctl_dbidresp: assert property (CHI5PC_ERR_RSP_CTL_DBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_DBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode DBIDResp must have RespErr = 'b0, Resp = 'b0 and PCrdType = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DBID_DBIDRESP
  // =====
  property CHI5PC_ERR_RSP_DBID_DBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP && S_RSP_match 
      |-> ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE] == Current_S_RSP_Info.DBID) || &Current_S_RSP_Info.RspOpCode1) ;
  endproperty
  chi5pc_err_rsp_dbid_dbidresp: assert property (CHI5PC_ERR_RSP_DBID_DBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DBID_DBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode DBIDResp must have DBID equal to value in previous Comp."});




  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CNT_READRECEIPT
  // =====
  property CHI5PC_ERR_RSP_CNT_READRECEIPT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT) && S_RSP_match
      |-> &Current_S_RSP_Info.RspOpCode1;
  endproperty
  chi5pc_err_rsp_cnt_readreceipt: assert property (CHI5PC_ERR_RSP_CNT_READRECEIPT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CNT_READRECEIPT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Only one ReadReceipt response is allowed per read transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_READRECEIPT_READ
  // =====
  property CHI5PC_ERR_RSP_READRECEIPT_READ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT) && S_RSP_match
      |-> Is_Read_vector[S_RSP_Info_Index];
  endproperty
  chi5pc_err_rsp_readreceipt_read: assert property (CHI5PC_ERR_RSP_READRECEIPT_READ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_READRECEIPT_READ::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "ReadReceipt response is only a valid response for a read transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_COMPDBID_READ
  // =====
  property CHI5PC_ERR_RSP_COMPDBID_READ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSP_match && 
       ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) ||
       (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP) ||
       (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) )
      |-> !Is_Read_vector[S_RSP_Info_Index];
  endproperty
  chi5pc_err_rsp_compdbid_read: assert property (CHI5PC_ERR_RSP_COMPDBID_READ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_COMPDBID_READ::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Comp, CompDBIDResp or DBIDResp are not valid responses for Read transactions."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_COMP_DBID_COPYBACK
  // =====
  property CHI5PC_ERR_RSP_COMP_DBID_COPYBACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSP_match && 
       ((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP) ||
       (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) )
      |-> Current_S_RSP_Info.OpCode != `CHI5PC_WRITEBACKFULL &&
          Current_S_RSP_Info.OpCode != `CHI5PC_WRITEBACKPTL &&
          Current_S_RSP_Info.OpCode != `CHI5PC_WRITECLEANFULL &&
          Current_S_RSP_Info.OpCode != `CHI5PC_WRITECLEANPTL &&
          Current_S_RSP_Info.OpCode != `CHI5PC_WRITEEVICTFULL;
  endproperty
  chi5pc_err_rsp_comp_dbid_copyback: assert property (CHI5PC_ERR_RSP_COMP_DBID_COPYBACK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_COMP_DBID_COPYBACK::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Comp and DBIDResp are not valid responses for WriteEvictFull, WriteClean* or WriteBack* transactions."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_COMP_CNT
  // =====
  property CHI5PC_ERR_RSP_CNT_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && S_RSP_match
      |-> (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_COMP) &&
          (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_COMPDBIDRESP);
  endproperty
  chi5pc_err_rsp_cnt_comp: assert property (CHI5PC_ERR_RSP_CNT_COMP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CNT_COMP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A Comp response message cannot be issued after a CompDBIDResp or a previous Comp response message for the same transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CNT_COMPDBIDRESP
  // =====
  property CHI5PC_ERR_RSP_CNT_COMPDBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP  && S_RSP_match
      |-> (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_COMP) &&
          (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_DBIDRESP) &&
          (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_COMPDBIDRESP);
  endproperty
  chi5pc_err_rsp_cnt_compdbidresp: assert property (CHI5PC_ERR_RSP_CNT_COMPDBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CNT_COMPDBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A CompDBIDResp response message cannot be issued after a Comp, DBIDResp or a previous CompDBIDResp response message for the same transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CNT_DBIDRESP
  // =====
  property CHI5PC_ERR_RSP_CNT_DBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP  && S_RSP_match
      |-> (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_DBIDRESP) &&
          (Current_S_RSP_Info.RspOpCode1 != `CHI5PC_COMPDBIDRESP) ;
  endproperty
  chi5pc_err_rsp_cnt_dbidresp: assert property (CHI5PC_ERR_RSP_CNT_DBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CNT_DBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A DBIDResp response message cannot be issued after a CompDBIDResp or a previous DBIDResp response message for the same transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TRXN_DBIDRESP
  // =====
  property CHI5PC_ERR_RSP_TRXN_DBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP)  && S_RSP_match
          |-> (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) ||
              (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPPTL) ||
              (Current_S_RSP_Info.OpCode == `CHI5PC_WRITENOSNPFULL) ||
              (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEPTL) ||
              (Current_S_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEFULL) ;
  endproperty
  chi5pc_err_rsp_trxn_dbidresp: assert property (CHI5PC_ERR_RSP_TRXN_DBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_TRXN_DBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode DBIDResp are only valid for DVM, WriteNoSnp* and WriteUnique* transactions."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TRXN_READRECEIPT
  // =====
  property CHI5PC_ERR_RSP_TRXN_READRECEIPT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT)  && S_RSP_match
      |-> `IS_READ_(Current_S_RSP_Info);
  endproperty
  chi5pc_err_rsp_trxn_readreceipt: assert property (CHI5PC_ERR_RSP_TRXN_READRECEIPT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_TRXN_READRECEIPT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode ReadReceipt are only valid for Read transactions."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_TRXN_COMPDBIDRESP
  // =====
  property CHI5PC_ERR_RSP_TRXN_COMPDBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP)  && S_RSP_match
      |-> ~(`IS_CLEAN__MAKE_(Current_S_RSP_Info) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_EVICT) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_EOBARRIER) ||
          (Current_S_RSP_Info.OpCode == `CHI5PC_ECBARRIER)) ;
  endproperty
  chi5pc_err_rsp_trxn_compdbidresp: assert property (CHI5PC_ERR_RSP_TRXN_COMPDBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_TRXN_COMPDBIDRESP::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A response with opcode CompDBIDResp is not valid for CMO, DVM, Evict or Barrier transactions."});


  // ====
  // INDEX:        - CHI5PC_ERR_RSP_ORDER_READRECEIPT
  // =====
  property CHI5PC_ERR_RSP_ORDER_READRECEIPT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && ~|Current_S_RSP_Info.Order && `IS_READ_(Current_S_RSP_Info)  && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_READRECEIPT;
  endproperty
  chi5pc_err_rsp_order_readreceipt: assert property (CHI5PC_ERR_RSP_ORDER_READRECEIPT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_ORDER_READRECEIPT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A ReadReceipt response must not be issued for a read transaction that did not request ordering."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_COMPACK_WU
  // =====
  property CHI5PC_ERR_RSP_COMPACK_WU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK)  && M_RSP_match && (`IS_WRITE_(Current_M_RSP_Info) ||`IS_CLEAN__MAKE_(Current_M_RSP_Info) )
      |-> `HAS_COMP(Current_M_RSP_Info);
  endproperty
  chi5pc_err_rsp_compack_wu: assert property (CHI5PC_ERR_RSP_COMPACK_WU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_COMPACK_WU::", string'(MODE == 1 ? " TXRSP: " : " RXRSP: "), "CompAck must only be issued after Comp for WriteUnique* transactions."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_COMPACK_READ
  // =====
  property CHI5PC_ERR_RSP_COMPACK_READ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && (M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK)  && M_RSP_match && `IS_READ_(Current_M_RSP_Info)
      |-> `HAS_ALLDATA(Current_M_RSP_Info);
  endproperty
  chi5pc_err_rsp_compack_read: assert property (CHI5PC_ERR_RSP_COMPACK_READ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_COMPACK_READ::", string'(MODE == 1 ? " TXRSP: " : " RXRSP: "), "CompAck must only be issued after all data for Read* transactions."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DVM_RX_FIRST
  // =====
  property CHI5PC_ERR_RSP_DVM_FIRST; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) && &Current_S_RSP_Info.RspOpCode1 && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RETRYACK) && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP;
  endproperty
  chi5pc_err_rsp_dvm_first: assert property (CHI5PC_ERR_RSP_DVM_FIRST) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DVM_FIRST::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The first response to a DVM operation must be a DBIDResp response."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DVM_SECOND
  // =====
  property CHI5PC_ERR_RSP_DVM_SECOND; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) && ~&Current_S_RSP_Info.RspOpCode1 && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP;
  endproperty
  chi5pc_err_rsp_dvm_second: assert property (CHI5PC_ERR_RSP_DVM_SECOND) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DVM_SECOND::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The second response message of a DVMOp transaction must be Comp."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DVM_ALLDAT
  // =====
  property CHI5PC_ERR_RSP_DVM_ALLDAT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && (Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) && S_RSP_match
      |-> `HAS_ALLDATA(Current_S_RSP_Info);
  endproperty
  chi5pc_err_rsp_dvm_alldat: assert property (CHI5PC_ERR_RSP_DVM_ALLDAT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DVM_ALLDAT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The Comp response message of a DVMOp transaction can only be issued after all data beats have completed."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RETRYACK_FIRST
  // =====
  property CHI5PC_ERR_RSP_RETRYACK_FIRST; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK) && S_RSP_match
      |-> &Current_S_RSP_Info.RspOpCode1 &&
          ~|Current_S_RSP_Info.DATID &&
          ((RDDAT_match && RDDATFLITV_) ? (RDDAT_Info_Index != S_RSP_Info_Index) : 1'b1);
  endproperty
  chi5pc_err_rsp_retryack_first: assert property (CHI5PC_ERR_RSP_RETRYACK_FIRST) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RETRYACK_FIRST::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "RetryAck must be issued as the first response to any transaction (including data responses)."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RETRYACK_PCRD_DYN
  // =====
  property CHI5PC_ERR_RSP_RETRYACK_PCRD_DYN; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK) && S_RSP_match
      |-> Current_S_RSP_Info.DynPCrd == CHI5PC_DYNAMIC;
  endproperty
  chi5pc_err_rsp_retryack_pcrd_dyn: assert property (CHI5PC_ERR_RSP_RETRYACK_PCRD_DYN) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RETRYACK_PCRD_DYN::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "RetryAck must not be issued to a request with AllowRetry deasserted."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DBID_ALLOCATION
  // =====
  property CHI5PC_ERR_RSP_DBID_ALLOCATION; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,RSP_DBID_ALLOC_ERR_vector}))
       && S_RSPFLITV_
      |-> ~|RSP_DBID_ALLOC_ERR_vector;
  endproperty
  chi5pc_err_rsp_dbid_allocation: assert property (CHI5PC_ERR_RSP_DBID_ALLOCATION) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DBID_ALLOCATION::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A DBID allocation must not be made for a buffer that is allocated to another transaction."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_DAT_DBID_ALLOCATION
  // =====
  property CHI5PC_ERR_RSP_DAT_DBID_ALLOCATION; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,RDDATFLITV_,S_RSPFLIT_,RDDATFLIT_}))
       && S_RSPFLITV_ && RDDATFLITV_
      |-> ~(((RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA) && Current_RDDAT_Info.ExpCompAck) &&
            (((S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP) && 
             (!(`HAS_ALLDATA(Current_S_RSP_Info)) || Current_S_RSP_Info.ExpCompAck)) ||       
             (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP) || 
             (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP)) &&
            (RDDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] ==  S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE]) &&
            (RDDATFLIT_[`CHI5PC_DAT_FLIT_SRCID_RANGE] == S_RSPFLIT_[`CHI5PC_RSP_FLIT_SRCID_RANGE]) 
      );
  endproperty
  chi5pc_err_rsp_dat_dbid_allocation: assert property (CHI5PC_ERR_RSP_DAT_DBID_ALLOCATION) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_DAT_DBID_ALLOCATION::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A DBID allocation must not be made for the same buffer on the DAT and RSP channels."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_PCRDGRANT
  // =====
  property CHI5PC_ERR_RSP_CTL_PCRDGRANT;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT) 
      |-> ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE]  &&
          ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] &&
          ~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_TXNID_RANGE] &&
          (~|S_RSPFLIT_[`CHI5PC_RSP_FLIT_DBID_RANGE]   ) ;
  endproperty
  chi5pc_err_rsp_ctl_pcrdgrant: assert property (CHI5PC_ERR_RSP_CTL_PCRDGRANT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_PCRDGRANT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode PCrdGrant must have TxnID = 'b0, RespErr = 'b0, Resp = 'b0 and DBID = 'b0."});

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_CTL_READRECEIPT
  // =====
  property CHI5PC_ERR_RSP_CTL_READRECEIPT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT) && S_RSP_match 
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == 'b0 &&
          S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESP_RANGE] == 'b0 &&
          S_RSPFLIT_[`CHI5PC_RSP_FLIT_PCRDTYPE_RANGE] == 'b0 ;
  endproperty
  chi5pc_err_rsp_ctl_readreceipt: assert property (CHI5PC_ERR_RSP_CTL_READRECEIPT) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_CTL_READRECEIPT::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "Response flits with opcode ReadReceipt must have RespErr = 'b0, Resp = 'b0 and PCrdType = 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_RETRYACK_PCRD_PREALLOC
  // =====
  property CHI5PC_ERR_RSP_RETRYACK_PCRD_PREALLOC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (Current_S_RSP_Info.DynPCrd == CHI5PC_STATIC) && S_RSP_match
      |-> S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_RETRYACK;
  endproperty
  chi5pc_err_rsp_retryack_pcrd_prealloc: assert property (CHI5PC_ERR_RSP_RETRYACK_PCRD_PREALLOC) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_RETRYACK_PCRD_PREALLOC::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "A RetryAck response cannot be issued for a transaction that uses pre-allocated protocol credit."});


  // =====
  // INDEX:        - CHI5PC_REC_RSP_ORDER_WRITEUNIQUE
  // =====
  property CHI5PC_REC_RSP_ORDER_WRITEUNIQUE; 
    @(posedge `CHI5_SVA_CLK) disable iff (!RecommendOn)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_  && ((Current_M_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEPTL) || (Current_M_RSP_Info.OpCode == `CHI5PC_WRITEUNIQUEFULL)) 
       && M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK
       &&   (Current_M_RSP_Info.Order == CHI5PC_ORDER_REQ) && M_RSP_match 
      |-> ~|TXPREV_WU_ERR_vector;
  endproperty
  chi5pc_rec_rsp_order_writeunique: assert property (CHI5PC_REC_RSP_ORDER_WRITEUNIQUE) else 
    `ARM_CHI5_PC_MSG_WARN({"CHI5PC_REC_RSP_ORDER_WRITEUNIQUE::", string'(MODE == 1 ? " TXRSP: " : " RXRSP: "), "It is recommended that a source should send a CompAck response after receiving all Comp responses for all earlier ordered WriteUniques."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_HNF_INVALID_REQ
  // =====
  property CHI5PC_ERR_RSP_HNF_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE_HAS_HNF)  && (MODE == 0) &&
          ((Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) ||
           (Current_S_RSP_Info.OpCode == `CHI5PC_EOBARRIER) ||
           (Current_S_RSP_Info.OpCode == `CHI5PC_ECBARRIER) )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_err_rsp_hnf_invalid_req: assert property (CHI5PC_ERR_RSP_HNF_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_HNF_INVALID_REQ: Node type HNF must return a non-data error if it receives a request for DVMOp, EOBarrier or ECBarrier."));
    
  // =====
  // INDEX:        - CHI5PC_ERR_RSP_HNI_INVALID_REQ
  // =====
  property CHI5PC_ERR_RSP_HNI_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE_HAS_HNI)  && (MODE == 0) &&
          ((Current_S_RSP_Info.OpCode == `CHI5PC_DVMOP) ||
           (Current_S_RSP_Info.OpCode == `CHI5PC_EOBARRIER) ||
           (Current_S_RSP_Info.OpCode == `CHI5PC_ECBARRIER) )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_err_rsp_hni_invalid_req: assert property (CHI5PC_ERR_RSP_HNI_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_HNI_INVALID_REQ: Node type HNI must return a non-data error if it receives a request for DVMOp, EOBarrier or ECBarrier."));

  // =====
  // INDEX:        - CHI5PC_REC_RSP_HNI_INVALID_REQ
  // =====
  property CHI5PC_REC_RSP_HNI_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE == HNI)  && (MODE == 0) &&
          ((Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPFULL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPPTL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_READNOSNP) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_PCRDRETURN)  )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_rec_rsp_hni_invalid_req: assert property (CHI5PC_REC_RSP_HNI_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_RSP_HNI_INVALID_REQ: It is recommended that Node type HNI return a non-data error if it receives a request other than ReadNoSnp, WriteNoSnp* or PCrdReturn."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_MN_INVALID_REQ
  // =====
  property CHI5PC_ERR_RSP_MN_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE_HAS_MN)  && (MODE == 0) &&
          ( (Current_S_RSP_Info.OpCode != `CHI5PC_DVMOP) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_EOBARRIER) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_ECBARRIER) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_PCRDRETURN)  )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_err_rsp_mn_invalid_req: assert property (CHI5PC_ERR_RSP_MN_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_MN_INVALID_REQ: Node type MN must return a non-data error if it receives a request other than DVMOp, EOBarrier, ECBarrier or PCrdReturn."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_SNF_INVALID_REQ
  // =====
  property CHI5PC_ERR_RSP_SNF_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE == SNF)  && (MODE == 0) &&
          ((Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPFULL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPPTL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_READNOSNP) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_PCRDRETURN)  )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_err_rsp_snf_invalid_req: assert property (CHI5PC_ERR_RSP_SNF_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_SNF_INVALID_REQ: Node type SNF must return a non-data error if it receives a request other than ReadNoSnp, WriteNoSnp* or PCrdReturn."));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_SNI_INVALID_REQ
  // =====
  property CHI5PC_ERR_RSP_SNI_INVALID_REQ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && (NODE_TYPE == SNI)  && (MODE == 0) &&
          ((Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPFULL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_WRITENOSNPPTL) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_READNOSNP) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_EOBARRIER) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_ECBARRIER) &&
           (Current_S_RSP_Info.OpCode != `CHI5PC_PCRDRETURN)  )
          && S_RSP_match
        |-> (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] == CHI5PC_NON_DATA_ERR) ;
  endproperty
  chi5pc_err_rsp_sni_invalid_req: assert property (CHI5PC_ERR_RSP_SNI_INVALID_REQ) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_SNI_INVALID_REQ: Node type SNI must return a non-data error if it receives a request other than ReadNoSnp, WriteNoSnp*, EOBarrier, ECBarrier or PCrdReturn."));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_EXOKAY_WR
  // =====
  property CHI5PC_ERR_RSP_EXOKAY_WR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSP_match && (S_RSPFLIT_[`CHI5PC_RSP_FLIT_RESPERR_RANGE] ==CHI5PC_EXCL_OK)
      |->   Current_S_RSP_Info.Excl;
  endproperty
  chi5pc_err_rsp_exokay_wr: assert property (CHI5PC_ERR_RSP_EXOKAY_WR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_RSP_EXOKAY_WR::", string'(MODE == 1 ? " RXRSP: " : " TXRSP: "), "The EXOKAY response is only permitted for requests with EXCL asserted."});


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_RETRYACK
  // =====
  property CHI5PC_ERR_RSP_OPCD_RETRYACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_RETRYACK
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI ||
             S_RSP_SRCID_NODE_TYPE_HAS_MN)
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_retryack: assert property (CHI5PC_ERR_RSP_OPCD_RETRYACK) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_RETRYACK: The permitted communicating node pairs for a RetryAck response message are: ICN(HNF, HNI, MN) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_DBIDRESP
  // =====
  property CHI5PC_ERR_RSP_OPCD_DBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_DBIDRESP
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI ||
             S_RSP_SRCID_NODE_TYPE_HAS_MN)
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_dbidresp: assert property (CHI5PC_ERR_RSP_OPCD_DBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_DBIDRESP: The permitted communicating node pairs for a DBIDResp response message are: ICN(HNF, HNI, MN) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_PCRDGRANT
  // =====
  property CHI5PC_ERR_RSP_OPCD_PCRDGRANT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI ||
             S_RSP_SRCID_NODE_TYPE_HAS_MN)
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_pcrdgrant: assert property (CHI5PC_ERR_RSP_OPCD_PCRDGRANT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_PCRDGRANT: The permitted communicating node pairs for a PCrdGrant response message are: ICN(HNF, HNI, MN) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_COMP
  // =====
  property CHI5PC_ERR_RSP_OPCD_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMP
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI ||
             S_RSP_SRCID_NODE_TYPE_HAS_MN)
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_comp: assert property (CHI5PC_ERR_RSP_OPCD_COMP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_COMP: The permitted communicating node pairs for a Comp response message are: ICN(HNF, HNI, MN) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_COMPDBIDRESP
  // =====
  property CHI5PC_ERR_RSP_OPCD_COMPDBIDRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDBIDRESP
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI )
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_compdbidresp: assert property (CHI5PC_ERR_RSP_OPCD_COMPDBIDRESP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_COMPDBIDRESP: The permitted communicating node pairs for a CompDBIDResp response message are: ICN(HNF, HNI) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_READRECEIPT
  // =====
  property CHI5PC_ERR_RSP_OPCD_READRECEIPT; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_READRECEIPT
      |-> (
            (S_RSP_SRCID_NODE_TYPE_HAS_HNF ||
             S_RSP_SRCID_NODE_TYPE_HAS_HNI )
            &&
            ((S_RSP_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (S_RSP_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (S_RSP_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            S_RSP_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_readreceipt: assert property (CHI5PC_ERR_RSP_OPCD_READRECEIPT) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_READRECEIPT: The permitted communicating node pairs for a ReadReceipt response message are: ICN(HNF, HNI, MN) to RNF, RNI, RND; SNI to ICN(HNI)." ));


  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_UPSTREAM
  // =====
  property CHI5PC_ERR_RSP_OPCD_UPSTREAM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({S_RSPFLITV_,S_RSPFLIT_}))
       && S_RSPFLITV_ && |S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] 
       && !NODE_TYPE_IS_ICN
      |-> ( S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_COMPACK) &&
          ( S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPRESP)
            ;
  endproperty
  chi5pc_err_rsp_opcd_upstream: assert property (CHI5PC_ERR_RSP_OPCD_UPSTREAM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_UPSTREAM: Upstream responses must not be CompAck or SnpResp." ));



  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_COMPACK
  // =====
  property CHI5PC_ERR_RSP_OPCD_COMPACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK
      |-> (
            ((M_RSP_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (M_RSP_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (M_RSP_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (M_RSP_TGTID_NODE_TYPE_HAS_HNF ||
             M_RSP_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_compack: assert property (CHI5PC_ERR_RSP_OPCD_COMPACK) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_COMPACK: The permitted communicating node pairs for a CompAck response message are: RNF, RNI, RND to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_SNPRESP
  // =====
  property CHI5PC_ERR_RSP_OPCD_SNPRESP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP
      |-> (
            (M_RSP_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            M_RSP_TGTID_NODE_TYPE_HAS_HNF 
          )
          ||
          (
            ((M_RSP_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (M_RSP_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            M_RSP_TGTID_NODE_TYPE_HAS_MN 
          )
            ;
  endproperty
  chi5pc_err_rsp_opcd_snpresp: assert property (CHI5PC_ERR_RSP_OPCD_SNPRESP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_SNPRESP: The permitted communicating node pairs for a SnpResp response message are: RNF to ICN(HNF); RNF, RND to ICN(MN)." ));



  // =====
  // INDEX:        - CHI5PC_ERR_RSP_OPCD_DOWNSTREAM
  // =====
  property CHI5PC_ERR_RSP_OPCD_DOWNSTREAM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({M_RSPFLITV_,M_RSPFLIT_}))
       && M_RSPFLITV_ && |M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE]
       && !NODE_TYPE_IS_ICN
      |-> ( M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_COMPACK) ||
          ( M_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESP)
            ;
  endproperty
  chi5pc_err_rsp_opcd_downstream: assert property (CHI5PC_ERR_RSP_OPCD_DOWNSTREAM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_RSP_OPCD_DOWNSTREAM: Downstream responses must be CompAck or SnpResp." ));



//------------------------------------------------------------------------------
// INDEX:   7)  DAT channel Checks
//------------------------------------------------------------------------------ 

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_RS
  // =====
  property CHI5PC_ERR_DAT_RESP_RS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  (Current_RDDAT_Info.OpCode == `CHI5PC_READSHARED) 
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == SC) ||
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UC) ||
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UD_PD) ||
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == SD_PD) ;
  endproperty
  chi5pc_err_dat_resp_rs: assert property (CHI5PC_ERR_DAT_RESP_RS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_RS::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field value of the CompData message of a ReadShared transaction must be SC, UC, UD_PD or SD_PD."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_RC
  // =====
  property CHI5PC_ERR_DAT_RESP_RC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  (Current_RDDAT_Info.OpCode == `CHI5PC_READCLEAN) 
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == SC) ||
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UC) ;
  endproperty
  chi5pc_err_dat_resp_rc: assert property (CHI5PC_ERR_DAT_RESP_RC) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_RC::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field value of the CompData message of a ReadClean transaction must be SC or UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_RO
  // =====
  property CHI5PC_ERR_DAT_RESP_RO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  (Current_RDDAT_Info.OpCode == `CHI5PC_READONCE) 
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I); 
  endproperty
  chi5pc_err_dat_resp_ro: assert property (CHI5PC_ERR_DAT_RESP_RO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_RO::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field value of the CompData message of a ReadOnce transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_RNS
  // =====
  property CHI5PC_ERR_DAT_RESP_RNS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  (Current_RDDAT_Info.OpCode == `CHI5PC_READNOSNP) 
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I); 
  endproperty
  chi5pc_err_dat_resp_rns: assert property (CHI5PC_ERR_DAT_RESP_RNS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_RNS::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field value of the CompData message of a ReadNoSnp transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_RU
  // =====
  property CHI5PC_ERR_DAT_RESP_RU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  (Current_RDDAT_Info.OpCode == `CHI5PC_READUNIQUE) 
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UC) ||
           (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UD_PD) ;
  endproperty
  chi5pc_err_dat_resp_ru: assert property (CHI5PC_ERR_DAT_RESP_RU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_RU::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The Resp field value of the CompData message of a ReadUnique transaction must be UC or UD_PD."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_DVM
  // =====
  property CHI5PC_ERR_DAT_RESP_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode == `CHI5PC_DVMOP)
       |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I) ;
  endproperty
  chi5pc_err_dat_resp_dvm: assert property (CHI5PC_ERR_DAT_RESP_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_DVM::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the NonCopyBackWrData message of a DVMOp transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WEF
  // =====
  property CHI5PC_ERR_DAT_RESP_WEF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode == `CHI5PC_WRITEEVICTFULL) 
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == SC) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UC);
  endproperty
  chi5pc_err_dat_resp_wef: assert property (CHI5PC_ERR_DAT_RESP_WEF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WEF::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the CopyBackWrData message of a WriteEvictFull transaction must be I, SC or UC."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WCP
  // =====
  property CHI5PC_ERR_DAT_RESP_WCP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode == `CHI5PC_WRITECLEANPTL) 
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UD_PD);
  endproperty
  chi5pc_err_dat_resp_wcp: assert property (CHI5PC_ERR_DAT_RESP_WCP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WCP::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the CopyBackWrData message of a WriteCleanPtl transaction must be I or UD_PD."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WUP
  // =====
  property CHI5PC_ERR_DAT_RESP_WUP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode == `CHI5PC_WRITEUNIQUEPTL) 
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
       |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I);
  endproperty
  chi5pc_err_dat_resp_wup: assert property (CHI5PC_ERR_DAT_RESP_WUP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WUP::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the NonCopyBackWrData message of a WriteUniquePtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WUF
  // =====
  property CHI5PC_ERR_DAT_RESP_WUF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode == `CHI5PC_WRITEUNIQUEFULL) 
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
       |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I);
  endproperty
  chi5pc_err_dat_resp_wuf: assert property (CHI5PC_ERR_DAT_RESP_WUF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WUF::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the NonCopyBackWrData message of a WriteUniqueFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WBP
  // =====
  property CHI5PC_ERR_DAT_RESP_WBP;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode == `CHI5PC_WRITEBACKPTL) 
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == UD_PD);
  endproperty
  chi5pc_err_dat_resp_wbp: assert property (CHI5PC_ERR_DAT_RESP_WBP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WBP::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the CopyBackWrData message of a WriteBackPtl transaction must be I or UD_PD."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WNSP
  // =====
  property CHI5PC_ERR_DAT_RESP_WNSP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode == `CHI5PC_WRITENOSNPPTL)
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
       |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I);
  endproperty
  chi5pc_err_dat_resp_wnsp: assert property (CHI5PC_ERR_DAT_RESP_WNSP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WNSP::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the NonCopyBackWrData message of a WriteNoSnpPtl transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESP_WNSF
  // =====
  property CHI5PC_ERR_DAT_RESP_WNSF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode == `CHI5PC_WRITENOSNPFULL)
       && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_DATA_ERR)
       |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == I);
  endproperty
  chi5pc_err_dat_resp_wnsf: assert property (CHI5PC_ERR_DAT_RESP_WNSF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESP_WNSF::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The Resp field value of the NonCopyBackWrData message of a WriteNoSnpFull transaction must be I."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_RO
  // =====
  property CHI5PC_ERR_DAT_RESPERR_RO; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match && (Current_RDDAT_Info.OpCode == `CHI5PC_READONCE) 
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] !=CHI5PC_EXCL_OK); 
  endproperty
  chi5pc_err_dat_resperr_ro: assert property (CHI5PC_ERR_DAT_RESPERR_RO) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_RO::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The RespErr field value of the CompData message of a ReadOnce transaction must be OK, DERR or NDERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_RU
  // =====
  property CHI5PC_ERR_DAT_RESPERR_RU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match && (Current_RDDAT_Info.OpCode == `CHI5PC_READUNIQUE) 
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] !=CHI5PC_EXCL_OK); 
  endproperty
  chi5pc_err_dat_resperr_ru: assert property (CHI5PC_ERR_DAT_RESPERR_RU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_RU::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The RespErr field value of the CompData message of a ReadUnique transaction must be OK, DERR or NDERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_DVM
  // =====
  property CHI5PC_ERR_DAT_RESPERR_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode == `CHI5PC_DVMOP)
       |->  ~|WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE];
  endproperty
  chi5pc_err_dat_resperr_dvm: assert property (CHI5PC_ERR_DAT_RESPERR_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_DVM::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The RespErr field value of the NonCopyBackWrData message of a DVMOp transaction must be OK."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_COPYBACK
  // =====
  property CHI5PC_ERR_DAT_RESPERR_COPYBACK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA)
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] == CHI5PC_DATA_ERR) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] == CHI5PC_RESP_OK_EXCL_FAIL);
  endproperty
  chi5pc_err_dat_resperr_copyback: assert property (CHI5PC_ERR_DAT_RESPERR_COPYBACK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_COPYBACK::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The RespErr field value of the CopyBackWrData message of a copyback transaction must be OK or DERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_WRITE
  // =====
  property CHI5PC_ERR_DAT_RESPERR_WRITE; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA) && WRDAT_match && (Current_WRDAT_Info.OpCode != `CHI5PC_DVMOP)
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] == CHI5PC_DATA_ERR) ||
           (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] == CHI5PC_RESP_OK_EXCL_FAIL) ;
  endproperty
  chi5pc_err_dat_resperr_write: assert property (CHI5PC_ERR_DAT_RESPERR_WRITE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_WRITE::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The RespErr field value of the NonCopyBackWrData message of a write transaction must be OK or DERR."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_READ_OK_EXOK
  // =====
  property CHI5PC_ERR_DAT_RESPERR_READ_OK_EXOK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  |Current_RDDAT_Info.DATID && (Current_RDDAT_Info.DATRespErr == CHI5PC_RESP_OK_EXCL_FAIL)
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] !=CHI5PC_EXCL_OK);
  endproperty
  chi5pc_err_dat_resperr_read_ok_exok: assert property (CHI5PC_ERR_DAT_RESPERR_READ_OK_EXOK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_READ_OK_EXOK::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A read transaction cannot have a RespErr field value of RESP_OK_EXCL_FAIL followed by a value of EXOKAY in consecutive CompData messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RESPERR_READ_EXOK_OK
  // =====
  property CHI5PC_ERR_DAT_RESPERR_READ_EXOK_OK; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  |Current_RDDAT_Info.DATID && (Current_RDDAT_Info.DATRespErr ==CHI5PC_EXCL_OK)
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] != CHI5PC_RESP_OK_EXCL_FAIL);
  endproperty
  chi5pc_err_dat_resperr_read_exok_ok: assert property (CHI5PC_ERR_DAT_RESPERR_READ_EXOK_OK) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RESPERR_READ_EXOK_OK::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A read transaction cannot have a RespErr field value of EXOKAY followed by a value of RESP_OK_EXCL_FAIL in consecutive CompData messages."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_RESP_COMP
  // =====
  property CHI5PC_ERR_DAT_RSVD_RESP_COMP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA) && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |-> !((RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b011) || (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b100) || (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b101));
  endproperty
  chi5pc_err_dat_rsvd_resp_comp: assert property (CHI5PC_ERR_DAT_RSVD_RESP_COMP) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_RESP_COMP::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Resp field values 3'b011, 3'b100 and 3'b101 in CompData messages are reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_RESP_WRDATA
  // =====
  property CHI5PC_ERR_DAT_RSVD_RESP_WRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && ((WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA) || (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA))
        && !WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
      |-> !((WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b011) || (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b100) || (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == 3'b101));
  endproperty
  chi5pc_err_dat_rsvd_resp_wrdata: assert property (CHI5PC_ERR_DAT_RSVD_RESP_WRDATA) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_RESP_WRDATA::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Resp field values 3'b011, 3'b100 and 3'b101 in CopyBackWrData and NonCopyBackWrData messages are reserved."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_COPYBACKWRDATA
  // =====
  property CHI5PC_ERR_DAT_CTL_COPYBACKWRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA) 
      |-> (WRDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == 'b0) || (WRDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == Current_WRDAT_Info.TxnID) ;
  endproperty
  chi5pc_err_dat_ctl_copybackwrdata: assert property (CHI5PC_ERR_DAT_CTL_COPYBACKWRDATA) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CTL_COPYBACKWRDATA::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Data flits with opcode CopyBackWrData must have DBID = 'b0 or the TxnID of the originating request."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_NONCOPYBACKWRDATA
  // =====
  property CHI5PC_ERR_DAT_CTL_NONCOPYBACKWRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA) && (Current_WRDAT_Info.OpCode != `CHI5PC_DVMOP)
      |-> (WRDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == 'b0) || (WRDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == Current_WRDAT_Info.TxnID) ;
  endproperty
  chi5pc_err_dat_ctl_noncopybackwrdata: assert property (CHI5PC_ERR_DAT_CTL_NONCOPYBACKWRDATA) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CTL_NONCOPYBACKWRDATA::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Non-DVM data flits with opcode NonCopyBackWrData must have DBID = 'b0 or the TxnID of the originating request."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_VALID_RDDATAID
  // =====
  property CHI5PC_ERR_DAT_VALID_RDDATAID;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match 
      |-> Current_RDDAT_Info.Exp_DATID[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]];
  endproperty
  chi5pc_err_dat_valid_rddataid: assert property (CHI5PC_ERR_DAT_VALID_RDDATAID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_VALID_RDDATAID::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "),  "Invalid DataID value for transaction on read-data flit."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_VALID_WRDATAID
  // =====
  property CHI5PC_ERR_DAT_VALID_WRDATAID;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode != `CHI5PC_DVMOP) 
      |-> Current_WRDAT_Info.Exp_DATID[WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]];
  endproperty
  chi5pc_err_dat_valid_wrdataid: assert property (CHI5PC_ERR_DAT_VALID_WRDATAID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_VALID_WRDATAID::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Invalid DataID value for transaction on write-data flit."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_VALID_WRBE
  // =====
  logic [CHI5PC_DAT_FLIT_BE_WIDTH-1:0] Current_Exp_BE;
  always_comb
  begin
    if (!Chi5_in.SRESETn || !WRDATFLITV_)
    begin
      Current_Exp_BE = 'b0;
    end
    else
    begin
      Current_Exp_BE = 'b0;
      case (DAT_FLIT_WIDTH)
        `CHI5PC_128B_DAT_FLIT_WIDTH:
        begin
          Current_Exp_BE = Current_WRDAT_Info.Exp_BE.BE[WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]];
        end
        `CHI5PC_256B_DAT_FLIT_WIDTH:
        begin
          Current_Exp_BE = {Current_WRDAT_Info.Exp_BE.BE[WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]+1],Current_WRDAT_Info.Exp_BE.BE[WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]]};
        end
        `CHI5PC_512B_DAT_FLIT_WIDTH:
        begin
          Current_Exp_BE = Current_WRDAT_Info.Exp_BE;
        end
        default:
          Current_Exp_BE = 'b0;
      endcase
    end
  end


  property CHI5PC_ERR_DAT_VALID_WRBE;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn 
       && WRDATFLITV_ && WRDAT_match && (`IS_WRITE_(Current_WRDAT_Info) && ~(`IS_DVMOP_(Current_WRDAT_Info)))
      |-> ~|(~Current_Exp_BE & WRDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_BE_MSB:Chi5_in.CHI5PC_DAT_FLIT_BE_LSB]); 
  endproperty
  chi5pc_err_dat_valid_wrbe: assert property (CHI5PC_ERR_DAT_VALID_WRBE) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_VALID_WRBE::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Invalid BE value for transaction on write-data flit." });

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_VALID_WRBE_DVM
  // =====
  property CHI5PC_ERR_DAT_VALID_WRBE_DVM;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn 
       && WRDATFLITV_ && WRDAT_match && `IS_DVMOP_(Current_WRDAT_Info)
      |-> &WRDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_BE_LSB + 7:Chi5_in.CHI5PC_DAT_FLIT_BE_LSB] &&
          ~|WRDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_BE_MSB : Chi5_in.CHI5PC_DAT_FLIT_BE_LSB + 8] ; 
  endproperty
  chi5pc_err_dat_valid_wrbe_dvm: assert property (CHI5PC_ERR_DAT_VALID_WRBE_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_VALID_WRBE_DVM::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "BE[7:0] must be set for DVMOp write data and all other BE bits must be 'b0." });


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_WRBE_X
  // =====
  property CHI5PC_ERR_DAT_WRBE_X;
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn 
       && WRDATFLITV_ && WRDAT_match && `IS_WRITE_(Current_WRDAT_Info)
      |-> !($isunknown(WRDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_BE_MSB:Chi5_in.CHI5PC_DAT_FLIT_BE_LSB])); 
  endproperty
  chi5pc_err_dat_wrbe_x: assert property (CHI5PC_ERR_DAT_WRBE_X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_WRBE_X::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "A value of X is not allowed in the BE field of a write-data flit." });


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDDATAID
  // =====
  property CHI5PC_ERR_DAT_RDDATAID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match
      |-> ~Current_RDDAT_Info.DATID[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]];
  endproperty
  chi5pc_err_dat_rddataid: assert property (CHI5PC_ERR_DAT_RDDATAID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDDATAID::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "DataID value cannot be issued more than once on read-data flit for the same transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_WRDATAID
  // =====
  property CHI5PC_ERR_DAT_WRDATAID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match &&  (Current_WRDAT_Info.OpCode != `CHI5PC_DVMOP)
      |-> ~Current_WRDAT_Info.DATID[WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]];
  endproperty
  chi5pc_err_dat_wrdataid: assert property (CHI5PC_ERR_DAT_WRDATAID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_WRDATAID::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "DataID value cannot be issued more than once on write-data flit for the same transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CTL_DVM
  // =====
  property CHI5PC_ERR_DAT_CTL_DVM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode ==  `CHI5PC_DVMOP)
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA 
          && (~|WRDATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE] || (WRDATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE] == Current_WRDAT_Info.CCID))
          && (~|WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]  || (WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == Current_WRDAT_Info.CCID))
          ;
  endproperty
  chi5pc_err_dat_ctl_dvm: assert property (CHI5PC_ERR_DAT_CTL_DVM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CTL_DVM::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Only NonCopyBackWrData can be returned for a DVM operation. DataID and CCID must be 'b0, or Addr[5:4] of the original request."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_NCBW_WNS
  // =====
  property CHI5PC_ERR_DAT_NCBW_WNS; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && ((Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITENOSNPFULL) || (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITENOSNPPTL))
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA;
  endproperty
  chi5pc_err_dat_ncbw_wns: assert property (CHI5PC_ERR_DAT_NCBW_WNS) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_NCBW_WNS::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The data message of WriteNoSnp* transactions must be NonCopyBackWrData."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_NCBW_WU
  // =====
  property CHI5PC_ERR_DAT_NCBW_WU; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && ((Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEUNIQUEFULL) || (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEUNIQUEPTL))
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA;
  endproperty
  chi5pc_err_dat_ncbw_wu: assert property (CHI5PC_ERR_DAT_NCBW_WU) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_NCBW_WU::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The data message of WriteUnique* transactions must be NonCopyBackWrData."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CBW_WB
  // =====
  property CHI5PC_ERR_DAT_CBW_WB; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && ((Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEBACKFULL) || (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEBACKPTL))
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA;
  endproperty
  chi5pc_err_dat_cbw_wb: assert property (CHI5PC_ERR_DAT_CBW_WB) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CBW_WB::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The data message of WriteBack* transactions must be CopyBackWrData."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CBW_WEF
  // =====
  property CHI5PC_ERR_DAT_CBW_WEF; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEEVICTFULL) 
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA;
  endproperty
  chi5pc_err_dat_cbw_wef: assert property (CHI5PC_ERR_DAT_CBW_WEF) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CBW_WEF::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The data message of WriteEvictFull transactions must be CopyBackWrData."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CBW_WC
  // =====
  property CHI5PC_ERR_DAT_CBW_WC; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && ((Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITECLEANFULL) || (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITECLEANPTL))
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA;
  endproperty
  chi5pc_err_dat_cbw_wc: assert property (CHI5PC_ERR_DAT_CBW_WC) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CBW_WC::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The data message of WriteClean* transactions must be CopyBackWrData."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_ORDER
  // =====
  property CHI5PC_ERR_DAT_ORDER; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
        && WRDATFLITV_ &&  (WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA || 
                            WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA)  
       |-> ((Current_WRDAT_Info.RspOpCode1 ==  `CHI5PC_DBIDRESP) ||
           (Current_WRDAT_Info.RspOpCode2 ==  `CHI5PC_DBIDRESP) ||
               (Current_WRDAT_Info.RspOpCode1 ==  `CHI5PC_COMPDBIDRESP));

  endproperty
  chi5pc_err_dat_order: assert property (CHI5PC_ERR_DAT_ORDER) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_ORDER::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "NonCopyBackWrData and CopyBackWrData can only be issued after DBIDResp or CompDBIDResp."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CONST_RESP_RD
  // =====
  property CHI5PC_ERR_DAT_CONST_RESP_RD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
        && RDDAT_match && RDDATFLITV_ &&  |Current_RDDAT_Info.DATID
       |-> RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == Current_RDDAT_Info.DATResp;

  endproperty
  chi5pc_err_dat_const_resp_rd: assert property (CHI5PC_ERR_DAT_CONST_RESP_RD) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CONST_RESP_RD::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Resp field values are required to be constant for all read-data flits within a transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CONST_RESP_WR
  // =====
  property CHI5PC_ERR_DAT_CONST_RESP_WR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
        && WRDAT_match && WRDATFLITV_ &&  |Current_WRDAT_Info.DATID
       |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == Current_WRDAT_Info.DATResp;

  endproperty
  chi5pc_err_dat_const_resp_wr: assert property (CHI5PC_ERR_DAT_CONST_RESP_WR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CONST_RESP_WR::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Resp field values are required to be constant for all write-data flits within a transaction."});



  // =====
  // INDEX:        - CHI5PC_ERR_DAT_EXOKAY_WR
  // =====
  property CHI5PC_ERR_DAT_EXOKAY_WR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (WRDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] ==CHI5PC_EXCL_OK)
      |->   Current_WRDAT_Info.Excl;
  endproperty
  chi5pc_err_dat_exokay_wr: assert property (CHI5PC_ERR_DAT_EXOKAY_WR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_EXOKAY_WR::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The EXOKAY response is only permitted for requests with EXCL asserted."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_EXOKAY_RD
  // =====
  property CHI5PC_ERR_DAT_EXOKAY_RD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match && (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_RANGE] ==CHI5PC_EXCL_OK)
      |->  Current_RDDAT_Info.Excl; 
  endproperty
  chi5pc_err_dat_exokay_rd: assert property (CHI5PC_ERR_DAT_EXOKAY_RD) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_EXOKAY_RD::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The EXOKAY response is only permitted for requests with EXCL asserted."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_WRCCID
  // =====
  property CHI5PC_ERR_DAT_WRCCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match
      |->  (WRDATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE] == Current_WRDAT_Info.CCID) ||
           ((Current_WRDAT_Info.OpCode == `CHI5PC_DVMOP) && ~|WRDATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE]);
  endproperty
  chi5pc_err_dat_wrccid: assert property (CHI5PC_ERR_DAT_WRCCID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_WRCCID::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "The CCID field of a write-data flit must always correspond to bits 5:4 of the transaction's address - except for DVMOp transactions where CCID is allowed to be 'b0."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDCCID
  // =====
  property CHI5PC_ERR_DAT_RDCCID; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match 
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_CCID_RANGE] == Current_RDDAT_Info.CCID);
  endproperty
  chi5pc_err_dat_rdccid: assert property (CHI5PC_ERR_DAT_RDCCID) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDCCID::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "The CCID field of a read-data flit must always correspond to bits 5:4 of the transaction's address."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_WRDATAID_256
  // =====
  property CHI5PC_ERR_DAT_RSVD_WRDATAID_256; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) && WRDAT_match &&  ~`IS_DVMOP_(Current_WRDAT_Info)
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_LSB] == 1'b0;
  endproperty
  chi5pc_err_dat_rsvd_wrdataid_256: assert property (CHI5PC_ERR_DAT_RSVD_WRDATAID_256) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_WRDATAID_256::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "When the data width is 256b the DataID field of a write data flit cannot be reserved values 2'b01 or 2'b11."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_WRDATAID_512
  // =====
  property CHI5PC_ERR_DAT_RSVD_WRDATAID_512; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH) && WRDAT_match &&  ~`IS_DVMOP_(Current_WRDAT_Info)
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == 2'b00;
  endproperty
  chi5pc_err_dat_rsvd_wrdataid_512: assert property (CHI5PC_ERR_DAT_RSVD_WRDATAID_512) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_WRDATAID_512::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "When the data width is 512b the DataID field of a write data flit cannot be reserved values 2'b01, 2'b10 or 2'b11."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_RDDATAID_256
  // =====
  property CHI5PC_ERR_DAT_RSVD_RDDATAID_256; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && (DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) && RDDAT_match 
      |-> RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_LSB] == 1'b0;
  endproperty
  chi5pc_err_dat_rsvd_rddataid_256: assert property (CHI5PC_ERR_DAT_RSVD_RDDATAID_256) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_RDDATAID_256::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "When the data width is 256b the DataID field of a read data flit cannot be reserved values 2'b01 or 2'b11."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RSVD_RDDATAID_512
  // =====
  property CHI5PC_ERR_DAT_RSVD_RDDATAID_512; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH) && RDDAT_match 
      |-> RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == 2'b00;
  endproperty
  chi5pc_err_dat_rsvd_rddataid_512: assert property (CHI5PC_ERR_DAT_RSVD_RDDATAID_512) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RSVD_RDDATAID_512::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "When the data width is 512b the DataID field of a read data flit cannot be reserved values 2'b01, 2'b10 or 2'b11."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDDATA127TO0_X
  // =====
  property CHI5PC_ERR_DAT_RDDATA127TO0_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  RDDATFLITV_ && 
      (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA)
      |-> (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][0] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+7:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][1] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+15:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+8]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][2] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+23:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+16]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][3] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+31:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+24]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][4] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+39:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+32]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][5] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+47:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+40]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][6] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+55:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+48]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][7] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+63:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+56]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][8] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+71:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+64]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][9] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+79:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+72]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][10] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+87:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+80]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][11] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+95:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+88]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][12] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+103:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+96]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][13] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+111:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+104]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][14] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+119:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+112]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE]][15] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+127:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+120]) :1'b1) ;
  endproperty
  chi5pc_err_dat_rddata127to0_x:  assert property (CHI5PC_ERR_DAT_RDDATA127TO0_X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDDATA127TO0_X::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A value of X is not allowed on valid byte lanes of read data."});



  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDDATA255TO128_X
  // =====
  if ((DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) || (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH)) 
  begin: rxdatflit_255_to_128_x
  property CHI5PC_ERR_DAT_RDDATA255TO128_X;
    @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
      `CHI5_SVA_RSTn &&  RDDATFLITV_ && 
      (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA)
      |-> (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][0] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+135:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+128]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][1] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+143:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+136]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][2] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+151:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+144]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][3] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+159:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+152]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][4] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+167:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+160]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][5] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+175:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+168]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][6] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+183:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+176]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][7] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+191:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+184]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][8] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+199:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+192]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][9] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+207:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+200]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][10] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+215:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+208]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][11] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+223:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+216]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][12] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+231:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+224]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][13] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+239:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+232]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][14] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+247:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+240]) :1'b1) &&
          (Current_RDDAT_Info.Exp_BE.BE[RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE+1]][15] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+255:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+248]) :1'b1) ;
  endproperty
  chi5pc_err_dat_rddata255to128_x:  assert property (CHI5PC_ERR_DAT_RDDATA255TO128_X) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDDATA255TO128_X::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A value of X is not allowed on valid byte lanes of read data."});
  end

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDDATA511TO256_X
  // =====
  generate 
    if (DAT_FLIT_WIDTH == `CHI5PC_512B_DAT_FLIT_WIDTH) 
    begin: txdatflit_511_to_256_x
    property CHI5PC_ERR_DAT_RDDATA511TO256_X;
      @(posedge `CHI5_SVA_CLK)  disable iff (!ErrorOn_Data_X)
        `CHI5_SVA_RSTn &&  RDDATFLITV_ &&  
        (RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA)
        |-> (Current_RDDAT_Info.Exp_BE.BE[2][0] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+263:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+256]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][1] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+271:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+264]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][2] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+279:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+272]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][3] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+287:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+280]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][4] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+295:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+288]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][5] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+303:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+296]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][6] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+311:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+304]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][7] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+319:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+312]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][8] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+327:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+320]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][9] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+335:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+328]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][10] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+343:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+336]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][11] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+351:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+344]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][12] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+359:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+352]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][13] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+367:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+360]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][14] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+375:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+368]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[2][15] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+383:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+376]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][0] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+391:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+384]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][1] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+399:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+392]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][2] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+407:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+400]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][3] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+415:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+408]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][4] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+423:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+416]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][5] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+431:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+424]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][6] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+439:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+432]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][7] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+447:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+440]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][8] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+455:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+448]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][9] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+463:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+456]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][10] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+471:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+464]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][11] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+479:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+472]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][12] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+487:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+480]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][13] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+495:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+488]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][14] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+503:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+496]) :1'b1) &&
            (Current_RDDAT_Info.Exp_BE.BE[3][15] ? !$isunknown(RDDATFLIT_[Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+511:Chi5_in.CHI5PC_DAT_FLIT_DATA_LSB+504]) :1'b1) ;
    endproperty
    chi5pc_err_dat_rddata511to256_x:  assert property (CHI5PC_ERR_DAT_RDDATA511TO256_X) else 
      `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDDATA511TO256_X::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A value of X is not allowed on valid byte lanes of read data."});
    end
  endgenerate


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDRESP_UNIFORM
  // =====
  property CHI5PC_ERR_DAT_RDRESP_UNIFORM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match &&  |Current_RDDAT_Info.DATID
      |->  (RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_RANGE] == Current_RDDAT_Info.DATResp) ;
  endproperty
  chi5pc_err_dat_rdresp_uniform: assert property (CHI5PC_ERR_DAT_RDRESP_UNIFORM) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDRESP_UNIFORM::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "CompData Resp values must be consistent for every data flit of a transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_BE_FULL
  // =====
  property CHI5PC_ERR_DAT_BE_FULL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && 
       ( (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEBACKFULL) ||
         (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITECLEANFULL) ||
         (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEEVICTFULL) ||
         (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITENOSNPFULL) ||
         (Current_WRDAT_Info.OpCode ==  `CHI5PC_WRITEUNIQUEFULL))
      |-> (DAT_FLIT_WIDTH == `CHI5PC_128B_DAT_FLIT_WIDTH) ? &WRDATFLIT_[`CHI5PC_128B_DAT_FLIT_BE_RANGE] : 
           (DAT_FLIT_WIDTH == `CHI5PC_256B_DAT_FLIT_WIDTH) ? &WRDATFLIT_[`CHI5PC_256B_DAT_FLIT_BE_RANGE] :
           &WRDATFLIT_[`CHI5PC_512B_DAT_FLIT_BE_RANGE];
  endproperty
  chi5pc_err_dat_be_full: assert property (CHI5PC_ERR_DAT_BE_FULL) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_BE_FULL::", string'(MODE == 1 ? " TXDAT: " : " RXDAT: "), "Data for WriteBackFull, WriteCleanFull, WriteEvictFull, WriteNoSnpFull and WriteUniqueFull cannot have partial ByteEnable."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_RDRESP_DIRTY
  // =====
  property CHI5PC_ERR_DAT_RDRESP_DIRTY; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match  
       && !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESPERR_MSB]
       && ((Current_RDDAT_Info.OpCode ==  `CHI5PC_READNOSNP) || 
         (Current_RDDAT_Info.OpCode ==  `CHI5PC_READONCE) ||
         (Current_RDDAT_Info.OpCode ==  `CHI5PC_READCLEAN) )
      |-> !RDDATFLIT_[`CHI5PC_DAT_FLIT_RESP_MSB];
  endproperty
  chi5pc_err_dat_rdresp_dirty: assert property (CHI5PC_ERR_DAT_RDRESP_DIRTY) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_RDRESP_DIRTY::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Data flits with PassDirty in the Resp field are not valid for ReadClean, ReadOnce and ReadNoSnp transactions."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_WRAPORDER_WR
  // =====
  property CHI5PC_ERR_DAT_WRAPORDER_WR; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDAT_match && (Current_WRDAT_Info.OpCode != `CHI5PC_DVMOP) && (MODE == 1) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
       && (DAT_FLIT_WIDTH != `CHI5PC_512B_DAT_FLIT_WIDTH)
      |-> WRDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == Chi5_in.Next_DATID(Current_WRDAT_Info);
  endproperty
  chi5pc_err_dat_wraporder_wr: assert property (CHI5PC_ERR_DAT_WRAPORDER_WR) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_WRAPORDER_WR: Write data must be sent in Critical-Chunk first wrap-order."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_WRAPORDER_RD
  // =====
  property CHI5PC_ERR_DAT_WRAPORDER_RD; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDAT_match && (Current_RDDAT_Info.OpCode != `CHI5PC_DVMOP) && (MODE == 0) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
       && (DAT_FLIT_WIDTH != `CHI5PC_512B_DAT_FLIT_WIDTH)
      |-> RDDATFLIT_[`CHI5PC_DAT_FLIT_DATAID_RANGE] == Chi5_in.Next_DATID(Current_RDDAT_Info);
  endproperty
  chi5pc_err_dat_wraporder_rd: assert property (CHI5PC_ERR_DAT_WRAPORDER_RD) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_WRAPORDER_RD: Read data must be sent in Critical-Chunk first wrap-order."));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_DBID_ALLOCATION
  // =====
  property CHI5PC_ERR_DAT_DBID_ALLOCATION; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_
      |-> ~|DAT_DBID_ALLOC_ERR_vector;
  endproperty
  chi5pc_err_dat_dbid_allocation: assert property (CHI5PC_ERR_DAT_DBID_ALLOCATION) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_DBID_ALLOCATION::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "A DBID allocation must not be made for a buffer that is allocated to another transaction."});


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_CONST_DBID_READ
  // =====
  property CHI5PC_ERR_DAT_CONST_DBID_READ; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && |Current_RDDAT_Info.DATID && |RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] && Current_RDDAT_Info.ExpCompAck
      |-> RDDATFLIT_[`CHI5PC_DAT_FLIT_DBID_RANGE] == Current_RDDAT_Info.DBID;
  endproperty
  chi5pc_err_dat_const_dbid_read: assert property (CHI5PC_ERR_DAT_CONST_DBID_READ) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_DAT_CONST_DBID_READ::", string'(MODE == 1 ? " RXDAT: " : " TXDAT: "), "Read data DBID values must remain consistent from one beat to the next."});

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_COMPDATA
  // =====
  property CHI5PC_ERR_DAT_OPCD_COMPDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA
      |-> (
            (RDDAT_SRCID_NODE_TYPE_HAS_HNF ||
             RDDAT_SRCID_NODE_TYPE_HAS_HNI )
            &&
            ((RDDAT_TGTID_NodeType == eChi5PCDevType'(RNF)) ||
            (RDDAT_TGTID_NodeType == eChi5PCDevType'(RNI)) ||
            (RDDAT_TGTID_NodeType == eChi5PCDevType'(RND))) 
          )
          ||
          (
            (RDDAT_SRCID_NodeType == eChi5PCDevType'(SNF)) 
            &&
            RDDAT_TGTID_NODE_TYPE_HAS_HNF  
          )
          ||
          (
            (RDDAT_SRCID_NodeType == eChi5PCDevType'(SNI)) 
            &&
            RDDAT_TGTID_NODE_TYPE_HAS_HNI  
          )
            ;
  endproperty
  chi5pc_err_dat_opcd_compdata: assert property (CHI5PC_ERR_DAT_OPCD_COMPDATA) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_COMPDATA: The permitted communicating node pairs for a CompData data message are: ICN(HNF, HNI) to RNF, RNI, RND; SNF to ICN(HNF); SNI to ICN(HNI)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_UPSTREAM
  // =====
  property CHI5PC_ERR_DAT_OPCD_UPSTREAM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({RDDATFLITV_,RDDATFLIT_}))
       && RDDATFLITV_ && |RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
       && !NODE_TYPE_IS_ICN
      |-> ( RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COMPDATA);
  endproperty
  chi5pc_err_dat_opcd_upstream: assert property (CHI5PC_ERR_DAT_OPCD_UPSTREAM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_UPSTREAM: Upstream data messages must be CompData." ));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_COPYBACKWRDATA
  // =====
  property CHI5PC_ERR_DAT_OPCD_COPYBACKWRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA
      |-> (
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            (WRDAT_TGTID_NODE_TYPE_HAS_HNF || 
            WRDAT_TGTID_NODE_TYPE_HAS_HNI)
          )
            ;
  endproperty
  chi5pc_err_dat_opcd_copybackwrdata: assert property (CHI5PC_ERR_DAT_OPCD_COPYBACKWRDATA) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_COPYBACKWRDATA: The permitted communicating node pairs for a CopyBackWrData data message are: RNF to ICN(HNF, HNI)." ));

  // =====
  // INDEX:        - CHI5PC_REC_DAT_OPCD_COPYBACKWRDATA
  // =====
  property CHI5PC_REC_DAT_OPCD_COPYBACKWRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_COPYBACKWRDATA
      |-> (
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            WRDAT_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_rec_dat_opcd_copybackwrdata: assert property (CHI5PC_REC_DAT_OPCD_COPYBACKWRDATA) else 
    `ARM_CHI5_PC_MSG_WARN(string'("CHI5PC_REC_DAT_OPCD_COPYBACKWRDATA: The expected communicating node pairs for a CopyBackWrData data message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_NONCOPYBACKWRDATA
  // =====
  property CHI5PC_ERR_DAT_OPCD_NONCOPYBACKWRDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_NONCOPYBACKWRDATA
      |-> (
            ((WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RNI)) ||
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            (WRDAT_TGTID_NODE_TYPE_HAS_HNF ||
             WRDAT_TGTID_NODE_TYPE_HAS_HNI )
          )
          ||
          (
            ((WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) ||
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RND))) 
            &&
            WRDAT_TGTID_NODE_TYPE_HAS_MN 
          )
          ||
          (
            WRDAT_SRCID_NODE_TYPE_HAS_HNF  
            &&
            (WRDAT_TGTID_NodeType == eChi5PCDevType'(SNF)) 
          )
          ||
          (
            WRDAT_SRCID_NODE_TYPE_HAS_HNI  
            &&
            (WRDAT_TGTID_NodeType == eChi5PCDevType'(SNI)) 
          )
            ;
  endproperty
  chi5pc_err_dat_opcd_noncopybackwrdata: assert property (CHI5PC_ERR_DAT_OPCD_NONCOPYBACKWRDATA) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_NONCOPYBACKWRDATA: The permitted communicating node pairs for a NonCopyBackWrData data message are: RNF, RNI, RND to ICN(HNF, HNI); RNF, RND to ICN(MN); ICN(HNF) to SNF; ICN(HNI) to SNI." ));


  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_SNPRESPDATA
  // =====
  property CHI5PC_ERR_DAT_OPCD_SNPRESPDATA; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATA
      |-> (
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            WRDAT_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_err_dat_opcd_snprespdata: assert property (CHI5PC_ERR_DAT_OPCD_SNPRESPDATA) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_SNPRESPDATA: The permitted communicating node pairs for a SnpRespData data message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_SNPRESPDATAPTL
  // =====
  property CHI5PC_ERR_DAT_OPCD_SNPRESPDATAPTL; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] == `CHI5PC_SNPRESPDATAPTL
      |-> (
            (WRDAT_SRCID_NodeType == eChi5PCDevType'(RNF)) 
            &&
            WRDAT_TGTID_NODE_TYPE_HAS_HNF
          )
            ;
  endproperty
  chi5pc_err_dat_opcd_snprespdataptl: assert property (CHI5PC_ERR_DAT_OPCD_SNPRESPDATAPTL) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_SNPRESPDATAPTL: The permitted communicating node pairs for a SnpRespDataPtl data message are: RNF to ICN(HNF)." ));

  // =====
  // INDEX:        - CHI5PC_ERR_DAT_OPCD_DOWNSTREAM
  // =====
  property CHI5PC_ERR_DAT_OPCD_DOWNSTREAM; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({WRDATFLITV_,WRDATFLIT_}))
       && WRDATFLITV_ && |WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE]
       && !NODE_TYPE_IS_ICN
      |-> ( WRDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] != `CHI5PC_COMPDATA);
  endproperty
  chi5pc_err_dat_opcd_downstream: assert property (CHI5PC_ERR_DAT_OPCD_DOWNSTREAM) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_DAT_OPCD_DOWNSTREAM: Downstream data messages must not be CompData." ));


  
    
  //------------------------------------------------------------------------------
  // INDEX:   8)  SNP Channel checks
  //------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_SNP_HAZARD_RXSNP
  // =====
  property CHI5PC_ERR_SNP_HAZARD_RXSNP; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,RXSNP_Addr_NS_haz_vector}))
        && SNPFLITV_ && (NODE_TYPE == eChi5PCDevType'(RNF)) && |SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE]
      |-> ~|RXSNP_Addr_NS_haz_vector;
  endproperty
  chi5pc_err_snp_hazard_rxsnp: assert property (CHI5PC_ERR_SNP_HAZARD_RXSNP) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_SNP_HAZARD_RXSNP: An RNF must not receive a snoop to a cacheline address for which it has an outstanding transaction that has received a Comp response."));


  // =====
  // INDEX:        - CHI5PC_ERR_SNP_REQATTR
  // =====
  property CHI5PC_ERR_SNP_REQATTR; 
    @(posedge `CHI5_SVA_CLK) disable iff (!ErrorOn_SW)
       `CHI5_SVA_RSTn && !($isunknown({SNPFLITV_,SNPFLIT_}))
       && SNPFLITV_
       && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPLINKFLIT)
       && (SNPFLIT_[`CHI5PC_SNP_FLIT_OPCODE_RANGE] != `CHI5PC_SNPDVMOP)
      |-> ~|SNP_Attr_CLASH_vector;
  endproperty
  chi5pc_err_snp_reqattr: assert property (CHI5PC_ERR_SNP_REQATTR) else 
    `ARM_CHI5_PC_MSG_ERR({"CHI5PC_ERR_SNP_REQATTR::", string'(MODE == 1 ? " RXSNP: " : " TXSNP: "), "All nodes must maintain a consistent view of the attributes of any region of memory. A Snoop request has been issued with memory or snoop attributes that differ from an outstanding request to the same region."});


//------------------------------------------------------------------------------
// INDEX:   9)  SACTIVE checks
//------------------------------------------------------------------------------ 
  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXSACTIVE_REQ_TX
  // =====
  property CHI5PC_ERR_LNK_TXSACTIVE_REQ_TX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({in_Flight_vector,REQFLITV_,REQFLIT_}))
       && ((REQFLITV_ && |REQFLIT_[`CHI5PC_REQ_FLIT_OPCODE_RANGE]) || |Info_Alloc_vector ) && (MODE == 1) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
      |->  SACTIVE_;
  endproperty
  chi5pc_err_lnk_txsactive_req_tx: assert property (CHI5PC_ERR_LNK_TXSACTIVE_REQ_TX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSACTIVE_REQ_TX: TXSACTIVE must be asserted if the protocol layer is active or TXREQFLITV is high."));

  // =====
  // INDEX:        - CHI5PC_ERR_LNK_TXSACTIVE_REQ_RX
  // =====
  property CHI5PC_ERR_LNK_TXSACTIVE_REQ_RX; 
    @(posedge `CHI5_SVA_CLK)
       `CHI5_SVA_RSTn && !($isunknown({in_Flight_vector,Has_no_RSP1_or_data_vector,S_RSPFLITV_,RDDATFLITV_})) && ((PCMODE == LOCAL) || (PCMODE == NORACE))
       && ((S_RSPFLITV_ && |S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] && (S_RSP_match || (S_RSPFLIT_[`CHI5PC_RSP_FLIT_OPCODE_RANGE] == `CHI5PC_PCRDGRANT))) || 
           (RDDATFLITV_ && |RDDATFLIT_[`CHI5PC_DAT_FLIT_OPCODE_RANGE] && RDDAT_match) ||
           |txactive_vector ||
            |in_Retry_vector ||
            |PCrd_OS)
            && (MODE == 0)
      |->  SACTIVE_;
  endproperty
  chi5pc_err_lnk_txsactive_req_rx: assert property (CHI5PC_ERR_LNK_TXSACTIVE_REQ_RX) else 
    `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_LNK_TXSACTIVE_REQ_RX: For received requests TXSACTIVE must be asserted no later than the first data or response flit."));

//------------------------------------------------------------------------------
// INDEX:   10)  End of simulation checks
//------------------------------------------------------------------------------ 

final
begin
  `ifndef CHI5PC_EOS_OFF
  $display ("Executing CHI End Of Simulation transaction checks");
  // =====
  // INDEX:        - CHI5PC_ERR_EOS_TRXN
  // =====
  //property CHI5PC_ERR_EOS_TRXN;
  if (!($isunknown(Info_Alloc_vector)))
  chi5pc_err_eos_trxn:
    assert (~|in_Flight_vector) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_TRXN: Outstanding transactions at end of simulation."));
  
  // =====
  // INDEX:        - CHI5PC_ERR_EOS_RETRY
  // =====
  //property CHI5PC_ERR_EOS_RETRY;
  if (!($isunknown(Info_Alloc_vector)) && !PCRDRETURN)
  chi5pc_err_eos_retry:
    assert (~|in_Retry_vector) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_RETRY: Outstanding retries at end of simulation."));

  // =====
  // INDEX:        - CHI5PC_ERR_EOS_PCRD
  // =====
  //property CHI5PC_ERR_EOS_PCRD;
  if (!($isunknown(Info_Alloc_vector)))
  chi5pc_err_eos_pcrd:
    assert ( ~|PCrd_OS ) else 
      `ARM_CHI5_PC_MSG_ERR(string'("CHI5PC_ERR_EOS_PCRD: Outstanding protocol credits at end of simulation."));
  `endif
end
//------------------------------------------------------------------------------
// INDEX:   11) Clear Verilog Defines
//------------------------------------------------------------------------------
// Clock and Reset
  `undef CHI5_AUX_CLK
  `undef CHI5_AUX_RSTn
  `undef CHI5_SVA_CLK
  `undef CHI5_SVA_RSTn

//------------------------------------------------------------------------------
// INDEX:   12) End of module
//------------------------------------------------------------------------------

endmodule // Chi5PC_FlitTrace 

//------------------------------------------------------------------------------
// INDEX:
// INDEX: End of File
//------------------------------------------------------------------------------

`endif
