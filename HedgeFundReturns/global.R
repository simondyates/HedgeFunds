library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyverse)

returns = read.csv('../EurekaHFIndices.csv')
returns = select(returns, -X50)
returns$Dates = as.Date(returns$Dates)

d_types = c('Index', 'Not Implemented')

to_returns = function(col_in) {
  print(length(returns[col_in]))
  returns[col_in][-1] / returns[col_in][1:(length(returns[col_in])-1)] -1
}
