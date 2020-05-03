
shinyServer(function(input, output) {

    adj_returns = reactive({
        if (input$rel_rets == TRUE) {
            filter(returns, Dates >= input$date_range[1] & Dates<= input$date_range[2]) %>%
            mutate(., results = 100 * Hedge.Fund.Index / SPY)
            } else {
            filter(returns, Dates >= input$date_range[1] & Dates<= input$date_range[2]) %>%
            mutate(., results = Hedge.Fund.Index)
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

})
