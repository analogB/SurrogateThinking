##functions use to tidy trial data and build trial metrics

makeClickData<-function(df,sList,tList){
  
  paneW=8
  testThreshold=4
  trialData    <-  tibble(subjectID = character(), trialID = character(), clix = character(),isTest = character(), targX = numeric(), targY = numeric(), targXmap=numeric(), targYmap=numeric(), match=logical())
  out          <-  tibble(subjectID = character(), trialID = character(), isTest = character(), pane = numeric(), X = numeric(), Y = numeric() )
  
  #construct clickdata by trial
  for (subj in sList){
    for (trial in tList){
      click     <-  as.character(filter(df, subjectID==subj, trial_index==trial) %>% select(clicks))
      matc      <-  as.numeric(filter(df, subjectID==subj, trial_index==trial) %>% select(match))
      trialRow  <-  tibble(subjectID=subj, trialID=trial, clix=click, isTest=(as.numeric(trial)>testThreshold), match=matc)
      sTarg     <-  filter(df, subjectID==subj, trial_index==trial) %>% select(sTarg)
      mTarg     <-  filter(df, subjectID==subj, trial_index==trial) %>% select(mTarg)
      targets   <-  cbind(parseTarg(sTarg,FALSE,paneW),parseTarg(mTarg,TRUE,paneW))
      trialRow  <-  cbind(trialRow,targets)
      trialData <-  rbind(trialData,trialRow)
      newClicks <-  parseClix(click)
      newClicks <-  cbind(trialRow,newClicks)
      out       <-  rbind(out,newClicks)
    }
  }
  return(out)
}

parseClix<-function(string){
  require('jsonlite')
  require('tidyr')
  
  y<-jsonlite::prettify(string)
  y<-jsonlite::fromJSON(y)
  
  y<-as.data.frame(gsub("clickable-","",y))
  y<-separate(y, col = 1, into = c("pane","X","Y"), sep = "-")
  
  y<-mutate(y, pane = as.numeric(substr(pane,2,100)))
  y<-mutate(y, X    = as.numeric(substr(X,2,100)))
  y<-mutate(y, Y    = as.numeric(substr(Y,2,100)))
  
  return(y)
}

parseTarg<-function(targ,ismap,paneWidth){
  if (ismap){
    xlabel<-paste("targX","map", sep="")
    ylabel<-paste("targY","map", sep="")
  } else {
    xlabel<-"targX"
    ylabel<-"targY"
  }
  targ<-as.character(targ)
  targ<-as.data.frame(gsub("\\[|\\]","",targ))
  targ<-separate(targ, col = 1, into = c(xlabel,ylabel), sep = ",")
  targ[,1]<-as.numeric(targ[,1])
  if (ismap){
    targ[,1]<-targ[,1]+paneWidth+1
  }
  targ[,2]<-as.numeric(targ[,2])
  return(targ)
}

trialMetrics<-function(df){
  
  require('tidyr')
  
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(isSwitch   = (lag(pane, n=1)!=pane))
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(nextSwitch = (lead(isSwitch, n=1)==TRUE))
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(Xchange    = abs(X-lag(X, n=1)))
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(Ychange    = abs(Y-lag(Y, n=1)))

  df<-mutate(df,totchange    = Xchange+Ychange)
  df<-mutate(df,euclidchange = sqrt(Xchange^2+Ychange^2))
  df<-mutate(df,Xpane        = X + pane*9)
  
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(clickID    = 1:n())
  df<-group_by(df,.dots=c("subjectID","trialID")) %>% mutate(clickTotal = max(clickID))
  
  return(df)
}