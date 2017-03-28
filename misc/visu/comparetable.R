#!/usr/bin/env Rscript
library(dplyr)
library(docopt)
library(ggplot2)
library(reshape2)
library(xtable)

'usage: tool.R <input1> <input2> [--o=<out> ]
        tool.R -h | --help
 ' -> doc
args <- docopt(doc)

options(stringsAsFactors=FALSE)

load <- function(filename,id,idsec) {
  data=read.csv(filename,sep=' ',header=FALSE)

  names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')
  A <- function(x) gsub(":1","",unlist(strsplit(x,"[.]"))[as.numeric(id)])
  B <- function(x) gsub(":1","",unlist(strsplit(x,"[.]"))[as.numeric(idsec)])

  data$Reservation=sapply(data$name,A)
  data$Backfilling=sapply(data$name,B)

  df=merge(merge(aggregate(meanwait ~ Reservation * Backfilling, data = data, FUN = mean),
                 aggregate(maxwait ~ Reservation * Backfilling, data = data, FUN = max),
                 by=c("Reservation","Backfilling")),
           merge(aggregate(meanbsld ~ Reservation * Backfilling, data = data, FUN = mean),
                 aggregate(maxbsld ~ Reservation * Backfilling, data = data, FUN = max),
                 by=c("Reservation","Backfilling")),
           by=c("Reservation","Backfilling"))

  df$meanwait=as.numeric(df$meanwait)
  df$meanbsld=as.numeric(df$meanbsld)
  df$maxwait=as.numeric(df$maxwait)
  df$maxbsld=as.numeric(df$maxbsld)

  return(df)
}

dfm=load(args$input1,3,2)
dfm2=load(args$input2,3,2)
head(dfm)
head(dfm2)

wspf=dfm[which(dfm$Backfilling=="exp" & dfm$Reservation=="exp"),]$meanwait
wspf2=dfm2[which(dfm2$Backfilling=="exp" & dfm2$Reservation=="exp"),]$meanwait

wsqf=dfm[which(dfm$Backfilling=="sqf" & dfm$Reservation=="sqf"),]$meanwait
wsqf2=dfm2[which(dfm2$Backfilling=="sqf" & dfm2$Reservation=="sqf"),]$meanwait

m<-rbind(c(wspf,wspf2),c(wsqf,wsqf2))
print(m)
colnames(m)=c("CTC-SP2","SDSC-SP2")
rownames(m)=c("EASY-EXP-EXP","EASY-SQF-SQF")

sink(args$o)
print.xtable(
  xtable(m,
         caption = "AvgWait performance of EASY-EXP-EXP and EASY-SQF-SQF on the original CTC-SP2 and SDSC-SP2 traces.",
         label = "tab:context"),
  include.rownames=T,
  )
sink()

