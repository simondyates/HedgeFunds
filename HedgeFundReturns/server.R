
shinyServer(function(input, output) {
# First, define two functions for repeatedly-used data
    
    line_data = function(Idx, d1, d2, relSPY) {
        # Non-reactive function to provide data required by several bar charts
        
        # Filter for the date slider and columns we need
        df = filter(returns, Dates >= d1 & Dates <= d2) %>%
            select(., c('Dates', 'SPY', Idx))
        names(df)[3] = 'SelIdx'
        
        # Relativize returns if required
        if (relSPY == TRUE) {
            df = mutate(df, results = 100 * SelIdx / SPY)
        } else {
            df = mutate(df, results = SelIdx)
        }
        return(df)
    }
    
    
    bar_data = function(Idx, d1, d2, relSPY, f_type, ret_type) {
        # Non-reactive function to provide data required by several bar charts
        
        # Filter for the date slider and columns we need
        df = filter(returns, Dates >= d1 & Dates <= d2) %>%
            select(., c('Dates', 'SPY', Idx))
        names(df)[3] = 'SelIdx'
        
        # Calculate returns
        df = mutate(df, IdxR = SelIdx / lag(SelIdx, 1) - 1, 
                    SpyR = SPY / lag(SPY, 1) - 1)
        if (relSPY) {
            df = mutate(df, RelIndex = IdxR - SpyR)
        } else {
            df = mutate(df, RelIndex = IdxR)
        }
        
        # Group by selected frequency
        f = switch(f_type, '3 month' = 3, '6 month' = 6, 'Annual' = 12)
        groups = rep(1:100, 1, each = f)[1:nrow(df)]
        df = df %>% mutate(., gp=groups) %>% group_by(., gp)
        
        # Return output
        if (ret_type == 'Returns') {
            df = summarise(df, Dates = last(Dates), results = sum(RelIndex, na.rm = TRUE))
        } else if (ret_type == 'Standard Deviations') {
            df = summarise(df, Dates = last(Dates), results = sqrt(12) * 
                               sd(RelIndex, na.rm = TRUE))
        } else {
            df = summarise(df, Dates = last(Dates),
                           results = sum(RelIndex, na.rm = TRUE) /
                               (sqrt(12) * sd(RelIndex, na.rm = TRUE)))
        }
        return(df)
    }
    
# Second, define reactive functions that call the data functions when needed
    
    # Index Tab
    idx_line_react = reactive({
        df = line_data('Index', input$date_range[1], input$date_range[2], input$rel_rets)
        return(df)
    })
    
    idx_bar_react = reactive({
        df = bar_data('Index', input$date_range[1], input$date_range[2], input$rel_rets, input$freq_type, input$data_type)
        return(df)
    })
    
    # Strategy Tab
    str_line_react = reactive({
        df = line_data(gsub(' ', '\\.', input$strat_type), input$date_range[1], input$date_range[2], input$rel_rets)
        return(df)
    }) 
    
    str_bar_react = reactive({
         df = bar_data(gsub(' ', '\\.', input$strat_type), input$date_range[1], input$date_range[2], 
                       input$rel_rets, input$freq_type, input$data_type)
         return(df)
     })
     
    # Size Tab
    sz_line_react = reactive({
        df = line_data(gsub(' ', '\\.', input$size_type), input$date_range[1], input$date_range[2], input$rel_rets)
        return(df)
    })
    
    sz_bar_react = reactive({
         df = bar_data(gsub(' ', '\\.', input$size_type), input$date_range[1], input$date_range[2], input$rel_rets, input$freq_type, input$data_type)
         return(df)
     })
    
    
# Third, generate the plots
    
    # Define the generic plots
    
    draw_line = function(react) {
        if (input$rel_rets) {
            clr = '#FF4500'
        } else {
            clr = 'blue'
        }
        ln = ggplot(react) +
            geom_line(aes(x=Dates, y=results), color = clr) + ylim(100, 700) + labs(title = 'Index Performance', x = '', y = 'Index Level')
       return(ln)
    }
    
    draw_bar = function(react) {
        if (input$rel_rets) {
            clr = '#FF4500'
        } else {
            clr = 'blue'
        }
        ttl = paste('Index', input$freq_type,input$data_type)
        if (input$data_type == 'Sharpe Ratios') {
            fmt = comma
        } else {
            fmt = percent
        }
        bar = ggplot(react) +
            geom_col(aes(x=Dates, y=results), fill=clr) + labs(title = ttl, x = '', y = input$data_type) + scale_y_continuous(label=fmt)
        return(bar)
    }
    
    # Index Tab
    output$idxlinePlot = renderPlot({
        draw_line(idx_line_react())
    })
    
    output$idxbarPlot = renderPlot({
        draw_bar(idx_bar_react())
    })
    
    # Strategy Tab
    output$strlinePlot = renderPlot({
        draw_line(str_line_react())
    })
    
    output$strbarPlot = renderPlot({
        draw_bar(str_bar_react())
    })

    # Size Tab
    output$szlinePlot = renderPlot({
        draw_line(sz_line_react())
    })
    
    output$szbarPlot = renderPlot({
        draw_bar(sz_bar_react())
    })
})
