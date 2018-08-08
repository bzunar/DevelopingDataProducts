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

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}",
               HTML('#panel {background-color: white;
                    padding: 10px 20px 20px 20px;
                    cursor: move;
                    opacity: 0.6;
                    zoom: 0.9;
                    transition: opacity 500ms 1s;}
                    #panel:hover {opacity: 0.9;
                    transition-delay: 0;}
                    #show {padding: 5px 5px 5px 5px;
                    display: block;
                    margin-left: auto;
                    margin-right: auto;
                    margin-bottom: 10px;
                    font-weight: bold;}
                    .modal-header {text-align: center;
                    font-weight: bold;}
                    .modal {text-align: justify;}')),
    
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(bottom = 10, left = 10, draggable = TRUE, width = "20%", id = "panel",
                  actionButton("show", "Manual"),
                  sliderInput("range", "Nobel Prize", 1901, 2016,
                              value = c(1901, 2016), step = 1, sep = "", dragRange = TRUE),
                  sliderInput("laureated", "Age when awarded [years]", 17, 91,
                              value = c(17, 91), step = 1, dragRange = TRUE),
                  radioButtons("event", "Place of", choices = c("Birth", "Death"), selected = c("Birth")),
                  checkboxGroupInput("alive", " ",
                                     choices = c("Living", "Deceased"),
                                     selected = c("Living", "Deceased")),
                  checkboxGroupInput("sex", "Sex",
                                     choices = c("Male", "Female"),
                                     selected = c("Male", "Female")),
                  checkboxGroupInput("category", "Categories",
                                     choices = c("Chemistry", "Economics", "Literature", "Medicine", "Peace", "Physics"),
                                     selected = c("Chemistry", "Economics", "Literature", "Medicine", "Peace", "Physics"))
    )
)