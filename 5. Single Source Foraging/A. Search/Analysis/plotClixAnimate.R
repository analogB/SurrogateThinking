plotClixAnimate<-function(.data){
  #y is the output object from parseClix.R for click data from single trial
  #NOTE!! THe plot window must be set so the sqare length and width are even. Viewer windo w:h is 2 to 1.1 ish
  
  require(gridExtra)
  require(ggimage)
  require(png)
  source('readData.R')
  source('parseMapList.R')
  source('parseClix.R')
  source('parseReveal.R')
  source('parseTarg.R')
  
  stimsize <- .data$stimSize
  clx<-       .data %>% parseClix()
  revsize<-   .data$revealSize
  reveal<-    .data %>% parseReveal()
  targ<-      .data %>% parseTarg()
  sid<-       .data$subjectID
  tri<-       .data$trial_index
  match<-     .data$match
  
  
  main<-"/Users/brad/Desktop/IU Research/Darkroom/03"
  animDir<-"/Users/brad/Desktop/IU Research/Darkroom/03/animated"
  subjDir<-paste("s",formatC(sid, width=3,flag=0), sep="")
  triDir<-paste("t", formatC(tri, width=3,flag=0), sep="")
  
  dir.create(file.path(animDir, subjDir), showWarnings = FALSE)
  dir.create(file.path(animDir, subjDir,triDir), showWarnings = FALSE)
  setwd(file.path(animDir, subjDir,triDir))
  
  scale = 0.093
  jit = 1

  prefix = paste(main,"/img/map/",sep="")
  
  for (i in 1:nrow(clx)){

  clx_trunc <- clx[1:i,]
    
  mapClix <-  ggplot(clx_trunc, aes(X+pane*(stimsize+1),Y)) +
    geom_rect(xmin=stimsize-0.5,xmax=stimsize+0.5,ymin=-2,ymax=stimsize+1, fill="white", linetype=0)+ 
    geom_rect(xmin=-1,xmax=-0.5,ymin=-2,ymax=stimsize+1, fill="white", linetype=0)+
    geom_rect(xmin=stimsize*2+0.5,xmax=stimsize*2+1,ymin=-2,ymax=stimsize+1, fill="white", linetype=0)+
    geom_rect(xmin=-0.5,xmax=stimsize*2+0.5,ymin=stimsize-0.5,ymax=stimsize+0.5,fill="white", linetype=0)+
    geom_point(aes(color=as.factor(pane)))+
    geom_image(aes(image=paste(prefix,path,sep="")), size=scale)+
    geom_image(aes(image=paste(prefix,path,sep="")), size=scale, data=reveal,  by="height")+ #asp=1.1,
    annotate("rect",xmin=reveal$X[1]-.5,xmax=reveal$X[1]+revsize-1+.5,ymin=reveal$Y[1]+.5,ymax=reveal$Y[1]-revsize+1-.5, fill="white", color="black", linetype=2, alpha=0.5)+
    annotate("text", label="intially \n revealed \n area", size=4, fontface=3, x=reveal$X[1]+(revsize-1)/2, y=reveal$Y[1]-(revsize-1)/2)+
    theme(legend.position="none")+
    scale_fill_brewer(palette=1)+
    geom_path(aes(x=jitter(X,jit)+pane*(stimsize+1),y=jitter(Y,jit)), alpha=0.4)+
    geom_text(aes(label=clickID),hjust=1.5, vjust=-1, size=3, col="black", fontface="bold")+
    ggtitle(paste("Subject: ",sid," Trial: ",tri," Match:", as.logical(match)))+
    xlab("")+
    ylab("")+
    theme(plot.title = element_text(hjust = 0.5))+
    scale_x_continuous(limits=c(-1,stimsize*2+.5),labels=c("","",seq(1:stimsize),"",seq(1:stimsize)),breaks=seq(-2,stimsize*2)+0.5, minor_breaks = c())+
    scale_y_continuous(limits=c(-1,stimsize+.5),labels=c("","",seq(1:stimsize)),breaks=seq(-2,stimsize-1)+0.5, minor_breaks = c())+
    theme(axis.text.x = element_text(hjust=4.0))+
    theme(axis.text.y = element_text(vjust=3))+
    geom_point(data=clx_trunc[1,],aes(x=X+pane*(stimsize+1),y=Y), color = "black", size = 3)+
    geom_point(data=clx_trunc[1,],aes(x=targ[1],y=targ[2]), shape = 'X', color = "red", size = 5)+
    geom_point(data=clx_trunc[1,],aes(x=targ[3]+stimsize+1,y=targ[4]), shape = 'X', color = "black", size = 5)+
    coord_cartesian(xlim=c(-0.05,stimsize*2), ylim=c(-0.15,stimsize-0.75), clip ='off')

    ggsave(paste('dark',subjDir,triDir,'clx',formatC(i,width=3,flag=0),'.png',sep="_"),width = 8, height = 4.2, units='in')
    grid.arrange(mapClix, nrow=1)
    dev.off()
  }
  setwd(main)
}
  