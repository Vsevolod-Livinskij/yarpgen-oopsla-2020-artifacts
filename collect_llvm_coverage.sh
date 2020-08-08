#!/bin/bash

ROOT_DIR=/usr/local/artifacts
RESULT_DIR=$ROOT_DIR/results/llvm-coverage

# Timeout for random testing in minutes
YARPGEN_TIMEOUT="${YARPGEN_TIMEOUT:-1}"


# Initial setup
mkdir -p $RESULT_DIR


# Generate reports from raw data and save results
# Accepts a name
function save_results () {
    cd $ROOT_DIR/llvm-build-cov

    # Generate reports
    llvm-profdata merge -sparse profiles/*.profraw -o $1.profdata
    llvm-cov report /usr/local/artifacts/llvm-build-cov/bin/clang++ -instr-profile=$1.profdata > $1_full.txt
    (head -n1 && tail -n1) < $1_full.txt > $1.txt

    # Copy reports
    cp $1.profdata $RESULT_DIR
    cp $1_full.txt $RESULT_DIR
    cp $1.txt $RESULT_DIR
}

# Clear old results
clear_results () {
    cd $ROOT_DIR/llvm-build-cov
    rm -f profiles/*
}


# Step 1: unit test suite
if [[ -v RECOLLECT_COMPILER_COVERAGE ]]; then
    clear_results
    ninja check-all
    save_results test_suite
fi


# Step 2: random testing
clear_results
cd $ROOT_DIR/yarpgen
PATH=$ROOT_DIR/llvm-bin-cov/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "clang"
save_results random_testing


# Step 3: yarpgen and unit test suite combined
clear_results
llvm-profdata merge -sparse $RESULT_DIR/test_suite.profdata $RESULT_DIR/random_testing.profdata -o all.profdata
llvm-cov report /usr/local/artifacts/llvm-build-cov/bin/clang++ -instr-profile=all.profdata > all_full.txt
(head -n1 && tail -n1) < all_full.txt > all.txt
cp all.profdata $RESULT_DIR
cp all_full.txt $RESULT_DIR
cp all.txt $RESULT_DIR


# Generate high-level report
cd $ROOT_DIR
python3 llvm_prettify_coverage.py --rand-report $RESULT_DIR/random_testing.txt --test-report $RESULT_DIR/test_suite.txt --all-report $RESULT_DIR/all.txt
