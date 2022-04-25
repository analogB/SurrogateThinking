parseMapList<-function(.data){
  require('jsonlite')
  require('tidyr')
  
  list<-jsonlite::fromJSON(jsonlite::prettify(.data$mapList))
  size<-.data$stimSize
  
  flipY <- function(n){
    out <- as.numeric(nth((size):1,n+1))-1
    return (out)
  }
  
  df<-as.data.frame(gsub("map","",gsub("img/map/m","",gsub(".png","",list))))
  df<-separate(df, col = 1, into = c("dir","img"), sep = "/")
  df$dir<-as.numeric(df$dir)
  df$img<-as.numeric(df$img)  
  df$listID <- as.numeric(rownames(df))
  df$pane <- round(df$listID / size^2 / 2)
  df$Y <- map_dbl((df$listID-1) %% size, flipY)
  df$X <- (((df$listID -1) %/% size +1)-1) %% size 

  return(df)
}