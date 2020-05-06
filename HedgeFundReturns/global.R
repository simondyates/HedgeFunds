library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyverse)

returns = read.csv('../EurekaHFIndices.csv')
returns = select(returns, -Top.50)
returns$Dates = as.Date(returns$Dates)

d_types = c('Returns', 'Standard Deviations', 'Sharpe Ratios')
f_types = c('3 month', '6 month', 'Annual')
N = nrow(returns)
l = ncol(returns)
sz_types = c('Small', 'Medium', 'Large', 'Billion Dollar')
c_names = gsub('\\.', ' ', names(returns)[c(-1, -2)])
st_types = c_names[! c_names %in% sz_types]
st_types = st_types[1:(length(st_types)-2)]

to_returns = function(col_in) {
  print(length(returns[col_in]))
  returns[col_in][-1] / returns[col_in][1:(length(returns[col_in])-1)] -1
}
