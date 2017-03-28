#!/usr/bin/env Rscript

library(docopt)
library(ggplot2)

'usage: tool.R <input1> <input2>
        tool.R -h | --help

options:
 <input1>        The first data file.
 <input2>        The second tata file
 ' -> doc

args<- docopt(doc)

data1=read.csv(args$input1,sep=',',header=FALSE)
data2=read.csv(args$input2,sep=',',header=FALSE)

mnm=c('q','n','y',
      'resres',
      'resjobq',
      'iwk_now',
      'iday_now',
      'restime',
      'resourcestate_free',
      'l_j_running',
      'q_running',
      'l_waitqueue',
      'q_waitqueue')

names(data1)=mnm
names(data2)=mnm

summary(data1)
summary(data2)
