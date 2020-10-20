#Install and load required packages
if (!require(rayshader)) {
  install.packages("rayshader", repos = "http://cran.us.r-project.org")
  require(rayshader)
}
if (!require(ggplot2)) {
  install.packages("ggplot2", repos = "http://cran.us.r-project.org")
  require(ggplot2)
}
if (!require(sf)) {
  install.packages("sf", repos = "http://cran.us.r-project.org")
  require(sf)
}
if (!require(tidyverse)) {
  install.packages("tidyverse", repos = "http://cran.us.r-project.org")
  require(tidyverse)
}

#Read spatial data for UK election geographies
electionGeoAreas <-
  st_read(
    "~/Downloads/Westminster_Parliamentary_Constituencies__December_2017__Boundaries_UK-shp/Westminster_Parliamentary_Constituencies__December_2017__Boundaries_UK.shp"
  )
#set trajectory
BNG = "+init=epsg:27700"
#Convert into SF and transform to trajectory
electionGeoAreasSF <- st_as_sf(electionGeoAreas)
electionGeoAreasSFBNG <- st_transform(electionGeoAreasSF, BNG)

#Read in election results
electionResults <-
  read_csv(
    "~/Desktop/UK2019Election.csv",
    na = c("", "NA", "n/a"),
    locale = locale(encoding = 'Latin1'),
    col_names = TRUE
  )
#Filter data for Labour voting data
labourElectionResults <-
  filter(electionResults, grepl('Labour', electionResults$party_name))
#Filter data for English voting data
labourElectionResultsEngland <-
  filter(labourElectionResults,
         grepl('England', labourElectionResults$country_name))
#Rename column for merging purposes
colnames(labourElectionResultsEngland)[colnames(labourElectionResultsEngland) == "constituency_name"] <-
  "pcon17nm"

#Merge spatial and non spatial data
labourEnglandElectionResultsSpatial <-
  merge(electionGeoAreasSFBNG,
        labourElectionResultsEngland,
        by = c("pcon17nm"))

#Plot using ggplot without rayshader
ggplot() +
  geom_sf(data = labourEnglandElectionResultsSpatial, aes(fill = votes)) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_gradient(low = "white", high = "red")

#Save ggplot to variable name
labourRayshader = ggplot() +
  geom_sf(data = labourEnglandElectionResultsSpatial, aes(fill = votes)) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  scale_fill_gradient(low = "white", high = "red")

#Plot using ggplot with rayshader
plot_gg(
  labourRayshader,
  width = 4,
  zoom = 0.60,
  theta = -45,
  phi = 30,
  windowsize = c(1400, 866)
)
#Render in plots tab
render_snapshot(clear = TRUE)
