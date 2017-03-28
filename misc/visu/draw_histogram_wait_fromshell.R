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
for (filename in args$input) {
  data=read.csv(filename,sep=' ',header=FALSE)
  names(data)=c('meanwait','maxwait','name')
  data$type=filename
  df=rbind(df,data)
  dfm=rbind(dfm,data.frame(meanmax=mean(data$maxwait),meanmean=mean(data$meanwait),type=filename))
}

bwmean<-(max(df$meanwait)-min(df$meanwait))/30
pmeanwait=ggplot(df,aes(x=meanwait,fill=type,color=type))+
  geom_histogram(aes(y=(..density..)),position="dodge", binwidth=bwmean)+
  geom_point(data=dfm,aes(y=-0.0001, x=meanmean,fill=type))+
  geom_vline(data=dfm,aes(xintercept=meanmean,color=type,fill=type))+
  geom_density(alpha=0.1,aes(color=type,fill=type))+
  xlab("Average Waiting Time")+
  ylab("Proportion of experiments")

bwmax<-(max(df$maxwait)-min(df$maxwait))/30
pmaxwait=ggplot(df,aes(x=maxwait,fill=type))+
  geom_histogram(aes(y=(..density..)),position="dodge", binwidth=bwmax)+
  geom_point(data=dfm,aes(y=-0.0001, x=meanmax,fill=type))+
  geom_vline(data=dfm,aes(xintercept=meanmax,color=type,fill=type))+
  xlab("Max Waiting Time")+
  ylab("Proportion of experiments")

pdf(file=args$mean,width=20,height=7)
pmeanwait
pdf(file=args$max,width=20,height=7)
pmaxwait
