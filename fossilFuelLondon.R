#pack installation
install.packages('maptools')
install.packages(c("OpenStreetMap", "classInt", "tmap"))
install.packages(c("RColorBrewer", "sp", "rgeos", 
                   "tmaptools", "sf", "downloader", "rgdal", 
                   "geojsonio"))
#Load Packages
library(maptools)
library(RColorBrewer)
library(classInt)
library(sp)
library(rgeos)
library(tmap)
library(tmaptools)
library(sf)
library(rgdal)
library(geojsonio)
library(tidyverse)

EW <- geojson_read("https://opendata.arcgis.com/datasets/8edafbe3276d4b56aec60991cbddda50_2.geojson", what = "sp")
#pulling out london borough map plot
LondonMap <- EW[grep("^E09",EW@data$lad15cd),]
#plot it using the base plot function
qtm(EW)
#read the shapefile into a simple features object
BoroughMapSF <- st_read("~/University/GIS/wk1/statistical-gis-boundaries-london/ESRI/London_Borough_Excluding_MHW.shp")

BoroughMapSP <- LondonMap
#plot it very quickly usking qtm (quick thematic map) to check
#it has been read in correctly
qtm(BoroughMapSF)
qtm(BoroughMapSP)

library(methods)
#check the class of BoroughMapSF
class(BoroughMapSF)
class(BoroughMapSP)
#now convert the SP object into an SF object...
newSF <- st_as_sf(BoroughMapSP)
#and try the other way around SF to SP...
newSP <- as(newSF, "Spatial")
#simples!
BoroughMapSP <- as(BoroughMapSP, "Spatial")

#join the data to the @data slot in the SP data frame
BoroughMapSP@data <- data.frame(BoroughMapSP@data,LondonData[match(BoroughMapSP@data[,"GSS_CODE"],LondonData[,"New.code"]),])
londonBoroughFossilFuelInvestment <- read_csv("~/Downloads/LondonBoroughFossilFuelPensionInvestment.csv")
#check it's joined.
head(BoroughMapSP@data)
BoroughDataMap<-merge(BoroughMapSF, 
                      londonBoroughFossilFuelInvestment, 
                      by.x="GSS_CODE", 
                      by.y="GSS_CODE",
                      no.dups = TRUE)

library(tmap)
library(tmaptools)
install.packages("shinyjs")

library(shinyjs)
#it's possible to explicitly tell R which 
#package to get the function from with the :: operator...
tmaptools::palette_explorer()
tmap_mode("view")
tm_shape(BoroughDataMap) +
  tm_polygons("londonShare",
              style="cont",
              palette="Greens",
              midpoint=NA,
              title="London Borough Fossil Fuel Pension Investment By Borough (£)") +
  tmap_options(max.categories = 10) 

colours<- brewer.pal(5, "Blues")

breaks<-classIntervals(BoroughDataMap$`Fossil Fuel Investment`, 
                       n=5, 
                       style="jenks")


graphics::plot(breaks, 
               pal=colours)

summary(breaks)
breaks <- as.numeric(breaks$brks)
#create a new sp object from the earlier sf object 
#with all of our data in THEN Transform it to WGS84 
#THEN convert it to SP.  

colnames(BoroughDataMap)[colnames(BoroughDataMap)=="Fossil Fuel Investment"] <- "londonShare"

fullMapSP <- BoroughDataMap %>%
  st_transform(crs = 4326) %>%
  as("Spatial")

#colour palette using colorBin colour mapping
pal <- colorBin(palette = "green", 
                domain = fullMapSP$Fossil.Fuel.Investment,
                #create bins using the breaks object from earlier
                bins = breaks)





