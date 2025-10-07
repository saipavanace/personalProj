# Steps to generate output files from source achl files

npm i achl //installs achl in the current directory ; if this command does not work check achl website for the latest command

setenv $ACHL_HOME <your install dir>/node_modules

$ACHL_HOME/.bin/ac -p <list of .js files seperated by commas>  <.js filename> -o <output filename>.v


## Steps to Generate dce.v

%setenv $ACHL_HOME /home/savitha/ACHL/node_modules
%$ACHL_HOME/.bin/ac -p ../../lib/src/concerto_system_params.js dce_wrapper.achl.js -o dce.v
