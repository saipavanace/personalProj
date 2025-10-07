###########################################################################################
# Description
#
# This configuration uses the following
#  Template -> ThreeSysThreeMemTemplate
#  CAIUs    -> 2 CHI-B
#  NCAIUs   -> 2 AXI4, 1 ACE5-LITE
#  CCEs     -> 2
#  DMIs     -> 3
#  DIIs     -> 1
#
#####################################################################################
# Main
#####################################################################################
# PHASE 1 
# Create project
# Create chip
# Create Power
# Create Clock
# *************************************************************************************
#Create project
set designName native_flow
set fileName $designName.mpf
if {[file exists $fileName] == 1} {
    file delete $fileName
}
set project [create_project -name $designName -license_token Arteris/Dev]

set_custom_attribute -object $project -name "echoAttributeValue" -value true

#create chip
set chip    [create_object -type chip    -name "chip"   -parent $project]

set frequency 1600; #MHz
set voltage 1000;#mV

#Create power
# Create a power region
set pregion [create_object -name "pwr_reg_x" -type power_region    -parent $chip]

# Set a voltage on the power region
set_attribute -object $pregion -name voltage -value $voltage

# Create the power domain
set pdomain [create_object -name "pwr_dom_x" -type power_domain    -parent $pregion]

#Set the gating on the power domain
set_attribute -object $pdomain -name gating -value always_on

#Create Clock
# Create a clock region
set clkregion [create_object -name "clk_reg" -type clock_region    -parent $chip]

# Set the blkClkGating to true
set_attribute -object $clkregion -name unitClockGating -value true

# Bind the power region to the clock region
update_object -name $clkregion -bind $pregion -type "powerRegion"

# Set the frequency on the clock region
set_attribute -object $clkregion -name frequency -value $frequency

# Create a clock domain
set clkdomain [create_object -name "clk_dom" -type clock_domain    -parent $clkregion]

#Bind the clock domain to the power domain
update_object -name $clkdomain -bind $pdomain -type "powerDomain"

#Create a clock subdomain
set clocksubdomain [create_object -name "clk_subdom" -type clock_subdomain -parent $clkdomain]

#####################################################################################
# PHASE 2
# Create system
# Create subsystem
# Create sockets
# Create memory map
#*************************************************************************************
# Create a system
set system  [create_object -type system  -name "system" -parent $chip]

#Create a subsystem
set subsystem  [create_object -type subsystem  -name "subsystem" -parent $system]
set_attribute -object $subsystem -name subsystemType -value ARTERIS_COHERENT

# Create the sockets
##########################################################################

#DCE count
set_attribute -object $subsystem/NcoreSettings -name dceCount -value 2

#Create the CHI-B socket
set sock [create_object -type socket -name "caiu0" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType CHI-B \
                                      socketFunction INITIATOR \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/NodeID_Width 7 \
                                      params/enPoison false \
                                      params/REQ_RSVDC 0]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the CHI-B socket
set sock [create_object -type socket -name "caiu1" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType CHI-B \
                                      socketFunction INITIATOR \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/NodeID_Width 7 \
                                      params/enPoison false \
                                      params/REQ_RSVDC 0]

update_object -name $sock -bind $clocksubdomain -type domain

#Create the AXI4-INITIATOR socket
set sock [create_object -type socket -name "ncaiu0" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction INITIATOR \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 10 \
                                      params/wAwId 10]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the AXI4-INITIATOR socket
set sock [create_object -type socket -name "ncaiu1" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction INITIATOR \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 10 \
                                      params/wAwId 10]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the ACE5-Lite-INITIATOR socket
set sock [create_object -type socket -name "ncaiu2" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType ACE5-Lite \
                                      socketFunction INITIATOR \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 10 \
                                      params/wAwId 10]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the DMI socket
set sock [create_object -type socket -name "dmi0" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction "MEMORY" \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 15 \
                                      params/wAwId 15]
update_object -name $sock -bind $clocksubdomain -type domain
#Create the DMI socket
set sock [create_object -type socket -name "dmi1" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction "MEMORY" \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 15 \
                                      params/wAwId 15]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the DMI socket
set sock [create_object -type socket -name "dmi2" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction "MEMORY" \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 15 \
                                      params/wAwId 15]
update_object -name $sock -bind $clocksubdomain -type domain

#Create the DII socket
set sock [create_object -type socket -name "dii0" -parent $subsystem]
set_attribute -object $sock -value_list [list protocolType AXI4 \
                                      socketFunction "PERIPHERAL" \
                                      params/wAddr 48 \
                                      params/wData 128 \
                                      params/wArUser 0 \
                                      params/wAwUser 0 \
                                      params/wArId 15 \
                                      params/wAwId 15]
update_object -name $sock -bind $clocksubdomain -type domain

# Mandatory APB debug Socket
set debug_sock [create_object -parent $subsystem -type socket -name "debug_apb"]
set_attribute -object $debug_sock -name "socketFunction" -value "EXTERNAL_DEBUG"
update_object -name $debug_sock -bind $clocksubdomain -type domain

#Create Memory Map

#create the object MemoryMap
set memorymap [create_object -type memory_map -name "mm" -parent $subsystem]

# DCE interleaving selection bits since we have 2 DCEs
set_attribute -object $memorymap -name dceInterleavingBits -value_list [list 40]

# Create the memory groups under memorySet0
set memorySet0 [create_object -type memory_set -parent $memorymap -name "memorySet0"]
set memoryGroup00 [create_object -type dynamic_memory_group -parent $memorySet0 -name "mg0"]
set memoryGroup01 [create_object -type dynamic_memory_group -parent $memorySet0 -name "mg1"]

#Assign DMI sockets to the memory group00
update_object -name $memoryGroup00 -value_list [list $subsystem/dmi0 $subsystem/dmi1] -type physicalChannels
update_object -name $memoryGroup01 -value_list [list $subsystem/dmi2] -type physicalChannels

# Create the memory groups under memorySet1
set memorySet1 [create_object -type memory_set -parent $memorymap -name "memorySet1"]
set memoryGroup10 [create_object -type dynamic_memory_group -parent $memorySet1 -name "mg0"]
set memoryGroup11 [create_object -type dynamic_memory_group -parent $memorySet1 -name "mg1"]
set memoryGroup12 [create_object -type dynamic_memory_group -parent $memorySet1 -name "mg2"]

#Assign DMI sockets to the memory group01
update_object -name $memoryGroup10 -value_list [list $subsystem/dmi0] -type physicalChannels
update_object -name $memoryGroup11 -value_list [list $subsystem/dmi1] -type physicalChannels
update_object -name $memoryGroup12 -value_list [list $subsystem/dmi2] -type physicalChannels

# Create 2-way interleaving functions
set twoWayIntFunc1 [create_object -type memory_interleave_function -name "twowayif1" -parent $memorymap]
set_attribute -object $twoWayIntFunc1 -name primaryInterleavingBitOne -value 8
set twoWayIntFunc2 [create_object -type memory_interleave_function -name "twowayif2" -parent $memorymap]
set_attribute -object $twoWayIntFunc2 -name primaryInterleavingBitOne -value 9

#create BootRegion
set boot [create_object -type boot_region -parent $memorymap -name "bootregion"]

#Set the base address on the bootregion
set_attribute -object $boot -name memoryBase -value [expr 0x0]

#Set the memory size on the bootregion
set_attribute -object $boot -name memorySize -value [expr 0x4000]

#access boot code from DMI
update_object -name $boot -bind $memoryGroup00 -type "memoryGroup"

#create CSR region
set csr_region [create_object -type configuration_region -parent $memorymap -name "csrregion"]

# Set the base address for CSR region
set_attribute -object $csr_region -name memoryBase -value [expr [expr 0x2e6e4000]*1024]; # in bytes


#####################################################################################
# PHASE 3: ARCHITECTURAL DESIGN
# Create topology
# Select coherent Template
# Auto generate units
# Set the node positions of the units in the topology
# Generate topology for routing
# Auto generate adapters
# Auto generate the Control and Status Register (CSR) network
# *************************************************************************************
#Create the topology
set topology [create_object -type topology -name "topology" -parent $subsystem]

#Select Template
set_attribute -object $topology -name coherentTemplate -value "TwoCtrlOneDataTemplate"

puts "############################################"
puts "####     Interface Unit Automation.     ####"
puts "############################################"
#Auto generate units
#Run automatic generation of Ncore units. The clock is given for the DCE and the DVE. 
#The params option defines the number of DCEs
run_generator -name "interface_units" -topology $topology -clock $clocksubdomain

puts "############################################"
puts "####  Interface Unit Automation Done.   ####"
puts "############################################"

#Creating a mesh of 4x4
# Set location of units
set caius [get_objects -parent $chip -type caiu]
set caiu0 [lindex $caius 0]
set_node_position -object $caiu0 -x 0 -y 0
set caiu1 [lindex $caius 1]
set_node_position -object $caiu1 -x 0 -y 1

set diis [get_objects -parent $chip -type dii]
set dii0 [lindex $diis 0]
set_node_position -object $dii0 -x 0 -y 2
set sys_dii   [get_objects -parent $chip -type dii -subtype configDii]
set_node_position -object $sys_dii -x 0 -y 3

set dmis [get_objects -parent $chip -type dmi]
set dmi0 [lindex $dmis 0]
set_node_position -object $dmi0 -x 1 -y 0
set dmi1 [lindex $dmis 1]
set_node_position -object $dmi1 -x 1 -y 1
set dmi2 [lindex $dmis 2]
set_node_position -object $dmi2 -x 1 -y 2

set dces [get_objects -parent $chip -type dce]
set dce0 [lindex $dces 0]
set_node_position -object $dce0 -x 1 -y 3
set dce1 [lindex $dces 1]
set_node_position -object $dce1 -x 2 -y 0

set ncaius [get_objects -parent $chip -type ncaiu]
set ncaiu0 [lindex $ncaius 0]
set_node_position -object $ncaiu0 -x 2 -y 2
set ncaiu1 [lindex $ncaius 1]
set_node_position -object $ncaiu1 -x 2 -y 3
set ncaiu2 [lindex $ncaius 2]
set_node_position -object $ncaiu2 -x 3 -y 0

set dves [get_objects -parent $chip -type dve]
set dve0 [lindex $dves 0]
set_node_position -object $dve0 -x 2 -y 1

#Create 2 snoopfilters
set sf0 [create_object -type snoop_filter -parent $topology -name "sf0"]
set sf1 [create_object -type snoop_filter -parent $topology -name "sf1"]

#Set parameters on the snoopfilters
set_attribute -object $sf0 -name nSets            -value 512
set_attribute -object $sf0 -name nWays            -value 20
set_attribute -object $sf0 -name aPrimaryBits    -value_list [list 16 17 18 19 20 21 22 25]
set_attribute -object $sf0 -name aSecondaryBits  -value_list [list  0  0  0  0  0  0  0  0]
set_attribute -object $sf0 -name nVictimEntries  -value 0

set_attribute -object $sf1 -name nSets            -value 512
set_attribute -object $sf1 -name nWays            -value 20
set_attribute -object $sf1 -name aPrimaryBits    -value_list [list 16 17 18 19 20 21 22 25]
set_attribute -object $sf1 -name aSecondaryBits  -value_list [list  0  0  0  0  0  0  0  0]
set_attribute -object $sf1 -name nVictimEntries  -value 0

#Assign CAIUS to Snoopfilter 0 (sf0)
update_object -name $caiu0 -type snoopFilter -bind $sf0
update_object -name $caiu1 -type snoopFilter -bind $sf0

# Set ProxyCache on NCAIUs 0, 1
set_attribute -object $ncaiu0 -name hasProxyCache -value true
set_attribute -object $ncaiu1 -name hasProxyCache -value true

#Assign NCAIUS to Snoopfilter 1 (sf1)
update_object -name $ncaiu0 -type snoopFilter -bind $sf1
update_object -name $ncaiu1 -type snoopFilter -bind $sf1

puts "############################################"
puts "####          Mesh Generation.          ####"
puts "############################################"

# Auto Generate mesh routes
# All the switches in the mesh are buffered switches by default.

#Specify the size of the square mesh
set meshSize 4

#Specify the datawidth of the network
set datawidth 128

# Access all the networks under the chip
set networks [get_objects -parent $chip -type network]


foreach net $networks {
  # Skip mesh generation if it is CSR network
  set request  [query_object -object $net -type "csr_request"]
  set response [query_object -object $net -type "csr_response"]
  if {$request == "true" || $response == "true"} {
    continue
  }

  set_context -name $net
  set pos [string last "/" $net]
  set nam [string range $net $pos+1 end]

  # Generate the mesh only on Data network and Non-data networks
  # Create the mesh generator. Assign the datawidth which is needed for the data network. 
  set dataWidth 0
  if {$nam == "dn"} {
    set dataWidth $datawidth
  }

  set route_params [list type mesh name $nam meshx $meshSize meshy $meshSize network $net dataWidth $dataWidth]
  run_generator -name "regular_topology" -topology $topology -clock $clocksubdomain -params $route_params
}
puts "############################################"
puts "####       Mesh Generation Done.        ####"
puts "############################################"

#Run automatic generator for the CSR network
create_configuration_units -topology $topology -clock $clocksubdomain
connect_request_csr_network -topology $topology -clock $clocksubdomain
connect_response_csr_network -topology $topology -clock $clocksubdomain

puts "############################################"
puts "####      CSR Insertion Automation.     ####"
puts "############################################"


puts "############################################"
puts "### Adapter insertion.   ####"
puts "############################################"

#Run automatic generator for insertion of adapters
run_generator -topology $topology -name "adapters"

puts "############################################"
puts "### Adapter insertion Done.   ####"
puts "############################################"

#Run automatic generator for interrupt accumulator
run_generator -topology $topology -name "interrupt" -clock $clocksubdomain 

puts "############################################"
puts "####   Pre map parameters               ####"
puts "############################################"

# atus
# Extract APB-ATUs in apbAtus
# Extract AXI-ATUs in axiAtus

# The ATUs are automatically created in the CSR(Control and Status Registers) Network. 

set objects [get_objects -type atu -parent $chip]
set axiAtus [list]
set apbAtus [list]
foreach atu $objects {
   set sk [get_objects -parent $atu -type socket]
   set func [get_parameter -object $sk -name socketFunction]
   if {[string compare $func "CONFIGURATION"] == 0} {
       lappend apbAtus $atu
   } elseif {[string compare $func "CONFIG_INTERFACE"] == 0} {
       lappend axiAtus $atu
   }
}

#-------------------------------------------------------------------
#System parameters
#-------------------------------------------------------------------
set_attribute -object $topology -name nDvmCmdCredits -value 2
set_attribute -object $topology -name nGPRA -value 6

#-----------------------------------------------------------------------
# Unit level parameters
#-----------------------------------------------------------------------

#-----------------------------------------------------------------
# PREMAP for DCE0
#---------------------------------------------------------------
set_attribute -object $dce0 -name nAttCtrlEntries    -value 48
set_attribute -object $dce0 -name nDceRbCredits      -value 2
set_attribute -object $dce0 -name nAiuSnpCredits     -value 2
#Test max values
set_attribute -object $dce0 -name nCMDSkidBufSize    -value 768
set_attribute -object $dce0 -name nCMDSkidBufArb     -value 256
#-----------------------------------------------------------------
# PREMAP for DCE1
#---------------------------------------------------------------
set_attribute -object $dce1 -name nAttCtrlEntries    -value 48
set_attribute -object $dce1 -name nDceRbCredits      -value 2
set_attribute -object $dce1 -name nAiuSnpCredits     -value 2
#Test max values
set_attribute -object $dce1 -name nCMDSkidBufSize    -value 768
set_attribute -object $dce1 -name nCMDSkidBufArb     -value 256

#-----------------------------------------------------------------
# PREMAP for CAIUS
#-----------------------------------------------------------------
#Set the premap  attributes on the caiu0
set_attribute -object $caiu0 -name nNativeCredits        -value 15
set_attribute -object $caiu0 -name nOttCtrlEntries       -value 48
set_attribute -object $caiu0 -name nStshSnpCredits       -value 2
set_attribute -object $caiu0 -name nProcessors           -value 2

#Set the premap  attributes on the caiu1
set_attribute -object $caiu1 -name nOttCtrlEntries   -value 48
set_attribute -object $caiu1 -name nProcessors       -value 2

#-----------------------------------------------------------------
# PREMAP for NCAIUS
#-----------------------------------------------------------------
#Set the premap  attributes on the ncaiu0
#-----------------------------------------------------------------
set_attribute -object $ncaiu0 -name nOttCtrlEntries  -value 64

set_attribute -object $ncaiu0 -name nTagBanks -value 2 
set_attribute -object $ncaiu0 -name nDataBanks -value 2
set_attribute -object $ncaiu0 -name cacheReplPolicy -value "NRU"

#------------------------------------------------------------------------
# 2 Tag_Memory of NCAIU0
#------------------------------------------------------------------------
set Tagmemories [get_objects -parent $ncaiu0 -type internal_memory -subtype TAG]
set tm0 [lindex $Tagmemories 0]
set tm1 [lindex $Tagmemories 1]
set_attribute -object $tm0 -name memoryType -value "FLOP"
set_attribute -object $tm1 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 2 Data_Memory of NCAIU0
#------------------------------------------------------------------------
set Datamemories [get_objects -parent $ncaiu0 -type internal_memory -subtype DATA]
set dm0 [lindex $Datamemories 0]
set dm1 [lindex $Datamemories 1]

set_attribute -object $dm0 -name memoryType -value "FLOP"
set_attribute -object $dm1 -name memoryType -value "FLOP"

#--------------------------------------------------------------------------
#Set the premap  attributes on the ncaiu1
#---------------------------------------------------------------------------
set_attribute -object $ncaiu1 -name nOttCtrlEntries  -value 48

set_attribute -object $ncaiu1 -name nTagBanks -value 2 
set_attribute -object $ncaiu1 -name nDataBanks -value 2
set_attribute -object $ncaiu1 -name cacheReplPolicy -value "NRU"

#------------------------------------------------------------------------
# 2 Tag_Memory of NCAIU1
#------------------------------------------------------------------------
set Tagmemories [get_objects -parent $ncaiu1 -type internal_memory -subtype TAG]
set tm0 [lindex $Tagmemories 0]
set tm1 [lindex $Tagmemories 1]
set_attribute -object $tm0 -name memoryType -value "FLOP"
set_attribute -object $tm1 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 2 Data_Memory of NCAIU1
#------------------------------------------------------------------------
set Datamemories [get_objects -parent $ncaiu1 -type internal_memory -subtype DATA]
set dm0 [lindex $Datamemories 0]
set dm1 [lindex $Datamemories 1]

set_attribute -object $dm0 -name memoryType -value "FLOP"
set_attribute -object $dm1 -name memoryType -value "FLOP"

#----------------------------------------------------------------------------
#Set the premap  attributes on the ncaiu2 (No Proxy Cache)
#----------------------------------------------------------------------------
set_attribute -object $ncaiu2 -name nOttCtrlEntries  -value 32


#-----------------------------------------------------------------
# PREMAP for DMI
#-----------------------------------------------------------------
#Set the premap attributes on the DMI0
#-----------------------------------------------------------------
set_attribute -object $dmi0 -name nDmiRbCredits      -value 16
set_attribute -object $dmi0 -name nRttCtrlEntries    -value 48
set_attribute -object $dmi0 -name nWttCtrlEntries    -value 32
set_attribute -object $dmi0 -name nCMDSkidBufSize    -value 8
set_attribute -object $dmi0 -name nCMDSkidBufArb     -value 4
set_attribute -object $dmi0 -name nMrdSkidBufSize    -value 8
set_attribute -object $dmi0 -name nMrdSkidBufArb     -value 4

set_attribute -object $dmi0 -name hasSysMemCache -value true
set_attribute -object $dmi0 -name nTagBanks -value 2 
set_attribute -object $dmi0 -name nDataBanks -value 4
set_attribute -object $dmi0 -name cacheReplPolicy -value "NRU"

#------------------------------------------------------------------------
# 2 Tag_Memory of DMI0
#------------------------------------------------------------------------
set Tagmemories [get_objects -parent $dmi0 -type internal_memory -subtype TAG]
set tm0 [lindex $Tagmemories 0]
set tm1 [lindex $Tagmemories 1]
set_attribute -object $tm0 -name memoryType -value "FLOP"
set_attribute -object $tm1 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 4 Data_Memory of DMI0
#------------------------------------------------------------------------
set Datamemories [get_objects -parent $dmi0 -type internal_memory -subtype DATA]
set dm0 [lindex $Datamemories 0]
set dm1 [lindex $Datamemories 1]
set dm2 [lindex $Datamemories 2]
set dm3 [lindex $Datamemories 3]

set_attribute -object $dm0 -name memoryType -value "FLOP"
set_attribute -object $dm1 -name memoryType -value "FLOP"
set_attribute -object $dm2 -name memoryType -value "FLOP"
set_attribute -object $dm3 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 1 Write Data_Memory of DMI0
#------------------------------------------------------------------------
set WrDatamemories [get_objects -parent $dmi0 -type internal_memory -subtype WDATA]
set wrdm0 [lindex $WrDatamemories 0]
set_attribute -object $wrdm0 -name memoryType -value "FLOP"

#-------------------------------------------------------------------------
#Set the premap attributes on the DMI1
#--------------------------------------------------------------------------
set_attribute -object $dmi1 -name nDmiRbCredits      -value 16
set_attribute -object $dmi1 -name nRttCtrlEntries    -value 48
set_attribute -object $dmi1 -name nWttCtrlEntries    -value 32
#check for the default values of dmi1
# set_attribute -object $dmi1 -name nCMDSkidBufSize    -value 8
# set_attribute -object $dmi1 -name nCMDSkidBufArb     -value 4
# set_attribute -object $dmi1 -name nMrdSkidBufSize    -value 8
# set_attribute -object $dmi1 -name nMrdSkidBufArb     -value 4

set_attribute -object $dmi1 -name hasSysMemCache -value true
set_attribute -object $dmi1 -name nTagBanks -value 2 
set_attribute -object $dmi1 -name nDataBanks -value 4
set_attribute -object $dmi1 -name cacheReplPolicy -value "NRU"

#------------------------------------------------------------------------
# 2 Tag_Memory of DMI1
#------------------------------------------------------------------------
set Tagmemories [get_objects -parent $dmi1 -type internal_memory -subtype TAG]
set tm0 [lindex $Tagmemories 0]
set tm1 [lindex $Tagmemories 1]
set_attribute -object $tm0 -name memoryType -value "FLOP"
set_attribute -object $tm1 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 4 Data_Memory of DMI1
#------------------------------------------------------------------------
set Datamemories [get_objects -parent $dmi1 -type internal_memory -subtype DATA]
set dm0 [lindex $Datamemories 0]
set dm1 [lindex $Datamemories 1]
set dm2 [lindex $Datamemories 2]
set dm3 [lindex $Datamemories 3]

set_attribute -object $dm0 -name memoryType -value "FLOP"
set_attribute -object $dm1 -name memoryType -value "FLOP"
set_attribute -object $dm2 -name memoryType -value "FLOP"
set_attribute -object $dm3 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
# 1 Write Data_Memory of DMI1
#------------------------------------------------------------------------
set WrDatamemories [get_objects -parent $dmi1 -type internal_memory -subtype WDATA]
set wrdm0 [lindex $WrDatamemories 0]
set_attribute -object $wrdm0 -name memoryType -value "FLOP"

#------------------------------------------------------------------------
#Set the premap attributes on the DMI2
#--------------------------------------------------------------------------
set_attribute -object $dmi2 -name nDmiRbCredits      -value 16
set_attribute -object $dmi2 -name nRttCtrlEntries    -value 32
set_attribute -object $dmi2 -name nWttCtrlEntries    -value 16
set_attribute -object $dmi2 -name nCMDSkidBufSize    -value 8
set_attribute -object $dmi2 -name nCMDSkidBufArb     -value 4
set_attribute -object $dmi2 -name nMrdSkidBufSize    -value 8
set_attribute -object $dmi2 -name nMrdSkidBufArb     -value 4
set_attribute -object $dmi2 -name hasSysMemCache     -value false

#DII
set diis [get_objects -type dii -parent $chip]
set dii0 [lindex $diis 0]
set sysdii [lindex $diis 1]

#-------------------------------------------------------------------------
#Set the premap attributes on dii0
#-------------------------------------------------------------------------
set_attribute -object $dii0 -name nDiiRbCredits      -value 16
set_attribute -object $dii0 -name nRttCtrlEntries    -value 32
set_attribute -object $dii0 -name nWttCtrlEntries    -value 16
set_attribute -object $dii0 -name nCMDSkidBufSize    -value 8
set_attribute -object $dii0 -name nCMDSkidBufArb     -value 4

puts "##################################################" 
puts "####   Setting Pre map parameters  complete   ####"
puts "##################################################"

puts "############################################"
puts "####   User Design Creation complete.   ####"
puts "############################################"

#Save the project
set fname ${designName}.premap.mpf
save_project -file $fname

########################################################################

run_task -name move_to_next_state

########################################################################
################## Phase 5: Refinement
########################################################################
puts "############################################"
puts "####   Setting post-map parameters.     ####"
puts "############################################"

#DCE settings
#DCE0
set_attribute -object $dce0 -name ImplementationParameters/nTaggedMonitors       -value 4

#DCE1
set_attribute -object $dce1 -name ImplementationParameters/nTaggedMonitors       -value 4

#Ncaiu settings

#Setting parameters related to proxyCache
set_attribute -object $ncaiu0 -name Cache/nSets                              -value 1024
set_attribute -object $ncaiu0 -name Cache/nWays                              -value 8
set_attribute -object $ncaiu0 -name Cache/SelectInfo/PriSubDiagAddrBits      -value_list [list 7 8 9 10 11 12 13 14 15 16]
set_attribute -object $ncaiu0 -name Cache/SelectInfo/SecSubRows              -value_list [list 0 0 0  0  0  0  0  0  0  0]
set_attribute -object $ncaiu0 -name Cache/SelectInfo/TagBankSelBits          -value_list [list 7]
set_attribute -object $ncaiu0 -name Cache/SelectInfo/DataBankSelBits         -value_list [list 8]

set_attribute -object $ncaiu1 -name Cache/nSets                              -value 1024
set_attribute -object $ncaiu1 -name Cache/nWays                              -value 8
set_attribute -object $ncaiu1 -name Cache/SelectInfo/PriSubDiagAddrBits      -value_list [list 7 8 9 10 11 12 13 14 15 16]
set_attribute -object $ncaiu1 -name Cache/SelectInfo/SecSubRows              -value_list [list 0 0 0  0  0  0  0  0  0  0]
set_attribute -object $ncaiu1 -name Cache/SelectInfo/TagBankSelBits          -value_list [list 7]
set_attribute -object $ncaiu1 -name Cache/SelectInfo/DataBankSelBits         -value_list [list 8]

# DMI settings
#DMI0
set_attribute -object $dmi0 -name useAtomic                                           -value true

# Settings for DMI configured with System Memory Cache
set_attribute -object $dmi0 -name Cache/nSets                              -value 1024
set_attribute -object $dmi0 -name Cache/nWays                              -value 16
set_attribute -object $dmi0 -name Cache/useScratchpad                      -value false
set_attribute -object $dmi0 -name Cache/SelectInfo/PriSubDiagAddrBits      -value_list [list 10 11 12 13 14 15 16 17 18 19]
set_attribute -object $dmi0 -name Cache/SelectInfo/SecSubRows              -value_list [list  0  0  0  0  0  0  0  0  0  0]
set_attribute -object $dmi0 -name Cache/SelectInfo/TagBankSelBits          -value_list [list 10]
set_attribute -object $dmi0 -name Cache/SelectInfo/DataBankSelBits         -value_list [list 10 11]

#DMI1
set_attribute -object $dmi1 -name useAtomic                                           -value false

# Settings for DMI configured with System Memory Cache
set_attribute -object $dmi1 -name Cache/nSets                              -value 1024
set_attribute -object $dmi1 -name Cache/nWays                              -value 16
set_attribute -object $dmi1 -name Cache/useScratchpad                      -value false
set_attribute -object $dmi1 -name Cache/SelectInfo/PriSubDiagAddrBits      -value_list [list 10 11 12 13 14 15 16 17 18 19]
set_attribute -object $dmi1 -name Cache/SelectInfo/SecSubRows              -value_list [list  0  0  0  0  0  0  0  0  0  0]
set_attribute -object $dmi1 -name Cache/SelectInfo/TagBankSelBits          -value_list [list 10]
set_attribute -object $dmi1 -name Cache/SelectInfo/DataBankSelBits         -value_list [list 10 11]

#DMI2
set_attribute -object $dmi2 -name useAtomic                                           -value false


#DII settings
set_attribute -object $dii0 -name nLargestEndPoint                              -value 262144


puts "#####################################################"
puts "####   Setting post-map parameters complete.     ####"
puts "#####################################################"

set postmapMpf       ${designName}.mpf
save_project -file $postmapMpf
puts "Design mpf created in $postmapMpf"

#############################################################
# PHASE 6: EXPORT
##############################################################
file mkdir ./json
set intermediateJson ./json/top.level.json

export_design -format flat -file $intermediateJson
puts "Intermediate Json created $intermediateJson"

#GENERATE RTL
#----------------------------------------------------------------------
gen_collateral 

exit
