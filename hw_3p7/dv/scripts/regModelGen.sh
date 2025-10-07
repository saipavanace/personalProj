#!/bin/csh
#===============================================
# This is script is used to generate the 
# ralegen model
#
#===============================================


#AIU Register Model
ralgen -uvm -l sv -t Coherent_Agent_Interface_Unit -o aiu_register -ipxact $WORK_TOP/dv/common/lib_tb/Concerto_Software_Model_Registers.xml

#IO Cache Register Model
ralgen -uvm -l sv -t Non_coherent_Bridge_Unit -o ncbu_register -ipxact $WORK_TOP/dv/common/lib_tb/Concerto_Software_Model_Registers.xml

#DMI Register Model
ralgen -uvm -l sv -t Coherent_Memory_Interface_Unit -o dmi_register -ipxact $WORK_TOP/dv/common/lib_tb/Concerto_Software_Model_Registers.xml


#DCE Register Model
ralgen -uvm -l sv -t Directory_Unit -o dce_register -ipxact $WORK_TOP/dv/common/lib_tb/Concerto_Software_Model_Registers.xml

#System Level Register Model 
ralgen -uvm -l sv -t Coherent_Subsystem -o coherent_subsystem_register -ipxact $WORK_TOP/dv/common/lib_tb/Concerto_Software_Model_Registers.xml

#Fault Controller Register Model 
ralgen -uvm -l sv -t Resiliency -o fc_register -ipxact $WORK_TOP/dv/common/lib_tb/fsys_config11_spirit.xml
