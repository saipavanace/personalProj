//----------------------------------------------------------------------
// Copyright(C) 2014 Arteris, Inc.
// All rights reserved.
//----------------------------------------------------------------------

'use strict';



module.exports = {
  "verSysParams": 1,
  "strProjectName": "New project",
  "wCacheLineOffset": 6,
  "wSecurityAttribute": 0,
  "wPriorityLevel": 0,
  "assertOn": 1,
  "AiuInfo": [
    {
      "strRtlNamePrefix": "aiu0",
      "specification": "NonCoherent",
      "nAius": 1,
      "AiuSelectInfo": {
        "nSelectBits": 0,
        "SelectBits": [],
        "HashBits": [],
        "SelectTable": []
      },
      "fnNativeInterface": "ACE",
      "useHwDebug": 1,
      "fnAiuSelect": "TABLE",
      "NativeInfo": {
        "nProcs": 2,
        "AxIdProcSelectInfo": {
          "nSelectBits": 1,
          "SelectBits": [
            0
          ],
          "HashBits": [],
          "SelectTable": []
        },
        "szAgentCacheLine": 64,
        "szMaxCoherentRead": 64,
        "szMaxCoherentWrite": 64,
        "useSharerPromotion": 1,
        "useWriteEvict": 0,
        "useBarriers": 0,
        "useDvm": 0,
        "SignalInfo": {
          "wAxId": 6,
          "wAxAddr": 40,
          "wXData": 128,
          "wCdData": 128,
          "wAwUser": 0,
          "wArUser": 0,
          "wWUser": 0,
          "wBUser": 0,
          "wRUser": 0,
          "useAceQosPort": 1,
          "useAceRegionPort": 0,
          "useAceUniquePort": 1,
          "useAceCache": 0,
          "useAceProt": 0,
          "useAceQos": 0,
          "useAceRegion": 0,
          "useAceDomain": 0,
          "useAceUnique": 0
        }
      },
      "SfiInfo": {
        "wMasterData": 128,
        "wSlaveData": 128
      },
      "CmpInfo": {
        "OttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "nOttCtrlEntries": 16,
        "nOttDataEntries": 4,
        "nOttStrbEntries": 4,
        "nCmdInFlight": 4,
        "nDtrInFlight": 4,
        "nUpdInFlight": 4,
        "nDvmMsgInFlight": 1,
        "nDvmCmpInFlight": 1,
        "nDtrSlaveIds": 4,
        "idSnoopFilterSlice": 0
      },
      "Derived": {
        "sfiPriv": {
          "msgType": {
            "width": 5,
            "lsb": 0,
            "msb": 4
          },
          "ST": {
            "width": 3,
            "lsb": 5,
            "msb": 7
          },
          "SD": {
            "width": 1,
            "lsb": 8,
            "msb": 8
          },
          "SO": {
            "width": 1,
            "lsb": 9,
            "msb": 9
          },
          "SS": {
            "width": 1,
            "lsb": 10,
            "msb": 10
          },
          "ErrResult": {
            "width": 2,
            "lsb": 11,
            "msb": 12
          },
          "AceExOkay": {
            "width": 1,
            "lsb": 13,
            "msb": 13
          },
          "aiuTransId": {
            "width": 4,
            "lsb": 5,
            "msb": 8
          },
          "aiuId": {
            "width": 2,
            "lsb": 9,
            "msb": 10
          },
          "aiuProcId": {
            "width": 1,
            "lsb": 11,
            "msb": 11
          },
          "aceLock": {
            "width": 1,
            "lsb": 12,
            "msb": 12
          },
          "aceCache": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceProt": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceQoS": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceRegion": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUser": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceDomain": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUnique": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "width": 14
        },
        "wSfiAddr": 40,
        "wSfiSlvId": 3,
        "wProtBitsPerByte": 0,
        "wSfiSlaveTransId": 10,
        "wSfiMasterTransId": 10,
        "nPendingTransactions": 1024,
        "nSysCohWindowPrefix": 0
      }
    },
    {
      "strRtlNamePrefix": "aiu1",
      "specification": "NonCoherent",
      "nAius": 1,
      "AiuSelectInfo": {
        "nSelectBits": 0,
        "SelectBits": [],
        "HashBits": [],
        "SelectTable": []
      },
      "fnNativeInterface": "ACE",
      "fnAiuSelect": "TABLE",
      "NativeInfo": {
        "nProcs": 2,
        "AxIdProcSelectInfo": {
          "nSelectBits": 1,
          "SelectBits": [
            0
          ],
          "HashBits": [],
          "SelectTable": []
        },
        "szAgentCacheLine": 64,
        "szMaxCoherentRead": 64,
        "szMaxCoherentWrite": 64,
        "useSharerPromotion": 1,
        "useWriteEvict": 0,
        "useBarriers": 0,
        "useDvm": 0,
        "SignalInfo": {
          "wAxId": 6,
          "wAxAddr": 40,
          "wXData": 128,
          "wCdData": 128,
          "wAwUser": 0,
          "wArUser": 0,
          "wWUser": 0,
          "wBUser": 0,
          "wRUser": 0,
          "useAceQosPort": 1,
          "useAceRegionPort": 0,
          "useAceUniquePort": 1,
          "useAceCache": 0,
          "useAceProt": 0,
          "useAceQos": 0,
          "useAceRegion": 0,
          "useAceDomain": 0,
          "useAceUnique": 0
        }
      },
      "SfiInfo": {
        "wMasterData": 128,
        "wSlaveData": 128
      },
      "CmpInfo": {
        "OttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "nOttCtrlEntries": 16,
        "nOttDataEntries": 4,
        "nOttStrbEntries": 4,
        "nCmdInFlight": 4,
        "nDtrInFlight": 4,
        "nUpdInFlight": 4,
        "nDvmMsgInFlight": 1,
        "nDvmCmpInFlight": 1,
        "nDtrSlaveIds": 4,
        "idSnoopFilterSlice": 0
      },
      "Derived": {
        "sfiPriv": {
          "msgType": {
            "width": 5,
            "lsb": 0,
            "msb": 4
          },
          "ST": {
            "width": 3,
            "lsb": 5,
            "msb": 7
          },
          "SD": {
            "width": 1,
            "lsb": 8,
            "msb": 8
          },
          "SO": {
            "width": 1,
            "lsb": 9,
            "msb": 9
          },
          "SS": {
            "width": 1,
            "lsb": 10,
            "msb": 10
          },
          "ErrResult": {
            "width": 2,
            "lsb": 11,
            "msb": 12
          },
          "AceExOkay": {
            "width": 1,
            "lsb": 13,
            "msb": 13
          },
          "aiuTransId": {
            "width": 4,
            "lsb": 5,
            "msb": 8
          },
          "aiuId": {
            "width": 2,
            "lsb": 9,
            "msb": 10
          },
          "aiuProcId": {
            "width": 1,
            "lsb": 11,
            "msb": 11
          },
          "aceLock": {
            "width": 1,
            "lsb": 12,
            "msb": 12
          },
          "aceCache": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceProt": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceQoS": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceRegion": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUser": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceDomain": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUnique": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "width": 14
        },
        "wSfiAddr": 40,
        "wSfiSlvId": 3,
        "wProtBitsPerByte": 0,
        "wSfiSlaveTransId": 10,
        "wSfiMasterTransId": 10,
        "nSysCohWindowPrefix": 0
      }
    },
    {
      "strRtlNamePrefix": "aiu2",
      "specification": "NonCoherent",
      "nAius": 1,
      "AiuSelectInfo": {
        "nSelectBits": 0,
        "SelectBits": [],
        "HashBits": [],
        "SelectTable": []
      },
      "fnNativeInterface": "ACE",
      "fnAiuSelect": "TABLE",
      "NativeInfo": {
        "nProcs": 2,
        "AxIdProcSelectInfo": {
          "nSelectBits": 1,
          "SelectBits": [
            0
          ],
          "HashBits": [],
          "SelectTable": []
        },
        "szAgentCacheLine": 64,
        "szMaxCoherentRead": 64,
        "szMaxCoherentWrite": 64,
        "useSharerPromotion": 1,
        "useWriteEvict": 0,
        "useBarriers": 0,
        "useDvm": 0,
        "SignalInfo": {
          "wAxId": 6,
          "wAxAddr": 40,
          "wXData": 128,
          "wCdData": 128,
          "wAwUser": 0,
          "wArUser": 0,
          "wWUser": 0,
          "wBUser": 0,
          "wRUser": 0,
          "useAceQosPort": 1,
          "useAceRegionPort": 0,
          "useAceUniquePort": 1,
          "useAceCache": 0,
          "useAceProt": 0,
          "useAceQos": 0,
          "useAceRegion": 0,
          "useAceDomain": 0,
          "useAceUnique": 0
        }
      },
      "SfiInfo": {
        "wMasterData": 128,
        "wSlaveData": 128
      },
      "CmpInfo": {
        "OttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "nOttCtrlEntries": 16,
        "nOttDataEntries": 4,
        "nOttStrbEntries": 4,
        "nCmdInFlight": 4,
        "nDtrInFlight": 4,
        "nUpdInFlight": 4,
        "nDvmMsgInFlight": 1,
        "nDvmCmpInFlight": 1,
        "nDtrSlaveIds": 4,
        "idSnoopFilterSlice": 0
      },
      "Derived": {
        "sfiPriv": {
          "msgType": {
            "width": 5,
            "lsb": 0,
            "msb": 4
          },
          "ST": {
            "width": 3,
            "lsb": 5,
            "msb": 7
          },
          "SD": {
            "width": 1,
            "lsb": 8,
            "msb": 8
          },
          "SO": {
            "width": 1,
            "lsb": 9,
            "msb": 9
          },
          "SS": {
            "width": 1,
            "lsb": 10,
            "msb": 10
          },
          "ErrResult": {
            "width": 2,
            "lsb": 11,
            "msb": 12
          },
          "AceExOkay": {
            "width": 1,
            "lsb": 13,
            "msb": 13
          },
          "aiuTransId": {
            "width": 4,
            "lsb": 5,
            "msb": 8
          },
          "aiuId": {
            "width": 2,
            "lsb": 9,
            "msb": 10
          },
          "aiuProcId": {
            "width": 1,
            "lsb": 11,
            "msb": 11
          },
          "aceLock": {
            "width": 1,
            "lsb": 12,
            "msb": 12
          },
          "aceCache": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceProt": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceQoS": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceRegion": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUser": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceDomain": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUnique": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "width": 14
        },
        "wSfiAddr": 40,
        "wSfiSlvId": 3,
        "wProtBitsPerByte": 0,
        "wSfiSlaveTransId": 10,
        "wSfiMasterTransId": 10,
        "nSysCohWindowPrefix": 0
      }
    },
    {
      "strRtlNamePrefix": "aiu3",
      "specification": "NonCoherent",
      "nAius": 1,
      "AiuSelectInfo": {
        "nSelectBits": 0,
        "SelectBits": [],
        "HashBits": [],
        "SelectTable": []
      },
      "fnNativeInterface": "ACE",
      "fnAiuSelect": "TABLE",
      "NativeInfo": {
        "nProcs": 2,
        "AxIdProcSelectInfo": {
          "nSelectBits": 1,
          "SelectBits": [
            0
          ],
          "HashBits": [],
          "SelectTable": []
        },
        "szAgentCacheLine": 64,
        "szMaxCoherentRead": 64,
        "szMaxCoherentWrite": 64,
        "useSharerPromotion": 1,
        "useWriteEvict": 0,
        "useBarriers": 0,
        "useDvm": 0,
        "SignalInfo": {
          "wAxId": 6,
          "wAxAddr": 40,
          "wXData": 128,
          "wCdData": 128,
          "wAwUser": 0,
          "wArUser": 0,
          "wWUser": 0,
          "wBUser": 0,
          "wRUser": 0,
          "useAceQosPort": 1,
          "useAceRegionPort": 0,
          "useAceUniquePort": 1,
          "useAceCache": 0,
          "useAceProt": 0,
          "useAceQos": 0,
          "useAceRegion": 0,
          "useAceDomain": 0,
          "useAceUnique": 0
        }
      },
      "SfiInfo": {
        "wMasterData": 128,
        "wSlaveData": 128
      },
      "CmpInfo": {
        "OttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "nOttCtrlEntries": 16,
        "nOttDataEntries": 4,
        "nOttStrbEntries": 4,
        "nCmdInFlight": 4,
        "nDtrInFlight": 4,
        "nUpdInFlight": 4,
        "nDvmMsgInFlight": 1,
        "nDvmCmpInFlight": 1,
        "nDtrSlaveIds": 4,
        "idSnoopFilterSlice": 0
      },
      "Derived": {
        "sfiPriv": {
          "msgType": {
            "width": 5,
            "lsb": 0,
            "msb": 4
          },
          "ST": {
            "width": 3,
            "lsb": 5,
            "msb": 7
          },
          "SD": {
            "width": 1,
            "lsb": 8,
            "msb": 8
          },
          "SO": {
            "width": 1,
            "lsb": 9,
            "msb": 9
          },
          "SS": {
            "width": 1,
            "lsb": 10,
            "msb": 10
          },
          "ErrResult": {
            "width": 2,
            "lsb": 11,
            "msb": 12
          },
          "AceExOkay": {
            "width": 1,
            "lsb": 13,
            "msb": 13
          },
          "aiuTransId": {
            "width": 4,
            "lsb": 5,
            "msb": 8
          },
          "aiuId": {
            "width": 2,
            "lsb": 9,
            "msb": 10
          },
          "aiuProcId": {
            "width": 1,
            "lsb": 11,
            "msb": 11
          },
          "aceLock": {
            "width": 1,
            "lsb": 12,
            "msb": 12
          },
          "aceCache": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceProt": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceQoS": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceRegion": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUser": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceDomain": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUnique": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "width": 14
        },
        "wSfiAddr": 40,
        "wSfiSlvId": 3,
        "wProtBitsPerByte": 0,
        "wSfiSlaveTransId": 10,
        "wSfiMasterTransId": 10,
        "nSysCohWindowPrefix": 0
      }
    }
  ],
  "BridgeAiuInfo": [],
  "SnoopFilterInfo": [
    {
      "CmpInfo": {
        "nSnpInFlight": 8,
        "useMemHints": 1
      },
      "strRtlNamePrefix": "snoop1",
      "fnFilterType": "NULL"
    }
  ],
  "DceInfo": {
    "nDces": 1,
    "CmpInfo": {
      "nAttCtrlEntries": 16,
      "nTaggedMonitors": 2,
      "nUpdSlaveIds": 0
    },
    "DvmInfo": {
      "nDvmSnpInFlight": 1,
      "nDvmRepInFlight": 1,
      "nDtfEntries": 4
    },
    "DceSelectInfo": {
      "nSelectBits": 0,
      "SelectBits": [],
      "HashBits": [],
      "SelectTable": []
    },
    "Derived": {
      "sfiPriv": {
        "msgType": {
          "width": 5,
          "lsb": 0,
          "msb": 4
        },
        "ST": {
          "width": 3,
          "lsb": 5,
          "msb": 7
        },
        "SD": {
          "width": 1,
          "lsb": 8,
          "msb": 8
        },
        "SO": {
          "width": 1,
          "lsb": 9,
          "msb": 9
        },
        "SS": {
          "width": 1,
          "lsb": 10,
          "msb": 10
        },
        "ErrResult": {
          "width": 2,
          "lsb": 11,
          "msb": 12
        },
        "AceExOkay": {
          "width": 1,
          "lsb": 13,
          "msb": 13
        },
        "aiuTransId": {
          "width": 4,
          "lsb": 5,
          "msb": 8
        },
        "aiuId": {
          "width": 2,
          "lsb": 9,
          "msb": 10
        },
        "aiuProcId": {
          "width": 1,
          "lsb": 11,
          "msb": 11
        },
        "aceLock": {
          "width": 1,
          "lsb": 12,
          "msb": 12
        },
        "aceCache": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceProt": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceQoS": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceRegion": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceUser": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceDomain": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "aceUnique": {
          "width": 0,
          "lsb": 13,
          "msb": 12
        },
        "width": 14
      },
      "wSfiAddr": 40,
      "wSfiSlvId": 3,
      "wProtBitsPerByte": 0,
      "wSfiData": 128,
      "wSfiSlaveTransId": 10,
      "wSfiMasterTransId": 10,
      "nAttSkidEntries": 16
    }
  },
  "MemRegionInfo": [
    {
      "strRtlNamePrefix": "dmi",
      "wRegionAddr": 40,
      "nRegionPrefix": 0,
      "CmpInfo": {
        "nMrdInFlight": 8
      }
    }
  ],
  "DmiInfo": [
    {
      "specification": "NonCoherent",
      "nDmis": 1,
      "fnNativeInterface": "AXI",
      "fnDmiSelect": "TABLE",
      "DmiSelectInfo": {
        "nSelectBits": 0,
        "SelectBits": [],
        "HashBits": [],
        "SelectTable": []
      },
      "SfiInfo": {
        "wMasterData": 128,
        "wSlaveData": 128
      },
      "NativeInfo": {
        "SignalInfo": {
          "wXData": 128
        }
      },
      "CmpInfo": {
        "nHttCtrlEntries": 16,
        "HttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "nRttCtrlEntries": 16,
        "useRttDataEntries": 1,
        "RttDataErrorInfo": {
          "fnErrDetectCorrect": "NONE"
        },
        "useSharedHttRtt": 0,
        "useMemRspIntrlv": 0,
        "nWttCtrlEntries": 16,
        "nDtrInFlight": 8,
        "nHntSlaveIds": 0,
        "nDtwSlaveIds": 16
      },
      "Derived": {
        "sfiPriv": {
          "msgType": {
            "width": 5,
            "lsb": 0,
            "msb": 4
          },
          "ST": {
            "width": 3,
            "lsb": 5,
            "msb": 7
          },
          "SD": {
            "width": 1,
            "lsb": 8,
            "msb": 8
          },
          "SO": {
            "width": 1,
            "lsb": 9,
            "msb": 9
          },
          "SS": {
            "width": 1,
            "lsb": 10,
            "msb": 10
          },
          "ErrResult": {
            "width": 2,
            "lsb": 11,
            "msb": 12
          },
          "AceExOkay": {
            "width": 1,
            "lsb": 13,
            "msb": 13
          },
          "aiuTransId": {
            "width": 4,
            "lsb": 5,
            "msb": 8
          },
          "aiuId": {
            "width": 2,
            "lsb": 9,
            "msb": 10
          },
          "aiuProcId": {
            "width": 1,
            "lsb": 11,
            "msb": 11
          },
          "aceLock": {
            "width": 1,
            "lsb": 12,
            "msb": 12
          },
          "aceCache": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceProt": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceQoS": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceRegion": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUser": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceDomain": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "aceUnique": {
            "width": 0,
            "lsb": 13,
            "msb": 12
          },
          "width": 14
        },
        "wSfiAddr": 40,
        "wSfiSlvId": 3,
        "wProtBitsPerByte": 0,
        "wSfiSlaveTransId": 10,
        "wSfiMasterTransId": 10,
        "wArId": 5,
        "wAwId": 4,
        "wAxAddr": 40,
        "wAwUser": 0,
        "wArUser": 0,
        "wBUser": 0,
        "wRUser": 0,
        "wWUser": 0,
        "useAceQosPort": 1,
        "useAceRegionPort": 0,
        "useAceUniquePort": 1,
        "useAceCache": 1,
        "useAceProt": 1,
        "useAceQos": 0,
        "useAceRegion": 0,
        "useAceDomain": 0,
        "useAceUnique": 0
      }
    }
  ]
}
