makeClickData<-function(dat){

  for (subj in subjectList){
    for (trial in trialList){
      click<-as.character(filter(dat, subjectID==subj, trial_index==trial) %>% select(clicks))
      matc<-as.logical(filter(dat, subjectID==subj, trial_index==trial) %>% select(match))
      trialRow<-tibble(subjecstID=subj, trialID=trial, clix=click, isTest=(as.numeric(trial)>testThreshold), match=matc)
      sTarg<-filter(dat, subjectID==subj, trial_index==trial) %>% select(sTarg)
      mTarg<-filter(dat, subjectID==subj, trial_index==trial) %>% select(mTarg)
      targets<-cbind(parseTarg(sTarg,FALSE,paneW),parseTarg(mTarg,TRUE,paneW))
      trialRow<-cbind(trialRow,targets)
      trialData<-rbind(trialData,trialRow)
      newClicks<-parseClix(click)
      newClicks<-cbind(trialRow,newClicks)
      clickDat <- rbind(clickData,newClicks)
    }
  }
  
  return(clickDat)
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