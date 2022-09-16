# Plotting historical revolutions

#First we load the required libraries.
library(data.table)
library(spacyr)
library(maps)
library(rasterVis)
library(raster)
library(ggmap)
library(ggplot2)
library(ggpubr)

# The Delpher dataset.
revol <- fread("dutchnewspapers.csv")

setDT(revol)

x <- revol[,c("date", "article_title", "url")]
x[5851:5858]

x$date <- as.Date(x$date)
x[, year := as.numeric(substr(x$date, 1,4))]
setDT(x)
x[, .N, list(year)][order(-year)][1:10]

x$article_title <- tolower(x$article_title)

spacy_initialize(model = "nl_core_news_sm")
