# list all files in folder
list_file <- list.files(sprintf('%s/',mydir), full.names=T)
x <- raster(list_file[1])
x <- setMinMax(x)

if (is.null(country) == TRUE){
  project_extent <- extent(x)
  ## Create the clipping polygon
  BB <- as(extent(project_extent@xmin, project_extent@xmax, project_extent@ymin, project_extent@ymax), "SpatialPolygons")
  proj4string(BB) = CRS(as.character(x@crs))
  BB <- spTransform(BB, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
  output <- BB
} else if (is.null(country) == F) {
  CountryShape <- getData('GADM', country = as.character(country), level=1)
  coordsys <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
  spTransform(CountryShape, coordsys)
  output <- CountryShape
}



Raster <- rast.list[[t]]
plot_Raster <- spTransform(buffer, CRS(proj4string(Raster))) 
plot_crop <- crop(Raster, plot_Raster)
reproject <- projectRaster(from = plot_crop, crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", method = 'ngb')
new_list[t] <- reproject