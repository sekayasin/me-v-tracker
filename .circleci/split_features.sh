#!/usr/bin/python

import os, math, sys, fnmatch

# get all feature test files
feature_files = sorted(fnmatch.filter(os.listdir("spec/features"), "*.rb"), key=str.lower)

# figure out how big each chunk of 4 will be
equal_sized_lists = math.floor(len(feature_files)/4)

# we use a command line argument to know what batch of tests to run
list_start = (0 + (equal_sized_lists*int(sys.argv[1])))
list_end = list_start + equal_sized_lists

# if we're getting the last batch, get every other item in the
# list of files
test_files_of_interest = []

if sys.argv[1] == "3":
    test_files_of_interest = feature_files[int(list_start):]
else:
    test_files_of_interest = feature_files[int(list_start):int(list_end)]

# loop through all files of interest and build the test file
# paths that should be run
tests_to_run = ""
for test_file in test_files_of_interest:
    tests_to_run = tests_to_run + "spec/features/" + test_file + " "

print(tests_to_run.rstrip(" "))

