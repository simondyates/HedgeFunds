
# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Hedge Fund Returns"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput('data_type', 'Bar Chart Display', d_types, selected = 1),
            selectInput('freq_type', 'Bar Chart Frequency', f_types, selected = 'Annual'),
            p("p creates a paragraph of text.")
        ),
        # Show a plot of the generated distribution
        mainPanel(
            p("Data displayed in this app are indices of cumulative returns for sets of hedge funds, calaulated by 
              EurekaHedge.  All indices have a base value of 100 as of 31 Dec 1999.  They can be viewed in their original form, 
              or can be relativized to the broad equity market by checking the box 'vs. SPY'"), 
            br(),
            
            fluidRow(
                column(3, offset = 1, 
                    checkboxInput('rel_rets', 'vs. SPY', value = FALSE)   
                ),
                column(7, offset = 1,
                    sliderInput('date_range', 'Date Range:',
                                min = min(returns$Dates), max = max(returns$Dates),
                                value = c(min(returns$Dates), max(returns$Dates)),
                                timeFormat = '%b %Y'),
                )
            ),
            tabsetPanel(
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
                )
            )
        )
    )
))
