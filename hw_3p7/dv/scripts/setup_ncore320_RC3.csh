#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/dev/releases/maestro/build/releases/Ncore_3.2.0_RC3/bin:/engr/dev/releases/maestro/build/releases/Ncore_3.2.0_RC3/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/dev/releases/maestro/build/releases/Ncore_3.2.0_RC3/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore320_RC3_repos


