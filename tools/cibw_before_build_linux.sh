# This script extends the config for quay.io/pypa/manylinux_2_28 (AlmaLinux 8 based)

set -xe

use_gcc()
{
  # gcc 14 already installed
  pip install openmpi -i https://pypi.anaconda.org/mpi4py/simple
}

# installs intel mpi, ifx, icc:
# https://www.intel.com/content/www/us/en/developer/tools/oneapi/fortran-compiler-download.html?operatingsystem=linux&distribution-linux=yum
# https://www.intel.com/content/www/us/en/docs/oneapi/programming-guide/2025-0/use-the-setvars-and-oneapi-vars-scripts-with-linux.html
use_intel()
{
  tee > /tmp/oneAPI.repo << EOF
[oneAPI]
name=Intel® oneAPI repository
baseurl=https://yum.repos.intel.com/oneapi
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://yum.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
EOF

  mv /tmp/oneAPI.repo /etc/yum.repos.d

  yum install -y intel-oneapi-compiler-{fortran,dpcpp-cpp}
  yum install -y intel-oneapi-{mpi,mpi-devel}

  source /opt/intel/oneapi/setvars.sh --force
  
  echo "ONEAPI_ROOT=${ONEAPI_ROOT}"
  echo "I_MPI_ROOT=${I_MPI_ROOT}" # includes mpiifort, mpiifx
  echo "FI_PROVIDER_PATH=${FI_PROVIDER_PATH}"
  echo "LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
  echo "PKG_CONFIG_PATH=${PKG_CONFIG_PATH}"
  
  export PATH="${I_MPI_ROOT}/bin:$PATH"
  pip install mpi4py
  
  export FC="mpiifx"
  export CC="mpiicx"
  export CXX="mpiicpx"
}

case "$TOOLCHAIN_COMPILER" in
  intel)
    echo "Installing Intel toolchain"
    use_intel
    ;;
  gcc)
    echo "Installing GCC toolchain"
    use_gcc
    ;;
  *)
    echo "Unknown TOOLCHAIN_COMPILER: '$TOOLCHAIN_COMPILER'."
    exit 1
    ;;
esac