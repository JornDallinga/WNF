# Retrieve Projection system
raster_sat <- raster('data/TREES_III/S17_W050/S17_W050_00_c.tif')
as.character(raster_sat@crs)

# assign projection system to shapefile and load into R environment
proj <- as.character(raster_sat@crs)
sat <- readOGR('data/TREES_III/S17_W050/S17_W050.shp', layer = 'S17_W050')

# load WWF data
WWF2000 <- raster('data/Transformed_Rasters/cerrado_forest_2000.tif')
WWF2010 <- raster('data/Transformed_Rasters/cerrado_2010.tif')


# reproject sat to WWF projection
#reproj <- as.character(WWF2000@crs)
#sat1 <- reproject(sat, CRS = reproj)

sat1 <- spTransform(x = sat, CRSobj = WWF2000@crs)

# plot data for testing
plot(WWF2000)
plot(sat1, add = T, col = 'red')

# test area

reproj <- as.character(WWF2000@crs)


WWF_2000_crop <- crop(WWF2000, sat1)
WWF_2010_crop <- crop(WWF2010, sat1)

WWF_2000 <- setMinMax(WWF_2000_crop)
WWF_2010 <- setMinMax(WWF_2010_crop)

rr <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

WWF_2010r <- reproject(WWF_2000, CRS = rr)
WWF_2000r <- reproject(WWF_2010, CRS = rr)

# Prepare WWF data for cover change

WWF2010t <- WWF_2010r 

WWF2010t[WWF_2010r == 1 & WWF_2000r == 1] <- 2 # Forest
WWF2010t[WWF_2000r == 0 & WWF_2000r == 1] <- 3 # Loss
WWF2010t[WWF_2000r == 1 & WWF_2000r == 0] <- 4 # Gain
WWF2010t[WWF_2000r == 0 & WWF_2000r == 0] <- 5 # Non-Forest

plot(WWF2010t)

## prepare landsat selection: raster testing

r <- raster(ncol=56, nrow=54)
extent(r) <- extent(poly)
rp <- rasterize(x = sat1, field = as.numeric(as.character(sat1$CH_00_10)),  y = WWF2000)

rp2 <- rp

# recalculate values
rp2[rp == 1010] <- 2 # Forest
rp2[rp == 1010] <- 3 # Loss
rp2[rp == 1010] <- 4 # Gain
rp2[rp == 1010] <- 5 # Non-Forest

WWF2010t[WWF_2000r == 0 & WWF_2000r == 1] <- 3 # Loss
WWF2010t[WWF_2000r == 1 & WWF_2000r == 0] <- 4 # Gain
WWF2010t[WWF_2000r == 0 & WWF_2000r == 0] <- 5 # Non-Forest

# select values
sel <- subset(rp2@data@values, substr(rp2@data@values, 2, 4) == c('12','10'))

as.matrix(rp2@data@values)
