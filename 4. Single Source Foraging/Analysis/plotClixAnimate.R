plotClixAnimate<-function(.data){
  #y is the output object from parseClix.R for click data from single trial
  #NOTE!! THe plot window must be set so the sqare length and width are even. Viewer windo w:h is 2 to 1.1 ish
  
  require(gridExtra)
  require('ggimage')
  require(png)
  source('readData.R')
  source('parseMapList.R')
  source('parseClix.R')
  source('parseReveal.R')
  source('parseTarg.R')
  
  require(gridExtra)
  require(ggimage)
  require(png)
  source('parseMapList.R')
  source('parseClix.R')
  #source('parseReveal.R')
  source('parseTarg.R')
  
  main<-getwd()
  stimsize<-  .data$stimSize
  clx<-       .data %>% parseClix()
  if ( length(clx)>0 ) {
    #revsize<-   .data$revealSize
    #reveal<-    .data %>% parseReveal()
    targ<-      .data %>% parseTarg()
    sid<-       .data$subjectID
    tri<-       .data$trial_index
    match<-     .data$match
    
    scale <- 0.135
    #scale = 0.093
    jit <- 0
    margin <- 1
    shift <- 0.5
    pad <- 0.02
    height <-  stimsize
    width <- stimsize*2+1
    
    prefix <- "../../../../Experiment/img/map/" 
    fillColor <- "gray93"
    
    animDir<-"./animated"
    subjDir<-paste("s",formatC(sid, width=3,flag=0), sep="")
    triDir<-paste("t", formatC(tri, width=3,flag=0), sep="")
    choice<- as.character(clx$choice[1])
    
    dir.create(file.path(animDir, subjDir), showWarnings = FALSE)
    dir.create(file.path(animDir, subjDir,triDir), showWarnings = FALSE)
    setwd(file.path(animDir, subjDir,triDir))
    for (i in 1:nrow(clx)){
      
      clx_trunc <- clx[1:i,]
      
      mapClix <-  ggplot(clx_trunc, aes(X+pane*(stimsize+1),Y)) +
        theme_bw()+
        #left vertical
        geom_rect(xmin=-margin-shift,xmax=-shift+pad,ymin=-shift,ymax=stimsize+margin, fill=fillColor, linetype=0)+
        #middle vertical
        geom_rect(xmin=stimsize-shift,xmax=stimsize-shift + 1,ymin=-margin,ymax=stimsize+margin,fill = fillColor, linetype=0)+
        #right vertical
        geom_rect(xmin=width-shift-pad,xmax=width+margin,ymin=-margin,ymax=stimsize+margin, fill=fillColor, linetype=0)+
        #top horizontal
        geom_rect(xmin=-margin-shift,xmax=width+margin-shift,ymin=stimsize-shift-pad,ymax=stimsize+shift,fill=fillColor, linetype=0)+
        #bottom horizontal
        geom_rect(xmin=-margin-shift,xmax=width+margin-shift,ymin=-margin-shift,ymax=-shift+pad,fill= fillColor, linetype=0)+
        #points
        geom_point(aes(color=as.factor(pane)))+
        geom_image(aes(image=paste(prefix,path,sep="")), size=scale, asp=2.3)+
        #geom_image(aes(image=paste(prefix,path,sep="")), size=scale, data=reveal,  by="height")+ #asp=1.1,
        #annotate("rect",xmin=reveal$X[1]-.5,xmax=reveal$X[1]+revsize-1+.5,ymin=reveal$Y[1]+.5,ymax=reveal$Y[1]-revsize+1-.5, fill="white", color="black", linetype=2, alpha=0.5)+
        #annotate("text", label="intially \n revealed \n area", size=4, fontface=3, x=reveal$X[1]+(revsize-1)/2, y=reveal$Y[1]-(revsize-1)/2)+
        theme(legend.position="none")+
        scale_fill_brewer(palette=1)+
        geom_path(aes(x=jitter(X,jit)+pane*(stimsize+1),y=jitter(Y,jit)), alpha=0.8, size=1, linetype=3 )+
        geom_text(aes(label=clickID),hjust=1.6, vjust=-1, size=3, col="black", fontface="bold")+
        ggtitle(paste("Subject: ",sid," Trial: ",tri," Match:", as.logical(match)," Choice:", choice))+
        xlab("")+
        ylab("")+
        theme(plot.title = element_text(hjust = 0.5))+
        scale_x_continuous(limits=c(-.0,stimsize*2+0.5),labels=c("",seq(1:stimsize),"",seq(1:stimsize),""),breaks=c(seq(-1,stimsize*2+1)+0.5), minor_breaks = c())+
        scale_y_continuous(limits=c(-.0,stimsize+.5),labels=c("",seq(1:stimsize)),breaks=seq(-1,stimsize-1)+0.5, minor_breaks = c())+
        #scale_x_continuous(limits=c(-1,stimsize*2+1.5),labels=c("","",seq(1:stimsize),"",seq(1:stimsize)),breaks=seq(-2,stimsize*2)+0.5, minor_breaks = c())+
        #scale_y_continuous(limits=c(-1,stimsize+.5),labels=c("","",seq(1:stimsize)),breaks=seq(-2,stimsize-1)+0.5, minor_breaks = c())+
        theme(axis.text.x = element_text(hjust=4.0))+
        theme(axis.text.y = element_text(vjust=3))+
        geom_point(data=clx[1,],aes(x=X+pane*(stimsize+1),y=Y), color = "black", size = 3)+
        #geom_point(data=clx[1,],aes(x=targ[1],y=targ[2]), shape = 'X', color = "red", size = 10)+
        #target
        geom_point(data=clx[1,],aes(x=targ[3]+stimsize+1,y=targ[4]), shape = 'X', color = "red", size = 8)+
        coord_cartesian(xlim=c(-0.20,stimsize*2.07), ylim=c(-0.38,stimsize-0.6), clip ='off')
      #   coord_cartesian(xlim=c(-0.06,stimsize*2+1.5), ylim=c(-0.15,stimsize-0.75), clip ='off')
      
      ggsave(paste('dark',subjDir,triDir,'clx',formatC(i,width=3,flag=0),'.png',sep="_"),width = 8, height = 4.2, units='in')
      grid.arrange(mapClix, nrow=1)
    }
    
    mapClix <-  ggplot(clx, aes(X+pane*(stimsize+1),Y)) +
      theme_bw()+
      #left vertical
      geom_rect(xmin=-margin-shift,xmax=-shift+pad,ymin=-shift,ymax=stimsize+margin, fill=fillColor, linetype=0)+
      #middle vertical
      geom_rect(xmin=stimsize-shift,xmax=stimsize-shift + 1,ymin=-margin,ymax=stimsize+margin,fill = fillColor, linetype=0)+
      #right vertical
      geom_rect(xmin=width-shift-pad,xmax=width+margin,ymin=-margin,ymax=stimsize+margin, fill=fillColor, linetype=0)+
      #top horizontal
      geom_rect(xmin=-margin-shift,xmax=width+margin-shift,ymin=stimsize-shift-pad,ymax=stimsize+shift,fill=fillColor, linetype=0)+
      #bottom horizontal
      geom_rect(xmin=-margin-shift,xmax=width+margin-shift,ymin=-margin-shift,ymax=-shift+pad,fill= fillColor, linetype=0)+
      #points
      geom_point(aes(color=as.factor(pane)))+
      geom_image(aes(image=paste(prefix,path,sep="")), size=scale, asp=2.3)+
      #geom_image(aes(image=paste(prefix,path,sep="")), size=scale, data=reveal,  by="height")+ #asp=1.1,
      #annotate("rect",xmin=reveal$X[1]-.5,xmax=reveal$X[1]+revsize-1+.5,ymin=reveal$Y[1]+.5,ymax=reveal$Y[1]-revsize+1-.5, fill="white", color="black", linetype=2, alpha=0.5)+
      #annotate("text", label="intially \n revealed \n area", size=4, fontface=3, x=reveal$X[1]+(revsize-1)/2, y=reveal$Y[1]-(revsize-1)/2)+
      theme(legend.position="none")+
      scale_fill_brewer(palette=1)+
      geom_path(aes(x=jitter(X,jit)+pane*(stimsize+1),y=jitter(Y,jit)), alpha=0.8, size=1, linetype=3 )+
      geom_text(aes(label=clickID),hjust=1.6, vjust=-1, size=3, col="black", fontface="bold")+
      ggtitle(paste("Subject: ",sid," Trial: ",tri," Match:", as.logical(match)," Choice:", choice))+
      xlab("")+
      ylab("")+
      theme(plot.title = element_text(hjust = 0.5))+
      scale_x_continuous(limits=c(-.0,stimsize*2+0.5),labels=c("",seq(1:stimsize),"",seq(1:stimsize),""),breaks=c(seq(-1,stimsize*2+1)+0.5), minor_breaks = c())+
      scale_y_continuous(limits=c(-.0,stimsize+.5),labels=c("",seq(1:stimsize)),breaks=seq(-1,stimsize-1)+0.5, minor_breaks = c())+
      #scale_x_continuous(limits=c(-1,stimsize*2+1.5),labels=c("","",seq(1:stimsize),"",seq(1:stimsize)),breaks=seq(-2,stimsize*2)+0.5, minor_breaks = c())+
      #scale_y_continuous(limits=c(-1,stimsize+.5),labels=c("","",seq(1:stimsize)),breaks=seq(-2,stimsize-1)+0.5, minor_breaks = c())+
      theme(axis.text.x = element_text(hjust=4.0))+
      theme(axis.text.y = element_text(vjust=3))+
      geom_point(data=clx[1,],aes(x=X+pane*(stimsize+1),y=Y), color = "black", size = 3)+
      #geom_point(data=clx[1,],aes(x=targ[1],y=targ[2]), shape = 'X', color = "red", size = 10)+
      #target
      geom_point(data=clx[1,],aes(x=targ[3]+stimsize+1,y=targ[4]), shape = 'X', color = "red", size = 8)+
      coord_cartesian(xlim=c(-0.20,stimsize*2.07), ylim=c(-0.38,stimsize-0.6), clip ='off')+
    #   coord_cartesian(xlim=c(-0.06,stimsize*2+1.5), ylim=c(-0.15,stimsize-0.75), clip ='off')
      geom_image(aes(image=paste(prefix,path,sep="")), size=scale, asp=2.3)
    
    ggsave(paste('dark',subjDir,triDir,'clx',formatC(i,width=3,flag=0),'.png',sep="_"),width = 8, height = 4.2, units='in')
    grid.arrange(mapClix, nrow=1)
    dev.off()
    
    
  }
  
  
  setwd(main)
}
  