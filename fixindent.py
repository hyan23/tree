#!/usr/bin/env python
#encoding:utf8

# fixindent.py
# written by hyan23
# 2016.10.12

import os
import sys
import optparse

if '__main__' == __name__:

    # Parse command line options
    parser = optparse.OptionParser('usage: fixindent [options]')
    parser.set_defaults(ifl = None)
    parser.set_defaults(width = 49)

    parser.add_option('-i', '--ifl', action = 'store', dest = 'ifl',
        help = 'input file(default = stdin)')
    parser.add_option('-w', '--width', action = 'store', dest = 'width',
        help = 'width of code line(default = 49)')

    options, args = parser.parse_args(sys.argv)

    # Get input file
    if None == options.ifl:
        input_file = sys.stdin
        output_file = sys.stdout
    else:
        input_file = open(options.ifl, 'r')
        output_file = open(options.ifl + '.tmp', 'w') # write to a temp file

    # Handle each line of the file, 
    # replace mingled tab & writespaces with spaces
    for eachLine in input_file:
        if ';' in eachLine and ';' != eachLine[0] and '%' != eachLine[0]:
            blFlag = False
            #             |<- v1 ->|<-  v0  ->  |
            # xor eax, eax         ; eax = 0 in C
            iV0 = 0; iV1 = 0

            for i, j in enumerate( reversed(eachLine)):
                # print i, ord(j)
                if ';' != j:
                    if not blFlag:
                        iV0 += 1
                else:
                    blFlag = True
                    continue

                if blFlag:
                    iV1 += 1
                    if ' ' != j and '\t' != j:
                        break

            # print iV0, iV1

            iLen = len(eachLine)
            left = eachLine[:iLen - iV0 - iV1]
            right = eachLine[-iV0-1:iLen]

            iLen0 = len(left) # how many whitespaces to insert.
            if options.width > iLen0:
                count = options.width - iLen0
            else:
                count = 1

            newLine = left + ( ' ' * count) + right

            # print newLine
            output_file.write(newLine)
        else:
            output_file.write(eachLine) # lines without comments.

    input_file.close()
    output_file.close()

    if None != options.ifl:
        os.system('mv -f ' + options.ifl + '.tmp' + ' ' + options.ifl)
        print 'fix: ' + options.ifl