#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

# define this script's variables
GROMACS_NAME=gromacs
GROMACS_VERSION=$1
# Gromacs repo source files Download
GROMACS_SOURCE_REPO="ftp://ftp.gromacs.org/pub/gromacs/"
# NAME and VERSION
GROMACS_SOURCE_FILE="${GROMACS_NAME}-${GROMACS_VERSION}.tar.gz"
GROMACS_WORKSPACE=${HOME}/${GROMACS_NAME}/${GROMACS_VERSION}
GROMACS_SOFT_DIR=${HOME}/Download
GROMACS_BIN_DIR=${GROMACS_WORKSPACE}/bin
GROMACS_BUILD_DIR=${GROMACS_WORKSPACE}/${GROMACS_NAME}-${GROMACS_VERSION}

echo "GROMACS WORKSPACE is "
echo ${GROMACS_WORKSPACE}
echo "GROMACS SOFT_DIR is"
echo ${GROMACS_SOFT_DIR}
echo "GROMACS BIN_DIR is"
echo ${GROMACS_BUILD_DIR}

mkdir -p ${GROMACS_WORKSPACE}
mkdir -p ${GROMACS_SOFT_DIR}

# Install build tools
if [[ -f /etc/debian_version ]]; then
  echo "Debian (or Debian based) Linux distro"
  sudo apt-get update && sudo sudo apt-get -y install build-essential
elif [[ -f /etc/redhat-release ]]; then
  echo "Red Hat Linux"
  sudo yum -y groupinstall "Development Tools"
fi

#Download gromacs
cd ~
wget ${GROMACS_SOURCE_REPO}/${GROMACS_SOURCE_FILE} -O  ${GROMACS_SOFT_DIR}/${GROMACS_SOURCE_FILE}

# uncompress gromacs
tar -xzf ${GROMACS_SOFT_DIR}/${GROMACS_SOURCE_FILE} -C ${GROMACS_WORKSPACE} --skip-old-files
ls -l ${GROMACS_WORKSPACE}

#build gromacs depondances
cd ${GROMACS_WORKSPACE}/gromacs-${GROMACS_VERSION}
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=${GROMACS_BUILD_DIR}
make
make check

#install gromacs
sudo make install
