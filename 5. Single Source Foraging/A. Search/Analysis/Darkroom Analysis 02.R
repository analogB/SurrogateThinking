#Mouse click set working directory to source file location

rm(list=ls(all=TRUE))
require(tidyr)
require(dplyr)
require(ggplot2)
require(RColorBrewer)
require(gridExtra)
source('readData.R')
source('parseTrials.R')
source('plotClix.R')

#Import data
rawData     <- readData()
subjectList <- as.factor(unique(rawData$subjectID[!is.na(rawData$subjectID)]))
trialList   <- rawData %>%
  filter(trial_type=='darkroom') %>%
  {as.factor(unique(.$trial_index))}

trialListPlay <-  as.character(seq(1,3))
trialListConc <-  as.character(seq(5,12))
trialListAbst <-  as.character(seq(14,17))

# Make click data tidy with clicklist collapsed (trialData) and expanded (clickData)
clickData<-makeClickData(rawData,subjectList,trialList) 
d<-trialMetrics(clickData)

# Make plots

subjPlotList <- subjectList
trialPlotList <- trialListAbst

filename<-paste("T",min(as.numeric(trialPlotList)),"-T",max(as.numeric(trialPlotList)),".pdf",sep="")
pdf(filename)
for (subj in subjPlotList){
  for (trial in trialPlotList){
    subjectFilter<-d$subjectID %in% subj
    trialFilter<-d$trialID %in% trial
    y<-d[subjectFilter&trialFilter,]
    p<-plotClix(y)
    print(p)
  }
}
dev.off()

ggplot(d, aes(clickID,euclidchange))+
  facet_grid(pane~trialID)+
  geom_path(data=subset(d,!is.na(euclidchange|isSwitch==TRUE) & subjectID=='1'), aes(clickID, euclidchange,alpha=!(as.logical(isSwitch))), size=.2)+
  scale_alpha_discrete(c(1,0.5))
  #geom_point(data=subset(d,isSwitch==TRUE & trialID=='6'), aes(clickID, euclidchange),shape=19)+
  #geom_point(data=subset(d,nextSwitch==TRUE & trialID=='6'), aes(clickID, euclidchange),shape=1)

geom_point(data=subset(d,isTargMap==TRUE), aes(clickID, euclidchange),color="yellow")

