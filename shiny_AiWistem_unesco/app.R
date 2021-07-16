#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(tidyverse)


# UI ####
ui <- dashboardPage(
    skin = 'black',
    dashboardHeader(title= "After iGEM Women in STEM UNESCO Database", 
                    titleWidth = 400),
    
    dashboardSidebar(collapsed = TRUE,
                     sidebarMenu(
                         menuItem("Data Download",tabName = 'data',icon = icon('search')),
                         menuItem("Background", tabName = "context", icon = icon("book-open"))
                     )),
    dashboardBody(
        tabItems(
            tabItem(tabName = "data", 
                    fluidRow(
                        # Filters ####
                        box(title = "Filters",
                            selectInput(inputId = "filter_data",
                                        label = "Select Datasets: Defaults to all",
                                        choices = c("National Monitoring",
                                                    "Research and Development",
                                                    "Innovation"),
                                        selected = c("National Monitoring",
                                                     "Research and Development",
                                                     "Innovation"),
                                        multiple = TRUE),
                            
                            sliderInput(inputId = 'filter_years',
                                        label = "Select Years",
                                        value = c(1970,2020),
                                        min = 1970,
                                        max = 2020,
                                        sep = ""),
                            
                            selectizeInput(inputId = "filter_countries",
                                           label = "Select Countries: No selection will return all",
                                           choices = NULL,
                                           selected = NULL,
                                           multiple = TRUE),
                            
                            selectizeInput(inputId = 'filter_codes',
                                           label = "Select Indicator Codes",
                                           choices = NULL,
                                           selected = NULL,
                                           multiple = TRUE),
                            
                            
                            radioButtons(inputId = "long_wide",
                                         label = "Database Format: (Wide: Years are Columns)",
                                         choiceNames = c("Long: More Data","Wide: Some Data loss, Years as columns"),
                                         choiceValues = c("Long","Wide"),
                                         selected = "Long"),
                            
                            # actionButton(inputId = "make_sheets",
                            #                label = "Generate Database"),
                            
                            "Downloads will take a few seconds depending on filters.",
                            br(),
                            
                            downloadButton(outputId = "create_sheet",
                                           label = "Download Database"),
                            br(),
                            br(),
                            conditionalPanel(
                                condition = "input.long_wide == 'Wide'",
                                downloadButton(
                                    outputId = "create_meta",
                                    label = "Download Metadata File if using wide format"))
                        )
                    )
            ),
            tabItem(tabName = "context",
                    
                    includeMarkdown('./addit_info.Rmd')
                    
                    
            )
        ))
)


# Server ####
server <- function(input, output) {
    
    # Data Import #### 
    countries <- read_csv('./countries.csv', na='', col_types = 'cc')
    data_nat  <- read_csv("./data_nat.csv", na='',col_types = 'cccddcccc')
    label     <- read_csv("./label.csv", col_types = 'ccc')
    meta      <- read_csv("./meta.csv",na='',col_types = 'ccdcccc')
    
    # Filter Options ####
    
    years <- (1970:2020)
    
    countries_opts <- setNames(countries$COUNTRY_ID,countries$COUNTRY_NAME_EN)
    
    
    # not using currently
    #regions   <- unique(cbind(natmon_data_reg$REGION_ID, sci_data_reg$REGION_ID))
    
    codes <- list(
        "Innovation" = setNames(
            label[label$source == "inno",]$INDICATOR_ID, 
            label[label$source == "inno",]$INDICATOR_LABEL_EN),
        
        "Research and Development" = setNames(
            label[label$source == 'sci',]$INDICATOR_ID,
            label[label$source == 'sci',]$INDICATOR_LABEL_EN),
        
        "National Monitoring" = setNames(
            label[label$source == 'natmon',]$INDICATOR_ID,
            label[label$source == 'natmon',]$INDICATOR_LABEL_EN)
    )
    
    updateSliderInput(inputId = 'filter_years',
                      value = c(min(years), max(years)),
                      min = min(years),
                      max = max(years))
    
    updateSelectizeInput(inputId = 'filter_countries',
                         choices = countries_opts)
    
    observeEvent(input$filter_data, {
        updateSelectizeInput(inputId = 'filter_codes',
                             choices = codes[input$filter_data])
        
    })
    
    # Data Preparation ####
    search_years     = reactive({input$filter_years[1]:input$filter_years[2]})
    search_countries = reactive({
        if (length(input$filter_countries) != 0) { 
            input$filter_countries
        } else{countries$COUNTRY_ID}
    })
    
    search_codes     = reactive({
        if (length(input$filter_codes) != 0) {
            input$filter_codes
        } else{label$INDICATOR_ID}
    }) 
    
    
    
    # Data & Download ####
    #observeEvent(input$make_sheets,{
    final_data <- reactive({
        
        data <- data_nat %>%
            filter(.,
                   YEAR %in% search_years(),
                   COUNTRY_ID %in% search_countries(),
                   INDICATOR_ID %in% search_codes())
        
        if(input$long_wide == "Long"){
            
            final_data <- data %>%
                left_join(.,meta,
                          by=c('INDICATOR_ID', 'COUNTRY_ID', 
                               'YEAR', 'COUNTRY_NAME_EN',
                               "INDICATOR_LABEL_EN")) %>% 
                select(., -SOURCE.y) %>% 
                rename(., SOURCE = SOURCE.x)
            
        }else{
            final_data <- data %>%
                select(-c(MAGNITUDE,QUALIFIER)) %>%
                pivot_wider(., id_cols= c(INDICATOR_ID,COUNTRY_ID),
                            names_from = YEAR,
                            values_from = VALUE)
        }
        #print('check3')
        final_data
        
    })
    filtered_meta <- reactive({
        meta %>% 
            filter(., 
                   YEAR %in% search_years(),
                   COUNTRY_ID %in% search_countries(),
                   INDICATOR_ID %in% search_codes())
    })
    
    
    
    
    
    output$create_sheet <- downloadHandler(
        filename = function(){paste0(format(Sys.Date(),"%y%m%d"), "_concat_unesco.csv")},
        content = function(file){write.csv(final_data(),file,row.names = FALSE)})
    
    output$create_meta <- downloadHandler(
        filename = function(){paste(format(Sys.Date(),"%y%m%d"), "_metadata.csv")},
        content = function(file){write.csv(filtered_meta(),file,row.names = FALSE)
        })
    
}


# Run the application ####
shinyApp(ui = ui, server = server)
