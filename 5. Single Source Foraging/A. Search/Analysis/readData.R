readData<-function(){
  require('readr')
  
  dir=getwd()
  dirData=paste(dir,'/data',sep='')
  setwd(dir)
  
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
  rawData$trial_type            <- as.factor    (rawData$trial_type)
  rawData$trial_index           <- as.factor    (rawData$trial_index)
  rawData$time_elapsed          <- as.numeric   (rawData$time_elapsed)
  rawData$internal_node_id      <- as.character (rawData$internal_node_id)
  #rawData$turkID                <- as.factor    (rawData$turkID) #OLD DATA VERSION
  rawData$sonaID                <- as.factor    (rawData$sonaID)
  #rawData$ExpEndTime           <- as.factor    (rawData$ExpEndTime)
  rawData$clicks                <- as.character (rawData$clicks)
  rawData$match                 <- as.logical    (rawData$match)
  rawData$sTarg                 <- as.character  (rawData$sTarg)
  rawData$mTarg                 <- as.character (rawData$mTarg)
  rawData$xGrid                 <- as.numeric   (rawData$xGrid)
  rawData$yGrid                 <- as.numeric   (rawData$yGrid)
  rawData$maxTrans              <- as.numeric   (rawData$maxTrans)
  rawData$maxPrize              <- as.numeric   (rawData$maxPrize)
  rawData$primaryDec            <- as.numeric   (rawData$primaryDec)
  rawData$surrogateDec          <- as.numeric   (rawData$surrogateDec)
  rawData$mapDir                <- as.factor    (rawData$mapDir)
  #rawData$responses             <- as.character (rawData$responses) #OLD DATA VERSION
  #rawData$subjectID             <- as.numeric   (as.factor(rawData$turkID)) #OLD DATA VERSION
  rawData$subjectID             <- as.numeric   (as.factor(rawData$sonaID))
  
  #make blockIDs
  rawData[,'blockID']<-substr(rawData[,'internal_node_id'],5,nchar(rawData[,'internal_node_id']))
  rawData$blockID <- gsub("\\-.*","",rawData$blockID)
  rawData$blockID<-substr(rawData$blockID,1,nchar(rawData$blockID)-2)
  return(rawData)
}