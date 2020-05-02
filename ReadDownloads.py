# Concatenates the Excel files downloaded from the Eurekahedge site into a single csv table
import pandas as pd
import os

data_dir = '/Users/simondyates/Desktop/EurekaHedge'

df = pd.read_excel(data_dir + '/EHI473_main_returns03-05-2020.xlsx')
name = df.iloc[0, 0].replace('Eurekahedge', '')
dates = df.iloc[3:247, 0]
values = df.iloc[3:247, 2]

agg_df = pd.DataFrame(values.values, index=dates, columns=[name])

for entry in os.scandir(data_dir):
    f_str = entry.path
    if f_str != (data_dir + '/EHI473_main_returns03-05-2020.xlsx'):
        df = pd.read_excel(f_str)
        name = df.iloc[0, 0].replace('Eurekahedge', '')
        dates = df.iloc[3:247, 0]
        values = df.iloc[3:247, 2]
        df = pd.DataFrame(values.values, index=dates, columns=[name])
        agg_df = agg_df.join(df)

agg_df.to_csv('EurekaHFIndices.csv')