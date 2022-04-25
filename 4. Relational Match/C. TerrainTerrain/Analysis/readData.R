readData<-function(){
  require('readr')
  
  dirs=c('LetterNumeral', 'NumeralNumeral', 'TerrainNumeral', 'TerrainPattern','TerrainTerrain')
  for (dir in dirs){
  
  root=getwd()
  dirData=paste('../',dir,'/data/',sep='')
  print(paste('setting directory to:',dirData))
  setwd(dirData)

  fileList <- list.files()
  for (file in fileList){
    # append data from all other files
    if (exists("rawData")){
      temp_dataset <-read.csv(file, header=TRUE, sep=",") %>% mutate(condition = dir)
      rawData<-rbind(rawData, temp_dataset)
      rm(temp_dataset)}
    # create from first data file
    if (!exists("rawData")){
      rawData <- read.csv(file, header=TRUE, sep=",") %>% mutate(condition = dir)}
    }
    setwd(root)
  }
  return(rawData)
}

formatData <- function(data) {
  require('readr')

  data <- data %>% mutate(test_index = trial_index-2)
  data <- data %>% mutate(stim_id=parse_number(stimulus)) 
  
  data$rt                    <- as.numeric   (data$rt)
  data$trial_type            <- as.factor    (data$trial_type)
  data$trial_index           <- as.numeric   (data$trial_index)
  data$time_elapsed          <- as.numeric   (data$time_elapsed)
  data$internal_node_id      <- as.character (data$internal_node_id)
  data$turkID                <- as.factor    (data$turkID)
  data$ExpEndTime            <- as.factor    (data$ExpEndTime)
  data$stim_id               <- as.factor    (data$stim_id)
  data$radio_response        <- as.character (data$radio_response)
  data$slider_start          <- as.numeric   (data$slider_start)
  data$slider_response       <- as.numeric   (data$slider_response)
  data$condition             <- as.factor    (data$condition)
  data$test_index            <- as.factor    (data$test_index)
  
  data <- data %>% filter(trial_type=="singlestim-multichoice-slider")
  data <- subset(data, select=-c(view_history,trial_type,trial_index,internal_node_id,ExpEndTime))
  
  print(typeof(data$stim_id))
  
  return(data)
}

readStims <- function () {
  require('readr')
  root=getwd()
  stims <-read.csv('stim_features.csv', header=TRUE, sep=",")
  return(stims)
}

formatStims <- function (stims) {
  stims$stim_id         <- as.factor(stims$stim_id)
  stims$source_pattern  <- as.factor(stims$source_pattern)
  stims$mapping_pattern <- as.factor(stims$mapping_pattern)
  stims$target_anchored <- as.factor(stims$target_anchored)
  stims$best_response   <- as.character(stims$best_response)
  return(stims)
}
