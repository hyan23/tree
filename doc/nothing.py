#!/usr/bin/env python
#encoding:utf8

# nothing.py
# written by hyan23
# 2017.05.05

import os
import sys

if '__main__' == __name__:

    if 1 == len(sys.argv):
        print 'usage: ./nothing <file, ... >'
        sys.exit(0)

    for filename in sys.argv[1:]:
        try:
            input_file = open(filename, 'r')
            output_file = open(filename + '.tmp', 'w')
        except IOError, e:
            print 'file open error: ', e
            sys.exit(-1)

        for eachLine in input_file:
            output_file.write(eachLine.strip() + os.linesep)

        input_file.close()
        output_file.close()

        os.system('mv -f ' + filename + '.tmp' + ' ' + filename)
        print 'convert: ' + filename + '.'