Confusion_Matrix <- function(WNF, Hansen){
  
  WNF <- resample(WNF, Hansen, method = 'ngb')
  
  WNF <- as.matrix(WNF)
  Hansen <- as.matrix(Hansen)
  
  Reference <- matrix(WNF)
  Predicted <- matrix(Hansen)
  
  Reference[Reference == 0] <- "Non.Forest"
  Reference[Reference == 1] <- "Forest"
  
  Reference[Reference == 3] <- "Water"
  Reference[Reference == 4] <- "Clouds/Shadow/No_data"
  
  Predicted[Predicted == 0] <- "Non.Forest"
  Predicted[Predicted == 1] <- "Forest"
  
  Predicted[Predicted == 3] <- "Water"
  Predicted[Predicted == 4] <- "Clouds/Shadow/No_data"
  
  WNF <- Reference
  Hansen <- Predicted
  
  tabletest <- table(WNF,Hansen)
  prop.table(tabletest)
  
  if ((nrow(tabletest) == ncol(tabletest)) & (nrow(tabletest) != 1) & (all(names(tabletest[,1]) %in% names(tabletest[1,])))) {
    outcome <- confusionMatrix(tabletest)
    
    Confusion_table <- as.data.frame.matrix(outcome$table)
    Confusion_overall <- as.matrix(outcome$overall)
    
    #dir.create(file.path('output/Excel/Confusion_Matrix'), showWarnings = FALSE)
    #dir.create(file.path(sprintf('output/Excel/Confusion_Matrix/Buffer_%s', BufferDistance)), showWarnings = FALSE)
    #dir.create(file.path(sprintf('output/Excel/Confusion_Matrix/Buffer_%s/Threshold_%s', BufferDistance, Threshold)), showWarnings = FALSE)
    #write.xlsx(Confusion_table, file = sprintf("output/Excel/Confusion_Matrix/Buffer_%s/Threshold_%s/Con_%s_Buffer%s_Threshold%s.xlsx", BufferDistance, Threshold, Chronosequence, BufferDistance, Threshold), sheetName = "Confusion_Matrix")
    #write.xlsx(Confusion_overall, file = sprintf("output/Excel/Confusion_Matrix/Buffer_%s/Threshold_%s/Con_%s_Buffer%s_Threshold%s.xlsx", BufferDistance, Threshold, Chronosequence, BufferDistance, Threshold), sheetName = "Confusion_Overall", append = T)
    
  } else {
    
  }
  
}