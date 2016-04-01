TREES_III <- function(from, to,TREES,type, year, Mosaic, ogr_layer, H){
  comb <- NULL
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
    

    if (type == 'FC'){
      
      if (H == T){
        Hans_TREES <- Hansen(threshold = threshold, year = year, output = TREES , UTM = T)
        TREES_trans <- spTransform(x = TREES, CRSobj = Hans_TREES@crs)
        rp <- rasterize(x = TREES_trans, fun = modal, field = as.numeric(as.character(TREES_trans[[sprintf('X%s', year)]])),  y = Hans_TREES)
        prediction <- Hans_TREES
      } else {
        TREES_from <- spTransform(x = TREES, CRSobj = from@crs)
        from_crop <- crop(from, TREES_from)
        
        from <- projectRaster(from = from_crop, to = to_crop, method = 'ngb')
        to <- to_crop
        
        rp <- rasterize(x = TREES_to, fun = modal, field = as.numeric(as.character(TREES_to[[sprintf('X%s', year)]])),  y = to) # normally y = to, x = TREES_to
        prediction <- to
      }
      
      
      ## test site for borneo
      #my_file <- list.files('data/TREES_III/borneo/', pattern = paste(ogr_layer,'_10_c.tif', sep = ""), full.names = T)
      #if (length(my_file) == 0){
      #  return(comb)
      #}
      rp2 <- rp
      
      # reclassify values for forest cover
      
      if (Mosaic == F){
        rp2[rp2 >= 60 & rp2 <= 100] <- NA # remove Water, clouds, no data and unclassified classes from analysis
        rp2[rp2 == 10] <- 1 # Forest
        rp2[rp2 >= 12 & rp2 <= 50] <- 0 # Non-Forest
      } else {
        rp2[rp2 >= 60 & rp2 <= 100] <- NA # remove Water, clouds, no data and unclassified classes from analysis
        rp2[rp2 == 10 | rp2 == 12] <- 1 # Forest
        rp2[rp2 >= 13 & rp2 <= 50] <- 0 # Non-Forest
      }
      
      #rp2 <- projectRaster(from = rp2, to = to, method = 'ngb')
      
      final_ref <- Forest_def(a = rp2)
      final_Pred <- Forest_def(a = prediction)

      names(final_ref) <- 'Reference'
      names(final_Pred) <- 'Prediction'
      
      comb <- stack(final_ref, final_Pred)
      return(comb)
      
    } else if ( type == 'FCC'){
      
      TREES_from <- spTransform(x = TREES, CRSobj = from@crs)
      from_crop <- crop(from, TREES_from)
      
      from <- projectRaster(from = from_crop, to = to_crop, method = 'ngb')
      to <- to_crop
      
      rp <- rasterize(x = TREES_to, fun = modal, field = as.numeric(as.character(TREES_to[[sprintf('X%s', year)]])),  y = to) # normally y = to, x = TREES_to
      prediction <- to
      
      # Copy dataset
      fromt <- from
      # Reassign values for forest cover change
      fromt[from == 1 & to == 1] <- 2 # Forest
      fromt[from == 0 & to == 1] <- 4 # Loss
      fromt[from == 1 & to == 0] <- 5 # Gain
      fromt[from == 0 & to == 0] <- 3 # Non-Forest
      fromt[fromt == 1 | fromt == 0] <- NA # remove remaining values because of different extents
      
      # copy dataset
      rp <- rasterize(x = TREES_to, fun = modal, field = as.numeric(as.character(TREES_from$CH_00_10)),  y = to)
      rp2 <- rp
      
      # replace values for reference raster
      rp2[rp2 == 1010] <- 2 # Forest
      rp2[(stri_sub(rp2@data@values,1,2) == 10) & (stri_sub(rp2@data@values,3,4) != 10)] <- 4 # loss
      rp2[(stri_sub(rp2@data@values,3,4) == 10)] <- 5 # Gain
      rp2[rp2 != 2 & rp2 != 3 & rp2 != 4] <- 3 # Non-Forest
      
      final_ref <- Forest_def(a = rp2)
      final_Pred <- Forest_def(a = fromt)
      
      names(final_ref) <- 'Reference'
      names(final_Pred) <- 'Prediction'
      
      comb <- stack(final_ref, final_Pred)
      return(comb)
      
    } else {
      print ('no other type available yet')
    }
    
  }

}
