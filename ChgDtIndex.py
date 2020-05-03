import yfinance as yf
import pandas as pd
import numpy as np
SPY = yf.download('SPY', start='1999-12-31', end='2020-04-01')

b_array = SPY.index.month[:-1] != SPY.index[1:].month
b_array = np.append(b_array, True)
SPY_me = SPY[b_array]
SPY_me.index = SPY_me.index.strftime('%Y-%m-%d')

HFs = pd.read_csv('EurekaHFIndices.csv', index_col=0)
HFs.set_index(SPY_me.index, inplace=True)
HFs.index.name = 'Dates'

HFs.to_csv('EurekaHFIndices.csv')