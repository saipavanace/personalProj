#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/prerelease/maestro/Ncore_3.4.2-10112/bin:/engr/prerelease/maestro/Ncore_3.4.2-10112/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/prerelease/maestro/Ncore_3.4.2-10112/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore342_Rel_repos


