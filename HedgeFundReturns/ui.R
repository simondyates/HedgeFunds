
shinyUI(fluidPage(

    # Application title
    titlePanel("Hedge Fund Industry Returns"),

    sidebarLayout(
        sidebarPanel(
            selectInput('data_type', 'Bar Chart Display', d_types, selected = 1),
            selectInput('freq_type', 'Bar Chart Frequency', f_types, selected = 'Annual'),
            
        # If Sharpe is selected, define what it is
        conditionalPanel(
            condition = "input.data_type == 'Sharpe Ratios'",
            h4("Sharpe Ratio"),
            p("This is the ratio of annualized return to annualized
              standard deviation. Thus, a higher Sharpe ratio indicates that more return
              is being generated per unit of risk.")
            ),
        
        # If the user selected the Strategy tab, define the strategy
        conditionalPanel(
            condition = "input.tabsPanel == 'Strategies'",
            htmlOutput('str_desc')
            ),
        
        # If the user selected the Size tab, define the sizes
        conditionalPanel(
            condition = "input.tabsPanel == 'Sizes'",
            htmlOutput('sz_desc')
            )
        ),
        
        mainPanel(
            p("Data displayed here are indices of cumulative returns for groups of hedge funds, calculated by 
              EurekaHedge.  All indices have a base value of 100 as of 31 Dec 1999.  They can be viewed in their original form, 
              or can be relativized to the US equity market by checking the box 'vs. SPY'"), 
            br(),
            
            # Allow control of relative returns and date range across all tabs
            fluidRow(
                column(3, offset = 1, 
                    checkboxInput('rel_rets', 'vs. SPY', value = FALSE)   
                ),
                column(7, offset = 1,
                    sliderInput('date_range', 'Date Range:',
                                min = min(returns$Dates), max = max(returns$Dates),
                                value = c(min(returns$Dates), max(returns$Dates)),
                                timeFormat = '%b %Y')
                )
            ),
            tabsetPanel(id = 'tabsPanel',
                tabPanel('Index',
                    plotOutput('idxlinePlot'), 
                    plotOutput('idxbarPlot')
                ),
                tabPanel('Strategies',
                    selectInput('strat_type', 'Strategy', st_types, selected = 1), 
                    plotOutput('strlinePlot'), 
                    plotOutput('strbarPlot')
                ),
                tabPanel('Sizes',
                    selectInput('size_type', 'Size', sz_types, selected = 1), 
                    plotOutput('szlinePlot'), 
                    plotOutput('szbarPlot')
                ),
                tabPanel('Comparisons', 
                    selectInput('compare_type', 'Compare by', cp_types, selected = 1),
                    plotOutput('cpboxPlot'))
            )
        )
    )
))
