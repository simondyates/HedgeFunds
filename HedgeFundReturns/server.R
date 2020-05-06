
shinyServer(function(input, output) {

    adj_returns = reactive({
        # Handles the main page line chart data
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2])
        if (input$rel_rets == TRUE) {
            mutate(df, results = 100 * Index / SPY)
            } else {
            mutate(df, results = Index)
            }
    })
    
    bar_returns = reactive({
        # Handles the main page bar chart data
        
        # Filter for the date slider and columns we need
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2]) %>%
            select(., one_of(c('Dates', 'SPY', 'Index')))
        # (if index is a sub index rename it here based on position)
        
        # Calculate returns
        df = mutate(df, IdxR = Index / lag(Index, 1) - 1, 
                    SpyR = SPY / lag(SPY, 1) - 1)
        if (input$rel_rets == TRUE) {
            df = mutate(df, RelIndex = IdxR - SpyR)
        } else {
            df = mutate(df, RelIndex = IdxR)
        }
        
        # Group by selected frequency
        f = switch(input$freq_type, '3 month' = 3, '6 month' = 6, 'Annual' = 12)
        groups = rep(1:100, 1, each = f)[1:nrow(df)]
        df = df %>% mutate(., gp=groups) %>% group_by(., gp)
        
        # Return output
        if (input$data_type == 'Returns') {
            df = summarise(df, Dates = last(Dates), results = sum(RelIndex, na.rm = TRUE))
        } else if (input$data_type == 'Standard Deviations') {
            df = summarise(df, Dates = last(Dates), results = sqrt(12) * 
                               sd(RelIndex, na.rm = TRUE))
        } else {
            df = summarise(df, Dates = last(Dates),
                                   results = sum(RelIndex, na.rm = TRUE) /
                                       (sqrt(12) * sd(RelIndex, na.rm = TRUE)))
        }
        return(df)
})
    
    str_adj_returns = reactive({
        # Handles the strategy tab's line chart data
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2])
        cols = c('Dates', 'SPY')
        cols[3] = gsub(' ', '\\.', input$strat_type)
        df = df %>% select(., cols) %>% rename(., SelIndex = 3)
        if (input$rel_rets == TRUE) {
            mutate(df, results = 100 * SelIndex / SPY)
        } else {
            mutate(df, results = SelIndex)
        }
    })
    
    output$linePlot = renderPlot({
        # Need to add titles and axis labels etc.
        # Maybe keep axis range fixed
        ggplot(adj_returns()) +
            geom_line(aes(x=Dates, y=results))
    })
    
    output$barPlot = renderPlot({
        ggplot(bar_returns()) +
            geom_col(aes(x=Dates, y=results), fill='blue')
        })
    
    output$strlinePlot = renderPlot({
        # Need to add titles and axis labels etc.
        ggplot(str_adj_returns()) +
            geom_line(aes(x=Dates, y=results))
    })
})
