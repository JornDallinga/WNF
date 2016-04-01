combine_tab <- function(tab, tab1){
  tg <- data.frame(tab)
  tb <- data.frame(tab1)
  rt <- rbind(tg, tb)
  rr <- xtabs(Freq ~ Pred + Ref, rt)
  return (rr)
}
