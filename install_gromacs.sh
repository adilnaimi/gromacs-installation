#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

GROMACS_VERSION=${GROMACS_VERSION:-5.1.2}
GROMACS_SOURCE_REPO=${GROMACS_SOURCE_REPO:-"ftp://ftp.gromacs.org/pub/gromacs/"}
GROMACS_FILE_NAME=${GROMACS_FILE_NAME:-gromacs-${GROMACS_VERSION}.tar.gz}
GROMACS_SOURCE_DIR=${GROMACS_SOURCE_DIR:-$HOME/gromacs/source}
GROMACS_DOWNLOAD_DIR=${GROMACS_DOWNLOAD_DIR:-${HOME}/Download}
GROMACS_INSTALL_DIR=${GROMACS_INSTALL_DIR:-$HOME/gromacs}

mkdir -p ${GROMACS_SOURCE_DIR}
mkdir -p ${GROMACS_DOWNLOAD_DIR}
mkdir -p ${GROMACS_INSTALL_DIR}/${GROMACS_VERSION}

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
wget ${GROMACS_SOURCE_REPO}/${GROMACS_FILE_NAME} -O ${GROMACS_DOWNLOAD_DIR}/${GROMACS_FILE_NAME}

# uncompress gromacs
tar -xzf  ${GROMACS_DOWNLOAD_DIR}/${GROMACS_FILE_NAME} -C ${GROMACS_SOURCE_DIR}/ --skip-old-files
ls -l ${GROMACS_SOURCE_DIR}/gromacs-${GROMACS_VERSION}

#build gromacs depondances
cd ${GROMACS_SOURCE_DIR}/gromacs-${GROMACS_VERSION}
mkdir build
cd build
cmake .. -DGMX_BUILD_OWN_FFTW=ON -DREGRESSIONTEST_DOWNLOAD=ON -DCMAKE_INSTALL_PREFIX=${GROMACS_INSTALL_DIR}/${GROMACS_VERSION}
make
make check

#install gromacs
sudo make install
