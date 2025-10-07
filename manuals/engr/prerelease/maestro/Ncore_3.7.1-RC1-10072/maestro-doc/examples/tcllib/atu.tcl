namespace eval Atu {
  namespace export set_nodeId
  namespace export set_pipeLevelAtp
  namespace export set_pipeLevelApb
  namespace export set_pipeLevelSmi
  namespace export set_pipeLevelLut
  namespace export set_ctlPipeReq
  namespace export set_ctlPipeResp
  namespace export set_wApbSlvDec
  namespace export set_maxPduSz
  namespace export set_enBufWrite
  namespace export set_fixedSupported
  namespace export set_incrSupported
  namespace export set_wrapSupported
  namespace export set_narrowSupported
  namespace export set_readInterleaveSupported
  namespace export set_userReqFieldHash
  namespace export set_userDataFieldHash
  namespace export set_crdMngrEn
  namespace export set_crdDataUnit
  namespace export set_timeoutErrChk
  namespace export set_timeoutErrCount
  namespace export set_numPri
  namespace export set_pktArbType
  namespace export set_depktArbType
  namespace export set_ctlPipeCtxt
  namespace export set_depktArbWeights
  namespace export set_pktArbWeights
  namespace export set_idCompMask
  namespace export postmap_defaults
  namespace export create_obj
  namespace export test

  set version 2.0
  set Description "Maestro_Atu"

  variable home [file join [pwd] [file dirname [info script]]]
}

proc Atu::set_nodeId { obj val} {
  # set_attribute -object $obj -name nodeId -value $val
}

proc Atu::set_pipeLevelAtp { obj val} {
  set_attribute -object $obj -name pipeLevelAtp -value $val
}

proc Atu::set_pipeLevelApb { obj val} {
  set_attribute -object $obj -name pipeLevelApb -value $val
}

proc Atu::set_pipeLevelSmi { obj val} {
  set_attribute -object $obj -name pipeLevelSmi -value $val
}

proc Atu::set_pipeLevelLut { obj val} {
  set_attribute -object $obj -name pipeLevelLut -value $val
}

proc Atu::set_ctlPipeReq { obj val} {
  set_attribute -object $obj -name ctlPipeReq -value $val
}

proc Atu::set_ctlPipeResp { obj val} {
  set_attribute -object $obj -name ctlPipeResp -value $val
}

proc Atu::set_wApbSlvDec { obj val} {
  set_attribute -object $obj -name wApbSlvDec -value $val
}

proc Atu::set_maxPduSz { obj val} {
  set_attribute -object $obj -name maxPduSz -value $val
}

proc Atu::set_enBufWrite { obj val} {
  set_attribute -object $obj -name enBufWrite -value $val
}

proc Atu::set_fixedSupported { obj val} {
  set_attribute -object $obj -name fixedSupported -value $val
}

proc Atu::set_incrSupported { obj val} {
  set_attribute -object $obj -name incrSupported -value $val
}

proc Atu::set_wrapSupported { obj val} {
  set_attribute -object $obj -name wrapSupported -value $val
}

proc Atu::set_narrowSupported { obj val} {
  set_attribute -object $obj -name narrowSupported -value $val
}

proc Atu::set_readInterleaveSupported { obj val} {
  set_attribute -object $obj -name readInterleaveSupported -value $val
}

proc Atu::set_userReqFieldHash { obj val} {
  set_attribute -object $obj -name userReqFieldHash -value $val
}

proc Atu::set_userDataFieldHash { obj val} {
  set_attribute -object $obj -name userDataFieldHash -value $val
}

proc Atu::set_crdMngrEn { obj val} {
  set_attribute -object $obj -name crdMngrEn -value $val
}

proc Atu::set_crdDataUnit { obj val} {
  set_attribute -object $obj -name crdDataUnit -value $val
}

proc Atu::set_timeoutErrChk { obj val} {
  set_attribute -object $obj -name timeoutErrChk -value $val
}

proc Atu::set_timeoutErrCount { obj val} {
  set_attribute -object $obj -name timeoutErrCount -value $val
}

proc Atu::set_numPri { obj val} {
  set_attribute -object $obj -name numPri -value $val
}

proc Atu::set_pktArbType { obj val} {
  set_attribute -object $obj -name pktArbType -value $val
}

proc Atu::set_depktArbType { obj val} {
  set_attribute -object $obj -name depktArbType -value $val
}

proc Atu::set_ctlPipeCtxt { obj val} {
  set_attribute -object $obj -name ctlPipeCtxt -value $val
}

proc Atu::set_depktArbWeights { obj val} {
  set_attribute -object $obj -name depktArbWeights -value $val
}

proc Atu::set_pktArbWeights { obj val} {
  set_attribute -object $obj -name pktArbWeights -value $val
}

proc Atu::set_idCompMask { obj val} {
  set_attribute -object $obj -name idCompMask -value $val
}

proc Atu::postmap_defaults { unit } {
  Atu::set_pipeLevelAtp $unit 2
  Atu::set_pipeLevelApb $unit 1
  Atu::set_pipeLevelSmi $unit 2
  Atu::set_pipeLevelLut $unit 2
  Atu::set_ctlPipeReq $unit 2
  Atu::set_ctlPipeResp $unit 2
  Atu::set_wApbSlvDec $unit 3
  Atu::set_maxPduSz $unit 4
  #Atu::set_enBufWrite $unit false
  Atu::set_fixedSupported $unit false
  Atu::set_incrSupported $unit false
  Atu::set_wrapSupported $unit false
  Atu::set_narrowSupported $unit false
  Atu::set_readInterleaveSupported $unit false
  Atu::set_userReqFieldHash $unit user
  Atu::set_userDataFieldHash $unit user
  Atu::set_crdMngrEn $unit false
  Atu::set_crdDataUnit $unit 0
  Atu::set_timeoutErrChk $unit false
  Atu::set_timeoutErrCount $unit 0
  Atu::set_numPri $unit 2
  Atu::set_pktArbType $unit arb_rr1
  Atu::set_depktArbType $unit arb_rr1
  Atu::set_ctlPipeCtxt $unit 0
  Atu::set_depktArbWeights $unit [list 1]
  Atu::set_pktArbWeights $unit [list 1]
  Atu::set_idCompMask $unit [list false]
}

proc Atu::create_obj { name clk parent params } {
  set unit [create_object -type atu -name $name -parent $parent ]
  set_attribute -object $unit -value_list $params
  update_object -name $unit -bind $clk -type "domain"

  return $unit
}

proc Atu::test { msg } {
  puts "In test atu proc: msg = $msg"
}

package provide Atu $Atu::version
package require Tcl 8.5
