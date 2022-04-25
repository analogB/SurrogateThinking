parseReveal<-function(.data){
  
  source('readData.R')
  source('parseMapList.R')
  source('parseClix.R')
  source('parseReveal.R')
  source('parseTarg.R')
  
  stimsize <- .data$stimSize
  clx<-       .data %>% parseClix()
  revsize<-   .data$revealSize
  reveal<-    .data %>% parseReveal()
  targ<-      .data %>% parseTarg()
  sid<-       .data$subjectID
  tri<-       .data$trial_index
  match<-     .data$match
  
  
  
  
  
  
  
}