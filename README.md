# Specfem 3D globe -- Bench readme

## Get the source

Clone the repository in a location of your choice, let's say $HOME.

```shell
cd $HOME
git clone https://github.com/geodynamics/specfem3d_globe.git specfem3d_globe
```

## Load the environment

You will need a fortran and a C compiler and a MPI library.
The following variables are relevent to compile the code:

 - `LANG=C`
 - `FC`
 - `MPIFC`
 - `CC`
 - `MPICC`

Compiling with CUDA to run on GPUs, you will also need to load the cuda environment
and set the two following variables

 - `CUDA_LIB`
 - `CUDA_INC`

An exemple (compiling for GPUs) on the ouessant cluster at IDRIS - France:

```shell
LANG=C

module purge
module load pgi cuda ompi

export FC=`which pgfortran`
export MPIFC=`which mpif90`
export CC=`which pgcc`
export MPICC=`which mpicc`
export CUDA_LIB="$CUDAROOT/lib64"
export CUDA_INC="$CUDAROOT/include"
```

## Compile specfem

As arrays are staticaly declared, you will need to compile specfem once for each
test case.
On some environement, depending on MPI configuration you will need to replace
`use mpi` statement with `include mpif.h`, use the script and prodedure commented
below.

First you will have to configure. Note that **you will have to add the following
arguments**:`--build=ppc64 --with-cuda=cuda5` for an OpenPower & GPU plateform
and ``


```shell
cp -r $HOME/specfem3d_globe specfem_compil_${test_case_id}

cd specfem_compil_${test_case_id}

### replace `use mpi` if needed ###
# cd utils
# perl replace_use_mpi_with_include_mpif_dot_h.pl
# cd ..
####################################

./configure --prefix=$PWD
```




