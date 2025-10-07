////////////////////////////////////////////////////////////////////////////////
//
// fsys_coverage 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
class Fsys_coverage;

    Fsys_smi_coverage smi;
    Fsys_smi_coverage_atomic atomic;
    Fsys_aiu_qos_coverage aiu_qos;
    Fsys_dmi_coverage dmi;
    Fsys_native_itf_coverage native_itf;
    Fsys_xxxcorr_err_coverage xxxcorr_err;
    Fsys_sftcrdt_coverage sftcrdt;
    Fsys_if_parity_chk_coverage if_parity_chk;
    Fsys_sys_event_coverage sys_event;

    function new();
       `ifndef FSYS_COVER_ONLY_ATOMIC
        smi = new();
        aiu_qos = new();
        dmi = new();
        sftcrdt = new();
        if_parity_chk = new();
        xxxcorr_err = new();
        sys_event = new();
        `endif //FSYS_COVER_ONLY_ATOMIC
        native_itf = new();
        atomic = new();
    endfunction:new

endclass:Fsys_coverage
