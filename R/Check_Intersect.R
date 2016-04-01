Check_Intersect <- function(TREES, to){
  comb <- F
  if (is.na(as.character(TREES@proj4string)) == T){
    #my_file <- list.files(myfiles[i], pattern = '.tif', full.names = T)[1]
    #my_ras <- raster(my_file)
    #crs(TREES) <- my_ras@crs
    return(comb)
  }
  
  TREES_to <- spTransform(x = TREES, CRSobj = to@crs)
  
  if (is.null(intersect(extent(TREES_to), extent(to))) == T){
    return(comb)
  }
  
  to_crop <- crop(to, TREES_to)
  
  if (length(unique(to_crop@data@values)) == 1 & is.na(unique(to_crop@data@values)[1] == T)){
    return(comb)
  } else {
    comb <- T
    return(comb)

  }
}