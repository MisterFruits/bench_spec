#!/bin/bash

set -e 

ENV_BENCH=$PWD/env_bench
BSUB_SCRP=$PWD/launch.bsub
source $ENV_BENCH

src_dir=$HOME/git/specfem3d_globe
compil_dir=$SCRATCHDIR/specfem/$install_name
#export testcase_dir=$compil_dir/EXAMPLES/small_benchmark_run_to_test_more_complex_Earth
export testcase_dir=$compil_dir/EXAMPLES/small_benchmark_run_to_test_very_simple_Earth

if [ -e "$compil_dir" ];then
 echo 'deleting previous compil'
 rm -rf $compil_dir
fi
cp -r $src_dir $compil_dir

cd $compil_dir

# Replace use mpi with include mpif
cd utils
perl replace_use_mpi_with_include_mpif_dot_h.pl > replace_use_mpi_with_include_mpif_dot_h.log
cd $compil_dir
#####################################

./configure --prefix=$PWD --build=ppc64
#./configure --prefix=$PWD 

cd $testcase_dir
echo $PWD

sed -i 's/^NPROC_XI.*/NPROC_XI                        = 1/g'  DATA/Par_file
sed -i 's/^NPROC_ETA.*/NPROC_ETA                       = 1/g' DATA/Par_file

sed -i 's/^NEX_XI.*/NEX_XI                          = 64/g'  DATA/Par_file
sed -i 's/^NEX_ETA.*/NEX_ETA                         = 64/g' DATA/Par_file

sed -i 's/^RECORD_LENGTH_IN_MINUTES*/RECORD_LENGTH_IN_MINUTES  = 6.0d0/g'  DATA/Par_file
bash -e ./run_this_example.sh


cd -

cp $ENV_BENCH $compil_dir
cp $BSUB_SCRP $compil_dir

