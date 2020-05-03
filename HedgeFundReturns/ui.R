
# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Hedge Fund Returns"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput('data_type', 'Display', d_types, selected = 1)
        ),
        # Show a plot of the generated distribution
        mainPanel(
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
            plotOutput('linePlot')
        )
    )
))
