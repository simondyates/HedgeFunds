
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
        df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2]) %>%
            filter(., row_number() %% f == 1) %>%
            mutate(., prd_ret = Index / lag(Index, 1) - 1, 
                   spy_ret = SPY / lag(SPY, 1) - 1)
        if (input$rel_rets == TRUE) {
            mutate(df, results = prd_ret - spy_ret)
        } else {
            mutate(df, results = prd_ret)
        }
    })
    
    output$linePlot = renderPlot({
        if (input$data_type == 'Index'){
            ggplot(adj_returns()) +
                geom_line(aes(x=Dates, y=results))
        } else {
            print('No')
        }
    })
    
    output$barPlot = renderPlot({
        if (input$data_type == 'Index'){
            ggplot(bar_returns()) +
                geom_col(aes(x=Dates, y=results))
        } else {
            print('No')
        }
    })
})
