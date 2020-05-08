# load libraries
library(curl)
library(tidyverse)
library(readxl)
library(data.table)
library(rworldmap)
library(ggplot2)
library(dplyr)
library(tweenr)
library(ggthemes)
library(viridis)
library(rgeos)
library(countrycode)
library(devtools)
install_github("dgrtwo/gganimate", ref = "26ec501")
library(gganimate)

area <- read_csv("~/Downloads/forest-area-as-share-of-land-area.csv")
colnames(area)[1] <- c("country")
colnames(area)[4] <- c("forrest")

area[, country_iso3c := countrycode(country, 'country.name', 'iso3c')]
vmax <- max(area$forrest, na.rm=T)
vmin <- min(area$forrest, na.rm=T)
# get world map
wmap <- getMap(resolution="low")
# small edits
wmap <- spTransform(wmap, CRS("+proj=robin")) # reproject
wmap <-   subset(wmap, !(NAME %like% "Antar")) # Remove Antarctica
# get centroids of countries
centroids <- gCentroid( wmap , byid=TRUE, id = wmap@data$ISO3)
centroids <- data.frame(centroids)
setDT(centroids, keep.rownames = TRUE)[]
setnames(centroids, "rn", "country_iso3c")

wmap_df <- fortify(wmap, region = "ISO3")
wmap_df <- left_join(wmap_df, area, by = c('id'='Code'))        # data
wmap_df <- left_join(wmap_df, centroids, by = c('id'='country_iso3c')) # centroids
colnames(wmap_df)[10] <- c("forrest")

legend.scale(c(0, 1), col = cm.colors(24))
library(scales)
o <- ggplot(data=wmap_df) +
  geom_polygon(aes(x = long, y = lat, group = group, fill=forrest, frame = Year), color="gray90") +
  scale_fill_viridis(name="Forest area as a proportion of total land area (%)", begin = 0, end = 1, limits = c(vmin,vmax), na.value="gray99") +
  theme_void() +
  guides(fill = guide_colorbar(title.position = "top")) +
  labs(title = "Forest Share") +
  labs(caption = "Map by Nathanael Sheehan, CASA UCL.") +
  theme(plot.title = element_text(hjust = 0.5, vjust = 0.05, size=25)) +
  theme(plot.caption = element_text(hjust = 0, color="gray40", size=15)) +
  coord_cartesian(xlim = c(-11807982, 14807978)) +
  theme( legend.position = c(.5, .08), 
         legend.direction = "horizontal", 
         legend.title.align = 0,
         legend.key.size = unit(1.3, "cm"),
         legend.title=element_text(size=17), 
         legend.text=element_text(size=13) )

o
+ scale_fill_continuous(breaks = c(5,10,15,20,25,30,35,40,45,50,55,60,65,70,75), labels = c("5%","10%","15%","20%","25%","30%","35%","40%", "45%", "50%","55%","60%", "65%", "70%", "75%"))

# save gif
gg_animate(o, "foresyt.gif", title_frame =T, 
           ani.width=1600, ani.height=820, dpi=800, interval = .4)
