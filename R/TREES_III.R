# Retrieve Projection system
raster_sat <- raster('data/TREES_III/S12_W053/S13_W053_10_c.tif')
as.character(raster_sat@crs)

# assign projection system to shapefile and load into R environment
proj <- as.character(raster_sat@crs)
sat <- readOGR('data/TREES_III/S12_W044/S12_W044.shp', layer = 'S12_W044')

# load WWF data
WWF2000 <- raster('data/Transformed_Rasters/cerrado_forest_2000.tif')
WWF2010 <- raster('data/Transformed_Rasters/cerrado_2010.tif')


rast <- Hansen(threshold = threshold, year = 2010, output = buff, UTM = T)

sat1 <- spTransform(x = sat, CRSobj = WWF2010@crs)

# plot data for testing
plot(WWF2010)
plot(sat1, add = T, col = 'red')

# reprojecting


WWF_2000_crop <- crop(WWF2000, sat1)
WWF_2010_crop <- crop(WWF2010, sat1)

WWF_2000 <- projectRaster(from = WWF_2000_crop, to = WWF_2010_crop, method = 'ngb')

WWF_2000 <- setMinMax(WWF_2000)
WWF_2010 <- setMinMax(WWF_2010_crop)



#rr <- CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

#WWF_2010r <- reproject(WWF_2000, CRS = rr)
#WWF_2000r <- reproject(WWF_2010, CRS = rr)

# Prepare WWF data for cover change

WWF2010t <- WWF_2010 

WWF2010t[WWF_2010r == 1 & WWF_2000r == 1] <- 2 # Forest
WWF2010t[WWF_2000r == 0 & WWF_2000r == 1] <- 3 # Loss
WWF2010t[WWF_2000r == 1 & WWF_2000r == 0] <- 4 # Gain
WWF2010t[WWF_2000r == 0 & WWF_2000r == 0] <- 5 # Non-Forest

plot(WWF2010t)

################################################# Forest Cover  ####################################################################

## recalculate values for forest cover 

rp <- rasterize(x = sat1, fun = modal, field = as.numeric(as.character(sat1$X2010)),  y = WWF_2010 )
t <- focal(rp, w=matrix(1,3,3), fun=modal)

rp2 <- rp

# recalculate values for forest cover

rp2[rp == 10] <- 1 # Forest
rp2[rp != 10] <- 0 # Non-Forest

## confusion matrix
# Calculate accuracy for polygons
tabletest <- table(rp2@data@values,WWF_2010@data@values, dnn = c('REF','WWF'))
outcome_poly <- confusionMatrix(tabletest)
outcome_poly


################################################# Forest Cover Change ####################################################################

# recalculate values for forest cover change
rp <- rasterize(x = sat1, fun = modal,field = as.numeric(as.character(sat1$CH_00_10)),  y = WWF_2000)

# copy dataset
rp2 <- rp

# replace values for reference raster
rp2[rp == 1010] <- 2 # Forest
rp2[(stri_sub(rp2@data@values,1,2) == 10) & (stri_sub(rp2@data@values,3,4) != 10)] <- 3 # loss
rp2[(stri_sub(rp2@data@values,3,4) == 10)] <- 4 # Gain
rp2[rp2 != c(2,3,4)] <- 5 # Non-Forest

# Select values for WNF dataset
WWF2010t <- WWF_2000 

WWF2010t[WWF_2010 == 1 & WWF_2000 == 1] <- 2 # Forest
WWF2010t[WWF_2010 == 0 & WWF_2000 == 1] <- 3 # Loss
WWF2010t[WWF_2010 == 1 & WWF_2000 == 0] <- 4 # Gain
WWF2010t[WWF_2010 == 0 & WWF_2000 == 0] <- 5 # Non-Forest

# set table classes even
pred <- WWF2010t@data@values
act <- rp2@data@values
u = union(pred, act)
t = table(factor(act, u), factor(pred, u), dnn = c('Pred', 'WNF'))

# create confusion matrix
outcome_poly <- confusionMatrix(t)
outcome_poly

