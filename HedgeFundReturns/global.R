library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyverse)
library(scales)

returns = read.csv('../EurekaHFIndices.csv')
returns = select(returns, -Top.50)
returns$Dates = as.Date(returns$Dates)
defs = read.csv('../EurekaStratDefs.csv')

d_types = c('Returns', 'Standard Deviations', 'Sharpe Ratios')
f_types = c('3 month', '6 month', 'Annual')
N = nrow(returns)
l = ncol(returns)
sz_types = c('Small', 'Medium', 'Large', 'Billion Dollar')
c_names = gsub('\\.', ' ', names(returns)[c(-1, -2)])
st_types = c_names[! c_names %in% sz_types]
st_types = st_types[1:(length(st_types)-2)]
cp_types = c('Strategy', 'Size')
