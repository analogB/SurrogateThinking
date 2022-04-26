plotClix<-function(y){
  #y is the output object from parseClix.R for click data from single trial

  mapClix <-   ggplot(y, aes(Xpane,Y)) +
    geom_rect(xmin=7.5,xmax=8.5,ymin=-2,ymax=9, fill="white", linetype=0)+
    geom_rect(xmin=-1,xmax=-0.5,ymin=-2,ymax=9, fill="white", linetype=0)+
    geom_rect(xmin=16.5,xmax=17,ymin=-2,ymax=9, fill="white", linetype=0)+
    geom_point(aes(color=as.factor(pane)))+
    theme(legend.position="none")+
    scale_fill_brewer(palette="set1")+
    geom_path(aes(x=Xpane,y=Y), alpha=0.15)+
    geom_text(aes(label=clickID),hjust=-.55, vjust=-.8, size=1.5)+
    ggtitle(paste("Subject: ",unique(y$subjectID)," Trial: ",unique(y$trialID)," Match:", as.logical(unique(y$match))))+
    xlab("horizontal position")+
    ylab("vertical position")+
    theme(plot.title = element_text(hjust = 0.5))+
    scale_x_continuous(limits=c(0,16),labels=c("",seq(1:8),"",seq(1:8)),breaks=seq(-1,16)+0.5, minor_breaks = c())+
    scale_y_continuous(limits=c(0,7.15),labels=c(seq(1:8)),breaks=seq(0,7)+0.5, minor_breaks = c())+
    theme(axis.text.x = element_text(hjust=2.6))+
    theme(axis.text.y = element_text(vjust=2.05))+
    geom_point(data=y[1,],aes(x=Xpane,y=Y), color = "black")+
    geom_point(data=y[1,],aes(x=targX,y=targY), shape = 'O', color = "black", size = 4)+
    geom_point(data=y[1,],aes(x=targXmap,y=targYmap), shape = 'O', color = "black", size = 4)

  
  distClix <- ggplot(y, aes(clickID,totchange))+
    geom_point(aes(color=as.factor(pane)))+
    xlim(0,max(c(40,max(y$clickID))))+
    theme(legend.position="none")+
    scale_fill_brewer(palette="set1")+
    #ggtitle(paste("Subject: ",unique(y$subjectID)," Trial: ",unique(y$trialID)," Match:", as.logical(unique(y$match))))+
    xlab("click")+
    ylab("manhattan distance")+
    geom_point(aes(x=1,y=0), color = "black")

  grid.arrange(mapClix,distClix,nrow=2)

}