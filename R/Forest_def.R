Forest_def <- function(a){
  # calc zonal statistics
  
  clumps <- clump(a, directions = 4)
  # calculate pixel frequency for each clumpID
  clumpFreq <- as.data.frame(freq(clumps))
  clumpFreq[,2] <- clumpFreq[,2] * prod(res(clumps)) 
  
  # clumpID to be excluded from output raster
  excludeID <- clumpFreq$value[which(clumpFreq$count < 5000)]
  
  # function to exclude 
  subNA <- function(a, b){
    a[b %in% excludeID] <- 0
    return(a)
  }
  
  final <- subNA(a = a, b = clumps)
  
  return(final)
}

