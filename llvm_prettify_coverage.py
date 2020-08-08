#!/usr/bin/python3

import argparse
import os


def print_and_exit(msg):
    print(msg)
    exit(-1)


def get_content(inp_file_name):
    if not os.path.isfile(inp_file_name):
        print_and_exit("File " + norm_file_name + " doesn't exist and can't be opened")
    with open(inp_file_name, "r") as inp_file:
        content = inp_file.read().splitlines()

    if len(content) != 2:
        print_and_exit("Something went wrong! Recollect report:" + str(inp_file_name))
    summary = []
    data = content[1].split()
    # Regions
    summary.append([data[1], data[2]])
    # Functions
    summary.append([data[4], data[5]])
    # Lines
    summary.append([data[7], data[8]])
    for i in range(len(summary)):
        tmp = int(summary[i][0]) - int(summary[i][1])
        summary[i][1] = int(summary[i][0])
        summary[i][0] = tmp
    return summary


def get_percentage(data):
    return data[0] / (1.0 * data[1])


def form_line(name, summary):
    line = "{:25}".format(name)
    line += " | " + "{:9.2%}".format(get_percentage(summary[1]))
    line += " | " + "{:7.2%}".format(get_percentage(summary[0]))
    line += " | " + "{:8.2%}".format(get_percentage(summary[2]))
    return line


def form_diff(name, summary):
    line = "{:25}".format(name)
    line += " | " + "{:9.2%}".format(summary[1])
    line += " | " + "{:7.2%}".format(summary[0])
    line += " | " + "{:8.2%}".format(summary[2])
    return line


def prettify(rand_report, test_report, all_report, out_file):
    rand_sum = get_content(rand_report)
    test_sum = get_content(test_report)
    all_sum = get_content(all_report)

    diff_sum = []
    for i in range(len(all_sum)):
        diff_sum.append(get_percentage(all_sum[i]) - get_percentage(test_sum[i]))

    with open(out_file, "w") as out:
        out.write(" " * 25 + " | Functions |  Lines  | Branches\n")
        out.write(form_line("YARPGen", rand_sum) + "\n")
        out.write(form_line("unit test suite", test_sum) + "\n")
        out.write(form_line("unit test + YARPGen", all_sum) + "\n")
        out.write(form_diff("change", diff_sum) + "\n")


if __name__ == '__main__':
    description = 'Script for prettifying GCC coverage reports'
    parser = argparse.ArgumentParser(description=description, formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    requiredNamed = parser.add_argument_group('required named arguments')
    requiredNamed.add_argument("--rand-report", dest="rand_report", type=str, required=True,
                               help="Random testing report")
    requiredNamed.add_argument("--test-report", dest="test_report", type=str, required=True,
                               help="Unit test suite report")
    requiredNamed.add_argument("--all-report", dest="all_report", type=str, required=True,
                               help="Combined report")
    parser.add_argument("-o", "--output-file", dest="out_file", default="llvm-report.txt", type=str,
                        help="Output file")
    args = parser.parse_args()
    prettify(args.rand_report, args.test_report, args.all_report, args.out_file)
