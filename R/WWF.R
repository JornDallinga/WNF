WWF <- function(x = x, output = output){
  
  output_transformed <- spTransform(output, CRSobj = x2@crs)
  outputtest <- projectRaster(from = x2, crs = as.character(output@proj4string), method = 'ngb', progress = 'text')
  proj4string(x2) <- CRS('+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0')
  
  output_crop <- crop(x, output_transformed)
  output_crop1 <- mask(output_crop, output_transformed)
  reproject <- projectRaster(from = output_crop1 , crs = as.character(output@proj4string), method = 'ngb', progress = 'text')
  
  return(reproject)
}

## temp script for bounding box (extent)
#output <- drawExtent(show=TRUE, col="red")
#BB <- spTransform(output, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0"))


output <- gUnaryUnion(output, id = output@data$NAME_0)
output_crop1 <- mask(outputtest, output)
