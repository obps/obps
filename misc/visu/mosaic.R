#!/usr/bin/env Rscript

'usage: mosaic.R <input_files>... [-o <output>]
tool.R -h | --help

options:
<input_files>                   The input data.
-o <output>                     Output file.
-h , --help                     Show this screen.
' -> doc

library(docopt)
args<- docopt(doc)

library('ggplot2')
library('ggmosaic')
library('dplyr')
library('directlabels')


theme_bw_tuned<-function()
{
  return(theme_bw() +theme(
                           plot.title = element_text(face="bold", size=10),
                           axis.title.x = element_text(face="bold", size=10),
                           axis.title.y = element_text(face="bold", size=10, angle=90),
                           axis.text.x = element_text(size=10),
                           axis.text.y = element_text(size=10),
                           panel.grid.minor = element_blank(),
                           legend.key = element_rect(colour="black"))
  )
}

dfs=data.frame()
for (filename in args$input_files) {
  d=read.delim(filename)
  names(d)<-c("Policy")
  d$t = seq(1,nrow(d))
  d$t = d$t
  dfs<-rbind(dfs,d)
}

dfs$t = floor(0.1 * dfs$t)
dfs$t = dfs$t*10

ti=table(dfs$t,dfs$Policy)
tid=as.data.frame(prop.table(ti,1))

names(tid)<-c("t","Policy","Freq")
tid$t=as.numeric(tid$t)
tid$Freq=as.numeric(tid$Freq)

tid$t=tid$t*3600*24*7
tmi=min(tid$t)
tid$t=tid$t-tmi
tma=max(tid$t)



timestamp_to_date <- function(timestamp){
  return(as.POSIXct(timestamp, origin="1970-01-01 01:00.00", tz="Europe/Paris"))
}

library(lubridate)
mymonth <- function(x){
  month(timestamp_to_date(x),label=TRUE)
}

ml=(tma-tmi)/6
brkx=seq(from = tmi, to = tma, by = ml)
labx=sapply(brkx,mymonth)

pdf(args$o,width=5.5, height=4)
df=arrange(tid,Policy,t)
df$Policy=as.character(df$Policy)
head(df[with(df, order(df$Policy)),])
head(df)

ggplot(df,aes(x = t, y = Freq, fill = Policy)) +
  geom_area(position='stack',alpha=0.7)+
  geom_line(position='stack')+
  geom_segment(x=tmi,y=0,xend=tma,yend=0)+
  theme_bw_tuned()+
  scale_fill_brewer(palette="Blues")+
  scale_x_continuous(breaks = brkx, labels = labx) +
  labs( x = "Date",
        y = "Average share of policies used")

#ggplot(data=dfs)+
  #geom_histogram(aes(t,fill=policy),binwidth=l/10,)

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
