#!/bin/bash
printf -v date '%(%Y-%m-%d-%H-%M-%S)T\n' -1 
mkdir $WORK_TOP/$date
runsim -e dmi -t random -i 1 -d $WORK_TOP/$date -g

cd $WORK_TOP/$date
cd ./regression/*/debug/dmi/
echo `pwd`
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config1/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config2/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config3/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config4/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config5/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config6/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config7/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config8/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config7_snps/exe/output/rtl/design -sv
$WORK_TOP/rtl/scripts/lint/run_lint --local -u "dmi_a.flist" -t -l -w ./config7_snps0/exe/output/rtl/design -sv

code ./*/exe/output/rtl/design/lint/consolidated_reports/lint_lint_rtl/moresimple.rpt