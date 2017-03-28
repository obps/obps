#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)
library(reshape2)

'usage: compare_weekvalues.R <input> [--out=<output>]
        compare_weekvalues.R -h | --help

options:
 <input>         Input file  [Default: none]
 --out=<output>  Output file [Default: tmpbars.pdf]
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)

df=read.csv(args$"<input>",sep=' ',header=FALSE, stringsAsFactors=FALSE)
names(df)=c('id','depth','backcount')
df$id = 1:nrow(df)
df2=melt(df,id.vars=c('id'))
summary(df2)

plot=ggplot(df2,aes(id,value,color=variable))+
  geom_point()+
  geom_line()+
  xlab("Week")+
  ylab("Value")

pdf(file=args$out,width=20,height=7)
plot
