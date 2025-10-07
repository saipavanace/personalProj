#!/bin/bash -fx
if ( $WORK_TOP == "" ) then
    echo "WORK_TOP is not set"
    exit 1
endif

module unload dev/concerto/by_path_ncore3_7
module load dev/concerto/by_path_ncore3_7_0

setenv ARTERISD_LICENSE_FILE 5281@lic-node0.arteris.com
setenv PATH                  "/engr/prerelease/maestro/Ncore_3.7.0-10055/bin:/engr/prerelease/maestro/Ncore_3.7.0-10055/maestro-server:${PATH}"
setenv MAESTRO_TCLLIB        /engr/prerelease/maestro/Ncore_3.7.0-10055/maestro-doc/examples/tcllib

source $WORK_TOP/dv/scripts/setup_ncore37_Rel_repos


