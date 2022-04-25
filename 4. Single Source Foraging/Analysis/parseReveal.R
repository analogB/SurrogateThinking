parseReveal<-function(.data){
  require('jsonlite')
  require('tidyr')
  source('parseMapList.R')
  
  size<-.data$stimSize
  revsize<-.data$revealSize
  orig <- gsub("\\[|\\]", "", .data$revealLoc)
  origin<- as.numeric(unlist(strsplit(orig,",")))
  df<-data.frame(matrix(ncol=3,nrow=revsize^2))
  colnames(df)<- c("pane","X","Y")
  
  for (i in seq(revsize)){
    for (j in seq(revsize)){
      df$pane[(i-1)*revsize+j] = 0
      df$X[(i-1)*revsize+j]=origin[1]+i-1
      df$Y[(i-1)*revsize+j]=origin[2]+j-1
    }
  }
  
  flipY <- function(n){
    out <- as.numeric(nth((size):1,n+1))-1
    return (out)
  }
  
  df$Y <- map_dbl(df$Y,flipY)
  
  parsed_stim<-.data %>% parseMapList()
  df<-df %>% left_join(parsed_stim, by=c("pane","X","Y"))
  df$path <- paste("m",df$dir,"/map",df$img,".png", sep="")
  
  return(df)
}