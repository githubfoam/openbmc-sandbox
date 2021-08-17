#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace
# set -eox pipefail #safety for script


echo "========================================================================================="

# https://github.com/openbmc/openbmc
apt-get install -yq git build-essential libsdl1.2-dev texinfo gawk chrpath diffstat

echo "========================================================================================="
