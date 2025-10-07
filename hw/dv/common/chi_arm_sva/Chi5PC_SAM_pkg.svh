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
//  File Revision       : $Revision: 158291 $
//
//  Date                : $Date: 2013-10-01 17:36:20 +0100 (Tue, 01 Oct 2013) $
//
//  Release Information : $State: Exp $
//
//------------------------------------------------------------------------------
//  Purpose             :Performs user specific Target ID remapping. Default
//                       file contents return the Target ID of the request
//                       Flit. This file is intended to be edited by the user
//                       to reflect the local system address map.
//
// 
//------------------------------------------------------------------------------
  // Defines all possible values for Chi5 interface types
  package Chi5PC_SAM_pkg;
  `include "Chi5PC_Chi5_defines.v"//the flit content definition
  `ifndef CHI5PC_FLIT_DEFINES_SVH
  `include "Chi5PC_Chi5_flit_defines.svh"//enums of flit content and the struct

  `define CHI5PC_FLIT_DEFINES_SVH
  `endif

  
  function logic[`CHI5PC_REQ_FLIT_TGTID_WIDTH-1:0] SAM_remap (input logic [`CHI5PC_REQ_FLIT_RANGE] REQFLIT );
    begin
      //Barriers and DVM are mapped according to opcode rather than address
      if ((REQFLIT[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_EOBARRIER)||
          (REQFLIT[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_ECBARRIER)||
          (REQFLIT[`CHI5PC_REQ_FLIT_OPCODE_RANGE] == `CHI5PC_DVMOP))
      begin
        return REQFLIT[`CHI5PC_REQ_FLIT_TGTID_RANGE];
      end
      else
      begin
        case (REQFLIT[`CHI5PC_REQ_FLIT_ADDR_RANGE])
        default:
          begin 
            return REQFLIT[`CHI5PC_REQ_FLIT_TGTID_RANGE];
          end
        endcase;
      end
    end
  endfunction
  endpackage : Chi5PC_SAM_pkg


