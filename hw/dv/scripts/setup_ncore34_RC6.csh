#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/prerelease/maestro/Ncore_3.4_RC6-10088/bin:/engr/prerelease/maestro/Ncore_3.4_RC6-10088/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/prerelease/maestro/Ncore_3.4_RC6-10088/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore34_RC6_repos


