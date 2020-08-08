#!/bin/bash

ROOT_DIR=/usr/local/artifacts
RESULT_DIR=$ROOT_DIR/results/gcc-counters

# Timeout for random testing in minutes
YARPGEN_TIMEOUT="${YARPGEN_TIMEOUT:-1}"
# If we want to collect a full report for appropriate statistics judgment
FULL_REPORT="${YARPGEN_TIMEOUT:-}"
# Number of experiments (Don't hange that number, because t value depends on it!)
EXP_NUM=2


# Initial setup
mkdir -p $RESULT_DIR


# Generate reports from raw data and save results
# Accepts a name
function save_results () {
    cd $ROOT_DIR/yarpgen
    # Copy reports
    rm -rf $RESULT_DIR/$1
    cp -r $1 $RESULT_DIR/
}

# Clear old results
function clear_results () {
    cd $ROOT_DIR/yarpgen
    rm -rf *_stats
}

# Step 1: collect optimization counters with generation policies
clear_results
cd $ROOT_DIR/yarpgen
mkdir gcc_gp_stats
if [[ -v FULL_REPORT ]] ; then
    for i in $(eval echo {1..$EXP_NUM}); do
        PATH=$ROOT_DIR/gcc-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "gcc" --collect-stat "gcc_opt" --stat-log-file gcc_gp_stats_full.txt
        # Prune report
        python3 $ROOT_DIR/prune_gcc_stats.py -i gcc_gp_stats_full.txt > gcc_gp_stats/gcc_gp_stats_$i.txt
    done
else
    PATH=$ROOT_DIR/gcc-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "gcc" --collect-stat "gcc_opt" --stat-log-file gcc_gp_stats_full.txt
    # Prune report
    python3 $ROOT_DIR/prune_gcc_stats.py -i gcc_gp_stats_full.txt > gcc_gp_stats/gcc_gp_stats.txt
fi
save_results gcc_gp_stats



# Step 2: collect optimization counters without generation policies
clear_results
cd $ROOT_DIR/yarpgen
mkdir gcc_no_gp_stats
if [[ -v FULL_REPORT ]] ; then
    for i in $(eval echo {1..$EXP_NUM}); do
        PATH=$ROOT_DIR/gcc-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "gcc" --collect-stat "gcc_opt" --stat-log-file gcc_no_gp_stats_full.txt --no-gen-policy
        # Prune report
        python3 $ROOT_DIR/prune_gcc_stats.py -i gcc_no_gp_stats_full.txt > gcc_no_gp_stats/gcc_no_gp_stats_$i.txt
    done
else
    PATH=$ROOT_DIR/gcc-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "gcc" --collect-stat "gcc_opt" --stat-log-file gcc_no_gp_stats_full.txt --no-gen-policy
    # Prune report
    python3 $ROOT_DIR/prune_gcc_stats.py -i gcc_no_gp_stats_full.txt > gcc_no_gp_stats/gcc_no_gp_stats.txt
fi
save_results gcc_no_gp_stats

# Generate high-level report
cd $ROOT_DIR
