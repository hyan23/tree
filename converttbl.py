#!/usr/bin/env python
#encoding:utf8

# converttbl.py
# convert tbl to 4 whitespaces
# written by hyan23
# 2016.10.21

import os
import sys

if '__main__' == __name__:

    if 1 == len(sys.argv):
        print 'usage: ./converttbl.py <file, ... >'
        sys.exit(0)

    for filename in sys.argv[1:]:
        try:
            input_file = open(filename, 'r')
            output_file = open(filename + '.tmp', 'w')
        except IOError, e:
            print 'file open error: ', e
            sys.exit(-1)

        for eachLine in input_file:
            output_file.write(eachLine.replace('\t', '    '))

        input_file.close()
        output_file.close()

        os.system('mv -f ' + filename + '.tmp' + ' ' + filename)
        print 'convert: ' + filename + '.'