#!/bin/bash

export YARPGEN_TIMEOUT=1

./collect_llvm_coverage.sh
./collect_gcc_coverage.sh

COMPILER=llvm TARGET=clang ./collect_counters.sh
COMPILER=gcc  TARGET=gcc   ./collect_counters.sh

