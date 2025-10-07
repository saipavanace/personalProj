#!/usr/bin/bash -x
# $1 is the target path and $2 is the source coverage path; $3 is the path to the older coverage database that needs to be merged

echo "Set up coverage subdirectories"

if [[ -d $WORK_TOP/$1 ]]; then
    echo "Removing coverage directory"
    rm -rf $WORK_TOP/$1
fi

mkdir -p $WORK_TOP/$1

for i in 128b_ecc 128b_parity 256b 256b_narrow_axid 64b 64b_wXttCtrlEntry; do
    mkdir -p $WORK_TOP/$1/dii_${i}_coverage
    node $WORK_TOP/../hw-lib/js/find_pat.js -i $WORK_TOP/$2/debug/dii/${i}/rtl -p $WORK_TOP/rtl/dii/exclusions/dii_${i}_waiver.json -o $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do -tp /tb_top/dut -tb dii_top_a
    echo " "                                      >> $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do
    echo "coverage exclude -scope /tb_top/dut/dup_unit -recursive" >> $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do
    echo " "                                      >> $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do
    echo "coverage save dii_${i}_final_excl.ucdb" >> $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do
    echo "quit -f"                                >> $WORK_TOP/$1/dii_${i}_coverage/dii_${i}_rtl_exclusion.do
    cp $WORK_TOP/$2/debug/dii/${i}/coverage/dii_merge_${i}.ucdb $WORK_TOP/$1/dii_${i}_coverage/merged_dii_regression.ucdb
done

for i in 128b_ecc 128b_parity 256b 256b_narrow_axid 64b 64b_wXttCtrlEntry; do
    cd $WORK_TOP/$1/dii_${i}_coverage
    vcover report merged_dii_regression.ucdb -instance=/tb_top/dut. -recursive -code scef -cvg -output dii_${i}_merged.rpt
    vsim -c -viewcov merged_dii_regression.ucdb -do $WORK_TOP/rtl/dii/exclusions/dii_${i}_cc.do -do "coverage save merged_with_cc_exclusions.ucdb; quit -f" >& dii_${i}_cc_exclusion.log
    vcover merge -du dii_wtt_entry_a -recursive ${i}_total_dii_wtt_entry_a.ucdb merged_with_cc_exclusions.ucdb >& dii_${i}_total_dii_wtt_etnry_a.log
    vcover merge -install /tb_top/dut/dii_unit/wtt/WTT_ENTRIES[0] ${i}_hierarchy_added_dii_wtt_entry_a.ucdb ${i}_total_dii_wtt_entry_a.ucdb >& dii_${i}_hierarchy_added_dii_wtt_entry_a.log
    vcover merge -du dii_rtt_entry_a -recursive ${i}_total_dii_rtt_entry_a.ucdb merged_with_cc_exclusions.ucdb >& dii_${i}_total_dii_rtt_entry_a.log
    vcover merge -install /tb_top/dut/dii_unit/rtt/RTT_ENTRIES[0] ${i}_hierarchy_added_dii_rtt_entry_a.ucdb ${i}_total_dii_rtt_entry_a.ucdb >& dii_${i}_hierarchy_added_dii_rtt_entry_a.log
    vcover merge final_dii_xtt_${i}_merged.ucdb ${i}_hierarchy_added_dii_wtt_entry_a.ucdb ${i}_hierarchy_added_dii_rtt_entry_a.ucdb merged_with_cc_exclusions.ucdb >& final_dii_xtt_${i}_merged.log
    vsim -c -viewcov final_dii_xtt_${i}_merged.ucdb -do $WORK_TOP/rtl/dii/exclusions/dii_${i}_exclusion.do >& dii_${i}_exclusion.log
    vcover report final_dii_xtt_${i}_merged.ucdb -instance=/tb_top/dut. -recursive -code scef -cvg -output dii_${i}_final_xtt.rpt
    vsim -c -viewcov final_dii_xtt_${i}_merged.ucdb -do dii_${i}_rtl_exclusion.do >& dii_${i}_rtl_exclusion.log
    vcover report dii_${i}_final_excl.ucdb -instance=/tb_top/dut. -recursive -code scef -cvg -output dii_${i}_final_excl.rpt
    vcover report dii_${i}_final_excl.ucdb -html -output dii_${i}_final_excl
done
