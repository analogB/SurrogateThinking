trialMetrics<-function(x){
  
  require('tidyr')
  
  for 
  
  y<-mutate(y,isSwitch=(lag(pane, n=1)!=pane))
  y$isSwitch <- as.factor(y$isSwitch)
  y<-mutate(y,nextSwitch=(lead(isSwitch, n=1)==TRUE))
  y$nextSwitch <- as.factor(y$nextSwitch)
  y<-mutate(y,Xchange=abs(X-lag(X, n=1)))
  y<-mutate(y,Ychange=abs(Y-lag(Y, n=1)))
  y<-mutate(y,totchange=Xchange+Ychange)
  y<-mutate(y,euclidchange=sqrt(Xchange^2+Ychange^2))
  y<-mutate(y,Xpane=X + pane*9)
  y<-mutate(y,clickID=1:n())
  y<-mutate(y,clickTotal=max(clickID))
  
  return(y)
}
