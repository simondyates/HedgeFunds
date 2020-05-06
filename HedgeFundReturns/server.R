
shinyServer(function(input, output) {

    adj_returns = reactive({
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2])
        if (input$rel_rets == TRUE) {
            mutate(df, results = 100 * Index / SPY)
            } else {
            mutate(df, results = Index)
            }
    })
    
    bar_returns = reactive({
        f = switch(input$freq_type, '3 month' = 3, '6 month' = 6, 'Annual' = 12)
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2]) 
        if (input$rel_rets == TRUE) {
            df = mutate(df, RelIndex = 100 * Index / SPY)
        } else {
            df = mutate(df, RelIndex = Index)
        }
        if (input$data_type == 'Returns') {
            df = df %>% filter(., row_number() %% f == 1) %>%
                mutate(., results = RelIndex / lag(RelIndex, 1) - 1)
        }
        else {
            groups = rep(1:100, 1, each=f)[1:nrow(df)]
            df = df %>% mutate(., gp=groups) %>% group_by(., gp)
            if (input$data_type == 'Standard Deviations') {
                    df = summarise(df, Dates = last(Dates), results = sd(RelIndex))
            } else {
                    df = summarise(df, Dates = last(Dates),
                                   results = (last(RelIndex) / first(RelIndex) - 1) /
                                       sd(RelIndex))
                }
            return(df)
        }
    })
    
    output$linePlot = renderPlot({
        # Need to add titles and axis labels etc.
        ggplot(adj_returns()) +
            geom_line(aes(x=Dates, y=results))
    })
    
    output$barPlot = renderPlot({
        ggplot(bar_returns()) +
            geom_col(aes(x=Dates, y=results), fill='blue')
        })
})
