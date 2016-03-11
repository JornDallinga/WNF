
Conf_t <- function(pred, ref){
  # set table classes even
  pred <- pred@data@values
  ref <- ref@data@values
  u = union(pred, ref)
  t = table(factor(ref, u), factor(pred, u), dnn = c('Pred', 'Ref'))
  return (t)
}
