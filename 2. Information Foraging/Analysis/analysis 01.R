rm(list=ls(all=TRUE))
require('jsonlite')
require('plyr')
require('readr')
require(tidyr)
require(dplyr)
require(R6)
require(ggplot2)
require(scales)
require(jsonlite)
require(plyr)
require(readr)
source('p-selection.R')

dir=getwd()
dirData=paste(dir,'/data raw',sep='')
setwd(dir)

OGP<-"Observed Gold Proportion"

#txtStims <- read_file("textStims Oct 2016.txt")
#stims=fromJSON(txtStims, simplifyVector = TRUE, flatten = FALSE)

### READ DATA ###
setwd(dirData)
fileList <- list.files()
for (file in fileList){
  # append data from all other files
  if (exists("rawData")){
    temp_dataset <-read.csv(file, header=TRUE, sep=",")
    rawData<-rbind(rawData, temp_dataset)
    rm(temp_dataset)}
  # create from first data file
  if (!exists("rawData")){
    rawData <- read.csv(file, header=TRUE, sep=",")}
}

setwd(dir)

### SPECIFY DATA FRAME ###
rawData$rt                    <- as.numeric   (rawData$rt)
rawData$key_press             <- as.factor    (rawData$key_press)
rawData$trial_type            <- as.factor    (rawData$trial_type)
rawData$trial_index           <- as.factor    (rawData$trial_index)
rawData$time_elapsed          <- as.numeric   (rawData$time_elapsed)
rawData$internal_node_id      <- as.character (rawData$internal_node_id)
rawData$turkID                <- as.factor    (rawData$turkID)
rawData$ExpEndTime            <- as.factor    (rawData$ExpEndTime)
rawData$button_pressed        <- as.factor    (rawData$button_pressed)
rawData$trials_remaining      <- as.numeric   (rawData$trials_remaining)
rawData$resource_choice       <- as.factor    (rawData$resource_choice)
rawData$resource_choice_value <- as.numeric   (rawData$resource_choice_value)
rawData$best_resource         <- as.factor    (rawData$best_resource)
rawData$total_earnings        <- as.numeric   (rawData$total_earnings)

rawData$subjectID <- as.numeric(as.factor(rawData$turkID))

rawData[,'blockID']<-substr(rawData[,'internal_node_id'],5,nchar(rawData[,'internal_node_id']))
rawData$blockID <- gsub("\\-.*","",rawData$blockID)
rawData$blockID<-substr(rawData$blockID,1,nchar(rawData$blockID)-2)

subjectIDList <- unique(rawData$subjectID[!is.na(rawData$subjectID)])
blockList <- as.factor(c(8,10,12,14,16))

nper <- 51

data<-rawData[(rawData$trial_type=='forage01')&(!is.na(rawData$subjectID)),]

for (subject in subjectIDList){
  for (block in blockList){
    goldCount <- 0
    dirtCount <- 0
    goldRatio <- NA
    explores  <- 0
    exploreCount<-0
    for (trial in nper:1){
      filter1 <- (data$subjectID %in% subject)&(data$blockID %in% block)&(data$trials_remaining %in% trial)
      choice <- data$button_pressed[filter1]
      best   <- data$best_resource[filter1]
      resource <- data$resource_choice[filter1]
      if (trial < nper){
        goldRatio = goldCount / (dirtCount + goldCount)
        exploreCount <- explores
      }
      if (choice == '0'){
          explores <- explores + 1
        if(resource == 'dirt'){
          dirtCount <- dirtCount + 1
        } else if (resource == 'gold' | resource == 'diamond'){
          goldCount <- goldCount + 1
        }
      }
      data$goldRatio[filter1]<-goldRatio
      data$explores[filter1] <- exploreCount
    }  
  }
}

for (subject in subjectIDList){
  for (block in blockList){
    for (trial in nper:1){
      finalbest<- as.character(data$best_resource[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==1)])
      data$finalBest[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==trial)] <- finalbest
      finalratio<- data$goldRatio[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==1)]
      data$finalRatio[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==trial)] <- finalratio   
      #finalearnings<- data$total_earnings[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==1)]
      #data$finalEarnings[(data$subjectID==subject)&(data$blockID==block)&(data$trials_remaining==trial)] <- finalearnings   
      }
  }
}
data$finalBest<-as.factor(data$finalBest)
data<-data[data$finalBest!='dirt',]

data$trial<-nper+1-data$trials_remaining
maxExpl<-setNames(aggregate(data$explores, list(data$subjectID,data$blockID), max),c('subjectID','blockID','maxExplores'))
data<-merge(data,maxExpl, by=c('subjectID','blockID'))

#### FILTERS ####
exploreFilter  <-   (data$button_pressed == '0')
exploitFilter  <-   (data$button_pressed == '1')
lastFilter     <-   (data$trial==nper)
bingoFilter    <-   (data$explores==(data$maxExplores-1))&exploreFilter&(data$maxExplores!=(nper-1))
bustFilter<-        (data$maxExplores==nper-1)&(data$explores==nper-1)&lastFilter
#jackpotFilter  <-   (data$trial==(data$trial[bingoFilter]+1))&(data$blockID==data$blockID[bingoFilter])
goldFilter     <-   (data$finalBest == 'gold')
diamondFilter  <-   (data$finalBest == 'diamond') #& (data$maxExplores!=nper)
alldirtFilter  <-   (data$goldRatio!=0)
subjectSelect  <-   as.character(seq(1,max(data$subjectID)))
subjectFilter  <-   (data$subjectID %in% subjectSelect)&(data$subjectID!=72)
data$jackpot<-FALSE

for (subject in subjectSelect){
  for (block in blockList){
    blockFilter<-(data$blockID==block)&(data$subjectID==subject)
    for (i in 1:nper-1){
      fil<-(blockFilter)&(data$trial==i)
      if ((sum(bingoFilter&blockFilter)>0)&(sum(fil)>0)){
        if (data$trial[fil]==(data$trial[bingoFilter&blockFilter]+1)){ 
          data$jackpot[fil]<-TRUE
        }
      }
    }
  }
}
jackpotFilter<-(data$jackpot==TRUE)

possRatios<-array(dim=c(0,2))
possSuccesses<-array(dim=c(0,2))
possLineA<-array(dim=c(0,2))
possLineB<-array(dim=c(0,2))
colnames(possRatios)<- c('explores','ratio')
colnames(possSuccesses)<- c('explores','successes')
colnames(possLineA)<- c('explores','ratio')
colnames(possLineB)<- c('explores','ratio')

for (i in 1:nper){
  for (j in 0:i){
    possRatios = rbind(possRatios,c(i,j/i))
    if (i<nper){
      for (k in 0:1){
        possLineA = rbind(possLineA,c(i,j/i))
        possLineB = rbind(possLineB,c((i+1),((j+k)/(i+1))))
      }
    }
  }
}

p1=0.2
p2=0.35
m=0.5
psel<- function(a,b,p1,p2){
  d1<-dbeta(p1,a+1,b+1)
  d2<-dbeta(p2,a+1,b+1)
  out<-d1/(d1+d2)
  return(1-out)
}

possRatios<-as.data.frame(possRatios)

#Probability of either mine
for (i in 1:length(possRatios[,1])){
  a=possRatios$explores[i]*possRatios$ratio[i]
  b=possRatios$explores[i]*(1-possRatios$ratio)[i]
  #possRatios$p[i] <- pselect(a,b,p1,p2,m)
  possRatios$p[i] <- psel(a,b,p1,p2)
}

#Probability of survival
possRatios$survival<-NA
possRatios$hazard<-NA
min4surv<-1
for (i in 1:length(possRatios[,1])){ 
  filterS<-   ((exploreFilter)|(jackpotFilter)) & 
              (data$explores==possRatios$explores[i]) &
              (data$goldRatio==possRatios$ratio[i]) &
              (goldFilter)
  if (sum(filterS)<min4surv){
    possRatios$counts[i]<-0
    possRatios$survival[i]<-NA
    possRatios$hazard[i]<-NA
  }else{
    possRatios$counts[i] <-sum(filterS)
    possRatios$hazard[i] <-sum(filterS & jackpotFilter)/sum(filterS)
    possRatios$survival[i]<-1-possRatios$hazard[i]
  }
}

            ####Optimal####
            df <- 1
            nActions <- 2
            nStates <- 4
            state <- seq(1:nStates) #list of ranks
            
            reward <- array(0,dim=c(nActions,nStates))
            reward[2,] <- c(0,1,100,0)
            
            zeros_1 <- array(0,dim=c(nStates))
            zeros_2 <- array(0,dim=c(nActions,nStates))
            zeros_3 <- array(0,dim=c(nActions,nStates,nStates))
            
            rank <- zeros_2
            
            for (i in 1:2){
              rank[i,] <- order(reward[i,],decreasing=TRUE)
            }
            
            #### FUNCTION LAND ####
            # Takes the probability of outcome i on 1 sample, the rank j of outcome i reward, and the number of samples. 
            # Returns the probability that outcome i will be the best reward outcome after n samples (explore choices).
            takeBestProb <- function(prb,rnk,n){
              tBP <- rep(0,length(rnk))
              for (j in 1:length(rnk)){
                tBP[rnk==j] <- (1-(sum(prb[rnk>j]))^n) - sum(tBP[rnk<j]) 
              }
              return(tBP)
            }
            
            # Takes the probability of outcome i, the rank of outcome i, and the best observed outcome.
            # Returns the probability that outcome i will be the best observed outcome following a subsequent sample.
            ratchet <- function(prb,rnk,nStates){
              out <- zeros_3
              for (i in 1:nStates){
                out[1,rnk[2,i],rnk[2,]==i] <- sum(prb[rnk[2,]>=i])
                out[1,rnk[2,i],rnk[2,]<i] <- prb[rnk[2,]<i]
                out[2,i,i]=1
              }
              return(out)
            }
            
            vect2arr <- function(vect){
              v <- zeros_2
              for (i in 1:nActions){
                v[i,]<-vect
              }
              return(v)
            }
            
            probs<-array(dim = c(2,4))
            probs[1,]<-c(0.8,0.2,0,0)
            probs[2,] <- c(0.6,0.35,0.05,0)
            valueGold<-array(dim=c(2,nper+1))
            
            for (i in 1:2){
            transProbs<-zeros_3
            transProbs<-ratchet(probs[i,],rank,nStates) #explore transistion probailities from [,i,] to [,,i]
            
            
            #### FINITE HORIZON BACKWARD SOLUTION ####
            v <-  array(0,dim=c(nStates,nper+1))
            vState <- zeros_2
            vContribution <- zeros_2
            value <- array(0,dim=c(nActions,nStates,nper))
            policy<- array(0,dim=c(nStates,nper))
            
            for (t in nper:1){
              for (s in 1:nStates){
                vState[,s] <- apply((transProbs[,s,]*vect2arr(v[,t+1])),1,sum)
                vContribution[,s] <- reward[,s]
                value[,s,t]<-vContribution[,s] + df*vState[,s]
                policy[s,t]<-which.max(value[,s,t])
                v[s,t] <- value[policy[s,t],s,t]
              }
            }
            valueGold[i,]<-v[2,]
            }
valueG<-as.data.frame(t(valueGold))

for ( i in 1:length(possRatios[,1])){
  expl<-possRatios$explores[i]
  prob<-possRatios$p[i]
  optExp<-((valueG[expl,1]*(1-prob))<(valueG[expl,2]*(prob)))&(policy[2,expl]!=2)
  possRatios$optExplore[i]<-optExp
}

possRatios$optExplore[possRatios$explores==nper]<-FALSE
possRatios$optExplore[possRatios$ratio==0]<-TRUE

possRatios$color <- rgb(0,1,0,1)
possRatios$color[!possRatios$optExplore] <- rgb(1,0,0,1)

#find optimal frontier
boundx<-0
counter<-0
found<-FALSE
bound<-NA
bound<-as.data.frame(array(dim=c(0,2)))
colnames(bound)<-c('x','y')
                     
for (i in 1:length(possRatios[,1])){
  X<-possRatios$explores[i]
  if (boundx==X){
    if (!found){
      if ((possRatios$optExplore[i])&(!possRatios$optExplore[i-1])){
        counter<-counter+1
        Y<-possRatios$ratio[i]-(1/X)+(1/100)
        boundrow<-data.frame(array(c(X,Y),dim=c(1,2)))
        colnames(boundrow)<-c('x','y')
        bound<-rbind(bound,boundrow)
        found<-TRUE
      }
    }
  }else{
    found<-FALSE
    boundx<-boundx+1
  }
}

boundx<-0
found<-FALSE
lobound<-NA
lobound<-as.data.frame(array(dim=c(0,2)))
colnames(lobound)<-c('x','y')

for (i in 1:length(possRatios$explores)){
  X<-possRatios$explores[i]
  if (boundx==X | X<bound$x[1]){
  }else{
    boundx<-X
    Y<-(2/(3*X))
    boundrow<-data.frame(array(c(X,Y),dim=c(1,2)))
    colnames(boundrow)<-c('x','y')
    lobound<-rbind(lobound,boundrow)
  }
}

Y<-0
rebound<-NA
rebound<-as.data.frame(array(dim=c(0,2)))
colnames(rebound)<-c('x','y')
for (i in 1:length(bound$y)){
  if (bound$y[i]>Y){
    X<-bound$x[i]
    Y<-bound$y[i]
    boundrow<-data.frame(array(c(X,Y),dim=c(1,2)))
    colnames(boundrow)<-c('x','y')
    rebound<-rbind(rebound,boundrow)
  }
}

found<-FALSE
quitx<-NA
for (i in 1:length(possRatios$explores)){
  X<-possRatios$explores[i]
  if ((possRatios$ratio[i]==1) & (!found) & (!possRatios$optExplore[i])){
    quitx<-X
    found<-TRUE
  }
}

quitY<-seq(max(rebound$y),1,(1/(quitx-1)))
quitX<-rep(quitx,length(quitY))
quitbound<-data.frame(quitX-0.5,quitY)

impossiblefilter<-possRatios$p<0.999
plot(x=possRatios$explores[impossiblefilter],y=possRatios$ratio[impossiblefilter],col=possRatios$color[impossiblefilter],pch=16,cex=.4, xlab="Explorations",ylab="Observed Gold Proportion",main="Optimal Exploration Decisions")
#plot(x=possRatios$explores,y=possRatios$ratio,col=rgb(0,0,0,0.2),pch=16,cex=.4, xlab="Explorations",ylab="Observed Gold Proportion",main="Optimal Exploration Decisions")
for (i in 1:length(possLineA[,1])){
  lines(x=c(possLineA[i,1],possLineB[i,1]),y=c(possLineA[i,2],possLineB[i,2]),col=rgb(0,0,0,.2))
}
lines(rebound, lty=2, lwd=1.5)
lines(lobound, lty=2, lwd=1.5)
lines(quitbound, lty=2, lwd=1.5)

#### Gold Paths ####
plotName<- paste('Participant Exploration Paths') 
plot1<-with(data[exploreFilter&subjectFilter&goldFilter,],plot(x=explores,y=goldRatio, col=(rgb(0,.5,0,1)),xlim = c(0,nper),ylim=c(0,1.0),pch=16,cex=.4,xlab = 'Explorations', ylab='Observed Gold Proportion', main=plotName))
for (subject in subjectSelect){
  for (block in blockList){
    blockFilter<-(data$blockID==block)&(data$subjectID==subject)
    fil<-exploreFilter&blockFilter&subjectFilter&goldFilter
    ord<-order(data$explores[fil])
    lines(x=data$explores[fil][ord],y=data$goldRatio[fil][ord],col=rgb(0,0,0,0.2))
    lines(x=c(data$explores[bingoFilter&blockFilter&subjectFilter&goldFilter],data$explores[bingoFilter&blockFilter&subjectFilter&goldFilter]+1),y=c(data$goldRatio[bingoFilter&blockFilter&subjectFilter&goldFilter],data$finalRatio[bingoFilter&blockFilter&subjectFilter&goldFilter]),col=rgb(0,0,0,0.2))
    #lines(x=c(data$explores[bustFilter&blockFilter&subjectFilter&goldFilter],data$explores[bustFilter&blockFilter&subjectFilter&goldFilter]+1),y=c(data$goldRatio[bustFilter&blockFilter&subjectFilter&goldFilter],data$finalRatio[bustFilter&blockFilter&subjectFilter&goldFilter]),col=rgb(0,0,0,0.2))
    }
}
points(x=data$explores[jackpotFilter&goldFilter&subjectFilter],y=data$finalRatio[jackpotFilter&goldFilter&subjectFilter],col=(rgb(218/255,165/255,32/255,1)),pch=15,cex=.7)
points(x=data$explores[bustFilter&goldFilter&subjectFilter],y=data$finalRatio[bustFilter&goldFilter&subjectFilter],col=(rgb(0,.5,0,1)),pch=16,cex=.55)
legend(30,0.95,legend=paste('n =',as.character(sum(goldFilter&subjectFilter&(bustFilter|bingoFilter))),'paths',sep=' '),box.lwd=0)
lines(rebound, lty=2, lwd=1.5)
lines(lobound, lty=2, lwd=1.5)
lines(quitbound, lty=2, lwd=1.5)

#### Diamond Paths ####
plotName<- paste('Participant Exploration Paths') 
plot1<-with(data[exploreFilter&subjectFilter&diamondFilter,],plot(x=explores,y=goldRatio, col=(rgb(0,.5,0,1)),xlim = c(0,nper),ylim=c(0,1.0),pch=16,cex=.4,xlab = 'Explorations', ylab='Observed Gold Proportion', main=plotName))
for (subject in subjectSelect){
  for (block in blockList){
    blockFilter<-(data$blockID==block)&(data$subjectID==subject)
    fil<-exploreFilter&blockFilter&subjectFilter&diamondFilter
    ord<-order(data$explores[fil])
    lines(x=data$explores[fil][ord],y=data$goldRatio[fil][ord],col=rgb(0,0,0,0.2))
    lines(x=c(data$explores[bingoFilter&blockFilter&subjectFilter&diamondFilter],data$explores[bingoFilter&blockFilter&subjectFilter&diamondFilter]+1),y=c(data$goldRatio[bingoFilter&blockFilter&subjectFilter&diamondFilter],data$finalRatio[bingoFilter&blockFilter&subjectFilter&diamondFilter]),col=rgb(0,0,0,0.2))
  }
}
points(x=data$explores[bingoFilter&diamondFilter&subjectFilter]+1,y=data$finalRatio[bingoFilter&diamondFilter&subjectFilter],col=(rgb(100/255,200/255,255/255,1)),pch=18,cex=1)
legend(30,0.95,legend=paste('n =',as.character(sum(diamondFilter&subjectFilter&bingoFilter)),'paths',sep=' '),box.lwd=0)
lines(rebound, lty=2, lwd=1.5)
lines(lobound, lty=2, lwd=1.5)
lines(quitbound, lty=2, lwd=1.5)


#### CONTOUR PLOT OF HAZARD ####
possRatios$weights <- (nper+1-possRatios$explores)/nper
possRatios$weights <- possRatios$weights/sum(possRatios$weights)
hazardData<-possRatios
for(i in 1:length(hazardData$explores)){
  for (j in 1:nper){
    blockFilter<-(hazardData$explores==j)
    upperSurvRat<-max(hazardData$ratio[blockFilter&(!is.na(hazardData$survival))])
    upperSurvival<-hazardData$survival[blockFilter&hazardData$ratio==upperSurvRat]
    hazardData$survival[blockFilter&hazardData$ratio>upperSurvRat]<-upperSurvival
    hazardData$hazard  [blockFilter&hazardData$ratio>upperSurvRat]<-1-upperSurvival
  }
}

contourdata <- loess(hazard ~ explores * ratio, data=hazardData, weights=weights^1)
xgrid <-  seq(0,nper,1)
ygrid <-  seq(0,1,0.02)
contourgrid <-  expand.grid(explores = xgrid, ratio = ygrid)
mtrx3d <-  predict(contourdata, newdata = contourgrid)
mtrx3d[mtrx3d<0]<-0
mtrx3d[mtrx3d>1.0]<-1
#mtrx3d[,1]<-0.02
clevels<-seq(0,01,0.02)
contour(x = xgrid, y = ygrid, z = mtrx3d, xlab = 'Explorations', ylab = 'Observed Gold Proportion',main='Possible Exploration Paths', levels=clevels, labcex=.75) #levels=c(0.2,0.5,0.8)
#plot(mtrx3d[,21],type='l', xlab="Explorations", ylab="Hazard", main="Hazard Rate at an observed Gold Proportion of 0.4")

plotName<- paste('Participant Explorations')
plot1<-with(data[exploreFilter&goldFilter,],plot(jitter(x=explores,5),y=jitter(goldRatio,150), col=(rgb(0,.5,0,.2)),xlim = c(0,nper),ylim=c(0,1.0),pch=16,cex=.5,xlab = 'Explorations', ylab='Observed Gold Proportion', main=plotName))
points(x=jitter(data$explores[bingoFilter&goldFilter&subjectFilter]+1,5),y=jitter(data$finalRatio[bingoFilter&goldFilter&subjectFilter],150),col=(rgb(205/255,0/255,0/255,0.6)),pch=21,cex=.85, lw=1.5)
lines(rebound, lty=2, lwd=1.5)
lines(lobound, lty=2, lwd=1.5)
lines(quitbound, lty=2, lwd=1.5)
legend(30,1,legend=c('explore','extract gold'),col=c(rgb(0,.5,0,.5),rgb(205/255,0/255,0/255,0.6)),pch=c(16,21),cex=c(1,1),box.lwd=0)

N=100
k=4
n=11
s<-seq(0,1,1/N)
plot(dbeta(x=s,k,n-k+1),cex=2, ylab='Relative Probability',xaxt='n', xlab='Observed Gold Proportion',names.arg=s, border=1, type="l")
axis(side=1,at=seq(0,N,N/10),las=1,labels=seq(0,N/100,N/1000))
legend(80,3,legend=c('n = 10','k =  3'),box.lwd=0)
lines(x=c(p1*N,p1*N),y=c(0,dbeta(x=p1,k,n-k+1)-0.11),lty=2)
lines(x=c(0,p1*N),y=c((dbeta(x=p1,k,n-k+1)-0.11),dbeta(x=p1,k,n-k+1)-0.11),lty=2)
lines(x=c(p2*N,p2*N),y=c(0,dbeta(x=p2,k,n-k+1)+0.04),lty=2)
lines(x=c(0,p2*N),y=c((dbeta(x=p2,k,n-k+1)+0.04),dbeta(x=p2,k,n-k+1)+0.04),lty=2)

hazardscale<-with(na.omit(possRatios),hazard^.5)
with(na.omit(possRatios),plot(explores,ratio,
                              col=rgb(
                                (hazardscale)
                                ,1-(hazardscale)
                                ,0
                                ,pmin((counts^1)/12,1)
                                ),pch=16,xlim=c(0,nper), xlab='Explorations', ylab='Observed Gold Proportion'))
legend(30,0.95,legend=paste('n =',as.character(sum(goldFilter&subjectFilter&(bustFilter|bingoFilter))),'paths',sep=' '),box.lwd=0)
lines(rebound, lty=2, lwd=1.5)
lines(lobound, lty=2, lwd=1.5)
lines(quitbound, lty=2, lwd=1.5)

colfunc <- colorRampPalette(c(rgb(1,0,0,0.5),rgb(0,1,0,0.6)),alpha=TRUE)
legend_image <- as.raster(matrix(colfunc(20), ncol=1))
legend_frame<-plot(c(0,2),c(0,1),type = 'n', axes = F,xlab = '', ylab = '', main = 'Hazard Rate')
text(x=1.3, y = seq(0,1,l=5), labels = format(round(seq(0,1,l=5),3),nsmall=2),cex=2)
legend(x=300,rasterImage(legend_image, 0, 0, 1,1))

diamondpaths<-sum(jackpotFilter&diamondFilter)
burnout<-as.data.frame(array(NA,dim=c(0,2)))
colnames(burnout)<-c('explores','halts')
for (i in 1:nper){
  y<-sum(jackpotFilter&goldFilter&(data$maxExpl==i))
  newburn<-as.data.frame(array(c(i,y),dim=c(1,2)))
  colnames(newburn)<-c('explores','halts')
  burnout<-rbind(burnout,newburn)
}
goldpaths<-sum(bingoFilter&goldFilter)
alive<-goldpaths
for (i in 1:length(burnout$explores)){
  burnout$hazard[i]<-burnout$halts[i]/alive
  alive<-alive-burnout$halts[i]
}
plot(x=burnout$explores, y=burnout$hazard, xlab='Explorations',ylab='Hazard Rate',col=rgb(0,0,0))
legend(35,.09,legend=paste('n =',as.character(sum(goldFilter&subjectFilter&(bustFilter|bingoFilter))),'paths',sep=' '),box.lwd=0)
model<-with(burnout[burnout$explores!=nper,],lm(hazard~explores))
hist(data$explores[bingoFilter&goldFilter],breaks=seq(0,nper,4), ylab='Extract Remaining Gold', xlab='Explorations')
legend(30,100,legend=paste('n =',as.character(sum(goldFilter&subjectFilter&(bustFilter|bingoFilter))),'paths',sep=' '),box.lwd=0)
