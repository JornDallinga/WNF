# criteria for accuracy assessment
accuracy <- function(output, threshold){
  mypol <- as.data.frame(output)
  
  ## accuracy assessment
  
  # clear of NA's in both coloms
  mypol <- mypol[!with(mypol,is.na(forest)& is.na(non_forest)),]
  
  # set threshold for accuracy assessment
  mypol$WWF[(mypol$forest >= (threshold/100))] <- 1
  mypol$WWF[(mypol$forest < (threshold/100)) | is.na(mypol$forest)] <- 0
  
  # Calculate accuracy for polygons
  tabletest <- table(mypol$Ref,mypol$WWF, dnn = c('REF','WWF'))
  outcome_poly <- confusionMatrix(tabletest)
  return(outcome_poly)
}

