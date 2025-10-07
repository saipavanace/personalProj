#!/bin/bash -f
config_name=`basename $1 | sed -e 's/.apf//g'`
echo $config_name
config_dir=`pwd`/$config_name
mkdir -p $config_dir

/engr/dev/tools/script/run_with_xvfb.sh $WORK_TOP/../codegen/bin/generatecli.js -k $config_dir/$config_name.json $1 -s -u $config_dir/user.txt -f $config_dir -r $config_dir/arch.txt -c $config_dir/$config_name``_coh.v -t $config_dir/top.v
cd $WORK_TOP/dv/sub_sys/tb
./customer1.js < customerflist.json >../../../tb/sub_sys/tb/index.js
cd $WORK_TOP
npm i
mkdir -p $config_dir/tb
node $WORK_TOP/dv/scripts/dvCustomer.js $config_dir/$config_name.json $config_dir
cd $config_dir/tb
make
