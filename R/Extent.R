# list all files in folder
list_file <- list.files(sprintf('%s/',mydir), full.names=T)
x <- raster(list_file[1])
test <- setMinMax(x)

project_extent <- extent(x)

test <-readGDAL(list_file[1])










#######################################testing#########################################
writeRaster(test, 'data/new_raster')
# reclassify the values into three groups 
# all values >= 0 and <= 0.25 become 1, etc.
m <- c(1, 280, 800)
rclmat <- matrix(m, ncol=3, byrow=TRUE)
rc <- reclassify(x, rclmat)

test1 <- setValues(x = test, 1)

writeRaster(x, 'data/test')


plot(x)
test[test == 0] <- 1
x[x == 1] <- 0

rasterToPolygons(x = x, fun = function(x) {x >= 1 & x < 300})

testing <- as.data.frame(x)
