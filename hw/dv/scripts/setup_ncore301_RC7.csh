#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/dev/releases/maestro/build/releases/maestro-1.1.0-RC7-2021-04-29/bin:${PATH}"
setenv MAESTRO_TCLLIB        /engr/dev/releases/maestro/build/releases/maestro-1.1.0-RC7-2021-04-29/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore301_RC7_repos


