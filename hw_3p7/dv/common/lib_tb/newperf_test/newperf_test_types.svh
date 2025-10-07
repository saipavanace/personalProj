/////////////////////////////////////////////////////////////
// File Name    :   perf_test_types.svh
// Author       :   Cyrille LUDWIG
// Description  :   Typedefs used by perf_test_scoreboard Scoreboard
/////////////////////////////////////////////////////////////
typedef enum {CHI,ACE,AXI,NONE} e_pt_type_itf;
typedef struct { int qos; int txnid; time timestamp;} s_txn_timestamp;
typedef struct { int qos; int txnid; int cycles;}  s_txn_cycle;
`undef LABEL_NEWPERF
`define LABEL_NEWPERF $sformatf("Ncore Block Name = %0s with (Interface %0s) NewPerf test SCB\n",aiu_name,cfg_e_type.name)
