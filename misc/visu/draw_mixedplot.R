#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R --in=<input>... --lab=<lab>... --type=<type>... [--out=<output>]
        tool.R -h | --help

options:
 --in=<input>    Input file  [Default: none]
 --lab=<lab>     Plot label  [Default: none]
 --out=<output>  Output file [Default: tmpmixed.pdf]
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)

df <- data.frame(meanwait=double(),
                sd=double(),
                q1=double(),
                q2=double(),
                name=double(),
                type=character(),
                type2=character(),
                stringsAsFactors=FALSE)
names(df)=c('meanwait','sd','q1','q2','name','type')


for (i in 1:length(args$"--in")){
  data=read.csv(args$"--in"[i],sep=' ',header=FALSE, stringsAsFactors=FALSE)
  names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')

  if (args$lab[i] == "expansionfactor") lab <- 0
  else if (args$lab[i] == "LF") lab <- 1
  else lab <- as.numeric(args$lab[i])

  if (args$type[i] == "train") type2 <- "training"
  else type2 <- "testing"

  quant=quantile(as.numeric(data$meanwait),probs=c(0.20,0.80))

  nr = list(mean(as.numeric(data$meanwait)),
            sd(as.numeric(data$meanwait)),
            quant[[1]],
            quant[[2]],
            lab,
            args$type[i],
            type2)

  df <- rbind.data.frame(nr,df)
}

names(df)=c('meanwait','sd','q1','q2','name','type','type2')
summary(df)

plot=ggplot(df,aes(name,meanwait,color=type))+
  facet_grid(type2 ~ ., scales = "free_y") +
  geom_point()+
  geom_line()+
  geom_errorbar(aes(ymin=q1,ymax=q2),width=0.01)+
  #scale_x_continuous(limits=args$lab,labels=args$lab)+
  xlab("Mixing proportion")+
  ylab("Average waiting time performance")

pdf(file=args$out,width=20,height=7)
plot
