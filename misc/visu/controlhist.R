#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R <input1> <input2> [-o=<output1>]
        tool.R -h | --help

options:
 <input1>        The input data for truthful mcts.
 <input2>        The input data for cheating mcts.
 -o=<output>  Output file [Default: tmp.pdf]
 ' -> doc

args<- docopt(doc)

data1=read.csv(args$input1,sep=' ',header=FALSE)
data1$type="MCTS"
names(data1)=c('sjbf','fcfs','ratio','type')
data2=read.csv(args$input2,sep=' ',header=FALSE)
data2$type="MCTS-cheat"
names(data2)=c('sjbf','fcfs','ratio','type')

if (all(data2$ratio==Inf)) {
 data2=rbind(data2,list(0,0,99,'MCTS-cheat'))
}

df=rbind(data1,data2)

p=ggplot(df,aes(x=ratio,fill=type,color=type))+
  geom_histogram(aes(y=(..density..)),position="dodge")+
  geom_density(alpha=0.1,aes(color=type,fill=type))+
  xlab("Control ratio")+
  ylab("Proportion of experiments")

pdf(file=args$o,width=20,height=7)
p
