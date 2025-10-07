//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';

module.exports = {
    // CMDReq Encodings
    "CMDreq": {
	"CmdRdCpy"    : "0000000",
	"CmdRdCln"    : "0000001",
	"CmdRdVld"    : "0000011",
	"CmdRdUnq"    : "0000100",
	"CmdClnUnq"   : "0000101",
	"CmdClnVld"   : "0001000",
	"CmdClnInv"   : "0001001",
	"CmdWrUnqPtl" : "0010000",
	"CmdWrUnqFull": "0010001",
	"CmdUpdVld"   : "0011010",  //ToBeRemoved
	"CmdUpdInv"   : "0011011",  //ToBeRemoved
	"CmdDvmMsg"   : "0001111"   //Check with DK
    },

    // UPD Encodings
    "UPDreq": {
	"UpdVld"      : "0101011",
	"UpdInv"      : "0101100" 
    },

    // HNT Encodings
    "HNTreq": {
	"HntRead"     : "1011100"
    },

    // SNPReq Encodings
    "SNPreq": {
	"SnpInv"      : "1000110", 
	"SnpClnDtr"   : "1000001",
	"SnpVldDtr"   : "1000011",
	"SnpInvDtr"   : "1000100",
	"SnpInvDtw"   : "1000101",
	"SnpRecall"   : "1001001",
	"SnpVldDtw"   : "1001000", 
	"SnpDvmMsg"   : "1001111"
    },

    // MRDreq Encodings
    "MRDreq":{
	"MrdRead"      : "1100001",
	"MrdRdCln"     : "1100001",
	"MrdRdFlsh"    : "1100010",
	"MrdRdVld"     : "1100011",
	"MrdRdInv"     : "1100100",
	"MrdFlush"     : "1100101"
    },
    
    // STRreq Encodings
    "STRreq":{
	"StrState"    : "1110001",
	"StrStateDvm" : "1110111"  //ToBeRemoved
    },

    // DTRreq Encodings
    "DTRreq":{
	"DtrData"     : "0110001",
	"DtrDataCln"     : "0110001",
	"DtrDataDty"     : "0110011",
	"DtrDataVis"     : "0110101",
	"DtrDvmCmp"   : "0110111"
    },

    // DTWreq Encodings
    "DTWreq":{
	"DtwData"     : "0111001",
	"DtwDataCln"     : "0111001",
	"DtwDataPtl"     : "0111010",
	"DtwDataDty"     : "0111011"
    },

    // TransID Prefix (v0.4 of DCE Arch)
    "TransIDPrefix":{
	"SnpTidPrefix"  : "0",
	"StrTidPrefix"  : "100",
	"HntTidPrefix"  : "101",
	"MrdTidPrefix"  : "110",
	"DVMSTidPrefix" : "1110",
	"DVMRTidPrefix" : "1111"
    },

    // SFI Response Error Codes
    "SfiRspErrCode":{
        "SFI_RSPERR_SLV"    : "000", // SLV  (0)
        "SFI_RSPERR_DISC"   : "011", // DISC (3)
        "SFI_RSPERR_SEC"    : "100", // SEC  (4)
        "SFI_RSPERR_TMO"    : "110", // TMO  (6)
        "SFI_RSPERR_DERR"   : "111"  // DERR (5) //NOTE: TO CHANGE THIS TO "111" (7) 
    },

    // MsgAttr fields
    "MsgAttr":{
        // VZ bit (Visibility)
        // System Visible
        "MsgAttrSV": "0",
        // Coherence Domain Visible
        "MsgAttrCV": "1",

        // AC bit (Allocation)
        // Not Allocate
        "MsgAttrNA": "0",
        // Allocate
        "MsgAttrAL": "1",

        // TS bit (Data Transfer State)
        // Not Constrained
        "MsgAttrNC": "0",
        // Clean Unless Invalid
        "MsgAttrCI": "1"
    }

};


