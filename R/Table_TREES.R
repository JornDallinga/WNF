Table_TREES <- function(df){
  # set table classes even
  pred <- df$Pred
  ref <- df$Ref
  u = union(df$Pred, df$Ref)
  t = table(factor(pred, u), factor(ref, u), dnn = c('Pred', 'Ref'))
  return (t)
}
