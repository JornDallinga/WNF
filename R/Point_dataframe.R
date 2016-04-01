Point_dataframe <- function(tab, comb, count){
  # test for accuracy of location
  if (nrow(tab) == 1 & ncol(tab == 1)){
    
  } else {
    
    conf <- confusionMatrix(tab)
    conf_table <- as.data.frame.matrix(conf$table)
    #t <- conf_table[2,2] / (conf_table[2,2] + conf_table[2,1]) # PA for forest
    t <- as.numeric(conf$overall[1]) # Overall accuracy selection
    pred <- subset(comb, 'Prediction')
    x <- (pred@extent@xmin + pred@extent@xmax) / 2
    y <- (pred@extent@ymin + pred@extent@ymax) / 2
    Spat <- SpatialPoints(data.frame(x = x, y = y), proj4string = pred@crs)
    spTransform
    Spat$Variable <- t

  }
  
  return(Spat)
}