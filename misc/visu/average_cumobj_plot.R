#!/usr/bin/env Rscript

'usage: tool.R <input_files> ...  [-o <output>]
tool.R -h | --help

options:
<input_files>                   The input data.
-o <output>                     Output file.
-h , --help                     Show this screen.
' -> doc

library(docopt)
args<- docopt(doc)

#library('TTR')
#library('gridExtra')
library('ggplot2')
#library('reshape2')
#library('plyr')
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

timestamp_to_date <- function(timestamp){
  return(as.POSIXct(timestamp, origin="1970-01-01 01:00.00", tz="Europe/Paris"))
}

dfs=data.frame()


for (filename in args$input_files) {
  d=read.table(filename)
  d$name=filename
  dfs<-rbind(dfs,d)
}

pdf(args$o,width=20)
summary(dfs)
ggplot(dfs,aes(x=time,y=mean_obj,ymin=min_obj,ymax=max_obj,fill=name,color=name),)+
geom_line()+
geom_ribbon(alpha=0.01,linetype="dashed")+
theme_bw()
