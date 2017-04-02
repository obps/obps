#!/usr/bin/env Rscript

'usage: tool.R <input_files> ...  [-o <output>] [-i <scalefile>] [--legend] [-t <trace>]
tool.R -h | --help

options:
<input_files>                   The input data.
-o <output>                     Output file.
-i <scalefile>                  Scale file.
-t <trace>                      Trace name
-h , --help                     Show this screen.
--legend                        Show the legend
' -> doc

library(docopt)
args<- docopt(doc)

library('ggplot2')
library('dplyr')


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

dfs=data.frame()


for (filename in args$input_files) {
  d=read.table(filename)
  d$name=filename
  dfs<-rbind(dfs,d)
}


dummyqp <- function (x) {
  as.numeric(quantile(x,probs=c(0.9),na.rm=TRUE))
}
dummyqn <- function (x) {
  as.numeric(quantile(x,probs=c(0.1),na.rm=TRUE))
}

dscale=read.table(args$i)
dfs$value=dfs$value/dscale$mean_obj[nrow(dscale)]

dfs = group_by(dfs,time,id)
dfs=summarise(dfs,mean(value),max(value),min(value),sd(value),dummyqp(value),dummyqn(value))

names(dfs)=c("time","name","mean_obj","max_obj","min_obj","sd_obj","sdn","sdp")

#dfs$time=lapply(dfs$time,timestamp_to_date)

timestamp_to_date <- function(timestamp){
  return(as.POSIXct(timestamp, origin="1970-01-01 01:00.00", tz="Europe/Paris"))
}

library(lubridate)
mymonth <- function(x){
  month(timestamp_to_date(x),label=TRUE)
}

myfl <- function(x){
  return(sprintf("%0.0f%%", x*100))
}

#summary(dfs)
library(directlabels)

#tmi=min(dfs$time)
tma=max(dfs$time, na.rm = TRUE)
tmi=min(dfs$time, na.rm = TRUE)
ml=(tma-tmi)/6
brkx=seq(from = tmi, to = tma, by = ml)
labx=sapply(brkx,mymonth)

moma=max(dfs$mean_obj, na.rm = TRUE)
momi=min(dfs$mean_obj, na.rm = TRUE)
brky=seq(from = momi, to = moma, by = (moma-momi)/5)
laby=sapply(brky,myfl)

print(moma)
print(momi)

pdf(args$o,width=5.5, height=4)
p=ggplot(dfs,aes(x=time-tmi,y=mean_obj,fill=name,color=name))+
  geom_line()+
  geom_ribbon(data=dfs,aes(x=time-tmi,ymin=sdn,ymax=sdp,fill=name,color=name),alpha=0.03,linetype="dashed",size=0.35)+
  expand_limits(x = c(tmi, tma+(tma-tmi)*0.15))+
  #scale_x_continuous(limits=c(min(timestamp_to_date(dfs$time)),max(timestamp_to_date((dfs$time))-min(timestamp_to_date(dfs$time)))))+
  scale_x_continuous(breaks = brkx, labels = labx) +
  scale_y_continuous(breaks = brky, labels = laby) +
  geom_segment(x=tmi,y=0,xend=tma,yend=0,color="black")+
  annotate("text",x=tma+(tma-tmi)*0.055,y=0,label="FCFS",size=4,color="black")+
  theme_bw_tuned()+
  scale_color_brewer(palette="Paired",guide=FALSE)+
  scale_fill_brewer(palette="Paired",guide=FALSE)+
  labs(name = "Algorithm",
         x = "Date",
         y = "Avg. Cumulative Waiting Time Reduction",
         title = args$t)
  direct.label(p,"last.qp")

#pdf(args$o,width=7)
#ggplot(dfs,aes(x=timestamp_to_date(time),y=mean_obj,ymin=sdn,ymax=sdp,fill=name,color=name),)+
  #geom_line()+
  #geom_ribbon(alpha=0.03,linetype="dashed")+
  #theme_bw_tuned()+
  #scale_color_brewer(palette="Dark2",guide=FALSE)+
  #scale_fill_brewer(palette="Dark2",guide=FALSE)+
  #labs(name = "Algorithm",
         #x = "Time",
         #y = "Avg. Wait. Time cumulative difference",
         #title = args$t)
#}
