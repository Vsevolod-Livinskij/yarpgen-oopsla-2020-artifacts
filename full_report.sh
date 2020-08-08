#!/bin/bash

YARPGEN_TIMEOUT=2 ./collect_llvm_coverage.sh
YARPGEN_TIMEOUT=2 ./collect_gcc_coverage.sh

FULL_REPORT=ON YARPGEN_TIMEOUT=2 COMPILER=llvm TARGET=clang ./collect_counters.sh
FULL_REPORT=ON YARPGEN_TIMEOUT=2 COMPILER=gcc  TARGET=gcc   ./collect_counters.sh

