
rm(list=ls(all=TRUE))
#detach('plyr')
require('dplyr')
require('tidyverse')
require('ggplot2')
#require('ggpubr')
source('readData.R')

stims <- formatStims(readStims())
df <- formatData(readData()) %>% left_join(stims, by='stim_id') %>% mutate(correct = radio_response == best_response)

min_corr <- 0.333

df <- df %>% left_join(df %>% group_by(turkID) %>% summarize(participant_correct = mean(correct)), by='turkID')
df <- df %>% filter(participant_correct>=min_corr)

df <- df %>% left_join(df %>% group_by(stim_id) %>% summarize(stim_avg = mean(slider_response)), by='stim_id')
df <- df %>% left_join(df %>% group_by(target_anchored) %>% summarize(anchored_avg = mean(slider_response)), by='target_anchored')
df <- df %>% left_join(df %>% group_by(source_pattern) %>% summarize(source_patt_avg = mean(slider_response)), by='source_pattern')
df <- df %>% left_join(df %>% group_by(mapping_pattern) %>% summarize(mapping_patt_avg = mean(slider_response)), by='mapping_pattern')
df <- df %>% left_join(df %>% group_by(condition) %>% summarize(condition_avg = mean(slider_response)), by='condition')
df <- df %>% left_join(df %>% group_by(condition,stim_id) %>% summarize(unique_condition_avg = mean(slider_response)), by=c('condition','stim_id'))


plot1 <- ggplot(df%>%filter(slider_response<100), aes(stim_id,slider_response))+
  geom_point(alpha=0.1)+
  geom_point(aes(stim_id,stim_avg), colour="black")

plot2 <-  ggplot(df%>%filter(slider_response<100), aes(target_anchored,slider_response))+
  geom_point(alpha=0.02)+
  geom_point(aes(target_anchored,anchored_avg), colour="blue")

plot3 <-  ggplot(df%>%filter(slider_response<100), aes(source_pattern,slider_response))+
  geom_point(alpha=0.02)+
  geom_point(aes(source_pattern,source_patt_avg), colour="blue")

plot4 <-  ggplot(df%>%filter(slider_response<100), aes(mapping_pattern,slider_response))+
  geom_point(alpha=0.02)+
  geom_point(aes(mapping_pattern,mapping_patt_avg), colour="red")

plot5 <-  ggplot(df%>%filter(slider_response<100), aes(condition,slider_response))+
  geom_point(alpha=0.02)+
  geom_point(aes(condition,condition_avg), colour="red")

plot6 <-  ggplot(df%>%filter(slider_response<100), aes(condition,slider_response))+
  geom_point(alpha=0.02)+
  geom_point(aes(condition,unique_condition_avg, colour=target_anchored, shape = mapping_pattern))

plot1
plot2
plot3
plot4
plot5
plot6

