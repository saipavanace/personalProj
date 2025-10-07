#! /bin/tclsh
# ==========================================================================
# Copyright(C) 2017-2025 Arteris, Inc.
# All rights reserved.
#
# These files and associated documentation is proprietary and Confidential
# to Arteris, Inc.  The files may only be used pursuant to the terms and
# conditions of a written license agreement with Arteris, Inc. or one of
# its subsidiaries. All other use, reproduction, modification, or of the
# information contained in the files or the associated documentation is
# strictly prohibited.
#
# This product is protected by patents as described at
# http://www.arteris.com/patents
# ==========================================================================
# See README.md for authors and usage.
# ==========================================================================

# 2x1 Chiplets
# 1 GIU
# 1 CHI-E
# 1 IOAIU ACE5-Lite
# 2 DMI
# 1 DCE
# 1 DII


set designName eva_ncore_multidie
set project [create_project -multi_chiplet -name $designName -license_token Arteris/Dev]

### TODO: remove after deadlock checker is completed
set_temporary_config -name IGNORE_ASSEMBLY_DEADLOCK -value true

set chip    [create_object -type chip -name "c" -parent $project]
set base_die [create_object -type chiplet -name "BASE_DIE" -parent $chip]

# 1 GIU in each Chiplet
create_object -type gateway -name "GIU0" -parent $base_die

## Create an assembly for our instances
set assembly_name DIE_ASSEMBLY
set die_assembly [create_object -type chiplet_assembly -name $assembly_name -parent $chip]
set_parameter -object $die_assembly -name nGlobalCachingAgents -value 2
set_parameter -object $die_assembly -name GlobalLargestNProc -value 8

## Create instances of the base die
set DIE_1 [create_chiplet_instance -of $base_die -in $die_assembly -name "DIE_1" -id 0]
set_node_position -object $DIE_1   -x 0 -y 0
set DIE_2 [create_chiplet_instance -of $base_die -in $die_assembly -name "DIE_2" -id 1]
set_node_position -object $DIE_2   -x 1 -y 0

# Create 2 links between two chiplet instances
set link_DIE_00 [link_gateways -first $DIE_1/GIU0 -second $DIE_2/GIU0]

set_current_chiplet -name $base_die

## Populate Chiplet (master) content
## =======================
## Clock and Power
## =======================

set pregion [create_object -name "pr" -type power_region  -parent $base_die]
set_parameter -object $pregion -name voltage -value 950; # mV
set pdomain [create_object -name "pd" -type power_domain    -parent $pregion]
set_parameter -object $pdomain -name gating -value always_on

set main_clock_region [create_object -name "main_clock_region"  -type clock_region  -parent $base_die]
update_object -name $main_clock_region -bind $pregion -type "powerRegion"
set_parameter -object $main_clock_region -name frequency -value 600; # MHz

set main_clock_domain [create_object -name "main_clock_domain"       -type clock_domain    -parent $main_clock_region]
update_object -name $main_clock_domain -bind $pdomain -type "powerDomain"
set main_clk [create_object -name "main_clk" -type clock_subdomain -parent $main_clock_domain]

set pcie_clock_region [create_object -name "pcie_clock_region"  -type clock_region  -parent $base_die]
update_object -name $pcie_clock_region -bind $pregion -type "powerRegion"
set_parameter -object $pcie_clock_region -name frequency -value 600; # MHz

set pcie_clock_domain [create_object -name "pcie_clock_domain"       -type clock_domain    -parent $pcie_clock_region]
update_object -name $pcie_clock_domain -bind $pdomain -type "powerDomain"
set pcie_clk [create_object -name "pcie_clk" -type clock_subdomain -parent $pcie_clock_domain]

set subsystem  [create_object -type subsystem  -name "ss" -parent $base_die]

## =======================
## Sockets
## =======================

puts "## Processing Sockets -- $base_die"

set rnf [create_object -type socket -name "RNF" -parent $subsystem]
update_object -name $rnf -bind $main_clk -type "domain"
set vals [list \
  socketFunction INITIATOR \
  protocolType CHI-E \
  fnCsrAccess true \
  hasEventInInt true \
  hasEventOutInt true \
  params/wData 256 \
  params/NodeID_Width 11 \
  params/wAddr 44 \
  params/REQ_RSVDC 0 \
  params/checkType NONE \
  params/enPoison false \
 ]
set_parameter -object $rnf -param_list $vals

set s0_adb_gic_rni [create_object -type socket -name "S0_ADB_GIC_RNI" -parent $subsystem]
update_object -name $s0_adb_gic_rni -bind $pcie_clk -type "domain"
set vals [list \
  socketFunction INITIATOR \
  protocolType ACE5-Lite \
  fnCsrAccess false \
  hasEventOutInt false \
  fnDisableRdInterleave false \
  params/wArId 15 \
  params/wAwId 15 \
  params/wAddr 44 \
  params/wData 128 \
  params/wAwUser 0 \
  params/wArUser 0 \
  params/wRegion 0 \
  params/checkType NONE \
  params/enableDVM false \
  params/atomicTransactions false \
 ]
set_parameter -object $s0_adb_gic_rni -param_list $vals

set sbsx0 [create_object -type socket -name "SBSX0" -parent $subsystem]
update_object -name $sbsx0 -bind $main_clk -type "domain"
set vals [list \
  socketFunction MEMORY \
  protocolType AXI4 \
  params/wArId 28 \
  params/wAwId 28 \
  params/wAddr 44 \
  params/wData 256 \
  params/wAwUser 0 \
  params/wArUser 0 \
  params/wRegion 0 \
 ]
set_parameter -object $sbsx0 -param_list $vals

set dii_name_list [list H_HND]
foreach n $dii_name_list {
  set sock [create_object -type socket -name "${n}" -parent $subsystem]
  set vals [list \
    socketFunction PERIPHERAL \
    protocolType AXI4 \
    params/wArId 28 \
    params/wAwId 28 \
    params/wAddr 44 \
    params/wData 256 \
    params/wAwUser 0 \
    params/wArUser 0 \
    params/wRegion 0 \
  ]
  set_parameter -object $sock -param_list $vals
  update_object -name $sock -bind $main_clk -type "domain"
}

set m_sram [create_object -type socket -name "M_SRAM" -parent $subsystem]
update_object -name $m_sram -bind $main_clk -type "domain"
set vals [list \
  socketFunction MEMORY \
  protocolType AXI4 \
  params/wArId 28 \
  params/wAwId 28 \
  params/wAddr 44 \
  params/wData 128 \
  params/wAwUser 0 \
  params/wArUser 0 \
  params/wRegion 0 \
 ]
set_parameter -object $m_sram -param_list $vals

set debug_sock [create_object -parent $subsystem -type socket -name "NCORE_CSR"]
set_parameter -object $debug_sock -name "socketFunction" -value "EXTERNAL_DEBUG"
update_object -name $debug_sock -bind $main_clk -type domain

# Create CXS port
set cxs [create_object -type cxs_port -name "GIU0_CXS" -parent $subsystem]
update_object -name $cxs -bind $main_clk -type "domain"
set_parameter -object $cxs -name CXS_MAX_CREDIT -value 4

# Set DCE
set ncoreSettingsName $subsystem/NcoreSettings
set_parameter -object $ncoreSettingsName -name dceCount -value 1
set_parameter -object $ncoreSettingsName -name dvmVersionSupport -value "DVM_v8"
set_parameter -object $ncoreSettingsName -name noDVM -value false

## =======================
## Memory Map
## =======================

set memoryMap [create_object -type memory_map -name "mm" -parent $subsystem]

set memorySet [create_object -type memory_set -parent $memoryMap -name MIGS0]
set dMemGrp [create_object -type dynamic_memory_group -parent $memorySet -name MIG00]
set sockets [list $subsystem/SBSX0]
update_object -name $dMemGrp -value_list $sockets -type physicalChannels
set dMemGrp [create_object -type dynamic_memory_group -parent $memorySet -name MIG01]
set sockets [list $subsystem/M_SRAM]
update_object -name $dMemGrp -value_list $sockets -type physicalChannels

set memorySet [create_object -type memory_set -parent $memoryMap -name MIGS1]
set dMemGrp [create_object -type dynamic_memory_group -parent $memorySet -name MIG02]
set sockets [list $subsystem/SBSX0 $subsystem/M_SRAM]
update_object -name $dMemGrp -value_list $sockets -type physicalChannels

set memInterleaveFunc [create_object -type memory_interleave_function -parent $memoryMap -name default_interleave_function]
 set vals [list \
  primaryInterleavingBitOne 8 \
  primaryInterleavingBitTwo 0 \
  primaryInterleavingBitThree 0 \
  primaryInterleavingBitFour 0 \
 ]
 set_parameter -object $memInterleaveFunc -param_list $vals

set boot [create_object -type boot_region -parent $memoryMap -name "boot"]
set_parameter -object $boot -name memoryBase -value 0
set_parameter -object $boot -name memorySize -value 16
update_object -name $boot -type "physicalChannel" -bind $subsystem/H_HND;

set configRegion [create_object -type configuration_region -parent $memoryMap -name default_configuration_region]
 set_parameter -object $configRegion -name memoryBase -value 1073741824
 set_parameter -object $configRegion -name memorySize -value 1024


## =======================
## Structural Design
## =======================

set topology [create_object -type topology -name "ts" -parent $subsystem]
set vals [list \
  nDvmCmdCredits 2 \
  coherentTemplate FourCtrlOneDataTemplate \
  nativeIntfProtEnabled false \
  nGPRA 24 \
  timeOutThreshold 16384 \
  qosEnabled true \
  qosEventThreshold 16 \
  nMainTraceBufSize 64 \
  nTraceRegisters 1 \
  syncDepth 2 \
  useRtlPrefix false \
 ]
set_parameter -object $topology -param_list $vals
set values [list 16'hC000 16'h3000 16'h0C00 16'h0300 16'h00C0 16'h0030 16'h000C 16'h0003 ]
set_parameter -object $topology -name qosMap -value $values

set_attribute -object $topology -name assertionsEnabled -value true

run_generator -name "interface_units" -topology $topology -clock $main_clk;

set sf0 [create_object -type snoop_filter -parent $topology -name "sf0"]
set_parameter -object $sf0 -name nSets            -value 1024
set_parameter -object $sf0 -name nWays            -value 16
set_parameter -object $sf0 -name aPrimaryBits    -value [list 6 7 8 9 10 11 12 13 14 15]
set_parameter -object $sf0 -name aSecondaryBits  -value [list 0 0 0 0 0 0 0 0 0 0]
set_parameter -object $sf0 -name nVictimEntries  -value 2
set_parameter -object $sf0 -name replPolicy      -value RANDOM

for {set i 0} {$i < 16} {incr i} {
    set_parameter -object "${sf0}/sf0_TagMem_way_${i}" -name memoryType -value SRAM
}


# Set AIU unit parameters
set ncunit $topology/RNF
 set vals [list \
  nPerfCounters 4 \
  nNativeCredits 15 \
  nOttCtrlEntries 128 \
  nStshSnpCredits 8 \
  nProcessors 4 \
 ]
 set_parameter -object $ncunit -param_list $vals
update_object -name $ncunit -type snoopFilter -bind $sf0

set ncunit $topology/S0_ADB_GIC_RNI
 set vals [list \
  nPerfCounters 4 \
  nOttCtrlEntries 128
 ]
 set_parameter -object $ncunit -param_list $vals
for {set i 0} {$i < 4} {incr i} {
    set_parameter -object "${ncunit}/OttMem${i}" -name memoryType -value SRAM
}

# Set DII unit parameters
set ncunit $topology/H_HND
 set vals [list \
  nPerfCounters 4 \
  nDiiRbCredits 32 \
  nRttCtrlEntries 32 \
  nWttCtrlEntries 32 \
  nExclusiveEntries 0 \
  nCMDSkidBufSize 80 \
  nCMDSkidBufArb 64 \
 ]
 set_parameter -object $ncunit -param_list $vals
for {set i 0} {$i < 2} {incr i} {
    set_parameter -object "${ncunit}/skidBufferMem${i}" -name memoryType -value SRAM
}

# Set DMI unit parameters
set ncunit $topology/SBSX0
 set vals [list \
  nPerfCounters 4 \
  nDmiRbCredits 64 \
  nRttCtrlEntries 128 \
  nWttCtrlEntries 64 \
  nExclusiveEntries 0 \
  hasSysMemCache true \
  enableReadRspInterleaving false \
  nTagBanks 1 \
  nDataBanks 1 \
  cacheReplPolicy RANDOM \
  nCMDSkidBufSize 64 \
  nCMDSkidBufArb 32 \
  nMrdSkidBufSize 64 \
  nMrdSkidBufArb 32 \
  tagTiming NO_PIPELINE \
  dataTiming ONE_CYCLE_NO_PIPELINE \
 ]
 set_parameter -object $ncunit -param_list $vals
for {set i 0} {$i < 2} {incr i} {
    set_parameter -object "${ncunit}/WriteDataMem${i}" -name memoryType -value SRAM
}
set_parameter -object "${ncunit}/TagMem0" -name memoryType -value SRAM
set_parameter -object "${ncunit}/DataMem0" -name memoryType -value SRAM
set_parameter -object "${ncunit}/CMDReqSbMem0" -name memoryType -value SRAM
set_parameter -object "${ncunit}/MRDReqSbMem0" -name memoryType -value SRAM

set ncunit $topology/M_SRAM
 set vals [list \
  nPerfCounters 4 \
  nDmiRbCredits 64 \
  nRttCtrlEntries 128 \
  nWttCtrlEntries 64 \
  nExclusiveEntries 0 \
  hasSysMemCache false \
  enableReadRspInterleaving false \
  nCMDSkidBufSize 64 \
  nCMDSkidBufArb 32 \
  nMrdSkidBufSize 64 \
  nMrdSkidBufArb 32 \
 ]
 set_parameter -object $ncunit -param_list $vals
for {set i 0} {$i < 2} {incr i} {
    set_parameter -object "${ncunit}/WriteDataMem${i}" -name memoryType -value SRAM
}
set_parameter -object "${ncunit}/CMDReqSbMem0" -name memoryType -value SRAM
set_parameter -object "${ncunit}/MRDReqSbMem0" -name memoryType -value SRAM

# Set DCE unit parameters
for {set i 0} {$i < 1} {incr i} {
  set ncunit "${topology}/dce${i}"
  set vals [list \
    nPerfCounters 4 \
    nDceRbCredits 32 \
    nAiuSnpCredits 7 \
    nAttCtrlEntries 64 \
    nCMDSkidBufSize 64 \
    nCMDSkidBufArb 32 \
    tagTiming NO_PIPELINE \
  ]
  set_parameter -object $ncunit -param_list $vals
  set_parameter -object "${ncunit}/skidBufferMem0" -name memoryType -value SRAM
}

# Set DVE unit parameters
set ncunit $topology/dve0
 set vals [list \
  nPerfCounters 4 \
 ]
 set_parameter -object $ncunit -param_list $vals
for {set i 0} {$i < 2} {incr i} {
    set_parameter -object "${ncunit}/TraceMem${i}" -name memoryType -value SRAM
}

connect_network -name $topology/ndn1
connect_network -name $topology/ndn2
connect_network -name $topology/ndn3
connect_network -name $topology/ndn4
connect_network -name $topology/dn

run_generator -topology $topology -name "interrupt" -clock $main_clk

set params [list atusSynchronousToNetwork true]
create_configuration_units -topology $topology -clock $main_clk

connect_request_csr_network -topology $topology -clock $main_clk
connect_response_csr_network -topology $topology -clock $main_clk

run_generator -topology $topology -name "adapters"

puts "## Processing Mapping -- $base_die"
run_task -name move_to_next_state

set ncunit $topology/H_HND
 set_parameter -object $ncunit -name nLargestEndPoint -value 4

set ncunit $topology/sys_dii
 set_parameter -object $ncunit -name nLargestEndPoint -value 4

set ncunit $topology/SBSX0
 set vals [list \
  useAtomic false \
  DmiQoSThVal 8 \
  nDmiWttQoSRsv 1 \
  nDmiRttQoSRsv 1 \
  ImplementationParameters/nAddrTransRegisters 0 \
  ImplementationParameters/nWayPartitioningRegisters 0 \
  Cache/nSets 4096 \
  Cache/nWays 8 \
  Cache/useScratchpad false \
 ]
 set_parameter -object $ncunit -param_list $vals
 set values [list 6 7 9 10 11 12 13 14 15 16 17 18 ]
 set_parameter -object $ncunit -name Cache/SelectInfo/PriSubDiagAddrBits -value $values
 set values [list 0 0 0 0 0 0 0 0 0 0 0 0 ]
 set_parameter -object $ncunit -name Cache/SelectInfo/SecSubRows -value $values
 set values [list ]
 set_parameter -object $ncunit -name Cache/SelectInfo/TagBankSelBits -value $values
 set values [list ]
 set_parameter -object $ncunit -name Cache/SelectInfo/DataBankSelBits -value $values

set ncunit $topology/M_SRAM
 set vals [list \
  useAtomic false \
  DmiQoSThVal 8 \
  nDmiWttQoSRsv 1 \
  nDmiRttQoSRsv 1 \
  ImplementationParameters/nAddrTransRegisters 0 \
 ]
 set_parameter -object $ncunit -param_list $vals

for {set i 0} {$i < 1} {incr i} {
  set ncunit "${topology}/dce${i}"
  set vals [list \
    ImplementationParameters/nTaggedMonitors 0 \
  ]
  set_parameter -object $ncunit -param_list $vals
}

# Export the intermediate Json
file mkdir ./json
set intermediateJson ./json/BASE_DIE.top.level.json
export_design -format "flat" -file $intermediateJson

clear_chiplet_selection

run_task -name move_to_next_state
# alternatively: move_forw_to_state "Export/Global Export"

export_design -format "flat_assembly" -assembly $die_assembly -file ./json/die_assembly.json


# This proc is designed for DV flows and to be used only when maestro client
# is launched from run_maestro
proc run_dv_gen_collateral {a_name} {
  global env
  if { [info exists env(USE_MAESTRO_SERVER)] != 1 || $env(USE_MAESTRO_SERVER) == "false" } {
    puts "run_dv_gen_collateral: USE_MAESTRO_SERVER is not defined, will not run maestro-server"
    return
  }


  if {$env(USE_MAESTRO_SERVER)=="true"} {
    gen_global_collateral -file server_output.tgz
  } else {
    gen_global_collateral -file server_output.tgz -server_exec $env(USE_MAESTRO_SERVER)
  }
  set tgzFile server_output.$a_name.tgz
  exec tar xvfz $tgzFile
}
run_dv_gen_collateral $assembly_name

puts "Design complete"

exit
