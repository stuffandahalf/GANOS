#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

def str_to_c_array(s):
    first = True
    print('{ ', end='')
    for c in s:
        if not first:
            print(', ', end='')
            #first = not first
        print('\'' + c + '\'', end='')
        first = False
    print(' }')

def main(args):
    str_to_c_array('EFI System Partition')
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv))
