#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R <input> ... [--mean=<output1>] [--max=<output2>]
        tool.R -h | --help

options:
 <input>                   The input data.
 --mean=<output>              Output file [Default: tmp1.pdf]
 --max=<output>              Output file [Default: tmp2.pdf]
 ' -> doc

args<- docopt(doc)

df=data.frame()
dfm=data.frame()
size = 0

for (filename in args$input) {
  data=read.csv(filename,sep=' ',header=FALSE)
  names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')
  fstrow = data[1,]
  data = data[2:nrow(data),]
  size = nrow(data)
  final_names = data$name
  for (i in 1:nrow(data)) {
    data$meanwait[i] = data$meanwait[i] / fstrow$meanwait[1]
    data$maxwait[i] = data$maxwait[i] / fstrow$maxwait[1]
  }
  data$name = 1:nrow(data)
  df=rbind(df,data)
}

df$name = final_names[df$name]

bwmean<-(max(df$meanwait)-min(df$meanwait))/30

df=df[complete.cases(df),]
print(summary(df))

dfm=data.frame()
for (n in unique(df$name)) {
  dfn=df[which(df$name==n),]
  dfm=rbind(dfm,data.frame(meanmax=mean(dfn$maxwait),meanmean=mean(dfn$meanwait),name=n))
}

pmeanwait=ggplot(df,aes(x=meanwait,fill=name))+
  geom_histogram(aes(y=(..density..)),position="dodge", binwidth=bwmean)+
  geom_point(data=dfm,aes(y=-0.0001, x=meanmean,fill=name))+
  geom_vline(data=dfm,aes(xintercept=meanmean,color=name,fill=name))+
  geom_density(alpha=0.1,aes(color=name,fill=name))+
  xlab("Average Waiting Time")+
  ylab("Proportion of experiments")

bwmax<-(max(df$maxwait)-min(df$maxwait))/30

pmaxwait=ggplot(df,aes(x=maxwait,fill=name))+
  geom_histogram(aes(y=(..density..)),position="dodge", binwidth=bwmax)+
  geom_point(data=dfm,aes(y=-0.0001, x=meanmax,fill=name))+
  geom_vline(data=dfm,aes(xintercept=meanmax,color=name,fill=name))+
  geom_density(alpha=0.1,aes(color=name,fill=name))+
  xlab("Max Waiting Time")+
  ylab("Proportion of experiments")

pdf(file=args$mean,width=20,height=7)
pmeanwait
pdf(file=args$max,width=20,height=7)
pmaxwait
