#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/dev/releases/maestro/build/releases/Ncore_3_Beta_20210708_1/bin:${PATH}"
setenv MAESTRO_TCLLIB        /engr/dev/releases/maestro/build/releases/Ncore_3_Beta_20210708_1/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore320_Beta_1_repos


