
namespace eval Apb_atu {
  namespace export set_pipeLevel
  namespace export set_pipeLevelAtp
  namespace export set_pipeLevelApb
  namespace export set_pipeLevelLut
  namespace export set_maxPduSz
  namespace export set_maxOutWr
  namespace export set_maxOutRd
  namespace export set_nativeType
  namespace export set_axiWrEn
  namespace export set_axiRdEn
  namespace export set_axiPipeR
  namespace export set_axiPipeB
  namespace export set_axiPipeW
  namespace export set_axiPipeAw
  namespace export set_axiPipeAr
  namespace export set_ctlPipeReq
  namespace export set_ctlPipeResp
  namespace export set_nodeId
  namespace export set_enBufWrite
  namespace export set_enSplitting
  namespace export set_enReordering
  namespace export set_widthAdaptionSupported
  namespace export set_fixedSupported
  namespace export set_incrSupported
  namespace export set_wrapSupported
  namespace export set_narrowSupported
  namespace export set_readInterleaveSupported
  namespace export set_idCompMask
  namespace export set_queueDepth
  namespace export set_qosMapMode
  namespace export set_crdMngrEn
  namespace export set_crdDataUnit
  namespace export set_atomicsSupported
  namespace export set_timeoutErrChk
  namespace export set_timeoutErrCount
  namespace export set_timeoutUseExternalValue
  namespace export set_maxOutTotal
  namespace export set_ctlPipeCtxt
  namespace export set_pipeLevelPam
  namespace export set_numPri
  namespace export set_pktArbType
  namespace export set_depktArbType
  namespace export set_pktArbWeights
  namespace export set_depktArbWeights
  namespace export set_smipktArbType
  namespace export set_smiDpkarbType
  namespace export set_mstrArbLock
  namespace export set_lckStyleVld
  namespace export set_rateLmtEn
  namespace export set_rateLmtUseExternalValues
  namespace export set_rateLmtRefCntGlobal
  namespace export set_refreshAmtGlobal
  namespace export set_rateLmtBktGlobal
  namespace export set_enDecodeError
  namespace export set_wRateLmtRefCntGlobal
  namespace export set_wRefreshAmtGlobal
  namespace export set_wRateLmtBktGlobal
  namespace export set_wRateLmtRefCntQueue
  namespace export set_wRefreshAmtQueue
  namespace export set_wRateLmtBktQueue
  namespace export set_enPathLookup
  namespace export set_smiPktnumPri
  namespace export set_smiPktarbRdyAware
  namespace export set_smiPktweightsProg
  namespace export set_smiPktweights
  namespace export set_smiDpkweights
  namespace export set_smiDpknumPri
  namespace export set_smiDpkarbRdyAware
  namespace export set_smiDpkweightsProg

  namespace export get_pipeLevel
  namespace export get_pipeLevelAtp
  namespace export get_pipeLevelApb
  namespace export get_pipeLevelLut
  namespace export get_maxPduSz
  namespace export get_maxOutWr
  namespace export get_maxOutRd
  namespace export get_nativeType
  namespace export get_axiWrEn
  namespace export get_axiRdEn
  namespace export get_axiPipeR
  namespace export get_axiPipeB
  namespace export get_axiPipeW
  namespace export get_axiPipeAw
  namespace export get_axiPipeAr
  namespace export get_ctlPipeReq
  namespace export get_ctlPipeResp
  namespace export get_nodeId
  namespace export get_enBufWrite
  namespace export get_enSplitting
  namespace export get_enReordering
  namespace export get_widthAdaptionSupported
  namespace export get_fixedSupported
  namespace export get_incrSupported
  namespace export get_wrapSupported
  namespace export get_narrowSupported
  namespace export get_readInterleaveSupported
  namespace export get_idCompMask
  namespace export get_queueDepth
  namespace export get_qosMapMode
  namespace export get_crdMngrEn
  namespace export get_crdDataUnit
  namespace export get_atomicsSupported
  namespace export get_timeoutErrChk
  namespace export get_timeoutErrCount
  namespace export get_timeoutUseExternalValue
  namespace export get_maxOutTotal
  namespace export get_ctlPipeCtxt
  namespace export get_pipeLevelPam
  namespace export get_numPri
  namespace export get_pktArbType
  namespace export get_depktArbType
  namespace export get_pktArbWeights
  namespace export get_depktArbWeights
  namespace export get_smipktArbType
  namespace export get_smiDpkarbType
  namespace export get_mstrArbLock
  namespace export get_lckStyleVld
  namespace export get_rateLmtEn
  namespace export get_rateLmtUseExternalValues
  namespace export get_rateLmtRefCntGlobal
  namespace export get_refreshAmtGlobal
  namespace export get_rateLmtBktGlobal
  namespace export get_enDecodeError
  namespace export get_wRateLmtRefCntGlobal
  namespace export get_wRefreshAmtGlobal
  namespace export get_wRateLmtBktGlobal
  namespace export get_wRateLmtRefCntQueue
  namespace export get_wRefreshAmtQueue
  namespace export get_wRateLmtBktQueue
  namespace export get_enPathLookup
  namespace export get_smiPktnumPri
  namespace export get_smiPktarbRdyAware
  namespace export get_smiPktweightsProg
  namespace export get_smiPktweights
  namespace export get_smiDpkweights
  namespace export get_smiDpknumPri
  namespace export get_smiDpkarbRdyAware
  namespace export get_smiDpkweightsProg

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test

  set version 2.0
  set Description "Maestro_Apb_atu"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Apb_atu::set_pipeLevel { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevel
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pipeLevelAtp { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelAtp
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pipeLevelApb { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelApb
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pipeLevelLut { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelLut
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_maxPduSz { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey maxPduSz
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_maxOutWr { objList val} {
  foreach obj $objList {
    set attrKey maxOutWr
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_maxOutRd { objList val} {
  foreach obj $objList {
    set attrKey maxOutRd
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_nativeType { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nativeType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiWrEn { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiWrEn
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiRdEn { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiRdEn
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiPipeR { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeR
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiPipeB { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeB
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiPipeW { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeW
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiPipeAw { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeAw
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_axiPipeAr { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeAr
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_ctlPipeReq { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeReq
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_ctlPipeResp { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeResp
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_nodeId { objList val} {
  # foreach obj $objList {
  #   set pos [string last "/" $obj]
  #   incr pos
  #   set shortName [string range $obj $pos end]
  #   set attrKey nodeId
  #   set_attribute -object $obj -name $attrKey -value $val
  # }
}

proc Apb_atu::set_enBufWrite { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enBufWrite
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_enSplitting { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enSplitting
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_enReordering { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enReordering
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_widthAdaptionSupported { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey widthAdaptionSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_fixedSupported { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey fixedSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_incrSupported { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey incrSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wrapSupported { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wrapSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_narrowSupported { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey narrowSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_readInterleaveSupported { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey readInterleaveSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_beatBufferEntries { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey beatBufferEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_idCompMask { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey idCompMask
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_queueMap { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey queueMap
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_queueDepth { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey queueDepth
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_qosMapMode { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey qosMapMode
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_crdMngrEn { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey crdMngrEn
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_crdDataUnit { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey crdDataUnit
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_atomicsSupported { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey atomicsSupported
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_timeoutErrChk { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutErrChk
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_timeoutErrCount { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutErrCount
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_timeoutUseExternalValue { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutUseExternalValue
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_maxOutTotal { objList val} {
  foreach obj $objList {
    set attrKey maxOutTotal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_ctlPipeCtxt { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeCtxt
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pipeLevelPam { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelPam
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_numPri { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey numPri
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pktArbType { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pktArbType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_depktArbType { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey depktArbType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_pktArbWeights { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweights
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_depktArbWeights { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweights
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_smipktArbType { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smipktArbType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiDpkarbType { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkarbType 
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_mstrArbLock { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey mstrArbLock
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_lckStyleVld { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey lckStyleVld
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_rateLmtEn { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtEn
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_rateLmtUseExternalValues { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtUseExternalValues
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_rateLmtRefCntGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtRefCntGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_refreshAmtGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey refreshAmtGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_rateLmtBktGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtBktGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_enDecodeError { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enDecodeError
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRateLmtRefCntGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtRefCntGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRefreshAmtGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRefreshAmtGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRateLmtBktGlobal { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtBktGlobal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRateLmtRefCntQueue { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtRefCntQueue 
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRefreshAmtQueue { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRefreshAmtQueue
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_wRateLmtBktQueue { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtBktQueue
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_enPathLookup { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enPathLookup
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiPktnumPri { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktnumPri
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiPktarbRdyAware { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktarbRdyAware
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiPktweightsProg { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweightsProg
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiPktweights { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweights
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_smiDpkweights { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweights
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Apb_atu::set_smiDpknumPri { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpknumPri
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiDpkarbRdyAware { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkarbRdyAware
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::set_smiDpkweightsProg { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweightsProg
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Apb_atu::get_pipeLevel { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevel
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pipeLevelAtp { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelAtp
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pipeLevelApb { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelApb
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pipeLevelLut { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelLut
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_maxPduSz { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey maxPduSz
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_nativeType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nativeType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiWrEn { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiWrEn
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiRdEn { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiRdEn
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiPipeR { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeR
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiPipeB { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeB
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiPipeW { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeW
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiPipeAw { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeAw
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_axiPipeAr { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey axiPipeAr
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_ctlPipeReq { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeReq
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_ctlPipeResp { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeResp
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_nodeId { objList } {
  set valList [list ]
  # foreach obj $objList {
  #   set pos [string last "/" $obj]
  #   incr pos
  #   set shortName [string range $obj $pos end]
  #   set attrKey nodeId
  #   set v [get_parameter -object $obj -name $attrKey]
  #   lappend valList $v
  # }
  return $valList
}

proc Apb_atu::get_enBufWrite { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enBufWrite
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_enSplitting { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enSplitting
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_enReordering { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enReordering
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_widthAdaptionSupported { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey widthAdaptionSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_fixedSupported { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey fixedSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_incrSupported { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey incrSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wrapSupported { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wrapSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_narrowSupported { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey narrowSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_readInterleaveSupported { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey readInterleaveSupported
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_idCompMask { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey idCompMask
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_beatBufferEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey beatBufferEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_queueDepth { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey queueDepth
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_qosMapMode { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey qosMapMode
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_crdMngrEn { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey crdMngrEn
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_crdDataUnit { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey crdDataUnit
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_timeoutErrChk { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutErrChk
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_timeoutErrCount { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutErrCount
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_timeoutUseExternalValue { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey timeoutUseExternalValue
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_ctlPipeCtxt { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ctlPipeCtxt
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pipeLevelPam { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pipeLevelPam
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_numPri { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey numPri
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pktArbType { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey pktArbType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_depktArbType { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey depktArbType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_pktArbWeights { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweights
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_depktArbWeights { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweights
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiPktweights { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweights
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiDpkweights { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweights
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smipktArbType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smipktArbType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiDpkarbType { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkarbType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_mstrArbLock { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey mstrArbLock
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_lckStyleVld { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey lckStyleVld
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_rateLmtEn { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtEn
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

####
proc Apb_atu::get_rateLmtUseExternalValues { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtUseExternalValues
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_rateLmtRefCntGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtRefCntGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_refreshAmtGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey refreshAmtGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_rateLmtBktGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey rateLmtBktGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_enDecodeError { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enDecodeError
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRateLmtRefCntGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtRefCntGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRefreshAmtGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRefreshAmtGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRateLmtBktGlobal { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtBktGlobal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRateLmtRefCntQueue { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtRefCntQueue
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRefreshAmtQueue { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRefreshAmtQueue
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_wRateLmtBktQueue { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey wRateLmtBktQueue
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_enPathLookup { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey enPathLookup
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiPktnumPri { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktnumPri
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiPktarbRdyAware { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktarbRdyAware
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiPktweightsProg { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiPktweightsProg
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiDpknumPri { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpknumPri
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiDpkarbRdyAware { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkarbRdyAware
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::get_smiDpkweightsProg { objList } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey smiDpkweightsProg
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Apb_atu::set_unit_attribute { ind procFunc value } {
  set unit [lindex $Apb_atu::created_units $ind]
  set x [$procFunc $unit $value]
}

proc Apb_atu::get_unit_attribute { ind procFunc } {
  set unit [lindex $Apb_atu::created_units $ind]
  set val [$procFunc $unit]
  return $val
}

proc Apb_atu::number_of_units { } {
  set val [llength $Apb_atu::created_units]
  return $val
}

proc Apb_atu::get_unit { indx } {
  if {$indx < 0 || $indx >= [llength $Apb_atu::created_units]} {
    return ""
  }
  set val [lindex $Apb_atu::created_units $indx]
  return $val
}

proc Apb_atu::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Apb_atu::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Apb_atu::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type atu -parent $chip]
  set apbAtus [list]
  foreach atu $objects {
    set sk [get_objects -parent $atu -type socket]
    set func [get_parameter -object $sk -name socketFunction]
    if {[string compare $func "CONFIGURATION"] == 0} {
        lappend apbAtus $atu
    }
  }
  return $apbAtus
}

proc Apb_atu::get_units { list_of_indices } {
  set units [list]
  set objects [Apb_atu::get_all_units]
  set n [llength $objects]
  foreach indx $list_of_indices {
    if {$indx < $n} {
      lappend units [lindex $objects $indx]
    }
  }
  return $units
}



package provide Apb_atu $Apb_atu::version
package require Tcl 8.5
