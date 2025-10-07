#!/usr/bin/env bash
# //--------------------------------------------------------------------------------------
# // Copyright(C) 2014-2024 Arteris, Inc. and its applicable subsidiaries.
# // All rights reserved.
# //
# // Disclaimer: This release is not provided nor intended for any chip implementations, tapeouts, or other features of production releases. 
# //
# // These files and associated documentation is proprietary and confidential to
# // Arteris, Inc. and its applicable subsidiaries. The files and documentation
# // may only be used pursuant to the terms and conditions of a signed written
# // license agreement with Arteris, Inc. or one of its subsidiaries.
# // All other use, reproduction, modification, or distribution of the information
# // contained in the files or the associated documentation is strictly prohibited.
# // This product and its technology is protected by patents and other forms of 
# // intellectual property protection.
# //--------------------------------------------------------------------------------------

### save the environment and figure out our path
export > /tmp/user-env-${USER}.bash
script_fullpath=$(realpath $(dirname ${BASH_SOURCE[0]}))
workTop=$(realpath $(dirname '${script_fullpath}')/../../..)
export WORK_TOP=${workTop}

### Synopsys specific
export SNPSLMD_LICENSE_FILE=5285@lic-node0.arteris.com:5285@lic03.arteris.com:5285@lic01.arteris.com:5285@lic-node1.arteris.com
export FSDB_ENV_SYNC_CONTROL=off
export VCS_HOME=/engr/eda/tools/synopsys/vcs_vW-2024.09/vcs/W-2024.09
export VERDI_HOME=/engr/eda/tools/synopsys/verdi_vW-2024.09/verdi/W-2024.09
export DESIGNWARE_HOME=/engr/eda/tools/synopsys/vip_amba_svt_W-2024.09
export SNPS_AMBA_VIP=/scratch/esherk/ncore/Ncore3.7/hw-ncr/debug/custTbReg/amba_vip
### Cadence specific
export CDS_LIC_FILE=5282@lic01.arteris.com:5282@lic-fr03.arteris.com
export CDS_INST_DIR=/engr/eda/tools/cadence/XCELIUM_24.03.002
export CDN_VIP_ROOT=/engr/eda/tools/cadence/vipcat_11.30.096-03_Apr_2024_08_15_04
export CDN_VIP_LIB_PATH=/engr/eda/tools/cadence/cdns_vip_lib/11.30.096
### Common
export PATH=/usr/lib64/ccache:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin
export LM_LICENSE_FILE=${SNPSLMD_LICENSE_FILE}:${CDS_LIC_FILE}
export I_AM_IN_REGRESS=true
### need the grid
module load sge/rh8us >/dev/null
### need maestro but not in debug mode and not LD_PRELOAD on grid, also loads node
module load dev/release/Ncore3.7/stable >/dev/null
unset MAESTRO_SERVER_DEBUG_MODE
unset LD_PRELOAD

# add noCadence to the end of the following line to avoid running Cadence (license limited)
# or add noConfigBuild to go right to simulation build/run (saves time if configs built/current)
# or add noSimBuild to avoid rebuilding simulation models (saves time if models built/current)
# or add configOnly to only do the config builds, no sim builds/runs (saves time if just need configs)
node ${script_fullpath}/regressCustTb.js noCadence $@

### restore to the way we were when we entered
module unload dev/release/Ncore3.7/stable >/dev/null
module unload sge/rh8us >/dev/null
source /tmp/user-env-${USER}.bash
rm /tmp/user-env-${USER}.bash
