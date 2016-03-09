list.files('data/')

WWF2000 <- raster('data/cerrado_forest_2000.tif')
WWF2010 <- raster('data/cerrado_af_2010_forest.tif')

WWF2000 <- setMinMax(WWF2000)
WWF2010 <- setMinMax(WWF2010)

WWF2010t <- WWF2010


WWF2010t[WWF2010 == 1 & WWF2000 == 1] <- 2 # Forest
WWF2010t[WWF2010 == 0 & WWF2000 == 1] <- 3 # Loss
WWF2010t[WWF2010 == 1 & WWF2000 == 0] <- 4 # Gain
WWF2010t[WWF2010 == 0 & WWF2000 == 0] <- 5 # Non-Forest



writeRaster(WWF2010t, filename = 'data/output/FFC2000_2010_cerrado.tif', overwrite = T)

plot(WWF2000_2005)


# write to raster for masking
writeRaster(WWF2000, filename = 'data/output/FFC2000_mask_cerrado.tif', overwrite = T)
writeRaster(WWF2010, filename = 'data/output/FFC2010_mask_cerrado.tif', overwrite = T)

