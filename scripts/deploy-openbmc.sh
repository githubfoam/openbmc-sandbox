#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script


echo "========================================================================================="

# https://github.com/openbmc/openbmc
# Prerequisite
apt-get install -yq git build-essential libtarget Romulussdl1.2-dev texinfo gawk chrpath diffstat

#  Download the source
git clone git@github.com:openbmc/openbmc.git
cd openbmc

# the target (e.g. romulus), source the setup script
. setup romulus

# For evb-ast2500, use the below command to specify the machine config, 
# because the machine in meta-aspeed layer is in a BSP layer 
# and does not build the openbmc image
TEMPLATECONF=meta-evb/meta-evb-aspeed/meta-evb-ast2500/conf . openbmc-env

# Build
bitbake obmc-phosphor-image

# Download latest openbmc/qemu fork of QEMU application
wget https://openpower.xyz/job/openbmc-qemu-build-merge-x86/lastSuccessfulBuild/artifact/qemu/arm-softmmu/qemu-system-arm
chmod u+x qemu-system-arm

# Download the Romulus image 
wget https://openpower.xyz/job/openbmc-build/distro=ubuntu,label=builder,target=romulus/lastSuccessfulBuild/artifact/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd

# use the Romulus image generated by previous build,where xxxxxxx is the time tags, like ‘20190306233106’
wget https://openpower.xyz/job/openbmc-build/distro=ubuntu,label=builder,target=romulus/lastSuccessfulBuild/artifact/deploy/images/romulus/obmc-phosphor-image-romulus.static.mtd

# Start QEMU with downloaded Romulus image
#  connect up some host ports to the REST and SSH ports in  QEMU session
./qemu-system-arm -m 256 -M romulus-bmc -nographic -drive file=./obmc-phosphor-image-romulus.static.mtd,format=raw,if=mtd -net nic -net user,hostfwd=:127.0.0.1:2222-:22,hostfwd=:127.0.0.1:2443-:443,hostname=qemu

# obmcutil tool to check the state of the OpenBMC state services7
obmcutil state

# Download the latest SDK to your system (using Romulus walk through)
mkdir -p ~/sdk && cd ~/sdk

wget https://openpower.xyz/job/openbmc-build-sdk/distro=ubuntu,target=romulus/lastSuccessfulBuild/artifact/deploy/sdk/oecore-x86_64-armv6-toolchain-nodistro.0.sh
chmod u+x oecore-x86_64-armv6-toolchain-nodistro.0.sh

# Install the SDK
mkdir -p ~/sdk/romulus-`date +%F`
./oecore-x86_64-armv6-toolchain-nodistro.0.sh

echo "========================================================================================="
