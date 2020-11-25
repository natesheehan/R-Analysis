library(sf)
library(pct)
library(stplanr)
library(leaflet)

devon_centroids = get_pct_centroids(region = "devon")
devon_zones = get_pct_zones(region = "devon")

plot(devon_centroids[, "bicycle"])
plot(devon_zones[, "bicycle"])

devon_lines_pct = get_pct_lines(region = "devon")

line_order = order(devon_lines_pct$bicycle, decreasing = TRUE)
devon_lines_30 = devon_lines_pct[line_order[1:30], ]

lwd = devon_lines_30$all / mean(devon_lines_30$all) * 5
plot(devon_lines_30[c("bicycle", "car_driver", "foot")], lwd = lwd)

devon_od_all = get_od(region = "devon")
summary(devon_od_all$geo_code1 %in% devon_centroids$geo_code)
summary(devon_od_all$geo_code2 %in% devon_centroids$geo_code)

devon_od = devon_od_all[
  devon_od_all$geo_code2 %in% devon_centroids$geo_code,]

