# list all files in folder
list_file <- list.files(sprintf('%s/',mydir), full.names=T)
x <- raster(list_file[1])
x <- setMinMax(x)

project_extent <- extent(test)
## Create the clipping polygon
BB <- as(extent(project_extent@xmin, project_extent@xmax, project_extent@ymin, project_extent@ymax), "SpatialPolygons")
proj4string(BB) = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")



test1 <- SpatialPolygons(list(project_extent))
##
test <- projectRaster(from = x, crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", method = 'ngb', filename = 'data/Borneo_WGS84')
test2 <- SpatialPolygons(Polygon(project_extent, proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")))

Raster <- rast.list[[t]]
plot_Raster <- spTransform(buffer, CRS(proj4string(Raster))) 
plot_crop <- crop(Raster, plot_Raster)
reproject <- projectRaster(from = plot_crop, crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", method = 'ngb')
new_list[t] <- reproject

spTransform

test <- rasterToPolygons(x = x, na.rm = T, dissolve = Y)
r <- x

m <- clump(r)
f <- freq(m)
f[,2] <- f[,2] * xres(r) * yres(r)

rasterOptions(format, overwrite, datatype, tmpdir, tmptime, progress, 
              timer, chunksize, maxmemory, todisk, setfileext, tolerance, 
              standardnames, depracatedwarnings, addheader, default=FALSE) 


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
