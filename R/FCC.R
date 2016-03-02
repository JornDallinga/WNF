list.files('data/')

WWF2005 <- raster('data/borneo_2005_forest.tif')
WWF2010 <- raster('data/borneo_2010_forest.tif')

WWF2005 <- setMinMax(WWF2005)
WWF2010 <- setMinMax(WWF2010)

WWF2010t <- WWF2010


WWF2010t[WWF2010 == 1 & WWF2005 == 1] <- 2 # Forest
WWF2010t[WWF2010 == 0 & WWF2005 == 1] <- 3 # Loss
WWF2010t[WWF2010 == 1 & WWF2005 == 0] <- 4 # Gain
WWF2010t[WWF2010 == 0 & WWF2005 == 0] <- 5 # Non-Forest



writeRaster(WWF2010t, filename = 'data/output/FFC2005_2010.tif', overwrite = T)

plot(WWF2000_2005)
