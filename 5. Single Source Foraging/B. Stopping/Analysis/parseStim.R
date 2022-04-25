parseMapList<-function(x){
  require('jsonlite')
  require('tidyr')
  y<-jsonlite::prettify(x)
  y<-jsonlite::fromJSON(y)
  y<-gsub("sell_map","clickable-R999-X999-Y999",y)
  y<-as.data.frame(gsub("clickable-","",y))
  y<-separate(y, col = 1, into = c("pane","X","Y"), sep = "-")
  y<-mutate(y,pane=substr(pane,2,100))
  y<-mutate(y,X=substr(X,2,100))
  y<-mutate(y,Y=substr(Y,2,100))
  y$clickID <- as.numeric(rownames(y))
  y$pane <- as.numeric(y$pane)
  y$X<-as.numeric(y$X)
  y$Y<-as.numeric(y$Y)
  
  return(y)
}