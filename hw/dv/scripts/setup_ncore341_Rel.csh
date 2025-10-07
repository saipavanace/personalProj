#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/prerelease/maestro/Ncore_3.4.1-10109/bin:/engr/prerelease/maestro/Ncore_3.4.1-10109/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/prerelease/maestro/Ncore_3.4.1-10109/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore341_Rel_repos


