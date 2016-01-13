x <- raster('data/mekong_2013_forest.tif')

output_transformed <- spTransform(output, CRSobj = x@crs)
output_crop <- crop(x, output_transformed)
output_crop1 <- mask(output_crop, output_transformed, progress = 'text')

reproject <- projectRaster(from = output_crop1 , crs = as.character(output@proj4string), method = 'ngb', progress = 'text')





writeRaster(reproject, filename = 'data/vietnam/vietnam2010.tif', overwrite = F)

V2000 <- raster('data/vietnam/vietnam2000.tif')
V2005 <- raster('data/vietnam/vietnam2005.tif')
V2010 <- raster('data/vietnam/vietnam2010.tif')

test <- extend(V2000, V2005, progress = 'text')

V2000 <- test

test <- resample(V2000, V2005, method = 'ngb', progress = 'text')

def2005_2010 <- V2005 - V2010
a <- area(def2005_2010)
b <- zonal(a, def2005_2010, fun = 'sum')
b[2,2] * 100
