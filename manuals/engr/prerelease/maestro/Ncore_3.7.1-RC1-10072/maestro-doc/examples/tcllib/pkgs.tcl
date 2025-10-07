package require Ts 2.0
package require Caiu 2.0
package require Ncaiu 2.0
package require Dce 2.0
package require Dii 2.0
package require Dmi 2.0
package require Dve 2.0
package require Socket 2.0
package require MeshGenerator 2.0
package require RingGenerator 2.0
package require TorusGenerator 2.0
package require SnoopFilter 2.0
package require Project 2.0
package require Apb_atu 2.0
package require Axi_atu 2.0
package require Fsc 2.0
package require BootRegion 2.0
package require CsrRegion 2.0
package require CsrNetwork 2.0
package require Qos 2.0
package require Interleaving 2.0
package require PipeAdapter 2.0
package require ClockAdapter 2.0
package require Switch 2.0
package require Clock 2.0
package require Power 2.0
package require Symphony 2.0
package require Switch 2.0
package require Safety 2.0

set tcllib_curDir [ file dirname [ file normalize [ info script ] ] ]
source [file join $tcllib_curDir maestro_init.tcl]
