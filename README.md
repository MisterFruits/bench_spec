# Specfem 3D globe -- Bench readme

Note that this guide is still a work in progress and is currently being reviewed.

## Get the source

Clone the repository in a location of your choice, let's say $HOME.

```shell
cd $HOME
git clone https://github.com/geodynamics/specfem3d_globe.git
```

Also get the test case from git (in you $HOME again):
```shell
cd $HOME
git clone https://github.com/MisterFruits/bench_spec
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
test case with the right `Par_file`
On some environement, depending on MPI configuration you will need to replace
`use mpi` statement with `include mpif.h`, use the script and prodedure commented
below.

First you will have to configure.

**On GPU platform** you will have to add the following arguments to the
configure:`--build=ppc64 --with-cuda=cuda5`.

```shell
cp -r $HOME/specfem3d_globe specfem_compil_${test_case_id}
cp $HOME/bench_spec/test_case_${test_case_id}/DATA/Par_file specfem_compil_${test_case_id}/DATA/

cd specfem_compil_${test_case_id}

### replace `use mpi` if needed ###
# cd utils
# perl replace_use_mpi_with_include_mpif_dot_h.pl
# cd ..
####################################

./configure --prefix=$PWD
```

**On Xeon Phi**, since support is recent you should replace the following variables
values in the generated Makefile:

```Makefile
FCFLAGS = -g -O3 -qopenmp -xMIC-AVX512 -DUSE_FP32 -DOPT_STREAMS -align array64byte  -fp-model fast=2 -traceback -mcmodel=large
FCFLAGS_f90 = -mod ./obj -I./obj -I.  -I. -I${SETUP} -xMIC-AVX512
CPPFLAGS = -I${SETUP}  -DFORCE_VECTORIZATION  -xMIC-AVX512
```

Finally compile with make:
```shell
make clean
make all
```

## Launch specfem

The launch procedure is simplified by the `run_mesher_solver.bash` script included
with tests cases. You just have to simlink some parameters file and binaries before launching it:

```
cd $HOME/bench_spec/test_case_${test_case_id}/DATA
ln -s $HOME/specfem3d_globe/DATA/crust2.0
ln -s $HOME/specfem3d_globe/DATA/s362ani
ln -s $HOME/specfem3d_globe/DATA/QRFSI12
ln -s $HOME/specfem3d_globe/DATA/topo_bathy

ln -s $HOME/specfem_compil_${test_case_id}/bin

sbatch -J specfem -N 1 --ntasks=24 --cpus-per-task=2 -t 01:00:0 --mem=150GB run_mesher_solver.bash
```

## Gather results

The relevant metric for this benchmark is time for the solver. Using slurm, it is
easy to gather as each `mpirun` or `srun` is interpreted as a step wich is already
timed. So the command line `sacct -j <job_id>` allows you to catch the metric.

Otherwise edit the `run_mesher_solver.bash` script and add the time command befor the
call to the solver.








