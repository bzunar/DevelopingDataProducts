---
title: "Birth and Death <br> of Nobel Laureates"
author: "Bojan Zunar"
date: '8 August 2018 '
output: 
    html_document
---



## The Laureates

**Nobel laureates** are often thought of as almost greater-than-life scientific celebrities. Last year [Kaggle](https://www.kaggle.com/), a platform for predictive modelling and analytics competitions, has compiled the [Nobel Laureates Dataset](https://www.kaggle.com/nobelfoundation/nobel-laureates) which details 18 variables on 969 laureates. While many have probed the set statistically, it would also be interesting to interactively explore the dataset.


```r
dim(laureates)
```

```
## [1] 969  18
```

```r
colnames(laureates)
```

```
##  [1] "Year"                 "Category"             "Prize"               
##  [4] "Motivation"           "Prize.Share"          "Laureate.ID"         
##  [7] "Laureate.Type"        "Full.Name"            "Birth.Date"          
## [10] "Birth.City"           "Birth.Country"        "Sex"                 
## [13] "Organization.Name"    "Organization.City"    "Organization.Country"
## [16] "Death.Date"           "Death.City"           "Death.Country"
```

## Using R and Leaflet, we ploted places of their birth and death...

<img src="figure/unnamed-chunk-2-1.png" title="plot of chunk unnamed-chunk-2" alt="plot of chunk unnamed-chunk-2" width="100%" />




 First, we decided to create an HTML widget which plots places of birth and death for each Nobel laureate.

This is an R Markdown presentation. Markdown is a simple formatting syntax for authoring HTML, PDF, and MS Word documents. For more details on using R Markdown see <http://rmarkdown.rstudio.com>.

When you click the **Knit** button a document will be generated that includes both content as well as the output of any embedded R code chunks within the document.

## Slide with Bullets

- Bullet 1
- Bullet 2
- Bullet 3

## Slide with R Output

## Slide with Plot

![plot of chunk pressure](figure/pressure-1.png)

