#!/bin/bash
cov_dir=$1
test_results=$2
has_qverify=$(which qverify)
if [ -x "$has_qverify" ] ; then
    echo $has_qverify
else 
    export PATH=/engr/dev/tools/mentor/qformal-2020.1/linux_x86_64/bin:$PATH
fi
node $WORK_TOP/dv/scripts/gatherCoverage.js $2 $1
code_cov=`find $1 | grep code_coverage_totals.txt`
#echo $code_cov
echo '' > $1/code_cov_tot.txt
for line in $code_cov; do
    condition=`grep Conditions $line | awk '{print $5}'`
    expression=`grep Expressions $line | awk '{print $5}'`
    statement=`grep Statement $line | awk '{print $5}'`
    echo "$line Condition:$condition Expression:$expression Statement:$statement" >> $1/code_cov_tot.txt
done
grep -e "TOTAL COVERGROUP COVERAGE" $1/*func_coverage_totals.txt > $1/function_cov_tot.txt

