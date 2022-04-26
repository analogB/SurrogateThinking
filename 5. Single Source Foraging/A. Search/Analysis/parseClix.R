parseClix<-function(.data){
  require('jsonlite')
  require('tidyr')
  
  size<-.data$stimSize
  
  list<-jsonlite::fromJSON(jsonlite::prettify(.data$clicks))
  list<-gsub("sell_map","clickable-R999-X999-Y999",list)
  
  flipY <- function(n){
    out <- as.numeric(nth((size):1,n+1))-1
    return (out)
  }
  
  df<-as.data.frame(gsub("clickable-","",list))
  df<-separate(df, col = 1, into = c("pane","X","Y"), sep = "-")
  df<-mutate(df,pane=substr(pane,2,100))
  df<-mutate(df,X=substr(X,2,100))
  df<-mutate(df,Y=substr(Y,2,100))
  df$clickID <- as.numeric(rownames(df))
  df$pane <- as.numeric(df$pane)
  df$X<-as.numeric(df$X)
  df$Y<-as.numeric(df$Y)
  
  df$Y <- map_dbl(df$Y,flipY)
  
  parsed_stim<-.data %>% parseMapList()
  df<-df %>% left_join(parsed_stim, by=c("pane","X","Y"))
  df$path <- paste("m",df$dir,"/map",df$img,".png", sep="")

  return(df)
}