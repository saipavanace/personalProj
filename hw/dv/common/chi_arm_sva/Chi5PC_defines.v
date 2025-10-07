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
//  File Revision       : 175626
//
//  Date                :  2014-06-27 12:03:33 +0100 (Fri, 27 Jun 2014)
//
//  Release Information : BP066-BU-01000-r0p0-00lac0
//
//------------------------------------------------------------------------------
//  Purpose             : Chi5PC macro defines
//                          
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
  `ifndef ARM_CHI5_PC_MSG_ERR
    `define ARM_CHI5_PC_MSG_ERR(label) $error({label})
  `endif

  `ifndef ARM_CHI5_PC_MSG_WARN
    `define ARM_CHI5_PC_MSG_WARN(label) $warning({label})
  `endif



  `ifndef CHI5PC_HELPER_FUNCTIONS
     `define CHI5PC_HELPER_FUNCTIONS
      `define IS_READ_(Current_info) ((Current_info.OpCode <= `CHI5PC_READUNIQUE) && (Current_info.OpCode != `CHI5PC_REQLINKFLIT) && (Current_info.OpCode != `CHI5PC_PCRDRETURN) )
      `define IS_WRITE_(Current_info) ((Current_info.OpCode >= `CHI5PC_WRITEEVICTFULL) && (Current_info.OpCode <= `CHI5PC_WRITENOSNPFULL))
      `define IS_DVMOP_(Current_info) (Current_info.OpCode == `CHI5PC_DVMOP) 
      `define IS_CLEAN__MAKE_(Current_info) ((Current_info.OpCode == `CHI5PC_CLEANSHARED) || (Current_info.OpCode == `CHI5PC_CLEANINVALID) || (Current_info.OpCode == `CHI5PC_CLEANUNIQUE) || (Current_info.OpCode == `CHI5PC_MAKEUNIQUE) || (Current_info.OpCode == `CHI5PC_MAKEINVALID) ) 
      `define IS_CMO_(Current_info) ((Current_info.OpCode == `CHI5PC_CLEANSHARED) || (Current_info.OpCode == `CHI5PC_CLEANINVALID) || (Current_info.OpCode == `CHI5PC_MAKEINVALID) ) 
      `define IS_WRITE__UNIQUE(Current_info) ((Current_info.OpCode == `CHI5PC_WRITEUNIQUEFULL) || (Current_info.OpCode == `CHI5PC_WRITEUNIQUEPTL ))
      `define IS_WBACK__WCLEAN__WEF(Current_info) ((Current_info.OpCode == `CHI5PC_WRITEBACKFULL) || (Current_info.OpCode == `CHI5PC_WRITEBACKPTL) || (Current_info.OpCode == `CHI5PC_WRITECLEANFULL) || (Current_info.OpCode == `CHI5PC_WRITECLEANPTL) || (Current_info.OpCode == `CHI5PC_WRITEEVICTFULL ))
      `define IS_EVICT(Current_info) (Current_info.OpCode == `CHI5PC_EVICT) 
      `define IS_BARRIER(Current_info) ((Current_info.OpCode == `CHI5PC_ECBARRIER) || (Current_info.OpCode == `CHI5PC_EOBARRIER ))
      `define IS_EVICT__BARRIER(Current_info) (`IS_EVICT(Current_info) || `IS_BARRIER(Current_info))
      `define HAS_DBIDRESP_COMP(Current_info) (((Current_info.RspOpCode1 == `CHI5PC_COMP) && (Current_info.RspOpCode2 == `CHI5PC_DBIDRESP )) || ((Current_info.RspOpCode1 == `CHI5PC_DBIDRESP) && (Current_info.RspOpCode2 == `CHI5PC_COMP)) ||  (Current_info.RspOpCode1 == `CHI5PC_COMPDBIDRESP))
      `define HAS_DBIDRESP(Current_info) (( Current_info.RspOpCode1 == `CHI5PC_DBIDRESP ) ||  (Current_info.RspOpCode1 == `CHI5PC_COMPDBIDRESP) || ( Current_info.RspOpCode2 == `CHI5PC_DBIDRESP ) )
      `define HAS_COMP(Current_info) (( Current_info.RspOpCode1 == `CHI5PC_COMP ) ||  (Current_info.RspOpCode1 == `CHI5PC_COMPDBIDRESP) || ( Current_info.RspOpCode2 == `CHI5PC_COMP ) )
      `define HAS_COMPDATA(Current_info) (`IS_READ_(Current_info) && |Current_info.DATID)
      `define HAS_DBID(Current_info) ((`IS_READ_(Current_info) && |Current_info.DATID) ||  ( Current_info.RspOpCode1 == `CHI5PC_COMP ) ||  (Current_info.RspOpCode1 == `CHI5PC_COMPDBIDRESP) || ( Current_info.RspOpCode1 == `CHI5PC_DBIDRESP ) )
      `define HAS_ALLDATA(Current_info) `IS_DVMOP_(Current_info) ? |Current_info.DATID : ~|(Current_info.Exp_DATID & ~(Current_info.DATID))
  `endif



