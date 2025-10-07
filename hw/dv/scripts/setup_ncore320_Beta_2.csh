#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/dev/releases/maestro/build/releases/Ncore_3_Beta_20210903_2/bin:/engr/dev/releases/maestro/build/releases/Ncore_3_Beta_20210903_2/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/dev/releases/maestro/build/releases/Ncore_3_Beta_20210903_2/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore320_Beta_2_repos


