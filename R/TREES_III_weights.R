TREES_III_weights <- function(TREES, from, to, year){
  
  poly_sub <- NA
  poly_sub1 <- NA
  poly_trans <- spTransform(TREES, CRS = to@crs)
  to_crop <- crop(x = to, poly_trans)
  
  n_list <- as.numeric(as.character(poly_trans$X2010))
  
  if (10 %in% n_list | 12 %in% n_list == T){
    poly_sub <- poly_trans[poly_trans$X2010 == 10 | poly_trans$X2010 == 12,]
    
  }
  
  if (T %in% (13:59 %in% poly_trans$X2010)){
    poly_sub1 <- poly_trans[as.numeric(as.character(poly_trans$X2010)) > 12 & as.numeric(as.character(poly_trans$X2010)) < 51,]
  }
  

  
  if (suppressWarnings(is.na(poly_sub) == T)){
    df_for <- data.frame(poly_sub)
  } else {
    d <- poly_sub
    # create df
    
    ma <- matrix(nrow = length(d), ncol = 2)
    df <- data.frame(ma)
    colnames(df) <- c('Ref','Pred')
    
    for (i in 1:length(d)){
      
      single <- d[i,]
      a <- area(single)/10000
      if (a < 5.5){
        next
      }
      
      
      extract_val <- extract(x = to_crop, y = single, weights = T)
      if (is.null(extract_val[[1]]) == F){
        df2 <- data.frame(extract_val)
        colnames(df2) <- c('value','weight')
        aggr <- aggregate(weight ~ value, data= df2, FUN=sum, na.action = na.pass)
      } else {
        next
      }

      
      # select values
      #Non_Forest <- aggr[which(aggr$value == 0), ][2] # non-forest
      Forest <- aggr[which(aggr$value == 1), ][2] # Forest
      
      
      if (is.na(as.numeric(Forest)) == T){
        w <- NA
      } else if (as.numeric(Forest) < .50){
        w <- 0
      } else {
        w <- 1
      }
      
      # add to dataframe
      df$Ref[i] <- 1
      df$Pred[i] <- w
      
    }
    
  }
  
  ##############################################
  
  if (suppressWarnings(is.na(poly_sub1) == T)){
    df_non <- data.frame(poly_sub1)
  } else {
    # Non_forest
    
    dd <- poly_sub1
    
    # create df non-forest
    ma1 <- matrix(nrow = length(dd), ncol = 2)
    df1 <- data.frame(ma1)
    colnames(df1) <- c('Ref','Pred')
    
    for (i in 1:length(dd)){
      
      single <- dd[i,]
      a <- area(single)/10000
      if (a < 5.5){
        next
      }
      
      extract_val <- extract(x = to_crop, y = single, weights = T)
      if (is.null(extract_val[[1]]) == F){
        df3 <- data.frame(extract_val)
        colnames(df3) <- c('value','weight')
        aggr <- aggregate(weight ~ value, data= df3, FUN=sum, na.action = na.pass)
      } else {
        next
      }

      
      # select values
      #Non_Forest <- aggr[which(aggr$value == 0), ][2] # non-forest
      Forest <- aggr[which(aggr$value == 1), ][2] # Forest
      
      
      if (is.na(as.numeric(Forest)) == T){
        w <- NA
      } else if (as.numeric(Forest) < .50){
        w <- 0
      } else {
        w <- 1
      }
      
      # add to dataframe
      df1$Ref[i] <- 0
      df1$Pred[i] <- w
    }
    
  }
  
  z <- rbind(df, df1)
  zz <- Table_TREES(z)

  return(zz)
}


