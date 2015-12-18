Extent_func <- function(year = year, mydir = mydir, country = country, region = region){

  ## end temp script for bounding box (extent)
  
  if (is.null(country) == TRUE){
    project_extent <- extent(x)
    
    ## Create the clipping polygon
    BB <- as(extent(project_extent@xmin, project_extent@xmax, project_extent@ymin, project_extent@ymax), "SpatialPolygons")
    proj4string(BB) = CRS(as.character(x@crs))
    BB <- spTransform(BB, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
    output <- BB
    
  } else if (is.null(region) == F) {
    CountryShape <- getData('GADM', country = as.character(country), level=1)
    coordsys <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
    spTransform(CountryShape, coordsys)
    output <- subset(CountryShape, CountryShape@data$NAME_1 == region)
    
        
  } else if (is.null(region) == T) {
    CountryShape <- getData('GADM', country = as.character(country), level=1)
    coordsys <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")
    spTransform(CountryShape, coordsys)
    output <- CountryShape
    
  } else {
    print("No valid name")
  }
  return(output)
}
