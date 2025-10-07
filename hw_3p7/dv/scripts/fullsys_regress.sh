#!/bin/bash

configs="1 2 3 4 5a 6 7 8 9 10 11 16 17 18"
today=$(date +%m_%d_%Y)
out_path=/scratch2/thbj/cust_env_test_1_27_16
fsys_configs_path=~/working/test_projects/updated_fsys_configs/
conductor_path=~/working/client/conductor
for i in $configs; do
    echo "Generating fsys_config$i into generated_rtl/fsys_config${i}_$today"
    $conductor_path $fsys_configs_path/fsys_config$i.apf -g -o ${out_path}/fsys_config${i}_$today
done

for i in $configs; do
    cd ${out_path}/fsys_config${i}_$today/tb/ && echo "Running TB in $(pwd)" && make && cd ../run/ && grep -r "UVM PASSED" * >& passing_tests && grep -r "UVM FAILED" * >& failing_tests
done

touch $out_path/all_tests

for i in $configs; do
    cd ${out_path}/fsys_config${i}_$today/run && echo "All Tests from $out_path/psys_config$i" >> $out_path/all_tests 2>&1 && cat passing_tests >> $out_path/all_tests 2>&1 && cat failing_tests >> $out_path/all_tests 2>&1 && echo "" >> $out_path/all_tests 2>&1
done
