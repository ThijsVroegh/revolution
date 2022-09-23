# Plotting historical revolutions

# https://rubenschalk.github.io/textcorpora/

#First we load the required libraries.
library(data.table)
library(spacyr)
library(maps)
library(rasterVis)
library(raster)
library(ggmap)
library(ggplot2)
library(ggpubr)

library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(rgeos)

# The Delpher dataset
revol <- fread("dutchnewspapers.csv")

setDT(revol)

x <- revol[,c("date", "article_title", "url")]
x[5851:5858]

x$date <- as.Date(x$date)
x[, year := as.numeric(substr(x$date, 1,4))]
setDT(x)
x[, .N, list(year)][order(-year)][1:10]

x$article_title <- tolower(x$article_title)

library(reticulate)
use_python("C:/Users/Gebruiker/AppData/Local/r-miniconda/envs/spacy_condaenv/python.exe")
use_virtualenv("~/myenv")
use_condaenv("myenv")

spacy_install()
spacy_initialize()
spacy_initialize(model = "nl_core_news_sm")

parsedtxt <- spacy_parse(x$article_title, lemma = FALSE, entity = TRUE, nounphrase = TRUE)

locations <- entity_extract(parsedtxt)

setDT(locations)
top100 <- locations[entity_type == "GPE", .N, list(entity) ][order(-N)]

head(top100)

coordinates_delpher <- fread("coordinates_delpher.csv")
head(coordinates_delpher)

# ====
coordinates_times <- fread("coordinates_times.csv")
head(coordinates_times)

coordinates_delpher[, dataset := "delpher"]
coordinates_times[, dataset := "times",]

coordinates_delpher <- coordinates_delpher %>% 
    dplyr::rename("N" = "n_delpher","entity" = "entity_delpher")

coordinates_times <- coordinates_times %>% 
    dplyr::rename("N" = "n_times","entity" = "entity_times")

coordinates_times <- coordinates_times[!is.na(lon),]
coordinates_delpher <- coordinates_delpher[!is.na(lon),]

world  <- ne_countries(scale = "medium", returnclass = "sf")
Europe <- world[which(world$continent == "Europe"),]

# Now that we have our map loaded, we parse it to ggplot.
# Then we can add our data to it. 
# The size of the dots corresponds to the number of times
# the geocoded placename is mentioned in our article titles.
# You’ll see that Paris and France are dominant, but also
# that we spot some unexpected places in Italy and
# even Eastern Europe.

p <- ggplot(Europe) +
    geom_sf() +
    coord_sf(xlim = c(-25,50), ylim = c(35,70), expand = FALSE)

times <- p + geom_point(data = coordinates_times, aes(x=lon, y=lat, 
                                                      size=(N)), shape=16, color = "red")
invisible(ggplot_build(times))
ggsave("times_map 16sept.png")

delpher <- p + geom_point(data = coordinates_delpher, aes(x=lon, y=lat, size=(N)), shape=16, color = "blue")
invisible(ggplot_build(delpher))
ggsave("delpher_map 16sept.png")

invisible(ggarrange(times, delpher))
ggsave("all_map.png",width = 60, height = 20, units = "cm")
