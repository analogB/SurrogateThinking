#Mouse click set working directory to source file location

rm(list=ls(all=TRUE))
require('tidyverse')
require('dplyr')
require('ggplot2')
require('ggimage')

source('readData.R')
source('parseMapList.R')
source('parseClix.R')
source('parseReveal.R')
source('parseTarg.R')
source('plotClix.R')
source('plotClixAnimate.R')

data<- readData()
data$stimSize<-7

stim_def <- data %>% select(seedArray,sTarg,mTarg,mapList,revealLoc,revealSize,exploreDelay,stimSize) %>% {distinct(.)}


subject_list <- as.numeric(unique(data$subjectID[!is.na(data$subjectID)]))
trial_list   <- data %>% filter(trial_type=='darkroom') %>% {as.numeric(unique(.$trial_index))-1}

subj=subject_list[5]
trial=trial_list[9]

trial_plot<-data %>% filter(subjectID==subj,trial_index==trial) %>% plotClix()
trial_plot<-data %>% filter(subjectID==subj,trial_index==trial) %>% plotClixAnimate()

clicks<-data %>% filter(subjectID==subj,trial_index==trial) %>% parseClix()
reveal<-data %>% filter(subjectID==subj,trial_index==trial) %>% parseReveal()


responses <- tribble(~sid, ~stim, ~trial_index,~rt,~pane,~X,~Y, ~dir,~img)
for (subj in subject_list){
  for (trial in trial_list){
    rt=data%>%filter(subjectID==subj,trial_index==trial)%>%select(rt)
    trial_clicks=data %>% filter(subjectID==subj,trial_index==trial) %>% parseClix() %>% add_column(sid=subj,stim=stimID,trial_index = trial,rt=rt,.before = 'pane')
    responses <- responses %>% bind_rows(trial_clicks)
  }
}


acf(clicks$X,lag=10,correlation = TRUE, pl=TRUE)
acf(clicks$Y,lag=10,correlation = TRUE, pl=TRUE)
acf(clicks$pane,lag=10,correlation =TRUE, pl=TRUE)

clicks<- clicks %>% mutate(check_reveal=pane==1 & X%in%reveal$X & Y%in%reveal$Y)

clicks$clickID <- as.integer(clicks$clickID)
clicks <- clicks %>% mutate(check_prev=duplicated(paste(X,Y),fromLast=FALSE))
clicks <- clicks %>% mutate(check = check_reveal|check_prev)
clicks <- clicks %>% mutate(switch=pane!=lag(pane,1))

#blockList <- as.factor(c(8,10,12,14,16))

# plots <- list()
# plots[[i]]<-parseClix(click)
# print(parseClix(click))


# data %>% group_by(subjectID, trial_index) %>% 
#   mutate(pareseClix)