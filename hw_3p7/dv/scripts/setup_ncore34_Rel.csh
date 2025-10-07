#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif
setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/prerelease/maestro/Ncore_3.4.0-10105/bin:/engr/prerelease/maestro/Ncore_3.4.0-10105/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/prerelease/maestro/Ncore_3.4.0-10105/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore34_Rel_repos


