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
revol <- fread("dutchnewspapers-public_query=revolutie_date=1840-01-01_1860-12-31_ocr=80_100_category=artikel.csv")
#revol <- fread("C:\\Users\\Schal107\\Documents\\UBU\\Team DH\\Delpher\\dutchnewspapers-public_query=revolutie_date=1840-01-01 1860-12-31_ocr=80 100_sort=date,desc.csv")

setDT(revol)
