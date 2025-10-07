#!/usr/bin/bash -x
# $1 is the path to the current run
# $2 is the path to the previous run to merge the ucdb from

for i in 128b_ecc 128b_parity 256b 256b_narrow_axid 64b 64b_wXttCtrlEntry; do
    cp $2/debug/dii/${i}/coverage/dii_merge_${i}.ucdb $1/debug/dii/${i}/coverage/dii_merge_${i}_prev_run.ucdb
    vsim -c -viewcov $1/debug/dii/${i}/coverage/dii_merge_${i}_prev_run.ucdb -do "coverage edit -rename -srcfilestring $2/debug/dii/${i}/rtl $1/debug/dii/${i}/rtl; coverage save $1/debug/dii/${i}/coverage/dii_${i}_prev_run_rtl_srcpath_updated.ucdb; quit -f"
    vcover merge $1/debug/dii/${i}/coverage/dii_merge_${i}.ucdb $1/debug/dii/${i}/coverage/merged_dii_${i}.ucdb $1/debug/dii/${i}/coverage/dii_${i}_prev_run_rtl_srcpath_updated.ucdb >& $1/debug/dii/${i}/coverage/dii_${i}_merge.log
done
