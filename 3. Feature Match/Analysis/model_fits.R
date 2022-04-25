modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1, 'x', 1, 1), c(1, 1, 'x', 1));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c('x', 0, 1, 1), negModel(c(0, 1, 'x', 0)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c('x', 0, 'x', 1), negModel(c('x', 1, 'x', 0)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,1,1,'x'), negModel(c(0, 'x', 0, 0)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(0, 1, 'x', 0), negModel(c(1, 0, 1, 'x')));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(0, 'x', 0, 1), negModel(c('x', 0, 0, 0)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,0,1,'x'), negModel(c(1,0,1,'x')));modelSet[modelSet$bivariateProb!=0,]
#5

modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(0,'x',0,1), negModel(c(1,0,'x',1)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,'x',1,1), negModel(c(1,0,'x',1)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(0, 'x', 1,1), negModel(c(0,0,1,'x')));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,1,1,'x'), negModel(c(0,'x',0,1)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,0,0,'x'), negModel(c(1,0,'x',0)));modelSet[modelSet$bivariateProb!=0,]

#10




#21
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,'x',1,1,'x'), negModel(c('x', 1, 'x', 0, 1)));modelSet[modelSet$bivariateProb!=0,]
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,'x',1,1,'x'), negModel(c('x', 1, 'x', 0, 1)));modelSet[modelSet$bivariateProb!=0,]



#28
modelSet <- jointBivariateProbablityOfModelsHackedNormalization(c(1,0,'x',1,1), negModel(c('x', 0,0,1,'x')));modelSet[modelSet$bivariateProb!=0,]





