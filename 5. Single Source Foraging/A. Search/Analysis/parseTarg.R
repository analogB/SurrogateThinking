parseTarg<-function(.data){
  sT= as.numeric(unlist(strsplit(gsub("\\[|\\]", "", .data$sTarg),',')))
  mT= as.numeric(unlist(strsplit(gsub("\\[|\\]", "", .data$mTarg),',')))
  size<-.data$stimSize
  
  flipY <- function(n){
    out <- as.numeric(nth((size):1,n+1))-1
    return (out)
  }
  
  targ = c(sT[1],flipY(sT[2]),mT[1],flipY(mT[2]))
  return(targ)
}