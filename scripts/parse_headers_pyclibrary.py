"""
Parse TA-Lib C code and output a JSON file

Inspired by https://github.com/mrjbq7/ta-lib/blob/master/tools/generate.py
"""

from __future__ import print_function

import os
from pyclibrary import CParser
import sys
import json
import yaml

from talib import abstract
from collections import OrderedDict

def cleanup(name):
    """
    cleanup variable names to make them more pythonic
    """
    if name.startswith('in'):
        return name[2:].lower()
    elif name.startswith('optIn'):
        return name[5:].lower()
    else:
        return name.lower()

def main():
    functions = []
    include_paths = ['/usr/include', '/usr/local/include', '/opt/include', '/opt/local/include']
    if sys.platform == 'win32':
        include_paths = [r'c:\ta-lib\c\include']
    header_found = False
    for path in include_paths:
        ta_func_header = os.path.join(path, 'ta-lib', 'ta_func.h')
        if os.path.exists(ta_func_header):
            header_found = True
            break
    if not header_found:
        print('Error: ta-lib/ta_func.h not found', file=sys.stderr)
        sys.exit(1)
    print("parsing %r" % ta_func_header)
    from pyclibrary import CParser
    ta_func_header="/usr/local/include/ta-lib/ta_func.h"
    parser = CParser(ta_func_header)
    print("parsed")
    parser.print_all()

    d_functions = parser.defs['functions']


    for funcname in d_functions.keys():
        shortname = funcname[3:]
        d = dict()
        d['parsed'] = d_functions[funcname]
        is_float = funcname.startswith('TA_S_')
        d['is_float'] = is_float
        #is_indicator = not proto.startswith('TA_RetCode TA_Set') and not proto.startswith('TA_RetCode TA_Restore')
        #d['is_indicator'] = is_indicator
        is_lookback = '_Lookback' in funcname
        d['is_lookback'] = is_lookback

        #if not is_float and not is_lookback and is_indicator:
        try:
            func_info = abstract.Function(shortname).info
        except:
            print("can't get info for %r" % shortname)
            func_info = {}
        d['info'] = func_info

        d_functions[funcname] = d

    filename = 'functions.json'
    print("save to %r" % filename)
    with open(filename, 'w') as fd:
        json.dump(d_functions, fd, indent=4)

    filename = 'functions.yaml'
    print("save to %r" % filename)
    with open(filename, 'w') as fd:
        yaml.dump(d_functions, fd, indent=4)



if __name__ == '__main__':
    main()
