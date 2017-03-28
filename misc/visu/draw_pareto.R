#!/usr/bin/env Rscript
library(dplyr)
library(docopt)
library(ggplot2)
library(reshape2)
library(xtable)

'usage: tool.R <title> <i1> <i2> <id1> <id2> <id3> <id4> [--os=<outs> ] [--outpareto=<out> ] [--outparetobsld=<out2> ] [--ot=<out3>] [--outparallel=<out3>] [--ob=<out3>]
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
  #d  = aggregate(meanwait ~ Reservation * Backfilling, data = data, FUN = mean)
  #d2 = aggregate(maxwait ~ Reservation * Backfilling, data = data, FUN = max)
       #aggregate(meanbsld ~ Reservation * Backfilling, data = data, FUN = mean),
       #aggregate(maxbsld ~ Reservation * Backfilling, data = data, FUN = max),

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
  colnames(dfsd)=c("Reservation","Backfilling","meanwaitsd","maxwaitsd","meanbsldsd","maxbsldsd")
  df=merge(df,dfsd,by=c("Reservation","Backfilling"))

  #print(df)


  df$meanwait=as.numeric(df$meanwait)
  df$meanbsld=as.numeric(df$meanbsld)
  df$maxwait=as.numeric(df$maxwait)
  df$maxbsld=as.numeric(df$maxbsld)
  df$meanwaitsd=as.numeric(df$meanwaitsd)
  df$meanbsldsd=as.numeric(df$meanbsldsd)
  df$maxwaitsd =as.numeric(df$maxwaitsd)
  df$maxbsldsd =as.numeric(df$maxbsldsd)


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


dfm=load(args$i1,args$id1,args$id2)
dfm2=load(args$i2,args$id3,args$id4)
#summary(dfm)
#summary(dfm2)
#print(dfm)

D = dfm[order(dfm$meanwait,dfm$maxwait,decreasing=FALSE),]
front = D[which(!duplicated(cummin(D$maxwait))),]
dfmm = merge(dfm,dfm2,by=c("Reservation","Backfilling"))
dfmm$mxwdiff = abs(dfmm$maxwait.y - dfmm$maxwait.x)
dfmm$mnwdiff = abs(dfmm$meanwait.y - dfmm$meanwait.x)
dfmm$mxbdiff = abs(dfmm$maxbsld.y - dfmm$maxbsld.x)
dfmm$mnbdiff = abs(dfmm$meanbsld.y - dfmm$meanbsld.x)
#summary(dfmm)

sink(args$ot)
print.xtable(
  xtable(summary(data.frame("NormMaxWait"=dfmm$mxwdiff
                            ,"NormAvgWait"=dfmm$mnwdiff
                            ,"NormMaxBSLD"=dfmm$mxbdiff
                            ,"NormAvgBSLD"=dfmm$mnbdiff),digits=3),
         caption = "Absolute value of the shift in the normalized values of MaxWait, AvgWait, MaxBsld, and AvgBsld between training and testing trace.",
         label = "tab:shift"),
  include.rownames=F,
  sanitize.colnames.function=function(x)gsub("\\."," ",x)
  )
sink()

pdf(file=args$os,width=10,height=8)
ggplot(dfm, aes(x=meanwait,y=maxwait,color=Reservation,shape=Backfilling))+
geom_point(size=4)+
geom_line(data=front,aes(x=meanwait,y=maxwait))+
geom_errorbar(aes(ymax = maxwait + maxwaitsd, ymin=maxwait - maxwaitsd),alpha=0.7,width=200,size=0.2)+
geom_errorbarh(aes(xmax = meanwait + meanwaitsd, xmin= meanwait - meanwaitsd),alpha=0.7,height=10000,size=0.2)+
theme_bw_tuned()+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)))+
scale_color_brewer(palette="Dark2")+
xlab("Average AvgWait cost")+
ylab("Average MaxWait cost")

eid=which(dfm2$Backfilling=="fcfs" & dfm2$Reservation=="fcfs")
dfm2$meanwaitsd=dfm2$meanwaitsd/dfm2$meanwait[eid]
dfm2$meanbsldsd=dfm2$meanbsldsd/dfm2$meanbsld[eid]
dfm2$maxbsldsd=dfm2$maxbsldsd/dfm2$maxbsld[eid]
dfm2$maxwaitsd=dfm2$maxwaitsd/dfm2$maxwait[eid]
dfm2$meanwait=dfm2$meanwait/dfm2$meanwait[eid]
dfm2$meanbsld=dfm2$meanbsld/dfm2$meanbsld[eid]
dfm2$maxbsld=dfm2$maxbsld/dfm2$maxbsld[eid]
dfm2$maxwait=dfm2$maxwait/dfm2$maxwait[eid]

eid=which(dfm$Backfilling=="fcfs" & dfm$Reservation=="fcfs")
dfm$meanwaitsd=dfm$meanwaitsd/dfm$meanwait[eid]
dfm$meanbsldsd=dfm$meanbsldsd/dfm$meanbsld[eid]
dfm$maxbsldsd=dfm$maxbsldsd/dfm$maxbsld[eid]
dfm$maxwaitsd=dfm$maxwaitsd/dfm$maxwait[eid]
dfm$meanwait=dfm$meanwait/dfm$meanwait[eid]
dfm$meanbsld=dfm$meanbsld/dfm$meanbsld[eid]
dfm$maxbsld=dfm$maxbsld/dfm$maxbsld[eid]
dfm$maxwait=dfm$maxwait/dfm$maxwait[eid]


D = dfm[order(dfm$meanwait,dfm$maxwait,decreasing=FALSE),]
front = D[which(!duplicated(cummin(D$maxwait))),]
dfmm = merge(dfm,dfm2,by=c("Reservation","Backfilling"))
dfmm$mxwdiff = abs(dfmm$maxwait.y - dfmm$maxwait.x)
dfmm$mnwdiff = abs(dfmm$meanwait.y - dfmm$meanwait.x)
dfmm$mxbdiff = abs(dfmm$maxbsld.y - dfmm$maxbsld.x)
dfmm$mnbdiff = abs(dfmm$meanbsld.y - dfmm$meanbsld.x)
#summary(dfmm)

sink(args$ot)
print.xtable(
  xtable(summary(data.frame("NormMaxWait"=dfmm$mxwdiff
                            ,"NormAvgWait"=dfmm$mnwdiff
                            ,"NormMaxBSLD"=dfmm$mxbdiff
                            ,"NormAvgBSLD"=dfmm$mnbdiff),digits=3),
         caption = "Absolute value of the shift in the normalized values of MaxWait, AvgWait, MaxBsld, and AvgBsld between training and testing trace.",
         label = "tab:shift"),
  include.rownames=F,
  sanitize.colnames.function=function(x)gsub("\\."," ",x)
  )
sink()

pdf(file=args$outpareto,width=10,height=4.4)
ggplot(dfm)+
geom_point(data=dfm, aes(x=meanwait,y=maxwait,color=Reservation,shape=Backfilling),size=4,alpha=0.4)+
geom_point(data=dfm2, aes(x=meanwait,y=maxwait,color=Reservation,shape=Backfilling),size=4)+
geom_segment(data=dfmm, aes(x=meanwait.x,y=maxwait.x,xend=meanwait.y,yend=maxwait.y),linetype="dotdash",alpha=0.4)+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)))+
scale_color_brewer(palette="Dark2")+
theme_bw_tuned()+
xlab("Normalized mean AvgWait cost")+
ylab("Normalized mean MaxWait cost")

pdf(file=args$outparetobsld,width=10,height=4.4)
D = dfm[order(dfm$meanbsld,dfm$maxbsld,decreasing=FALSE),]
front = D[which(!duplicated(cummin(D$maxbsld))),]
ggplot(dfm)+
geom_point(data=dfm, aes(x=meanbsld,y=maxbsld,color=Reservation),size=4,shape=17,alpha=0.4)+
geom_point(data=dfm2, aes(x=meanbsld,y=maxbsld,color=Reservation),size=4,shape=19)+
geom_segment(data=dfmm, aes(x=meanbsld.x,y=maxbsld.x,xend=meanbsld.y,yend=maxbsld.y),linetype="dotdash",alpha=0.4)+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)))+
scale_color_brewer()+
geom_line(data=front,aes(x=meanbsld,y=maxbsld))+
theme_bw_tuned()


dfmm1 <- rename(dfmm, Train = meanwait.x,
       Test = meanwait.y)

dfmmm <- melt(dfmm1,measure.vars=c("Train","Test"), id.vars=c("Reservation","Backfilling"))
#print(summary(dfmmm))
dfmmm$t=mapply(paste,dfmm$Backfilling,dfmm$Reservation)

if (args$title=="l_kth_sp") {
pdf(file=args$outparallel,width=3.5,height=4.4)
ggplot(dfmmm) +
geom_line(aes(x=variable, y=value, group=t, color=Reservation))+
geom_point(aes(x=variable, y=value, shape=Backfilling))+
ylab("Normalized mean AvgWait cost")+
xlab(sprintf("Worst MaxWait: \n %0.1f%% on Test\n %0.1f%% on Train\n Learned Performance: \n MeanWait: %0.1f%%\n MaxWait: %0.1f%%"
             ,100*max(dfmm$maxwait.y)
             ,100*max(dfmm$maxwait.x)
             ,100*dfmm$meanwait.y[which.min(dfmm$meanwait.x)]
             ,100*dfmm$maxwait.y[which.min(dfmm$meanwait.x)]))+
scale_color_brewer(palette="Dark2")+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)))+
theme_bw_tuned()+
ggtitle(args$title)
}else{
pdf(file=args$outparallel,width=2,height=4.4)
ggplot(dfmmm) +
geom_line(aes(x=variable, y=value, group=t, color=Reservation))+
geom_point(aes(x=variable, y=value, shape=Backfilling))+
ylab("Normalized mean AvgWait cost")+
xlab(sprintf("Worst MaxWait: \n %0.1f%% on Test\n %0.1f%% on Train\n Learned Performance: \n MeanWait: %0.1f%%\n MaxWait: %0.1f%%"
             ,100*max(dfmm$maxwait.y)
             ,100*max(dfmm$maxwait.x)
             ,100*dfmm$meanwait.y[which.min(dfmm$meanwait.x)]
             ,100*dfmm$maxwait.y[which.min(dfmm$meanwait.x)]))+
scale_color_brewer(palette="Dark2",guide=FALSE)+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)),guide=FALSE)+
theme_bw_tuned()+
ggtitle(args$title)
}


dfmm2 <- rename(dfmm, Train = meanbsld.x,
       Test = meanbsld.y)

dfmmm <- melt(dfmm2,measure.vars=c("Train","Test"), id.vars=c("Reservation","Backfilling"))
dfmmm$t=mapply(paste,dfmm$Backfilling,dfmm$Reservation)

if (args$title=="l_kth_sp") {
pdf(file=args$ob,width=3.5,height=4.4)
ggplot(dfmmm) +
geom_line(aes(x=variable, y=value, group=t, color=Reservation))+
geom_point(aes(x=variable, y=value, shape=Backfilling))+
ylab("Normalized mean AvgBsld cost")+
xlab(sprintf("Worst MaxBsld: \n %0.1f%% on Test\n %0.1f%% on Train\n Learned Performance: \n MeanBsld: %0.1f%%\n MaxBsld: %0.1f%%"
             ,100*max(dfmm$maxbsld.y)
             ,100*max(dfmm$maxbsld.x)
             ,100*dfmm$meanbsld.y[which.min(dfmm$meanwait.x)]
             ,100*dfmm$maxbsld.y[which.min(dfmm$meanwait.x)]))+
scale_color_brewer(palette="Dark2")+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)))+
theme_bw_tuned()+
ggtitle(args$title)
}else{
pdf(file=args$ob,width=2,height=4.4)
ggplot(dfmmm) +
geom_line(aes(x=variable, y=value, group=t, color=Reservation))+
geom_point(aes(x=variable, y=value, shape=Backfilling))+
ylab("Normalized mean AvgBsld cost")+
xlab(sprintf("Worst MaxBsld: \n %0.1f%% on Test\n %0.1f%% on Train\n Learned Performance: \n MeanBsld: %0.1f%%\n MaxBsld: %0.1f%%"
             ,100*max(dfmm$maxbsld.y)
             ,100*max(dfmm$maxbsld.x)
             ,100*dfmm$meanbsld.y[which.min(dfmm$meanbsld.x)]
             ,100*dfmm$maxbsld.y[which.min(dfmm$meanbsld.x)]))+
scale_color_brewer(palette="Dark2",guide=FALSE)+
scale_shape_manual(values=1:nlevels(factor(dfm$Reservation)),guide=FALSE)+
theme_bw_tuned()+
ggtitle(args$title)
}
