# test loop
Poly_looping <- function(mydata, ras, buff){
  
  # extract raster values
  extract_val <- extract(x = ras, y = buff, weights = T)
  df <- data.frame(extract_val)
  aggr <- aggregate(weight ~ value, data= df, FUN=sum, na.action = na.pass)
  
  # select values
  w <- aggr[which(aggr$value == 0), ][2]
  w1 <- aggr[which(aggr$value == 1), ][2]

  
  return(c(w,w1))

}

