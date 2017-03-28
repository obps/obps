#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)
library(scatterplot3d)

'usage: tool.R <input> [--out=<output>]
        tool.R -h | --help

options:
 <input>    Input file  [Default: none]
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)

df <- data.frame(id=double(),
                 meanwait=double(),
                sd=double(),
                q1=double(),
                q2=double(),
                name=character(),
                explo=double(),
                budget=double())

df=read.csv(args$"<input>",sep=' ',header=TRUE, stringsAsFactors=FALSE)

names(df)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name','explo','budget')

print(df)

pdf(file=args$out,width=20,height=7)
with(df, {
   scatterplot3d(budget, explo, meanwait,
                 color="blue", pch=19,
                 type="h",
                 main="search grid for MCTS budget vs exploration param.",
                 xlab="MCTS search budget",
                 ylab="Exploration parameter",
                 zlab="Average waiting time")
})
