#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R --in=<input>... --lab=<lab>... [--out=<output>] [--out2=<output>]
        tool.R -h | --help

options:
 --in=<input>    Input file  [Default: none]
 --lab=<lab>     Plot label  [Default: none]
 --out=<output>  Output file [Default: tmpbars.pdf]
 --out2=<output>  Output file [Default: tmpnormalized.pdf]
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)

df <- data.frame(id=double(),
                 meanwait=double(),
                sd=double(),
                q1=double(),
                q2=double(),
                Policy=character())

names(df)=c('id','meanwait','sd','q1','q2','Policy')

for (i in 1:length(args$"--in")){
  data=read.csv(args$"--in"[i],sep=',',header=TRUE, stringsAsFactors=FALSE)
  data$Policy=args$"--lab"[i]
  names(data)=c('truc','id','meanwait','sd','q1','q2','Policy')

  df <- rbind.data.frame(data,df)
}

names(df)=c('truc','id','meanwait','sd','q1','q2','Policy')
mww=df[which(df$Policy=="fcfs"),]$meanwait
df$nmw=df$meanwait / mww

theme_bw_tuned<-function()
{
	return(theme_bw() +theme(
		plot.title = element_text(face="bold", size=10),
		axis.title.x = element_text(face="bold", size=10),
		axis.title.y = element_text(face="bold", size=10, angle=90),
		axis.text.x = element_text(size=10),
		axis.text.y = element_text(size=10),
		panel.grid.minor = element_blank(),
		legend.key = element_rect(colour="white"))
         )
}

plot=ggplot(df,aes(id,meanwait,color=Policy))+
  geom_point()+
  geom_line()+
  geom_errorbar(aes(ymin=q1,ymax=q2),width=0.01)+
  xlab("Week number")+
  ylab("AvgWait performance")+
  scale_color_brewer(palette="Dark2")+
  theme_bw_tuned()

pdf(file=args$out,width=10,height=2)
plot

plot=ggplot(df,aes(id,nmw,color=Policy))+
  geom_point()+
  geom_line()+
  xlab("Week number")+
  ylab("normalized AvgWait performance")+
  scale_color_brewer(palette="Dark2")+
  theme_bw_tuned()

pdf(file=args$out2,width=10,height=2)
plot
