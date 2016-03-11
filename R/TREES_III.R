TREES_III <- function(from, to,TREES,type, year){
  comb <- NULL
  if (is.na(as.character(TREES@proj4string)) == T){
    my_file <- list.files(myfiles[i], pattern = '.tif', full.names = T)[1]
    my_ras <- raster(my_file)
    crs(TREES) <- my_ras@crs
  }
  
  TREES <- spTransform(x = TREES, CRSobj = from@crs)
  
  if (is.null(intersect(extent(TREES), extent(from))) == T){
    return(comb)
  }
  from_crop <- crop(from, TREES)
  
  if (NA %in% unique(from_crop@data@values) == F){

    TREES <- spTransform(x = TREES, CRSobj = to@crs)
    to_crop <- crop(to, TREES)
    
    from <- projectRaster(from = from_crop, to = to_crop, method = 'ngb')
    to <- to_crop
    
    if (type == 'FC'){
      
      rp <- rasterize(x = TREES, fun = modal, field = as.numeric(as.character(TREES[[sprintf('X%s', year)]])),  y = from)
      rp2 <- rp
      
      # recalculate values for forest cover
      
      rp2[rp == 10] <- 1 # Forest
      rp2[rp != 10] <- 0 # Non-Forest
      
      final_ref <- Forest_def(a = rp2)
      final_Pred <- Forest_def(a = from)
      names(final_ref) <- 'Reference'
      names(final_Pred) <- 'Prediction'
      
      comb <- stack(final_ref, final_Pred)
      return(comb)
      
    } else if ( type == 'FCC'){
      # Copy dataset
      fromt <- from
      # Reassign values for forest cover change
      fromt[from == 1 & to == 1] <- 2 # Forest
      fromt[from == 0 & to == 1] <- 3 # Loss
      fromt[from == 1 & to == 0] <- 4 # Gain
      fromt[from == 0 & to == 0] <- 5 # Non-Forest
      
      # copy dataset
      rp <- rasterize(x = TREES, fun = modal, field = as.numeric(as.character(TREES[[sprintf('X%s', year)]])),  y = from)
      rp2 <- rp
      
      # replace values for reference raster
      rp2[rp2 == 1010] <- 2 # Forest
      rp2[(stri_sub(rp2@data@values,1,2) == 10) & (stri_sub(rp2@data@values,3,4) != 10)] <- 3 # loss
      rp2[(stri_sub(rp2@data@values,3,4) == 10)] <- 4 # Gain
      rp2[rp2 != 2 & rp2 != 3 & rp2 != 4] <- 5 # Non-Forest
      
      final_ref <- Forest_def(a = rp2)
      final_Pred <- Forest_def(a = fromt)
      
      names(final_ref) <- 'Reference'
      names(final_Pred) <- 'Prediction'
      
      comb <- stack(final_ref, final_Pred)
      return(comb)
      
    } else {
      print ('no other type available yet')
    }
  
  } else {
    print ('extents dont overlap, skipping sample')
    return(comb)
  }
}
