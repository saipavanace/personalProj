work=`echo $WORK_TOP`
export USE_TACHL_DEBUG=true
rm $WORK_TOP/debug/giu/chiplet1/exe/ -r
cd $WORK_TOP/../m-ncore
unset WORK_TOP
npm run prepublish
export WORK_TOP=$work
node ./index.js -j $WORK_TOP/rtl/giu/json/chiplet1.json -r $WORK_TOP/debug/giu/chiplet1/exe/
cd $WORK_TOP/dv/giu/
make -f ./utils/Makefile build


