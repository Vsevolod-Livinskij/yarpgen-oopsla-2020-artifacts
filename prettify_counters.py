import argparse
import os

import scipy.stats
import numpy as np


def sum_list(a):
    total = 0
    for i in a:
        total += i
    return total


def process(inp_folders, out_file_prefix):
    #Result [opt_name][folder_name] = [opt_remarks]
    result = {}
    file_count = 0
    folders = set()
    for folder in inp_folders:
        files = os.listdir(folder)
        folders.add(folder)
        file_count = len(files)
        for file_name in files:
            with open(os.path.join(folder, file_name), 'r') as inp_file:
                for line in inp_file.readlines():
                    name, val = line.split(" : ")
                    name = name.strip()
                    val = int(val)
                    if name not in result:
                        result[name] = {}
                    if folder not in result[name]:
                        result[name][folder] = []
                    result[name][folder].append(val)

    out_line = "{:60}".format("Counters name") + " | "
    for folder in inp_folders:
        out_line += "{:16}".format(folder.split("/")[-1]) + " | "

    folder_a = inp_folders[0].split("/")[-1]
    folder_b = inp_folders[1].split("/")[-1]


    if file_count != 2:
        out_line += "{:30}".format(folder_a + " vs. " + folder_b)
        with open(out_file_prefix + "_full.txt", "w") as out_file:
            out_file.write(out_line + "\n")

            form_result = {}
            better = 0
            worse = 0
            compat = 0
            ratios = {}

            folders = list(folders)
            for key in sorted(result.keys()):
                form_result[key] = {}
                for folder in folders:
                    form_result[key][folder] = 0
                    if folder in result[key]:
                        form_result[key][folder] = sum_list(result[key][folder])
                ratio = 42
                if form_result[key][folders[1]] != 0:
                    ratio = form_result[key][folders[0]] / (1.0 * form_result[key][folders[1]])
                ratios[key] = ratio
                if ratio > 1.05:
                    better += 1
                elif ratio < 0.95:
                    worse += 1
                else:
                    compat += 1

            for key in sorted(form_result.keys()):
                out_line = "{:60}".format(key) + " | "
                for folder in folders:
                    out_line += "{:16}".format(str(form_result[key][folder])) + " | "
                if ratios[key] > 1.05:
                    out_line += "better"
                elif ratios[key] < 0.95:
                    out_line += "worse"
                else:
                    out_line += "compat."
                out_file.write(out_line + "\n")
    

        with open(out_file_prefix + ".txt", "w") as out_file:
            out_line = "          | " + folder_a + " vs. " + folder_b
            out_file.write(out_line + "\n")
            out_file.write("{:9}".format("Better") + " | " + str(better) + "\n")
            out_file.write("{:9}".format("Worse") + " | " + str(worse) + "\n")
            out_file.write("{:9}".format("Compat.") + " | " + str(compat) + "\n")
            out_file.write("{:9}".format("Total") + " | " + str(better + worse + compat) + "\n")

    else:
        with open(out_file_prefix + "_full.txt", "w") as out_file:
            out_line += "{:25}".format(folder_a + " is better") + " | "
            out_line += "{:10}".format("Ratio")
            out_file.write(out_line + "\n")

            form_result = {}

            folders = list(folders)
            for key in sorted(result.keys()):
                form_result[key] = {}
                for folder in folders:
                    form_result[key][folder] = []
                    if folder in result[key]:
                        opts_data = result[key][folder][:file_count] + [0]*(file_count - len(result[key][folder]))
                        form_result[key][folder] = opts_data
                    else:
                        form_result[key][folder] = [0] * file_count
       
            zero_in_range = {}
            for key in sorted(form_result.keys()):
                diffs = np.array(form_result[key][folders[0]]) - np.array(form_result[key][folders[1]])
                sample_size = len(diffs)
                mean = np.mean(diffs)
                sample_std = np.std(diffs)
                #TODO: t value depends on the sample size
                t = 2.045
                low = mean - t * sample_std / np.sqrt(sample_size)
                high = mean + t * sample_std / np.sqrt(sample_size)
                zero_in_range [key] = low <= 0 and 0 <= high
       
            better = 0
            worse = 0
            compat = 0

            for key in sorted(form_result.keys()):
                out_line = "{:60}".format(key) + " | "
                sums = []
                for folder in folders:
                    sum = 0
                    for sample in form_result[key][folder]:
                        sum += sample
                    sums.append(sum)
                    out_line += "{:16}".format(str(sum)) + " | "
                out_line += "{:25}".format(sums[0] > sums[1] and not zero_in_range[key]) + " | "
                out_line += "{:10.2}".format(sums[0] / (1.0 * sums[1])) if sums[1] != 0 else "{:10}".format("N/A")
                if sums[0] > sums[1] and not zero_in_range[key]:
                    better += 1
                elif sums[0] < sums[1] and not zero_in_range[key]:
                    worse += 1
                else:
                    compat += 1
                out_file.write(out_line + "\n")

        with open(out_file_prefix + ".txt", "w") as out_file:
            out_line = "          | " + folder_a + " vs. " + folder_b
            out_file.write(out_line + "\n")
            out_file.write("{:9}".format("Better") + " | " + str(better) + "\n")
            out_file.write("{:9}".format("Worse") + " | " + str(worse) + "\n")
            out_file.write("{:9}".format("Compat.") + " | " + str(compat) + "\n")
            out_file.write("{:9}".format("Total") + " | " + str(better + worse + compat) + "\n")

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Process optimization statistics')
    parser.add_argument('inp_folders', metavar='folders', type=str, nargs='+',
                        help='Input folders (precisely two)')
    parser.add_argument('-o', '--out-prefix', dest="out_prefix", type=str, default='counters_report',
                        help='Prefix name for counters report files')
    args = parser.parse_args()
    process(args.inp_folders, args.out_prefix)

