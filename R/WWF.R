WWF <- function(x = x, output = output){
  
  output_transformed <- spTransform(output, CRS = as.character(x@crs))
  output_crop <- crop(x, output_transformed)
  reproject <- projectRaster(from = output_crop , crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0", method = 'ngb')
  
  return(reproject)
}

## temp script for bounding box (extent)
#output <- drawExtent(show=TRUE, col="red")
#BB <- spTransform(output, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))

