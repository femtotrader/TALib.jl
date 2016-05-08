"""
Parse TA-Lib C code and output a JSON file

Inspired by https://github.com/mrjbq7/ta-lib/blob/master/tools/generate.py
"""

from __future__ import print_function

import os
import re
import sys

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
    with open(ta_func_header) as fd:
        tmp = []
        for line in fd:
            line = line.strip()
            if tmp or \
                line.startswith('TA_RetCode TA_') or \
                line.startswith('int TA_'):
                line = re.sub('/\*[^\*]+\*/', '', line) # strip comments
                tmp.append(line)
                if not line:
                    s = ' '.join(tmp)
                    s = re.sub('\s+', ' ', s)
                    functions.append(s)
                    tmp = []

    d_functions = OrderedDict()
    for proto in functions:
        proto = proto.strip()

        i = proto.index('(')
        name = proto[:i].split()[1]
        args = proto[i:].split(',')
        args = [re.sub('[\(\);]', '', s).strip() for s in args]
        shortname = name[3:]

        key = shortname  # key for dict is shortname

        d_functions[key] = dict()
        d_functions[key]['prototype'] = proto
        is_float = proto.startswith('TA_RetCode TA_S_')
        d_functions[key]['is_float'] = is_float
        is_indicator = not proto.startswith('TA_RetCode TA_Set') and not proto.startswith('TA_RetCode TA_Restore')
        d_functions[key]['is_indicator'] = is_indicator
        is_lookback = '_Lookback' in proto
        d_functions[key]['is_lookback'] = is_lookback

        #d_functions[key]['shortname'] = shortname

        if not is_float and not is_lookback and is_indicator:
            func_info = abstract.Function(shortname).info
        else:
            func_info = {}
        d_functions[key]['info'] = func_info

    #print(d_functions)
    import json
    print(json.dumps(d_functions, indent=4))

    print(len(d_functions))

    with open('functions.json', 'w') as fd:
        json.dump(d_functions, fd, indent=4)
    

    # just for printing
    """
    import pandas as pd
    pd.options.display.max_rows = 10
    df_functions = pd.DataFrame(d_functions)
    df_functions = df_functions.transpose()
    df_functions.index.name = 'prototype'
    df_functions = df_functions.reset_index()
    print(df_functions)
    #df_functions.to_csv("func.csv", index=False)
    #df_functions.to_excel("func.xlsx", index=False)
    """

if __name__ == '__main__':
    main()
