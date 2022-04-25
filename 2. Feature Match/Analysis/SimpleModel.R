require(plyr)





probabilityModelGivenData <- function(model, data){
  knowns   <- sum(data!='x')
  unknowns <- sum(data=='x')
  match <- mean(model[data!='x' & model!='x'] == data[data!='x' & model!='x'])==1
  if(is.na(match)){match <- 1}
  return(match/(2^unknowns))          
}


jointUnivariateProbabilityOfModelsGivenData <- function(model1,  data1, model2, data2){
  probabilityModelGivenData(model1, data1) * probabilityModelGivenData(model2, data2)
}




generateModelSpace <- function(length){
  if(length==1){list(c(0), c(1))} else {
    y <- generateModelSpace(length-1)
    c(lapply(y, function(x){c(x,0)}),
      lapply(y, function(x){c(x,1)}))
  }    
}



pObservingPatterningnessGivenModel <- function(model1, data1,model2,data2){
  observations1   <- sum(data1!='x')
  unknowns1 <- sum(data1=='x')
  observations2   <- sum(data2!='x')
  unknowns2 <- sum(data2=='x')
  matches <- sum(model1==model2)
  mismatches <- sum(model1!=model2)
  # So we want the probability that given a certain number of observations, we observe only matches
  # This is 1 minus the probability of detecting a mismatch, eg., detecting both halves of a mismatching item.
  prob <- 0
  for(i in 0:length(data1)){
    pIMatches <- dhyper(i, observations1, unknowns1, observations2) #prob of this many paired data points
    pMismatchGivenIMatches <- dhyper(0, mismatches, matches, i)
    prob <- prob + pMismatchGivenIMatches * pIMatches

  }
  prob
}



pObservingCrossGivenModel <- function(model1, data1,model2,data2){
  observations1   <- sum(data1!='x')
  unknowns1 <- sum(data1=='x')
  observations2   <- sum(data2!='x')
  unknowns2 <- sum(data2=='x')
  matches <- sum(model1==model2)
  mismatches <- sum(model1!=model2)
  dataMatches <- sum((data1==data2)[data1!='x' & data2!='x'])
  dataMismatches <- sum((data1!=data2)[data1!='x' & data2!='x'])
  # So we want the probability that given a certain number of observations, we observe exactly this 
  # pattern of matches and mismatches, and non-mathces.
  prob <- 0
  # probablity of number of correspondences
  pAnyMatches <- dhyper(dataMatches+dataMismatches, observations1, unknowns1, observations2)
  # probablity of the proportion of matches given the number of correspondences selected
  pMatches <- dhyper(dataMatches, matches, mismatches, dataMatches+dataMismatches)
  
  pAnyMatches*pMatches
  
}




pObservedCross <- function(data1, data2, pPat=-1){
  pModel <- 1/2^length(data1)*1/2^length(data1) # nope, this is wrong. The model must be consistent with the number of matches in the data.  Eqv here to matching the actual data?
  
  
  if(pPat==-1){pPat <- 1/2^length(data1)}
  models1 <- generateModelSpace(length(data1))
  models2 <- models1
  prob <- 0
  # Count consistent models
  count <- 0
  for(i in 1:length(models1)){
    for(j in 1:length(models2)){
      model1 <- models1[[i]]
      model2 <- models2[[j]]
      matches <- sum(model1==model2)
      mismatches <- sum(model1!=model2)
      dataMatches <- sum((data1==data2)[data1!='x' & data2!='x'])
      dataMismatches <- sum((data1!=data2)[data1!='x' & data2!='x'])
      if(matches>=dataMatches & mismatches >= dataMismatches){count <- count+1}
    }
  }
  
  for(i in 1:length(models1)){
    for(j in 1:length(models2)){
      model1 <- models1[[i]]
      model2 <- models2[[j]]
      matches <- sum(model1==model2)
      mismatches <- sum(model1!=model2)
      dataMatches <- sum((data1==data2)[data1!='x' & data2!='x'])
      dataMismatches <- sum((data1!=data2)[data1!='x' & data2!='x'])
     # if(matches<dataMatches | mismatches < dataMismatches){
    #    pModel <- 0
    #    } else {
    #    pModel <- 1/count
    #  }
      
      prob <- prob + pModel *pObservingCrossGivenModel(model1, data1, model2, data2)
     # print(c(model1, model2))
    #  print(pModel)
    #  print(pObservingCrossGivenModel(model1, data1, model2, data2))
      
    }
  }
 # print(count)
  prob
}

pModelGivenObservedPattern <- function(model1, data1, model2, data2){
  pModel <- 1/2^length(model1)*1/2^length(model1)
  pModel * pObservingCrossGivenModel(model1, data1, model2, data2) / pObservedCross(data1, data2)
}


jointBivariateProbabilityOfModelsGivenDataUnnormalized <- function(model1, data1, model2, data2){
  jointUnivariateProbabilityOfModelsGivenData(model1, data1, model2, data2)*pModelGivenObservedPattern(model1, data1, model2, data2)
}

negModel <- function(model){
  model2 <- model
  model2[model!="x"] <- as.character(1-as.numeric(model[model!='x']))
  model2
}

jointBivariateProbablityOfModelsHackedNormalization <- function(data1, data2){
  # Assumes that p([M,N] | [D, E], S) is proportional to p(M|D,S) * p(N|E,S) * p(MxN | DxE, S)
  # Where M is the first model, N is the second, D is the observations of the first, E the second, and the AxB's reflect 
  # The number of matches, mismatches, etc.  It's clear that this is wrong, and that we need to divide by
  # some kind of normalization...but what, exactly?  I don't know.  
  models1 <- generateModelSpace(length(data1))
  models2 <- models1
  modelFrame<- ddply(data.frame(model1=unlist(lapply(models1, function(x){paste(x, collapse="")}))), .(model1), function(x){data.frame(model1=x, model2 =unlist(lapply(models1, function(x){paste(x, collapse="")}))) })  
  modelFrame$neg2 <- 0
  modelFrame$bivariateProb<-0
  modelFrame$univariateProb<-0
  modelFrame$prior <- 1/length(modelFrame$model1) # uniform prior
  
  for(i in 1:length(modelFrame$model1)){
    model1 <- unlist(strsplit(as.character(modelFrame$model1[i]), ""))
    model2 <- unlist(strsplit(as.character(modelFrame$model2[i]), ""))
    #print(model1)
    #print(model2)
    modelFrame$bivariateProb[i]  <-  jointBivariateProbabilityOfModelsGivenDataUnnormalized(model1, data1, model2, data2)
    modelFrame$univariateProb[i] <- jointUnivariateProbabilityOfModelsGivenData(model1, data1, model2, data2)
    modelFrame$neg2[i] <- paste(negModel(model2), collapse="")
    
  }
  modelFrame$bivariateProb <- modelFrame$bivariateProb / sum(modelFrame$bivariateProb)
  modelFrame
}



pValueGivenData <- function(sample, index, value, data1, data2){
  # sample = 0, 1, index is obvious, etc.
  pPGD <- pPatGivenData(data1, data2)
  pValueGivenPat(sample, index, value, data1, data2)*pPGD +
    0.5*(1-pPGD)
}


