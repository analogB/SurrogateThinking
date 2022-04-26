#SPECIFY STRING CHARACTERISTICS
N <- 4
n <- 2
k <- 2

#SPECIFY MODELS & MODEL PRIORS
p <- c(0.5,k/n) #dual model
prior <- c(0.5,0.5) #prior on dual model
#p <- 0.5 #single chance model
#p <- (seq(0,1,0.01)) #proportion model
#prior <- rep(1/length(p),length(p)) #prior on proportion model

#OTHER INITIALIZATIONS
K <- seq(0,N)
pbyK <- length(p) * length(K)
P <- data.frame(rep(0,pbyK),rep(0,pbyK),rep(0,pbyK))
colnames(P) <- c('K','p','prob')
moment <- 2
Pr<- rep(0,N+1)
out<-data.frame()
count<-1
KProb <- 0
pProb <- 0

#LIKELIHOOD FUNCTION TIMES PRIOR
for (j in 1:length(p)){
  for (i in 1:length(K)){
    P$K[count]<-K[i]
    P$p[count]<-p[j]
    P$prob[count] <- prior[j]*
      p[j]^(K[i])*(1-p[j])^(N-K[i])*factorial(N)/factorial(K[i])/factorial(N-K[i])* 
      
      (factorial(K[i])/factorial(k)/factorial(K[i]-k) *
      factorial(N-K[i])/factorial(n-k)/factorial(N-K[i]-n+k)/
      factorial(N)/factorial(n)/factorial(N-n))^2
    if (P$prob[count] == 'NaN') {P$prob[count]<-0}
    count<-count+1
}}

#FORMAT AND NORMALIZE
P$p<-as.factor(P$p)
P$K<-as.factor(P$K)
P$prob <- P$prob / sum(P$prob)

#AGGREGATE OUTPUT VARIABLES
pProb<-aggregate(prob ~ p,FUN=sum,data=P)
KProb<-aggregate(prob ~ K, FUN=sum, data=P)

#OUTPUT
plot(pProb)
plot(KProb)
print(pProb)
print(KProb)
print(pProb[length(p),2])
