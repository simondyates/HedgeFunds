import yfinance as yf
import pandas as pd
import numpy as np
SPY = yf.download('SPY', start='1999-12-31', end='2020-04-01')

b_array = SPY.index.month[:-1] != SPY.index[1:].month
b_array = np.append(b_array, True)
SPY_me = SPY[b_array]
SPY_me.index = SPY_me.index.strftime('%b %Y')
SPY_me['index_lvl'] = SPY_me['Adj Close'] * 100 / SPY_me['Adj Close'][0]
SPY_me = SPY_me[['index_lvl']]
SPY_me.columns = ['SPY']

HFs = pd.read_csv('EurekaHFIndices.csv', index_col=0)
HFs = HFs.join(SPY_me)
HFs.to_csv('EurekaHFIndices.csv')