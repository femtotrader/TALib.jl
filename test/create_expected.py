#!/usr/bin/env python

"""
Create expected indicators values using Python TA-Lib wrapper
"""
import numpy as np
import pandas as pd
pd.options.display.max_rows = 20
import talib
import traceback

def main():
    df = pd.read_csv("ford_2012.csv", index_col='Date', parse_dates='Date')
    df['Volume'] = df['Volume'].astype(np.float64)
    df.columns = [s.lower() for s in df.columns]
    print(df)
    lst_errors = []
    for i, funcname in enumerate(talib.get_functions()):
        try:
            print("%03d %s" % (i, funcname))
            func = talib.abstract.Function(funcname)
            print(func.info)
            expected = func(df)
            if isinstance(expected, pd.Series):
                expected.name = "Value"
                expected = pd.DataFrame(expected)
            print(expected)
            print(type(expected))
            print("")
            expected.to_csv("expected/%s.csv" % funcname)
        except:
            print(traceback.format_exc())
            lst_errors.append(funcname)

    print("errors: %s" % lst_errors)

if __name__ == '__main__':
    main()
