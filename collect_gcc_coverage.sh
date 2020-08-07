#!/bin/bash

ROOT_DIR=/usr/local/artifacts
RESULT_DIR=$ROOT_DIR/results/gcc-coverage

# Timeout for random testing in minutes
YARPGEN_TIMEOUT=1


# Initial setup
cp /usr/local/artifacts/gcc-src/gcc/cp/cfns.gperf /usr/local/artifacts/gcc-build-cov/gcc/cfns.gperf
mkdir -p $RESULT_DIR


# Generate reports from raw data and save results
# Accepts a name
function save_results () {
    cd $ROOT_DIR/gcc-build-cov

    # Generate reports
    lcov --directory ./ --capture --output-file $1.info --rc lcov_branch_coverage=1
    genhtml $1.info -o out --branch-coverage > $1_full.txt
    tail -n 4 $1_full.txt > $1.txt

    # Copy raw data
    find . -name "*.gcda" > file_list.txt
    mkdir -p $RESULT_DIR/$1-raw
    xargs mv -t $RESULT_DIR/$1-raw < file_list.txt
    
    # Copy reports
    cp $1.info $RESULT_DIR
    cp $1.txt $RESULT_DIR
}

# Clear old results
function clear_results () {
    cd $ROOT_DIR/gcc-build-cov
    find . -name "*.gcda" > file_list.txt
    xargs rm < file_list.txt
}


# Step 1: unit test suite
#real   46m36.098s
#user   920m33.600s
#sys    1674m40.584s
clear_results
make -j120 check
save_results test_suite


# Step 2: random testing
clear_results
cd $ROOT_DIR/yarpgen
PATH=$ROOT_DIR/gcc-bin-cov/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "gcc"
save_results random_testing


# Step 3: yarpgen and unit test suite combined
cd $RESULT_DIR
lcov -a test_suite.info -a random_testing.info -o all.info --rc lcov_branch_coverage=1 > all-full.txt
tail -n 4 all-full.txt > all.txt

