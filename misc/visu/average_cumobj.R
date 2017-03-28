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

swf_read <- function(f)
{
  df <- read.table(f,comment.char=';')
  names(df) <- c('job_id','submit_time','wait_time','run_time','proc_alloc','cpu_time_used','mem_used','proc_req','time_req','mem_req','status','user_id','group_id','exec_id','queue_id','partition_id','previous_job_id','think_time')
  return(df)
}

timestamp_to_date <- function(timestamp){
  return(as.POSIXct(timestamp, origin="1970-01-01 01:00.00", tz="Europe/Paris"))
}

d=swf_read(args$input_files[1])
mis = min(d$submit_time)
mas = max(d$submit_time)
interpolation_points = seq(from = 0, to = mas-mis, by = 60000)

interpolateds=data.frame(time=double(),value=double(),id=character())

for (filename in args$input_files) {
  d=swf_read(filename)

  d=d[order(d$submit_time),]
  d$csum=cumsum(as.numeric(d$wait_time))
  mis = min(d$submit_time)

  interpolated = approx(x= d$submit_time-mis, y=d$csum, xout = interpolation_points, method = "constant")

  interpolateds<-rbind(interpolateds,data.frame(time=interpolated$x,value=interpolated$y,id=filename))
}

g_interpolateds = group_by(interpolateds,time)
d=summarise(g_interpolateds,mean(value),max(value),min(value),sd(value))
names(d)=c("time","mean_obj","min_obj","max_obj")
write.table(d,args$o)
