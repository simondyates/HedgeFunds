
shinyServer(function(input, output) {
# First, define two functions for repeatedly-used data
    
    line_data = function(Idx, d1, d2, relSPY) {
        # Non-reactive function to provide data required by several line charts
        
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
        df = bar_data('Index', input$date_range[1], input$date_range[2], input$rel_rets, 
                      input$freq_type, input$data_type)
        return(df)
    })
    
    # Strategy Tab
    str_line_react = reactive({
        df = line_data(gsub(' ', '\\.', input$strat_type), input$date_range[1], input$date_range[2], 
                       input$rel_rets)
        return(df)
    }) 
    
    str_bar_react = reactive({
         df = bar_data(gsub(' ', '\\.', input$strat_type), input$date_range[1], input$date_range[2], 
                       input$rel_rets, input$freq_type, input$data_type)
         return(df)
     })
     
    # Size Tab
    sz_line_react = reactive({
        df = line_data(gsub(' ', '\\.', input$size_type), input$date_range[1], input$date_range[2], 
                       input$rel_rets)
        return(df)
    })
    
    sz_bar_react = reactive({
         df = bar_data(gsub(' ', '\\.', input$size_type), input$date_range[1], input$date_range[2], 
                       input$rel_rets, input$freq_type, input$data_type)
         return(df)
     })
    
    
# Third, generate the plots
    
    # Define the generic plots
    
    draw_line = function(react) {
        if (input$rel_rets) {
            clr = 'orange'
        } else {
            clr = 'blue'
        }
        ln = ggplot(react) +
            geom_line(aes(x=Dates, y=results), color = clr) + 
                ylim(100, 700) + 
                labs(title = 'Index Performance', x = '', y = 'Index Level')
       return(ln)
    }
    
    draw_bar = function(react) {
        if (input$rel_rets) {
            clr = 'orange'
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
            geom_col(aes(x=Dates, y=results), fill=clr) + 
                labs(title = ttl, x = '', y = input$data_type) + 
                scale_y_continuous(label=fmt)
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

    # Generate the Comparison Tab boxplot

    output$cpboxPlot = renderPlot({
    
    # Select dataset
    if (input$compare_type == 'Strategy') {
        cols = gsub(' ', '\\.', st_types)
    } else {
        cols = gsub(' ', '\\.', sz_types)
    }
    
    # Select columns
    df = filter(returns, Dates >= input$date_range[1] & Dates <= input$date_range[2]) %>%
        select(., c('Dates', 'SPY', cols))
    
    # Calculate relative returns
    df$SPY = df$SPY / lag(df$SPY, 1) - 1
    for (c in cols) {
        if (input$rel_rets) {
            df[c] = df[[c]] / lag(df[[c]], 1) - 1 - df$SPY
        } else {
            df[c] = df[[c]] / lag(df[[c]], 1) - 1
        }
    }
    
    # Group by selected frequency
    f = switch(input$freq_type, '3 month' = 3, '6 month' = 6, 'Annual' = 12)
    groups = rep(1:100, 1, each = f)[1:nrow(df)]
    df = df %>% mutate(., gp=groups) %>% group_by(., gp)
    
    # Summarise based on selected output
    st_devs = function(x) {
        return( sqrt(12) * sd(x, na.rm = TRUE))
    }
    
    sharpes = function(x) {
        return( sum(x, na.rm = TRUE) / (sqrt(12) * sd(x, na.rm = TRUE)))
    }
    
    if (input$data_type == 'Returns') {
        df = summarise_at(df, cols, sum, na.rm = TRUE)
    } else if (input$data_type == 'Standard Deviations') {
        df = summarise_at(df, cols, st_devs)
    } else {
        df = summarise_at(df, cols, sharpes)
    }
    df = select(df, -gp)
    names(df) = gsub('\\.', ' ', names(df))
    
    # Generate the boxplot
    if (input$data_type == 'Sharpe Ratios') {
        fmt = comma
    } else {
        fmt = percent
    }
    if (input$rel_rets) {
        clr = 'orange'
    } else {
        clr = 'light blue'
    }
    ttl = paste('Distribution of ', input$freq_type, ifelse(input$rel_rets, ' Relative ', ' '), 
                input$data_type, ' from ',
                input$date_range[1], ' to ', input$date_range[2], sep = '')
                
    box = ggplot(stack(df)) + geom_boxplot(aes(x = ind, y = values), fill = clr) +
            scale_y_continuous(label=fmt) + labs(title = ttl, x = '', y = input$data_type) +
            theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    return(box)
    })
    
    # Provide strategy descriptions
    output$str_desc = renderUI({
        str_col = gsub(' ', '\\.', input$strat_type)
        html = HTML(paste(h4(input$strat_type), p(defs[[str_col]])))
        return(html)
    })
    
    # Provide size descriptions
    output$sz_desc = renderUI({
        txt = switch(input$size_type, 
                     'Small' = 'An equally weighted index of 1295 funds with < $100m assets under management.', 
                     'Medium' = 'An equally weighted index of 580 funds with $100m - $500m assets under management.',
                     'Large' = 'An equally weighted index of 286 funds with $500m - $1bn assets under management.',
                     'Billion Dollar' = 'An equally weighted index of 149 funds with $500m - $1bn assets under management')
        html = HTML(paste(h4(input$size_type), p(txt)))
        return(html)
    })
})
