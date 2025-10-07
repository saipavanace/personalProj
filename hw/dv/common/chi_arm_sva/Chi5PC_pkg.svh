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
//  File Revision       : 179045
//
//  Date                :  2014-08-20 14:24:28 +0100 (Wed, 20 Aug 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             :Applies enumeration to info in the flit trace to ease debug
// 
//------------------------------------------------------------------------------
  // Defines all possible values for Chi5 interface types
  package Chi5PC_pkg;
  `include "Chi5PC_Chi5_defines.v"//the flit content definition
  `include "Chi5PC_Chi5_flit_defines.svh"//enums of flit content and the struct

  typedef enum bit[3:0]{ RNF, RNI, RND, HNF, HNI, SNI, SNF, MN, HNI_MN, HNF_MN, HNF_HNI, HNF_HNI_MN} eChi5PCDevType;
  typedef enum bit[1:0]{ LOCAL = 2'b00, MIRROR = 2'b01, MIDPOINT = 2'b10, NORACE = 2'b11} eChi5PCMode;
  typedef enum bit[2:0]{ 
    I  = 3'b000,
    SC = 3'b001,
    UC = 3'b010,
    UD_PD = 3'b110,
    SD_PD = 3'b111
    } Chi5PCRespType;
  
  typedef enum bit[2:0]{ 
    snp_I  = 3'b000,
    snp_SC = 3'b001,
    snp_UC_UD = 3'b010,
    snp_SD = 3'b011,
    snp_I_PD  = 3'b100,
    snp_SC_PD = 3'b101,
    snp_UC_PD = 3'b110
    } Chi5PCSnpRespType;

  typedef struct packed {
     eChi5PCReqOp OpCode;
     logic PCrdGrnt;
     logic [`CHI5PC_REQ_FLIT_SRCID_WIDTH:0] Ref_ID;
     logic [`CHI5PC_SNP_FLIT_TXNID_WIDTH-1:0] TxnID;
     logic Retried;
     logic [`CHI5PC_REQ_FLIT_PCRDTYPE_WIDTH-1:0]PCrdType;
  } Chi5PC_Ret_Crdgnt_Info;

  function integer clogb2 (input integer n);
    begin
      for (clogb2=0; n>0; clogb2=clogb2+1)
        n = n >> 1;
    end
  endfunction
  endpackage : Chi5PC_pkg


