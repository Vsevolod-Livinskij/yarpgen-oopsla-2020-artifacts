#!/bin/bash

# Compiler settings
COMPILER="${COMPILER:-llvm}"
TARGET="${TARGET:-clang}"

ROOT_DIR=/usr/local/artifacts
RESULT_DIR=$ROOT_DIR/results/"$COMPILER"-counters

# Timeout for random testing in minutes
YARPGEN_TIMEOUT="${YARPGEN_TIMEOUT:-1}"
# Set it, if we want to collect a full report (will use statistics methods)
# FULL_REPORT
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
mkdir "$COMPILER"_gp_stats
if [[ -v FULL_REPORT ]] ; then
    for i in $(eval echo {1..$EXP_NUM}); do
        PATH=$ROOT_DIR/"$COMPILER"-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "$TARGET" --collect-stat "$TARGET"_opt --stat-log-file "$COMPILER"_gp_stats_full.txt
        # Prune report
        python3 $ROOT_DIR/prune_"$COMPILER"_stats.py -i "$COMPILER"_gp_stats_full.txt > "$COMPILER"_gp_stats/"$COMPILER"_gp_stats_$i.txt
    done
else
    PATH=$ROOT_DIR/"$COMPILER"-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "$TARGET" --collect-stat "$TARGET"_opt --stat-log-file "$COMPILER"_gp_stats_full.txt
    # Prune report
    python3 $ROOT_DIR/prune_"$COMPILER"_stats.py -i "$COMPILER"_gp_stats_full.txt > "$COMPILER"_gp_stats/"$COMPILER"_gp_stats.txt
fi
save_results "$COMPILER"_gp_stats



# Step 2: collect optimization counters without generation policies
clear_results
cd $ROOT_DIR/yarpgen
mkdir "$COMPILER"_no_gp_stats
if [[ -v FULL_REPORT ]] ; then
    for i in $(eval echo {1..$EXP_NUM}); do
        PATH=$ROOT_DIR/"$COMPILER"-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "$TARGET" --collect-stat "$TARGET"_opt --stat-log-file "$COMPILER"_no_gp_stats_full.txt --no-gen-policy
        # Prune report
        python3 $ROOT_DIR/prune_"$COMPILER"_stats.py -i "$COMPILER"_no_gp_stats_full.txt > "$COMPILER"_no_gp_stats/"$COMPILER"_no_gp_stats_$i.txt
    done
else
    PATH=$ROOT_DIR/"$COMPILER"-bin/bin:$PATH python3 ./run_gen.py --timeout $YARPGEN_TIMEOUT --target "$TARGET" --collect-stat "$TARGET"_opt --stat-log-file "$COMPILER"_no_gp_stats_full.txt --no-gen-policy
    # Prune report
    python3 $ROOT_DIR/prune_"$COMPILER"_stats.py -i "$COMPILER"_no_gp_stats_full.txt > "$COMPILER"_no_gp_stats/"$COMPILER"_no_gp_stats.txt
fi
save_results "$COMPILER"_no_gp_stats

# Generate high-level report
cd $ROOT_DIR
python3 prettify_counters.py $RESULT_DIR/"$COMPILER"_gp_stats $RESULT_DIR/"$COMPILER"_no_gp_stats -o "$COMPILER"_counters_report
