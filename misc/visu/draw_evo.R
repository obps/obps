#!/usr/bin/env Rscript
library(dplyr)
library(docopt)
library(ggplot2)
library(reshape2)
library(xtable)

'usage: tool.R [ --intrain=<train>... ] [--intest=<test>... ] [--th=<th>... ] [--owait=<out>] [--obsld=<out>] [--tname=<tname>]

        tool.R -h | --help
 ' -> doc

args <- docopt(doc)

options(stringsAsFactors=FALSE)
scalar1 <- function(x) {(x-min(x))/(max(x)-min(x))}

load <- function(filename,id,idsec) {
  data=read.csv(filename,sep=' ',header=FALSE)

  names(data)=c('meanwait','maxwait','meanbsld','maxbsld','meanflow','maxflow','name')

  A <- function(x) gsub(":1","",unlist(strsplit(x,"[.]"))[as.numeric(id)])
  B <- function(x) gsub(":1","",unlist(strsplit(x,"[.]"))[as.numeric(idsec)])
  data$Reservation=sapply(data$name,A)
  data$Backfilling=sapply(data$name,B)

  print(head(data))

  C <- function(x) paste(unlist(strsplit(x,"[.]"))[as.numeric(id+1)],unlist(strsplit(x,"[.]"))[as.numeric(id+2)],unlist(strsplit(x,"[.]"))[as.numeric(id+3)])
  data$Id=sapply(data$name,C)

  eid=which(data$Backfilling=="fcfs" & data$Reservation=="fcfs")
  data$meanwait=data$meanwait/data$meanwait[eid]
  data$meanbsld=data$meanbsld/data$meanbsld[eid]
  data$maxbsld=data$maxbsld/data$maxbsld[eid]
  data$maxwait=data$maxwait/data$maxwait[eid]

  df=merge(merge(aggregate(meanwait ~ Reservation * Backfilling, data = data, FUN = mean),
                 aggregate(maxwait ~ Reservation * Backfilling, data = data, FUN = mean),
                 by=c("Reservation","Backfilling")),
           merge(aggregate(meanbsld ~ Reservation * Backfilling, data = data, FUN = mean),
                 aggregate(maxbsld ~ Reservation * Backfilling, data = data, FUN = mean),
                 by=c("Reservation","Backfilling")),
           by=c("Reservation","Backfilling"))
  dfsd=merge(merge(aggregate(meanwait ~ Reservation * Backfilling, data = data, FUN = sd),
                 aggregate(maxwait ~ Reservation * Backfilling, data = data, FUN = sd),
                 by=c("Reservation","Backfilling")),
           merge(aggregate(meanbsld ~ Reservation * Backfilling, data = data, FUN = sd),
                 aggregate(maxbsld ~ Reservation * Backfilling, data = data, FUN = sd),
                 by=c("Reservation","Backfilling")),
           by=c("Reservation","Backfilling"))
  colnames(dfsd)=c("Reservation","Backfilling","meanwait-sd","maxwait-sd","meanbsld-sd","maxbsld-sd")
  df=merge(df,dfsd,by=c("Reservation","Backfilling"))


  return(df)
}

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

dfth<-data.frame(th=double(),
                value=double(),
                type=character(),
                gentype=character())
colnames(dfth)=c("th","value","type")
dfthb<-data.frame(th=double(),
                value=double(),
                type=character(),
                gentype=character())
colnames(dfthb)=c("th","value","type")

for (i in 1:length(args$intrain)) {
  d = load(args$intrain[i],4,2)
  dt = load(args$intest[i],4,2)
  th = as.numeric(args$th[i])

  Bfmw = d[which.min(d$meanwait),]$Backfilling
  Resmw = d[which.min(d$meanwait),]$Reservation
  idmw = which(d$Backfilling == Bfmw & d$Reservation == Resmw)
  idmb = which(d$Backfilling == Bfmw & d$Reservation == Resmw)

  idgenmw = which(dt$Backfilling == Bfmw & dt$Reservation == Resmw)
  Bfmb = d[which.min(d$meanbsld),]$Backfilling
  Resmb = d[which.min(d$meanbsld),]$Reservation
  idgenmb = which(dt$Backfilling == Bfmb & dt$Reservation == Resmb)

  dfth<-rbind(dfth, c(th,d$"meanwait-sd"[idmw],d$meanwait[idmw],"MeanWait","train"))
  dfth<-rbind(dfth, c(th,d$"maxwait-sd"[idmw],d$maxwait[idmw],"MaxWait","train"))
  dfthb<-rbind(dfthb, c(th,d$"meanbsld-sd"[idmb],d$meanbsld[idmb],"MeanBsld","train"))
  dfthb<-rbind(dfthb, c(th,d$"maxbsld-sd"[idmb],d$maxbsld[idmb],"MaxBsld","train"))

  dfth<-rbind(dfth, c(th,dt$"meanwait-sd"[idgenmw],dt$meanwait[idgenmw],"MeanWait","test"))
  dfth<-rbind(dfth, c(th,dt$"maxwait-sd"[idgenmw],dt$maxwait[idgenmw],"MaxWait","test"))
  dfthb<-rbind(dfthb, c(th,dt$"meanbsld-sd"[idgenmb],dt$meanbsld[idgenmb],"MeanBsld","test"))
  dfthb<-rbind(dfthb, c(th,dt$"maxbsld-sd"[idgenmb],dt$maxbsld[idgenmb],"MaxBsld","test"))
}
colnames(dfth)=c("th","sd","value","type","gentype")
colnames(dfthb)=c("th","sd","value","type","gentype")

dfth$th=as.numeric(dfth$th)
dfth$value=as.numeric(dfth$value)
dfth$sd=as.numeric(dfth$sd)
dfthb$th=as.numeric(dfthb$th)
dfthb$value=as.numeric(dfthb$value)
dfthb$sd=as.numeric(dfthb$sd)

pdf(file=args$owait,width=12,height=4.4)
ggplot(dfth,aes(x=th,y=value,color=gentype))+
geom_line()+
geom_segment(x=0,xend=max(dfth$th),y=1,yend=1,color="black")+
geom_errorbar(aes(ymax = value + sd, ymin=value - sd))+
facet_grid(type ~ .,scales="free")+
theme_bw_tuned()+
scale_color_brewer(palette="Dark2")+
xlab("T")+
ylab("Normalized cost")+
ggtitle(paste("Average and maximal waiting time as function of queue threshold for the",args$tname,"trace."))+
labs(color = "Trace type\n")

pdf(file=args$obsld,width=12,height=4.4)
ggplot(dfthb,aes(x=th,y=value,color=gentype))+
geom_line()+
geom_segment(x=0,xend=max(dfthb$th),y=1,yend=1,color="black")+
geom_errorbar(aes(ymax = value + sd, ymin=value - sd))+
facet_grid(type ~ .,scales="free")+
theme_bw_tuned()+
scale_color_brewer(palette="Dark2")+
xlab("T")+
ylab("Normalized cost")+
ggtitle(paste("Average and maximal bounded slowdown as function of queue threshold for the",args$tname,"trace."))+
labs(color = "Trace type\n")
