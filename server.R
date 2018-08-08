#
# This is a Shiny web application "Birth and Death of Nobel laureates v1.4"
# 
# Last changed on 7 August 2018
# 

library(shiny)
library(leaflet)
library(dplyr)
library(lubridate)
library(tidyr)
library(doBy)

server <- function(input, output, session) {
    
    laureates.final <- readRDS("laureatesFinal.rds")
    
    getColor <- function(x) {
        unname(
            sapply(x$Category, function(Category) {
                if(Category == "Chemistry") {"red"}
                else if(Category == "Literature") {"orange"}
                else if(Category == "Medicine") {"green"}
                else if(Category == "Peace") {"lightgreen"}
                else if(Category == "Physics") {"blue"}
                else if(Category == "Economics") {"purple"}
                else {"white"}
            })
        )
    }
    
    laureates.filtered <- reactive({
        laureates.final %>%
            mutate(lngBirth = as.numeric(as.character(lngBirth)),
                   latBirth = as.numeric(as.character(latBirth)),
                   lngDeath = as.numeric(as.character(lngDeath)),
                   latDeath = as.numeric(as.character(latDeath)),
                   lngBirth = ifelse(Birth.Date == "", NA, lngBirth),
                   latBirth = ifelse(Birth.Date == "", NA, latBirth),
                   lngDeath = ifelse(Death.Date == "", NA, lngDeath),
                   latDeath = ifelse(Death.Date == "", NA, latDeath),
                   HtmlBirth = paste0("<center>", Icon, "<br>",
                                      "<b><a href='", Wiki, "'>",
                                      Full.Name, "</a><br><tt>",
                                      Category, ": ", 
                                      Year, "</b></tt><blockquote>",
                                      Motivation, "</blockquote>born:",
                                      Birth.Date, ", ", 
                                      Birth.City, ", ", 
                                      Birth.Country, "</center>"),
                   HtmlDeath = paste0("<center>", Icon, "<br>",
                                      "<b><a href='", Wiki, "'>",
                                      Full.Name, "</a><br><tt>",
                                      Category, ": ", 
                                      Year, "</b></tt><blockquote>",
                                      Motivation, "</blockquote>died:",
                                      Death.Date, ", ", 
                                      Death.City, ", ", 
                                      Death.Country, "</center>")) %>%
            doBy::renameCol(paste0("lng", input$event),"lng") %>%
            doBy::renameCol(paste0("lat", input$event),"lat") %>%
            doBy::renameCol(paste0("Html", input$event),"Html") %>%
            mutate(Year = as.numeric(Year),
                   Birth.Date = ymd(Birth.Date),
                   Award.Date = ymd(paste0(Year, "-12-10")),
                   Death.Date = ymd(Death.Date)) %>%
            drop_na(Birth.Date, Award.Date) %>%
            mutate(Old.When.Awarded = Award.Date - Birth.Date,
                   Old.When.Died = Death.Date - Birth.Date,
                   Lived.With.Award = Death.Date - Award.Date,
                   Alive = ifelse(is.na(Old.When.Died), "Living", "Deceased")) %>%
            filter(Year >= input$range[1],
                   Year <= input$range[2],
                   Old.When.Awarded >= dyears(input$laureated[1]),
                   Old.When.Awarded <= dyears(input$laureated[2]),
                   Alive %in% input$alive,
                   Sex %in% input$sex,
                   Category %in% input$category,
                   lng != "",
                   lat != "")
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addProviderTiles(providers$Esri.WorldImagery, 
                             group = "Landscape") %>%
            addProviderTiles(providers$Stamen.TonerLines,
                             group = "Landscape", options = providerTileOptions(opacity = 0.5)) %>%
            addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012, 
                             group = "Urbanization", options = providerTileOptions(noWrap = TRUE)) %>%
            addProviderTiles(providers$CartoDB.DarkMatter, 
                             group = "GeoLabels") %>%
            addLayersControl(baseGroups = c("Landscape","Urbanization", "GeoLabels"),
                             options = layersControlOptions(collapsed = FALSE)) %>%
            addControl(HTML("<b><center>Birth and Death of Nobel Laureates</b><br><small> v1.4 (2018-08-07)</small></center>"),
                       position = "bottomright")
    })
    
    observeEvent({
        input$range
        input$category
        input$sex
        input$laureated
        input$alive
        input$event
    }, {
        filtered <- laureates.filtered()
        if (nrow(filtered) == 0) {
            filtered <- data.frame(Full.Name = "The Birthplace of R", Year = "1992", Category = "", lat = "-36.852225", lng = "174.769096",
                                   Html = "<center><img src=\"data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACgAAAAoCAYAAACM/rhtAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAOZSURBVFhH5ZhbyE5ZGMc/x9BocpaZ0SiH5JASUgiNQyNuJkTJMaeSQm4dC6UcCiM5JhcTczWoaeaCuJhRDsn5NFMuECnTqBHD77c+u8/3fe9+99qv931d+Nev9rP23ms/e+21nvU8u+ZzUFcYA9NhIcyHH2AwtIWqqyl8Bwfgb3hbhNfwJ6yD3lBRNQdH5y748FdwBjbADBgFjpqMh0WwG25C4vApGAZl11C4DD7kPiyD9hCrAbAT/oX/4RB0gLJoFThaz2EpOJKlqjPsB510enzUaDaDXeConYWvoFxyCjyBlzDZhlLk/NG5I9DChjLrW7gF/8E4G/JoBejcUWhiQ4VkiLoDzs2+NsTIeZGs0JY2VFh94AVcg1Y2FJMLwNXqguhmQ5U0C/xia4JVRAvAC5cEq7r6HVw0fvaCcodwPtyDmFDSHaYWwF3ma8irIeDgbAlWAdmxFywPVrZmgten8St8A3nkvH8MBaOGAdQl3zFY2Uoc3AG+nBgu5sJp8NxtaA2x8l7vmxisBjKy+waxShxMm68/gefdv2PlTuMuszVYH8gVa2cbgxWnLAengOcN+Hl0Hc7VHtZpNNiZD41VloOTwPONRiNDJ+BZ7WGdkoeNDFacshw8DJ6fFqx4bQfvq7dJmAnbOChYcUoc/HCRiA4dA+eSQT9v9rMe7LdeOpesHmNRrBIHC6FzP0MnyKtNYB9fBuu9fGsbxwYrTomD+yAJ0vbj/HGrLDUh3QNvoF6SYpruwxYHK05pc3Al2L4tWPllgP+r9rBOVl8WOHlCQpqDZiQ+wIyopw055Kg9gl+C1UAX4EbtYZTSHFSzwXOGjDzqB963OlgNlKyegcHKVjEHTTyugOdH2BCpteA9FlmN1AtcfYaNGBVzUH0Pnv8DYrJyw5Hb7aVgpegkmH67J1Zbc8AXmhesFA0HR9HMppr6Ah6CPwUyCzSLap2cEKzq6Edw9Ny/M+UW41wwcexhQ4WV1CP+64mWvzqci5YAqTVCGWRiapLsnt3Ghjwyn/Nma5RK/JkyVtq/WXcpe3aQvyj+AetWOyyHXBB7wc96ET76C1nxXwU7/A38/KXIOOdLulrt6yDk/qxpsvCxqLZutXNrF1O0mHjZH/yB+QC813kdtVpLURewbnWF+zDDkTXEcTB78WfmZjBlMitx4/c6cevzpSrxI6qRfIgr0HrjPDyFxBExn3PEzErc+B3FTy6dbveez0U1Ne8A4UTw/uxwEM8AAAAASUVORK5CYII=\"><br><b><a href='https://en.wikipedia.org/wiki/R_(programming_language)'>University of Auckland, New Zealand</a><br><tt>1992</b></tt><blockquote>0 results found.</blockquote>Too narrow search parameters.<br>Are you trying to crash the app?</center>")
            
        }
        leafletProxy("map", data = filtered) %>%
            clearMarkerClusters() %>%
            clearMarkers() %>%
            addAwesomeMarkers(lng = ~as.numeric(as.character(lng)), 
                              lat = ~as.numeric(as.character(lat)), 
                              label = ~Full.Name, 
                              popup = ~Html,
                              icon = awesomeIcons(icon = "pin", 
                                                  iconColor = "white", 
                                                  library = "ion",
                                                  markerColor = getColor(filtered)),
                              clusterOptions = markerClusterOptions()) %>%
            addLayersControl(baseGroups = c("Landscape","Urbanization", "GeoLabels"),
                             options = layersControlOptions(collapsed = FALSE))
    })
    
    observeEvent(input$show, {
        showModal(modalDialog(
            title = "Documentation",
            HTML("The app <I>\'Birth and Death of Nobel Laureates\'</I> is based on the <a href=\"https://www.kaggle.com/nobelfoundation/nobel-laureates\">Kaggle's <I>Nobel Laureates dataset</I></a> (accessed on 4 August 2018). <b>The app draws the laureates by their places of birth and death</b>, and filters them by the year in which they were awarded, their age at the time, and the category for which they were awarded. Circles denote clusters which break into individual markers as the user zooms in. Each marker contains additional information about the laureate and includes the Wikipedia link.<br>In the right corner of the window, the user can change between the standard map of the world and those that approximate population density (NASA\'s \'Earth at Night\' data, showing the human-generated light emanating from Earth at night) and those that focus on the geographic labels.<br>Happy hunting! :)"),
            easyClose = TRUE
        ))
    })
}