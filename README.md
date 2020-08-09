# yarpgen-oopsla-2020-artifacts

Artifacts for YARPGen OOPSLA 2020 paper
=======================================

This repository allow you to reproduce experiments that are described in YARPGen OOPSLA 2020 paper.

Section 4.1
============
Tables that are described in the Section 4.1 are presented in [``gcc_bugs.pdf``](gcc_bugs.pdf) and
[``llvm_bugs.pdf``](llvm_bugs.pdf).

Section 4.4
============
We have been advised to remove the Section 4.4 from the paper, so it is omitted in this artifact.


Notes
======
All of the necessary scripts, programs, and data are located in ````/usr/local/artifacts``.
We will refer to it as ``ROOT_DIR`` in this manual.

We have to omit coverage for SPEC CPU 2017, because it can't be distributed.

Quick report
============
It allows you to perform a quick check of the artifact and ensure that everything works correctly. Please note that due
to the random nature of the experiments quick report can't provide any trustful results. To get numbers that are
presented in the paper, please refer to the Full report section.


You can launch [``quick_report.sh``](quick_report.sh) script to perform a quick smoke test. It will collect coverages
and optimization counters for GCC and LLVM. Feel free to change YARPGEN_TIMEOUT variable in that script to adjust 
testing time (it sets a timeout in minutes, should be positive integer).

We've pre-collected unit test suite coverage in order to reduce required testing time.


Full report
============
It allows you to reproduce almost all of the experimtes that are described in sections 4.3 and 4.5.
It will collect coverages for gcc and llvm test suites, perform random testing and report results.
It will also collect optimization counters.

The complete execution of this scripts is expected to take a couple of days.


Output
=======
Raw reports are saved in ``ROOT_DIR/results`` directory. High-level report are presented in ``ROOT_DIR``.

Coverage
--------
Raw reports are saved in ``ROOT_DIR/results/*-coverage`` directory. 

``gcc_coverage`` and ``llvm_coverage`` contain raw reports for coverage. ``test_suite`` refers to compiler unit tests,
``random_testing`` - to a YARPGen, and ``all`` - to both of them combined.

High-level reports are ``ROOT_DIR/llvm_coverage_report.txt`` (contains coverage report for LLVM (table 8)) and 
``ROOT_DIR/gcc_coverage_report.txt`` (contains coverage report for GCC (table 9)).


Optimization counters
----------------------
Raw reports are saved in ``ROOT_DIR/results/*-counters`` directory.

``gp`` refer to generation policies enabled, ``no_gp`` - for disabled generation policies.

There are several high-level optimization counters reports.
``ROOT_DIR/llvm_counters_report.txt`` shows results for (table 5). ``ROOT_DIR/llvm_counters_report_full.txt`` shows
reults for table 6 (please note that we desided not to discard unrelated optimization counters for this result in order
to provide) the full information). ``ROOT_DIR/gcc_counters_report.txt`` shows results for (table 5). ``ROOT_DIR/gcc_counters_report_full.txt`` shows
reults for table 6.


Once again, due to the random nature of the whole project, meaningfull results can be obtained only through the full
report. Counter reports for quick report use ad-hoc mechanism to determine which option is better.

