library(raster)
library(rayshader)

#data from https://sedac.ciesin.columbia.edu/data/set/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-rev11/data-download
pop = raster_to_matrix(raster("./Data/gpw-v4-population-density-adjusted-to-2015-unwpp-country-totals-rev11_2020_15_min_tif/gpw_v4_population_density_adjusted_to_2015_unwpp_country_totals_rev11_2020_15_min.tif"))

pal=colorRampPalette(c("skyblue", "white"))

pop %>%
  height_shade(texture=pal(256))%>%
  plot_3d(pop, zscale = 100, solid = FALSE,
          shadowdepth = 0.3, windowsize = c(1800,900), theta = 0,zoom=0.4)

render_highquality(camera_lookat = c(0,-80,0), light=0.8, 
                   filename = "global_population_density.png", rotate_env=180,
                   title_text = "Global Population Density \n Nathanael Sheehan", title_color = "white",
                   ground_material = rayrender::diffuse(color = "lawngreen"))
