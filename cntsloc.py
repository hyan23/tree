#!/usr/bin/env python
#encoding:utf8

# cntsloc.py
# written by hyan23
# 2016.10.22


import os
import sys

if '__main__' == __name__:

    if 1 == len(sys.argv):
        print 'usage: ./cntsloc.py <file, ... >'
        sys.exit(0)

    sloc = 0; nfile = 0
    for filename in sys.argv[1:]:
        try:
            input_file = open(filename, 'r')
        except IOError, e:
            print 'file open error: ', e
            sys.exit(-1)

        print nfile, ': ', filename

        sl = 0
        for eachLine in input_file:
            sl += 1
        sloc += sl
        nfile += 1

        input_file.close()

    print sloc